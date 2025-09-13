# AHB to APB Bridge Testbench
# File: tb_ahb_apb_bridge.v

`timescale 1ns/1ps

module tb_ahb_apb_bridge;

// Clock and reset
reg        HCLK;
reg        HRESETn;

// AHB Slave Interface signals
reg  [31:0] HADDR;
reg  [31:0] HWDATA;
reg  [1:0]  HTRANS;
reg         HWRITE;
reg  [2:0]  HSIZE;
reg  [2:0]  HBURST;
reg         HREADY_IN;
wire [31:0] HRDATA;
wire        HREADY_OUT;
wire [1:0]  HRESP;

// APB Master Interface signals
wire [31:0] PADDR;
wire [31:0] PWDATA;
wire [2:0]  PSEL;
wire        PENABLE;
wire        PWRITE;
wire [31:0] PRDATA;

// APB Slave models
wire [31:0] PRDATA0, PRDATA1, PRDATA2;
reg  [31:0] slave_data [0:2];

// Clock generation
initial begin
    HCLK = 0;
    forever #5 HCLK = ~HCLK; // 100MHz clock
end

// Reset generation
initial begin
    HRESETn = 0;
    #20 HRESETn = 1;
end

// Instantiate DUT (Device Under Test)
ahb_apb_bridge uut (
    .HCLK(HCLK),
    .HRESETn(HRESETn),
    .HADDR(HADDR),
    .HWDATA(HWDATA),
    .HTRANS(HTRANS),
    .HWRITE(HWRITE),
    .HSIZE(HSIZE),
    .HBURST(HBURST),
    .HREADY_IN(HREADY_IN),
    .HRDATA(HRDATA),
    .HREADY_OUT(HREADY_OUT),
    .HRESP(HRESP),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PRDATA(PRDATA)
);

// APB Slave 0 Model
apb_slave_model slave0 (
    .PCLK(HCLK),
    .PRESETn(HRESETn),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PSEL(PSEL[0]),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PRDATA(PRDATA0),
    .slave_id(8'h00)
);

// APB Slave 1 Model  
apb_slave_model slave1 (
    .PCLK(HCLK),
    .PRESETn(HRESETn),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PSEL(PSEL[1]),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PRDATA(PRDATA1),
    .slave_id(8'h01)
);

// APB Slave 2 Model
apb_slave_model slave2 (
    .PCLK(HCLK),
    .PRESETn(HRESETn),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PSEL(PSEL[2]),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PRDATA(PRDATA2),
    .slave_id(8'h02)
);

// PRDATA multiplexing
assign PRDATA = PSEL[0] ? PRDATA0 :
                PSEL[1] ? PRDATA1 :
                PSEL[2] ? PRDATA2 : 32'h0;

// Test stimulus
initial begin
    $display("AHB-APB Bridge Testbench Started");
    $dumpfile("ahb_apb_bridge.vcd");
    $dumpvars(0, tb_ahb_apb_bridge);
    
    // Initialize signals
    HADDR = 32'h0;
    HWDATA = 32'h0;
    HTRANS = 2'b00; // IDLE
    HWRITE = 1'b0;
    HSIZE = 3'b010; // 32-bit
    HBURST = 3'b000; // SINGLE
    HREADY_IN = 1'b1;
    
    // Wait for reset
    wait(HRESETn);
    repeat(5) @(posedge HCLK);
    
    $display("\n=== Test 1: Single Write Transaction ===");
    ahb_write(32'h80000004, 32'hDEADBEEF);
    
    $display("\n=== Test 2: Single Read Transaction ===");
    ahb_read(32'h80000004);
    
    $display("\n=== Test 3: Multiple Slave Access ===");
    ahb_write(32'h80010008, 32'h12345678); // Slave 1
    ahb_read(32'h80010008);
    
    ahb_write(32'h8002000C, 32'hABCDEF00); // Slave 2
    ahb_read(32'h8002000C);
    
    $display("\n=== Test 4: Burst Write Transaction (INCR4) ===");
    ahb_burst_write(32'h80000010, 32'h11111111, 3'b001); // INCR4
    
    $display("\n=== Test 5: Burst Read Transaction (INCR4) ===");
    ahb_burst_read(32'h80000010, 3'b001); // INCR4
    
    $display("\n=== Test 6: Invalid Address Access ===");
    ahb_write(32'hFFFFFFFF, 32'hBAD1BAD1); // Invalid address
    
    repeat(10) @(posedge HCLK);
    
    $display("\n=== All Tests Completed ===");
    $finish;
end

// Task for AHB single write
task ahb_write(input [31:0] addr, input [31:0] data);
    begin
        @(posedge HCLK);
        HADDR = addr;
        HTRANS = 2'b10; // NONSEQ
        HWRITE = 1'b1;
        
        @(posedge HCLK);
        HWDATA = data;
        HTRANS = 2'b00; // IDLE
        
        wait(HREADY_OUT);
        @(posedge HCLK);
        $display("Write: Addr=0x%08h, Data=0x%08h", addr, data);
    end
endtask

// Task for AHB single read
task ahb_read(input [31:0] addr);
    begin
        @(posedge HCLK);
        HADDR = addr;
        HTRANS = 2'b10; // NONSEQ
        HWRITE = 1'b0;
        
        @(posedge HCLK);
        HTRANS = 2'b00; // IDLE
        
        wait(HREADY_OUT);
        @(posedge HCLK);
        $display("Read: Addr=0x%08h, Data=0x%08h", addr, HRDATA);
    end
endtask

// Task for AHB burst write
task ahb_burst_write(input [31:0] start_addr, input [31:0] start_data, input [2:0] burst_type);
    integer i;
    reg [31:0] addr, data;
    begin
        addr = start_addr;
        data = start_data;
        
        for (i = 0; i < 4; i = i + 1) begin
            @(posedge HCLK);
            HADDR = addr;
            HTRANS = (i == 0) ? 2'b10 : 2'b11; // NONSEQ for first, SEQ for rest
            HWRITE = 1'b1;
            HBURST = burst_type;
            
            @(posedge HCLK);
            HWDATA = data;
            if (i == 3) HTRANS = 2'b00; // IDLE for last
            
            wait(HREADY_OUT);
            $display("Burst Write[%0d]: Addr=0x%08h, Data=0x%08h", i, addr, data);
            
            // Address increment logic
            addr = addr + 4;
            data = data + 1;
        end
    end
endtask

// Task for AHB burst read
task ahb_burst_read(input [31:0] start_addr, input [2:0] burst_type);
    integer i;
    reg [31:0] addr;
    begin
        addr = start_addr;
        
        for (i = 0; i < 4; i = i + 1) begin
            @(posedge HCLK);
            HADDR = addr;
            HTRANS = (i == 0) ? 2'b10 : 2'b11; // NONSEQ for first, SEQ for rest
            HWRITE = 1'b0;
            HBURST = burst_type;
            
            @(posedge HCLK);
            if (i == 3) HTRANS = 2'b00; // IDLE for last
            
            wait(HREADY_OUT);
            $display("Burst Read[%0d]: Addr=0x%08h, Data=0x%08h", i, addr, HRDATA);
            
            // Address increment logic
            addr = addr + 4;
        end
    end
endtask

endmodule

// APB Slave Model
module apb_slave_model (
    input  wire        PCLK,
    input  wire        PRESETn,
    input  wire [31:0] PADDR,
    input  wire [31:0] PWDATA,
    input  wire        PSEL,
    input  wire        PENABLE,
    input  wire        PWRITE,
    output reg  [31:0] PRDATA,
    input  wire [7:0]  slave_id
);

reg [31:0] memory [0:255]; // 256 words of memory
integer i;

// Initialize memory
initial begin
    for (i = 0; i < 256; i = i + 1) begin
        memory[i] = {slave_id, 8'h00, 16'h0000} + i;
    end
end

// APB slave behavior
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
        PRDATA <= 32'h0;
    end else if (PSEL && PENABLE) begin
        if (PWRITE) begin
            // Write operation
            memory[PADDR[9:2]] <= PWDATA;
            $display("APB Slave %d: Write Addr=0x%08h, Data=0x%08h", slave_id, PADDR, PWDATA);
        end else begin
            // Read operation
            PRDATA <= memory[PADDR[9:2]];
            $display("APB Slave %d: Read Addr=0x%08h, Data=0x%08h", slave_id, PADDR, memory[PADDR[9:2]]);
        end
    end
end

endmodule
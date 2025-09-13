# AHB to APB Bridge - Top Level Module
# File: ahb_apb_bridge.v

module ahb_apb_bridge (
    // AHB Slave Interface - Input from AHB Master
    input  wire        HCLK,
    input  wire        HRESETn,
    input  wire [31:0] HADDR,
    input  wire [31:0] HWDATA,
    input  wire [1:0]  HTRANS,
    input  wire        HWRITE,
    input  wire [2:0]  HSIZE,
    input  wire [2:0]  HBURST,
    input  wire        HREADY_IN,
    output wire [31:0] HRDATA,
    output wire        HREADY_OUT,
    output wire [1:0]  HRESP,
    
    // APB Master Interface - Output to APB Slaves
    output wire [31:0] PADDR,
    output wire [31:0] PWDATA,
    output wire [2:0]  PSEL,
    output wire        PENABLE,
    output wire        PWRITE,
    input  wire [31:0] PRDATA
);

// Internal registers and wires
reg [31:0] haddr_reg;
reg [31:0] hwdata_reg;
reg        hwrite_reg;
reg [2:0]  tempsel;
reg [1:0]  current_state;
reg [1:0]  next_state;

// State encoding
localparam ST_IDLE   = 2'b00;
localparam ST_SETUP  = 2'b01;
localparam ST_ACCESS = 2'b10;

// AHB transaction types
localparam IDLE     = 2'b00;
localparam NONSEQ   = 2'b10;
localparam SEQ      = 2'b11;

// Address decode logic
always @(*) begin
    if (haddr_reg[31:16] == 16'h8000)
        tempsel = 3'b001;  // APB Slave 0
    else if (haddr_reg[31:16] == 16'h8001)
        tempsel = 3'b010;  // APB Slave 1
    else if (haddr_reg[31:16] == 16'h8002)
        tempsel = 3'b100;  // APB Slave 2
    else
        tempsel = 3'b000;  // No slave selected
end

// Address and control capture
always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        haddr_reg <= 32'h0;
        hwdata_reg <= 32'h0;
        hwrite_reg <= 1'b0;
    end else if (HREADY_IN && HTRANS != IDLE) begin
        haddr_reg <= HADDR;
        hwrite_reg <= HWRITE;
        if (HWRITE)
            hwdata_reg <= HWDATA;
    end
end

// State machine
always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn)
        current_state <= ST_IDLE;
    else
        current_state <= next_state;
end

// Next state logic
always @(*) begin
    case (current_state)
        ST_IDLE: begin
            if (HTRANS != IDLE && HREADY_IN && tempsel != 3'b000)
                next_state = ST_SETUP;
            else
                next_state = ST_IDLE;
        end
        
        ST_SETUP: begin
            next_state = ST_ACCESS;
        end
        
        ST_ACCESS: begin
            next_state = ST_IDLE;
        end
        
        default: next_state = ST_IDLE;
    endcase
end

// APB signals generation
assign PADDR   = haddr_reg;
assign PWDATA  = hwdata_reg;
assign PWRITE  = hwrite_reg;
assign PSEL    = (current_state != ST_IDLE) ? tempsel : 3'b000;
assign PENABLE = (current_state == ST_ACCESS);

// AHB response signals
assign HRDATA     = PRDATA;
assign HREADY_OUT = (current_state == ST_IDLE) || (current_state == ST_ACCESS);
assign HRESP      = 2'b00; // OKAY response

endmodule
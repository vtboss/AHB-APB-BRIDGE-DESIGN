# PART 1: Data Collection Guide for Brother 
# Complete ISE Project Setup and Data Extraction

## 🎯 MISSION: Collect All Technical Data for AHB-APB Bridge Report

Hey! You're going to help gather all the technical data needed for your brother's final report. Don't worry - I'll guide you through every single step. Just follow this exactly!

## 📁 STEP 1: Project Setup (15 minutes)

### A. Create New ISE Project
1. **Launch ISE Design Suite**
   - Start → Programs → Xilinx ISE Design Suite → ISE Design Tools → Project Navigator
   
2. **Create New Project**
   - File → New Project
   - Project Name: `AHB_APB_Bridge_VT`
   - Location: `C:\xilinx_projects\AHB_APB_Bridge_VT`
   - Device Family: `Spartan6` (or whatever FPGA board you have)
   - Device: `xc6slx16` (or your specific device)
   - Package: `csg324`
   - Speed Grade: `-3`
   - Click **Next** → **Next** → **Finish**

### B. Add Source Files
1. **Add Main Design File**
   - Project → Add Source
   - Create New: **Verilog Module**
   - File Name: `ahb_apb_bridge`
   - Click **Next** → **Finish**
   - **COPY the entire code from `ahb_apb_bridge.v` file I provided**

2. **Add Testbench File**
   - Project → Add Source  
   - Create New: **Verilog Test Fixture**
   - File Name: `tb_ahb_apb_bridge`
   - Click **Next** → **Finish**
   - **COPY the entire code from `tb_ahb_apb_bridge.v` file I provided**

3. **Add Constraint File**
   - Project → Add Source
   - Create New: **User Constraints File (.ucf)**
   - File Name: `ahb_apb_bridge`
   - **COPY the entire code from `ahb_apb_bridge.ucf` file I provided**

4. **Set Top Module**
   - Right-click on `ahb_apb_bridge.v` in Sources window
   - Select **"Set as Top Module"**

## 📊 STEP 2: Data Collection Phase (30 minutes)

### A. Check Syntax First
1. **Select** `ahb_apb_bridge` in Sources window
2. **Expand** "Synthesize - XST" in Processes window
3. **Double-click** "Check Syntax"
4. **WAIT** for green checkmark ✅
5. **If RED X**: Look at Console tab, fix errors, try again

### B. Run Synthesis (GET DATA!)
1. **Double-click** "Synthesize - XST" in Processes window
2. **WAIT** (5-15 minutes - be patient!)
3. **Look for GREEN checkmark** ✅

### C. Extract Synthesis Data
1. **Right-click** on "Synthesize - XST"
2. **Select** "View XST Report"
3. **FIND Section 8.3: "Device Utilization Summary"**
4. **COPY EXACTLY** (write down these numbers):

```
SYNTHESIS DATA COLLECTION SHEET
========================================
Date: _________________
Time Started: _________
ISE Version: __________
Target Device: ________

DEVICE UTILIZATION SUMMARY:
Selected Device: ________________________

Number of Slice Registers: _______ out of _______ _____%
Number of Slice LUTs:      _______ out of _______ _____%
Number of occupied Slices: _______ out of _______ _____%
Number of MUXCYs used:     _______ out of _______ _____%
Number of IOs:             _______ 
Number of BUFGMUXs:        _______ out of _______ _____%
Number of DCM_CLKGENs:     _______ out of _______ _____%
Number of BRAM/FIFO:       _______ out of _______ _____%
Number of DSP48A1s:        _______ out of _______ _____%
```

5. **FIND Section 8.4: "Timing Summary"**
6. **COPY EXACTLY**:

```
TIMING SUMMARY (SYNTHESIS):
Maximum Frequency: _______ MHz
Minimum Period:    _______ ns  
Maximum Delay:     _______ ns
```

### D. Run Implementation
1. **Double-click** "Implement Design" in Processes window
2. **WAIT** (10-30 minutes - this takes longer!)
3. **Look for GREEN checkmark** ✅

### E. Extract Final Implementation Data
1. **Expand** "Implement Design" in Processes window
2. **Right-click** "Place & Route" 
3. **Select** "View Text Report"
4. **FIND "Constraint Summary"**
5. **COPY EXACTLY**:

```
FINAL IMPLEMENTATION DATA:
=========================================
Constraint: TS_HCLK = PERIOD "HCLK" ____ ns HIGH 50%
   _____ paths analyzed
   _____ endpoints analyzed  
   _____ failing endpoints
   _____ timing errors detected

Minimum period is: _______ ns
Maximum Frequency: _______ MHz

FINAL RESOURCE UTILIZATION:
Number of Slices:          _______ out of _______ _____%
Number of Slice Flip Flops: _______ out of _______ _____%
Number of 4 input LUTs:     _______ out of _______ _____%
Number of bonded IOBs:      _______ out of _______ _____%
Number of BUFGMUX:          _______ out of _______ _____%
Number of DCM_SP:           _______ out of _______ _____%

TIMING CONSTRAINT SUMMARY:
Constraint Name    | Requested | Actual    | Status
TS_HCLK           | _____ MHz | _____ MHz | _______
```

## 🌊 STEP 3: Waveform Capture (20 minutes)

### A. Setup Simulation
1. **Select** `tb_ahb_apb_bridge` in Sources window
2. **Expand** "ModelSim Simulator" (or ISim if no ModelSim)
3. **Double-click** "Simulate Behavioral Model"

### B. In ModelSim (or ISim)
1. **Add all signals**: 
   ```tcl
   add wave -radix hex /tb_ahb_apb_bridge/*
   add wave -radix binary /tb_ahb_apb_bridge/uut/current_state
   add wave -radix hex /tb_ahb_apb_bridge/uut/haddr_reg
   ```

2. **Run simulation**:
   ```tcl
   run 2000ns
   zoom full
   ```

3. **Take Screenshots** of these waveforms:
   - **AHB Single Write**: Around 100-300ns
   - **AHB Single Read**: Around 400-600ns  
   - **State Machine**: Show ST_IDLE → ST_SETUP → ST_ACCESS transitions
   - **APB Protocol**: Show PSEL, PENABLE, PADDR, PWDATA timing
   - **Burst Transfer**: Show multiple transfers

4. **Save Waveform**:
   ```tcl
   write format wave -window .main_pane.wave.interior.cs.body.pw.wf ahb_apb_waveform.do
   ```

## 📋 STEP 4: Generate Programming File
1. **Double-click** "Generate Programming File" 
2. **WAIT** for GREEN checkmark ✅
3. **Note**: File generated in project folder

## 📂 STEP 5: Organize All Files

Create this folder structure and COPY all files:
```
AHB_APB_Bridge_Data/
├── source_files/
│   ├── ahb_apb_bridge.v
│   ├── tb_ahb_apb_bridge.v  
│   └── ahb_apb_bridge.ucf
├── reports/
│   ├── synthesis_report.syr
│   ├── timing_report.twr
│   ├── par_report.par
│   └── utilization_report.txt
├── waveforms/
│   ├── ahb_single_write.png
│   ├── ahb_single_read.png
│   ├── state_machine.png
│   ├── apb_protocol.png
│   └── burst_transfer.png
└── data_sheets/
    ├── synthesis_data.txt (your handwritten notes)
    ├── implementation_data.txt (your handwritten notes)
    └── waveform_descriptions.txt
```

## 🔥 CRITICAL SUCCESS CRITERIA

**YOU MUST GET THESE NUMBERS:**
- [ ] Resource utilization (LUTs, FFs, Slices with percentages)
- [ ] Maximum frequency achieved (in MHz)
- [ ] Timing constraint status (PASSED/FAILED)  
- [ ] Setup violations count (should be 0)
- [ ] Hold violations count (should be 0)
- [ ] 5+ professional waveform screenshots

## ⚠️ TROUBLESHOOTING

**Problem: Synthesis RED X**
- Check Console tab for errors
- Usually missing semicolon or typo in Verilog
- Fix error and re-run

**Problem: Implementation fails**  
- Check if constraint file is properly loaded
- Try reducing clock frequency in UCF file
- Change `10 ns` to `15 ns` in TIMESPEC line

**Problem: No waveforms**
- Make sure testbench is selected as top module for simulation
- Check if ModelSim is properly configured

**Problem: Can't find reports**
- Reports are in project folder
- Look for files ending in .syr, .twr, .par

## ⏰ TIME TRACKING

**Fill this out as you go:**
- Project Setup Start: _______
- Synthesis Start: _______
- Synthesis Complete: _______
- Implementation Start: _______
- Implementation Complete: _______  
- Simulation Start: _______
- All Data Collected: _______

**TOTAL TIME**: Should be 1.5-2 hours

## 📞 EMERGENCY HELP

**If anything goes wrong:**
1. Take screenshot of error message
2. Note exact step you were on
3. Save project and close ISE
4. Restart ISE and try again
5. Write down what worked and what didn't

## 🎉 SUCCESS CHECKLIST

At the end, you should have:
- [ ] GREEN checkmarks for Synthesis ✅
- [ ] GREEN checkmarks for Implementation ✅  
- [ ] All resource numbers written down
- [ ] Maximum frequency number
- [ ] 5+ waveform screenshots saved
- [ ] All report files backed up
- [ ] Project folder organized

**CONGRATULATIONS!** You've just completed professional-level VLSI synthesis and implementation! This data will help create an industry-standard technical report that can be used for job applications.

Your brother will be very proud! 🚀💪
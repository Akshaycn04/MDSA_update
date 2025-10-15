package tb_mdsa_oen;

import Vector :: *;
import mdsa_types :: *;
import oddeven_sorter :: *;
import mdsa_oddeven :: *;

typedef enum {
    IDLE
    , WAIT_FOR_OUTPUT
    , DONE
} MDSA_TB_STAGE deriving(Bits, Eq, FShow);

(* synthesize *)
module mk_mdsa_oddeven_testbench(Empty);

    Reg#(MDSA_TB_STAGE) rg_mdsa_tb_stage <- mkReg(IDLE);
    Reg#(UInt#(32)) rg_cycle_count <- mkReg(0);
    
    Ifc_mdsa_oddeven mdsa_oddeven <- mk_mdsa_oddeven();
    
    // Helper function to create test data
    function MDSA_64 create_test_matrix();
    MDSA_64 matrix = unpack(0);

    // Hardcoded "random" values between 1..64 (no repetition)
    Integer vals[64];
    vals[0] = 37;  vals[1] = 4;   vals[2] = 58;  vals[3] = 19;
    vals[4] = 46;  vals[5] = 9;   vals[6] = 21;  vals[7] = 63;
    vals[8] = 15;  vals[9] = 54;  vals[10] = 1;  vals[11] = 35;
    vals[12] = 61; vals[13] = 29; vals[14] = 42; vals[15] = 17;
    vals[16] = 60; vals[17] = 7;  vals[18] = 50; vals[19] = 26;
    vals[20] = 39; vals[21] = 11; vals[22] = 28; vals[23] = 3;
    vals[24] = 48; vals[25] = 23; vals[26] = 33; vals[27] = 8;
    vals[28] = 45; vals[29] = 25; vals[30] = 6;  vals[31] = 40;
    vals[32] = 16; vals[33] = 62; vals[34] = 30; vals[35] = 53;
    vals[36] = 14; vals[37] = 27; vals[38] = 2;  vals[39] = 59;
    vals[40] = 31; vals[41] = 12; vals[42] = 47; vals[43] = 41;
    vals[44] = 36; vals[45] = 18; vals[46] = 57; vals[47] = 5;
    vals[48] = 52; vals[49] = 43; vals[50] = 49; vals[51] = 10;
    vals[52] = 44; vals[53] = 32; vals[54] = 13; vals[55] = 38;
    vals[56] = 20; vals[57] = 64; vals[58] = 24; vals[59] = 56;
    vals[60] = 55; vals[61] = 34; vals[62] = 22; vals[63] = 51;

    Integer idx = 0;
    for (Integer i = 0; i < 8; i = i + 1) begin
        for (Integer j = 0; j < 8; j = j + 1) begin
            matrix[i][j] = fromInteger(vals[idx]);
            idx = idx + 1;
        end
    end

    return matrix;
endfunction

    
    // Create test input
    MDSA_64 test_input = create_test_matrix();
    
    // Cycle counter for debugging
    rule rl_count_cycles;
        rg_cycle_count <= rg_cycle_count + 1;
    endrule
    
    // Start the sorting process
    rule rl_start(rg_mdsa_tb_stage == IDLE);
        mdsa_oddeven.ma_input_mdsa(test_input);
        rg_mdsa_tb_stage <= WAIT_FOR_OUTPUT;
        
        $display("=============================================");
        //$display("[%0d] Starting MDSA Odd-Even Sorter Test", $time);
        $display("=============================================");
        $display("Input Matrix (8x8):");
        
        for(Integer i = 0; i < 8; i = i + 1) begin
            $display("Row %0d: %2d %2d %2d %2d %2d %2d %2d %2d", i,
                test_input[i][0], test_input[i][1], 
                test_input[i][2], test_input[i][3],
                test_input[i][4], test_input[i][5], 
                test_input[i][6], test_input[i][7]);
        end
        $display("---------------------------------------------");
    endrule

    // Wait for and display output
    rule rl_display_final_output(rg_mdsa_tb_stage == WAIT_FOR_OUTPUT);
        let sorted_output <- mdsa_oddeven.mav_return_outputs();
        
        $display("=============================================");
        //$display("[%0d] MDSA Odd-Even Sorting Complete!", $time);
        //$display("Total Cycles: %0d", rg_cycle_count);
        $display("=============================================");
        $display("Sorted Output Matrix (8x8):");
        
        for(Integer i = 0; i < 8; i = i + 1) begin
            $display("Row %0d: %2d %2d %2d %2d %2d %2d %2d %2d", i,
                sorted_output[i][0], sorted_output[i][1], 
                sorted_output[i][2], sorted_output[i][3],
                sorted_output[i][4], sorted_output[i][5], 
                sorted_output[i][6], sorted_output[i][7]);
        end
        
        // Verify sorting correctness
        // Verify sorting in descending order
Bool is_sorted = True;
Bit#(WordLength) prev_val = 0;

// Initialize prev_val to the largest possible value so the first comparison works correctly
prev_val = '1;  // all bits 1 -> max value

for (Integer i = 0; i < 8; i = i + 1) begin
    for (Integer j = 0; j < 8; j = j + 1) begin
        if (sorted_output[i][j] > prev_val) begin
            is_sorted = False;
            $display("ERROR at [%0d][%0d]: %2d > %2d", i, j, sorted_output[i][j], prev_val);
        end
        prev_val = sorted_output[i][j];
    end
end

        $display("---------------------------------------------");
        if (is_sorted) begin
            $display("VERIFICATION PASSED: Output is correctly sorted!");
        end else begin
            $display("VERIFICATION FAILED: Output is NOT sorted!");
        end
        $display("=============================================");
        
        rg_mdsa_tb_stage <= DONE;
    endrule
    
    rule rl_finish(rg_mdsa_tb_stage == DONE);
        $finish(0);
    endrule
    
endmodule

// Alternative testbench with random/custom test cases
(* synthesize *)
module mk_mdsa_oddeven_testbench_custom(Empty);

    Reg#(MDSA_TB_STAGE) rg_mdsa_tb_stage <- mkReg(IDLE);
    Reg#(UInt#(32)) rg_cycle_count <- mkReg(0);
    
    Ifc_mdsa_oddeven mdsa_oddeven <- mk_mdsa_oddeven();
    
    // Custom test matrix with mixed values
    MDSA_64 custom_input = unpack(0);
    
    // Row 0: Large values
    custom_input[0][0] = 63; custom_input[0][1] = 61; custom_input[0][2] = 59; custom_input[0][3] = 57;
    custom_input[0][4] = 55; custom_input[0][5] = 53; custom_input[0][6] = 51; custom_input[0][7] = 49;
    
    // Row 1: Medium-high values
    custom_input[1][0] = 47; custom_input[1][1] = 45; custom_input[1][2] = 43; custom_input[1][3] = 41;
    custom_input[1][4] = 39; custom_input[1][5] = 37; custom_input[1][6] = 35; custom_input[1][7] = 33;
    
    // Row 2: Medium values
    custom_input[2][0] = 31; custom_input[2][1] = 29; custom_input[2][2] = 27; custom_input[2][3] = 25;
    custom_input[2][4] = 23; custom_input[2][5] = 21; custom_input[2][6] = 19; custom_input[2][7] = 17;
    
    // Row 3: Small values
    custom_input[3][0] = 15; custom_input[3][1] = 13; custom_input[3][2] = 11; custom_input[3][3] = 9;
    custom_input[3][4] = 7;  custom_input[3][5] = 5;  custom_input[3][6] = 3;  custom_input[3][7] = 1;
    
    // Row 4: Reversed pattern
    custom_input[4][0] = 2;  custom_input[4][1] = 4;  custom_input[4][2] = 6;  custom_input[4][3] = 8;
    custom_input[4][4] = 10; custom_input[4][5] = 12; custom_input[4][6] = 14; custom_input[4][7] = 16;
    
    // Row 5: Mixed pattern
    custom_input[5][0] = 18; custom_input[5][1] = 20; custom_input[5][2] = 22; custom_input[5][3] = 24;
    custom_input[5][4] = 26; custom_input[5][5] = 28; custom_input[5][6] = 30; custom_input[5][7] = 32;
    
    // Row 6: Another mixed pattern
    custom_input[6][0] = 34; custom_input[6][1] = 36; custom_input[6][2] = 38; custom_input[6][3] = 40;
    custom_input[6][4] = 42; custom_input[6][5] = 44; custom_input[6][6] = 46; custom_input[6][7] = 48;
    
    // Row 7: Completing the sequence
    custom_input[7][0] = 50; custom_input[7][1] = 52; custom_input[7][2] = 54; custom_input[7][3] = 56;
    custom_input[7][4] = 58; custom_input[7][5] = 60; custom_input[7][6] = 62; custom_input[7][7] = 64;
    
    // Cycle counter
    rule rl_count_cycles;
        rg_cycle_count <= rg_cycle_count + 1;
    endrule
    
    // Start sorting
    rule rl_start(rg_mdsa_tb_stage == IDLE);
        mdsa_oddeven.ma_input_mdsa(custom_input);
        rg_mdsa_tb_stage <= WAIT_FOR_OUTPUT;
        
        $display("=============================================");
        $display("[%0d] MDSA Odd-Even Custom Test", $time);
        $display("=============================================");
        $display("Input Matrix:");
        
        for(Integer i = 0; i < 8; i = i + 1) begin
            $display("Row %0d: %2d %2d %2d %2d %2d %2d %2d %2d", i,
                custom_input[i][0], custom_input[i][1], 
                custom_input[i][2], custom_input[i][3],
                custom_input[i][4], custom_input[i][5], 
                custom_input[i][6], custom_input[i][7]);
        end
        $display("---------------------------------------------");
    endrule

    // Display output
    rule rl_display_output(rg_mdsa_tb_stage == WAIT_FOR_OUTPUT);
        let sorted_output <- mdsa_oddeven.mav_return_outputs();
        
        $display("=============================================");
        //$display("[%0d] Sorting Complete! Cycles: %0d", $time, rg_cycle_count);
        $display("=============================================");
        $display("Sorted Output:");
        
        for(Integer i = 0; i < 8; i = i + 1) begin
            $display("Row %0d: %2d %2d %2d %2d %2d %2d %2d %2d", i,
                sorted_output[i][0], sorted_output[i][1], 
                sorted_output[i][2], sorted_output[i][3],
                sorted_output[i][4], sorted_output[i][5], 
                sorted_output[i][6], sorted_output[i][7]);
        end
        
        // Verify sorting in descending order
Bool is_sorted = True;

for (Integer i = 0; i < 8; i = i + 1) begin
    Bit#(WordLength) prev_val = sorted_output[i][0]; // start with first element of row
    for (Integer j = 1; j < 8; j = j + 1) begin
        if (sorted_output[i][j] > prev_val) begin
            is_sorted = False;
            $display("ERROR at [%0d][%0d]: %2d > %2d", i, j, sorted_output[i][j], prev_val);
        end
        prev_val = sorted_output[i][j];
    end
end

        
        $display("---------------------------------------------");
        $display(is_sorted ? "PASS: Correctly sorted" : "FAIL: Not sorted");
        $display("=============================================");
        
        rg_mdsa_tb_stage <= DONE;
    endrule
    
    rule rl_finish(rg_mdsa_tb_stage == DONE);
        $finish(0);
    endrule
    
endmodule

endpackage

package tb_mdsa_oen;

import Vector :: *;
import mdsa_types :: *;
import oddeven_sorter :: *;
import mdsa_oddeven :: *;

typedef enum {
    IDLE
    , WAIT_FOR_OUTPUT
} MDSA_TB_STAGE deriving(Bits, Eq, FShow);

(* synthesize *)
module mk_mdsa_oddeven_testbench(Empty);

    Reg#(MDSA_TB_STAGE) rg_mdsa_tb_stage <- mkReg(IDLE);
    Ifc_mdsa_oddeven mdsa_oddeven <- mk_mdsa_oddeven();
    
    MDSA_64 test_input = unpack(0);
    
    // Hardcoded test values
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
            test_input[i][j] = fromInteger(vals[idx]);
            idx = idx + 1;
        end
    end
    
    Reg#(MDSA_64) v_mdsa_input_tb <- mkReg(test_input);
    Reg#(UInt#(32)) cycle <- mkReg(0);
    
    rule cycle_count;
        cycle <= cycle + 1;
    endrule
    
    rule rl_start(rg_mdsa_tb_stage == IDLE);
        mdsa_oddeven.ma_input_mdsa(v_mdsa_input_tb);
        rg_mdsa_tb_stage <= WAIT_FOR_OUTPUT;
        
        $display("Starting MDSA Odd-Even Sorter");
        $display("Cycle: %d", cycle);
        
        for(Integer i = 0; i < 8; i = i + 1) begin
            $display("Row %d: %2d %2d %2d %2d %2d %2d %2d %2d", i,
                v_mdsa_input_tb[i][0], v_mdsa_input_tb[i][1], 
                v_mdsa_input_tb[i][2], v_mdsa_input_tb[i][3],
                v_mdsa_input_tb[i][4], v_mdsa_input_tb[i][5], 
                v_mdsa_input_tb[i][6], v_mdsa_input_tb[i][7]);
        end
    endrule
    
    rule rl_display_final_output(rg_mdsa_tb_stage == WAIT_FOR_OUTPUT);
        let lv_mdsa_output <- mdsa_oddeven.mav_return_outputs();
        
        $display("MDSA Odd-Even Sorting complete!");
        $display("Cycle: %d", cycle);
        $display("Raw hex output: %h", lv_mdsa_output);
        
        // Display in descending order
        for(Integer i = 7; i >= 0; i = i - 1) begin
            $display("Row %d: %2d %2d %2d %2d %2d %2d %2d %2d", 7-i,
                lv_mdsa_output[i][7], lv_mdsa_output[i][6], 
                lv_mdsa_output[i][5], lv_mdsa_output[i][4],
                lv_mdsa_output[i][3], lv_mdsa_output[i][2], 
                lv_mdsa_output[i][1], lv_mdsa_output[i][0]);
        end
        
        // Verify sorting in descending order
        Bool is_sorted = True;
        Bit#(WordLength) prev_val = '1; // Max value
        
        for (Integer i = 7; i >= 0; i = i - 1) begin
            for (Integer j = 7; j >= 0; j = j - 1) begin
                if (lv_mdsa_output[i][j] > prev_val) begin
                    is_sorted = False;
                    $display("ERROR at [%d][%d]: %d > %d", i, j, 
                             lv_mdsa_output[i][j], prev_val);
                end
                prev_val = lv_mdsa_output[i][j];
            end
        end
        
        if (is_sorted) begin
            $display("VERIFICATION PASSED: Output is correctly sorted in descending order!");
        end else begin
            $display("VERIFICATION FAILED: Output is NOT sorted!");
        end
        
        $display("Test completed - Total cycles: %d", cycle);
        $finish;
    endrule
    
endmodule

endpackage


// To print output onto a log file
/*
package tb_mdsa_oen;

import Vector :: *;
import mdsa_types :: *;
import oddeven_sorter :: *;
import mdsa_oddeven :: *;

typedef enum {
    IDLE
    , WAIT_FOR_OUTPUT
} MDSA_TB_STAGE deriving(Bits, Eq, FShow);

(* synthesize *)
module mk_mdsa_oddeven_testbench(Empty);

    Reg#(MDSA_TB_STAGE) rg_mdsa_tb_stage <- mkReg(IDLE);
    Ifc_mdsa_oddeven mdsa_oddeven <- mk_mdsa_oddeven();
    
    // File handle
    let out_file <- mkReg(InvalidFile);
    Reg#(Bool) file_valid <- mkReg(False);
    
    rule set_outfile(file_valid == False);
        $display("set_outfile");
        String file = "mdsa_oddeven_log.txt";
        File f <- $fopen(file, "w");
        if (f == InvalidFile) begin
            $display("Invalid file %s", file);
            $finish(0);
        end
        file_valid <= True;
        out_file <= f;
    endrule
    
    MDSA_64 test_input = unpack(0);
    
    // Hardcoded test values
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
            test_input[i][j] = fromInteger(vals[idx]);
            idx = idx + 1;
        end
    end
    
    Reg#(MDSA_64) v_mdsa_input_tb <- mkReg(test_input);
    Reg#(UInt#(32)) cycle <- mkReg(0);
    
    rule cycle_count(file_valid);
        cycle <= cycle + 1;
    endrule
    
    rule rl_start(rg_mdsa_tb_stage == IDLE && file_valid);
        mdsa_oddeven.ma_input_mdsa(v_mdsa_input_tb);
        rg_mdsa_tb_stage <= WAIT_FOR_OUTPUT;
        
        $display("Starting MDSA Odd-Even Sorter");
        $display("Cycle: %d", cycle);
        
        $fwrite(out_file, "MDSA Odd-Even Sorter Test Log\n");
        $fwrite(out_file, "=============================\n\n");
        $fwrite(out_file, "Cycle: %d\n\n", cycle);
        $fwrite(out_file, "INPUT MATRIX (8x8):\n");
        $fwrite(out_file, "-------------------\n");
        
        for(Integer i = 0; i < 8; i = i + 1) begin
            $display("Row %d: %2d %2d %2d %2d %2d %2d %2d %2d", i,
                v_mdsa_input_tb[i][0], v_mdsa_input_tb[i][1], 
                v_mdsa_input_tb[i][2], v_mdsa_input_tb[i][3],
                v_mdsa_input_tb[i][4], v_mdsa_input_tb[i][5], 
                v_mdsa_input_tb[i][6], v_mdsa_input_tb[i][7]);
            
            $fwrite(out_file, "Row %d: [%3d, %3d, %3d, %3d, %3d, %3d, %3d, %3d]\n", i,
                v_mdsa_input_tb[i][0], v_mdsa_input_tb[i][1], 
                v_mdsa_input_tb[i][2], v_mdsa_input_tb[i][3],
                v_mdsa_input_tb[i][4], v_mdsa_input_tb[i][5], 
                v_mdsa_input_tb[i][6], v_mdsa_input_tb[i][7]);
        end
        $fwrite(out_file, "\n");
    endrule
    
    rule rl_display_final_output(rg_mdsa_tb_stage == WAIT_FOR_OUTPUT && file_valid);
        let lv_mdsa_output <- mdsa_oddeven.mav_return_outputs();
        
        $display("MDSA Odd-Even Sorting complete!");
        $display("Cycle: %d", cycle);
        $display("Raw hex output: %h", lv_mdsa_output);
        
        
        $fwrite(out_file, "Cycle: %d\n\n", cycle);
        $fwrite(out_file, "RAW OUTPUT (Hex):\n");
        $fwrite(out_file, "-----------------\n");
        $fwrite(out_file, "%h\n\n", lv_mdsa_output);
        
        $fwrite(out_file, "OUTPUT MATRIX (8x8) - Decimal (Descending Order):\n");
        $fwrite(out_file, "--------------------------------------------------\n");
        
        // Display in descending order as in hexadecimal display in BSV, the RIGHTMOST digits correspond to the LOWEST indices, and it reads RIGHT to LEFT
        for(Integer i = 7; i >= 0; i = i - 1) begin
            $display("Row %d: %2d %2d %2d %2d %2d %2d %2d %2d", 7-i,
                lv_mdsa_output[i][7], lv_mdsa_output[i][6], 
                lv_mdsa_output[i][5], lv_mdsa_output[i][4],
                lv_mdsa_output[i][3], lv_mdsa_output[i][2], 
                lv_mdsa_output[i][1], lv_mdsa_output[i][0]);
            
            $fwrite(out_file, "Row %d: [%3d, %3d, %3d, %3d, %3d, %3d, %3d, %3d]\n", 7-i,
                lv_mdsa_output[i][7], lv_mdsa_output[i][6], 
                lv_mdsa_output[i][5], lv_mdsa_output[i][4],
                lv_mdsa_output[i][3], lv_mdsa_output[i][2], 
                lv_mdsa_output[i][1], lv_mdsa_output[i][0]);
        end
        
        // Verify sorting in descending order
        Bool is_sorted = True;
        Bit#(WordLength) prev_val = '1; // Max value
        
        for (Integer i = 7; i >= 0; i = i - 1) begin
            for (Integer j = 7; j >= 0; j = j - 1) begin
                if (lv_mdsa_output[i][j] > prev_val) begin
                    is_sorted = False;
                    $display("ERROR at [%d][%d]: %d > %d", i, j, 
                             lv_mdsa_output[i][j], prev_val);
                    $fwrite(out_file, "ERROR at [%d][%d]: %d > %d\n", i, j,
                            lv_mdsa_output[i][j], prev_val);
                end
                prev_val = lv_mdsa_output[i][j];
            end
        end
        
        $fwrite(out_file, "\n");
        if (is_sorted) begin
            $display("VERIFICATION PASSED: Output is correctly sorted in descending order!");
            $fwrite(out_file, "VERIFICATION: PASSED\n");
            $fwrite(out_file, "Output is correctly sorted in descending order.\n");
        end else begin
            $display("VERIFICATION FAILED: Output is NOT sorted!");
            $fwrite(out_file, "VERIFICATION: FAILED\n");
            $fwrite(out_file, "Output is NOT correctly sorted.\n");
        end
        
        $fwrite(out_file, "\nTest completed successfully\n");
        $fwrite(out_file, "Total cycles: %d\n", cycle);
        
        $fclose(out_file);
        $finish;
    endrule
    
endmodule

endpackage
*/

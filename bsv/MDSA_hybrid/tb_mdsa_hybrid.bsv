package tb_mdsa_hybrid;

import Vector :: *;
import mdsa_types :: *;
import hybrid_sorter :: *;
import mdsa_hybrid ::*;
typedef enum {
    IDLE
    , WAIT_FOR_OUTPUT
} MDSA_TB_STAGE deriving(Bits, Eq, FShow);

(* synthesize *)
module mk_mdsa_hybrid_testbench_manual(Empty);

    Reg#(MDSA_TB_STAGE) rg_mdsa_tb_stage <- mkReg(IDLE);

    Ifc_mdsa_hybrid mdsa_hybrid <- mk_mdsa_hybrid();
    
    // Initialize with manually written 64 values
    MDSA_64 initial_vector = unpack(0);
    
    // Manually assign all 64 values (8x8 matrix)
    initial_vector[0][0] = 23;  initial_vector[0][1] = 45;  initial_vector[0][2] = 67;  initial_vector[0][3] = 89;
    initial_vector[0][4] = 12;  initial_vector[0][5] = 34;  initial_vector[0][6] = 56;  initial_vector[0][7] = 78;
    
    initial_vector[1][0] = 91;  initial_vector[1][1] = 13;  initial_vector[1][2] = 35;  initial_vector[1][3] = 57;
    initial_vector[1][4] = 79;  initial_vector[1][5] = 24;  initial_vector[1][6] = 46;  initial_vector[1][7] = 68;
    
    initial_vector[2][0] = 82;  initial_vector[2][1] = 14;  initial_vector[2][2] = 36;  initial_vector[2][3] = 58;
    initial_vector[2][4] = 71;  initial_vector[2][5] = 93;  initial_vector[2][6] = 15;  initial_vector[2][7] = 37;
    
    initial_vector[3][0] = 59;  initial_vector[3][1] = 81;  initial_vector[3][2] = 25;  initial_vector[3][3] = 47;
    initial_vector[3][4] = 69;  initial_vector[3][5] = 83;  initial_vector[3][6] = 16;  initial_vector[3][7] = 38;
    
    initial_vector[4][0] = 52;  initial_vector[4][1] = 74;  initial_vector[4][2] = 96;  initial_vector[4][3] = 18;
    initial_vector[4][4] = 41;  initial_vector[4][5] = 63;  initial_vector[4][6] = 85;  initial_vector[4][7] = 29;
    
    initial_vector[5][0] = 51;  initial_vector[5][1] = 73;  initial_vector[5][2] = 95;  initial_vector[5][3] = 17;
    initial_vector[5][4] = 39;  initial_vector[5][5] = 61;  initial_vector[5][6] = 84;  initial_vector[5][7] = 26;
    
    initial_vector[6][0] = 48;  initial_vector[6][1] = 72;  initial_vector[6][2] = 94;  initial_vector[6][3] = 19;
    initial_vector[6][4] = 43;  initial_vector[6][5] = 65;  initial_vector[6][6] = 87;  initial_vector[6][7] = 21;
    
    initial_vector[7][0] = 44;  initial_vector[7][1] = 66;  initial_vector[7][2] = 88;  initial_vector[7][3] = 22;
    initial_vector[7][4] = 55;  initial_vector[7][5] = 77;  initial_vector[7][6] = 99;  initial_vector[7][7] = 11;
    
    Reg#(MDSA_64) v_mdsa_input_tb <- mkReg(initial_vector);
    Reg#(UInt#(32)) cycle <- mkReg(0);
	rule cycle_count;
    	cycle<=cycle+1;
    endrule
    rule rl_start(rg_mdsa_tb_stage == IDLE);
        mdsa_hybrid.ma_input_mdsa(v_mdsa_input_tb);
        rg_mdsa_tb_stage <= WAIT_FOR_OUTPUT;
        $display("Starting MDSA with manually assigned input matrix:");
        for(Integer i = 0; i < 8; i = i + 1) begin
            $display("Row %d: %d %d %d %d %d %d %d %d", i,
                v_mdsa_input_tb[i][0], v_mdsa_input_tb[i][1], 
                v_mdsa_input_tb[i][2], v_mdsa_input_tb[i][3],
                v_mdsa_input_tb[i][4], v_mdsa_input_tb[i][5], 
                v_mdsa_input_tb[i][6], v_mdsa_input_tb[i][7]);
        end
        $display("cycle: ",cycle);
    endrule

    rule rl_display_final_mdsa_output(rg_mdsa_tb_stage == WAIT_FOR_OUTPUT);
        let lv_mdsa_output <- mdsa_hybrid.mav_return_outputs();
        $display("Final MDSA output: %h", lv_mdsa_output);
        $display("cycle: ",cycle);
        $finish;
    endrule
    
endmodule

endpackage


/*
// To print output onto a log file
package tb_mdsa_hybrid;
import Vector :: *;
import mdsa_types :: *;
import hybrid_sorter :: *;
import mdsa_hybrid ::*;

typedef enum {
    IDLE
    , WAIT_FOR_OUTPUT
} MDSA_TB_STAGE deriving(Bits, Eq, FShow);

(* synthesize *)
module mk_mdsa_hybrid_testbench_manual(Empty);
    Reg#(MDSA_TB_STAGE) rg_mdsa_tb_stage <- mkReg(IDLE);
    Ifc_mdsa_hybrid mdsa_hybrid <- mk_mdsa_hybrid();
    
    // File handle
    let out_file <- mkReg(InvalidFile);
    Reg#(Bool) file_valid <- mkReg(False);
    
    rule set_outfile(file_valid == False);
        $display("set_outfile");
        String file = "mdsa_hybrid_log.txt";
        File f <- $fopen(file, "w");
        if (f == InvalidFile) begin
            $display("Invalid file %s", file);
            $finish(0);
        end
        file_valid <= True;
        out_file <= f;
    endrule
    
    // Initialize with manually written 64 values
    MDSA_64 initial_vector = unpack(0);
    
    // Manually assign all 64 values (8x8 matrix)
    initial_vector[0][0] = 23;  initial_vector[0][1] = 45;  initial_vector[0][2] = 67;  initial_vector[0][3] = 89;
    initial_vector[0][4] = 12;  initial_vector[0][5] = 34;  initial_vector[0][6] = 56;  initial_vector[0][7] = 78;
    
    initial_vector[1][0] = 91;  initial_vector[1][1] = 13;  initial_vector[1][2] = 35;  initial_vector[1][3] = 57;
    initial_vector[1][4] = 79;  initial_vector[1][5] = 24;  initial_vector[1][6] = 46;  initial_vector[1][7] = 68;
    
    initial_vector[2][0] = 82;  initial_vector[2][1] = 14;  initial_vector[2][2] = 36;  initial_vector[2][3] = 58;
    initial_vector[2][4] = 71;  initial_vector[2][5] = 93;  initial_vector[2][6] = 15;  initial_vector[2][7] = 37;
    
    initial_vector[3][0] = 59;  initial_vector[3][1] = 81;  initial_vector[3][2] = 25;  initial_vector[3][3] = 47;
    initial_vector[3][4] = 69;  initial_vector[3][5] = 83;  initial_vector[3][6] = 16;  initial_vector[3][7] = 38;
    
    initial_vector[4][0] = 52;  initial_vector[4][1] = 74;  initial_vector[4][2] = 96;  initial_vector[4][3] = 18;
    initial_vector[4][4] = 41;  initial_vector[4][5] = 63;  initial_vector[4][6] = 85;  initial_vector[4][7] = 29;
    
    initial_vector[5][0] = 51;  initial_vector[5][1] = 73;  initial_vector[5][2] = 95;  initial_vector[5][3] = 17;
    initial_vector[5][4] = 39;  initial_vector[5][5] = 61;  initial_vector[5][6] = 84;  initial_vector[5][7] = 26;
    
    initial_vector[6][0] = 48;  initial_vector[6][1] = 72;  initial_vector[6][2] = 94;  initial_vector[6][3] = 19;
    initial_vector[6][4] = 43;  initial_vector[6][5] = 65;  initial_vector[6][6] = 87;  initial_vector[6][7] = 21;
    
    initial_vector[7][0] = 44;  initial_vector[7][1] = 66;  initial_vector[7][2] = 88;  initial_vector[7][3] = 22;
    initial_vector[7][4] = 55;  initial_vector[7][5] = 77;  initial_vector[7][6] = 99;  initial_vector[7][7] = 11;
    
    Reg#(MDSA_64) v_mdsa_input_tb <- mkReg(initial_vector);
    Reg#(UInt#(32)) cycle <- mkReg(0);
    
    rule cycle_count(file_valid);
        cycle <= cycle + 1;
    endrule
    
    rule rl_start(rg_mdsa_tb_stage == IDLE && file_valid);
        mdsa_hybrid.ma_input_mdsa(v_mdsa_input_tb);
        rg_mdsa_tb_stage <= WAIT_FOR_OUTPUT;
        
        $display("Starting MDSA with manually assigned input matrix:");
        $display("Cycle: %d", cycle);
        
        // Write header to file
        $fwrite(out_file, "MDSA Hybrid Test Log\n");
        $fwrite(out_file, "====================\n\n");
        $fwrite(out_file, "Cycle: %d\n\n", cycle);
        $fwrite(out_file, "INPUT MATRIX (8x8):\n");
        $fwrite(out_file, "-------------------\n");
        
        for(Integer i = 0; i < 8; i = i + 1) begin
            $display("Row %d: %d %d %d %d %d %d %d %d", i,
                v_mdsa_input_tb[i][0], v_mdsa_input_tb[i][1], 
                v_mdsa_input_tb[i][2], v_mdsa_input_tb[i][3],
                v_mdsa_input_tb[i][4], v_mdsa_input_tb[i][5], 
                v_mdsa_input_tb[i][6], v_mdsa_input_tb[i][7]);
            
            // Write to file with nice formatting
            $fwrite(out_file, "Row %d: [%3d, %3d, %3d, %3d, %3d, %3d, %3d, %3d]\n", i,
                v_mdsa_input_tb[i][0], v_mdsa_input_tb[i][1], 
                v_mdsa_input_tb[i][2], v_mdsa_input_tb[i][3],
                v_mdsa_input_tb[i][4], v_mdsa_input_tb[i][5], 
                v_mdsa_input_tb[i][6], v_mdsa_input_tb[i][7]);
        end
        $fwrite(out_file, "\n");
    endrule
    
    rule rl_display_final_mdsa_output(rg_mdsa_tb_stage == WAIT_FOR_OUTPUT && file_valid);
        let lv_mdsa_output <- mdsa_hybrid.mav_return_outputs();
        
        $display("Final MDSA output received");
        $display("Cycle: %d", cycle);
        $display("Raw hex output: %h", lv_mdsa_output);
        
        // Write output header
        $fwrite(out_file, "Cycle: %d\n\n", cycle);
        $fwrite(out_file, "RAW OUTPUT (Hex):\n");
        $fwrite(out_file, "-----------------\n");
        $fwrite(out_file, "%h\n\n", lv_mdsa_output);
        
        $fwrite(out_file, "OUTPUT MATRIX (8x8) - Decimal:\n");
        $fwrite(out_file, "-------------------------------\n");
        
        // Display in descending order as they appear in the hex output
        // The hex shows values from highest index to lowest (right to left)
        for(Integer i = 7; i >= 0; i = i - 1) begin
            $display("Row %d: %d %d %d %d %d %d %d %d", 7-i,
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
        
        $fwrite(out_file, "\n");
        $fwrite(out_file, "Test completed successfully\n");
        $fwrite(out_file, "Total cycles: %d\n", cycle);
        
        $fclose(out_file);
        $finish;
    endrule
    
endmodule
endpackage
*/

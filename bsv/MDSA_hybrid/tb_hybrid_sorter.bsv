package tb_hybrid_sorter;
import mdsa_types       ::*;
import Vector           ::*;
import BuildVector      ::*;
import hybrid_sorter ::*;
(* synthesize *)
module mk_tb_hybrid_sorter();

   Ifc_hybrid_sorter dut <- mk_hybrid_sorter();

   Reg#(UInt#(4)) test_state <- mkReg(0);
   Reg#(UInt#(32)) cycle_count <- mkReg(0);
   Reg#(Bool) data_sent <- mkReg(False);

   // Test data
   HYB test_data = vec(0,7,17,4,8,2,1,21);

   rule rl_count_cycles;
      cycle_count <= cycle_count + 1;
   endrule

   rule rl_send_data (test_state == 0 && cycle_count > 5 && !data_sent);
      dut.ma_put_data(test_data);
      data_sent <= True;
      test_state <= 1;
      $display("Cycle %d: Sent test data [0,7,17,4,8,2,1,21]", cycle_count);
   endrule

   rule rl_check_result (test_state == 1 && dut.mv_is_ready());
      let result = dut.mv_get_sorted_data();
      $display("Cycle %d: Sorting complete!", cycle_count);
      $display("Result: [%d,%d,%d,%d,%d,%d,%d,%d]", 
               result[0], result[1], result[2], result[3],
               result[4], result[5], result[6], result[7]);

      if (result[0] == 0 && result[1] == 1 && result[2] == 2 && result[3] == 4 &&
          result[4] == 7 && result[5] == 8 && result[6] == 17 && result[7] == 21) 
          begin
             $display("SUCCESS: Correctly sorted!");
      end 
      else begin
         $display("FAILURE: Incorrect sorting!");
      end

      test_state <= 2;
   endrule

   rule rl_finish (test_state == 2);
      $display("Test completed in %d cycles", cycle_count);
      $finish();
   endrule

   rule rl_timeout (cycle_count > 500);
      $display("ERROR: Test timeout!");
      $finish();
   endrule
endmodule
endpackage

// To print output onto a log file
/*package tb_hybrid_sorter;
import mdsa_types       ::*;
import Vector           ::*;
import BuildVector      ::*;
import hybrid_sorter ::*;

(* synthesize *)
module mk_tb_hybrid_sorter();
   
   Ifc_hybrid_sorter dut <- mk_hybrid_sorter();
   
   Reg#(UInt#(4)) test_state <- mkReg(0);
   Reg#(UInt#(32)) cycle_count <- mkReg(0);
   Reg#(Bool) data_sent <- mkReg(False);
   
   // Test data
   HYB test_data = vec(0,7,17,4,8,2,1,21);
   
   // File handle
   let out_file <- mkReg(InvalidFile);
   Reg#(Bool) file_valid <- mkReg(False);
   
   rule set_outfile(file_valid == False);
      $display("set_outfile");
      String file = "hybrid_sorter_log.txt";
      File f <- $fopen(file, "w");
      if (f == InvalidFile) begin
         $display("Invalid file %s", file);
         $finish(0);
      end
      file_valid <= True;
      out_file <= f;
   endrule
   
   rule rl_count_cycles (file_valid);
      cycle_count <= cycle_count + 1;
   endrule
   
   rule rl_send_data (test_state == 0 && cycle_count > 5 && !data_sent && file_valid);
      dut.ma_put_data(test_data);
      data_sent <= True;
      test_state <= 1;
      
      $display("Cycle %d: Sent test data [0,7,17,4,8,2,1,21]", cycle_count);
      
      // Write to log file
      $fwrite(out_file, "Hybrid Sorter Test Log\n");
      $fwrite(out_file, "======================\n\n");
      $fwrite(out_file, "Cycle %d: INPUT DATA\n", cycle_count);
      for (Integer i = 0; i < 8; i = i + 1) begin
         $fwrite(out_file, "Element[%d] = %d\n", i, test_data[i]);
      end
      $fwrite(out_file, "\n");
   endrule
   
   rule rl_check_result (test_state == 1 && dut.mv_is_ready() && file_valid);
      let result = dut.mv_get_sorted_data();
      
      $display("Cycle %d: Sorting complete!", cycle_count);
      $display("Result: [%d,%d,%d,%d,%d,%d,%d,%d]", 
               result[0], result[1], result[2], result[3],
               result[4], result[5], result[6], result[7]);
      
      // Write result to log file
      $fwrite(out_file, "Cycle %d: SORTED OUTPUT\n", cycle_count);
      for (Integer i = 0; i < 8; i = i + 1) begin
         $fwrite(out_file, "Element[%d] = %d\n", i, result[i]);
      end
      $fwrite(out_file, "\n");
      
      // Check correctness
      if (result[0] == 0 && result[1] == 1 && result[2] == 2 && result[3] == 4 &&
          result[4] == 7 && result[5] == 8 && result[6] == 17 && result[7] == 21) 
      begin
         $display("SUCCESS: Correctly sorted!");
         $fwrite(out_file, "TEST RESULT: SUCCESS\n");
         $fwrite(out_file, "All elements correctly sorted in ascending order.\n\n");
      end 
      else begin
         $display("FAILURE: Incorrect sorting!");
         $fwrite(out_file, "TEST RESULT: FAILURE\n");
         $fwrite(out_file, "Sorting produced incorrect results.\n\n");
      end
      
      test_state <= 2;
   endrule
   
   rule rl_finish (test_state == 2 && file_valid);
      $display("Test completed in %d cycles", cycle_count);
      $fwrite(out_file, "Test completed in %d cycles\n", cycle_count);
      $fclose(out_file);
      $finish();
   endrule
   
   rule rl_timeout (cycle_count > 500 && file_valid);
      $display("ERROR: Test timeout!");
      $fwrite(out_file, "ERROR: Test timeout after %d cycles\n", cycle_count);
      $fclose(out_file);
      $finish();
   endrule
endmodule
endpackage
*/

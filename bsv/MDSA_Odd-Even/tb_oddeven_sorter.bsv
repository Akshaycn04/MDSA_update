package tb_oddeven_sorter;
import mdsa_types       ::*;
import Vector           ::*;
import BuildVector      ::*;
import oddeven_sorter   ::*;

(* synthesize *)
module mk_tb_oddeven_sorter();
   
   Ifc_sorting_network dut <- mk_sorting_network();
   
   // Test control registers
   Reg#(UInt#(4)) test_state <- mkReg(0);
   Reg#(UInt#(32)) cycle_count <- mkReg(0);
   Reg#(Bool) data_sent <- mkReg(False);
   
   // File handle
   let out_file <- mkReg(InvalidFile);
   Reg#(Bool) file_valid <- mkReg(False);
   
   rule set_outfile(file_valid == False);
      $display("set_outfile");
      String file = "oddeven_sorter_log.txt";
      File f <- $fopen(file, "w");
      if (f == InvalidFile) begin
         $display("Invalid file %s", file);
         $finish(0);
      end
      file_valid <= True;
      out_file <= f;
   endrule
   
   // Test data [3, 1, 5, 6, 7, 8, 9, 4]
   ODE test_data = vec(3, 1, 5, 6, 7, 8, 9, 4);
   
   // Expected sorted result in ascending order: [1, 3, 4, 5, 6, 7, 8, 9]
   ODE expected_result = vec(1, 3, 4, 5, 6, 7, 8, 9);
   
   
   rule rl_count_cycles(file_valid);
      cycle_count <= cycle_count + 1;
   endrule
   
   
   rule rl_send_data (test_state == 0 && cycle_count > 5 && !data_sent && file_valid);
      dut.ma_put_data(test_data);
      data_sent <= True;
      test_state <= 1;
      
      $display("Cycle %d: Sent test data [3,1,5,6,7,8,9,4]", cycle_count);
      
      
      $fwrite(out_file, "Odd-Even Sorter Test Log\n");
      $fwrite(out_file, "========================\n\n");
      $fwrite(out_file, "Cycle: %d\n\n", cycle_count);
      $fwrite(out_file, "INPUT DATA:\n");
      $fwrite(out_file, "-----------\n");
      
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
      
      
      $fwrite(out_file, "Cycle: %d\n\n", cycle_count);
      $fwrite(out_file, "SORTED OUTPUT (Ascending Order):\n");
      $fwrite(out_file, "---------------------------------\n");
      
      for (Integer i = 0; i < 8; i = i + 1) begin
         $fwrite(out_file, "Element[%d] = %d\n", i, result[i]);
      end
      $fwrite(out_file, "\n");
      
      $fwrite(out_file, "EXPECTED OUTPUT:\n");
      $fwrite(out_file, "----------------\n");
      for (Integer i = 0; i < 8; i = i + 1) begin
         $fwrite(out_file, "Element[%d] = %d\n", i, expected_result[i]);
      end
      $fwrite(out_file, "\n");
      
      
      if (result == expected_result) begin
         $display("SUCCESS: Correctly sorted in ascending order!");
         $fwrite(out_file, "VERIFICATION: PASSED\n");
         $fwrite(out_file, "Output is correctly sorted in ascending order.\n");
      end else begin
         $display("FAILURE: Incorrect sorting!");
         $fwrite(out_file, "VERIFICATION: FAILED\n");
         $fwrite(out_file, "Output does not match expected result.\n");
         
 
         $fwrite(out_file, "\nDifferences:\n");
         for (Integer i = 0; i < 8; i = i + 1) begin
            if (result[i] != expected_result[i]) begin
               $fwrite(out_file, "  Position %d: Got %d, Expected %d\n", 
                       i, result[i], expected_result[i]);
            end
         end
      end
      
      test_state <= 2;
   endrule
   

   rule rl_finish (test_state == 2 && file_valid);
      $display("Test completed in %d cycles", cycle_count);
      $fwrite(out_file, "\nTest completed successfully\n");
      $fwrite(out_file, "Total cycles: %d\n", cycle_count);
      $fclose(out_file);
      $finish();
   endrule
   

   rule rl_timeout (cycle_count > 500 && file_valid);
      $display("ERROR: Test timeout!");
      $fwrite(out_file, "\nERROR: Test timeout after %d cycles\n", cycle_count);
      $fclose(out_file);
      $finish();
   endrule
endmodule
endpackage

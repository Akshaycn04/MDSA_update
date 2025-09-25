package tb_sorting_network;

import mdsa_types       ::*;
import Vector           ::*;
import BuildVector      ::*;
import hybrid_sorter ::*;

(* synthesize *)
module mk_tb_sorting_network_simple();
   
   // Instantiate the DUT
   Ifc_sorting_network dut <- mk_sorting_network();
   
   // Test control registers
   Reg#(UInt#(4)) test_state <- mkReg(0);
   Reg#(UInt#(32)) cycle_count <- mkReg(0);
   Reg#(Bool) data_sent <- mkReg(False);
   
   // Test data [3, 1, 5, 6, 7, 8, 9, 4]
   OEH test_data = vec(0,7,17,4,8,2,1,21);
   
   // Cycle counter
   rule rl_count_cycles;
      cycle_count <= cycle_count + 1;
   endrule
   
   // Send test data
   rule rl_send_data (test_state == 0 && cycle_count > 5 && !data_sent);
      dut.ma_put_data(test_data);
      data_sent <= True;
      test_state <= 1;
      $display("Cycle %d: Sent test data [0,7,17,4,8,2,1,21", cycle_count);
   endrule
   
   // Wait for completion and check result
   rule rl_check_result (test_state == 1 && dut.mv_is_ready());
      let result = dut.mv_get_sorted_data();
      $display("Cycle %d: Sorting complete!", cycle_count);
      $display("Result: [%d,%d,%d,%d,%d,%d,%d,%d]", 
               result[0], result[1], result[2], result[3],
               result[4], result[5], result[6], result[7]);
      
      // Check if sorted correctly
      if (result[0] == 1 && result[1] == 3 && result[2] == 4 && result[3] == 5 &&
          result[4] == 6 && result[5] == 7 && result[6] == 8 && result[7] == 9) begin
         $display("SUCCESS: Correctly sorted!");
      end else begin
         $display("FAILURE: Incorrect sorting!");
      end
      
      test_state <= 2;
   endrule
   
   // Finish test
   rule rl_finish (test_state == 2);
      $display("Test completed in %d cycles", cycle_count);
      $finish();
   endrule
   
   // Timeout
   rule rl_timeout (cycle_count > 500);
      $display("ERROR: Test timeout!");
      $finish();
   endrule

endmodule

endpackage

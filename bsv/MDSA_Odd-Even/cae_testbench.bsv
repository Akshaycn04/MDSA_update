package cae_testbench;

import cae :: *;
import mdsa_types :: *;
import Vector :: *;

(* synthesize *)
module mk_cae_testbench (Empty);

   Ifc_cae cae_inst <- mk_cae();

   // Using genVector with the correct size of 2
   CAE v_cae_test_inputs = map(fromInteger, reverse(genVector));

   Reg#(CAE) rg_cae <- mkReg(v_cae_test_inputs);

   rule rl_tb_get_data(True);
      // Corrected: Use $format to combine the string and fshow result into a single argument
      //fn_display($format("Sending data: %s", fshow(rg_cae)));
      $display("Sending data: %s", fshow(rg_cae));
		
      let lv_numbers <- cae_inst.mav_get_sort(rg_cae);
      // Corrected: Use $format to combine the string and fshow result into a single argument
      //fn_display($format("Received data: %s", fshow(lv_numbers)));  
      $display("Received data: %s", fshow(lv_numbers));
      
      $finish;
   endrule

endmodule

// Updated genVector to return a Vector of size 2 as required by CAE
function Vector#(2, Integer) genVector();
   Vector#(2, Integer) v = newVector;
   v[0] = 1;
   v[1] = 5;
   return v;
endfunction

endpackage

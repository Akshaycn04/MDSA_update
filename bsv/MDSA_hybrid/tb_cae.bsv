package tb_cae;

import cae :: *;
import mdsa_types :: *;
import Vector :: *;

(* synthesize *)
module mk_tb_cae (Empty);

   Ifc_cae cae_inst <- mk_cae();

   CAE v_cae_test_inputs = map(fromInteger, reverse(genVector));

   Reg#(CAE) rg_cae <- mkReg(v_cae_test_inputs);

   rule rl_tb_get_data(True);
      $display("Sending data: %h %h", rg_cae[0],rg_cae[1]);		
      let lv_numbers <- cae_inst.mav_get_sort(rg_cae);
      $display("Received data: %h %h", lv_numbers[0],lv_numbers[1]);
      
      $finish;
   endrule

endmodule

function Vector#(2, Integer) genVector();
   Vector#(2, Integer) v = newVector;
   v[0] = 1;
   v[1] = 5;
   return v;
endfunction

endpackage

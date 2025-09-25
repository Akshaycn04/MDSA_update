package cae;

import mdsa_types       ::*;
import Vector           ::*;
import BuildVector      ::*;


interface Ifc_cae;
   method ActionValue#(CAE) mav_get_sort (CAE cae_in);
endinterface

(* synthesize *)
module mk_cae(Ifc_cae);
   method ActionValue#(CAE) mav_get_sort (CAE cae_in);
      if(cae_in[0] > cae_in[1]) begin
         cae_in = reverse(cae_in);
      end      
      return(cae_in);
   endmethod

endmodule

endpackage

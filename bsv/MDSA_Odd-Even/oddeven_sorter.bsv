package oddeven_sorter;

import mdsa_types       ::*;
import Vector           ::*;
import BuildVector      ::*;
import cae              ::*;


interface Ifc_oddeven_sorter;
   method Action ma_put_data (ODE ode_in);
   method ODE mv_get_sorted_data();
   method Bool mv_is_ready();
endinterface

(* synthesize *)
module mk_oddeven_sorter(Ifc_oddeven_sorter);
   
   // Input and output registers
   Reg#(ODE) rg_input_data <- mkReg(replicate(0));
   Reg#(ODE) rg_output_data <- mkReg(replicate(0));
   Reg#(Bool) rg_sort_complete <- mkReg(False);
   Reg#(Bool) rg_data_valid <- mkReg(False);
   Reg#(RG_STAGE) rg_stage <- mkReg(INIT);
   
   Reg#(ODE) rg_stage_0 <- mkReg(replicate(0));
   Reg#(ODE) rg_stage_1 <- mkReg(replicate(0));
   Reg#(ODE) rg_stage_2 <- mkReg(replicate(0));
   Reg#(ODE) rg_stage_3 <- mkReg(replicate(0));
   Reg#(ODE) rg_stage_4 <- mkReg(replicate(0));
   Reg#(ODE) rg_stage_5 <- mkReg(replicate(0));
   
   // Compare-and-exchange units
   Ifc_cae cae_01 <- mk_cae();
   Ifc_cae cae_23 <- mk_cae();
   Ifc_cae cae_45 <- mk_cae();
   Ifc_cae cae_67 <- mk_cae();
   Ifc_cae cae_02 <- mk_cae();
   Ifc_cae cae_13 <- mk_cae();
   Ifc_cae cae_46 <- mk_cae();
   Ifc_cae cae_57 <- mk_cae();
   Ifc_cae cae_12_s3 <- mk_cae();
   Ifc_cae cae_56_s3 <- mk_cae();
   Ifc_cae cae_04 <- mk_cae();
   Ifc_cae cae_15 <- mk_cae();
   Ifc_cae cae_26 <- mk_cae();
   Ifc_cae cae_37 <- mk_cae();
   Ifc_cae cae_24 <- mk_cae();
   Ifc_cae cae_35 <- mk_cae();
   Ifc_cae cae_12_s6 <- mk_cae();
   Ifc_cae cae_34 <- mk_cae();
   Ifc_cae cae_56_s6 <- mk_cae();
   
   rule rl_start_sort (rg_stage == INIT && rg_data_valid && !rg_sort_complete);
      rg_stage_0 <= rg_input_data;
      rg_stage <= STAGE_1;
      rg_data_valid <= False;
   endrule
   
   // Rule: Stage 1 - Parallel OE 2's: (0,1), (2,3), (4,5), (6,7)
   rule rl_stage_1 (rg_stage == STAGE_1);
      let cae_in_01 = vec(rg_stage_0[0], rg_stage_0[1]);
      let cae_in_23 = vec(rg_stage_0[2], rg_stage_0[3]);
      let cae_in_45 = vec(rg_stage_0[4], rg_stage_0[5]);
      let cae_in_67 = vec(rg_stage_0[6], rg_stage_0[7]);
      
      let sorted_01 <- cae_01.mav_get_sort(cae_in_01);
      let sorted_23 <- cae_23.mav_get_sort(cae_in_23);
      let sorted_45 <- cae_45.mav_get_sort(cae_in_45);
      let sorted_67 <- cae_67.mav_get_sort(cae_in_67);
      
      ODE temp_stage_1 = replicate(0);
      temp_stage_1[0] = sorted_01[0]; temp_stage_1[1] = sorted_01[1];
      temp_stage_1[2] = sorted_23[0]; temp_stage_1[3] = sorted_23[1];
      temp_stage_1[4] = sorted_45[0]; temp_stage_1[5] = sorted_45[1];
      temp_stage_1[6] = sorted_67[0]; temp_stage_1[7] = sorted_67[1];
      
      rg_stage_1 <= temp_stage_1;
      rg_stage <= STAGE_2;
   endrule
   
   // Rule: Stage 2 - Parallel OE 4's: (0,2), (1,3), (4,6), (5,7)
   rule rl_stage_2 (rg_stage == STAGE_2);
      let cae_in_02 = vec(rg_stage_1[0], rg_stage_1[2]);
      let cae_in_13 = vec(rg_stage_1[1], rg_stage_1[3]);
      let cae_in_46 = vec(rg_stage_1[4], rg_stage_1[6]);
      let cae_in_57 = vec(rg_stage_1[5], rg_stage_1[7]);
      
      let sorted_02 <- cae_02.mav_get_sort(cae_in_02);
      let sorted_13 <- cae_13.mav_get_sort(cae_in_13);
      let sorted_46 <- cae_46.mav_get_sort(cae_in_46);
      let sorted_57 <- cae_57.mav_get_sort(cae_in_57);
      
      ODE temp_stage_2 = replicate(0);
      temp_stage_2[0] = sorted_02[0]; temp_stage_2[2] = sorted_02[1];
      temp_stage_2[1] = sorted_13[0]; temp_stage_2[3] = sorted_13[1];
      temp_stage_2[4] = sorted_46[0]; temp_stage_2[6] = sorted_46[1];
      temp_stage_2[5] = sorted_57[0]; temp_stage_2[7] = sorted_57[1];
      
      rg_stage_2 <= temp_stage_2;
      rg_stage <= STAGE_3;
   endrule
   
   // Rule: Stage 3 - Still Parallel OE 4's: (1,2), (5,6)
   rule rl_stage_3 (rg_stage == STAGE_3);
      let cae_in_12 = vec(rg_stage_2[1], rg_stage_2[2]);
      let cae_in_56 = vec(rg_stage_2[5], rg_stage_2[6]);
      
      let sorted_12 <- cae_12_s3.mav_get_sort(cae_in_12);
      let sorted_56 <- cae_56_s3.mav_get_sort(cae_in_56);
      
      ODE temp_stage_3 = rg_stage_2;
      temp_stage_3[1] = sorted_12[0]; 
      temp_stage_3[2] = sorted_12[1];
      temp_stage_3[5] = sorted_56[0]; 
      temp_stage_3[6] = sorted_56[1];
      
      rg_stage_3 <= temp_stage_3;
      rg_stage <= STAGE_4;
   endrule
   
   // Rule: Stage 4 - Parallel OE 8's begins: (0,4), (1,5), (2,6), (3,7)
   rule rl_stage_4 (rg_stage == STAGE_4);
      let cae_in_04 = vec(rg_stage_3[0], rg_stage_3[4]);
      let cae_in_15 = vec(rg_stage_3[1], rg_stage_3[5]);
      let cae_in_26 = vec(rg_stage_3[2], rg_stage_3[6]);
      let cae_in_37 = vec(rg_stage_3[3], rg_stage_3[7]);
      
      let sorted_04 <- cae_04.mav_get_sort(cae_in_04);
      let sorted_15 <- cae_15.mav_get_sort(cae_in_15);
      let sorted_26 <- cae_26.mav_get_sort(cae_in_26);
      let sorted_37 <- cae_37.mav_get_sort(cae_in_37);
      
      ODE temp_stage_4 = replicate(0);
      temp_stage_4[0] = sorted_04[0]; 
      temp_stage_4[4] = sorted_04[1];
      temp_stage_4[1] = sorted_15[0]; 
      temp_stage_4[5] = sorted_15[1];
      temp_stage_4[2] = sorted_26[0]; 
      temp_stage_4[6] = sorted_26[1];
      temp_stage_4[3] = sorted_37[0]; 
      temp_stage_4[7] = sorted_37[1];
      
      rg_stage_4 <= temp_stage_4;
      rg_stage <= STAGE_5;
   endrule
   
   // Rule: Stage 5 - Parallel OE 8's continues: (2,4), (3,5)
   rule rl_stage_5 (rg_stage == STAGE_5);
      let cae_in_24 = vec(rg_stage_4[2], rg_stage_4[4]);
      let cae_in_35 = vec(rg_stage_4[3], rg_stage_4[5]);
      
      let sorted_24 <- cae_24.mav_get_sort(cae_in_24);
      let sorted_35 <- cae_35.mav_get_sort(cae_in_35);
      
      ODE temp_stage_5 = rg_stage_4;
      temp_stage_5[2] = sorted_24[0]; 
      temp_stage_5[4] = sorted_24[1];
      temp_stage_5[3] = sorted_35[0]; 
      temp_stage_5[5] = sorted_35[1];
      
      rg_stage_5 <= temp_stage_5;
      rg_stage <= STAGE_6;
   endrule
   
   // Rule: Stage 6 - Final stage: (1,2), (3,4), (5,6)
   rule rl_stage_6 (rg_stage == STAGE_6);
      let cae_in_12 = vec(rg_stage_5[1], rg_stage_5[2]);
      let cae_in_34 = vec(rg_stage_5[3], rg_stage_5[4]);
      let cae_in_56 = vec(rg_stage_5[5], rg_stage_5[6]);
      
      let sorted_12 <- cae_12_s6.mav_get_sort(cae_in_12);
      let sorted_34 <- cae_34.mav_get_sort(cae_in_34);
      let sorted_56 <- cae_56_s6.mav_get_sort(cae_in_56);
      
      ODE temp_sorted = rg_stage_5;
      temp_sorted[1] = sorted_12[0]; 
      temp_sorted[2] = sorted_12[1];
      temp_sorted[3] = sorted_34[0]; 
      temp_sorted[4] = sorted_34[1];
      temp_sorted[5] = sorted_56[0]; 
      temp_sorted[6] = sorted_56[1];
      
      rg_output_data <= temp_sorted;
      rg_sort_complete <= True;
      rg_stage <= INIT;
   endrule
   
   method Action ma_put_data (ODE ode_in) if (rg_stage == INIT && !rg_data_valid);
      rg_input_data <= ode_in;
      rg_data_valid <= True;
      if (rg_sort_complete) begin
         rg_sort_complete <= False;
      end
   endmethod
   
   method ODE mv_get_sorted_data() if (rg_sort_complete);
      return rg_output_data;
   endmethod
   
   method Bool mv_is_ready();
      return rg_sort_complete;
   endmethod

endmodule

endpackage

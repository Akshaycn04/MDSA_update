package mdsa_hybrid;

import Vector :: *;
import mdsa_types :: *;
import hybrid_sorter :: *;

interface Ifc_mdsa_hybrid;
    method Action ma_input_mdsa (MDSA_64 mdsa);
    method ActionValue#(MDSA_64) mav_return_outputs;
endinterface

(*synthesize*)
module mk_mdsa_hybrid(Ifc_mdsa_hybrid);

    Reg#(MDSA_FSM) rg_mdsa_fsm <- mkReg(IDLE);
    Reg#(UInt#(8)) rg_wait_counter <- mkReg(0);
    Reg#(MDSA_64) v_rg_mdsa_data <- mkReg(unpack(0));

    // Vector of 8 sorting network interfaces
    Vector#(8, Ifc_hybrid_sorter) hybrid_sorters <- replicateM(mk_hybrid_sorter());

    /*------------------ PHASE 1: Column Sorting (All Normal = Descending) ----------------*/
    rule rl_phase1_input(rg_mdsa_fsm == STAGE_1_IN);
        
        // Send each column to a sorter (columns are already in column format)
        for (Integer i = 0; i < 8; i = i + 1) begin
            Vector#(8, Bit#(WordLength)) column = newVector();
            for (Integer j = 0; j < 8; j = j + 1) begin
                column[j] = v_rg_mdsa_data[j][i]; // Extract column i
            end
            hybrid_sorters[i].ma_put_data(column);
        end
        
        rg_mdsa_fsm <= STAGE_1_OUT;
        rg_wait_counter <= 0;
    endrule

    rule rl_phase1_output(rg_mdsa_fsm == STAGE_1_OUT);
        Bool all_ready = True;
        for (Integer i = 0; i < 8; i = i + 1) begin
            if (!hybrid_sorters[i].mv_is_ready()) all_ready = False;
        end
        
        if (all_ready && rg_wait_counter >= 20) begin
            MDSA_64 phase1_output = newVector();
            
            // Collect sorted columns (all in descending order)
            for (Integer i = 0; i < 8; i = i + 1) begin
                Vector#(8, Bit#(WordLength)) sorted_column = hybrid_sorters[i].mv_get_sorted_data();
                for (Integer j = 0; j < 8; j = j + 1) begin
                    phase1_output[j][i] = sorted_column[j]; // Place back in column format
                end
            end
            
            v_rg_mdsa_data <= phase1_output;
            rg_mdsa_fsm <= STAGE_2_IN;
        end else begin
            rg_wait_counter <= rg_wait_counter + 1;
        end
    endrule

    /*------------------ PHASE 2: Row Sorting (Even=Reverse/Ascending, Odd=Normal/Descending) ----------------*/
    rule rl_phase2_input(rg_mdsa_fsm == STAGE_2_IN);
        
        // Send each row to a sorter
        for (Integer i = 0; i < 8; i = i + 1) begin
            hybrid_sorters[i].ma_put_data(v_rg_mdsa_data[i]);
        end
        
        rg_mdsa_fsm <= STAGE_2_OUT;
        rg_wait_counter <= 0;
    endrule

    rule rl_phase2_output(rg_mdsa_fsm == STAGE_2_OUT);
        Bool all_ready = True;
        for (Integer i = 0; i < 8; i = i + 1) begin
            if (!hybrid_sorters[i].mv_is_ready()) all_ready = False;
        end
        
        if (all_ready && rg_wait_counter >= 20) begin
            MDSA_64 phase2_output = newVector();
            
            for (Integer i = 0; i < 8; i = i + 1) begin
                Vector#(8, Bit#(WordLength)) sorted_row = hybrid_sorters[i].mv_get_sorted_data();
                
                if (i % 2 == 0) begin
                    // Even rows (0,2,4,6): Reverse sorting (ascending)
                    phase2_output[i] = reverse(sorted_row);
                end else begin
                    // Odd rows (1,3,5,7): Normal sorting (descending)
                    phase2_output[i] = sorted_row;
                end
            end
            
            v_rg_mdsa_data <= phase2_output;
            rg_mdsa_fsm <= STAGE_3_IN;
        end else begin
            rg_wait_counter <= rg_wait_counter + 1;
        end
    endrule

    /*------------------ PHASE 3: Column Sorting (All Normal = Descending) ----------------*/
    rule rl_phase3_input(rg_mdsa_fsm == STAGE_3_IN);
        
        // Send each column to a sorter
        for (Integer i = 0; i < 8; i = i + 1) begin
            Vector#(8, Bit#(WordLength)) column = newVector();
            for (Integer j = 0; j < 8; j = j + 1) begin
                column[j] = v_rg_mdsa_data[j][i];
            end
            hybrid_sorters[i].ma_put_data(column);
        end
        
        rg_mdsa_fsm <= STAGE_3_OUT;
        rg_wait_counter <= 0;
    endrule

    rule rl_phase3_output(rg_mdsa_fsm == STAGE_3_OUT);
        Bool all_ready = True;
        for (Integer i = 0; i < 8; i = i + 1) begin
            if (!hybrid_sorters[i].mv_is_ready()) all_ready = False;
        end
        
        if (all_ready && rg_wait_counter >= 20) begin
            MDSA_64 phase3_output = newVector();
            
            for (Integer i = 0; i < 8; i = i + 1) begin
                Vector#(8, Bit#(WordLength)) sorted_column = hybrid_sorters[i].mv_get_sorted_data();
                for (Integer j = 0; j < 8; j = j + 1) begin
                    phase3_output[j][i] = sorted_column[j];
                end
            end
            
            v_rg_mdsa_data <= phase3_output;
            rg_mdsa_fsm <= STAGE_4_IN;
        end else begin
            rg_wait_counter <= rg_wait_counter + 1;
        end
    endrule

    /*------------------ PHASE 4: Row Sorting (Odd=Reverse/Ascending, Even=Normal/Descending) ----------------*/
    rule rl_phase4_input(rg_mdsa_fsm == STAGE_4_IN);
        
        for (Integer i = 0; i < 8; i = i + 1) begin
            hybrid_sorters[i].ma_put_data(v_rg_mdsa_data[i]);
        end
        
        rg_mdsa_fsm <= STAGE_4_OUT;
        rg_wait_counter <= 0;
    endrule

    rule rl_phase4_output(rg_mdsa_fsm == STAGE_4_OUT);
        Bool all_ready = True;
        for (Integer i = 0; i < 8; i = i + 1) begin
            if (!hybrid_sorters[i].mv_is_ready()) all_ready = False;
        end
        
        if (all_ready && rg_wait_counter >= 20) begin
            MDSA_64 phase4_output = newVector();
            
            for (Integer i = 0; i < 8; i = i + 1) begin
                Vector#(8, Bit#(WordLength)) sorted_row = hybrid_sorters[i].mv_get_sorted_data();
                
                if (i % 2 == 1) begin
                    // Odd rows (1,3,5,7): Reverse sorting (ascending)
                    phase4_output[i] = reverse(sorted_row);
                end else begin
                    // Even rows (0,2,4,6): Normal sorting (descending)
                    phase4_output[i] = sorted_row;
                end
            end
            
            v_rg_mdsa_data <= phase4_output;
            rg_mdsa_fsm <= STAGE_5_IN;
        end else begin
            rg_wait_counter <= rg_wait_counter + 1;
        end
    endrule

    /*------------------ PHASE 5: Column Sorting (All Normal = Descending) ----------------*/
    rule rl_phase5_input(rg_mdsa_fsm == STAGE_5_IN);
        
        for (Integer i = 0; i < 8; i = i + 1) begin
            Vector#(8, Bit#(WordLength)) column = newVector();
            for (Integer j = 0; j < 8; j = j + 1) begin
                column[j] = v_rg_mdsa_data[j][i];
            end
            hybrid_sorters[i].ma_put_data(column);
        end
        
        rg_mdsa_fsm <= STAGE_5_OUT;
        rg_wait_counter <= 0;
    endrule

    rule rl_phase5_output(rg_mdsa_fsm == STAGE_5_OUT);
        Bool all_ready = True;
        for (Integer i = 0; i < 8; i = i + 1) begin
            if (!hybrid_sorters[i].mv_is_ready()) all_ready = False;
        end
        
        if (all_ready && rg_wait_counter >= 20) begin
            MDSA_64 phase5_output = newVector();
            
            for (Integer i = 0; i < 8; i = i + 1) begin
                Vector#(8, Bit#(WordLength)) sorted_column = hybrid_sorters[i].mv_get_sorted_data();
                for (Integer j = 0; j < 8; j = j + 1) begin
                    phase5_output[j][i] = sorted_column[j];
                end
            end
            
            v_rg_mdsa_data <= phase5_output;
            rg_mdsa_fsm <= STAGE_6_IN;
        end else begin
            rg_wait_counter <= rg_wait_counter + 1;
        end
    endrule

    /*----------------- PHASE 6: Row Sorting (All Normal = Descending) ---------------*/
    rule rl_phase6_input(rg_mdsa_fsm == STAGE_6_IN);
        
        for (Integer i = 0; i < 8; i = i + 1) begin
            hybrid_sorters[i].ma_put_data(v_rg_mdsa_data[i]);
        end
        
        rg_mdsa_fsm <= STAGE_6_OUT;
        rg_wait_counter <= 0;
    endrule

    rule rl_phase6_output(rg_mdsa_fsm == STAGE_6_OUT);
        Bool all_ready = True;
        for (Integer i = 0; i < 8; i = i + 1) begin
            if (!hybrid_sorters[i].mv_is_ready()) all_ready = False;
        end
        
        if (all_ready && rg_wait_counter >= 20) begin
            MDSA_64 final_output = newVector();
            
            // All rows in normal sorting (descending order)
            for (Integer i = 0; i < 8; i = i + 1) begin
                final_output[i] = hybrid_sorters[i].mv_get_sorted_data();
            end
            
            v_rg_mdsa_data <= final_output;
            rg_mdsa_fsm <= MDSA_DONE;
        end else begin
            rg_wait_counter <= rg_wait_counter + 1;
        end
    endrule

    // Interface methods
    method Action ma_input_mdsa (MDSA_64 mdsa_in) if (rg_mdsa_fsm == IDLE);
        v_rg_mdsa_data <= mdsa_in;
        rg_mdsa_fsm <= STAGE_1_IN;
    endmethod

    method ActionValue#(MDSA_64) mav_return_outputs if (rg_mdsa_fsm == MDSA_DONE);
        rg_mdsa_fsm <= IDLE;
        return v_rg_mdsa_data;
    endmethod

endmodule

endpackage

package mdsa_types;

import Vector :: *;

// `define WordLength 32
typedef 32 WordLength;

// typedef of CAE inputs
typedef Vector#(2, Bit#(WordLength)) CAE;
// typedef of BM8 inputs
typedef Vector#(8, Bit#(WordLength)) ODE;

// typedef of the complete MDSA 64 input - two dimensional array of 8x8
typedef Vector#(8, Vector#(8, Bit#(WordLength))) MDSA_64;

typedef enum {
   INIT,
   STAGE_1,
   STAGE_2,
   STAGE_3,    
   STAGE_4,    
   STAGE_5,    
   STAGE_6   
} RG_STAGE deriving (Bits, Eq, FShow);


// The MDSA FSM
typedef enum {
    IDLE 
    , STAGE_1_IN
    , STAGE_1_OUT
    , STAGE_2_IN
    , STAGE_2_OUT
    , STAGE_3_IN
    , STAGE_3_OUT   
    , STAGE_4_IN
    , STAGE_4_OUT
    , STAGE_5_IN
    , STAGE_5_OUT
    , STAGE_6_IN
    , STAGE_6_OUT
    , MDSA_DONE
    } MDSA_FSM deriving (Bits, Eq, FShow);

`ifdef DISPLAY 
    function Action fn_display(Fmt display_statement);
        action
            $display("[%0d]", $time, display_statement);
        endaction
    endfunction
`else 
    function Action fn_display(Fmt display_statement);
        action 
            noAction;
        endaction
    endfunction
`endif


endpackage

{# include('templates/defines.v') #}
// NABP
//     6 Mar 2012
// The top level entity which encapsulates all components.
//
// S̲c̲h̲e̲m̲a̲t̲i̲c̲
//
//   __________________________
//  |       Sinogram RAM       |
//    ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅|̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅
//   _____________v̲____________
//  | ̲ ̲ ̲ ̲ ̲ ̲TODO ̲R̲e̲b̲i̲n̲n̲i̲n̲g̲ ̲ ̲ ̲ ̲ ̲ ̲|
//  |   Filtered RAM Control   |
//    ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅|̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅
//   _____________v̲____________
//  | Processing Swap Control  |
//    ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅|̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅
//   _____________v̲____________
//  |   Processing Elements    |
//    ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅|̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅  <- TODO implement processing element data out.
//   _____________v̲____________
//  |         Image RAM        |
//    ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅

module NABP
(
    // global signals
    input wire clk,
    input wire reset_n,
    // TODO inputs from Sinogram RAM
    // TODO inputs from Image RAM
    // TODO outputs to Sinogram RAM
    // TODO outputs to Image RAM
);

// TODO declaration of modules

endmodule

// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Primary design header
//
// This header should be included by all source files instantiating the design.
// The class here is then constructed to instantiate the design.
// See the Verilator manual for examples.

#ifndef _VTENSORDOTPRODUCTUNIT_TB_H_
#define _VTENSORDOTPRODUCTUNIT_TB_H_  // guard

#include "verilated_heavy.h"

//==========

class VTensorDotProductUnit_tb__Syms;
class VTensorDotProductUnit_tb_VerilatedVcd;


//----------

VL_MODULE(VTensorDotProductUnit_tb) {
  public:
    
    // LOCAL SIGNALS
    // Internals; generally not touched by application code
    CData/*0:0*/ TensorDotProductUnit_tb__DOT__clock;
    CData/*0:0*/ TensorDotProductUnit_tb__DOT__reset;
    CData/*0:0*/ TensorDotProductUnit_tb__DOT__io_in_valid;
    CData/*0:0*/ TensorDotProductUnit_tb__DOT__io_stall;
    CData/*0:0*/ TensorDotProductUnit_tb__DOT__io_out_valid;
    CData/*0:0*/ TensorDotProductUnit_tb__DOT__dut__DOT__valid_stage1;
    CData/*0:0*/ TensorDotProductUnit_tb__DOT__dut__DOT__valid_stage2;
    SData/*15:0*/ TensorDotProductUnit_tb__DOT__io_in_bits_a_0;
    SData/*15:0*/ TensorDotProductUnit_tb__DOT__io_in_bits_a_1;
    SData/*15:0*/ TensorDotProductUnit_tb__DOT__io_in_bits_a_2;
    SData/*15:0*/ TensorDotProductUnit_tb__DOT__io_in_bits_a_3;
    SData/*15:0*/ TensorDotProductUnit_tb__DOT__io_in_bits_b_0;
    SData/*15:0*/ TensorDotProductUnit_tb__DOT__io_in_bits_b_1;
    SData/*15:0*/ TensorDotProductUnit_tb__DOT__io_in_bits_b_2;
    SData/*15:0*/ TensorDotProductUnit_tb__DOT__io_in_bits_b_3;
    IData/*31:0*/ TensorDotProductUnit_tb__DOT__io_in_bits_c;
    IData/*31:0*/ TensorDotProductUnit_tb__DOT__cycle;
    IData/*31:0*/ TensorDotProductUnit_tb__DOT__dut__DOT__partial_result_0;
    IData/*31:0*/ TensorDotProductUnit_tb__DOT__dut__DOT__partial_result_1;
    IData/*31:0*/ TensorDotProductUnit_tb__DOT__dut__DOT__sum_ab;
    IData/*31:0*/ TensorDotProductUnit_tb__DOT__dut__DOT__result;
    
    // LOCAL VARIABLES
    // Internals; generally not touched by application code
    CData/*0:0*/ __VinpClk__TOP__TensorDotProductUnit_tb__DOT__clock;
    CData/*0:0*/ __VinpClk__TOP__TensorDotProductUnit_tb__DOT__reset;
    CData/*0:0*/ __Vclklast__TOP____VinpClk__TOP__TensorDotProductUnit_tb__DOT__clock;
    CData/*0:0*/ __Vclklast__TOP____VinpClk__TOP__TensorDotProductUnit_tb__DOT__reset;
    CData/*0:0*/ __Vchglast__TOP__TensorDotProductUnit_tb__DOT__clock;
    CData/*0:0*/ __Vchglast__TOP__TensorDotProductUnit_tb__DOT__reset;
    IData/*31:0*/ __Vm_traceActivity;
    
    // INTERNAL VARIABLES
    // Internals; generally not touched by application code
    VTensorDotProductUnit_tb__Syms* __VlSymsp;  // Symbol table
    
    // CONSTRUCTORS
  private:
    VL_UNCOPYABLE(VTensorDotProductUnit_tb);  ///< Copying not allowed
  public:
    /// Construct the model; called by application code
    /// The special name  may be used to make a wrapper with a
    /// single model invisible with respect to DPI scope names.
    VTensorDotProductUnit_tb(const char* name = "TOP");
    /// Destroy the model; called (often implicitly) by application code
    ~VTensorDotProductUnit_tb();
    /// Trace signals in the model; called by application code
    void trace(VerilatedVcdC* tfp, int levels, int options = 0);
    
    // API METHODS
    /// Evaluate the model.  Application must call when inputs change.
    void eval();
    /// Simulation complete, run final blocks.  Application must call on completion.
    void final();
    
    // INTERNAL METHODS
  private:
    static void _eval_initial_loop(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp);
  public:
    void __Vconfigure(VTensorDotProductUnit_tb__Syms* symsp, bool first);
  private:
    static QData _change_request(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp);
    void _ctor_var_reset() VL_ATTR_COLD;
  public:
    static void _eval(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp);
  private:
#ifdef VL_DEBUG
    void _eval_debug_assertions();
#endif  // VL_DEBUG
  public:
    static void _eval_initial(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp) VL_ATTR_COLD;
    static void _eval_settle(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp) VL_ATTR_COLD;
    static void _initial__TOP__1(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp) VL_ATTR_COLD;
    static void _initial__TOP__4(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp) VL_ATTR_COLD;
    static void _sequent__TOP__2(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp);
    static void _settle__TOP__3(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp) VL_ATTR_COLD;
    static void traceChgThis(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void traceChgThis__2(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void traceChgThis__3(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void traceChgThis__4(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void traceFullThis(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) VL_ATTR_COLD;
    static void traceFullThis__1(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) VL_ATTR_COLD;
    static void traceInitThis(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) VL_ATTR_COLD;
    static void traceInitThis__1(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) VL_ATTR_COLD;
    static void traceInit(VerilatedVcd* vcdp, void* userthis, uint32_t code);
    static void traceFull(VerilatedVcd* vcdp, void* userthis, uint32_t code);
    static void traceChg(VerilatedVcd* vcdp, void* userthis, uint32_t code);
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);

//----------


#endif  // guard

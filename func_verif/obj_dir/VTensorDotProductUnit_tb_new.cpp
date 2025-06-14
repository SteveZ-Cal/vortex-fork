// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VTensorDotProductUnit_tb_new.h for the primary calling header

#include "VTensorDotProductUnit_tb_new.h"
#include "VTensorDotProductUnit_tb_new__Syms.h"

//==========

VL_CTOR_IMP(VTensorDotProductUnit_tb_new) {
    VTensorDotProductUnit_tb_new__Syms* __restrict vlSymsp = __VlSymsp = new VTensorDotProductUnit_tb_new__Syms(this, name());
    VTensorDotProductUnit_tb_new* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Reset internal values
    
    // Reset structure values
    _ctor_var_reset();
}

void VTensorDotProductUnit_tb_new::__Vconfigure(VTensorDotProductUnit_tb_new__Syms* vlSymsp, bool first) {
    if (0 && first) {}  // Prevent unused
    this->__VlSymsp = vlSymsp;
}

VTensorDotProductUnit_tb_new::~VTensorDotProductUnit_tb_new() {
    delete __VlSymsp; __VlSymsp=NULL;
}

void VTensorDotProductUnit_tb_new::eval() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate VTensorDotProductUnit_tb_new::eval\n"); );
    VTensorDotProductUnit_tb_new__Syms* __restrict vlSymsp = this->__VlSymsp;  // Setup global symbol table
    VTensorDotProductUnit_tb_new* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
#ifdef VL_DEBUG
    // Debug assertions
    _eval_debug_assertions();
#endif  // VL_DEBUG
    // Initialize
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) _eval_initial_loop(vlSymsp);
    // Evaluate till stable
    int __VclockLoop = 0;
    QData __Vchange = 1;
    do {
        VL_DEBUG_IF(VL_DBG_MSGF("+ Clock loop\n"););
        vlSymsp->__Vm_activity = true;
        _eval(vlSymsp);
        if (VL_UNLIKELY(++__VclockLoop > 100)) {
            // About to fail, so enable debug to see what's not settling.
            // Note you must run make with OPT=-DVL_DEBUG for debug prints.
            int __Vsaved_debug = Verilated::debug();
            Verilated::debug(1);
            __Vchange = _change_request(vlSymsp);
            Verilated::debug(__Vsaved_debug);
            VL_FATAL_MT("TensorDotProductUnit_tb_new.sv", 1, "",
                "Verilated model didn't converge\n"
                "- See DIDNOTCONVERGE in the Verilator manual");
        } else {
            __Vchange = _change_request(vlSymsp);
        }
    } while (VL_UNLIKELY(__Vchange));
}

void VTensorDotProductUnit_tb_new::_eval_initial_loop(VTensorDotProductUnit_tb_new__Syms* __restrict vlSymsp) {
    vlSymsp->__Vm_didInit = true;
    _eval_initial(vlSymsp);
    vlSymsp->__Vm_activity = true;
    // Evaluate till stable
    int __VclockLoop = 0;
    QData __Vchange = 1;
    do {
        _eval_settle(vlSymsp);
        _eval(vlSymsp);
        if (VL_UNLIKELY(++__VclockLoop > 100)) {
            // About to fail, so enable debug to see what's not settling.
            // Note you must run make with OPT=-DVL_DEBUG for debug prints.
            int __Vsaved_debug = Verilated::debug();
            Verilated::debug(1);
            __Vchange = _change_request(vlSymsp);
            Verilated::debug(__Vsaved_debug);
            VL_FATAL_MT("TensorDotProductUnit_tb_new.sv", 1, "",
                "Verilated model didn't DC converge\n"
                "- See DIDNOTCONVERGE in the Verilator manual");
        } else {
            __Vchange = _change_request(vlSymsp);
        }
    } while (VL_UNLIKELY(__Vchange));
}

VL_INLINE_OPT void VTensorDotProductUnit_tb_new::_sequent__TOP__1(VTensorDotProductUnit_tb_new__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTensorDotProductUnit_tb_new::_sequent__TOP__1\n"); );
    VTensorDotProductUnit_tb_new* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->__Vdly__TensorDotProductUnit_tb_new__DOT__dut__DOT__sum_ab 
        = vlTOPp->TensorDotProductUnit_tb_new__DOT__dut__DOT__sum_ab;
    if (vlTOPp->TensorDotProductUnit_tb_new__DOT__reset) {
        vlTOPp->TensorDotProductUnit_tb_new__DOT__dut__DOT__valid_stage2 = 0U;
    } else {
        if ((1U & (~ (IData)(vlTOPp->TensorDotProductUnit_tb_new__DOT__io_stall)))) {
            vlTOPp->TensorDotProductUnit_tb_new__DOT__dut__DOT__valid_stage2 
                = vlTOPp->TensorDotProductUnit_tb_new__DOT__dut__DOT__valid_stage1;
        }
    }
    if (vlTOPp->TensorDotProductUnit_tb_new__DOT__reset) {
        vlTOPp->__Vdly__TensorDotProductUnit_tb_new__DOT__dut__DOT__sum_ab = 0U;
    } else {
        if ((1U & (~ (IData)(vlTOPp->TensorDotProductUnit_tb_new__DOT__io_stall)))) {
            vlTOPp->__Vdly__TensorDotProductUnit_tb_new__DOT__dut__DOT__sum_ab 
                = (vlTOPp->TensorDotProductUnit_tb_new__DOT__dut__DOT__partial_result_0 
                   + vlTOPp->TensorDotProductUnit_tb_new__DOT__dut__DOT__partial_result_1);
        }
    }
    if (vlTOPp->TensorDotProductUnit_tb_new__DOT__reset) {
        vlTOPp->TensorDotProductUnit_tb_new__DOT__dut__DOT__valid_stage1 = 0U;
    } else {
        if ((1U & (~ (IData)(vlTOPp->TensorDotProductUnit_tb_new__DOT__io_stall)))) {
            vlTOPp->TensorDotProductUnit_tb_new__DOT__dut__DOT__valid_stage1 
                = vlTOPp->TensorDotProductUnit_tb_new__DOT__io_in_valid;
        }
    }
    if (vlTOPp->TensorDotProductUnit_tb_new__DOT__reset) {
        vlTOPp->TensorDotProductUnit_tb_new__DOT__dut__DOT__partial_result_0 = 0U;
    } else {
        if ((1U & (~ (IData)(vlTOPp->TensorDotProductUnit_tb_new__DOT__io_stall)))) {
            vlTOPp->TensorDotProductUnit_tb_new__DOT__dut__DOT__partial_result_0 
                = ((((IData)(vlTOPp->TensorDotProductUnit_tb_new__DOT__io_in_bits_a_1) 
                     << 0x10U) | (IData)(vlTOPp->TensorDotProductUnit_tb_new__DOT__io_in_bits_a_0)) 
                   * (((IData)(vlTOPp->TensorDotProductUnit_tb_new__DOT__io_in_bits_b_1) 
                       << 0x10U) | (IData)(vlTOPp->TensorDotProductUnit_tb_new__DOT__io_in_bits_b_0)));
        }
    }
    if (vlTOPp->TensorDotProductUnit_tb_new__DOT__reset) {
        vlTOPp->TensorDotProductUnit_tb_new__DOT__dut__DOT__partial_result_1 = 0U;
    } else {
        if ((1U & (~ (IData)(vlTOPp->TensorDotProductUnit_tb_new__DOT__io_stall)))) {
            vlTOPp->TensorDotProductUnit_tb_new__DOT__dut__DOT__partial_result_1 
                = ((((IData)(vlTOPp->TensorDotProductUnit_tb_new__DOT__io_in_bits_a_3) 
                     << 0x10U) | (IData)(vlTOPp->TensorDotProductUnit_tb_new__DOT__io_in_bits_a_2)) 
                   * (((IData)(vlTOPp->TensorDotProductUnit_tb_new__DOT__io_in_bits_b_3) 
                       << 0x10U) | (IData)(vlTOPp->TensorDotProductUnit_tb_new__DOT__io_in_bits_b_2)));
        }
    }
}

VL_INLINE_OPT void VTensorDotProductUnit_tb_new::_sequent__TOP__2(VTensorDotProductUnit_tb_new__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTensorDotProductUnit_tb_new::_sequent__TOP__2\n"); );
    VTensorDotProductUnit_tb_new* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Variables
    IData/*31:0*/ __Vdly__TensorDotProductUnit_tb_new__DOT__cycle;
    // Body
    vlTOPp->__Vdly__TensorDotProductUnit_tb_new__DOT__reset 
        = vlTOPp->TensorDotProductUnit_tb_new__DOT__reset;
    vlTOPp->__Vdly__TensorDotProductUnit_tb_new__DOT__io_in_bits_c 
        = vlTOPp->TensorDotProductUnit_tb_new__DOT__io_in_bits_c;
    __Vdly__TensorDotProductUnit_tb_new__DOT__cycle 
        = vlTOPp->TensorDotProductUnit_tb_new__DOT__cycle;
    vlTOPp->__Vdly__TensorDotProductUnit_tb_new__DOT__io_stall 
        = vlTOPp->TensorDotProductUnit_tb_new__DOT__io_stall;
    __Vdly__TensorDotProductUnit_tb_new__DOT__cycle 
        = ((IData)(1U) + vlTOPp->TensorDotProductUnit_tb_new__DOT__cycle);
    if ((0U == vlTOPp->TensorDotProductUnit_tb_new__DOT__cycle)) {
        vlTOPp->__Vdly__TensorDotProductUnit_tb_new__DOT__reset = 1U;
        vlTOPp->TensorDotProductUnit_tb_new__DOT__io_in_valid = 0U;
        vlTOPp->__Vdly__TensorDotProductUnit_tb_new__DOT__io_stall = 0U;
        vlTOPp->TensorDotProductUnit_tb_new__DOT__io_in_bits_a_0 = 0U;
        vlTOPp->TensorDotProductUnit_tb_new__DOT__io_in_bits_a_1 = 0U;
        vlTOPp->TensorDotProductUnit_tb_new__DOT__io_in_bits_a_2 = 0U;
        vlTOPp->TensorDotProductUnit_tb_new__DOT__io_in_bits_a_3 = 0U;
        vlTOPp->TensorDotProductUnit_tb_new__DOT__io_in_bits_b_0 = 0U;
        vlTOPp->TensorDotProductUnit_tb_new__DOT__io_in_bits_b_1 = 0U;
        vlTOPp->TensorDotProductUnit_tb_new__DOT__io_in_bits_b_2 = 0U;
        vlTOPp->TensorDotProductUnit_tb_new__DOT__io_in_bits_b_3 = 0U;
        vlTOPp->__Vdly__TensorDotProductUnit_tb_new__DOT__io_in_bits_c = 0U;
    } else {
        if ((2U == vlTOPp->TensorDotProductUnit_tb_new__DOT__cycle)) {
            vlTOPp->__Vdly__TensorDotProductUnit_tb_new__DOT__reset = 0U;
        } else {
            if ((3U == vlTOPp->TensorDotProductUnit_tb_new__DOT__cycle)) {
                vlTOPp->TensorDotProductUnit_tb_new__DOT__io_in_valid = 1U;
                vlTOPp->TensorDotProductUnit_tb_new__DOT__io_in_bits_a_0 = 0x3c00U;
                vlTOPp->TensorDotProductUnit_tb_new__DOT__io_in_bits_a_1 = 0x4000U;
                vlTOPp->TensorDotProductUnit_tb_new__DOT__io_in_bits_b_0 = 0x4200U;
                vlTOPp->TensorDotProductUnit_tb_new__DOT__io_in_bits_b_1 = 0x4400U;
                vlTOPp->__Vdly__TensorDotProductUnit_tb_new__DOT__io_in_bits_c = 0x40400000U;
            } else {
                if ((4U == vlTOPp->TensorDotProductUnit_tb_new__DOT__cycle)) {
                    vlTOPp->TensorDotProductUnit_tb_new__DOT__io_in_valid = 0U;
                } else {
                    if (VL_UNLIKELY((0xaU == vlTOPp->TensorDotProductUnit_tb_new__DOT__cycle))) {
                        VL_WRITEF("Output at cycle %0d: 0x%08x\n",
                                  32,vlTOPp->TensorDotProductUnit_tb_new__DOT__cycle,
                                  32,vlTOPp->TensorDotProductUnit_tb_new__DOT__dut__DOT__result);
                        if (((IData)(vlTOPp->TensorDotProductUnit_tb_new__DOT__io_out_valid) 
                             & (0x41600000U == vlTOPp->TensorDotProductUnit_tb_new__DOT__dut__DOT__result))) {
                            VL_WRITEF("TEST PASSED\n");
                        } else {
                            VL_WRITEF("TEST FAILED\n");
                        }
                        VL_FINISH_MT("TensorDotProductUnit_tb_new.sv", 73, "");
                    }
                }
            }
        }
    }
    vlTOPp->TensorDotProductUnit_tb_new__DOT__cycle 
        = __Vdly__TensorDotProductUnit_tb_new__DOT__cycle;
}

void VTensorDotProductUnit_tb_new::_initial__TOP__3(VTensorDotProductUnit_tb_new__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTensorDotProductUnit_tb_new::_initial__TOP__3\n"); );
    VTensorDotProductUnit_tb_new* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->TensorDotProductUnit_tb_new__DOT__cycle = 0U;
}

VL_INLINE_OPT void VTensorDotProductUnit_tb_new::_settle__TOP__4(VTensorDotProductUnit_tb_new__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTensorDotProductUnit_tb_new::_settle__TOP__4\n"); );
    VTensorDotProductUnit_tb_new* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->TensorDotProductUnit_tb_new__DOT__io_out_valid 
        = ((IData)(vlTOPp->TensorDotProductUnit_tb_new__DOT__dut__DOT__valid_stage2) 
           & (~ (IData)(vlTOPp->TensorDotProductUnit_tb_new__DOT__io_stall)));
}

VL_INLINE_OPT void VTensorDotProductUnit_tb_new::_sequent__TOP__5(VTensorDotProductUnit_tb_new__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTensorDotProductUnit_tb_new::_sequent__TOP__5\n"); );
    VTensorDotProductUnit_tb_new* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    if (vlTOPp->TensorDotProductUnit_tb_new__DOT__reset) {
        vlTOPp->TensorDotProductUnit_tb_new__DOT__dut__DOT__result = 0U;
    } else {
        if ((1U & (~ (IData)(vlTOPp->TensorDotProductUnit_tb_new__DOT__io_stall)))) {
            vlTOPp->TensorDotProductUnit_tb_new__DOT__dut__DOT__result 
                = (vlTOPp->TensorDotProductUnit_tb_new__DOT__dut__DOT__sum_ab 
                   + vlTOPp->TensorDotProductUnit_tb_new__DOT__io_in_bits_c);
        }
    }
    vlTOPp->TensorDotProductUnit_tb_new__DOT__dut__DOT__sum_ab 
        = vlTOPp->__Vdly__TensorDotProductUnit_tb_new__DOT__dut__DOT__sum_ab;
}

VL_INLINE_OPT void VTensorDotProductUnit_tb_new::_sequent__TOP__6(VTensorDotProductUnit_tb_new__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTensorDotProductUnit_tb_new::_sequent__TOP__6\n"); );
    VTensorDotProductUnit_tb_new* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->TensorDotProductUnit_tb_new__DOT__io_in_bits_c 
        = vlTOPp->__Vdly__TensorDotProductUnit_tb_new__DOT__io_in_bits_c;
    vlTOPp->TensorDotProductUnit_tb_new__DOT__reset 
        = vlTOPp->__Vdly__TensorDotProductUnit_tb_new__DOT__reset;
    vlTOPp->TensorDotProductUnit_tb_new__DOT__io_stall 
        = vlTOPp->__Vdly__TensorDotProductUnit_tb_new__DOT__io_stall;
}

void VTensorDotProductUnit_tb_new::_eval(VTensorDotProductUnit_tb_new__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTensorDotProductUnit_tb_new::_eval\n"); );
    VTensorDotProductUnit_tb_new* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    if ((((IData)(vlTOPp->TensorDotProductUnit_tb_new__DOT__clock) 
          & (~ (IData)(vlTOPp->__Vclklast__TOP__TensorDotProductUnit_tb_new__DOT__clock))) 
         | ((IData)(vlTOPp->__VinpClk__TOP__TensorDotProductUnit_tb_new__DOT__reset) 
            & (~ (IData)(vlTOPp->__Vclklast__TOP____VinpClk__TOP__TensorDotProductUnit_tb_new__DOT__reset))))) {
        vlTOPp->_sequent__TOP__1(vlSymsp);
        vlTOPp->__Vm_traceActivity = (2U | vlTOPp->__Vm_traceActivity);
    }
    if (((IData)(vlTOPp->TensorDotProductUnit_tb_new__DOT__clock) 
         & (~ (IData)(vlTOPp->__Vclklast__TOP__TensorDotProductUnit_tb_new__DOT__clock)))) {
        vlTOPp->_sequent__TOP__2(vlSymsp);
        vlTOPp->__Vm_traceActivity = (4U | vlTOPp->__Vm_traceActivity);
    }
    if ((((IData)(vlTOPp->TensorDotProductUnit_tb_new__DOT__clock) 
          & (~ (IData)(vlTOPp->__Vclklast__TOP__TensorDotProductUnit_tb_new__DOT__clock))) 
         | ((IData)(vlTOPp->__VinpClk__TOP__TensorDotProductUnit_tb_new__DOT__reset) 
            & (~ (IData)(vlTOPp->__Vclklast__TOP____VinpClk__TOP__TensorDotProductUnit_tb_new__DOT__reset))))) {
        vlTOPp->_sequent__TOP__5(vlSymsp);
        vlTOPp->__Vm_traceActivity = (8U | vlTOPp->__Vm_traceActivity);
    }
    if (((IData)(vlTOPp->TensorDotProductUnit_tb_new__DOT__clock) 
         & (~ (IData)(vlTOPp->__Vclklast__TOP__TensorDotProductUnit_tb_new__DOT__clock)))) {
        vlTOPp->_sequent__TOP__6(vlSymsp);
        vlTOPp->__Vm_traceActivity = (0x10U | vlTOPp->__Vm_traceActivity);
    }
    if ((((IData)(vlTOPp->TensorDotProductUnit_tb_new__DOT__clock) 
          & (~ (IData)(vlTOPp->__Vclklast__TOP__TensorDotProductUnit_tb_new__DOT__clock))) 
         | ((IData)(vlTOPp->__VinpClk__TOP__TensorDotProductUnit_tb_new__DOT__reset) 
            & (~ (IData)(vlTOPp->__Vclklast__TOP____VinpClk__TOP__TensorDotProductUnit_tb_new__DOT__reset))))) {
        vlTOPp->_settle__TOP__4(vlSymsp);
    }
    // Final
    vlTOPp->__Vclklast__TOP__TensorDotProductUnit_tb_new__DOT__clock 
        = vlTOPp->TensorDotProductUnit_tb_new__DOT__clock;
    vlTOPp->__Vclklast__TOP____VinpClk__TOP__TensorDotProductUnit_tb_new__DOT__reset 
        = vlTOPp->__VinpClk__TOP__TensorDotProductUnit_tb_new__DOT__reset;
    vlTOPp->__VinpClk__TOP__TensorDotProductUnit_tb_new__DOT__reset 
        = vlTOPp->TensorDotProductUnit_tb_new__DOT__reset;
}

void VTensorDotProductUnit_tb_new::_eval_initial(VTensorDotProductUnit_tb_new__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTensorDotProductUnit_tb_new::_eval_initial\n"); );
    VTensorDotProductUnit_tb_new* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->__Vclklast__TOP__TensorDotProductUnit_tb_new__DOT__clock 
        = vlTOPp->TensorDotProductUnit_tb_new__DOT__clock;
    vlTOPp->__Vclklast__TOP____VinpClk__TOP__TensorDotProductUnit_tb_new__DOT__reset 
        = vlTOPp->__VinpClk__TOP__TensorDotProductUnit_tb_new__DOT__reset;
    vlTOPp->_initial__TOP__3(vlSymsp);
    vlTOPp->__Vm_traceActivity = (1U | vlTOPp->__Vm_traceActivity);
}

void VTensorDotProductUnit_tb_new::final() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTensorDotProductUnit_tb_new::final\n"); );
    // Variables
    VTensorDotProductUnit_tb_new__Syms* __restrict vlSymsp = this->__VlSymsp;
    VTensorDotProductUnit_tb_new* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void VTensorDotProductUnit_tb_new::_eval_settle(VTensorDotProductUnit_tb_new__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTensorDotProductUnit_tb_new::_eval_settle\n"); );
    VTensorDotProductUnit_tb_new* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->_settle__TOP__4(vlSymsp);
}

VL_INLINE_OPT QData VTensorDotProductUnit_tb_new::_change_request(VTensorDotProductUnit_tb_new__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTensorDotProductUnit_tb_new::_change_request\n"); );
    VTensorDotProductUnit_tb_new* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    // Change detection
    QData __req = false;  // Logically a bool
    __req |= ((vlTOPp->TensorDotProductUnit_tb_new__DOT__reset ^ vlTOPp->__Vchglast__TOP__TensorDotProductUnit_tb_new__DOT__reset));
    VL_DEBUG_IF( if(__req && ((vlTOPp->TensorDotProductUnit_tb_new__DOT__reset ^ vlTOPp->__Vchglast__TOP__TensorDotProductUnit_tb_new__DOT__reset))) VL_DBG_MSGF("        CHANGE: TensorDotProductUnit_tb_new.sv:4: TensorDotProductUnit_tb_new.reset\n"); );
    // Final
    vlTOPp->__Vchglast__TOP__TensorDotProductUnit_tb_new__DOT__reset 
        = vlTOPp->TensorDotProductUnit_tb_new__DOT__reset;
    return __req;
}

#ifdef VL_DEBUG
void VTensorDotProductUnit_tb_new::_eval_debug_assertions() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTensorDotProductUnit_tb_new::_eval_debug_assertions\n"); );
}
#endif  // VL_DEBUG

void VTensorDotProductUnit_tb_new::_ctor_var_reset() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTensorDotProductUnit_tb_new::_ctor_var_reset\n"); );
    // Body
    TensorDotProductUnit_tb_new__DOT__clock = VL_RAND_RESET_I(1);
    TensorDotProductUnit_tb_new__DOT__reset = VL_RAND_RESET_I(1);
    TensorDotProductUnit_tb_new__DOT__io_in_valid = VL_RAND_RESET_I(1);
    TensorDotProductUnit_tb_new__DOT__io_in_bits_a_0 = VL_RAND_RESET_I(16);
    TensorDotProductUnit_tb_new__DOT__io_in_bits_a_1 = VL_RAND_RESET_I(16);
    TensorDotProductUnit_tb_new__DOT__io_in_bits_a_2 = VL_RAND_RESET_I(16);
    TensorDotProductUnit_tb_new__DOT__io_in_bits_a_3 = VL_RAND_RESET_I(16);
    TensorDotProductUnit_tb_new__DOT__io_in_bits_b_0 = VL_RAND_RESET_I(16);
    TensorDotProductUnit_tb_new__DOT__io_in_bits_b_1 = VL_RAND_RESET_I(16);
    TensorDotProductUnit_tb_new__DOT__io_in_bits_b_2 = VL_RAND_RESET_I(16);
    TensorDotProductUnit_tb_new__DOT__io_in_bits_b_3 = VL_RAND_RESET_I(16);
    TensorDotProductUnit_tb_new__DOT__io_in_bits_c = VL_RAND_RESET_I(32);
    TensorDotProductUnit_tb_new__DOT__io_stall = VL_RAND_RESET_I(1);
    TensorDotProductUnit_tb_new__DOT__io_out_valid = VL_RAND_RESET_I(1);
    TensorDotProductUnit_tb_new__DOT__cycle = VL_RAND_RESET_I(32);
    TensorDotProductUnit_tb_new__DOT__dut__DOT__partial_result_0 = VL_RAND_RESET_I(32);
    TensorDotProductUnit_tb_new__DOT__dut__DOT__partial_result_1 = VL_RAND_RESET_I(32);
    TensorDotProductUnit_tb_new__DOT__dut__DOT__sum_ab = VL_RAND_RESET_I(32);
    TensorDotProductUnit_tb_new__DOT__dut__DOT__result = VL_RAND_RESET_I(32);
    TensorDotProductUnit_tb_new__DOT__dut__DOT__valid_stage1 = VL_RAND_RESET_I(1);
    TensorDotProductUnit_tb_new__DOT__dut__DOT__valid_stage2 = VL_RAND_RESET_I(1);
    __Vdly__TensorDotProductUnit_tb_new__DOT__reset = VL_RAND_RESET_I(1);
    __Vdly__TensorDotProductUnit_tb_new__DOT__io_stall = VL_RAND_RESET_I(1);
    __Vdly__TensorDotProductUnit_tb_new__DOT__io_in_bits_c = VL_RAND_RESET_I(32);
    __Vdly__TensorDotProductUnit_tb_new__DOT__dut__DOT__sum_ab = VL_RAND_RESET_I(32);
    __VinpClk__TOP__TensorDotProductUnit_tb_new__DOT__reset = VL_RAND_RESET_I(1);
    __Vchglast__TOP__TensorDotProductUnit_tb_new__DOT__reset = VL_RAND_RESET_I(1);
    __Vm_traceActivity = 0;
}

// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VTensorDotProductUnit_tb.h for the primary calling header

#include "VTensorDotProductUnit_tb.h"
#include "VTensorDotProductUnit_tb__Syms.h"

//==========

VL_CTOR_IMP(VTensorDotProductUnit_tb) {
    VTensorDotProductUnit_tb__Syms* __restrict vlSymsp = __VlSymsp = new VTensorDotProductUnit_tb__Syms(this, name());
    VTensorDotProductUnit_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Reset internal values
    
    // Reset structure values
    _ctor_var_reset();
}

void VTensorDotProductUnit_tb::__Vconfigure(VTensorDotProductUnit_tb__Syms* vlSymsp, bool first) {
    if (0 && first) {}  // Prevent unused
    this->__VlSymsp = vlSymsp;
}

VTensorDotProductUnit_tb::~VTensorDotProductUnit_tb() {
    delete __VlSymsp; __VlSymsp=NULL;
}

void VTensorDotProductUnit_tb::eval() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate VTensorDotProductUnit_tb::eval\n"); );
    VTensorDotProductUnit_tb__Syms* __restrict vlSymsp = this->__VlSymsp;  // Setup global symbol table
    VTensorDotProductUnit_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
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

void VTensorDotProductUnit_tb::_eval_initial_loop(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp) {
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

void VTensorDotProductUnit_tb::_initial__TOP__1(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTensorDotProductUnit_tb::_initial__TOP__1\n"); );
    VTensorDotProductUnit_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
}

VL_INLINE_OPT void VTensorDotProductUnit_tb::_sequent__TOP__2(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTensorDotProductUnit_tb::_sequent__TOP__2\n"); );
    VTensorDotProductUnit_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    if (vlTOPp->TensorDotProductUnit_tb__DOT__reset) {
        vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__valid_stage2 = 0U;
    } else {
        if ((1U & (~ (IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_stall)))) {
            vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__valid_stage2 
                = vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__valid_stage1;
        }
    }
    if (vlTOPp->TensorDotProductUnit_tb__DOT__reset) {
        vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__result = 0U;
    } else {
        if ((1U & (~ (IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_stall)))) {
            vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__result 
                = (vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__sum_ab 
                   + vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_c);
        }
    }
    vlTOPp->TensorDotProductUnit_tb__DOT__io_out_valid 
        = ((IData)(vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__valid_stage2) 
           & (~ (IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_stall)));
    if (vlTOPp->TensorDotProductUnit_tb__DOT__reset) {
        vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__valid_stage1 = 0U;
    } else {
        if ((1U & (~ (IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_stall)))) {
            vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__valid_stage1 
                = vlTOPp->TensorDotProductUnit_tb__DOT__io_in_valid;
        }
    }
    if (vlTOPp->TensorDotProductUnit_tb__DOT__reset) {
        vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__sum_ab = 0U;
    } else {
        if ((1U & (~ (IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_stall)))) {
            vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__sum_ab 
                = (vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__partial_result_0 
                   + vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__partial_result_1);
        }
    }
    if (vlTOPp->TensorDotProductUnit_tb__DOT__reset) {
        vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__partial_result_0 = 0U;
    } else {
        if ((1U & (~ (IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_stall)))) {
            vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__partial_result_0 
                = ((((IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_a_1) 
                     << 0x10U) | (IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_a_0)) 
                   * (((IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_b_1) 
                       << 0x10U) | (IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_b_0)));
        }
    }
    if (vlTOPp->TensorDotProductUnit_tb__DOT__reset) {
        vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__partial_result_1 = 0U;
    } else {
        if ((1U & (~ (IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_stall)))) {
            vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__partial_result_1 
                = ((((IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_a_3) 
                     << 0x10U) | (IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_a_2)) 
                   * (((IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_b_3) 
                       << 0x10U) | (IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_b_2)));
        }
    }
}

void VTensorDotProductUnit_tb::_settle__TOP__3(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTensorDotProductUnit_tb::_settle__TOP__3\n"); );
    VTensorDotProductUnit_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->TensorDotProductUnit_tb__DOT__io_out_valid 
        = ((IData)(vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__valid_stage2) 
           & (~ (IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_stall)));
}

void VTensorDotProductUnit_tb::_initial__TOP__4(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTensorDotProductUnit_tb::_initial__TOP__4\n"); );
    VTensorDotProductUnit_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->TensorDotProductUnit_tb__DOT__io_stall = 0U;
    vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_a_0 = 0x3c00U;
    vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_a_1 = 0x4000U;
    vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_a_2 = 0U;
    vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_a_3 = 0U;
    vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_b_0 = 0x4200U;
    vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_b_1 = 0x4400U;
    vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_b_2 = 0U;
    vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_b_3 = 0U;
    vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_c = 0x40400000U;
    vlTOPp->TensorDotProductUnit_tb__DOT__reset = 0U;
    vlTOPp->TensorDotProductUnit_tb__DOT__io_in_valid = 0U;
    if (VL_UNLIKELY(vlTOPp->TensorDotProductUnit_tb__DOT__io_out_valid)) {
        VL_WRITEF("Output (hex): %x\n",32,vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__result);
        if ((0x41600000U != vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__result)) {
            VL_WRITEF("TEST FAILED: Expected 0x41600000\n");
            VL_FINISH_MT("TensorDotProductUnit_tb_new.sv", 69, "");
        } else {
            VL_WRITEF("TEST PASSED\n");
            VL_FINISH_MT("TensorDotProductUnit_tb_new.sv", 72, "");
        }
    }
    if (VL_UNLIKELY(vlTOPp->TensorDotProductUnit_tb__DOT__io_out_valid)) {
        VL_WRITEF("Output (hex): %x\n",32,vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__result);
        if ((0x41600000U != vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__result)) {
            VL_WRITEF("TEST FAILED: Expected 0x41600000\n");
            VL_FINISH_MT("TensorDotProductUnit_tb_new.sv", 69, "");
        } else {
            VL_WRITEF("TEST PASSED\n");
            VL_FINISH_MT("TensorDotProductUnit_tb_new.sv", 72, "");
        }
    }
    if (VL_UNLIKELY(vlTOPp->TensorDotProductUnit_tb__DOT__io_out_valid)) {
        VL_WRITEF("Output (hex): %x\n",32,vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__result);
        if ((0x41600000U != vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__result)) {
            VL_WRITEF("TEST FAILED: Expected 0x41600000\n");
            VL_FINISH_MT("TensorDotProductUnit_tb_new.sv", 69, "");
        } else {
            VL_WRITEF("TEST PASSED\n");
            VL_FINISH_MT("TensorDotProductUnit_tb_new.sv", 72, "");
        }
    }
    if (VL_UNLIKELY(vlTOPp->TensorDotProductUnit_tb__DOT__io_out_valid)) {
        VL_WRITEF("Output (hex): %x\n",32,vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__result);
        if ((0x41600000U != vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__result)) {
            VL_WRITEF("TEST FAILED: Expected 0x41600000\n");
            VL_FINISH_MT("TensorDotProductUnit_tb_new.sv", 69, "");
        } else {
            VL_WRITEF("TEST PASSED\n");
            VL_FINISH_MT("TensorDotProductUnit_tb_new.sv", 72, "");
        }
    }
    if (VL_UNLIKELY(vlTOPp->TensorDotProductUnit_tb__DOT__io_out_valid)) {
        VL_WRITEF("Output (hex): %x\n",32,vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__result);
        if ((0x41600000U != vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__result)) {
            VL_WRITEF("TEST FAILED: Expected 0x41600000\n");
            VL_FINISH_MT("TensorDotProductUnit_tb_new.sv", 69, "");
        } else {
            VL_WRITEF("TEST PASSED\n");
            VL_FINISH_MT("TensorDotProductUnit_tb_new.sv", 72, "");
        }
    }
    if (VL_UNLIKELY(vlTOPp->TensorDotProductUnit_tb__DOT__io_out_valid)) {
        VL_WRITEF("Output (hex): %x\n",32,vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__result);
        if ((0x41600000U != vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__result)) {
            VL_WRITEF("TEST FAILED: Expected 0x41600000\n");
            VL_FINISH_MT("TensorDotProductUnit_tb_new.sv", 69, "");
        } else {
            VL_WRITEF("TEST PASSED\n");
            VL_FINISH_MT("TensorDotProductUnit_tb_new.sv", 72, "");
        }
    }
    if (VL_UNLIKELY(vlTOPp->TensorDotProductUnit_tb__DOT__io_out_valid)) {
        VL_WRITEF("Output (hex): %x\n",32,vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__result);
        if ((0x41600000U != vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__result)) {
            VL_WRITEF("TEST FAILED: Expected 0x41600000\n");
            VL_FINISH_MT("TensorDotProductUnit_tb_new.sv", 69, "");
        } else {
            VL_WRITEF("TEST PASSED\n");
            VL_FINISH_MT("TensorDotProductUnit_tb_new.sv", 72, "");
        }
    }
    if (VL_UNLIKELY(vlTOPp->TensorDotProductUnit_tb__DOT__io_out_valid)) {
        VL_WRITEF("Output (hex): %x\n",32,vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__result);
        if ((0x41600000U != vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__result)) {
            VL_WRITEF("TEST FAILED: Expected 0x41600000\n");
            VL_FINISH_MT("TensorDotProductUnit_tb_new.sv", 69, "");
        } else {
            VL_WRITEF("TEST PASSED\n");
            VL_FINISH_MT("TensorDotProductUnit_tb_new.sv", 72, "");
        }
    }
    if (VL_UNLIKELY(vlTOPp->TensorDotProductUnit_tb__DOT__io_out_valid)) {
        VL_WRITEF("Output (hex): %x\n",32,vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__result);
        if ((0x41600000U != vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__result)) {
            VL_WRITEF("TEST FAILED: Expected 0x41600000\n");
            VL_FINISH_MT("TensorDotProductUnit_tb_new.sv", 69, "");
        } else {
            VL_WRITEF("TEST PASSED\n");
            VL_FINISH_MT("TensorDotProductUnit_tb_new.sv", 72, "");
        }
    }
    vlTOPp->TensorDotProductUnit_tb__DOT__cycle = 0xdU;
    vlTOPp->TensorDotProductUnit_tb__DOT__clock = 1U;
    if (VL_UNLIKELY(vlTOPp->TensorDotProductUnit_tb__DOT__io_out_valid)) {
        VL_WRITEF("Output (hex): %x\n",32,vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__result);
        if ((0x41600000U != vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__result)) {
            VL_WRITEF("TEST FAILED: Expected 0x41600000\n");
            VL_FINISH_MT("TensorDotProductUnit_tb_new.sv", 69, "");
        } else {
            VL_WRITEF("TEST PASSED\n");
            VL_FINISH_MT("TensorDotProductUnit_tb_new.sv", 72, "");
        }
    }
    VL_WRITEF("No valid output after 10 cycles.\n");
    VL_FINISH_MT("TensorDotProductUnit_tb_new.sv", 78, "");
}

void VTensorDotProductUnit_tb::_eval(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTensorDotProductUnit_tb::_eval\n"); );
    VTensorDotProductUnit_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    if ((((IData)(vlTOPp->__VinpClk__TOP__TensorDotProductUnit_tb__DOT__clock) 
          & (~ (IData)(vlTOPp->__Vclklast__TOP____VinpClk__TOP__TensorDotProductUnit_tb__DOT__clock))) 
         | ((IData)(vlTOPp->__VinpClk__TOP__TensorDotProductUnit_tb__DOT__reset) 
            & (~ (IData)(vlTOPp->__Vclklast__TOP____VinpClk__TOP__TensorDotProductUnit_tb__DOT__reset))))) {
        vlTOPp->_sequent__TOP__2(vlSymsp);
        vlTOPp->__Vm_traceActivity = (2U | vlTOPp->__Vm_traceActivity);
    }
    // Final
    vlTOPp->__Vclklast__TOP____VinpClk__TOP__TensorDotProductUnit_tb__DOT__clock 
        = vlTOPp->__VinpClk__TOP__TensorDotProductUnit_tb__DOT__clock;
    vlTOPp->__Vclklast__TOP____VinpClk__TOP__TensorDotProductUnit_tb__DOT__reset 
        = vlTOPp->__VinpClk__TOP__TensorDotProductUnit_tb__DOT__reset;
    vlTOPp->__VinpClk__TOP__TensorDotProductUnit_tb__DOT__clock 
        = vlTOPp->TensorDotProductUnit_tb__DOT__clock;
    vlTOPp->__VinpClk__TOP__TensorDotProductUnit_tb__DOT__reset 
        = vlTOPp->TensorDotProductUnit_tb__DOT__reset;
}

void VTensorDotProductUnit_tb::_eval_initial(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTensorDotProductUnit_tb::_eval_initial\n"); );
    VTensorDotProductUnit_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->_initial__TOP__1(vlSymsp);
    vlTOPp->__Vm_traceActivity = (1U | vlTOPp->__Vm_traceActivity);
    vlTOPp->__Vclklast__TOP____VinpClk__TOP__TensorDotProductUnit_tb__DOT__clock 
        = vlTOPp->__VinpClk__TOP__TensorDotProductUnit_tb__DOT__clock;
    vlTOPp->__Vclklast__TOP____VinpClk__TOP__TensorDotProductUnit_tb__DOT__reset 
        = vlTOPp->__VinpClk__TOP__TensorDotProductUnit_tb__DOT__reset;
    vlTOPp->_initial__TOP__4(vlSymsp);
}

void VTensorDotProductUnit_tb::final() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTensorDotProductUnit_tb::final\n"); );
    // Variables
    VTensorDotProductUnit_tb__Syms* __restrict vlSymsp = this->__VlSymsp;
    VTensorDotProductUnit_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void VTensorDotProductUnit_tb::_eval_settle(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTensorDotProductUnit_tb::_eval_settle\n"); );
    VTensorDotProductUnit_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->_settle__TOP__3(vlSymsp);
}

VL_INLINE_OPT QData VTensorDotProductUnit_tb::_change_request(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTensorDotProductUnit_tb::_change_request\n"); );
    VTensorDotProductUnit_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    // Change detection
    QData __req = false;  // Logically a bool
    __req |= ((vlTOPp->TensorDotProductUnit_tb__DOT__clock ^ vlTOPp->__Vchglast__TOP__TensorDotProductUnit_tb__DOT__clock)
         | (vlTOPp->TensorDotProductUnit_tb__DOT__reset ^ vlTOPp->__Vchglast__TOP__TensorDotProductUnit_tb__DOT__reset));
    VL_DEBUG_IF( if(__req && ((vlTOPp->TensorDotProductUnit_tb__DOT__clock ^ vlTOPp->__Vchglast__TOP__TensorDotProductUnit_tb__DOT__clock))) VL_DBG_MSGF("        CHANGE: TensorDotProductUnit_tb_new.sv:3: TensorDotProductUnit_tb.clock\n"); );
    VL_DEBUG_IF( if(__req && ((vlTOPp->TensorDotProductUnit_tb__DOT__reset ^ vlTOPp->__Vchglast__TOP__TensorDotProductUnit_tb__DOT__reset))) VL_DBG_MSGF("        CHANGE: TensorDotProductUnit_tb_new.sv:4: TensorDotProductUnit_tb.reset\n"); );
    // Final
    vlTOPp->__Vchglast__TOP__TensorDotProductUnit_tb__DOT__clock 
        = vlTOPp->TensorDotProductUnit_tb__DOT__clock;
    vlTOPp->__Vchglast__TOP__TensorDotProductUnit_tb__DOT__reset 
        = vlTOPp->TensorDotProductUnit_tb__DOT__reset;
    return __req;
}

#ifdef VL_DEBUG
void VTensorDotProductUnit_tb::_eval_debug_assertions() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTensorDotProductUnit_tb::_eval_debug_assertions\n"); );
}
#endif  // VL_DEBUG

void VTensorDotProductUnit_tb::_ctor_var_reset() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTensorDotProductUnit_tb::_ctor_var_reset\n"); );
    // Body
    TensorDotProductUnit_tb__DOT__clock = VL_RAND_RESET_I(1);
    TensorDotProductUnit_tb__DOT__reset = VL_RAND_RESET_I(1);
    TensorDotProductUnit_tb__DOT__io_in_valid = VL_RAND_RESET_I(1);
    TensorDotProductUnit_tb__DOT__io_in_bits_a_0 = VL_RAND_RESET_I(16);
    TensorDotProductUnit_tb__DOT__io_in_bits_a_1 = VL_RAND_RESET_I(16);
    TensorDotProductUnit_tb__DOT__io_in_bits_a_2 = VL_RAND_RESET_I(16);
    TensorDotProductUnit_tb__DOT__io_in_bits_a_3 = VL_RAND_RESET_I(16);
    TensorDotProductUnit_tb__DOT__io_in_bits_b_0 = VL_RAND_RESET_I(16);
    TensorDotProductUnit_tb__DOT__io_in_bits_b_1 = VL_RAND_RESET_I(16);
    TensorDotProductUnit_tb__DOT__io_in_bits_b_2 = VL_RAND_RESET_I(16);
    TensorDotProductUnit_tb__DOT__io_in_bits_b_3 = VL_RAND_RESET_I(16);
    TensorDotProductUnit_tb__DOT__io_in_bits_c = VL_RAND_RESET_I(32);
    TensorDotProductUnit_tb__DOT__io_stall = VL_RAND_RESET_I(1);
    TensorDotProductUnit_tb__DOT__io_out_valid = VL_RAND_RESET_I(1);
    TensorDotProductUnit_tb__DOT__cycle = VL_RAND_RESET_I(32);
    TensorDotProductUnit_tb__DOT__dut__DOT__partial_result_0 = VL_RAND_RESET_I(32);
    TensorDotProductUnit_tb__DOT__dut__DOT__partial_result_1 = VL_RAND_RESET_I(32);
    TensorDotProductUnit_tb__DOT__dut__DOT__sum_ab = VL_RAND_RESET_I(32);
    TensorDotProductUnit_tb__DOT__dut__DOT__result = VL_RAND_RESET_I(32);
    TensorDotProductUnit_tb__DOT__dut__DOT__valid_stage1 = VL_RAND_RESET_I(1);
    TensorDotProductUnit_tb__DOT__dut__DOT__valid_stage2 = VL_RAND_RESET_I(1);
    __VinpClk__TOP__TensorDotProductUnit_tb__DOT__clock = VL_RAND_RESET_I(1);
    __VinpClk__TOP__TensorDotProductUnit_tb__DOT__reset = VL_RAND_RESET_I(1);
    __Vchglast__TOP__TensorDotProductUnit_tb__DOT__clock = VL_RAND_RESET_I(1);
    __Vchglast__TOP__TensorDotProductUnit_tb__DOT__reset = VL_RAND_RESET_I(1);
    __Vm_traceActivity = 0;
}

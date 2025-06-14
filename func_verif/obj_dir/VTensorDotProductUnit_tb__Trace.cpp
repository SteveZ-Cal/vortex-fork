// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "VTensorDotProductUnit_tb__Syms.h"


//======================

void VTensorDotProductUnit_tb::traceChg(VerilatedVcd* vcdp, void* userthis, uint32_t code) {
    // Callback from vcd->dump()
    VTensorDotProductUnit_tb* t = (VTensorDotProductUnit_tb*)userthis;
    VTensorDotProductUnit_tb__Syms* __restrict vlSymsp = t->__VlSymsp;  // Setup global symbol table
    if (vlSymsp->getClearActivity()) {
        t->traceChgThis(vlSymsp, vcdp, code);
    }
}

//======================


void VTensorDotProductUnit_tb::traceChgThis(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    VTensorDotProductUnit_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c = code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
        if (VL_UNLIKELY((1U & vlTOPp->__Vm_traceActivity))) {
            vlTOPp->traceChgThis__2(vlSymsp, vcdp, code);
        }
        if (VL_UNLIKELY((1U & (vlTOPp->__Vm_traceActivity 
                               | (vlTOPp->__Vm_traceActivity 
                                  >> 1U))))) {
            vlTOPp->traceChgThis__3(vlSymsp, vcdp, code);
        }
        if (VL_UNLIKELY((2U & vlTOPp->__Vm_traceActivity))) {
            vlTOPp->traceChgThis__4(vlSymsp, vcdp, code);
        }
    }
    // Final
    vlTOPp->__Vm_traceActivity = 0U;
}

void VTensorDotProductUnit_tb::traceChgThis__2(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    VTensorDotProductUnit_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c = code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
        vcdp->chgBit(c+1,(vlTOPp->TensorDotProductUnit_tb__DOT__clock));
        vcdp->chgBit(c+9,(vlTOPp->TensorDotProductUnit_tb__DOT__reset));
        vcdp->chgBit(c+17,(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_valid));
        vcdp->chgBus(c+25,(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_a_0),16);
        vcdp->chgBus(c+33,(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_a_1),16);
        vcdp->chgBus(c+41,(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_a_2),16);
        vcdp->chgBus(c+49,(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_a_3),16);
        vcdp->chgBus(c+57,(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_b_0),16);
        vcdp->chgBus(c+65,(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_b_1),16);
        vcdp->chgBus(c+73,(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_b_2),16);
        vcdp->chgBus(c+81,(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_b_3),16);
        vcdp->chgBus(c+89,(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_c),32);
        vcdp->chgBit(c+97,(vlTOPp->TensorDotProductUnit_tb__DOT__io_stall));
        vcdp->chgBus(c+105,(vlTOPp->TensorDotProductUnit_tb__DOT__cycle),32);
        vcdp->chgBus(c+113,((((IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_a_1) 
                              << 0x10U) | (IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_a_0))),32);
        vcdp->chgBus(c+121,((((IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_a_3) 
                              << 0x10U) | (IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_a_2))),32);
        vcdp->chgBus(c+129,((((IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_b_1) 
                              << 0x10U) | (IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_b_0))),32);
        vcdp->chgBus(c+137,((((IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_b_3) 
                              << 0x10U) | (IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_b_2))),32);
    }
}

void VTensorDotProductUnit_tb::traceChgThis__3(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    VTensorDotProductUnit_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c = code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
        vcdp->chgBit(c+145,(((IData)(vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__valid_stage2) 
                             & (~ (IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_stall)))));
    }
}

void VTensorDotProductUnit_tb::traceChgThis__4(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    VTensorDotProductUnit_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c = code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
        vcdp->chgBus(c+153,(vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__result),32);
        vcdp->chgBus(c+161,(vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__partial_result_0),32);
        vcdp->chgBus(c+169,(vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__partial_result_1),32);
        vcdp->chgBus(c+177,(vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__sum_ab),32);
        vcdp->chgBit(c+185,(vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__valid_stage1));
        vcdp->chgBit(c+193,(vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__valid_stage2));
    }
}

// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "VTensorDotProductUnit_tb__Syms.h"


//======================

void VTensorDotProductUnit_tb::trace(VerilatedVcdC* tfp, int, int) {
    tfp->spTrace()->addCallback(&VTensorDotProductUnit_tb::traceInit, &VTensorDotProductUnit_tb::traceFull, &VTensorDotProductUnit_tb::traceChg, this);
}
void VTensorDotProductUnit_tb::traceInit(VerilatedVcd* vcdp, void* userthis, uint32_t code) {
    // Callback from vcd->open()
    VTensorDotProductUnit_tb* t = (VTensorDotProductUnit_tb*)userthis;
    VTensorDotProductUnit_tb__Syms* __restrict vlSymsp = t->__VlSymsp;  // Setup global symbol table
    if (!Verilated::calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
                        "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vcdp->scopeEscape(' ');
    t->traceInitThis(vlSymsp, vcdp, code);
    vcdp->scopeEscape('.');
}
void VTensorDotProductUnit_tb::traceFull(VerilatedVcd* vcdp, void* userthis, uint32_t code) {
    // Callback from vcd->dump()
    VTensorDotProductUnit_tb* t = (VTensorDotProductUnit_tb*)userthis;
    VTensorDotProductUnit_tb__Syms* __restrict vlSymsp = t->__VlSymsp;  // Setup global symbol table
    t->traceFullThis(vlSymsp, vcdp, code);
}

//======================


void VTensorDotProductUnit_tb::traceInitThis(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    VTensorDotProductUnit_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c = code;
    if (0 && vcdp && c) {}  // Prevent unused
    vcdp->module(vlSymsp->name());  // Setup signal names
    // Body
    {
        vlTOPp->traceInitThis__1(vlSymsp, vcdp, code);
    }
}

void VTensorDotProductUnit_tb::traceFullThis(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    VTensorDotProductUnit_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c = code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
        vlTOPp->traceFullThis__1(vlSymsp, vcdp, code);
    }
    // Final
    vlTOPp->__Vm_traceActivity = 0U;
}

void VTensorDotProductUnit_tb::traceInitThis__1(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    VTensorDotProductUnit_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c = code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
        vcdp->declBit(c+1,"TensorDotProductUnit_tb clock", false,-1);
        vcdp->declBit(c+9,"TensorDotProductUnit_tb reset", false,-1);
        vcdp->declBit(c+17,"TensorDotProductUnit_tb io_in_valid", false,-1);
        vcdp->declBus(c+25,"TensorDotProductUnit_tb io_in_bits_a_0", false,-1, 15,0);
        vcdp->declBus(c+33,"TensorDotProductUnit_tb io_in_bits_a_1", false,-1, 15,0);
        vcdp->declBus(c+41,"TensorDotProductUnit_tb io_in_bits_a_2", false,-1, 15,0);
        vcdp->declBus(c+49,"TensorDotProductUnit_tb io_in_bits_a_3", false,-1, 15,0);
        vcdp->declBus(c+57,"TensorDotProductUnit_tb io_in_bits_b_0", false,-1, 15,0);
        vcdp->declBus(c+65,"TensorDotProductUnit_tb io_in_bits_b_1", false,-1, 15,0);
        vcdp->declBus(c+73,"TensorDotProductUnit_tb io_in_bits_b_2", false,-1, 15,0);
        vcdp->declBus(c+81,"TensorDotProductUnit_tb io_in_bits_b_3", false,-1, 15,0);
        vcdp->declBus(c+89,"TensorDotProductUnit_tb io_in_bits_c", false,-1, 31,0);
        vcdp->declBit(c+97,"TensorDotProductUnit_tb io_stall", false,-1);
        vcdp->declBit(c+145,"TensorDotProductUnit_tb io_out_valid", false,-1);
        vcdp->declBus(c+153,"TensorDotProductUnit_tb io_out_bits_data", false,-1, 31,0);
        vcdp->declBus(c+105,"TensorDotProductUnit_tb cycle", false,-1, 31,0);
        vcdp->declBit(c+1,"TensorDotProductUnit_tb dut clock", false,-1);
        vcdp->declBit(c+9,"TensorDotProductUnit_tb dut reset", false,-1);
        vcdp->declBit(c+17,"TensorDotProductUnit_tb dut io_in_valid", false,-1);
        vcdp->declBus(c+25,"TensorDotProductUnit_tb dut io_in_bits_a_0", false,-1, 15,0);
        vcdp->declBus(c+33,"TensorDotProductUnit_tb dut io_in_bits_a_1", false,-1, 15,0);
        vcdp->declBus(c+41,"TensorDotProductUnit_tb dut io_in_bits_a_2", false,-1, 15,0);
        vcdp->declBus(c+49,"TensorDotProductUnit_tb dut io_in_bits_a_3", false,-1, 15,0);
        vcdp->declBus(c+57,"TensorDotProductUnit_tb dut io_in_bits_b_0", false,-1, 15,0);
        vcdp->declBus(c+65,"TensorDotProductUnit_tb dut io_in_bits_b_1", false,-1, 15,0);
        vcdp->declBus(c+73,"TensorDotProductUnit_tb dut io_in_bits_b_2", false,-1, 15,0);
        vcdp->declBus(c+81,"TensorDotProductUnit_tb dut io_in_bits_b_3", false,-1, 15,0);
        vcdp->declBus(c+89,"TensorDotProductUnit_tb dut io_in_bits_c", false,-1, 31,0);
        vcdp->declBit(c+97,"TensorDotProductUnit_tb dut io_stall", false,-1);
        vcdp->declBit(c+145,"TensorDotProductUnit_tb dut io_out_valid", false,-1);
        vcdp->declBus(c+153,"TensorDotProductUnit_tb dut io_out_bits_data", false,-1, 31,0);
        vcdp->declBus(c+161,"TensorDotProductUnit_tb dut partial_result_0", false,-1, 31,0);
        vcdp->declBus(c+169,"TensorDotProductUnit_tb dut partial_result_1", false,-1, 31,0);
        vcdp->declBus(c+177,"TensorDotProductUnit_tb dut sum_ab", false,-1, 31,0);
        vcdp->declBus(c+153,"TensorDotProductUnit_tb dut result", false,-1, 31,0);
        vcdp->declBit(c+185,"TensorDotProductUnit_tb dut valid_stage1", false,-1);
        vcdp->declBit(c+193,"TensorDotProductUnit_tb dut valid_stage2", false,-1);
        vcdp->declBus(c+113,"TensorDotProductUnit_tb dut a0_fp32", false,-1, 31,0);
        vcdp->declBus(c+121,"TensorDotProductUnit_tb dut a1_fp32", false,-1, 31,0);
        vcdp->declBus(c+129,"TensorDotProductUnit_tb dut b0_fp32", false,-1, 31,0);
        vcdp->declBus(c+137,"TensorDotProductUnit_tb dut b1_fp32", false,-1, 31,0);
    }
}

void VTensorDotProductUnit_tb::traceFullThis__1(VTensorDotProductUnit_tb__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    VTensorDotProductUnit_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c = code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
        vcdp->fullBit(c+1,(vlTOPp->TensorDotProductUnit_tb__DOT__clock));
        vcdp->fullBit(c+9,(vlTOPp->TensorDotProductUnit_tb__DOT__reset));
        vcdp->fullBit(c+17,(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_valid));
        vcdp->fullBus(c+25,(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_a_0),16);
        vcdp->fullBus(c+33,(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_a_1),16);
        vcdp->fullBus(c+41,(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_a_2),16);
        vcdp->fullBus(c+49,(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_a_3),16);
        vcdp->fullBus(c+57,(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_b_0),16);
        vcdp->fullBus(c+65,(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_b_1),16);
        vcdp->fullBus(c+73,(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_b_2),16);
        vcdp->fullBus(c+81,(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_b_3),16);
        vcdp->fullBus(c+89,(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_c),32);
        vcdp->fullBit(c+97,(vlTOPp->TensorDotProductUnit_tb__DOT__io_stall));
        vcdp->fullBus(c+105,(vlTOPp->TensorDotProductUnit_tb__DOT__cycle),32);
        vcdp->fullBus(c+113,((((IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_a_1) 
                               << 0x10U) | (IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_a_0))),32);
        vcdp->fullBus(c+121,((((IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_a_3) 
                               << 0x10U) | (IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_a_2))),32);
        vcdp->fullBus(c+129,((((IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_b_1) 
                               << 0x10U) | (IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_b_0))),32);
        vcdp->fullBus(c+137,((((IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_b_3) 
                               << 0x10U) | (IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_in_bits_b_2))),32);
        vcdp->fullBit(c+145,(((IData)(vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__valid_stage2) 
                              & (~ (IData)(vlTOPp->TensorDotProductUnit_tb__DOT__io_stall)))));
        vcdp->fullBus(c+153,(vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__result),32);
        vcdp->fullBus(c+161,(vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__partial_result_0),32);
        vcdp->fullBus(c+169,(vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__partial_result_1),32);
        vcdp->fullBus(c+177,(vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__sum_ab),32);
        vcdp->fullBit(c+185,(vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__valid_stage1));
        vcdp->fullBit(c+193,(vlTOPp->TensorDotProductUnit_tb__DOT__dut__DOT__valid_stage2));
    }
}

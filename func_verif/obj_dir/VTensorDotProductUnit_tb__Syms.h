// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef _VTENSORDOTPRODUCTUNIT_TB__SYMS_H_
#define _VTENSORDOTPRODUCTUNIT_TB__SYMS_H_  // guard

#include "verilated_heavy.h"

// INCLUDE MODULE CLASSES
#include "VTensorDotProductUnit_tb.h"

// SYMS CLASS
class VTensorDotProductUnit_tb__Syms : public VerilatedSyms {
  public:
    
    // LOCAL STATE
    const char* __Vm_namep;
    bool __Vm_activity;  ///< Used by trace routines to determine change occurred
    bool __Vm_didInit;
    
    // SUBCELL STATE
    VTensorDotProductUnit_tb*      TOPp;
    
    // CREATORS
    VTensorDotProductUnit_tb__Syms(VTensorDotProductUnit_tb* topp, const char* namep);
    ~VTensorDotProductUnit_tb__Syms() {}
    
    // METHODS
    inline const char* name() { return __Vm_namep; }
    inline bool getClearActivity() { bool r=__Vm_activity; __Vm_activity=false; return r; }
    
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);

#endif  // guard

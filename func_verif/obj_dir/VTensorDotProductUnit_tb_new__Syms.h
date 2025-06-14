// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef _VTENSORDOTPRODUCTUNIT_TB_NEW__SYMS_H_
#define _VTENSORDOTPRODUCTUNIT_TB_NEW__SYMS_H_  // guard

#include "verilated_heavy.h"

// INCLUDE MODULE CLASSES
#include "VTensorDotProductUnit_tb_new.h"

// SYMS CLASS
class VTensorDotProductUnit_tb_new__Syms : public VerilatedSyms {
  public:
    
    // LOCAL STATE
    const char* __Vm_namep;
    bool __Vm_activity;  ///< Used by trace routines to determine change occurred
    bool __Vm_didInit;
    
    // SUBCELL STATE
    VTensorDotProductUnit_tb_new*  TOPp;
    
    // CREATORS
    VTensorDotProductUnit_tb_new__Syms(VTensorDotProductUnit_tb_new* topp, const char* namep);
    ~VTensorDotProductUnit_tb_new__Syms() {}
    
    // METHODS
    inline const char* name() { return __Vm_namep; }
    inline bool getClearActivity() { bool r=__Vm_activity; __Vm_activity=false; return r; }
    
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);

#endif  // guard

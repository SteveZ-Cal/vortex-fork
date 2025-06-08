#include "common.h"
#include <vx_print.h>
#include <vx_spawn.h>

#define RISCV_CUSTOM2 0x5B

#define M 16
#define N 16
#define K 16

// Assume 16 x 16 x 16 tile and 32 threads
// Registers [00-07] store A
// Registers [08-15] store B
// Registers [16-23] store C
// Registers [24-31] store D
// Thread i => row=i/2, cols=[8 * i%2, 8 * i%2 + 8)
// [    thread0    ][    thread1    ]
// [    thread2    ][    thread3    ]
// [    thread4    ][    thread5    ]
//        ...              ...
// [    thread30   ][    thread31   ]

void vx_load_A(const volatile TYPE *addr, int tid) {
  int offset = tid * 8;
  __asm__ volatile ("flw f0, %0" :: "m"(addr[offset + 0]) : "f0");
  __asm__ volatile ("flw f1, %0" :: "m"(addr[offset + 1]) : "f1");
  __asm__ volatile ("flw f2, %0" :: "m"(addr[offset + 2]) : "f2");
  __asm__ volatile ("flw f3, %0" :: "m"(addr[offset + 3]) : "f3");
  __asm__ volatile ("flw f4, %0" :: "m"(addr[offset + 4]) : "f4");
  __asm__ volatile ("flw f5, %0" :: "m"(addr[offset + 5]) : "f5");
  __asm__ volatile ("flw f6, %0" :: "m"(addr[offset + 6]) : "f6");
  __asm__ volatile ("flw f7, %0" :: "m"(addr[offset + 7]) : "f7");
}

void vx_load_B(const volatile TYPE *addr, int tid) {
  int offset = tid * 8;
  __asm__ volatile ("flw f8, %0" :: "m"(addr[offset + 0]) : "f8");
  __asm__ volatile ("flw f9, %0" :: "m"(addr[offset + 1]) : "f9");
  __asm__ volatile ("flw f10, %0" :: "m"(addr[offset + 2]) : "f10");
  __asm__ volatile ("flw f11, %0" :: "m"(addr[offset + 3]) : "f11");
  __asm__ volatile ("flw f12, %0" :: "m"(addr[offset + 4]) : "f12");
  __asm__ volatile ("flw f13, %0" :: "m"(addr[offset + 5]) : "f13");
  __asm__ volatile ("flw f14, %0" :: "m"(addr[offset + 6]) : "f14");
  __asm__ volatile ("flw f15, %0" :: "m"(addr[offset + 7]) : "f15");
}

void vx_load_C(const volatile TYPE *addr, int tid) {
  int offset = tid * 8;
  __asm__ volatile ("flw f16, %0" :: "m"(addr[offset + 0]) : "f16");
  __asm__ volatile ("flw f17, %0" :: "m"(addr[offset + 1]) : "f17");
  __asm__ volatile ("flw f18, %0" :: "m"(addr[offset + 2]) : "f18");
  __asm__ volatile ("flw f19, %0" :: "m"(addr[offset + 3]) : "f19");
  __asm__ volatile ("flw f20, %0" :: "m"(addr[offset + 4]) : "f20");
  __asm__ volatile ("flw f21, %0" :: "m"(addr[offset + 5]) : "f21");
  __asm__ volatile ("flw f22, %0" :: "m"(addr[offset + 6]) : "f22");
  __asm__ volatile ("flw f23, %0" :: "m"(addr[offset + 7]) : "f23");
}

void vx_wmma() {
  __asm__ volatile (".insn r %0, 0, 0, x0, x0, x0" :: "i"(RISCV_CUSTOM2)
    : "f0",  "f1",  "f2",  "f3",  "f4",  "f5",  "f6",  "f7",
      "f8",  "f9",  "f10", "f11", "f12", "f13", "f14", "f15",
      "f16", "f17", "f18", "f19", "f20", "f21", "f22", "f23",
      "f24", "f25", "f26", "f27", "f28", "f29", "f30", "f31"
  );
}

void vx_store_D(volatile TYPE *addr, int tid) {
  int offset = tid * 8;
  __asm__ volatile ("fsw f24, %0" :: "m"(addr[offset + 0]) : "f24");
  __asm__ volatile ("fsw f25, %0" :: "m"(addr[offset + 1]) : "f25");
  __asm__ volatile ("fsw f26, %0" :: "m"(addr[offset + 2]) : "f26");
  __asm__ volatile ("fsw f27, %0" :: "m"(addr[offset + 3]) : "f27");
  __asm__ volatile ("fsw f28, %0" :: "m"(addr[offset + 4]) : "f28");
  __asm__ volatile ("fsw f29, %0" :: "m"(addr[offset + 5]) : "f29");
  __asm__ volatile ("fsw f30, %0" :: "m"(addr[offset + 6]) : "f30");
  __asm__ volatile ("fsw f31, %0" :: "m"(addr[offset + 7]) : "f31");
}


void kernel_body(kernel_arg_t *__UNIFORM__ arg) {
  auto A = reinterpret_cast<TYPE *>(arg->A_addr);
  auto B = reinterpret_cast<TYPE *>(arg->B_addr);
  auto C = reinterpret_cast<TYPE *>(arg->C_addr);

  // Initialize C to zeroes
  for (int i = 0; i < M*N; i++) {
    C[i] = 0.0;
  }

  vx_load_A(A, threadIdx.x);
  vx_load_B(B, threadIdx.x);
  vx_load_C(C, threadIdx.x);

  vx_wmma();

  vx_store_D(C, threadIdx.x); // we store back into C
}

int main() {
  kernel_arg_t *arg = (kernel_arg_t *)csr_read(VX_CSR_MSCRATCH);
  return vx_spawn_threads(2, arg->grid_dim, arg->block_dim, (vx_kernel_func_cb)kernel_body, arg);
}

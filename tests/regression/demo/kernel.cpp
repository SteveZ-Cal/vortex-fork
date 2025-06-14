#include <vx_spawn.h>
#include "common.h"

void kernel_body(kernel_arg_t* __UNIFORM__ arg) {
	auto src0_ptr = reinterpret_cast<TYPE*>(arg->src0_addr);
	auto src1_ptr = reinterpret_cast<TYPE*>(arg->src1_addr);
	auto dst_ptr = reinterpret_cast<TYPE*>(arg->dst_addr);

	uint32_t count = arg->task_size;
	uint32_t offset = blockIdx.x * count;

	for (uint32_t i = 0; i < count; ++i) {
		dst_ptr[offset+i] = src0_ptr[offset+i] + src1_ptr[offset+i];
	}
}

int main() {
	asm volatile (".insn r %0, 0, 0, x0, x0, x0" :: "i"(RISCV_CUSTOM3));
// D.data = vx_hmma_844_c_f16_f32(A.data, B.data, C.data);
// directly call the mma instruction (for running the instuction through) 
//	kernel_arg_t* arg = (kernel_arg_t*)csr_read(VX_CSR_MSCRATCH);
//	return vx_spawn_threads(1, &arg->num_tasks, nullptr, (vx_kernel_func_cb)kernel_body, arg);
}

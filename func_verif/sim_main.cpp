#include "VTensorDotProductUnit_tb_new.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);

    VTensorDotProductUnit_tb* tb = new VTensorDotProductUnit_tb;

    // Enable waveform tracing
    VerilatedVcdC* tfp = nullptr;
    bool trace = true;
    if (trace) {
        Verilated::traceEverOn(true);
        tfp = new VerilatedVcdC;
        tb->trace(tfp, 99);
        tfp->open("wave.vcd");
    }

    // Initialize clock and reset signals
    tb->clock = 0;
    tb->reset = 1;

    int main_time = 0;  // simulation time in cycles
    const int max_cycles = 50;

    while (!Verilated::gotFinish() && main_time < max_cycles) {
        // Toggle clock every half cycle
        tb->clock = !tb->clock;

        // At rising edge, eval the DUT
        if (tb->clock) {
            tb->eval();

            // Release reset after a few cycles
            if (main_time > 2) {
                tb->reset = 0;
            }
        } else {
            tb->eval();
        }

        if (trace) {
            tfp->dump(main_time);
        }

        main_time++;

        // Optional: slow down simulation for debug
        // std::this_thread::sleep_for(std::chrono::milliseconds(10));
    }

    // Final model cleanup
    tb->final();

    if (trace) {
        tfp->close();
        delete tfp;
    }
    delete tb;

    return 0;
}


// Copyright © 2019-2023
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include "tensor_unit.h"
#include "core.h"

using namespace vortex;

class TensorUnit::Impl {
public:
  Impl(TensorUnit* simobject, const Arch& arch, Core* core)
    : simobject_(simobject)
    , core_(core)
    , arch_(arch)
    , perf_stats_()
  {
    //--
  }

  ~Impl() {
    // Destructor logic if needed
  }

  void reset() {
    perf_stats_ = PerfStats();
  }

  void tick() {
    for (uint32_t iw = 0; iw < ISSUE_WIDTH; ++iw) {
      auto& input = simobject_->Inputs.at(iw);
      if (input.empty())
          return;
      auto trace = input.front();
      int delay = 0;
      switch (trace->tpu_type) {
      case TpuType::HMMA844:
        delay = 4;
        break;
      default:
        std::abort();
      }
      simobject_->Outputs.at(iw).push(trace, 2 + delay);
      DT(3, simobject_->name() << ": op=" << trace->tpu_type << ", " << *trace);
      input.pop();
    }
  }

  void hmma844(uint32_t wid,
               uint32_t fmt, uint32_t step,
               const std::vector<reg_data_t>& rs1_data,
               const std::vector<reg_data_t>& rs2_data,
               const std::vector<reg_data_t>& rs3_data,
               std::vector<reg_data_t>& rd_data,
               ExeTraceData* trace_data) {
    uint32_t num_octects = arch_.num_threads() / 8;
    uint32_t threadgroup_lane_offset = 4 * num_octects;
    float subA[8][4] , acc[8][4], subB[4][4];
    for (uint32_t i = 0; i < num_octects; ++i) {
      std::vector<reg_data_t> octet_A(8);
      std::vector<reg_data_t> octet_B(8);
      std::vector<reg_data_t> octet_C(8);
      std::vector<reg_data_t> octet_D(8);

      for (uint32_t j = 0; j < 8; ++j) {
        octet_A[j] = rs1_data[i * 8 + j];
        octet_B[j] = rs2_data[i * 8 + j];
        octet_C[j] = rs3_data[i * 8 + j];
        octet_D[j] = rd_data[i * 8 + j];
      }
    }

    for (uint32_t i = 0; i < 8; ++i) {
        for (uint32_t j = 0; j < 4; ++j) {
            acc[i][j] = rs3_data[i * 4 + j];
        }
    }

    // Process each octet (thread group)
    for (uint32_t octet = 0; octet < num_octects; ++octet) {
        // Load octet-specific portions of A and B
        for (uint32_t j = 0; j < 8; ++j) {
            // Load 2 rows (8 elements) of A per octet (4 columns)
            uint32_t row = octet * 2 + (j / 4);
            uint32_t col = j % 4;
            subA[row][col] = rs1_data[octet * 8 + j];
            
            // Load 2 rows (8 elements) of B per octet (4 columns)
            if (j < 4) {
                subB[j/2][j%2 + (octet%2)*2] = rs2_data[octet * 4 + j];
            }
        }

        for (uint32_t i = 0; i < 2; ++i) {          // 2 rows processed per octet
            uint32_t row = octet * 2 + i;
            for (uint32_t j = 0; j < 4; ++j) {       // All columns
                for (uint32_t k = 0; k < 4; ++k) {   // Dot product
                    acc[row][j] += subA[row][k] * subB[k][j];
                }
            }
        }
    }

    rd_data.resize(8 * 4);
    for (uint32_t i = 0; i < 8; ++i) {
        for (uint32_t j = 0; j < 4; ++j) {
            rd_data[i * 4 + j] = acc[i][j];
        }
    }

  }

  const PerfStats& perf_stats() const {
    return perf_stats_;
  }

private:
  TensorUnit*   simobject_;
  Core*         core_;
  Arch          arch_;
  PerfStats     perf_stats_;
};

///////////////////////////////////////////////////////////////////////////////

TensorUnit::TensorUnit(const SimContext &ctx, const char* name, const Arch& arch, Core* core)
	: SimObject<TensorUnit>(ctx, name)
	, Inputs(ISSUE_WIDTH, this)
	, Outputs(ISSUE_WIDTH, this)
	, impl_(new Impl(this, arch, core))
{}

TensorUnit::~TensorUnit() {
  delete impl_;
}

void TensorUnit::reset() {
  impl_->reset();
}

void TensorUnit::tick() {
  impl_->tick();
}

const TensorUnit::PerfStats &TensorUnit::perf_stats() const {
	return impl_->perf_stats();
}

void TensorUnit::hmma844(uint32_t wid,
                         uint32_t fmt, uint32_t step,
                         const std::vector<reg_data_t>& rs1_data,
                         const std::vector<reg_data_t>& rs2_data,
                         const std::vector<reg_data_t>& rs3_data,
                         std::vector<reg_data_t>& rd_data,
                         ExeTraceData* trace_data) {
  impl_->hmma844(wid, fmt, step, rs1_data, rs2_data, rs3_data, rd_data, trace_data);
}
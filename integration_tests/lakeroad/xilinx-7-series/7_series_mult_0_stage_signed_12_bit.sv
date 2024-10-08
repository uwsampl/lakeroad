// RUN: outfile=$(mktemp)
// RUN: racket $LAKEROAD_DIR/bin/main.rkt \
// RUN:  --solver stp \
// RUN:  --verilog-module-filepath %s \
// RUN:  --architecture xilinx-7-series \
// RUN:  --template dsp \
// RUN:  --out-format verilog \
// RUN:  --top-module-name top \
// RUN:  --verilog-module-out-signal out:12 \
// RUN:  --pipeline-depth 0 \
// RUN:  --module-name out \
// RUN:  --input-signal 'a:(port a 12):12' \
// RUN:  --input-signal 'b:(port b 12):12' \
// RUN:  --timeout 120 \
// RUN:  --extra-cycles 3 \
// RUN:  > $outfile
// RUN: FileCheck %s < $outfile
// RUN: if [ -z ${LAKEROAD_PRIVATE_DIR+x} ]; then \
// RUN:   echo "Warning: LAKEROAD_PRIVATE_DIR is not set. Skipping simulation."; \
// RUN:   exit 0; \
// RUN: else \
// RUN:   python3 $LAKEROAD_DIR/bin/simulate_with_verilator.py \
// RUN:    --test_module_name out \
// RUN:    --ground_truth_module_name top \
// RUN:    --max_num_tests=10000 \
// RUN:    --verilog_filepath $outfile \
// RUN:    --verilog_filepath %s \
// RUN:    --pipeline_depth 0 \
// RUN:    --output_signal out:12 \
// RUN:    --input_signal a:12 \
// RUN:    --input_signal b:12 \ 
// RUN:    --verilator_include_dir "$LAKEROAD_PRIVATE_DIR/DSP48E1/" \
// RUN:    --verilator_extra_arg='-DXIL_XECLIB' \
// RUN:    --verilator_extra_arg='-Wno-UNOPTFLAT' \
// RUN:    --verilator_extra_arg='-Wno-LATCH' \
// RUN:    --verilator_extra_arg='-Wno-WIDTH' \
// RUN:    --verilator_extra_arg='-Wno-STMTDLY' \
// RUN:    --verilator_extra_arg='-Wno-CASEX' \
// RUN:    --verilator_extra_arg='-Wno-TIMESCALEMOD' \
// RUN:    --verilator_extra_arg='-Wno-PINMISSING' \
// RUN:    --verilator_extra_arg='-Wno-COMBDLY' \
// RUN: 	 --verilator_extra_arg='-Wno-INITIALDLY' \
// RUN: 	 --verilator_extra_arg='-Wno-CASEINCOMPLETE'; \
// RUN: fi

(* use_dsp = "yes" *) module top(
	input signed [11:0] a,
	input signed [11:0] b,
	output [11:0] out
	);

	assign out = a * b;
endmodule

// CHECK: module out(a, b, out);
// CHECK:   DSP48E1 #(
// CHECK: endmodule

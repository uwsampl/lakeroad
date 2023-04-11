#lang rosette/safe

(require racket/base
         racket/match
         rackunit
         "generated/intel-altmult-accum.rkt"
         "signal.rkt"
         rosette/solver/smt/boolector
         rosette/lib/synthax)

(current-solver (boolector))

(define current-index (make-parameter 0))
(define (index!)
  (define idx (current-index))
  (current-index (add1 idx))
  idx)

(define (run
         state
         #:accum_direction [accum_direction (constant (list 'accum_direction (index!)) (bitvector 5))]
         #:accum_round [accum_round (constant (list 'accum_round (index!)) (bitvector 1))]
         #:accum_round_aclr
         [accum_round_aclr (constant (list 'accum_round_aclr (index!)) (bitvector 5))]
         #:accum_round_pipeline_aclr
         [accum_round_pipeline_aclr
          (constant (list 'accum_round_pipeline_aclr (index!)) (bitvector 5))]
         #:accum_round_pipeline_reg
         [accum_round_pipeline_reg (constant (list 'accum_round_pipeline_reg (index!)) (bitvector 5))]
         #:accum_round_reg [accum_round_reg (constant (list 'accum_round_reg (index!)) (bitvector 5))]
         #:accum_saturation
         [accum_saturation (constant (list 'accum_saturation (index!)) (bitvector 1))]
         #:accum_saturation_aclr
         [accum_saturation_aclr (constant (list 'accum_saturation_aclr (index!)) (bitvector 5))]
         #:accum_saturation_pipeline_aclr
         [accum_saturation_pipeline_aclr
          (constant (list 'accum_saturation_pipeline_aclr (index!)) (bitvector 5))]
         #:accum_saturation_pipeline_reg
         [accum_saturation_pipeline_reg
          (constant (list 'accum_saturation_pipeline_reg (index!)) (bitvector 5))]
         #:accum_saturation_reg
         [accum_saturation_reg (constant (list 'accum_saturation_reg (index!)) (bitvector 5))]
         #:accum_sload [accum_sload (constant (list 'accum_sload (index!)) (bitvector 1))]
         #:accum_sload_aclr
         [accum_sload_aclr (constant (list 'accum_sload_aclr (index!)) (bitvector 5))]
         #:accum_sload_pipeline_aclr
         [accum_sload_pipeline_aclr
          (constant (list 'accum_sload_pipeline_aclr (index!)) (bitvector 5))]
         #:accum_sload_pipeline_reg
         [accum_sload_pipeline_reg (constant (list 'accum_sload_pipeline_reg (index!)) (bitvector 5))]
         #:accum_sload_reg [accum_sload_reg (constant (list 'accum_sload_reg (index!)) (bitvector 5))]
         #:accum_sload_upper_data
         [accum_sload_upper_data (constant (list 'accum_sload_upper_data (index!)) (bitvector 1))]
         #:accum_sload_upper_data_aclr
         [accum_sload_upper_data_aclr
          (constant (list 'accum_sload_upper_data_aclr (index!)) (bitvector 5))]
         #:accum_sload_upper_data_pipeline_aclr
         [accum_sload_upper_data_pipeline_aclr
          (constant (list 'accum_sload_upper_data_pipeline_aclr (index!)) (bitvector 5))]
         #:accum_sload_upper_data_pipeline_reg
         [accum_sload_upper_data_pipeline_reg
          (constant (list 'accum_sload_upper_data_pipeline_reg (index!)) (bitvector 5))]
         #:accum_sload_upper_data_reg
         [accum_sload_upper_data_reg
          (constant (list 'accum_sload_upper_data_reg (index!)) (bitvector 5))]
         #:aclr0 [aclr0 (constant (list 'aclr0 (index!)) (bitvector 1))]
         #:aclr1 [aclr1 (constant (list 'aclr1 (index!)) (bitvector 1))]
         #:aclr2 [aclr2 (constant (list 'aclr2 (index!)) (bitvector 1))]
         #:aclr3 [aclr3 (constant (list 'aclr3 (index!)) (bitvector 1))]
         #:addnsub [addnsub (constant (list 'addnsub (index!)) (bitvector 1))]
         #:addnsub_aclr [addnsub_aclr (constant (list 'addnsub_aclr (index!)) (bitvector 5))]
         #:addnsub_pipeline_aclr
         [addnsub_pipeline_aclr (constant (list 'addnsub_pipeline_aclr (index!)) (bitvector 5))]
         #:addnsub_pipeline_reg
         [addnsub_pipeline_reg (constant (list 'addnsub_pipeline_reg (index!)) (bitvector 5))]
         #:addnsub_reg [addnsub_reg (constant (list 'addnsub_reg (index!)) (bitvector 5))]
         #:clock0 [clock0 (constant (list 'clock0 (index!)) (bitvector 1))]
         #:clock1 [clock1 (constant (list 'clock1 (index!)) (bitvector 1))]
         #:clock2 [clock2 (constant (list 'clock2 (index!)) (bitvector 1))]
         #:clock3 [clock3 (constant (list 'clock3 (index!)) (bitvector 1))]
         #:coefsel0 [coefsel0 (constant (list 'coefsel0 (index!)) (bitvector 3))]
         #:coefsel1 [coefsel1 (constant (list 'coefsel1 (index!)) (bitvector 3))]
         #:coefsel2 [coefsel2 (constant (list 'coefsel2 (index!)) (bitvector 3))]
         #:coefsel3 [coefsel3 (constant (list 'coefsel3 (index!)) (bitvector 3))]
         #:dataa [dataa (constant (list 'dataa (index!)) (bitvector 18))]
         #:datab [datab (constant (list 'datab (index!)) (bitvector 18))]
         #:datac [datac (constant (list 'datac (index!)) (bitvector 22))]
         #:dedicated_multiplier_circuitry
         [dedicated_multiplier_circuitry
          (constant (list 'dedicated_multiplier_circuitry (index!)) (bitvector 5))]
         #:dsp_block_balancing
         [dsp_block_balancing (constant (list 'dsp_block_balancing (index!)) (bitvector 5))]
         #:ena0 [ena0 (constant (list 'ena0 (index!)) (bitvector 1))]
         #:ena1 [ena1 (constant (list 'ena1 (index!)) (bitvector 1))]
         #:ena2 [ena2 (constant (list 'ena2 (index!)) (bitvector 1))]
         #:ena3 [ena3 (constant (list 'ena3 (index!)) (bitvector 1))]
         #:input_aclr_a [input_aclr_a (constant (list 'input_aclr_a (index!)) (bitvector 5))]
         #:input_aclr_b [input_aclr_b (constant (list 'input_aclr_b (index!)) (bitvector 5))]
         #:input_reg_a [input_reg_a (constant (list 'input_reg_a (index!)) (bitvector 5))]
         #:input_reg_b [input_reg_b (constant (list 'input_reg_b (index!)) (bitvector 5))]
         #:input_source_a [input_source_a (constant (list 'input_source_a (index!)) (bitvector 5))]
         #:input_source_b [input_source_b (constant (list 'input_source_b (index!)) (bitvector 5))]
         #:intended_device_family
         [intended_device_family (constant (list 'intended_device_family (index!)) (bitvector 5))]
         #:lpm_hint [lpm_hint (constant (list 'lpm_hint (index!)) (bitvector 5))]
         #:lpm_type [lpm_type (constant (list 'lpm_type (index!)) (bitvector 5))]
         #:mult_round [mult_round (constant (list 'mult_round (index!)) (bitvector 1))]
         #:mult_round_aclr [mult_round_aclr (constant (list 'mult_round_aclr (index!)) (bitvector 5))]
         #:mult_round_reg [mult_round_reg (constant (list 'mult_round_reg (index!)) (bitvector 5))]
         #:mult_saturation [mult_saturation (constant (list 'mult_saturation (index!)) (bitvector 1))]
         #:mult_saturation_aclr
         [mult_saturation_aclr (constant (list 'mult_saturation_aclr (index!)) (bitvector 5))]
         #:mult_saturation_reg
         [mult_saturation_reg (constant (list 'mult_saturation_reg (index!)) (bitvector 5))]
         #:multiplier1_direction
         [multiplier1_direction (constant (list 'multiplier1_direction (index!)) (bitvector 5))]
         #:multiplier3_direction
         [multiplier3_direction (constant (list 'multiplier3_direction (index!)) (bitvector 5))]
         #:multiplier_aclr [multiplier_aclr (constant (list 'multiplier_aclr (index!)) (bitvector 5))]
         #:multiplier_reg [multiplier_reg (constant (list 'multiplier_reg (index!)) (bitvector 5))]
         #:output_aclr [output_aclr (constant (list 'output_aclr (index!)) (bitvector 5))]
         #:output_reg [output_reg (constant (list 'output_reg (index!)) (bitvector 5))]
         #:port_accum_is_saturated
         [port_accum_is_saturated (constant (list 'port_accum_is_saturated (index!)) (bitvector 1))]
         #:port_addnsub [port_addnsub (constant (list 'port_addnsub (index!)) (bitvector 5))]
         #:port_mult_is_saturated
         [port_mult_is_saturated (constant (list 'port_mult_is_saturated (index!)) (bitvector 1))]
         #:port_signa [port_signa (constant (list 'port_signa (index!)) (bitvector 5))]
         #:port_signb [port_signb (constant (list 'port_signb (index!)) (bitvector 5))]
         #:representation_a
         [representation_a (constant (list 'representation_a (index!)) (bitvector 5))]
         #:representation_b
         [representation_b (constant (list 'representation_b (index!)) (bitvector 5))]
         #:scanina [scanina (constant (list 'scanina (index!)) (bitvector 18))]
         #:scaninb [scaninb (constant (list 'scaninb (index!)) (bitvector 18))]
         #:sign_aclr_a [sign_aclr_a (constant (list 'sign_aclr_a (index!)) (bitvector 5))]
         #:sign_aclr_b [sign_aclr_b (constant (list 'sign_aclr_b (index!)) (bitvector 5))]
         #:sign_pipeline_aclr_a
         [sign_pipeline_aclr_a (constant (list 'sign_pipeline_aclr_a (index!)) (bitvector 5))]
         #:sign_pipeline_aclr_b
         [sign_pipeline_aclr_b (constant (list 'sign_pipeline_aclr_b (index!)) (bitvector 5))]
         #:sign_pipeline_reg_a
         [sign_pipeline_reg_a (constant (list 'sign_pipeline_reg_a (index!)) (bitvector 5))]
         #:sign_pipeline_reg_b
         [sign_pipeline_reg_b (constant (list 'sign_pipeline_reg_b (index!)) (bitvector 5))]
         #:sign_reg_a [sign_reg_a (constant (list 'sign_reg_a (index!)) (bitvector 5))]
         #:sign_reg_b [sign_reg_b (constant (list 'sign_reg_b (index!)) (bitvector 5))]
         #:signa [signa (constant (list 'signa (index!)) (bitvector 1))]
         #:signb [signb (constant (list 'signb (index!)) (bitvector 1))]
         #:sourcea [sourcea (constant (list 'sourcea (index!)) (bitvector 1))]
         #:sourceb [sourceb (constant (list 'sourceb (index!)) (bitvector 1))]
         #:unnamed-input-400
         [unnamed-input-400 (constant (list 'unnamed-input-400 (index!)) (bitvector 1))]
         #:unnamed-input-402
         [unnamed-input-402 (constant (list 'unnamed-input-402 (index!)) (bitvector 1))]
         #:unnamed-input-484
         [unnamed-input-484 (constant (list 'unnamed-input-484 (index!)) (bitvector 36))]
         #:unnamed-input-953
         [unnamed-input-953 (constant (list 'unnamed-input-953 (index!)) (bitvector 35))]
         #:unnamed-input-954
         [unnamed-input-954 (constant (list 'unnamed-input-954 (index!)) (bitvector 35))]
         #:unnamed-input-956
         [unnamed-input-956 (constant (list 'unnamed-input-956 (index!)) (bitvector 35))]
         #:unnamed-input-957
         [unnamed-input-957 (constant (list 'unnamed-input-957 (index!)) (bitvector 35))]
         #:unnamed-input-963
         [unnamed-input-963 (constant (list 'unnamed-input-963 (index!)) (bitvector 35))]
         #:unnamed-input-983
         [unnamed-input-983 (constant (list 'unnamed-input-983 (index!)) (bitvector 35))]
         #:unnamed-input-1023
         [unnamed-input-1023 (constant (list 'unnamed-input-1023 (index!)) (bitvector 1))]
         #:unnamed-input-1024
         [unnamed-input-1024 (constant (list 'unnamed-input-1024 (index!)) (bitvector 1))]
         #:unnamed-input-1034
         [unnamed-input-1034 (constant (list 'unnamed-input-1034 (index!)) (bitvector 1))]
         #:unnamed-input-1038
         [unnamed-input-1038 (constant (list 'unnamed-input-1038 (index!)) (bitvector 1))]
         #:unnamed-input-1046
         [unnamed-input-1046 (constant (list 'unnamed-input-1046 (index!)) (bitvector 1))]
         #:unnamed-input-1053
         [unnamed-input-1053 (constant (list 'unnamed-input-1053 (index!)) (bitvector 1))]
         #:unnamed-input-1054
         [unnamed-input-1054 (constant (list 'unnamed-input-1054 (index!)) (bitvector 1))]
         #:unnamed-input-1057
         [unnamed-input-1057 (constant (list 'unnamed-input-1057 (index!)) (bitvector 1))])

  (assoc-ref (intel-altmult-accum
              #:accum_direction (signal accum_direction state)
              #:accum_round (bv->signal accum_round)
              #:accum_round_aclr (bv->signal accum_round_aclr)
              #:accum_round_pipeline_aclr (bv->signal accum_round_pipeline_aclr)
              #:accum_round_pipeline_reg (bv->signal accum_round_pipeline_reg)
              #:accum_round_reg (bv->signal accum_round_reg)
              #:accum_saturation (bv->signal accum_saturation)
              #:accum_saturation_aclr (bv->signal accum_saturation_aclr)
              #:accum_saturation_pipeline_aclr (bv->signal accum_saturation_pipeline_aclr)
              #:accum_saturation_pipeline_reg (bv->signal accum_saturation_pipeline_reg)
              #:accum_saturation_reg (bv->signal accum_saturation_reg)
              #:accum_sload (bv->signal accum_sload)
              #:accum_sload_aclr (bv->signal accum_sload_aclr)
              #:accum_sload_pipeline_aclr (bv->signal accum_sload_pipeline_aclr)
              #:accum_sload_pipeline_reg (bv->signal accum_sload_pipeline_reg)
              #:accum_sload_reg (bv->signal accum_sload_reg)
              #:accum_sload_upper_data (bv->signal accum_sload_upper_data)
              #:accum_sload_upper_data_aclr (bv->signal accum_sload_upper_data_aclr)
              #:accum_sload_upper_data_pipeline_aclr (bv->signal accum_sload_upper_data_pipeline_aclr)
              #:accum_sload_upper_data_pipeline_reg (bv->signal accum_sload_upper_data_pipeline_reg)
              #:accum_sload_upper_data_reg (bv->signal accum_sload_upper_data_reg)
              #:aclr0 (bv->signal aclr0)
              #:aclr1 (bv->signal aclr1)
              #:aclr2 (bv->signal aclr2)
              #:aclr3 (bv->signal aclr3)
              #:addnsub (bv->signal addnsub)
              #:addnsub_aclr (bv->signal addnsub_aclr)
              #:addnsub_pipeline_aclr (bv->signal addnsub_pipeline_aclr)
              #:addnsub_pipeline_reg (bv->signal addnsub_pipeline_reg)
              #:addnsub_reg (bv->signal addnsub_reg)
              #:clock0 (bv->signal clock0)
              #:clock1 (bv->signal clock1)
              #:clock2 (bv->signal clock2)
              #:clock3 (bv->signal clock3)
              #:coefsel0 (bv->signal coefsel0)
              #:coefsel1 (bv->signal coefsel1)
              #:coefsel2 (bv->signal coefsel2)
              #:coefsel3 (bv->signal coefsel3)
              #:dataa (bv->signal dataa)
              #:datab (bv->signal datab)
              #:datac (bv->signal datac)
              #:dedicated_multiplier_circuitry (bv->signal dedicated_multiplier_circuitry)
              #:dsp_block_balancing (bv->signal dsp_block_balancing)
              #:ena0 (bv->signal ena0)
              #:ena1 (bv->signal ena1)
              #:ena2 (bv->signal ena2)
              #:ena3 (bv->signal ena3)
              #:input_aclr_a (bv->signal input_aclr_a)
              #:input_aclr_b (bv->signal input_aclr_b)
              #:input_reg_a (bv->signal input_reg_a)
              #:input_reg_b (bv->signal input_reg_b)
              #:input_source_a (bv->signal input_source_a)
              #:input_source_b (bv->signal input_source_b)
              #:intended_device_family (bv->signal intended_device_family)
              #:lpm_hint (bv->signal lpm_hint)
              #:lpm_type (bv->signal lpm_type)
              #:mult_round (bv->signal mult_round)
              #:mult_round_aclr (bv->signal mult_round_aclr)
              #:mult_round_reg (bv->signal mult_round_reg)
              #:mult_saturation (bv->signal mult_saturation)
              #:mult_saturation_aclr (bv->signal mult_saturation_aclr)
              #:mult_saturation_reg (bv->signal mult_saturation_reg)
              #:multiplier1_direction (bv->signal multiplier1_direction)
              #:multiplier3_direction (bv->signal multiplier3_direction)
              #:multiplier_aclr (bv->signal multiplier_aclr)
              #:multiplier_reg (bv->signal multiplier_reg)
              #:output_aclr (bv->signal output_aclr)
              #:output_reg (bv->signal output_reg)
              #:port_accum_is_saturated (bv->signal port_accum_is_saturated)
              #:port_addnsub (bv->signal port_addnsub)
              #:port_mult_is_saturated (bv->signal port_mult_is_saturated)
              #:port_signa (bv->signal port_signa)
              #:port_signb (bv->signal port_signb)
              #:representation_a (bv->signal representation_a)
              #:representation_b (bv->signal representation_b)
              #:scanina (bv->signal scanina)
              #:scaninb (bv->signal scaninb)
              #:sign_aclr_a (bv->signal sign_aclr_a)
              #:sign_aclr_b (bv->signal sign_aclr_b)
              #:sign_pipeline_aclr_a (bv->signal sign_pipeline_aclr_a)
              #:sign_pipeline_aclr_b (bv->signal sign_pipeline_aclr_b)
              #:sign_pipeline_reg_a (bv->signal sign_pipeline_reg_a)
              #:sign_pipeline_reg_b (bv->signal sign_pipeline_reg_b)
              #:sign_reg_a (bv->signal sign_reg_a)
              #:sign_reg_b (bv->signal sign_reg_b)
              #:signa (bv->signal signa)
              #:signb (bv->signal signb)
              #:sourcea (bv->signal sourcea)
              #:sourceb (bv->signal sourceb)
              #:unnamed-input-400 (bv->signal unnamed-input-400)
              #:unnamed-input-402 (bv->signal unnamed-input-402)
              #:unnamed-input-484 (bv->signal unnamed-input-484)
              #:unnamed-input-953 (bv->signal unnamed-input-953)
              #:unnamed-input-954 (bv->signal unnamed-input-954)
              #:unnamed-input-956 (bv->signal unnamed-input-956)
              #:unnamed-input-957 (bv->signal unnamed-input-957)
              #:unnamed-input-963 (bv->signal unnamed-input-963)
              #:unnamed-input-983 (bv->signal unnamed-input-983)
              #:unnamed-input-1023 (bv->signal unnamed-input-1023)
              #:unnamed-input-1024 (bv->signal unnamed-input-1024)
              #:unnamed-input-1034 (bv->signal unnamed-input-1034)
              #:unnamed-input-1038 (bv->signal unnamed-input-1038)
              #:unnamed-input-1046 (bv->signal unnamed-input-1046)
              #:unnamed-input-1053 (bv->signal unnamed-input-1053)
              #:unnamed-input-1054 (bv->signal unnamed-input-1054)
              #:unnamed-input-1057 (bv->signal unnamed-input-1057))
             'result))

(test-case "find any nonzero output"
           (begin
             (define o0 (run (list)))
             (define o1 (run (signal-state o0)))
             (define o2 (run (signal-state o1)))
             (define o3 (run (signal-state o2)))
             (check-true (sat? (solve (assert (bveq (bv 1 18) (signal-value o3))))))))

(test-case "multiplication"
           (begin
             (define-symbolic a b (bitvector 18))
             (define o0 (run (list) #:dataa a #:datab b))
             (define o1 (run (signal-state o0)))
             (define o2 (run (signal-state o1)))
             (define o3 (run (signal-state o2)))
             (check-true (sat? (synthesize #:forall (list a b)
                                           #:guarantee
                                           (assert (bveq (bvmul a b)
                                                         (extract 17 0 (signal-value o3)))))))))
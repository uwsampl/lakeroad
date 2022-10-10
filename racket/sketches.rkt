;;; Lakeroad sketches.
;;;
;;; Lakeroad provides a number of synthesis sketches that should work across a wide range of
;;; platforms. Once a sketch is generated, it is architecture-dependent; to support users who would
;;; like to use new architectures with Lakeroad, we generate sketches using architecture-independent
;;; sketch generators. A sketch generator is a function which takes an architecture description, and
;;; uses that architecture description to generate an architecture-specific sketch. From the
;;; architecture description, the sketch generator is able to instantiate common interfaces like LUTs,
;;; MUXes, and DSPs, and the architecture description utilities (see architecture-description.rkt)
;;; will generate the architecture-specific instantiations of these interfaces.
#lang errortrace racket/base

(require "architecture-description.rkt"
         "logical-to-physical.rkt"
         (prefix-in lr: "language.rkt")
         rosette
         rosette/lib/angelic)

;;; Generates a "bitwise" sketch, for operations like AND and OR.
;;;
;;; Bitwise operations are very simple: for n-bit inputs i0 and i1, bit 0 of i0 and bit 0 of i1 are
;;; paired together and put into a LUT, bit 1 of i0 and bit 1 of i1 are paired together and put into a
;;; LUT, and so on. This simple pattern is able to implement many useful operations.
;;;
;;; - logical-inputs: A Lakeroad list expression, representing a list of logical inputs. Each logical
;;;   input should have the same bitwidth.
;;; - num-logical-inputs: The number of logical inputs. This is used to determine the size of the LUTs
;;;   to be used.
;;; - bitwidth: The bitwidth of the inputs, which will also be the bitwidth of the output.
(define (bitwise-sketch-generator architecture-description logical-inputs num-logical-inputs bitwidth)
  ;;; First, we construct a LUT just to get the `internal-data`. We will reuse this internal data to
  ;;; create more LUTs which use the same LUT memory.
  (match-let*
      ([(list _ internal-data)
        (construct-interface
         architecture-description
         (interface-identifier "LUT" (hash "num_inputs" num-logical-inputs))
         ;;; Note that we don't care what the inputs are hooked up to here, because we are
         ;;; just trying to get the internal data.
         (for/list ([i num-logical-inputs])
           (cons (format "I~a" i) (bv 0 1))))]
       [physical-inputs (logical-to-physical-mapping (choose* '(bitwise) '(bitwise-reverse))
                                                     logical-inputs)]
       [physical-outputs
        (for/list ([i bitwidth])
          (let* ([physical-inputs-this-lut (lr:list-ref physical-inputs i)]
                 [port-map (for/list ([i num-logical-inputs])
                             (cons (format "I~a" i) (lr:extract i i physical-inputs-this-lut)))])
            (construct-interface architecture-description
                                 (interface-identifier "LUT" (hash "num_inputs" num-logical-inputs))
                                 port-map
                                 #:internal-data internal-data)))]
       [logical-outputs (physical-to-logical-mapping (choose* '(bitwise) '(bitwise-reverse))
                                                     physical-outputs)]
       [out-expr (lr:list-ref logical-outputs 0)])
    out-expr))

(module+ test
  (require rackunit
           "interpreter.rkt")

  (test-case "bitwise sketch generator"
             (begin
               (define sketch
                 (bitwise-sketch-generator (xilinx-ultrascale-plus-architecture-description)
                                           (list (bv 0 2) (bv 1 2))
                                           2
                                           2))
               (interpret sketch))))
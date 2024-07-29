(set-logic QF_BV)
(declare-fun c0 () (_ BitVec 13))
(define-fun e1 () (_ BitVec 26) ((_ zero_extend 13) c0))
(declare-fun c2 () (_ BitVec 13))
(define-fun e3 () (_ BitVec 26) ((_ zero_extend 13) c2))
(define-fun e4 () (_ BitVec 26) (bvmul e1 e3))
(define-fun e5 () (_ BitVec 27) ((_ zero_extend 1) e4))
(declare-fun c6 () (_ BitVec 26))
(define-fun e7 () (_ BitVec 27) ((_ zero_extend 1) c6))
(define-fun e8 () (_ BitVec 27) (bvadd e5 e7))
(define-fun e9 () (_ BitVec 48) (bvneg (_ bv2 48)))
(define-fun e10 () (_ BitVec 48) ((_ sign_extend 22) c6))
(define-fun e11 () (_ BitVec 48) (bvand e9 e10))
(define-fun e12 () (_ BitVec 13) ((_ extract 47 35) e11))
(define-fun e13 () (_ BitVec 14) ((_ zero_extend 1) e12))
(define-fun e14 () (_ BitVec 1) (bvneg (_ bv1 1)))
(define-fun e15 () (_ BitVec 48) (bvxor e9 e10))
(define-fun e16 () (_ BitVec 12) ((_ extract 47 36) e15))
(define-fun e17 () (_ BitVec 13) (concat e14 e16))
(define-fun e18 () (_ BitVec 14) ((_ zero_extend 1) e17))
(define-fun e19 () (_ BitVec 14) (bvadd e13 e18))
(define-fun e20 () (_ BitVec 12) ((_ extract 34 23) e11))
(define-fun e21 () (_ BitVec 13) ((_ zero_extend 1) e20))
(define-fun e22 () (_ BitVec 12) ((_ extract 35 24) e15))
(define-fun e23 () (_ BitVec 13) ((_ zero_extend 1) e22))
(define-fun e24 () (_ BitVec 13) (bvadd e21 e23))
(define-fun e25 () (_ BitVec 12) ((_ extract 22 11) e11))
(define-fun e26 () (_ BitVec 13) ((_ zero_extend 1) e25))
(define-fun e27 () (_ BitVec 12) ((_ extract 23 12) e15))
(define-fun e28 () (_ BitVec 13) ((_ zero_extend 1) e27))
(define-fun e29 () (_ BitVec 13) (bvadd e26 e28))
(define-fun e30 () (_ BitVec 11) ((_ extract 10 0) e11))
(declare-fun c31 () (_ BitVec 13))
(define-fun e32 () (_ BitVec 18) ((_ sign_extend 5) c31))
(define-fun e33 () (_ BitVec 1) ((_ extract 17 17) e32))
(declare-fun c34 () (_ BitVec 13))
(define-fun e35 () (_ BitVec 27) ((_ sign_extend 14) c34))
(define-fun e36 () (_ BitVec 1) ((_ extract 26 26) e35))
(define-fun e37 () (_ BitVec 1) (bvxor e33 e36))
(define-fun e38 () (_ BitVec 1) (bvnot e37))
(define-fun e39 () (_ BitVec 12) (concat e30 e38))
(define-fun e40 () (_ BitVec 13) ((_ zero_extend 1) e39))
(define-fun e41 () (_ BitVec 12) ((_ extract 11 0) e15))
(define-fun e42 () (_ BitVec 13) ((_ zero_extend 1) e41))
(define-fun e43 () (_ BitVec 13) (bvadd e40 e42))
(define-fun e44 () (_ BitVec 1) ((_ extract 12 12) e43))
(define-fun e45 () (_ BitVec 13) ((_ zero_extend 12) e44))
(define-fun e46 () (_ BitVec 13) (bvadd e29 e45))
(define-fun e47 () (_ BitVec 1) ((_ extract 12 12) e46))
(define-fun e48 () (_ BitVec 13) ((_ zero_extend 12) e47))
(define-fun e49 () (_ BitVec 13) (bvadd e24 e48))
(define-fun e50 () (_ BitVec 1) ((_ extract 12 12) e49))
(define-fun e51 () (_ BitVec 14) ((_ zero_extend 13) e50))
(define-fun e52 () (_ BitVec 14) (bvadd e19 e51))
(define-fun e53 () (_ BitVec 12) ((_ extract 11 0) e52))
(define-fun e54 () (_ BitVec 12) ((_ extract 11 0) e49))
(define-fun e55 () (_ BitVec 12) ((_ extract 11 0) e46))
(define-fun e56 () (_ BitVec 12) ((_ extract 11 0) e43))
(define-fun e57 () (_ BitVec 24) (concat e55 e56))
(define-fun e58 () (_ BitVec 36) (concat e54 e57))
(define-fun e59 () (_ BitVec 48) (concat e53 e58))
(define-fun e60 () (_ BitVec 48) (bvnot e59))
(define-fun e61 () (_ BitVec 27) ((_ extract 26 0) e60))
(define-fun e62 () Bool (= e8 e61))
(define-fun e63 () Bool (not e62))
(assert e63)
(check-sat)
(get-model)

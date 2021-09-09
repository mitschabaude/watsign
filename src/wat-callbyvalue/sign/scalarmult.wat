(module
  (import "../log.wat" "log_vec16" (func $log_vec16))
  (import "../../../node_modules/esbuild-plugin-wat/lib/memory.wat" "alloc" (func $alloc (param i32) (result i32)))

	(import "../math25519.wat" "set" (func $set25519 (param i32 i32)))
	(import "../math25519.wat" "add" (func $A (param i32 i32 i32)))
	(import "../math25519.wat" "subtract" (func $Z (param i32 i32 i32)))
	(import "../math25519.wat" "multiply" (func $M (param i32 i32 i32)))
	(import "../math25519.wat" "sel" (func $sel25519 (param i32 i32 i32)))

  ;; TODO add types
  (import "../math25519/add.wat" "add_value" (func $AV))
	(import "../math25519/add.wat" "subtract_value" (func $ZV))
	(import "../math25519/multiply.wat" "multiply_value" (func $MV))

  (import "../load.wat" "load" (func $load25519 (param i32) (result i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64)))
  (import "../load.wat" "store" (func $store25519 (param i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i32)))
  (import "../load.wat" "load4" (func $load4))
  (import "../load.wat" "store4" (func $store4))

  (import "./globals.wat" "D2" (global $D2 i32))
  (import "./globals.wat" "X" (global $X i32))
  (import "./globals.wat" "Y" (global $Y i32))

  ;; (import "../bytes_utils.wat" "alloc_zero" (func $alloc_zero (param i32) (result i32)))
  (import "../bytes_utils.wat" "zero" (func $zero (param i32 i32)))

  (export "scalarmult" (func $scalarmult))
  (export "scalarbase" (func $scalarbase))
  (export "add" (func $add))

  (func $scalarbase
    (param $p i32) ;; output ec point, 4 x 16 x i64
    (param $s i32) ;; scalar, 32 x i8

    (local $q i32)
    ;; let q = [gf(), gf(), gf(), gf()];
    ;; set25519(q[0], X);
    ;; set25519(q[1], Y);
    ;; set25519(q[2], gf1);
    ;; mul25519(q[3], X, Y);
    ;; scalarmult(p, q, s);
    (local.set $q (call $alloc (i32.const 512)))
    (call $set25519 (local.get $q) (global.get $X))
    (call $set25519 (i32.add (local.get $q) (i32.const 128)) (global.get $Y))
    (call $zero (i32.add (local.get $q) (i32.const 256)) (i32.const 128))
    (i32.store8 offset=256 (local.get $q) (i32.const 1))
    (call $M (i32.add (local.get $q) (i32.const 384)) (global.get $X) (global.get $Y))
    (call $scalarmult (local.get $p) (local.get $q) (local.get $s))
  )

  (func $scalarmult
    (param $p i32) ;; output ec point, 4 x 16 x i64
    (param $q i32) ;; input ec point, 4 x 16 x i64
    (param $s i32) ;; scalar, 32 x i8

    (local $i i32) (local $b i32)
    ;; p
    (local $p00 i64) (local $p01 i64) (local $p02 i64) (local $p03 i64)
    (local $p04 i64) (local $p05 i64) (local $p06 i64) (local $p07 i64)
    (local $p08 i64) (local $p09 i64) (local $p0a i64) (local $p0b i64)
    (local $p0c i64) (local $p0d i64) (local $p0e i64) (local $p0f i64)
    (local $p10 i64) (local $p11 i64) (local $p12 i64) (local $p13 i64)
    (local $p14 i64) (local $p15 i64) (local $p16 i64) (local $p17 i64)
    (local $p18 i64) (local $p19 i64) (local $p1a i64) (local $p1b i64)
    (local $p1c i64) (local $p1d i64) (local $p1e i64) (local $p1f i64)
    (local $p20 i64) (local $p21 i64) (local $p22 i64) (local $p23 i64)
    (local $p24 i64) (local $p25 i64) (local $p26 i64) (local $p27 i64)
    (local $p28 i64) (local $p29 i64) (local $p2a i64) (local $p2b i64)
    (local $p2c i64) (local $p2d i64) (local $p2e i64) (local $p2f i64)
    (local $p30 i64) (local $p31 i64) (local $p32 i64) (local $p33 i64)
    (local $p34 i64) (local $p35 i64) (local $p36 i64) (local $p37 i64)
    (local $p38 i64) (local $p39 i64) (local $p3a i64) (local $p3b i64)
    (local $p3c i64) (local $p3d i64) (local $p3e i64) (local $p3f i64)
    ;; q
    (local $q00 i64) (local $q01 i64) (local $q02 i64) (local $q03 i64)
    (local $q04 i64) (local $q05 i64) (local $q06 i64) (local $q07 i64)
    (local $q08 i64) (local $q09 i64) (local $q0a i64) (local $q0b i64)
    (local $q0c i64) (local $q0d i64) (local $q0e i64) (local $q0f i64)
    (local $q10 i64) (local $q11 i64) (local $q12 i64) (local $q13 i64)
    (local $q14 i64) (local $q15 i64) (local $q16 i64) (local $q17 i64)
    (local $q18 i64) (local $q19 i64) (local $q1a i64) (local $q1b i64)
    (local $q1c i64) (local $q1d i64) (local $q1e i64) (local $q1f i64)
    (local $q20 i64) (local $q21 i64) (local $q22 i64) (local $q23 i64)
    (local $q24 i64) (local $q25 i64) (local $q26 i64) (local $q27 i64)
    (local $q28 i64) (local $q29 i64) (local $q2a i64) (local $q2b i64)
    (local $q2c i64) (local $q2d i64) (local $q2e i64) (local $q2f i64)
    (local $q30 i64) (local $q31 i64) (local $q32 i64) (local $q33 i64)
    (local $q34 i64) (local $q35 i64) (local $q36 i64) (local $q37 i64)
    (local $q38 i64) (local $q39 i64) (local $q3a i64) (local $q3b i64)
    (local $q3c i64) (local $q3d i64) (local $q3e i64) (local $q3f i64)

    (call $load4 (local.get $q))
    local.set $q3f local.set $q3e local.set $q3d local.set $q3c
    local.set $q3b local.set $q3a local.set $q39 local.set $q38
    local.set $q37 local.set $q36 local.set $q35 local.set $q34
    local.set $q33 local.set $q32 local.set $q31 local.set $q30
    local.set $q2f local.set $q2e local.set $q2d local.set $q2c
    local.set $q2b local.set $q2a local.set $q29 local.set $q28
    local.set $q27 local.set $q26 local.set $q25 local.set $q24
    local.set $q23 local.set $q22 local.set $q21 local.set $q20
    local.set $q1f local.set $q1e local.set $q1d local.set $q1c
    local.set $q1b local.set $q1a local.set $q19 local.set $q18
    local.set $q17 local.set $q16 local.set $q15 local.set $q14
    local.set $q13 local.set $q12 local.set $q11 local.set $q10
    local.set $q0f local.set $q0e local.set $q0d local.set $q0c
    local.set $q0b local.set $q0a local.set $q09 local.set $q08
    local.set $q07 local.set $q06 local.set $q05 local.set $q04
    local.set $q03 local.set $q02 local.set $q01 local.set $q00

    ;; set25519(p[0], gf0); set25519(p[1], gf1);
    ;; set25519(p[2], gf1); set25519(p[3], gf0);
    (local.set $p10 (i64.const 1))
    (local.set $p20 (i64.const 1))

    ;; for (i = 255; i >= 0; --i)
    (local.set $i (i32.const 255))
    (loop
      ;; b = (s[(i / 8) | 0] >> (i & 7)) & 1;
      (i32.load8_u (i32.add (local.get $s)
        (i32.shr_u (local.get $i) (i32.const 3))
      ))
      (i32.and (local.get $i) (i32.const 7))
      i32.shr_s
      i32.const 1
      i32.and
      local.set $b

      ;; cswap(p, q, b);
      ;; add(q, p);
      ;; add(p, p);
      ;; cswap(p, q, b);
      local.get $p00 local.get $p01 local.get $p02 local.get $p03
      local.get $p04 local.get $p05 local.get $p06 local.get $p07
      local.get $p08 local.get $p09 local.get $p0a local.get $p0b
      local.get $p0c local.get $p0d local.get $p0e local.get $p0f
      local.get $p10 local.get $p11 local.get $p12 local.get $p13
      local.get $p14 local.get $p15 local.get $p16 local.get $p17
      local.get $p18 local.get $p19 local.get $p1a local.get $p1b
      local.get $p1c local.get $p1d local.get $p1e local.get $p1f
      local.get $p20 local.get $p21 local.get $p22 local.get $p23
      local.get $p24 local.get $p25 local.get $p26 local.get $p27
      local.get $p28 local.get $p29 local.get $p2a local.get $p2b
      local.get $p2c local.get $p2d local.get $p2e local.get $p2f
      local.get $p30 local.get $p31 local.get $p32 local.get $p33
      local.get $p34 local.get $p35 local.get $p36 local.get $p37
      local.get $p38 local.get $p39 local.get $p3a local.get $p3b
      local.get $p3c local.get $p3d local.get $p3e local.get $p3f

      local.get $q00 local.get $q01 local.get $q02 local.get $q03
      local.get $q04 local.get $q05 local.get $q06 local.get $q07
      local.get $q08 local.get $q09 local.get $q0a local.get $q0b
      local.get $q0c local.get $q0d local.get $q0e local.get $q0f
      local.get $q10 local.get $q11 local.get $q12 local.get $q13
      local.get $q14 local.get $q15 local.get $q16 local.get $q17
      local.get $q18 local.get $q19 local.get $q1a local.get $q1b
      local.get $q1c local.get $q1d local.get $q1e local.get $q1f
      local.get $q20 local.get $q21 local.get $q22 local.get $q23
      local.get $q24 local.get $q25 local.get $q26 local.get $q27
      local.get $q28 local.get $q29 local.get $q2a local.get $q2b
      local.get $q2c local.get $q2d local.get $q2e local.get $q2f
      local.get $q30 local.get $q31 local.get $q32 local.get $q33
      local.get $q34 local.get $q35 local.get $q36 local.get $q37
      local.get $q38 local.get $q39 local.get $q3a local.get $q3b
      local.get $q3c local.get $q3d local.get $q3e local.get $q3f

      local.get $b
      call $cswap
      local.set $p3f local.set $p3e local.set $p3d local.set $p3c
      local.set $p3b local.set $p3a local.set $p39 local.set $p38
      local.set $p37 local.set $p36 local.set $p35 local.set $p34
      local.set $p33 local.set $p32 local.set $p31 local.set $p30
      local.set $p2f local.set $p2e local.set $p2d local.set $p2c
      local.set $p2b local.set $p2a local.set $p29 local.set $p28
      local.set $p27 local.set $p26 local.set $p25 local.set $p24
      local.set $p23 local.set $p22 local.set $p21 local.set $p20
      local.set $p1f local.set $p1e local.set $p1d local.set $p1c
      local.set $p1b local.set $p1a local.set $p19 local.set $p18
      local.set $p17 local.set $p16 local.set $p15 local.set $p14
      local.set $p13 local.set $p12 local.set $p11 local.set $p10
      local.set $p0f local.set $p0e local.set $p0d local.set $p0c
      local.set $p0b local.set $p0a local.set $p09 local.set $p08
      local.set $p07 local.set $p06 local.set $p05 local.set $p04
      local.set $p03 local.set $p02 local.set $p01 local.set $p00

      local.set $q3f local.set $q3e local.set $q3d local.set $q3c
      local.set $q3b local.set $q3a local.set $q39 local.set $q38
      local.set $q37 local.set $q36 local.set $q35 local.set $q34
      local.set $q33 local.set $q32 local.set $q31 local.set $q30
      local.set $q2f local.set $q2e local.set $q2d local.set $q2c
      local.set $q2b local.set $q2a local.set $q29 local.set $q28
      local.set $q27 local.set $q26 local.set $q25 local.set $q24
      local.set $q23 local.set $q22 local.set $q21 local.set $q20
      local.set $q1f local.set $q1e local.set $q1d local.set $q1c
      local.set $q1b local.set $q1a local.set $q19 local.set $q18
      local.set $q17 local.set $q16 local.set $q15 local.set $q14
      local.set $q13 local.set $q12 local.set $q11 local.set $q10
      local.set $q0f local.set $q0e local.set $q0d local.set $q0c
      local.set $q0b local.set $q0a local.set $q09 local.set $q08
      local.set $q07 local.set $q06 local.set $q05 local.set $q04
      local.set $q03 local.set $q02 local.set $q01 local.set $q00

      local.get $q00 local.get $q01 local.get $q02 local.get $q03
      local.get $q04 local.get $q05 local.get $q06 local.get $q07
      local.get $q08 local.get $q09 local.get $q0a local.get $q0b
      local.get $q0c local.get $q0d local.get $q0e local.get $q0f
      local.get $q10 local.get $q11 local.get $q12 local.get $q13
      local.get $q14 local.get $q15 local.get $q16 local.get $q17
      local.get $q18 local.get $q19 local.get $q1a local.get $q1b
      local.get $q1c local.get $q1d local.get $q1e local.get $q1f
      local.get $q20 local.get $q21 local.get $q22 local.get $q23
      local.get $q24 local.get $q25 local.get $q26 local.get $q27
      local.get $q28 local.get $q29 local.get $q2a local.get $q2b
      local.get $q2c local.get $q2d local.get $q2e local.get $q2f
      local.get $q30 local.get $q31 local.get $q32 local.get $q33
      local.get $q34 local.get $q35 local.get $q36 local.get $q37
      local.get $q38 local.get $q39 local.get $q3a local.get $q3b
      local.get $q3c local.get $q3d local.get $q3e local.get $q3f

      local.get $p00 local.get $p01 local.get $p02 local.get $p03
      local.get $p04 local.get $p05 local.get $p06 local.get $p07
      local.get $p08 local.get $p09 local.get $p0a local.get $p0b
      local.get $p0c local.get $p0d local.get $p0e local.get $p0f
      local.get $p10 local.get $p11 local.get $p12 local.get $p13
      local.get $p14 local.get $p15 local.get $p16 local.get $p17
      local.get $p18 local.get $p19 local.get $p1a local.get $p1b
      local.get $p1c local.get $p1d local.get $p1e local.get $p1f
      local.get $p20 local.get $p21 local.get $p22 local.get $p23
      local.get $p24 local.get $p25 local.get $p26 local.get $p27
      local.get $p28 local.get $p29 local.get $p2a local.get $p2b
      local.get $p2c local.get $p2d local.get $p2e local.get $p2f
      local.get $p30 local.get $p31 local.get $p32 local.get $p33
      local.get $p34 local.get $p35 local.get $p36 local.get $p37
      local.get $p38 local.get $p39 local.get $p3a local.get $p3b
      local.get $p3c local.get $p3d local.get $p3e local.get $p3f
      call $add
      local.set $q3f local.set $q3e local.set $q3d local.set $q3c
      local.set $q3b local.set $q3a local.set $q39 local.set $q38
      local.set $q37 local.set $q36 local.set $q35 local.set $q34
      local.set $q33 local.set $q32 local.set $q31 local.set $q30
      local.set $q2f local.set $q2e local.set $q2d local.set $q2c
      local.set $q2b local.set $q2a local.set $q29 local.set $q28
      local.set $q27 local.set $q26 local.set $q25 local.set $q24
      local.set $q23 local.set $q22 local.set $q21 local.set $q20
      local.set $q1f local.set $q1e local.set $q1d local.set $q1c
      local.set $q1b local.set $q1a local.set $q19 local.set $q18
      local.set $q17 local.set $q16 local.set $q15 local.set $q14
      local.set $q13 local.set $q12 local.set $q11 local.set $q10
      local.set $q0f local.set $q0e local.set $q0d local.set $q0c
      local.set $q0b local.set $q0a local.set $q09 local.set $q08
      local.set $q07 local.set $q06 local.set $q05 local.set $q04
      local.set $q03 local.set $q02 local.set $q01 local.set $q00

      local.get $p00 local.get $p01 local.get $p02 local.get $p03
      local.get $p04 local.get $p05 local.get $p06 local.get $p07
      local.get $p08 local.get $p09 local.get $p0a local.get $p0b
      local.get $p0c local.get $p0d local.get $p0e local.get $p0f
      local.get $p10 local.get $p11 local.get $p12 local.get $p13
      local.get $p14 local.get $p15 local.get $p16 local.get $p17
      local.get $p18 local.get $p19 local.get $p1a local.get $p1b
      local.get $p1c local.get $p1d local.get $p1e local.get $p1f
      local.get $p20 local.get $p21 local.get $p22 local.get $p23
      local.get $p24 local.get $p25 local.get $p26 local.get $p27
      local.get $p28 local.get $p29 local.get $p2a local.get $p2b
      local.get $p2c local.get $p2d local.get $p2e local.get $p2f
      local.get $p30 local.get $p31 local.get $p32 local.get $p33
      local.get $p34 local.get $p35 local.get $p36 local.get $p37
      local.get $p38 local.get $p39 local.get $p3a local.get $p3b
      local.get $p3c local.get $p3d local.get $p3e local.get $p3f
      
      local.get $p00 local.get $p01 local.get $p02 local.get $p03
      local.get $p04 local.get $p05 local.get $p06 local.get $p07
      local.get $p08 local.get $p09 local.get $p0a local.get $p0b
      local.get $p0c local.get $p0d local.get $p0e local.get $p0f
      local.get $p10 local.get $p11 local.get $p12 local.get $p13
      local.get $p14 local.get $p15 local.get $p16 local.get $p17
      local.get $p18 local.get $p19 local.get $p1a local.get $p1b
      local.get $p1c local.get $p1d local.get $p1e local.get $p1f
      local.get $p20 local.get $p21 local.get $p22 local.get $p23
      local.get $p24 local.get $p25 local.get $p26 local.get $p27
      local.get $p28 local.get $p29 local.get $p2a local.get $p2b
      local.get $p2c local.get $p2d local.get $p2e local.get $p2f
      local.get $p30 local.get $p31 local.get $p32 local.get $p33
      local.get $p34 local.get $p35 local.get $p36 local.get $p37
      local.get $p38 local.get $p39 local.get $p3a local.get $p3b
      local.get $p3c local.get $p3d local.get $p3e local.get $p3f
      call $add
      local.set $p3f local.set $p3e local.set $p3d local.set $p3c
      local.set $p3b local.set $p3a local.set $p39 local.set $p38
      local.set $p37 local.set $p36 local.set $p35 local.set $p34
      local.set $p33 local.set $p32 local.set $p31 local.set $p30
      local.set $p2f local.set $p2e local.set $p2d local.set $p2c
      local.set $p2b local.set $p2a local.set $p29 local.set $p28
      local.set $p27 local.set $p26 local.set $p25 local.set $p24
      local.set $p23 local.set $p22 local.set $p21 local.set $p20
      local.set $p1f local.set $p1e local.set $p1d local.set $p1c
      local.set $p1b local.set $p1a local.set $p19 local.set $p18
      local.set $p17 local.set $p16 local.set $p15 local.set $p14
      local.set $p13 local.set $p12 local.set $p11 local.set $p10
      local.set $p0f local.set $p0e local.set $p0d local.set $p0c
      local.set $p0b local.set $p0a local.set $p09 local.set $p08
      local.set $p07 local.set $p06 local.set $p05 local.set $p04
      local.set $p03 local.set $p02 local.set $p01 local.set $p00

      local.get $p00 local.get $p01 local.get $p02 local.get $p03
      local.get $p04 local.get $p05 local.get $p06 local.get $p07
      local.get $p08 local.get $p09 local.get $p0a local.get $p0b
      local.get $p0c local.get $p0d local.get $p0e local.get $p0f
      local.get $p10 local.get $p11 local.get $p12 local.get $p13
      local.get $p14 local.get $p15 local.get $p16 local.get $p17
      local.get $p18 local.get $p19 local.get $p1a local.get $p1b
      local.get $p1c local.get $p1d local.get $p1e local.get $p1f
      local.get $p20 local.get $p21 local.get $p22 local.get $p23
      local.get $p24 local.get $p25 local.get $p26 local.get $p27
      local.get $p28 local.get $p29 local.get $p2a local.get $p2b
      local.get $p2c local.get $p2d local.get $p2e local.get $p2f
      local.get $p30 local.get $p31 local.get $p32 local.get $p33
      local.get $p34 local.get $p35 local.get $p36 local.get $p37
      local.get $p38 local.get $p39 local.get $p3a local.get $p3b
      local.get $p3c local.get $p3d local.get $p3e local.get $p3f

      local.get $q00 local.get $q01 local.get $q02 local.get $q03
      local.get $q04 local.get $q05 local.get $q06 local.get $q07
      local.get $q08 local.get $q09 local.get $q0a local.get $q0b
      local.get $q0c local.get $q0d local.get $q0e local.get $q0f
      local.get $q10 local.get $q11 local.get $q12 local.get $q13
      local.get $q14 local.get $q15 local.get $q16 local.get $q17
      local.get $q18 local.get $q19 local.get $q1a local.get $q1b
      local.get $q1c local.get $q1d local.get $q1e local.get $q1f
      local.get $q20 local.get $q21 local.get $q22 local.get $q23
      local.get $q24 local.get $q25 local.get $q26 local.get $q27
      local.get $q28 local.get $q29 local.get $q2a local.get $q2b
      local.get $q2c local.get $q2d local.get $q2e local.get $q2f
      local.get $q30 local.get $q31 local.get $q32 local.get $q33
      local.get $q34 local.get $q35 local.get $q36 local.get $q37
      local.get $q38 local.get $q39 local.get $q3a local.get $q3b
      local.get $q3c local.get $q3d local.get $q3e local.get $q3f

      local.get $b
      call $cswap
      local.set $p3f local.set $p3e local.set $p3d local.set $p3c
      local.set $p3b local.set $p3a local.set $p39 local.set $p38
      local.set $p37 local.set $p36 local.set $p35 local.set $p34
      local.set $p33 local.set $p32 local.set $p31 local.set $p30
      local.set $p2f local.set $p2e local.set $p2d local.set $p2c
      local.set $p2b local.set $p2a local.set $p29 local.set $p28
      local.set $p27 local.set $p26 local.set $p25 local.set $p24
      local.set $p23 local.set $p22 local.set $p21 local.set $p20
      local.set $p1f local.set $p1e local.set $p1d local.set $p1c
      local.set $p1b local.set $p1a local.set $p19 local.set $p18
      local.set $p17 local.set $p16 local.set $p15 local.set $p14
      local.set $p13 local.set $p12 local.set $p11 local.set $p10
      local.set $p0f local.set $p0e local.set $p0d local.set $p0c
      local.set $p0b local.set $p0a local.set $p09 local.set $p08
      local.set $p07 local.set $p06 local.set $p05 local.set $p04
      local.set $p03 local.set $p02 local.set $p01 local.set $p00

      local.set $q3f local.set $q3e local.set $q3d local.set $q3c
      local.set $q3b local.set $q3a local.set $q39 local.set $q38
      local.set $q37 local.set $q36 local.set $q35 local.set $q34
      local.set $q33 local.set $q32 local.set $q31 local.set $q30
      local.set $q2f local.set $q2e local.set $q2d local.set $q2c
      local.set $q2b local.set $q2a local.set $q29 local.set $q28
      local.set $q27 local.set $q26 local.set $q25 local.set $q24
      local.set $q23 local.set $q22 local.set $q21 local.set $q20
      local.set $q1f local.set $q1e local.set $q1d local.set $q1c
      local.set $q1b local.set $q1a local.set $q19 local.set $q18
      local.set $q17 local.set $q16 local.set $q15 local.set $q14
      local.set $q13 local.set $q12 local.set $q11 local.set $q10
      local.set $q0f local.set $q0e local.set $q0d local.set $q0c
      local.set $q0b local.set $q0a local.set $q09 local.set $q08
      local.set $q07 local.set $q06 local.set $q05 local.set $q04
      local.set $q03 local.set $q02 local.set $q01 local.set $q00
    
      (br_if 0 (i32.ne (i32.const -1)
        (local.tee $i (i32.sub (local.get $i) (i32.const 1)))
      ))
    )
    local.get $p00 local.get $p01 local.get $p02 local.get $p03
    local.get $p04 local.get $p05 local.get $p06 local.get $p07
    local.get $p08 local.get $p09 local.get $p0a local.get $p0b
    local.get $p0c local.get $p0d local.get $p0e local.get $p0f
    local.get $p10 local.get $p11 local.get $p12 local.get $p13
    local.get $p14 local.get $p15 local.get $p16 local.get $p17
    local.get $p18 local.get $p19 local.get $p1a local.get $p1b
    local.get $p1c local.get $p1d local.get $p1e local.get $p1f
    local.get $p20 local.get $p21 local.get $p22 local.get $p23
    local.get $p24 local.get $p25 local.get $p26 local.get $p27
    local.get $p28 local.get $p29 local.get $p2a local.get $p2b
    local.get $p2c local.get $p2d local.get $p2e local.get $p2f
    local.get $p30 local.get $p31 local.get $p32 local.get $p33
    local.get $p34 local.get $p35 local.get $p36 local.get $p37
    local.get $p38 local.get $p39 local.get $p3a local.get $p3b
    local.get $p3c local.get $p3d local.get $p3e local.get $p3f
    local.get $p call $store4
  )

	(func $add
    ;; p0
    (param $p00 i64) (param $p01 i64) (param $p02 i64) (param $p03 i64)
    (param $p04 i64) (param $p05 i64) (param $p06 i64) (param $p07 i64)
    (param $p08 i64) (param $p09 i64) (param $p0a i64) (param $p0b i64)
    (param $p0c i64) (param $p0d i64) (param $p0e i64) (param $p0f i64)
    ;; p1
    (param $p10 i64) (param $p11 i64) (param $p12 i64) (param $p13 i64)
    (param $p14 i64) (param $p15 i64) (param $p16 i64) (param $p17 i64)
    (param $p18 i64) (param $p19 i64) (param $p1a i64) (param $p1b i64)
    (param $p1c i64) (param $p1d i64) (param $p1e i64) (param $p1f i64)
    ;; p2
    (param $p20 i64) (param $p21 i64) (param $p22 i64) (param $p23 i64)
    (param $p24 i64) (param $p25 i64) (param $p26 i64) (param $p27 i64)
    (param $p28 i64) (param $p29 i64) (param $p2a i64) (param $p2b i64)
    (param $p2c i64) (param $p2d i64) (param $p2e i64) (param $p2f i64)
    ;; p3
    (param $p30 i64) (param $p31 i64) (param $p32 i64) (param $p33 i64)
    (param $p34 i64) (param $p35 i64) (param $p36 i64) (param $p37 i64)
    (param $p38 i64) (param $p39 i64) (param $p3a i64) (param $p3b i64)
    (param $p3c i64) (param $p3d i64) (param $p3e i64) (param $p3f i64)
    ;; q0
    (param $q00 i64) (param $q01 i64) (param $q02 i64) (param $q03 i64)
    (param $q04 i64) (param $q05 i64) (param $q06 i64) (param $q07 i64)
    (param $q08 i64) (param $q09 i64) (param $q0a i64) (param $q0b i64)
    (param $q0c i64) (param $q0d i64) (param $q0e i64) (param $q0f i64)
    ;; q1
    (param $q10 i64) (param $q11 i64) (param $q12 i64) (param $q13 i64)
    (param $q14 i64) (param $q15 i64) (param $q16 i64) (param $q17 i64)
    (param $q18 i64) (param $q19 i64) (param $q1a i64) (param $q1b i64)
    (param $q1c i64) (param $q1d i64) (param $q1e i64) (param $q1f i64)
    ;; q2
    (param $q20 i64) (param $q21 i64) (param $q22 i64) (param $q23 i64)
    (param $q24 i64) (param $q25 i64) (param $q26 i64) (param $q27 i64)
    (param $q28 i64) (param $q29 i64) (param $q2a i64) (param $q2b i64)
    (param $q2c i64) (param $q2d i64) (param $q2e i64) (param $q2f i64)
    ;; q3
    (param $q30 i64) (param $q31 i64) (param $q32 i64) (param $q33 i64)
    (param $q34 i64) (param $q35 i64) (param $q36 i64) (param $q37 i64)
    (param $q38 i64) (param $q39 i64) (param $q3a i64) (param $q3b i64)
    (param $q3c i64) (param $q3d i64) (param $q3e i64) (param $q3f i64)

    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)

    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)

    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)

    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)

    ;; a
    (local $a0 i64) (local $a1 i64) (local $a2 i64) (local $a3 i64)
    (local $a4 i64) (local $a5 i64) (local $a6 i64) (local $a7 i64)
    (local $a8 i64) (local $a9 i64) (local $aa i64) (local $ab i64)
    (local $ac i64) (local $ad i64) (local $ae i64) (local $af i64)
    ;; b
    (local $b0 i64) (local $b1 i64) (local $b2 i64) (local $b3 i64)
    (local $b4 i64) (local $b5 i64) (local $b6 i64) (local $b7 i64)
    (local $b8 i64) (local $b9 i64) (local $ba i64) (local $bb i64)
    (local $bc i64) (local $bd i64) (local $be i64) (local $bf i64)
    ;; t
    (local $t0 i64) (local $t1 i64) (local $t2 i64) (local $t3 i64)
    (local $t4 i64) (local $t5 i64) (local $t6 i64) (local $t7 i64)
    (local $t8 i64) (local $t9 i64) (local $ta i64) (local $tb i64)
    (local $tc i64) (local $td i64) (local $te i64) (local $tf i64)

    ;; sub25519(a, p[1], p[0]);
    ;; sub25519(t, q[1], q[0]);
    ;; mul25519(a, a, t);

    ;; (call $Z (local.get $a) (local.get $P1) (local.get $P0))
    local.get $p10 local.get $p11 local.get $p12 local.get $p13
    local.get $p14 local.get $p15 local.get $p16 local.get $p17
    local.get $p18 local.get $p19 local.get $p1a local.get $p1b
    local.get $p1c local.get $p1d local.get $p1e local.get $p1f
    local.get $p00 local.get $p01 local.get $p02 local.get $p03
    local.get $p04 local.get $p05 local.get $p06 local.get $p07
    local.get $p08 local.get $p09 local.get $p0a local.get $p0b
    local.get $p0c local.get $p0d local.get $p0e local.get $p0f
    call $ZV
    local.set $af local.set $ae local.set $ad local.set $ac
    local.set $ab local.set $aa local.set $a9 local.set $a8
    local.set $a7 local.set $a6 local.set $a5 local.set $a4
    local.set $a3 local.set $a2 local.set $a1 local.set $a0

    ;; (call $Z (local.get $t) (local.get $Q1) (local.get $Q0))
    local.get $q10 local.get $q11 local.get $q12 local.get $q13
    local.get $q14 local.get $q15 local.get $q16 local.get $q17
    local.get $q18 local.get $q19 local.get $q1a local.get $q1b
    local.get $q1c local.get $q1d local.get $q1e local.get $q1f
    local.get $q00 local.get $q01 local.get $q02 local.get $q03
    local.get $q04 local.get $q05 local.get $q06 local.get $q07
    local.get $q08 local.get $q09 local.get $q0a local.get $q0b
    local.get $q0c local.get $q0d local.get $q0e local.get $q0f
    call $ZV
    local.set $tf local.set $te local.set $td local.set $tc
    local.set $tb local.set $ta local.set $t9 local.set $t8
    local.set $t7 local.set $t6 local.set $t5 local.set $t4
    local.set $t3 local.set $t2 local.set $t1 local.set $t0

    ;; (call $M (local.get $a) (local.get $a) (local.get $t))
    local.get $a0 local.get $a1 local.get $a2 local.get $a3
    local.get $a4 local.get $a5 local.get $a6 local.get $a7
    local.get $a8 local.get $a9 local.get $aa local.get $ab
    local.get $ac local.get $ad local.get $ae local.get $af
    local.get $t0 local.get $t1 local.get $t2 local.get $t3
    local.get $t4 local.get $t5 local.get $t6 local.get $t7
    local.get $t8 local.get $t9 local.get $ta local.get $tb
    local.get $tc local.get $td local.get $te local.get $tf
    call $MV
    local.set $af local.set $ae local.set $ad local.set $ac
    local.set $ab local.set $aa local.set $a9 local.set $a8
    local.set $a7 local.set $a6 local.set $a5 local.set $a4
    local.set $a3 local.set $a2 local.set $a1 local.set $a0
    
    ;; add25519(b, p[0], p[1]);
    ;; add25519(t, q[0], q[1]);
    ;; mul25519(b, b, t);
    ;; (call $A (local.get $b) (local.get $P0) (local.get $P1))
    local.get $p00 local.get $p01 local.get $p02 local.get $p03
    local.get $p04 local.get $p05 local.get $p06 local.get $p07
    local.get $p08 local.get $p09 local.get $p0a local.get $p0b
    local.get $p0c local.get $p0d local.get $p0e local.get $p0f
    local.get $p10 local.get $p11 local.get $p12 local.get $p13
    local.get $p14 local.get $p15 local.get $p16 local.get $p17
    local.get $p18 local.get $p19 local.get $p1a local.get $p1b
    local.get $p1c local.get $p1d local.get $p1e local.get $p1f
    call $AV
    local.set $bf local.set $be local.set $bd local.set $bc
    local.set $bb local.set $ba local.set $b9 local.set $b8
    local.set $b7 local.set $b6 local.set $b5 local.set $b4
    local.set $b3 local.set $b2 local.set $b1 local.set $b0

    ;; (call $A (local.get $t) (local.get $Q0) (local.get $Q1))
    local.get $q00 local.get $q01 local.get $q02 local.get $q03
    local.get $q04 local.get $q05 local.get $q06 local.get $q07
    local.get $q08 local.get $q09 local.get $q0a local.get $q0b
    local.get $q0c local.get $q0d local.get $q0e local.get $q0f
    local.get $q10 local.get $q11 local.get $q12 local.get $q13
    local.get $q14 local.get $q15 local.get $q16 local.get $q17
    local.get $q18 local.get $q19 local.get $q1a local.get $q1b
    local.get $q1c local.get $q1d local.get $q1e local.get $q1f
    call $AV
    local.set $tf local.set $te local.set $td local.set $tc
    local.set $tb local.set $ta local.set $t9 local.set $t8
    local.set $t7 local.set $t6 local.set $t5 local.set $t4
    local.set $t3 local.set $t2 local.set $t1 local.set $t0

    ;; (call $M (local.get $b) (local.get $b) (local.get $t))
    local.get $b0 local.get $b1 local.get $b2 local.get $b3
    local.get $b4 local.get $b5 local.get $b6 local.get $b7
    local.get $b8 local.get $b9 local.get $ba local.get $bb
    local.get $bc local.get $bd local.get $be local.get $bf
    local.get $t0 local.get $t1 local.get $t2 local.get $t3
    local.get $t4 local.get $t5 local.get $t6 local.get $t7
    local.get $t8 local.get $t9 local.get $ta local.get $tb
    local.get $tc local.get $td local.get $te local.get $tf
    call $MV
    local.set $bf local.set $be local.set $bd local.set $bc
    local.set $bb local.set $ba local.set $b9 local.set $b8
    local.set $b7 local.set $b6 local.set $b5 local.set $b4
    local.set $b3 local.set $b2 local.set $b1 local.set $b0
    
    ;; mul25519(c, p[3], q[3]); // c := P0
    ;; mul25519(c, c, D2);
    ;; mul25519(d, p[2], q[2]); // d := P1
    ;; (call $M (local.get $P0) (local.get $P3) (local.get $Q3))
    local.get $p30 local.get $p31 local.get $p32 local.get $p33
    local.get $p34 local.get $p35 local.get $p36 local.get $p37
    local.get $p38 local.get $p39 local.get $p3a local.get $p3b
    local.get $p3c local.get $p3d local.get $p3e local.get $p3f
    local.get $q30 local.get $q31 local.get $q32 local.get $q33
    local.get $q34 local.get $q35 local.get $q36 local.get $q37
    local.get $q38 local.get $q39 local.get $q3a local.get $q3b
    local.get $q3c local.get $q3d local.get $q3e local.get $q3f
    call $MV
    local.set $p0f local.set $p0e local.set $p0d local.set $p0c
    local.set $p0b local.set $p0a local.set $p09 local.set $p08
    local.set $p07 local.set $p06 local.set $p05 local.set $p04
    local.set $p03 local.set $p02 local.set $p01 local.set $p00

    ;; (call $M (local.get $P0) (local.get $P0) (global.get $D2))
    local.get $p00 local.get $p01 local.get $p02 local.get $p03
    local.get $p04 local.get $p05 local.get $p06 local.get $p07
    local.get $p08 local.get $p09 local.get $p0a local.get $p0b
    local.get $p0c local.get $p0d local.get $p0e local.get $p0f
    (call $load25519 (global.get $D2))
    call $MV
    local.set $p0f local.set $p0e local.set $p0d local.set $p0c
    local.set $p0b local.set $p0a local.set $p09 local.set $p08
    local.set $p07 local.set $p06 local.set $p05 local.set $p04
    local.set $p03 local.set $p02 local.set $p01 local.set $p00

    ;; (call $M (local.get $P1) (local.get $P2) (local.get $Q2))
    local.get $p20 local.get $p21 local.get $p22 local.get $p23
    local.get $p24 local.get $p25 local.get $p26 local.get $p27
    local.get $p28 local.get $p29 local.get $p2a local.get $p2b
    local.get $p2c local.get $p2d local.get $p2e local.get $p2f
    local.get $q20 local.get $q21 local.get $q22 local.get $q23
    local.get $q24 local.get $q25 local.get $q26 local.get $q27
    local.get $q28 local.get $q29 local.get $q2a local.get $q2b
    local.get $q2c local.get $q2d local.get $q2e local.get $q2f
    call $MV
    local.set $p1f local.set $p1e local.set $p1d local.set $p1c
    local.set $p1b local.set $p1a local.set $p19 local.set $p18
    local.set $p17 local.set $p16 local.set $p15 local.set $p14
    local.set $p13 local.set $p12 local.set $p11 local.set $p10

    ;; add25519(d, d, d);
    ;; sub25519(e, b, a); // e := P3
    ;; sub25519(f, d, c); // t := f
    ;; add25519(h, b, a); // a := h
    ;; add25519(g, d, c); // b := g
    ;; (call $A (local.get $P1) (local.get $P1) (local.get $P1))
    local.get $p10 local.get $p11 local.get $p12 local.get $p13
    local.get $p14 local.get $p15 local.get $p16 local.get $p17
    local.get $p18 local.get $p19 local.get $p1a local.get $p1b
    local.get $p1c local.get $p1d local.get $p1e local.get $p1f
    local.get $p10 local.get $p11 local.get $p12 local.get $p13
    local.get $p14 local.get $p15 local.get $p16 local.get $p17
    local.get $p18 local.get $p19 local.get $p1a local.get $p1b
    local.get $p1c local.get $p1d local.get $p1e local.get $p1f
    call $AV
    local.set $p1f local.set $p1e local.set $p1d local.set $p1c
    local.set $p1b local.set $p1a local.set $p19 local.set $p18
    local.set $p17 local.set $p16 local.set $p15 local.set $p14
    local.set $p13 local.set $p12 local.set $p11 local.set $p10

    ;; (call $Z (local.get $P3) (local.get $b) (local.get $a))
    local.get $b0 local.get $b1 local.get $b2 local.get $b3
    local.get $b4 local.get $b5 local.get $b6 local.get $b7
    local.get $b8 local.get $b9 local.get $ba local.get $bb
    local.get $bc local.get $bd local.get $be local.get $bf
    local.get $a0 local.get $a1 local.get $a2 local.get $a3
    local.get $a4 local.get $a5 local.get $a6 local.get $a7
    local.get $a8 local.get $a9 local.get $aa local.get $ab
    local.get $ac local.get $ad local.get $ae local.get $af
    call $ZV
    local.set $p3f local.set $p3e local.set $p3d local.set $p3c
    local.set $p3b local.set $p3a local.set $p39 local.set $p38
    local.set $p37 local.set $p36 local.set $p35 local.set $p34
    local.set $p33 local.set $p32 local.set $p31 local.set $p30

    ;; (call $Z (local.get $t) (local.get $P1) (local.get $P0))
    local.get $p10 local.get $p11 local.get $p12 local.get $p13
    local.get $p14 local.get $p15 local.get $p16 local.get $p17
    local.get $p18 local.get $p19 local.get $p1a local.get $p1b
    local.get $p1c local.get $p1d local.get $p1e local.get $p1f
    local.get $p00 local.get $p01 local.get $p02 local.get $p03
    local.get $p04 local.get $p05 local.get $p06 local.get $p07
    local.get $p08 local.get $p09 local.get $p0a local.get $p0b
    local.get $p0c local.get $p0d local.get $p0e local.get $p0f
    call $ZV
    local.set $tf local.set $te local.set $td local.set $tc
    local.set $tb local.set $ta local.set $t9 local.set $t8
    local.set $t7 local.set $t6 local.set $t5 local.set $t4
    local.set $t3 local.set $t2 local.set $t1 local.set $t0

    ;; (call $A (local.get $a) (local.get $b) (local.get $a))
    local.get $b0 local.get $b1 local.get $b2 local.get $b3
    local.get $b4 local.get $b5 local.get $b6 local.get $b7
    local.get $b8 local.get $b9 local.get $ba local.get $bb
    local.get $bc local.get $bd local.get $be local.get $bf
    local.get $a0 local.get $a1 local.get $a2 local.get $a3
    local.get $a4 local.get $a5 local.get $a6 local.get $a7
    local.get $a8 local.get $a9 local.get $aa local.get $ab
    local.get $ac local.get $ad local.get $ae local.get $af
    call $AV
    local.set $af local.set $ae local.set $ad local.set $ac
    local.set $ab local.set $aa local.set $a9 local.set $a8
    local.set $a7 local.set $a6 local.set $a5 local.set $a4
    local.set $a3 local.set $a2 local.set $a1 local.set $a0

    ;; (call $A (local.get $b) (local.get $P1) (local.get $P0))
    local.get $p10 local.get $p11 local.get $p12 local.get $p13
    local.get $p14 local.get $p15 local.get $p16 local.get $p17
    local.get $p18 local.get $p19 local.get $p1a local.get $p1b
    local.get $p1c local.get $p1d local.get $p1e local.get $p1f
    local.get $p00 local.get $p01 local.get $p02 local.get $p03
    local.get $p04 local.get $p05 local.get $p06 local.get $p07
    local.get $p08 local.get $p09 local.get $p0a local.get $p0b
    local.get $p0c local.get $p0d local.get $p0e local.get $p0f
    call $AV
    local.set $bf local.set $be local.set $bd local.set $bc
    local.set $bb local.set $ba local.set $b9 local.set $b8
    local.set $b7 local.set $b6 local.set $b5 local.set $b4
    local.set $b3 local.set $b2 local.set $b1 local.set $b0

    ;; mul25519(p[0], e, f);
    ;; mul25519(p[1], h, g);
    ;; mul25519(p[2], g, f);
    ;; mul25519(p[3], e, h);
    ;; (call $M (local.get $P0) (local.get $P3) (local.get $t))
    local.get $p30 local.get $p31 local.get $p32 local.get $p33
    local.get $p34 local.get $p35 local.get $p36 local.get $p37
    local.get $p38 local.get $p39 local.get $p3a local.get $p3b
    local.get $p3c local.get $p3d local.get $p3e local.get $p3f
    local.get $t0 local.get $t1 local.get $t2 local.get $t3
    local.get $t4 local.get $t5 local.get $t6 local.get $t7
    local.get $t8 local.get $t9 local.get $ta local.get $tb
    local.get $tc local.get $td local.get $te local.get $tf
    call $MV
    local.set $p0f local.set $p0e local.set $p0d local.set $p0c
    local.set $p0b local.set $p0a local.set $p09 local.set $p08
    local.set $p07 local.set $p06 local.set $p05 local.set $p04
    local.set $p03 local.set $p02 local.set $p01 local.set $p00

    ;; (call $M (local.get $P1) (local.get $a) (local.get $b))
    local.get $a0 local.get $a1 local.get $a2 local.get $a3
    local.get $a4 local.get $a5 local.get $a6 local.get $a7
    local.get $a8 local.get $a9 local.get $aa local.get $ab
    local.get $ac local.get $ad local.get $ae local.get $af
    local.get $b0 local.get $b1 local.get $b2 local.get $b3
    local.get $b4 local.get $b5 local.get $b6 local.get $b7
    local.get $b8 local.get $b9 local.get $ba local.get $bb
    local.get $bc local.get $bd local.get $be local.get $bf
    call $MV
    local.set $p1f local.set $p1e local.set $p1d local.set $p1c
    local.set $p1b local.set $p1a local.set $p19 local.set $p18
    local.set $p17 local.set $p16 local.set $p15 local.set $p14
    local.set $p13 local.set $p12 local.set $p11 local.set $p10

    ;; (call $M (local.get $P2) (local.get $b) (local.get $t))
    local.get $b0 local.get $b1 local.get $b2 local.get $b3
    local.get $b4 local.get $b5 local.get $b6 local.get $b7
    local.get $b8 local.get $b9 local.get $ba local.get $bb
    local.get $bc local.get $bd local.get $be local.get $bf
    local.get $t0 local.get $t1 local.get $t2 local.get $t3
    local.get $t4 local.get $t5 local.get $t6 local.get $t7
    local.get $t8 local.get $t9 local.get $ta local.get $tb
    local.get $tc local.get $td local.get $te local.get $tf
    call $MV
    local.set $p2f local.set $p2e local.set $p2d local.set $p2c
    local.set $p2b local.set $p2a local.set $p29 local.set $p28
    local.set $p27 local.set $p26 local.set $p25 local.set $p24
    local.set $p23 local.set $p22 local.set $p21 local.set $p20

    ;; (call $M (local.get $P3) (local.get $P3) (local.get $a))
    local.get $p30 local.get $p31 local.get $p32 local.get $p33
    local.get $p34 local.get $p35 local.get $p36 local.get $p37
    local.get $p38 local.get $p39 local.get $p3a local.get $p3b
    local.get $p3c local.get $p3d local.get $p3e local.get $p3f
    local.get $a0 local.get $a1 local.get $a2 local.get $a3
    local.get $a4 local.get $a5 local.get $a6 local.get $a7
    local.get $a8 local.get $a9 local.get $aa local.get $ab
    local.get $ac local.get $ad local.get $ae local.get $af
    call $MV
    local.set $p3f local.set $p3e local.set $p3d local.set $p3c
    local.set $p3b local.set $p3a local.set $p39 local.set $p38
    local.set $p37 local.set $p36 local.set $p35 local.set $p34
    local.set $p33 local.set $p32 local.set $p31 local.set $p30

    local.get $p00 local.get $p01 local.get $p02 local.get $p03
    local.get $p04 local.get $p05 local.get $p06 local.get $p07
    local.get $p08 local.get $p09 local.get $p0a local.get $p0b
    local.get $p0c local.get $p0d local.get $p0e local.get $p0f
    
    local.get $p10 local.get $p11 local.get $p12 local.get $p13
    local.get $p14 local.get $p15 local.get $p16 local.get $p17
    local.get $p18 local.get $p19 local.get $p1a local.get $p1b
    local.get $p1c local.get $p1d local.get $p1e local.get $p1f

    local.get $p20 local.get $p21 local.get $p22 local.get $p23
    local.get $p24 local.get $p25 local.get $p26 local.get $p27
    local.get $p28 local.get $p29 local.get $p2a local.get $p2b
    local.get $p2c local.get $p2d local.get $p2e local.get $p2f

    local.get $p30 local.get $p31 local.get $p32 local.get $p33
    local.get $p34 local.get $p35 local.get $p36 local.get $p37
    local.get $p38 local.get $p39 local.get $p3a local.get $p3b
    local.get $p3c local.get $p3d local.get $p3e local.get $p3f
	)

  (func $cswap
    ;; p0
    (param $p00 i64) (param $p01 i64) (param $p02 i64) (param $p03 i64)
    (param $p04 i64) (param $p05 i64) (param $p06 i64) (param $p07 i64)
    (param $p08 i64) (param $p09 i64) (param $p0a i64) (param $p0b i64)
    (param $p0c i64) (param $p0d i64) (param $p0e i64) (param $p0f i64)
    ;; p1
    (param $p10 i64) (param $p11 i64) (param $p12 i64) (param $p13 i64)
    (param $p14 i64) (param $p15 i64) (param $p16 i64) (param $p17 i64)
    (param $p18 i64) (param $p19 i64) (param $p1a i64) (param $p1b i64)
    (param $p1c i64) (param $p1d i64) (param $p1e i64) (param $p1f i64)
    ;; p2
    (param $p20 i64) (param $p21 i64) (param $p22 i64) (param $p23 i64)
    (param $p24 i64) (param $p25 i64) (param $p26 i64) (param $p27 i64)
    (param $p28 i64) (param $p29 i64) (param $p2a i64) (param $p2b i64)
    (param $p2c i64) (param $p2d i64) (param $p2e i64) (param $p2f i64)
    ;; p3
    (param $p30 i64) (param $p31 i64) (param $p32 i64) (param $p33 i64)
    (param $p34 i64) (param $p35 i64) (param $p36 i64) (param $p37 i64)
    (param $p38 i64) (param $p39 i64) (param $p3a i64) (param $p3b i64)
    (param $p3c i64) (param $p3d i64) (param $p3e i64) (param $p3f i64)
    ;; q0
    (param $q00 i64) (param $q01 i64) (param $q02 i64) (param $q03 i64)
    (param $q04 i64) (param $q05 i64) (param $q06 i64) (param $q07 i64)
    (param $q08 i64) (param $q09 i64) (param $q0a i64) (param $q0b i64)
    (param $q0c i64) (param $q0d i64) (param $q0e i64) (param $q0f i64)
    ;; q1
    (param $q10 i64) (param $q11 i64) (param $q12 i64) (param $q13 i64)
    (param $q14 i64) (param $q15 i64) (param $q16 i64) (param $q17 i64)
    (param $q18 i64) (param $q19 i64) (param $q1a i64) (param $q1b i64)
    (param $q1c i64) (param $q1d i64) (param $q1e i64) (param $q1f i64)
    ;; q2
    (param $q20 i64) (param $q21 i64) (param $q22 i64) (param $q23 i64)
    (param $q24 i64) (param $q25 i64) (param $q26 i64) (param $q27 i64)
    (param $q28 i64) (param $q29 i64) (param $q2a i64) (param $q2b i64)
    (param $q2c i64) (param $q2d i64) (param $q2e i64) (param $q2f i64)
    ;; q3
    (param $q30 i64) (param $q31 i64) (param $q32 i64) (param $q33 i64)
    (param $q34 i64) (param $q35 i64) (param $q36 i64) (param $q37 i64)
    (param $q38 i64) (param $q39 i64) (param $q3a i64) (param $q3b i64)
    (param $q3c i64) (param $q3d i64) (param $q3e i64) (param $q3f i64)
    
    (param $b i32) ;; boolean

    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)

    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)

    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)

    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)

    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)

    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)

    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)

    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)

    local.get $b
		i32.eqz
    if
      local.get $q00 local.get $q01 local.get $q02 local.get $q03
      local.get $q04 local.get $q05 local.get $q06 local.get $q07
      local.get $q08 local.get $q09 local.get $q0a local.get $q0b
      local.get $q0c local.get $q0d local.get $q0e local.get $q0f
      local.get $q10 local.get $q11 local.get $q12 local.get $q13
      local.get $q14 local.get $q15 local.get $q16 local.get $q17
      local.get $q18 local.get $q19 local.get $q1a local.get $q1b
      local.get $q1c local.get $q1d local.get $q1e local.get $q1f
      local.get $q20 local.get $q21 local.get $q22 local.get $q23
      local.get $q24 local.get $q25 local.get $q26 local.get $q27
      local.get $q28 local.get $q29 local.get $q2a local.get $q2b
      local.get $q2c local.get $q2d local.get $q2e local.get $q2f
      local.get $q30 local.get $q31 local.get $q32 local.get $q33
      local.get $q34 local.get $q35 local.get $q36 local.get $q37
      local.get $q38 local.get $q39 local.get $q3a local.get $q3b
      local.get $q3c local.get $q3d local.get $q3e local.get $q3f

      local.get $p00 local.get $p01 local.get $p02 local.get $p03
      local.get $p04 local.get $p05 local.get $p06 local.get $p07
      local.get $p08 local.get $p09 local.get $p0a local.get $p0b
      local.get $p0c local.get $p0d local.get $p0e local.get $p0f
      local.get $p10 local.get $p11 local.get $p12 local.get $p13
      local.get $p14 local.get $p15 local.get $p16 local.get $p17
      local.get $p18 local.get $p19 local.get $p1a local.get $p1b
      local.get $p1c local.get $p1d local.get $p1e local.get $p1f
      local.get $p20 local.get $p21 local.get $p22 local.get $p23
      local.get $p24 local.get $p25 local.get $p26 local.get $p27
      local.get $p28 local.get $p29 local.get $p2a local.get $p2b
      local.get $p2c local.get $p2d local.get $p2e local.get $p2f
      local.get $p30 local.get $p31 local.get $p32 local.get $p33
      local.get $p34 local.get $p35 local.get $p36 local.get $p37
      local.get $p38 local.get $p39 local.get $p3a local.get $p3b
      local.get $p3c local.get $p3d local.get $p3e local.get $p3f
      return
    end
    local.get $p00 local.get $p01 local.get $p02 local.get $p03
    local.get $p04 local.get $p05 local.get $p06 local.get $p07
    local.get $p08 local.get $p09 local.get $p0a local.get $p0b
    local.get $p0c local.get $p0d local.get $p0e local.get $p0f
    local.get $p10 local.get $p11 local.get $p12 local.get $p13
    local.get $p14 local.get $p15 local.get $p16 local.get $p17
    local.get $p18 local.get $p19 local.get $p1a local.get $p1b
    local.get $p1c local.get $p1d local.get $p1e local.get $p1f
    local.get $p20 local.get $p21 local.get $p22 local.get $p23
    local.get $p24 local.get $p25 local.get $p26 local.get $p27
    local.get $p28 local.get $p29 local.get $p2a local.get $p2b
    local.get $p2c local.get $p2d local.get $p2e local.get $p2f
    local.get $p30 local.get $p31 local.get $p32 local.get $p33
    local.get $p34 local.get $p35 local.get $p36 local.get $p37
    local.get $p38 local.get $p39 local.get $p3a local.get $p3b
    local.get $p3c local.get $p3d local.get $p3e local.get $p3f

    local.get $q00 local.get $q01 local.get $q02 local.get $q03
    local.get $q04 local.get $q05 local.get $q06 local.get $q07
    local.get $q08 local.get $q09 local.get $q0a local.get $q0b
    local.get $q0c local.get $q0d local.get $q0e local.get $q0f
    local.get $q10 local.get $q11 local.get $q12 local.get $q13
    local.get $q14 local.get $q15 local.get $q16 local.get $q17
    local.get $q18 local.get $q19 local.get $q1a local.get $q1b
    local.get $q1c local.get $q1d local.get $q1e local.get $q1f
    local.get $q20 local.get $q21 local.get $q22 local.get $q23
    local.get $q24 local.get $q25 local.get $q26 local.get $q27
    local.get $q28 local.get $q29 local.get $q2a local.get $q2b
    local.get $q2c local.get $q2d local.get $q2e local.get $q2f
    local.get $q30 local.get $q31 local.get $q32 local.get $q33
    local.get $q34 local.get $q35 local.get $q36 local.get $q37
    local.get $q38 local.get $q39 local.get $q3a local.get $q3b
    local.get $q3c local.get $q3d local.get $q3e local.get $q3f
  )

	(func $cswap_
		(param $p i32) (param $q i32) ;; 4 x 16 x i64
		(param $b i32) ;; boolean
		(local $i i32) (local $t i32) (local $x i32)
		;; for (i = 0; i < 512; i+=128) sel25519(p[i], q[i], b);
		(local.set $i (i32.const 0))
		(loop
      (call $load25519 (i32.add (local.get $p) (local.get $i)))
      (call $load25519 (i32.add (local.get $q) (local.get $i)))
			local.get $b
		  call $sel25519
      (i32.add (local.get $p) (local.get $i)) call $store25519
      (i32.add (local.get $q) (local.get $i)) call $store25519

			(br_if 0 (i32.ne (i32.const 512)
				(local.tee $i (i32.add (local.get $i) (i32.const 128)))
			))
		)
	)

)
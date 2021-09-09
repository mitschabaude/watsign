(module
  ;; these functions operate on 16 x i64 vectors representing integers mod (2^255 - 19)
  ;; elements are the coefficients of 2^0, ..., 2^15

  (import "../load.wat" "load" (func $load25519 (param i32) (result i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64)))
  (import "../load.wat" "store" (func $store25519 (param i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i32)))

  (export "add" (func $add25519))
  (export "subtract" (func $subtract25519))

  (export "add_value" (func $add25519_value))
  (export "subtract_value" (func $subtract25519_value))

  (func $add25519_slow
    ;; out = a + b
    (param $out i32) (param $a i32) (param $b i32) ;; 16 * 8 (i64) = 128
    (local $i i32)
    
    ;; for (let i = 0; i < 128; i+=8) out[i] = a[i] + b[i];
    (local.set $i (i32.const 0))
    (loop
      (i32.add (local.get $out) (local.get $i))
      (i32.add (local.get $a) (local.get $i))
      i64.load
      (i32.add (local.get $b) (local.get $i))
      i64.load
      i64.add
      i64.store
      (br_if 0 (i32.ne (i32.const 128)
        (local.tee $i (i32.add (local.get $i) (i32.const 8)))
      ))
    )
  )

  (func $subtract25519_slow
    ;; out = a - b
    (param $out i32) (param $a i32) (param $b i32) ;; 16 * 8 (i64) = 128
    (local $i i32)
    
    ;; for (let i = 0; i < 128; i+=8) out[i] = a[i] - b[i];
    (local.set $i (i32.const 0))
    (loop
      (i32.add (local.get $out) (local.get $i))
      (i32.add (local.get $a) (local.get $i))
      i64.load
      (i32.add (local.get $b) (local.get $i))
      i64.load
      i64.sub
      i64.store
      (br_if 0 (i32.ne (i32.const 128)
        (local.tee $i (i32.add (local.get $i) (i32.const 8)))
      ))
    )
  )

  (func $add25519
    (param $out i32) (param $a i32) (param $b i32) ;; 16 * 8 (i64) = 128
    (call $load25519 (local.get $a))
    (call $load25519 (local.get $b))
    call $add25519_value
    (local.get $out)
    call $store25519
  )

  (func $subtract25519
    (param $out i32) (param $a i32) (param $b i32) ;; 16 * 8 (i64) = 128
    (call $load25519 (local.get $a))
    (call $load25519 (local.get $b))
    call $subtract25519_value
    (local.get $out)
    call $store25519
  )

  (func $add25519_value
    (param $p0 i64) (param $p1 i64) (param $p2 i64) (param $p3 i64)
    (param $p4 i64) (param $p5 i64) (param $p6 i64) (param $p7 i64)
    (param $p8 i64) (param $p9 i64) (param $pa i64) (param $pb i64)
    (param $pc i64) (param $pd i64) (param $pe i64) (param $pf i64)

    (param $q0 i64) (param $q1 i64) (param $q2 i64) (param $q3 i64)
    (param $q4 i64) (param $q5 i64) (param $q6 i64) (param $q7 i64)
    (param $q8 i64) (param $q9 i64) (param $qa i64) (param $qb i64)
    (param $qc i64) (param $qd i64) (param $qe i64) (param $qf i64)

    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)

    (i64.add (local.get $p0) (local.get $q0))
    (i64.add (local.get $p1) (local.get $q1))
    (i64.add (local.get $p2) (local.get $q2))
    (i64.add (local.get $p3) (local.get $q3))
    (i64.add (local.get $p4) (local.get $q4))
    (i64.add (local.get $p5) (local.get $q5))
    (i64.add (local.get $p6) (local.get $q6))
    (i64.add (local.get $p7) (local.get $q7))
    (i64.add (local.get $p8) (local.get $q8))
    (i64.add (local.get $p9) (local.get $q9))
    (i64.add (local.get $pa) (local.get $qa))
    (i64.add (local.get $pb) (local.get $qb))
    (i64.add (local.get $pc) (local.get $qc))
    (i64.add (local.get $pd) (local.get $qd))
    (i64.add (local.get $pe) (local.get $qe))
    (i64.add (local.get $pf) (local.get $qf))
  )

  (func $subtract25519_value
    (param $p0 i64) (param $p1 i64) (param $p2 i64) (param $p3 i64)
    (param $p4 i64) (param $p5 i64) (param $p6 i64) (param $p7 i64)
    (param $p8 i64) (param $p9 i64) (param $pa i64) (param $pb i64)
    (param $pc i64) (param $pd i64) (param $pe i64) (param $pf i64)

    (param $q0 i64) (param $q1 i64) (param $q2 i64) (param $q3 i64)
    (param $q4 i64) (param $q5 i64) (param $q6 i64) (param $q7 i64)
    (param $q8 i64) (param $q9 i64) (param $qa i64) (param $qb i64)
    (param $qc i64) (param $qd i64) (param $qe i64) (param $qf i64)

    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)

    (i64.sub (local.get $p0) (local.get $q0))
    (i64.sub (local.get $p1) (local.get $q1))
    (i64.sub (local.get $p2) (local.get $q2))
    (i64.sub (local.get $p3) (local.get $q3))
    (i64.sub (local.get $p4) (local.get $q4))
    (i64.sub (local.get $p5) (local.get $q5))
    (i64.sub (local.get $p6) (local.get $q6))
    (i64.sub (local.get $p7) (local.get $q7))
    (i64.sub (local.get $p8) (local.get $q8))
    (i64.sub (local.get $p9) (local.get $q9))
    (i64.sub (local.get $pa) (local.get $qa))
    (i64.sub (local.get $pb) (local.get $qb))
    (i64.sub (local.get $pc) (local.get $qc))
    (i64.sub (local.get $pd) (local.get $qd))
    (i64.sub (local.get $pe) (local.get $qe))
    (i64.sub (local.get $pf) (local.get $qf))
  )
)

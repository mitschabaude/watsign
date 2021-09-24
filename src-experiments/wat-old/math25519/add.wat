(module
  ;; these functions operate on 16 x i64 vectors representing integers mod (2^255 - 19)
  ;; elements are the coefficients of 2^0, ..., 2^15

  (export "add" (func $add25519))
  (export "subtract" (func $subtract25519))

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

  (func $add25519 (param $out i32) (param $a i32) (param $b i32) ;; 16 * 8 (i64) = 128
    (i64.store offset=0 (local.get $out) (i64.add (i64.load offset=0 (local.get $a)) (i64.load offset=0 (local.get $b))))
    (i64.store offset=8 (local.get $out) (i64.add (i64.load offset=8 (local.get $a)) (i64.load offset=8 (local.get $b))))
    (i64.store offset=16 (local.get $out) (i64.add (i64.load offset=16 (local.get $a)) (i64.load offset=16 (local.get $b))))
    (i64.store offset=24 (local.get $out) (i64.add (i64.load offset=24 (local.get $a)) (i64.load offset=24 (local.get $b))))
    (i64.store offset=32 (local.get $out) (i64.add (i64.load offset=32 (local.get $a)) (i64.load offset=32 (local.get $b))))
    (i64.store offset=40 (local.get $out) (i64.add (i64.load offset=40 (local.get $a)) (i64.load offset=40 (local.get $b))))
    (i64.store offset=48 (local.get $out) (i64.add (i64.load offset=48 (local.get $a)) (i64.load offset=48 (local.get $b))))
    (i64.store offset=56 (local.get $out) (i64.add (i64.load offset=56 (local.get $a)) (i64.load offset=56 (local.get $b))))
    (i64.store offset=64 (local.get $out) (i64.add (i64.load offset=64 (local.get $a)) (i64.load offset=64 (local.get $b))))
    (i64.store offset=72 (local.get $out) (i64.add (i64.load offset=72 (local.get $a)) (i64.load offset=72 (local.get $b))))
    (i64.store offset=80 (local.get $out) (i64.add (i64.load offset=80 (local.get $a)) (i64.load offset=80 (local.get $b))))
    (i64.store offset=88 (local.get $out) (i64.add (i64.load offset=88 (local.get $a)) (i64.load offset=88 (local.get $b))))
    (i64.store offset=96 (local.get $out) (i64.add (i64.load offset=96 (local.get $a)) (i64.load offset=96 (local.get $b))))
    (i64.store offset=104 (local.get $out) (i64.add (i64.load offset=104 (local.get $a)) (i64.load offset=104 (local.get $b))))
    (i64.store offset=112 (local.get $out) (i64.add (i64.load offset=112 (local.get $a)) (i64.load offset=112 (local.get $b))))
    (i64.store offset=120 (local.get $out) (i64.add (i64.load offset=120 (local.get $a)) (i64.load offset=120 (local.get $b))))
  )

  (func $subtract25519 (param $out i32) (param $a i32) (param $b i32) ;; 16 * 8 (i64) = 128
    (i64.store offset=0 (local.get $out) (i64.sub (i64.load offset=0 (local.get $a)) (i64.load offset=0 (local.get $b))))
    (i64.store offset=8 (local.get $out) (i64.sub (i64.load offset=8 (local.get $a)) (i64.load offset=8 (local.get $b))))
    (i64.store offset=16 (local.get $out) (i64.sub (i64.load offset=16 (local.get $a)) (i64.load offset=16 (local.get $b))))
    (i64.store offset=24 (local.get $out) (i64.sub (i64.load offset=24 (local.get $a)) (i64.load offset=24 (local.get $b))))
    (i64.store offset=32 (local.get $out) (i64.sub (i64.load offset=32 (local.get $a)) (i64.load offset=32 (local.get $b))))
    (i64.store offset=40 (local.get $out) (i64.sub (i64.load offset=40 (local.get $a)) (i64.load offset=40 (local.get $b))))
    (i64.store offset=48 (local.get $out) (i64.sub (i64.load offset=48 (local.get $a)) (i64.load offset=48 (local.get $b))))
    (i64.store offset=56 (local.get $out) (i64.sub (i64.load offset=56 (local.get $a)) (i64.load offset=56 (local.get $b))))
    (i64.store offset=64 (local.get $out) (i64.sub (i64.load offset=64 (local.get $a)) (i64.load offset=64 (local.get $b))))
    (i64.store offset=72 (local.get $out) (i64.sub (i64.load offset=72 (local.get $a)) (i64.load offset=72 (local.get $b))))
    (i64.store offset=80 (local.get $out) (i64.sub (i64.load offset=80 (local.get $a)) (i64.load offset=80 (local.get $b))))
    (i64.store offset=88 (local.get $out) (i64.sub (i64.load offset=88 (local.get $a)) (i64.load offset=88 (local.get $b))))
    (i64.store offset=96 (local.get $out) (i64.sub (i64.load offset=96 (local.get $a)) (i64.load offset=96 (local.get $b))))
    (i64.store offset=104 (local.get $out) (i64.sub (i64.load offset=104 (local.get $a)) (i64.load offset=104 (local.get $b))))
    (i64.store offset=112 (local.get $out) (i64.sub (i64.load offset=112 (local.get $a)) (i64.load offset=112 (local.get $b))))
    (i64.store offset=120 (local.get $out) (i64.sub (i64.load offset=120 (local.get $a)) (i64.load offset=120 (local.get $b))))
  )
)

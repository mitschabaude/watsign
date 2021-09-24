(module
  (export "load" (func $load))
  (export "load4" (func $load4))
  (export "store" (func $store))
  (export "store4" (func $store4))

  (func $load
    (param $i i32) ;; memory index

    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
  
    (i64.load offset=0 (local.get $i))
    (i64.load offset=8 (local.get $i))
    (i64.load offset=16 (local.get $i))
    (i64.load offset=24 (local.get $i))
    (i64.load offset=32 (local.get $i))
    (i64.load offset=40 (local.get $i))
    (i64.load offset=48 (local.get $i))
    (i64.load offset=56 (local.get $i))
    (i64.load offset=64 (local.get $i))
    (i64.load offset=72 (local.get $i))
    (i64.load offset=80 (local.get $i))
    (i64.load offset=88 (local.get $i))
    (i64.load offset=96 (local.get $i))
    (i64.load offset=104 (local.get $i))
    (i64.load offset=112 (local.get $i))
    (i64.load offset=120 (local.get $i))
  )

  (func $store
    (param i64) (param i64) (param i64) (param i64)
    (param i64) (param i64) (param i64) (param i64)
    (param i64) (param i64) (param i64) (param i64)
    (param i64) (param i64) (param i64) (param i64)

    (param $i i32) ;; memory index, at the end to facilitate usage
  
    (i64.store offset=0 (local.get $i) (local.get 0))
    (i64.store offset=8 (local.get $i) (local.get 1))
    (i64.store offset=16 (local.get $i) (local.get 2))
    (i64.store offset=24 (local.get $i) (local.get 3))
    (i64.store offset=32 (local.get $i) (local.get 4))
    (i64.store offset=40 (local.get $i) (local.get 5))
    (i64.store offset=48 (local.get $i) (local.get 6))
    (i64.store offset=56 (local.get $i) (local.get 7))
    (i64.store offset=64 (local.get $i) (local.get 8))
    (i64.store offset=72 (local.get $i) (local.get 9))
    (i64.store offset=80 (local.get $i) (local.get 10))
    (i64.store offset=88 (local.get $i) (local.get 11))
    (i64.store offset=96 (local.get $i) (local.get 12))
    (i64.store offset=104 (local.get $i) (local.get 13))
    (i64.store offset=112 (local.get $i) (local.get 14))
    (i64.store offset=120 (local.get $i) (local.get 15))
  )

  (func $load4
    (param $i i32)

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

    (call $load (i32.add (local.get $i) (i32.const 000)))
		(call $load (i32.add (local.get $i) (i32.const 128)))
		(call $load (i32.add (local.get $i) (i32.const 256)))
		(call $load (i32.add (local.get $i) (i32.const 384)))
  )

  (func $store4
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

    (param $i i32) ;; memory index, at the end to facilitate usage
  
    local.get $p00 local.get $p01 local.get $p02 local.get $p03
    local.get $p04 local.get $p05 local.get $p06 local.get $p07
    local.get $p08 local.get $p09 local.get $p0a local.get $p0b
    local.get $p0c local.get $p0d local.get $p0e local.get $p0f
    local.get $i
    call $store

    local.get $p10 local.get $p11 local.get $p12 local.get $p13
    local.get $p14 local.get $p15 local.get $p16 local.get $p17
    local.get $p18 local.get $p19 local.get $p1a local.get $p1b
    local.get $p1c local.get $p1d local.get $p1e local.get $p1f
    (i32.add (local.get $i) (i32.const 128))
    call $store

    local.get $p20 local.get $p21 local.get $p22 local.get $p23
    local.get $p24 local.get $p25 local.get $p26 local.get $p27
    local.get $p28 local.get $p29 local.get $p2a local.get $p2b
    local.get $p2c local.get $p2d local.get $p2e local.get $p2f
    (i32.add (local.get $i) (i32.const 256))
    call $store

    local.get $p30 local.get $p31 local.get $p32 local.get $p33
    local.get $p34 local.get $p35 local.get $p36 local.get $p37
    local.get $p38 local.get $p39 local.get $p3a local.get $p3b
    local.get $p3c local.get $p3d local.get $p3e local.get $p3f
    (i32.add (local.get $i) (i32.const 384))
    call $store
  )
)
(module
  (export "select" (func $sel25519))

	(func $sel25519_slow
		(param $p i32) (param $q i32) (; 16 x i64 ;)
		(param $b i32) (; boolean ;)
		
		(local $i i32)
		(local $c i64) (local $t i64)
		(local $pi i64) (local $qi i64)

		;; let c = ~(b - 1); // == -b == 0 - b
		i64.const 0
		local.get $b
		i64.extend_i32_u
		i64.sub
		local.set $c
		
		;; for (i = 0; i < 16*8; i+=8)
		(local.set $i (i32.const 0))
    (loop
			;; let t = c & (p[i] ^ q[i]);
			(i32.add (local.get $p) (local.get $i))
			i64.load
			local.tee $pi
			(i32.add (local.get $q) (local.get $i))
			i64.load
			local.tee $qi
			i64.xor
			local.get $c
			i64.and
			local.set $t

			;; p[i] ^= t;
			(i32.add (local.get $p) (local.get $i))
			local.get $pi
			local.get $t
			i64.xor
			i64.store

			;; q[i] ^= t;
			(i32.add (local.get $q) (local.get $i))
			local.get $qi
			local.get $t
			i64.xor
			i64.store

      (br_if 0 (i32.ne (i32.const 128)
        (local.tee $i (i32.add (local.get $i) (i32.const 8)))
      ))
    )
	)

	(func $sel25519
		(param $p i32) (param $q i32) (; 16 x i64 ;)
		(param $b i32) (; boolean ;)

		(local $c i64) (local $t i64)
		(local $pi i64) (local $qi i64)

		;; let c = ~(b - 1); // == -b == 0 - b
		(local.set $c (i64.sub (i64.const 0) (i64.extend_i32_u (local.get $b))))

		;; UNROLLED		
		;; let t = c & (p[i] ^ q[i]);
		;; p[i] ^= t;
		;; q[i] ^= t;		
		(local.tee $pi (i64.load offset=0 (local.get $p)))
		(local.tee $qi (i64.load offset=0 (local.get $q)))
		i64.xor local.get $c i64.and local.set $t
		(i64.store offset=0 (local.get $p) (i64.xor (local.get $pi) (local.get $t)))
		(i64.store offset=0 (local.get $q) (i64.xor (local.get $qi) (local.get $t)))

		(local.tee $pi (i64.load offset=8 (local.get $p)))
		(local.tee $qi (i64.load offset=8 (local.get $q)))
		i64.xor local.get $c i64.and local.set $t
		(i64.store offset=8 (local.get $p) (i64.xor (local.get $pi) (local.get $t)))
		(i64.store offset=8 (local.get $q) (i64.xor (local.get $qi) (local.get $t)))

		(local.tee $pi (i64.load offset=16 (local.get $p)))
		(local.tee $qi (i64.load offset=16 (local.get $q)))
		i64.xor local.get $c i64.and local.set $t
		(i64.store offset=16 (local.get $p) (i64.xor (local.get $pi) (local.get $t)))
		(i64.store offset=16 (local.get $q) (i64.xor (local.get $qi) (local.get $t)))

		(local.tee $pi (i64.load offset=24 (local.get $p)))
		(local.tee $qi (i64.load offset=24 (local.get $q)))
		i64.xor local.get $c i64.and local.set $t
		(i64.store offset=24 (local.get $p) (i64.xor (local.get $pi) (local.get $t)))
		(i64.store offset=24 (local.get $q) (i64.xor (local.get $qi) (local.get $t)))

		(local.tee $pi (i64.load offset=32 (local.get $p)))
		(local.tee $qi (i64.load offset=32 (local.get $q)))
		i64.xor local.get $c i64.and local.set $t
		(i64.store offset=32 (local.get $p) (i64.xor (local.get $pi) (local.get $t)))
		(i64.store offset=32 (local.get $q) (i64.xor (local.get $qi) (local.get $t)))

		(local.tee $pi (i64.load offset=40 (local.get $p)))
		(local.tee $qi (i64.load offset=40 (local.get $q)))
		i64.xor local.get $c i64.and local.set $t
		(i64.store offset=40 (local.get $p) (i64.xor (local.get $pi) (local.get $t)))
		(i64.store offset=40 (local.get $q) (i64.xor (local.get $qi) (local.get $t)))

		(local.tee $pi (i64.load offset=48 (local.get $p)))
		(local.tee $qi (i64.load offset=48 (local.get $q)))
		i64.xor local.get $c i64.and local.set $t
		(i64.store offset=48 (local.get $p) (i64.xor (local.get $pi) (local.get $t)))
		(i64.store offset=48 (local.get $q) (i64.xor (local.get $qi) (local.get $t)))

		(local.tee $pi (i64.load offset=56 (local.get $p)))
		(local.tee $qi (i64.load offset=56 (local.get $q)))
		i64.xor local.get $c i64.and local.set $t
		(i64.store offset=56 (local.get $p) (i64.xor (local.get $pi) (local.get $t)))
		(i64.store offset=56 (local.get $q) (i64.xor (local.get $qi) (local.get $t)))

		(local.tee $pi (i64.load offset=64 (local.get $p)))
		(local.tee $qi (i64.load offset=64 (local.get $q)))
		i64.xor local.get $c i64.and local.set $t
		(i64.store offset=64 (local.get $p) (i64.xor (local.get $pi) (local.get $t)))
		(i64.store offset=64 (local.get $q) (i64.xor (local.get $qi) (local.get $t)))

		(local.tee $pi (i64.load offset=72 (local.get $p)))
		(local.tee $qi (i64.load offset=72 (local.get $q)))
		i64.xor local.get $c i64.and local.set $t
		(i64.store offset=72 (local.get $p) (i64.xor (local.get $pi) (local.get $t)))
		(i64.store offset=72 (local.get $q) (i64.xor (local.get $qi) (local.get $t)))

		(local.tee $pi (i64.load offset=80 (local.get $p)))
		(local.tee $qi (i64.load offset=80 (local.get $q)))
		i64.xor local.get $c i64.and local.set $t
		(i64.store offset=80 (local.get $p) (i64.xor (local.get $pi) (local.get $t)))
		(i64.store offset=80 (local.get $q) (i64.xor (local.get $qi) (local.get $t)))

		(local.tee $pi (i64.load offset=88 (local.get $p)))
		(local.tee $qi (i64.load offset=88 (local.get $q)))
		i64.xor local.get $c i64.and local.set $t
		(i64.store offset=88 (local.get $p) (i64.xor (local.get $pi) (local.get $t)))
		(i64.store offset=88 (local.get $q) (i64.xor (local.get $qi) (local.get $t)))

		(local.tee $pi (i64.load offset=96 (local.get $p)))
		(local.tee $qi (i64.load offset=96 (local.get $q)))
		i64.xor local.get $c i64.and local.set $t
		(i64.store offset=96 (local.get $p) (i64.xor (local.get $pi) (local.get $t)))
		(i64.store offset=96 (local.get $q) (i64.xor (local.get $qi) (local.get $t)))

		(local.tee $pi (i64.load offset=104 (local.get $p)))
		(local.tee $qi (i64.load offset=104 (local.get $q)))
		i64.xor local.get $c i64.and local.set $t
		(i64.store offset=104 (local.get $p) (i64.xor (local.get $pi) (local.get $t)))
		(i64.store offset=104 (local.get $q) (i64.xor (local.get $qi) (local.get $t)))

		(local.tee $pi (i64.load offset=112 (local.get $p)))
		(local.tee $qi (i64.load offset=112 (local.get $q)))
		i64.xor local.get $c i64.and local.set $t
		(i64.store offset=112 (local.get $p) (i64.xor (local.get $pi) (local.get $t)))
		(i64.store offset=112 (local.get $q) (i64.xor (local.get $qi) (local.get $t)))

		(local.tee $pi (i64.load offset=120 (local.get $p)))
		(local.tee $qi (i64.load offset=120 (local.get $q)))
		i64.xor local.get $c i64.and local.set $t
		(i64.store offset=120 (local.get $p) (i64.xor (local.get $pi) (local.get $t)))
		(i64.store offset=120 (local.get $q) (i64.xor (local.get $qi) (local.get $t)))
	)

)
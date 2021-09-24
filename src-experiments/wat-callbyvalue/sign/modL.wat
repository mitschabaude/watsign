(module
	(import "../../../node_modules/esbuild-plugin-wat/lib/return.wat" "return_bytes" (func $return_bytes (param i32) (param i32) (result i32)))
  (import "../bytes_utils.wat" "i8_to_i64" (func $i8_to_i64 (param i32 i32 i32)))
	(import "../bytes_utils.wat" "alloc_zero" (func $alloc_zero (param i32) (result i32)))

	(import "./globals.wat" "L" (global $L i32))

  (export "reduce" (func $reduce))
  (export "modL" (func $modL))

	(func $reduce
		(param $x i32) ;; 64 x i8, ~= sha512 output interpreted as integer 0 <= n < 2^512
		(param $_xLength i32)
		(result i32) ;; 32 x i8, ~= x mod L, where L < 2^256 is the EC group order

		(local $X i32)

		(call $alloc_zero (i32.const 512))
		local.tee $X
		local.get $x
		i32.const 64
		call $i8_to_i64
		(call $modL (local.get $x) (local.get $X))
		
		local.get $x
		i32.const 32
		call $return_bytes
	)

	(func $modL
		(param $out i32) ;; 32 x 1 (i8), output
		(param $x i32) ;; 64 x 8 (i64), input, gets modified (not needed afterwards)

		(local $carry i64)
		(local $i i32) (local $j i32) (local $k i32)
		(local $xi i64) (local $xj i64)

		;; 	for (i = 63*8; i >= 32*8; i-=8)
		(local.set $i (i32.const 504))
		(loop
			;; carry = 0;
			(local.set $carry (i64.const 0))
			;; xi = x[i]
			(i32.add (local.get $x) (local.get $i))
			i64.load
			local.set $xi

			;; for (j = i - 32*8, k = i - 12*8; j < k; j+=8)
			(local.set $j (i32.sub (local.get $i) (i32.const 256)))
			(local.set $k (i32.sub (local.get $i) (i32.const 96)))
			(loop
				;; x[j] += carry - 16 * x[i] * L[j - (i - 32*8)];
				(i32.add (local.get $x) (local.get $j))
				i64.load
				local.tee $xj
				local.get $carry

				i64.const 16
				local.get $xi
				i64.mul
				(i32.add (i32.sub (local.get $j) (local.get $i)) (i32.const 256))
				global.get $L
				i32.add
				i64.load
				i64.mul

				i64.sub
				i64.add
				local.tee $xj

				;; carry = (x[j] + 128) >> 8;
				i64.const 128
				i64.add
				i64.const 8
				i64.shr_s
				local.set $carry

				;; x[j] -= carry * 256;
				local.get $xj
				local.get $carry
				i64.const 256
				i64.mul
				i64.sub
				local.set $xj

				(i32.add (local.get $x) (local.get $j))
				local.get $xj
				i64.store
				(br_if 0 (i32.ne (local.get $k)
					(local.tee $j (i32.add (local.get $j) (i32.const 8)))
				))
			)
			;; x[j] += carry;
			(i32.add (local.get $x) (local.get $j))
			(i32.add (local.get $x) (local.get $j))
			i64.load
			local.get $carry
			i64.add
			i64.store
			;; x[i] = 0;
			(i32.add (local.get $x) (local.get $i))
			i64.const 0
			i64.store
		
			(br_if 0 (i32.ne (i32.const 248)
				(local.tee $i (i32.sub (local.get $i) (i32.const 8)))
			))
		)
		;; 	carry = 0;
		(local.set $carry (i64.const 0))
		;; xi = (x[31*8] >> 4)
		(i64.load offset=248 (local.get $x))
		i64.const 4
		i64.shr_s
		local.set $xi
		;; for (j = 0; j < 32*8; j+=8)
		(local.set $j (i32.const 0))
		(loop
			;; xj = x[j]
			(i32.add (local.get $x) (local.get $j))
			i64.load
			local.tee $xj
			;; x[j] += carry - (x[31] >> 4) * L[j];
			local.get $carry
			local.get $xi
			(i32.add (global.get $L) (local.get $j))
			i64.load
			i64.mul
			i64.sub
			i64.add
			local.tee $xj

			;; carry = x[j] >> 8;
			i64.const 8
			i64.shr_s
			local.set $carry

			;; x[j] &= 255;
			local.get $xj
			i64.const 255
			i64.and
			local.set $xj

			(i32.add (local.get $x) (local.get $j))
			local.get $xj
			i64.store

			(br_if 0 (i32.ne (i32.const 256)
				(local.tee $j (i32.add (local.get $j) (i32.const 8)))
			))
		)
		;; 	for (j = 0; j < 32*8; j+=8) x[j] -= carry * L[j];
		(local.set $j (i32.const 0))
		(loop
			(i32.add (local.get $x) (local.get $j))
			(i32.add (local.get $x) (local.get $j))
			i64.load
			local.get $carry
			(i32.add (global.get $L) (local.get $j))
			i64.load
			i64.mul
			i64.sub
			i64.store
			(br_if 0 (i32.ne (i32.const 256)
				(local.tee $j (i32.add (local.get $j) (i32.const 8)))
			))
		)
		;; 	for (i = 0; i < 32*8; i+=8) {
		;; 		x[i+1*8] += x[i] >> 8;
		;; 		r[i >>> 3] = x[i] & 255;
		;; 	}
		(local.set $i (i32.const 0))
		(loop
			(i32.add (local.get $x) (local.get $i))
			i64.load
			local.set $xi
			
			(i32.add (local.get $x) (local.get $i))
			(i32.add (local.get $x) (local.get $i))
			i64.load offset=8
			local.get $xi
			i64.const 8
			i64.shr_s
			i64.add
			i64.store offset=8

			(i32.add (local.get $out) (i32.shr_u (local.get $i) (i32.const 3)))
			local.get $xi
			i64.const 255
			i64.and
			i64.store8
			
			(br_if 0 (i32.ne (i32.const 256)
				(local.tee $i (i32.add (local.get $i) (i32.const 8)))
			))
		)
	
	)

)
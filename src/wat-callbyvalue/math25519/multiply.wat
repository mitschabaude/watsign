(module
	;; these functions operate on 16 x i64 vectors representing integers mod (2^255 - 19)
  ;; elements are the coefficients of 2^0, ..., 2^15
	(import "window" "console.log" (func $log (param i64)))
	(import "window" "console.log" (func $log4 (param i64 i64 i64 i64)))
	(import "window" "console.log" (func $log16 (param i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64)))
	(import "../bytes_utils.wat" "alloc_zero" (func $alloc_zero (param i32) (result i32)))

  (import "../load.wat" "load" (func $load25519 (param i32) (result i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64)))
  (import "../load.wat" "store" (func $store25519 (param i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i32)))

	(export "multiply" (func $mul25519))
  (export "square" (func $squ25519))

	(export "multiply_value" (func $mul25519_value))
  (export "square_value" (func $squ25519_value))

	(export "carry" (func $car25519))

	(func $squ25519 (param $out i32) (param $a i32)
		(call $mul25519 (local.get $out) (local.get $a) (local.get $a))
	)

	(func $squ25519_value
		(param $a00 i64) (param $a01 i64) (param $a02 i64) (param $a03 i64)
		(param $a04 i64) (param $a05 i64) (param $a06 i64) (param $a07 i64)
		(param $a08 i64) (param $a09 i64) (param $a10 i64) (param $a11 i64)
		(param $a12 i64) (param $a13 i64) (param $a14 i64) (param $a15 i64)

		(result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)

		(local.get $a00) (local.get $a01) (local.get $a02) (local.get $a03)
		(local.get $a04) (local.get $a05) (local.get $a06) (local.get $a07)
		(local.get $a08) (local.get $a09) (local.get $a10) (local.get $a11)
		(local.get $a12) (local.get $a13) (local.get $a14) (local.get $a15)

		(local.get $a00) (local.get $a01) (local.get $a02) (local.get $a03)
		(local.get $a04) (local.get $a05) (local.get $a06) (local.get $a07)
		(local.get $a08) (local.get $a09) (local.get $a10) (local.get $a11)
		(local.get $a12) (local.get $a13) (local.get $a14) (local.get $a15)

		call $mul25519_value
	)

	;; multiplication is the hottest path of the entire library
	;; therefore we made a faster version with loops unrolled, see below
	(func $mul25519_slow (param $out i32) (param $a i32) (param $b i32)
		(local $i i32) (local $j i32) (local $t i32) (local $ai i64)

		;; let t = new Float64Array(31);
		;; for (i = 0; i < 31; i++) t[i] = 0;
		(call $alloc_zero (i32.const 248 (; 31 * 8 ;)))
		local.set $t

		;; for (i = 0; i < 128; i+=8)
    (local.set $i (i32.const 0))
    (loop
			;; for (i = 0; i < 128; i+=8)
			(local.set $j (i32.const 0))
			;; let ai = a[i]
			(i32.add (local.get $a) (local.get $i))
			i64.load
			local.set $ai
			(loop
				;; t[i + j] += ai * b[j];
				(i32.add (local.get $t) (i32.add (local.get $i) (local.get $j)))
				
				(i32.add (local.get $t) (i32.add (local.get $i) (local.get $j)))
				i64.load

				local.get $ai				
				(i32.add (local.get $b) (local.get $j))
				i64.load
				i64.mul

				i64.add

				i64.store

				(br_if 0 (i32.ne (i32.const 128)
        	(local.tee $j (i32.add (local.get $j) (i32.const 8)))
      	))
			)
      (br_if 0 (i32.ne (i32.const 128)
        (local.tee $i (i32.add (local.get $i) (i32.const 8)))
      ))
    )
		;; for (i = 0; i < 120; i+=8)
		(local.set $i (i32.const 0))
		(loop
			;; t[i] += 38 * t[i + 16*8];
			(i32.add (local.get $t) (local.get $i))
			(i64.load (i32.add (local.get $t) (local.get $i)))
			i64.const 38
			(i64.load offset=128 (i32.add (local.get $t) (local.get $i)))
			i64.mul
			i64.add
			i64.store
			(br_if 0 (i32.ne (i32.const 120)
        (local.tee $i (i32.add (local.get $i) (i32.const 8)))
      ))
		)
		;; for (i = 0; i < 128; i+=8) out[i] = t[i];
		(local.set $i (i32.const 0))
		(loop
			(i32.add (local.get $out) (local.get $i))
			(i32.add (local.get $t) (local.get $i))
			i64.load
			i64.store
			(br_if 0 (i32.ne (i32.const 128)
        (local.tee $i (i32.add (local.get $i) (i32.const 8)))
      ))
		)
		;; car25519(out);
		;; car25519(out);
		(call $car25519 (local.get $out))
		(call $car25519 (local.get $out))
	)

	(func $car25519 (param $out i32) ;; 16 * 8 (i64) = 128
		(local $c i64)
		(local $v i64)
		(local $i i32)

		;; c = 1;
    (local.set $c (i64.const 1))

    ;; for (i = 0; i < 128; i+=8)
    (local.set $i (i32.const 0))
    (loop
			;; v = o[i] + c + 65535;
			(i32.add (local.get $out) (local.get $i))
      i64.load
			local.get $c
			i64.add
			i64.const 65535
			i64.add
			local.set $v

			;; c = Math.floor(v / 65536);
			local.get $v
			i64.const 16
			i64.shr_s
			local.set $c

			;; o[i] = v - c * 65536;
			(i32.add (local.get $out) (local.get $i))
			local.get $v
			local.get $c
			i64.const 65536
			i64.mul
			i64.sub
      i64.store

      (br_if 0 (i32.ne (i32.const 128)
        (local.tee $i (i32.add (local.get $i) (i32.const 8)))
      ))
    )
		;; o[0] += c - 1 + 37 * (c - 1);
		local.get $out
		(i64.load (local.get $out))
		(i64.sub (local.get $c) (i64.const 1))
		i64.const 37
		(i64.sub (local.get $c) (i64.const 1))
		i64.mul
		i64.add
		i64.add
		i64.store
	)

	(func $mul25519
    (param $out i32) (param $a i32) (param $b i32) ;; 16 * 8 (i64) = 128
    (call $load25519 (local.get $a))
    (call $load25519 (local.get $b))
    call $mul25519_value
    local.get $out
		call $store25519
  )

	(func $mul25519_value
		(param $a00 i64) (param $a01 i64) (param $a02 i64) (param $a03 i64)
		(param $a04 i64) (param $a05 i64) (param $a06 i64) (param $a07 i64)
		(param $a08 i64) (param $a09 i64) (param $a10 i64) (param $a11 i64)
		(param $a12 i64) (param $a13 i64) (param $a14 i64) (param $a15 i64)

		(param $b00 i64) (param $b01 i64) (param $b02 i64) (param $b03 i64)
		(param $b04 i64) (param $b05 i64) (param $b06 i64) (param $b07 i64)
		(param $b08 i64) (param $b09 i64) (param $b10 i64) (param $b11 i64)
		(param $b12 i64) (param $b13 i64) (param $b14 i64) (param $b15 i64)

		(result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)

		(local $o00 i64) (local $o01 i64) (local $o02 i64) (local $o03 i64)
		(local $o04 i64) (local $o05 i64) (local $o06 i64) (local $o07 i64)
		(local $o08 i64) (local $o09 i64) (local $o10 i64) (local $o11 i64)
		(local $o12 i64) (local $o13 i64) (local $o14 i64) (local $o15 i64)

		(local $c i64) (local $v i64)

		;; UNROLLED
		;; for (i = 0; i < 16; i++) {
		;; 	 for (i = 0; i < 16; i++) t[i + j] += a[i] * b[j];
		;; }
		;; for (i = 0; i < 15; i++) t[i] += 38 * t[i + 16*8];
		;; for (i = 0; i < 128; i+=8) out[i] = t[i];
		;; car25519(out);

		(local.set $c (i64.const 1))

		(i64.mul (local.get $a00) (local.get $b00)) ;; t00
		(i64.mul (local.get $a15) (local.get $b01)) ;; t16
		(i64.mul (local.get $a14) (local.get $b02))
		(i64.mul (local.get $a13) (local.get $b03))
		(i64.mul (local.get $a12) (local.get $b04))
		(i64.mul (local.get $a11) (local.get $b05))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a10) (local.get $b06))
		(i64.mul (local.get $a09) (local.get $b07))
		(i64.mul (local.get $a08) (local.get $b08))
		(i64.mul (local.get $a07) (local.get $b09))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a06) (local.get $b10))
		(i64.mul (local.get $a05) (local.get $b11))
		(i64.mul (local.get $a04) (local.get $b12))
		(i64.mul (local.get $a03) (local.get $b13))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a02) (local.get $b14))
		(i64.mul (local.get $a01) (local.get $b15))
		i64.add i64.add
		i64.const 38 i64.mul i64.add
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o00

		(i64.mul (local.get $a01) (local.get $b00)) ;; t01
		(i64.mul (local.get $a00) (local.get $b01))
		i64.add
		(i64.mul (local.get $a15) (local.get $b02)) ;; t17
		(i64.mul (local.get $a14) (local.get $b03))
		(i64.mul (local.get $a13) (local.get $b04))
		(i64.mul (local.get $a12) (local.get $b05))
		(i64.mul (local.get $a11) (local.get $b06))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a10) (local.get $b07))
		(i64.mul (local.get $a09) (local.get $b08))
		(i64.mul (local.get $a08) (local.get $b09))
		(i64.mul (local.get $a07) (local.get $b10))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a06) (local.get $b11))
		(i64.mul (local.get $a05) (local.get $b12))
		(i64.mul (local.get $a04) (local.get $b13))
		(i64.mul (local.get $a03) (local.get $b14))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a02) (local.get $b15))
		i64.add
		i64.const 38 i64.mul i64.add
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o01

		(i64.mul (local.get $a02) (local.get $b00)) ;; t02
		(i64.mul (local.get $a01) (local.get $b01))
		(i64.mul (local.get $a00) (local.get $b02))
		i64.add i64.add
		(i64.mul (local.get $a15) (local.get $b03)) ;; t18
		(i64.mul (local.get $a14) (local.get $b04))
		(i64.mul (local.get $a13) (local.get $b05))
		(i64.mul (local.get $a12) (local.get $b06))
		(i64.mul (local.get $a11) (local.get $b07))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a10) (local.get $b08))
		(i64.mul (local.get $a09) (local.get $b09))
		(i64.mul (local.get $a08) (local.get $b10))
		(i64.mul (local.get $a07) (local.get $b11))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a06) (local.get $b12))
		(i64.mul (local.get $a05) (local.get $b13))
		(i64.mul (local.get $a04) (local.get $b14))
		(i64.mul (local.get $a03) (local.get $b15))
		i64.add i64.add i64.add i64.add
		i64.const 38 i64.mul i64.add
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o02

		(i64.mul (local.get $a03) (local.get $b00)) ;; t03
		(i64.mul (local.get $a02) (local.get $b01))
		(i64.mul (local.get $a01) (local.get $b02))
		(i64.mul (local.get $a00) (local.get $b03))
		i64.add i64.add i64.add
		(i64.mul (local.get $a15) (local.get $b04)) ;; t19
		(i64.mul (local.get $a14) (local.get $b05))
		(i64.mul (local.get $a13) (local.get $b06))
		(i64.mul (local.get $a12) (local.get $b07))
		(i64.mul (local.get $a11) (local.get $b08))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a10) (local.get $b09))
		(i64.mul (local.get $a09) (local.get $b10))
		(i64.mul (local.get $a08) (local.get $b11))
		(i64.mul (local.get $a07) (local.get $b12))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a06) (local.get $b13))
		(i64.mul (local.get $a05) (local.get $b14))
		(i64.mul (local.get $a04) (local.get $b15))
		i64.add i64.add i64.add		
		i64.const 38 i64.mul i64.add
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o03

		(i64.mul (local.get $a04) (local.get $b00)) ;; t04
		(i64.mul (local.get $a03) (local.get $b01))
		(i64.mul (local.get $a02) (local.get $b02))
		(i64.mul (local.get $a01) (local.get $b03))
		(i64.mul (local.get $a00) (local.get $b04))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a15) (local.get $b05)) ;; t20
		(i64.mul (local.get $a14) (local.get $b06))
		(i64.mul (local.get $a13) (local.get $b07))
		(i64.mul (local.get $a12) (local.get $b08))
		(i64.mul (local.get $a11) (local.get $b09))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a10) (local.get $b10))
		(i64.mul (local.get $a09) (local.get $b11))
		(i64.mul (local.get $a08) (local.get $b12))
		(i64.mul (local.get $a07) (local.get $b13))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a06) (local.get $b14))
		(i64.mul (local.get $a05) (local.get $b15))
		i64.add i64.add
		i64.const 38 i64.mul i64.add
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o04

		(i64.mul (local.get $a05) (local.get $b00)) ;; t05
		(i64.mul (local.get $a04) (local.get $b01))
		(i64.mul (local.get $a03) (local.get $b02))
		(i64.mul (local.get $a02) (local.get $b03))
		(i64.mul (local.get $a01) (local.get $b04))
		(i64.mul (local.get $a00) (local.get $b05))
		i64.add i64.add i64.add i64.add
		i64.add
		(i64.mul (local.get $a15) (local.get $b06)) ;; t21
		(i64.mul (local.get $a14) (local.get $b07))
		(i64.mul (local.get $a13) (local.get $b08))
		(i64.mul (local.get $a12) (local.get $b09))
		(i64.mul (local.get $a11) (local.get $b10))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a10) (local.get $b11))
		(i64.mul (local.get $a09) (local.get $b12))
		(i64.mul (local.get $a08) (local.get $b13))
		(i64.mul (local.get $a07) (local.get $b14))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a06) (local.get $b15))
		i64.add
		i64.const 38 i64.mul i64.add
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o05

		(i64.mul (local.get $a06) (local.get $b00)) ;; t06
		(i64.mul (local.get $a05) (local.get $b01))
		(i64.mul (local.get $a04) (local.get $b02))
		(i64.mul (local.get $a03) (local.get $b03))
		(i64.mul (local.get $a02) (local.get $b04))
		(i64.mul (local.get $a01) (local.get $b05))
		(i64.mul (local.get $a00) (local.get $b06))
		i64.add i64.add i64.add i64.add
		i64.add i64.add
		(i64.mul (local.get $a15) (local.get $b07)) ;; t22
		(i64.mul (local.get $a14) (local.get $b08))
		(i64.mul (local.get $a13) (local.get $b09))
		(i64.mul (local.get $a12) (local.get $b10))
		(i64.mul (local.get $a11) (local.get $b11))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a10) (local.get $b12))
		(i64.mul (local.get $a09) (local.get $b13))
		(i64.mul (local.get $a08) (local.get $b14))
		(i64.mul (local.get $a07) (local.get $b15))
		i64.add i64.add i64.add i64.add
		i64.const 38 i64.mul i64.add
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o06

		(i64.mul (local.get $a07) (local.get $b00)) ;; t07
		(i64.mul (local.get $a06) (local.get $b01))
		(i64.mul (local.get $a05) (local.get $b02))
		(i64.mul (local.get $a04) (local.get $b03))
		(i64.mul (local.get $a03) (local.get $b04))
		(i64.mul (local.get $a02) (local.get $b05))
		(i64.mul (local.get $a01) (local.get $b06))
		(i64.mul (local.get $a00) (local.get $b07))
		i64.add i64.add i64.add i64.add
		i64.add i64.add i64.add
		(i64.mul (local.get $a15) (local.get $b08)) ;; t23
		(i64.mul (local.get $a14) (local.get $b09))
		(i64.mul (local.get $a13) (local.get $b10))
		(i64.mul (local.get $a12) (local.get $b11))
		(i64.mul (local.get $a11) (local.get $b12))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a10) (local.get $b13))
		(i64.mul (local.get $a09) (local.get $b14))
		(i64.mul (local.get $a08) (local.get $b15))
		i64.add i64.add i64.add
		i64.const 38 i64.mul i64.add
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o07

		(i64.mul (local.get $a08) (local.get $b00)) ;; t08
		(i64.mul (local.get $a07) (local.get $b01))
		(i64.mul (local.get $a06) (local.get $b02))
		(i64.mul (local.get $a05) (local.get $b03))
		(i64.mul (local.get $a04) (local.get $b04))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a03) (local.get $b05))
		(i64.mul (local.get $a02) (local.get $b06))
		(i64.mul (local.get $a01) (local.get $b07))
		(i64.mul (local.get $a00) (local.get $b08))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a15) (local.get $b09)) ;; t24
		(i64.mul (local.get $a14) (local.get $b10))
		(i64.mul (local.get $a13) (local.get $b11))
		(i64.mul (local.get $a12) (local.get $b12))
		(i64.mul (local.get $a11) (local.get $b13))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a10) (local.get $b14))
		(i64.mul (local.get $a09) (local.get $b15))
		i64.add i64.add
		i64.const 38 i64.mul i64.add
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o08

		(i64.mul (local.get $a09) (local.get $b00)) ;; t09
		(i64.mul (local.get $a08) (local.get $b01))
		(i64.mul (local.get $a07) (local.get $b02))
		(i64.mul (local.get $a06) (local.get $b03))
		(i64.mul (local.get $a05) (local.get $b04))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a04) (local.get $b05))
		(i64.mul (local.get $a03) (local.get $b06))
		(i64.mul (local.get $a02) (local.get $b07))
		(i64.mul (local.get $a01) (local.get $b08))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a00) (local.get $b09))
		i64.add
		(i64.mul (local.get $a15) (local.get $b10)) ;; t25
		(i64.mul (local.get $a14) (local.get $b11))
		(i64.mul (local.get $a13) (local.get $b12))
		(i64.mul (local.get $a12) (local.get $b13))
		(i64.mul (local.get $a11) (local.get $b14))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a10) (local.get $b15))
		i64.add
		i64.const 38 i64.mul i64.add
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o09

		(i64.mul (local.get $a10) (local.get $b00)) ;; t10
		(i64.mul (local.get $a09) (local.get $b01))
		(i64.mul (local.get $a08) (local.get $b02))
		(i64.mul (local.get $a07) (local.get $b03))
		(i64.mul (local.get $a06) (local.get $b04))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a05) (local.get $b05))
		(i64.mul (local.get $a04) (local.get $b06))
		(i64.mul (local.get $a03) (local.get $b07))
		(i64.mul (local.get $a02) (local.get $b08))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a01) (local.get $b09))
		(i64.mul (local.get $a00) (local.get $b10))
		i64.add i64.add
		(i64.mul (local.get $a15) (local.get $b11)) ;; t26
		(i64.mul (local.get $a14) (local.get $b12))
		(i64.mul (local.get $a13) (local.get $b13))
		(i64.mul (local.get $a12) (local.get $b14))
		(i64.mul (local.get $a11) (local.get $b15))
		i64.add i64.add i64.add i64.add
		i64.const 38 i64.mul i64.add
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o10

		(i64.mul (local.get $a11) (local.get $b00)) ;; t11
		(i64.mul (local.get $a10) (local.get $b01))
		(i64.mul (local.get $a09) (local.get $b02))
		(i64.mul (local.get $a08) (local.get $b03))
		(i64.mul (local.get $a07) (local.get $b04))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a06) (local.get $b05))
		(i64.mul (local.get $a05) (local.get $b06))
		(i64.mul (local.get $a04) (local.get $b07))
		(i64.mul (local.get $a03) (local.get $b08))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a02) (local.get $b09))
		(i64.mul (local.get $a01) (local.get $b10))
		(i64.mul (local.get $a00) (local.get $b11))
		i64.add i64.add i64.add
		(i64.mul (local.get $a15) (local.get $b12)) ;; t27
		(i64.mul (local.get $a14) (local.get $b13))
		(i64.mul (local.get $a13) (local.get $b14))
		(i64.mul (local.get $a12) (local.get $b15))
		i64.add i64.add i64.add
		i64.const 38 i64.mul i64.add
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o11

		(i64.mul (local.get $a12) (local.get $b00)) ;; t12
		(i64.mul (local.get $a11) (local.get $b01))
		(i64.mul (local.get $a10) (local.get $b02))
		(i64.mul (local.get $a09) (local.get $b03))
		(i64.mul (local.get $a08) (local.get $b04))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a07) (local.get $b05))
		(i64.mul (local.get $a06) (local.get $b06))
		(i64.mul (local.get $a05) (local.get $b07))
		(i64.mul (local.get $a04) (local.get $b08))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a03) (local.get $b09))
		(i64.mul (local.get $a02) (local.get $b10))
		(i64.mul (local.get $a01) (local.get $b11))
		(i64.mul (local.get $a00) (local.get $b12))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a15) (local.get $b13)) ;; t28
		(i64.mul (local.get $a14) (local.get $b14))
		(i64.mul (local.get $a13) (local.get $b15))
		i64.add i64.add
		i64.const 38 i64.mul i64.add
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o12

		(i64.mul (local.get $a13) (local.get $b00)) ;; t13
		(i64.mul (local.get $a12) (local.get $b01))
		(i64.mul (local.get $a11) (local.get $b02))
		(i64.mul (local.get $a10) (local.get $b03))
		(i64.mul (local.get $a09) (local.get $b04))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a08) (local.get $b05))
		(i64.mul (local.get $a07) (local.get $b06))
		(i64.mul (local.get $a06) (local.get $b07))
		(i64.mul (local.get $a05) (local.get $b08))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a04) (local.get $b09))
		(i64.mul (local.get $a03) (local.get $b10))
		(i64.mul (local.get $a02) (local.get $b11))
		(i64.mul (local.get $a01) (local.get $b12))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a00) (local.get $b13))
		i64.add
		(i64.mul (local.get $a15) (local.get $b14)) ;; t29
		(i64.mul (local.get $a14) (local.get $b15))
		i64.add
		i64.const 38 i64.mul i64.add
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o13

		(i64.mul (local.get $a14) (local.get $b00)) ;; t14
		(i64.mul (local.get $a13) (local.get $b01))
		(i64.mul (local.get $a12) (local.get $b02))
		(i64.mul (local.get $a11) (local.get $b03))
		(i64.mul (local.get $a10) (local.get $b04))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a09) (local.get $b05))
		(i64.mul (local.get $a08) (local.get $b06))
		(i64.mul (local.get $a07) (local.get $b07))
		(i64.mul (local.get $a06) (local.get $b08))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a05) (local.get $b09))
		(i64.mul (local.get $a04) (local.get $b10))
		(i64.mul (local.get $a03) (local.get $b11))
		(i64.mul (local.get $a02) (local.get $b12))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a01) (local.get $b13))
		(i64.mul (local.get $a00) (local.get $b14))
		i64.add i64.add
		(i64.mul (local.get $a15) (local.get $b15)) ;; t30
		i64.const 38 i64.mul i64.add
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o14

		(i64.mul (local.get $a15) (local.get $b00)) ;; t15
		(i64.mul (local.get $a14) (local.get $b01))
		(i64.mul (local.get $a13) (local.get $b02))
		(i64.mul (local.get $a12) (local.get $b03))
		(i64.mul (local.get $a11) (local.get $b04))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a10) (local.get $b05))
		(i64.mul (local.get $a09) (local.get $b06))
		(i64.mul (local.get $a08) (local.get $b07))
		(i64.mul (local.get $a07) (local.get $b08))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a06) (local.get $b09))
		(i64.mul (local.get $a05) (local.get $b10))
		(i64.mul (local.get $a04) (local.get $b11))
		(i64.mul (local.get $a03) (local.get $b12))
		i64.add i64.add i64.add i64.add
		(i64.mul (local.get $a02) (local.get $b13))
		(i64.mul (local.get $a01) (local.get $b14))
		(i64.mul (local.get $a00) (local.get $b15))
		i64.add i64.add i64.add
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o15

		;; o00 += c - 1 + 37 * (c - 1);
		local.get $o00
		(i64.sub (local.get $c) (i64.const 1))
		(i64.sub (local.get $c) (i64.const 1)) i64.const 37
		i64.mul i64.add i64.add
		local.set $o00

		;; second carry
		(local.set $c (i64.const 1))
					
		local.get $o00
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o00

		local.get $o01
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o01

		local.get $o02
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o02

		local.get $o03
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o03

		local.get $o04
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o04

		local.get $o05
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o05

		local.get $o06
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o06


		local.get $o07
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o07

		local.get $o08
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o08

		local.get $o09
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o09

		local.get $o10
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o10

		local.get $o11
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o11

		local.get $o12
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o12

		local.get $o13
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o13

		local.get $o14
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o14

		local.get $o15
		local.get $c i64.add i64.const 65535 i64.add local.tee $v
		i64.const 16 i64.shr_s local.set $c
		local.get $v local.get $c i64.const 65536 i64.mul i64.sub
		local.set $o15

		;; o[0] += c - 1 + 37 * (c - 1);
		local.get $o00
		(i64.sub (local.get $c) (i64.const 1))
		(i64.sub (local.get $c) (i64.const 1)) i64.const 37
		i64.mul i64.add i64.add
		local.set $o00

		local.get $o00 local.get $o01 local.get $o02 local.get $o03
		local.get $o04 local.get $o05 local.get $o06 local.get $o07
		local.get $o08 local.get $o09 local.get $o10 local.get $o11
		local.get $o12 local.get $o13 local.get $o14 local.get $o15
	)
)

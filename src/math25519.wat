;; Arithmetic modulo the prime 2^255 - 19

;; integers mod p are internally represented as Int64Array(16),
;; where elements are coefficients of 2^0, ..., 2^15
;; unpack25519, pack25519 convert from/to external representation as Uint8Array(32)
;; the remaining functions operate on one or more Int64Array(16)

(module
	(import "js" "console.log" (func $log (param i32)))
	(import "./bytes_utils.wat" "alloc_zero" (func $alloc_zero (param i32) (result i32)))
	(import "watever/memory.wat" "alloc" (func $alloc (param i32) (result i32)))

	(import "./math25519/add.wat" "add" (func $add (param i32 i32 i32)))
	(import "./math25519/add.wat" "subtract" (func $subtract (param i32 i32 i32)))

  (import "./math25519/multiply.wat" "multiply" (func $multiply (param i32 i32 i32)))
  (import "./math25519/multiply.wat" "square" (func $square (param i32 i32)))
	(import "./math25519/multiply.wat" "carry" (func $car25519 (param i32)))

	(import "./math25519/select.wat" "select" (func $sel25519 (param i32 i32 i32)))

	(export "add" (func $add))
	(export "subtract" (func $subtract))
  (export "multiply" (func $multiply))
	(export "square" (func $square))
	(export "carry" (func $car25519))
  (export "sel" (func $sel25519))
	(export "invert" (func $inv25519))

	(export "unpack" (func $unpack25519))
	(export "pack" (func $pack25519))
	(export "par" (func $par25519))
	(export "set" (func $set25519))
	(export "neq" (func $neq25519))
	(export "verify_32" (func $crypto_verify_32))

	(func $unpack25519 (param $out i32) (; 16 x i64 ;) (param $in i32) (; 32 x u8 ;)
		;; for (let i = 0; i < 32; i+=2)
		(local $i i32)
		(local.set $i (i32.const 0))
		(loop
		 	;; o[i*4] = n[i] + (n[i + 1] << 8);
			(i32.add (local.get $out) (i32.shl (local.get $i) (i32.const 2)))
			(i64.load8_u (i32.add (local.get $in) (local.get $i)))
			(i64.load8_u offset=1 (i32.add (local.get $in) (local.get $i)))
			i64.const 8
			i64.shl
			i64.add
			i64.store
			(br_if 0 (i32.ne (i32.const 32)
        (local.tee $i (i32.add (local.get $i) (i32.const 2)))
      ))
		)
		;; o[15] &= 0x7fff;
		local.get $out
		(i64.load offset=120 (local.get $out))
		i64.const 0x7fff
  	i64.and
		i64.store offset=120
	)
  
	(func $neq25519 (param $a i32) (param $b i32) (result i32)
		;; let c = new Uint8Array(32);
		;; let d = new Uint8Array(32);
		(local $c i32) (local $d i32)
		(local.set $c (call $alloc (i32.const 64)))
		(local.set $d (i32.add (local.get $c) (i32.const 32)))
		;; pack25519(c, a);
  	;; pack25519(d, b);
		(call $pack25519 (local.get $c) (local.get $a))
		(call $pack25519 (local.get $d) (local.get $b))
		;; return crypto_verify_32(c, 0, d, 0);
		(call $crypto_verify_32 (local.get $c) (i32.const 0) (local.get $d) (i32.const 0))
	)

	(func $crypto_verify_32 ;; returns 0 if equal, -1 if not equal; constant time
		(param $x i32) (param $x_offset i32)
		(param $y i32) (param $y_offset i32)
		(result i32)

		(local $d i32) (local $i i32)
		;; let d = 0;
		(local.set $d (i32.const 0))
		;; for (let i = 0; i < 32; i++)
		(local.set $i (i32.const 0))
		(loop
			;; (call $log (local.get $i))
			;; (i32.add (local.get $x) (i32.add (local.get $x_offset) (local.get $i)))
			;; i32.load8_u
			;; call $log
			;; (i32.add (local.get $y) (i32.add (local.get $y_offset) (local.get $i)))
			;; i32.load8_u
			;; call $log
			;; d |= x[xi + i] ^ y[yi + i];
			(i32.add (local.get $x) (i32.add (local.get $x_offset) (local.get $i)))
			i32.load8_u
			(i32.add (local.get $y) (i32.add (local.get $y_offset) (local.get $i)))
			i32.load8_u
			i32.xor
			local.get $d
			i32.or
			local.set $d
			(br_if 0 (i32.ne (i32.const 32)
				(local.tee $i (i32.add (local.get $i) (i32.const 1)))
			))
		)
		;; return (1 & ((d - 1) >>> 8)) - 1;	
		(i32.sub (local.get $d) (i32.const 1))
		i32.const 8
		i32.shr_u
		i32.const 1
		i32.and
		i32.const 1
		i32.sub
	)

	(func $pack25519 (param $out i32) (; 32 x u8 ;) (param $in i32) (; 16 x i64 ;)
		(local $i i32) (local $j i32)
		(local $b i32)
		(local $m i32) (local $t i32)
		(local $mi i64)

		;; let m = new Float64Array(16);
	  ;; let t = new Float64Array(16);
		(local.set $m (call $alloc (i32.const 256)))
		(local.set $t (i32.add (local.get $m) (i32.const 128)))

		;; for (i = 0; i < 16; i++) t[i] = in[i];
		(call $set25519 (local.get $t) (local.get $in))
		;; car25519(t);
		;; car25519(t);
		;; car25519(t);
		(call $car25519 (local.get $t))
		(call $car25519 (local.get $t))
		(call $car25519 (local.get $t))

		;; for (j = 0; j < 2; j++)
		(local.set $j (i32.const 0))
		(loop
	    ;; m[0] = mi = t[0] - 0xffed;
			local.get $m
			(i64.load (local.get $t))
			i64.const 0xffed
			i64.sub
			local.tee $mi
			i64.store

			;; m[0] &= 0xffff;
			local.get $m
			local.get $mi
			i64.const 0xffff
			i64.and
			i64.store

	    ;; for (i = 8; i < 15*8; i+=8)
			(local.set $i (i32.const 8))
			(loop
			  ;; m[i] = mi = t[i] - 0xffff - ((mi >> 16) & 1);
				;; m[i] &= 0xffff;
				(i32.add (local.get $m) (local.get $i))
				(i32.add (local.get $t) (local.get $i))
				i64.load
				i64.const 0xffff
				i64.sub
				(i64.and (i64.shr_s (local.get $mi) (i64.const 16)) (i64.const 1))
				i64.sub
				local.tee $mi
				i64.const 0xffff
				i64.and
				i64.store

				(br_if 0 (i32.ne (i32.const 120)
        	(local.tee $i (i32.add (local.get $i) (i32.const 8)))
      	))
			)
			;; m[15] = mi = t[15] - 0x7fff - ((mi >> 16) & 1);
			(i32.add (local.get $m) (local.get $i))
			(i32.add (local.get $t) (local.get $i))
			i64.load
			i64.const 0x7fff
			i64.sub
			(i64.and (i64.shr_s (local.get $mi) (i64.const 16)) (i64.const 1))
			i64.sub
			local.tee $mi
			i64.store

			;; b = (mi >> 16) & 1;
			(i64.and (i64.shr_s (local.get $mi) (i64.const 16)) (i64.const 1))
			i32.wrap_i64
			local.set $b

			;; sel25519(t, m, 1 - b);
			local.get $t
			local.get $m
			(i32.sub (i32.const 1) (local.get $b))
			call $sel25519
		
			(br_if 0 (i32.ne (i32.const 2)
        (local.tee $j (i32.add (local.get $j) (i32.const 1)))
      ))
		)
		
		;; for (i = 0; i < 16*2; i+=2)
		(local.set $i (i32.const 0))
		(loop
			;; mi = t[i*4]
			(i32.add (local.get $t) (i32.shl (local.get $i) (i32.const 2)))
			i64.load
			local.set $mi
		  ;; out[i] = mi & 0xff;
			(i32.add (local.get $out) (local.get $i))
			(i64.and (local.get $mi) (i64.const 0xff))
			i64.store8
	    ;; out[i + 1] = mi >> 8;
			(i32.add (local.get $out) (i32.add (local.get $i) (i32.const 1)))
			(i64.shr_s (local.get $mi) (i64.const 8))
			i64.store8

			(br_if 0 (i32.ne (i32.const 32)
				(local.tee $i (i32.add (local.get $i) (i32.const 2)))
			))
		)
	)

	(func $par25519 (param $a i32) (; 16 x i64 ;) (result i32) (; boolean ;)
		(local $d i32)
		;; let d = new Uint8Array(32);
		;; pack25519(d, a);
		(call $alloc (i32.const 32))
		local.tee $d
		local.get $a
		call $pack25519
		;; return d[0] & 1;
		(i32.load8_u (local.get $d))
		i32.const 1
		i32.and
	)

	(func $set25519 (param $out i32) (param $in i32)
		(local $i i32)
		;; for (i = 0; i < 16*8; i+=8) out[i] = in[i];
		(local.set $i (i32.const 0))
    (loop
      (i32.add (local.get $out) (local.get $i))
      (i32.add (local.get $in) (local.get $i))
      i64.load
			i64.store
      (br_if 0 (i32.ne (i32.const 128)
        (local.tee $i (i32.add (local.get $i) (i32.const 8)))
      ))
    )
	)

	(func $inv25519 (param $out i32) (param $in i32)
		(local $i i32) (local $c i32)
		;; let c = new Float64Array(16);
		;; for (i = 0; i < 16; i++) c[i] = in[i];
		(call $alloc (i32.const 128))
		local.tee $c
		local.get $in
		call $set25519

		;; for (i = 253; i > 4; i--)
		(local.set $i (i32.const 253))
		(loop
			;; square25519(c, c); mul25519(c, c, i);
			(call $square (local.get $c) (local.get $c))
			(call $multiply (local.get $c) (local.get $c) (local.get $in))
			(br_if 0 (i32.ne (i32.const 4)
				(local.tee $i (i32.sub (local.get $i) (i32.const 1)))
			))
		)
		(call $square (local.get $c) (local.get $c)) ;; i=4
		(call $square (local.get $c) (local.get $c)) ;; i=3
		(call $multiply (local.get $c) (local.get $c) (local.get $in))
		(call $square (local.get $c) (local.get $c)) ;; i=2
		(call $square (local.get $c) (local.get $c)) ;; i=1
		(call $multiply (local.get $c) (local.get $c) (local.get $in))
		(call $square (local.get $c) (local.get $c)) ;; i=0
		(call $multiply (local.get $c) (local.get $c) (local.get $in))

		;; for (i = 0; i < 16; i++) o[a] = c[a];
		(call $set25519 (local.get $out) (local.get $c))
	)
)

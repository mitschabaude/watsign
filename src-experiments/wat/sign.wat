(module
	(import "js" "console.log" (func $log (param i32)))
	(import "watever/memory.wat" "alloc" (func $alloc (param i32) (result i32)))
	(import "watever/glue.wat" "lift_bytes" (func $return_bytes (param i32) (param i32) (result i32)))
	(import "watever/glue.wat" "lift_bool" (func $return_bool (param i32) (result i32)))

	(import "./sign/scalarmult.wat" "scalarbase" (func $scalarbase (param i32 i32)))
	(import "./sign/scalarmult.wat" "scalarmult" (func $scalarmult (param i32 i32 i32)))
	(import "./sign/scalarmult.wat" "add" (func $add (param i32 i32)))
	(import "./sign/pack.wat" "pack" (func $pack (param i32 i32)))
	(import "./sign/pack.wat" "unpackneg" (func $unpackneg (param i32 i32) (result i32)))
	(import "./sign/modL.wat" "modL" (func $modL (param i32 i32)))
	(import "./sign/modL.wat" "reduce" (func $reduce (param i32 i32) (result i32)))

	(import "./math25519.wat" "verify_32" (func $crypto_verify_32 (param i32 i32 i32 i32) (result i32)))

	(import "./bytes_utils.wat" "alloc_zero" (func $alloc_zero (param i32) (result i32)))
	(import "./bytes_utils.wat" "zero" (func $zero (param i32 i32)))
	(import "./bytes_utils.wat" "i8_to_i64" (func $i8_to_i64 (param i32 i32 i32)))

	(export "scalarbasePack#lift" (func $scalarbasePack))
	(export "signPt2#lift" (func $signPt2))
	(export "reduce#lift" (func $reduce))
	(export "signVerifyFromHash#lift" (func $signVerifyFromHash))
	(export "signPublicKeyFromHash#lift" (func $signPublicKeyFromHash))

	(func $signPublicKeyFromHash
		(param $secret_scalar i32) ;; 32 x i8
		(result i32)
		(local $pk i32) (local $p i32)

		;; secret_scalar[0] &= 248;
		;; secret_scalar[31] &= 127;
		;; secret_scalar[31] |= 64;
		local.get $secret_scalar
		(i32.and (i32.load8_u (local.get $secret_scalar)) (i32.const 248))
		i32.store8
		local.get $secret_scalar
		(i32.load8_u offset=31 (local.get $secret_scalar))
		i32.const 127
		i32.and
		i32.const 64
		i32.or
		i32.store8 offset=31

		;; let p = [gf(), gf(), gf(), gf()];
		;; scalarbase(p, skHash);
		;; pack(pk, p);
		(local.set $p (call $alloc_zero (i32.const 544)))
		(local.set $pk (i32.add (local.get $p) (i32.const 512)))
		(call $scalarbase (local.get $p) (local.get $secret_scalar))
		(call $pack (local.get $pk) (local.get $p))
		(call $return_bytes (local.get $pk) (i32.const 32))

		;; ;; sk.set(pk, 32);
		;; (local.set $i (i32.const 0))
		;; (loop
		;; 	(i32.load8_u (i32.add (local.get $pk) (local.get $i)))
		;; 	call $log
		;; 	local.get $sk
		;; 	(i32.load8_u (i32.add (local.get $pk) (local.get $i)))
		;; 	i32.store8 offset=32
		;; 	(br_if 0 (i32.ne (i32.const 32)
		;; 		(local.tee $i (i32.add (local.get $i) (i32.const 1)))
		;; 	))
		;; )
	)

	(func $signVerifyFromHash
		(param $big_hash i32) ;; 64 x i8
		(param $nonce_point i32) ;; 32 x i8
		(param $sig i32) ;; 32 x i8
		(param $public_key i32) ;; 32 x i8
		(result i32) ;; boolean
		
		(local $t i32) (local $p i32) (local $q i32) (local $x i32)
		(local.set $t (call $alloc_zero (i32.const 1056))) ;; 32 + 2*512
		(local.set $p (i32.add (local.get $t) (i32.const 32)))
		(local.set $q (i32.add (local.get $p) (i32.const 512)))

		;; if (unpackneg(q, publicKey)) return false;
		(call $unpackneg (local.get $q) (local.get $public_key))
		if (return (call $return_bool (i32.const 0))) end

		;; big_hash = reduce(big_hash);
		(call $i8_to_i64 (local.get $p) (local.get $big_hash) (i32.const 64))
		(call $modL (local.get $big_hash) (local.get $p))

		;; scalarmult(p, q, big_hash);
		;; scalarbase(q, sig);
		;; add(p, q);
		;; pack(t, p);
		(call $scalarmult (local.get $p) (local.get $q) (local.get $big_hash))
		(call $scalarbase (local.get $q) (local.get $sig))
		(call $add (local.get $p) (local.get $q))
		(call $pack (local.get $t) (local.get $p))

		;; if (crypto_verify_32(nonce_point, 0, t, 0)) return false;
		;; return true;
		(call $crypto_verify_32 (local.get $nonce_point) (i32.const 0) (local.get $t) (i32.const 0))
		if (return (call $return_bool (i32.const 0))) end
		(call $return_bool (i32.const 1))
	)
	
	(func $scalarbasePack
		(param $nonce i32) ;; 32 x i8
		(result i32) ;; 32 x i8
		
		(local $nonce_point i32) (local $R i32)
		(local.set $nonce_point (call $alloc_zero (i32.const 544)))
		(local.set $R (i32.add (local.get $nonce_point) (i32.const 512)))

		(call $scalarbase (local.get $nonce_point) (local.get $nonce))
		(call $pack (local.get $R) (local.get $nonce_point))
		(call $return_bytes (local.get $R) (i32.const 32))
	)

	(func $signPt2
		(param $nonce i32) ;; 32 x i8
		(param $secret_scalar i32) ;; 32 x i8
		(param $big_hash i32) ;; 64 x i8
		(result i32) ;; 32 x i8

		(local $i i32) (local $j i32) (local $ix i32) (local $k i32) (local $hi i64)
		(local $x i32) (local $S i32)
		(local.set $x (call $alloc_zero (i32.const 544)))
		(local.set $S (i32.add (local.get $x) (i32.const 512)))

		;; big_hash = reduce(big_hash);
		(call $i8_to_i64 (local.get $x) (local.get $big_hash) (i32.const 64))
		(call $modL (local.get $big_hash) (local.get $x))

		;; secret_scalar[0] &= 248;
		;; secret_scalar[31] &= 127;
		;; secret_scalar[31] |= 64;
		local.get $secret_scalar
		(i32.and (i32.load8_u (local.get $secret_scalar)) (i32.const 248))
		i32.store8
		local.get $secret_scalar
		(i32.load8_u offset=31 (local.get $secret_scalar))
		i32.const 127
		i32.and
		i32.const 64
		i32.or
		i32.store8 offset=31

		;; // sig = (r + H*s) mod L
		;; let x = new Float64Array(64); x.set(nonce);
		(call $i8_to_i64 (local.get $x) (local.get $nonce) (i32.const 32))
		(call $zero (i32.add (local.get $x) (i32.const 256)) (i32.const 256))

		;; for (i = 0, ix = x; i < 32; i++, ix+=8)
		(local.set $i (i32.const 0))
		(local.set $ix (local.get $x))
		(loop
			(i32.add (local.get $i) (local.get $big_hash))
			i64.load8_u
			local.set $hi
			;; for (j = 0, k = ix; j < 32; j++, k+=8)
			(local.set $j (i32.const 0))
			(local.set $k (local.get $ix))
			(loop
				;; x[i + j] += big_hash[i] * secret_scalar[j];
				local.get $k
				(i64.load (local.get $k))
				local.get $hi
				(i32.add (local.get $j) (local.get $secret_scalar))
				i64.load8_u
				i64.mul
				i64.add
				i64.store
				(local.set $k (i32.add (local.get $k) (i32.const 8)))
				(br_if 0 (i32.ne (i32.const 32)
					(local.tee $j (i32.add (i32.const 1) (local.get $j)))
				))
			)
			(local.set $ix (i32.add (local.get $ix) (i32.const 8)))
			(br_if 0 (i32.ne (i32.const 32)
				(local.tee $i (i32.add (i32.const 1) (local.get $i)))
			))
		)
		(call $modL (local.get $S) (local.get $x))
		(call $return_bytes (local.get $S) (i32.const 32))
	)
)

(module
	(import "js" "console.log" (func $log (param i32)))
	(import "js" "s => {throw Error(s);}#lift" (func $throw (param i32)))
	
	(import "#crypto" "hashNative#lift" (func $hashNative (param i32) (result i32)))
	(import "#crypto" "randomBytes" (func $randomBytes (param i32) (result i32)))

	(import "watever/memory.wat" "alloc" (func $alloc (param i32) (result i32)))
	(import "watever/memory.wat" "get_length" (func $get_length (param i32) (result i32)))
	(import "watever/memory.wat" "keep" (func $keep (param i32)))
	(import "watever/memory.wat" "free" (func $free (param i32)))

	(import "watever/glue.wat" "lift_string" (func $lift_string (param i32) (result i32)))
	(import "watever/glue.wat" "lift_raw_bytes" (func $lift_raw_bytes (param i32 i32) (result i32)))
	(import "watever/glue.wat" "lift_bytes" (func $lift_bytes (param i32) (result i32)))
	(import "watever/glue.wat" "lift_bool" (func $lift_bool (param i32) (result i32)))
	(import "watever/glue.wat" "lift_int" (func $lift_int (param i32) (result i32)))
	(import "watever/glue.wat" "lift_extern" (func $lift_extern (param i32) (result i32)))
	(import "watever/glue.wat" "new_object" (func $new_object (param i32) (result i32)))
  (import "watever/glue.wat" "add_entry" (func $add_entry (param i32)))
	
	(import "watever/promise.wat" "then_1" (func $then_1 (param i32 i32 i32) (result i32)))
	(import "watever/promise.wat" "then_2" (func $then_2 (param i32 i32 i32 i32) (result i32)))
	(import "watever/promise.wat" "then_3" (func $then_3 (param i32 i32 i32 i32 i32) (result i32)))

	(import "./sign/scalarmult.wat" "scalarbase" (func $scalarbase (param i32 i32)))
	(import "./sign/scalarmult.wat" "scalarmult" (func $scalarmult (param i32 i32 i32)))
	(import "./sign/scalarmult.wat" "add" (func $add (param i32 i32)))
	(import "./sign/pack.wat" "pack" (func $pack (param i32 i32)))
	(import "./sign/pack.wat" "unpackneg" (func $unpackneg (param i32 i32) (result i32)))
	(import "./sign/modL.wat" "modL" (func $modL (param i32 i32)))
	;; (import "./sign/modL.wat" "reduce" (func $reduce (param i32 i32) (result i32)))

	(import "./math25519.wat" "verify_32" (func $crypto_verify_32 (param i32 i32 i32 i32) (result i32)))

	(import "./bytes_utils.wat" "alloc_zero" (func $alloc_zero (param i32) (result i32)))
	(import "./bytes_utils.wat" "zero" (func $zero (param i32 i32)))
	(import "./bytes_utils.wat" "copy" (func $copy (param i32 i32 i32)))
	(import "./bytes_utils.wat" "i8_to_i64" (func $i8_to_i64 (param i32 i32 i32)))

	;; (export "scalarbasePack#lift" (func $scalarbasePack))
	;; (export "signPt2#lift" (func $signPt2))
	;; (export "reduce#lift" (func $reduce))
	(export "sign#lift" (func $sign))
	(export "verify#lift" (func $verify))
	(export "newKeyPair#lift" (func $newKeyPair))
	(export "keyPairFromSecretKey#lift" (func $keyPairFromSecretKey))
	(export "keyPairFromSeed#lift" (func $keyPairFromSeed))

	;; strings for error messages and keyPair object, stored in pointer format with length encoded
	(data (i32.const 896) "\0c\00\00\00bad key size") ;; 12
	(global $BAD_KEY_SIZE i32 (i32.const 900))
	(data (i32.const 912) "\12\00\00\00bad signature size") ;; 18
	(global $BAD_SIG_SIZE i32 (i32.const 916))
	(data (i32.const 934) "\0d\00\00\00bad seed size") ;; 13
	(global $BAD_SEED_SIZE i32 (i32.const 938))
	(data (i32.const 951) "\09\00\00\00publicKey") ;; 9
	(global $PUBLIC_KEY i32 (i32.const 955))
	(data (i32.const 964) "\09\00\00\00secretKey") ;; 9
	(global $SECRET_KEY i32 (i32.const 968))

	(table 5 funcref)
	(export "table" (table 0))
	(elem (i32.const 0) $verifyFromHash $keyPairFromHashAndSeed $signPt0 $signPt1 $signPt2a)

	(func $sign (param $message i32) (param $secret_key i32) (result i32)
		;; if (secretKey.length !== 64) throw new Error('bad secret key size');
		;; // secretKey = [secret, publicKey], where
		;; // publicKey = A := a * B, where a = hash(secret)[0:32]
		;; let secret = secretKey.subarray(0, 32);
		;; let publicKey = secretKey.subarray(32); // A
		;; let secretHash = await hashNative(secret);
		;; signPt0(secretHash, message, secretKey)

		(call $keep (local.get $message))
		(call $keep (local.get $secret_key))

		(call $hashNative (call $lift_raw_bytes (local.get $secret_key) (i32.const 32)))
		i32.const 2 ;; signPt0
		(call $lift_int (local.get $message))
		(call $lift_int (local.get $secret_key))
		call $then_2
		call $lift_extern
	)

	(func $signPt0 (param $secret_hash i32) (param $message i32) (param $secret_key i32) (result i32)
		(local $hashed i32) (local $msg_length i32)
		;; let secretScalar = secretHash.subarray(0, 32); // a
		;; let nonceSeed = secretHash.subarray(32);

	  ;; // compute nonce r = hash(hash(secret)[32:], msg) mod L
		;; // and curve point R = r * B
		;; let toBeHashed = new Uint8Array(64 + msg.byteLength);
		;; toBeHashed.set(nonceSeed, 32);
		;; toBeHashed.set(msg, 64);
		;; let nonce = await hashNative(toBeHashed.subarray(32));
		;; signPt1(nonce, secretKey, secretHash, toBeHashed)

		(local.set $msg_length (call $get_length (local.get $message)))

		(call $alloc (i32.add (i32.const 64) (local.get $msg_length)))
		local.set $hashed
		(call $copy (i32.add (i32.const 32) (local.get $hashed)) (i32.add (i32.const 32) (local.get $secret_hash)) (i32.const 32))
		(call $copy (i32.add (i32.const 64) (local.get $hashed)) (local.get $message) (local.get $msg_length))

		(call $keep (local.get $secret_hash))
		(call $keep (local.get $hashed))
		(call $free (local.get $message))

		(call $hashNative
			(call $lift_raw_bytes
				(i32.add (i32.const 32) (local.get $hashed))
				(i32.add (i32.const 32) (local.get $msg_length))
			)
		)
		i32.const 3 ;; signPt1
		(call $lift_int (local.get $secret_key))
		(call $lift_int (local.get $secret_hash))
		(call $lift_int (local.get $hashed))
		call $then_3
		call $lift_extern
	)
	
	(func $signPt1 (param $nonce i32) (param $secret_key i32) (param $secret_hash i32) (param $hashed i32) (result i32)
		(local $X i32) (local $nonce_point i32) (local $R i32)
		;; nonce = await reduce(nonce); // r
		;; let noncePoint = await scalarbasePack(nonce); // R

		(local.set $X (call $alloc_zero (i32.const 512)))
		(call $i8_to_i64 (local.get $X) (local.get $nonce) (i32.const 64))
		(call $modL (local.get $nonce) (local.get $X))

		(local.set $nonce_point (call $alloc_zero (i32.const 512)))
		(local.set $R (call $alloc_zero (i32.const 32)))

		(call $keep (local.get $nonce))
		(call $keep (local.get $R))
		(call $free (local.get $secret_key))
		(call $free (local.get $hashed))

		(call $scalarbase (local.get $nonce_point) (local.get $nonce))
		(call $pack (local.get $R) (local.get $nonce_point))
		;; (call $lift_raw_bytes (local.get $R) (i32.const 32))

		;; // H = hash(R, A, msg)
		;; // sig = S = (r + H*a) mod L
		;; toBeHashed.set(noncePoint);
		;; toBeHashed.set(publicKey, 32);

		(call $copy (local.get $hashed) (local.get $R) (i32.const 32))
		(call $copy (i32.add (i32.const 32) (local.get $hashed)) (i32.add (i32.const 32) (local.get $secret_key)) (i32.const 32))

		;; let bigHash = await hashNative(toBeHashed); // H
		;; signPt2a(bigHash, nonce, secretHash, noncePoint)

		(call $hashNative (call $lift_bytes (local.get $hashed)))
		i32.const 4 ;; signPt2a
		(call $lift_int (local.get $nonce))
		(call $lift_int (local.get $secret_hash))
		(call $lift_int (local.get $R))
		call $then_3
		call $lift_extern
	)

	(func $signPt2a
		(param $big_hash i32) ;; 64 x i8
		(param $nonce i32) ;; 64 x i8 (only use 0...32)
		(param $secret_scalar i32) ;; 64 x i8 (only use 0..32)
		(param $nonce_point i32) ;; 32 x i8
		(result i32) ;; 64 x i8

		;; let sig = await signPt2(nonce, secretScalar, bigHash); // S
		(local $signature i32)
		(local $i i32) (local $j i32) (local $ix i32) (local $k i32) (local $hi i64)
		(local $x i32) (local $S i32)
		(local.set $x (call $alloc_zero (i32.const 544)))
		(local.set $S (i32.add (local.get $x) (i32.const 512)))

		(call $free (local.get $nonce))
		(call $free (local.get $secret_scalar))
		(call $free (local.get $nonce_point))

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

		;; // return [R, S]
		;; return concat(noncePoint, sig);

		(local.set $signature (call $alloc (i32.const 64)))
		(call $copy (local.get $signature) (local.get $nonce_point) (i32.const 32))
		(call $copy (i32.add (i32.const 32) (local.get $signature)) (local.get $S) (i32.const 32))

		(call $lift_bytes (local.get $signature))

		;; // the verifier has the signature [R, S], the public key A, the msg, and the base point B
		;; // he can re-compute H = hash(R, A, msg) and verify
		;; // S * B (=== r * B + H * a * B ) === R + H * A
		;; // constructing S implies knowledge of r, a and thus the secret
	)
	
	(func $verify (param $message i32) (param $signature i32) (param $public_key i32)
		(result i32)

		(local $msg_length i32)
		(local $hashed i32)

		;; if (signature.length !== 64) throw new Error('bad signature size');
    ;; if (publicKey.length !== 32) throw new Error('bad public key size');
		(call $get_length (local.get $public_key)) (i32.const 32) i32.ne
		if (call $throw (call $lift_string (global.get $BAD_KEY_SIZE))) end
		(call $get_length (local.get $signature)) (i32.const 64) i32.ne
		if (call $throw (call $lift_string (global.get $BAD_SIG_SIZE))) end
		
		(local.set $msg_length (call $get_length (local.get $message)))

		;; concat(signature.subarray(0, 32), publicKey, message)
		(call $alloc (i32.add (i32.const 64) (local.get $msg_length)))
		local.set $hashed 
		(call $copy (local.get $hashed) (local.get $signature) (i32.const 32))
		(call $copy (i32.add (local.get $hashed) (i32.const 32)) (local.get $public_key)  (i32.const 32))
		(call $copy (i32.add (local.get $hashed) (i32.const 64)) (local.get $message) (local.get $msg_length))

		;; let hash = await hashNative(hashed)
		;; return verifyFromHash(hash, signature.subarray(0, 32), signature.subarray(32), publicKey)
		(call $hashNative (call $lift_bytes (local.get $hashed)))
		i32.const 0
		(call $lift_raw_bytes (local.get $signature) (i32.const 32))
		(call $lift_raw_bytes (i32.add (local.get $signature) (i32.const 32)) (i32.const 32))
		(call $lift_bytes (local.get $public_key))
		call $then_3
		call $lift_extern
	)

	(func $verifyFromHash
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
		if (return (call $lift_bool (i32.const 0))) end

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
		if (return (call $lift_bool (i32.const 0))) end
		(call $lift_bool (i32.const 1))
	)

	(func $newKeyPair (result i32)
		(call $randomBytes (i32.const 32))
		call $keyPairFromSeed
	)

	(func $keyPairFromSecretKey (param $secret_key i32) (result i32)
		;; if (secretKey.length !== 64) throw new Error('bad key size');
		(call $get_length (local.get $secret_key)) (i32.const 64) i32.ne
		if (call $throw (call $lift_string (global.get $BAD_KEY_SIZE))) end

		;; return {secretKey, publicKey: secretKey.subarray(32)}
		(call $new_object (i32.const 2))
		(call $add_entry (global.get $SECRET_KEY))
		(call $lift_bytes (local.get $secret_key)) drop
		(call $add_entry (global.get $PUBLIC_KEY))
		(call $lift_raw_bytes (i32.add (local.get $secret_key) (i32.const 32)) (i32.const 32)) drop
	)

	(func $keyPairFromSeed (param $seed i32) (result i32)
		(local $seed_lifted i32)
		;; if (seed.length !== 32) throw new Error('bad seed size');
		(call $get_length (local.get $seed)) (i32.const 32) i32.ne
		if (call $throw (call $lift_string (global.get $BAD_SEED_SIZE))) end

		;; let secretHash = await hashNative(secretKey.subarray(0, 32));
		;; return keyPairFromHashAndSeed(secretHash, seed);
		(local.tee $seed_lifted (call $lift_bytes (local.get $seed)))
		call $hashNative
		i32.const 1 ;; $keyPairFromHashAndSeed
		local.get $seed_lifted
		call $then_1
		call $lift_extern
	)

	(func $keyPairFromHashAndSeed (param $secret_hash i32) (param $seed i32) (result i32)
		(local $secret_key i32) (local $public_key i32)

		;; let publicKey = publicKeyFromHash(secretHash); // only uses first 32 bytes of hash
		(local.set $public_key (call $publicKeyFromHash (local.get $secret_hash)))

		;; let secretKey = concat(seed, publicKey);
		(local.set $secret_key (call $alloc (i32.const 64)))
		(call $copy (local.get $secret_key) (local.get $seed) (i32.const 32))
		(call $copy (i32.add (local.get $secret_key) (i32.const 32)) (local.get $public_key) (i32.const 32))

		;; return {secretKey, publicKey}
		(call $new_object (i32.const 2)) ;; returns pointer to object
		(call $add_entry (global.get $SECRET_KEY))
		(call $lift_bytes (local.get $secret_key)) drop
		(call $add_entry (global.get $PUBLIC_KEY))
		(call $lift_bytes (local.get $public_key)) drop
	)

	(func $publicKeyFromHash
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
		(local.set $p (call $alloc_zero (i32.const 512)))
		(local.set $pk (call $alloc_zero (i32.const 32)))
		(call $scalarbase (local.get $p) (local.get $secret_scalar))
		(call $pack (local.get $pk) (local.get $p))

		local.get $pk
		;; (call $lift_raw_bytes (local.get $pk) (i32.const 32))
	)
	
	;; UNUSED
	(func $scalarbasePack
		(param $nonce i32) ;; 32 x i8
		(result i32) ;; 32 x i8
		
		(local $nonce_point i32) (local $R i32)
		(local.set $nonce_point (call $alloc_zero (i32.const 544)))
		(local.set $R (i32.add (local.get $nonce_point) (i32.const 512)))

		(call $scalarbase (local.get $nonce_point) (local.get $nonce))
		(call $pack (local.get $R) (local.get $nonce_point))
		(call $lift_raw_bytes (local.get $R) (i32.const 32))
	)
	;; UNUSED
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
		(call $lift_raw_bytes (local.get $S) (i32.const 32))
	)
)

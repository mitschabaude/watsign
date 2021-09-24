(module
  (import "window" "console.log" (func $log (param i32)))
  (import "../../../node_modules/esbuild-plugin-wat/lib/memory.wat" "alloc" (func $alloc (param i32) (result i32)))

  (import "../math25519.wat" "unpack" (func $unpack25519 (param i32 i32)))
	(import "../math25519.wat" "par" (func $par25519 (param i32 i32)))
	(import "../math25519.wat" "pack" (func $pack25519 (param i32 i32)))
	(import "../math25519.wat" "multiply" (func $M (param i32 i32 i32)))
  (import "../math25519.wat" "square" (func $S (param i32 i32)))
  (import "../math25519.wat" "add" (func $A (param i32 i32 i32)))
  (import "../math25519.wat" "subtract" (func $Z (param i32 i32 i32)))
  (import "../math25519.wat" "invert" (func $inv25519 (param i32 i32)))
  (import "../math25519.wat" "neq" (func $neq25519 (param i32 i32) (result i32)))
  (import "../math25519.wat" "set" (func $set25519 (param i32 i32)))

  (import "./globals.wat" "D" (global $D i32))
  (import "./globals.wat" "I" (global $I i32))

  (import "../bytes_utils.wat" "zero" (func $zero (param i32 i32)))
  (import "../bytes_utils.wat" "alloc_zero" (func $alloc_zero (param i32) (result i32)))
	
  (export "pack" (func $pack))
  (export "unpackneg" (func $unpackneg))

	(func $pack (param $out i32) (; 32 x i8 ;) (param $p i32) (; 4 x 16 x i64 ;)
		;; let tx = gf(), ty = gf(), zi = gf();
		(local $tx i32) (local $ty i32) (local $zi i32)
		(local.set $tx (call $alloc (i32.const 1536))) ;; 3 * 4 * 128
		(local.set $ty (i32.add (local.get $tx) (i32.const 512)))
		(local.set $zi (i32.add (local.get $ty) (i32.const 512)))

		;; inv25519(zi, p[2]);
		local.get $zi
		(i32.add (local.get $p) (i32.const 256))
		call $inv25519
	  ;; mul25519(tx, p[0], zi);
		local.get $tx
		local.get $p
		local.get $zi
		call $M
	  ;; mul25519(ty, p[1], zi);
		local.get $ty
		(i32.add (local.get $p) (i32.const 128))
		local.get $zi
		call $M

	  ;; pack25519(out, ty);
		(call $pack25519 (local.get $out) (local.get $ty))
		;; out[31] ^= par25519(tx) << 7;
		local.get $out
		(i32.load8_u offset=31 (local.get $out))
		(i32.shl (call $par25519 (local.get $tx)) (i32.const 7))
		i32.xor
		i32.store8 offset=31
	)
  
  (func $unpackneg (param $r i32) (; 4 x 16 x i64 ;) (param $p i32) (; 32 x i8 ;)
    (result i32) (; -1 or 0 ;)
    (local $t i32) (local $chk i32) (local $num i32) (local $den i32)
    (local $den2 i32) (local $den4 i32) (local $den6 i32)
    
    ;; let t = gf(), chk = gf(), num = gf(),
    ;;   den = gf(), den2 = gf(), den4 = gf(), den6 = gf();
    (local.set $t (call $alloc_zero (i32.const 896))) ;; 7 * 128
    (local.set $chk (i32.add (local.get $t) (i32.const 128)))
    (local.set $num (i32.add (local.get $chk) (i32.const 128)))
    (local.set $den (i32.add (local.get $num) (i32.const 128)))
    (local.set $den2 (i32.add (local.get $den) (i32.const 128)))
    (local.set $den4 (i32.add (local.get $den2) (i32.const 128)))
    (local.set $den6 (i32.add (local.get $den4) (i32.const 128)))

    ;; set25519(r[2], gf1);
    ;; unpack25519(r[1], p);
    ;; square25519(num, r[1]);
    ;; mul25519(den, num, D);
    ;; sub25519(num, num, r[2]);
    ;; add25519(den, r[2], den);
    (i64.store8 offset=256 (local.get $r) (i64.const 1))
    (call $unpack25519 (i32.add (local.get $r) (i32.const 128)) (local.get $p))
    (call $S (local.get $num) (i32.add (local.get $r) (i32.const 128)))
    (call $M (local.get $den) (local.get $num) (global.get $D))
    (call $Z (local.get $num) (local.get $num) (i32.add (local.get $r) (i32.const 256)))
    (call $A (local.get $den) (i32.add (local.get $r) (i32.const 256)) (local.get $den))

    ;; square25519(den2, den);
    ;; square25519(den4, den2);
    ;; mul25519(den6, den4, den2);
    ;; mul25519(t, den6, num);
    ;; mul25519(t, t, den);
    (call $S (local.get $den2) (local.get $den))
    (call $S (local.get $den4) (local.get $den2))
    (call $M (local.get $den6) (local.get $den4) (local.get $den2))
    (call $M (local.get $t) (local.get $den6) (local.get $num))
    (call $M (local.get $t) (local.get $t) (local.get $den))

    ;; pow2523(t, t);
    ;; mul25519(t, t, num);
    ;; mul25519(t, t, den);
    ;; mul25519(t, t, den);
    ;; mul25519(r[0], t, den);
    (call $pow2523 (local.get $t) (local.get $t))
    (call $M (local.get $t) (local.get $t) (local.get $num))
    (call $M (local.get $t) (local.get $t) (local.get $den))
    (call $M (local.get $t) (local.get $t) (local.get $den))
    (call $M (local.get $r) (local.get $t) (local.get $den))

    ;; square25519(chk, r[0]);
    ;; mul25519(chk, chk, den);
    ;; if (neq25519(chk, num)) mul25519(r[0], r[0], I);
    (call $S (local.get $chk) (local.get $r))
    (call $M (local.get $chk) (local.get $chk) (local.get $den))
    (call $neq25519 (local.get $chk) (local.get $num))
    if
      (call $M (local.get $r) (local.get $r) (global.get $I))
    end

    ;; square25519(chk, r[0]);
    ;; mul25519(chk, chk, den);
    ;; if (neq25519(chk, num)) return -1;
    (call $S (local.get $chk) (local.get $r))
    (call $M (local.get $chk) (local.get $chk) (local.get $den))
    (call $neq25519 (local.get $chk) (local.get $num))
    if
      (return (i32.const -1))
    end

    ;; if (par25519(r[0]) === p[31] >> 7) sub25519(r[0], gf0, r[0]);
    (call $zero (local.get $t) (i32.const 128))
    (call $par25519 (local.get $r))
    (i32.shr_s (i32.load8_u offset=31 (local.get $p)) (i32.const 7))
    i32.eq
    if
      (call $Z (local.get $r) (local.get $t) (local.get $r))
    end

    ;; mul25519(r[3], r[0], r[1]);
    ;; return 0;
    (call $M (i32.add (local.get $r) (i32.const 384)) (local.get $r) (i32.add (local.get $r) (i32.const 128)))
    i32.const 0
  )

  ;; function pow2523(o, i) {
  (func $pow2523 (param $out i32) (param $in i32) (; 16 x i64 ;)
    (local $c i32) (local $i i32)
    ;; let c = gf();
    ;; creating the intermediate $c is necessary because $out and $in will be the same
    (local.set $c (call $alloc (i32.const 128)))
    ;; let i;
    ;; for (i = 0; i < 16; i++) c[i] = in[i];
    (call $set25519 (local.get $c) (local.get $in))
    ;; for (i = 250; i >= 0; i--) {
    ;;   square25519(c, c);
    ;;   if (i !== 1) mul25519(c, c, in);
    ;; }
    (local.set $i (i32.const 250))
    (loop
      (call $S (local.get $c) (local.get $c))
      (call $M (local.get $c) (local.get $c) (local.get $in))
      (br_if 0 (i32.ne (i32.const 1)
        (local.tee $i (i32.sub (local.get $i) (i32.const 1)))
      ))
    )
    (call $S (local.get $c) (local.get $c))
    (call $S (local.get $c) (local.get $c))
    (call $M (local.get $c) (local.get $c) (local.get $in))
    ;; for (i = 0; i < 16; i++) out[i] = c[i];
    (call $set25519 (local.get $out) (local.get $c))
  )
)
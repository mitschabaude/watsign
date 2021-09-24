(module
  ;; (import "../log.wat" "log_vec16" (func $log_vec16))
  (import "../../../node_modules/esbuild-plugin-wat/lib/memory.wat" "alloc" (func $alloc (param i32) (result i32)))

	(import "../math25519.wat" "set" (func $set25519 (param i32 i32)))
	(import "../math25519.wat" "add" (func $A (param i32 i32 i32)))
	(import "../math25519.wat" "subtract" (func $Z (param i32 i32 i32)))
	(import "../math25519.wat" "multiply" (func $M (param i32 i32 i32)))
	(import "../math25519.wat" "sel" (func $sel25519 (param i32 i32 i32)))

  (import "./globals.wat" "D2" (global $D2 i32))
  (import "./globals.wat" "X" (global $X i32))
  (import "./globals.wat" "Y" (global $Y i32))

  ;; (import "../bytes_utils.wat" "alloc_zero" (func $alloc_zero (param i32) (result i32)))
  (import "../bytes_utils.wat" "zero" (func $zero (param i32 i32)))

  (export "scalarmult" (func $scalarmult))
  (export "scalarbase" (func $scalarbase))
  (export "add" (func $add))

  (func $scalarbase
    (param $p i32) ;; output ec point, 4 x 16 x i64
    (param $s i32) ;; scalar, 32 x i8

    (local $q i32)
    ;; let q = [gf(), gf(), gf(), gf()];
    ;; set25519(q[0], X);
    ;; set25519(q[1], Y);
    ;; set25519(q[2], gf1);
    ;; mul25519(q[3], X, Y);
    ;; scalarmult(p, q, s);
    (local.set $q (call $alloc (i32.const 512)))
    (call $set25519 (local.get $q) (global.get $X))
    (call $set25519 (i32.add (local.get $q) (i32.const 128)) (global.get $Y))
    (call $zero (i32.add (local.get $q) (i32.const 256)) (i32.const 128))
    (i32.store8 offset=256 (local.get $q) (i32.const 1))
    (call $M (i32.add (local.get $q) (i32.const 384)) (global.get $X) (global.get $Y))
    (call $scalarmult (local.get $p) (local.get $q) (local.get $s))
  )

  (func $scalarmult
    (param $p i32) ;; output ec point, 4 x 16 x i64
    (param $q i32) ;; input ec point, 4 x 16 x i64
    (param $s i32) ;; scalar, 32 x i8

    (local $i i32) (local $b i32)
    ;; set25519(p[0], gf0); set25519(p[1], gf1);
    ;; set25519(p[2], gf1); set25519(p[3], gf0);
    (call $zero (local.get $p) (i32.const 512))
    (i32.store8 offset=128 (local.get $p) (i32.const 1))
    (i32.store8 offset=256 (local.get $p) (i32.const 1))

    ;; for (i = 255; i >= 0; --i)
    (local.set $i (i32.const 255))
    (loop
      ;; b = (s[(i / 8) | 0] >> (i & 7)) & 1;
      (i32.load8_u (i32.add (local.get $s)
        (i32.shr_u (local.get $i) (i32.const 3))
      ))
      (i32.and (local.get $i) (i32.const 7))
      i32.shr_s
      i32.const 1
      i32.and
      local.set $b

      ;; cswap(p, q, b);
      ;; add(q, p);
      ;; add(p, p);
      ;; cswap(p, q, b);
      (call $cswap (local.get $p) (local.get $q) (local.get $b))
      (call $add (local.get $q) (local.get $p))
      (call $add (local.get $p) (local.get $p))
      (call $cswap (local.get $p) (local.get $q) (local.get $b))
    
      (br_if 0 (i32.ne (i32.const -1)
        (local.tee $i (i32.sub (local.get $i) (i32.const 1)))
      ))
    )
  )

	(func $add (param $p i32) (param $q i32) ;; 4 x 16 x i64

    (local $a i32) (local $b i32) (local $c i32) (local $d i32)
    (local $e i32) (local $f i32) (local $g i32) (local $h i32)
    (local $t i32)
    
    ;; let a = gf(), b = gf(), c = gf(), d = gf(),
    ;;   e = gf(), f = gf(), g = gf(), h = gf(), t = gf();
    (local.set $a (call $alloc (i32.const 1152))) ;; 9 * 128
    (local.set $b (i32.add (local.get $a) (i32.const 128)))
    (local.set $c (i32.add (local.get $b) (i32.const 128)))
    (local.set $d (i32.add (local.get $c) (i32.const 128)))
    (local.set $e (i32.add (local.get $d) (i32.const 128)))
    (local.set $f (i32.add (local.get $e) (i32.const 128)))
    (local.set $g (i32.add (local.get $f) (i32.const 128)))
    (local.set $h (i32.add (local.get $g) (i32.const 128)))
    (local.set $t (i32.add (local.get $h) (i32.const 128)))

    ;; sub25519(a, p[1], p[0]);
    ;; sub25519(t, q[1], q[0]);
    ;; mul25519(a, a, t);
    (call $Z (local.get $a) (i32.add (local.get $p) (i32.const 128)) (local.get $p))
    (call $Z (local.get $t) (i32.add (local.get $q) (i32.const 128)) (local.get $q))
    (call $M (local.get $a) (local.get $a) (local.get $t))
    
    ;; add25519(b, p[0], p[1]);
    ;; add25519(t, q[0], q[1]);
    ;; mul25519(b, b, t);
    (call $A (local.get $b) (local.get $p) (i32.add (local.get $p) (i32.const 128)))
    (call $A (local.get $t) (local.get $q) (i32.add (local.get $q) (i32.const 128)))
    (call $M (local.get $b) (local.get $b) (local.get $t))
    
    ;; mul25519(c, p[3], q[3]);
    ;; mul25519(c, c, D2);
    ;; mul25519(d, p[2], q[2]);
    (call $M (local.get $c) (i32.add (local.get $p) (i32.const 384)) (i32.add (local.get $q) (i32.const 384)))
    (call $M (local.get $c) (local.get $c) (global.get $D2))
    (call $M (local.get $d) (i32.add (local.get $p) (i32.const 256)) (i32.add (local.get $q) (i32.const 256)))

    ;; add25519(d, d, d);
    ;; sub25519(e, b, a);
    ;; sub25519(f, d, c);
    ;; add25519(g, d, c);
    ;; add25519(h, b, a);
    (call $A (local.get $d) (local.get $d) (local.get $d))
    (call $Z (local.get $e) (local.get $b) (local.get $a))
    (call $Z (local.get $f) (local.get $d) (local.get $c))
    (call $A (local.get $g) (local.get $d) (local.get $c))
    (call $A (local.get $h) (local.get $b) (local.get $a))

    ;; mul25519(p[0], e, f);
    ;; mul25519(p[1], h, g);
    ;; mul25519(p[2], g, f);
    ;; mul25519(p[3], e, h);
    (call $M (local.get $p) (local.get $e) (local.get $f))
    (call $M (i32.add (local.get $p) (i32.const 128)) (local.get $h) (local.get $g))
    (call $M (i32.add (local.get $p) (i32.const 256)) (local.get $g) (local.get $f))
    (call $M (i32.add (local.get $p) (i32.const 384)) (local.get $e) (local.get $h))
	)

	(func $cswap
		(param $p i32) (param $q i32) ;; 4 x 16 x i64
		(param $b i32) ;; boolean
		(local $i i32)
		;; for (i = 0; i < 512; i+=128) sel25519(p[i], q[i], b);
		(local.set $i (i32.const 0))
		(loop
			(i32.add (local.get $p) (local.get $i))
			(i32.add (local.get $q) (local.get $i))
			local.get $b
			call $sel25519
			(br_if 0 (i32.ne (i32.const 512)
				(local.tee $i (i32.add (local.get $i) (i32.const 128)))
			))
		)
	)

)
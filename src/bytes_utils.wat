(module
  (import "watever/memory.wat" "alloc" (func $alloc (param i32) (result i32)))

  (export "zero" (func $zero))
  (export "alloc_zero" (func $alloc_zero))
	(export "copy" (func $copy))
	(export "i8_to_i64" (func $i8_to_i64))

	(func $alloc_zero (param $length i32) (result i32)
		(local $pointer i32)
		(local.set $pointer (call $alloc (local.get $length)))
		(call $zero (local.get $pointer) (local.get $length))
		local.get $pointer
	)

	(func $zero (param $x i32) (param $xLength i32)
		(local $I i32)
		(local $end i32)
		(local.set $end (i32.add (local.get $x) (local.get $xLength)))
		(local.set $I (local.get $x))
		(loop
			(i32.store8 (local.get $I) (i32.const 0))
			(br_if 0 (i32.ne (local.get $end)
				(local.tee $I (i32.add (local.get $I) (i32.const 1)))
			))
		)
	)

	(func $copy (param $target i32) (param $source i32) (param $length i32)
		(local $i i32)
		(local.set $i (i32.const 0))
		(loop
			(i32.store8 (i32.add (local.get $i) (local.get $target))
				(i32.load8_s
					(i32.add (local.get $i) (local.get $source))
				)
			)
			(br_if 0 (i32.ne (local.get $length)
				(local.tee $i (i32.add (local.get $i) (i32.const 1)))
			))
		)
	)

	(func $i8_to_i64
		(param $X i32) ;; length n * i64 = n * 8
		(param $x i32) (param $xLength i32) ;; n

		(local $i i32)
		(local.set $i (i32.const 0))
		(loop
			;; index to write
			(i32.add (local.get $X) (i32.shl (local.get $i) (i32.const 3)))
			;; byte to copy
			(i32.add (local.get $i) (local.get $x))
			i64.load8_u

			i64.store
			
			(br_if 0 (i32.ne (local.get $xLength)
				(local.tee $i (i32.add (local.get $i) (i32.const 1)))
			))
		)
	)
)

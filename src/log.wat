(module
  ;; advanced debug stuff
	;; (import "js" "console.log" (func $log (param i64)))
	;; (import "js" "console.log#lift" (func $log_bytes (param i32)))
	;; (import "js" "b => {let a = Array(b.byteLength >> 3); let v = new DataView(b.buffer); for (let i=0; i<b.byteLength; i+=8) {a[i>>3] = Number(v.getBigInt64(i, true));}; console.log(a);}#lift" (func $log_int64array (param i32)))
	;; (import "js" "b => console.log(Buffer.from(b).toString('base64'))#lift" (func $log_b64 (param i32)))

  (import "js" "console.log" (func $log16 (param i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64)))
  (global $has_logs (mut i32) (i32.const 3))
  
  (func $log_vec16 (export "log_vec16")
    (param $p i32)

    global.get $has_logs
    i32.eqz
    if (return) end
    global.get $has_logs
    i32.const 1
    i32.sub
    global.set $has_logs

    (i64.load offset=000 (local.get $p))
    (i64.load offset=008 (local.get $p))
    (i64.load offset=016 (local.get $p))
    (i64.load offset=024 (local.get $p))
    (i64.load offset=032 (local.get $p))
    (i64.load offset=040 (local.get $p))
    (i64.load offset=048 (local.get $p))
    (i64.load offset=056 (local.get $p))
    (i64.load offset=064 (local.get $p))
    (i64.load offset=072 (local.get $p))
    (i64.load offset=080 (local.get $p))
    (i64.load offset=088 (local.get $p))
    (i64.load offset=096 (local.get $p))
    (i64.load offset=104 (local.get $p))
    (i64.load offset=112 (local.get $p))
    (i64.load offset=120 (local.get $p))
    call $log16
  )
)
(module
  (import "window" "console.log" (func $log16 (param i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64 i64)))
  (global $has_logs (mut i32) (i32.const 3))
  
  (func $log_vec16 (export "log_vec16")
    (param $p0 i64) (param $p1 i64) (param $p2 i64) (param $p3 i64)
    (param $p4 i64) (param $p5 i64) (param $p6 i64) (param $p7 i64)
    (param $p8 i64) (param $p9 i64) (param $pa i64) (param $pb i64)
    (param $pc i64) (param $pd i64) (param $pe i64) (param $pf i64)

    global.get $has_logs
    i32.eqz
    if (return) end
    global.get $has_logs
    i32.const 1
    i32.sub
    global.set $has_logs

    local.get $p0 local.get $p1 local.get $p2 local.get $p3
    local.get $p4 local.get $p5 local.get $p6 local.get $p7
    local.get $p8 local.get $p9 local.get $pa local.get $pb
    local.get $pc local.get $pd local.get $pe local.get $pf
    call $log16
  )
)
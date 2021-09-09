(module
  (export "select" (func $sel25519))

	(func $sel25519
		(param $p0 i64) (param $p1 i64) (param $p2 i64) (param $p3 i64)
    (param $p4 i64) (param $p5 i64) (param $p6 i64) (param $p7 i64)
    (param $p8 i64) (param $p9 i64) (param $pa i64) (param $pb i64)
    (param $pc i64) (param $pd i64) (param $pe i64) (param $pf i64)

    (param $q0 i64) (param $q1 i64) (param $q2 i64) (param $q3 i64)
    (param $q4 i64) (param $q5 i64) (param $q6 i64) (param $q7 i64)
    (param $q8 i64) (param $q9 i64) (param $qa i64) (param $qb i64)
    (param $qc i64) (param $qd i64) (param $qe i64) (param $qf i64)
  
		(param $b i32) (; boolean ;)

    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)

    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)
    (result i64) (result i64) (result i64) (result i64)

		(local $c i64) (local $t i64)
		(local $pi i64) (local $qi i64)

		local.get $b
		i32.eqz
		if
			local.get $q0 local.get $q1 local.get $q2 local.get $q3
			local.get $q4 local.get $q5 local.get $q6 local.get $q7
			local.get $q8 local.get $q9 local.get $qa local.get $qb
			local.get $qc local.get $qd local.get $qe local.get $qf

			local.get $p0 local.get $p1 local.get $p2 local.get $p3
			local.get $p4 local.get $p5 local.get $p6 local.get $p7
			local.get $p8 local.get $p9 local.get $pa local.get $pb
			local.get $pc local.get $pd local.get $pe local.get $pf
			return
		end
		local.get $p0 local.get $p1 local.get $p2 local.get $p3
		local.get $p4 local.get $p5 local.get $p6 local.get $p7
		local.get $p8 local.get $p9 local.get $pa local.get $pb
		local.get $pc local.get $pd local.get $pe local.get $pf

		local.get $q0 local.get $q1 local.get $q2 local.get $q3
		local.get $q4 local.get $q5 local.get $q6 local.get $q7
		local.get $q8 local.get $q9 local.get $qa local.get $qb
		local.get $qc local.get $qd local.get $qe local.get $qf
	)

)
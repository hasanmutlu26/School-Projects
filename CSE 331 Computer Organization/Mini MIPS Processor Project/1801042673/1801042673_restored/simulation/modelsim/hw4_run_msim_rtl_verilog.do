transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Lenovo/Desktop/OKUL/3\ Fall/331\ Computer\ Organization/HW4/1801042673/1801042673_restored {C:/Users/Lenovo/Desktop/OKUL/3 Fall/331 Computer Organization/HW4/1801042673/1801042673_restored/_32bit_OR.v}
vlog -vlog01compat -work work +incdir+C:/Users/Lenovo/Desktop/OKUL/3\ Fall/331\ Computer\ Organization/HW4/1801042673/1801042673_restored {C:/Users/Lenovo/Desktop/OKUL/3 Fall/331 Computer Organization/HW4/1801042673/1801042673_restored/full_adder.v}
vlog -vlog01compat -work work +incdir+C:/Users/Lenovo/Desktop/OKUL/3\ Fall/331\ Computer\ Organization/HW4/1801042673/1801042673_restored {C:/Users/Lenovo/Desktop/OKUL/3 Fall/331 Computer Organization/HW4/1801042673/1801042673_restored/half_adder.v}
vlog -vlog01compat -work work +incdir+C:/Users/Lenovo/Desktop/OKUL/3\ Fall/331\ Computer\ Organization/HW4/1801042673/1801042673_restored {C:/Users/Lenovo/Desktop/OKUL/3 Fall/331 Computer Organization/HW4/1801042673/1801042673_restored/_32bit_SUB.v}
vlog -vlog01compat -work work +incdir+C:/Users/Lenovo/Desktop/OKUL/3\ Fall/331\ Computer\ Organization/HW4/1801042673/1801042673_restored {C:/Users/Lenovo/Desktop/OKUL/3 Fall/331 Computer Organization/HW4/1801042673/1801042673_restored/_32bit_ADD.v}
vlog -vlog01compat -work work +incdir+C:/Users/Lenovo/Desktop/OKUL/3\ Fall/331\ Computer\ Organization/HW4/1801042673/1801042673_restored {C:/Users/Lenovo/Desktop/OKUL/3 Fall/331 Computer Organization/HW4/1801042673/1801042673_restored/_32bit_XOR.v}
vlog -vlog01compat -work work +incdir+C:/Users/Lenovo/Desktop/OKUL/3\ Fall/331\ Computer\ Organization/HW4/1801042673/1801042673_restored {C:/Users/Lenovo/Desktop/OKUL/3 Fall/331 Computer Organization/HW4/1801042673/1801042673_restored/_32bit_SLT.v}


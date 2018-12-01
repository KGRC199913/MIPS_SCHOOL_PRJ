.data
menu: 		.asciiz		"Chon 1 tuy chon:\n1.Xuat ra cac phan tu.\n2.Tinh tong cac phan tu.\n3.Liet ke cac phan tu la so nguyen to.\n4.Tim max.\n5.Tim phan tu co gia tri x.\n6.Thoat chuong trinh\nLua chon:"
eol:  		.asciiz		"\n"
space_char:	.asciiz		" "

.text
	j 	main

read_n:
	li	$v0, 5
	syscall
	blez	$v0, read_n	#if n <= 0 re-loop
	jr	$ra
 
allocate_array:
	li	$v0, 9
	syscall
	jr	$ra 

read_element:
	li	$v0, 5
	syscall
	jr	$ra	

read_n_element:
	li	$t2, 0			# will use $t2 as byte index
	addi	$sp, $sp, -4		#get a stack mem for int32
loop_read_n:
	ble	$t0, $t2, end_func_with_stack_allocate	# if !(n <= i) continue else return
	add	$t3, $t2, $t1		# $t3 now contain the address of current pos of array, like &a[i]
	sw	$ra, 0($sp)		# temp save the current $ra value
	jal	read_element		# read the input element
	lw	$ra, 0($sp)		# re-assign $ra value
	sw	$v0, ($t3)		# save the returned value to a[i]
	addi	$t2, $t2, 4		# move the byte pointer forward 4 bytes
	j 	loop_read_n

end_func_with_stack_allocate:
	addi	$sp, $sp, 4		# return the stack mem
	jr	$ra

print_menu:
	li	$v0, 4
	la	$a0, eol
	syscall
	la	$a0, menu
	syscall
	jr	$ra

get_option:
	li	$s0, 6
get_option_loop:
	li	$v0, 5
	syscall
	blez	$v0, get_option_loop
	blt	$s0, $v0, get_option_loop
	jr	$ra

print_ele:
	li	$v0, 1
	syscall
	li	$v0, 4
	la	$a0, space_char
	syscall
	jr	$ra

print_all_ele:
	li	$t2, 0			# will use $t2 as byte index
	addi	$sp, $sp, -4		#get a stack mem for int32
print_all_ele_loop:
	ble	$t0, $t2, end_func_with_stack_allocate	# if !(n <= i) continue else return
	add	$t3, $t2, $t1		# $t3 now contain the address of current pos of array, like &a[i]
	sw	$ra, 0($sp)		# temp save the current $ra value
	lw	$a0, ($t3)
	jal	print_ele		# read the input element
	lw	$ra, 0($sp)		# re-assign $ra value
	addi	$t2, $t2, 4		# move the byte pointer forward 4 bytes
	j 	print_all_ele_loop
	
calculate_sum:
	li	$t2, 0
	move	$v0, $0
calucalte_sum_loop:
	ble	$t0, $t2, end_func	# if !(n <= i) continue else return
	add	$t3, $t2, $t1		# $t3 now contain the address of current pos of array, like &a[i]
	lw	$s0, ($t3)
	add	$v0, $v0, $s0
	addi	$t2, $t2, 4		# move the byte pointer forward 4 bytes
	j 	calucalte_sum_loop
	
end_func:
	jr	$ra

find_max:
	lw	$v0, ($t1)
	li	$t2, 0
find_max_loop:
	ble	$t0, $t2, end_func
	add	$t3, $t2, $t1
	lw	$s0, ($t3)
	slt	$s1, $v0, $s0
	addi	$t2, $t2, 4
	beq	$s1, $0, find_max_loop
	move	$v0, $s0
	j 	find_max_loop

get_input_int:
	li	$v0, 5
	syscall
	jr	$ra

# return the pos of the input ele if found, else return -1
find_ele_pos:
	li	$t2, 0
	li	$v0, -1
find_ele_pos_loop:
	ble	$t0, $t2, end_func
	add	$t3, $t2, $t1
	lw	$s0, ($t3)
	addi	$t2, $t2, 4
	bne	$a0, $s0, find_ele_pos_loop
	li	$s0, 4	
	div	$t2, $s0
	mflo	$v0
	subi	$v0, $v0, 1
	jr	$ra

.globl main
main:
	jal read_n
	move	$t0, $v0	# $t0 now contains value of n
	li	$s0, 4
	multu	$t0, $s0
	mflo	$t0		# $t0 is n * 4, is the byte size of the array
	add	$a0, $t0, $0
	jal	allocate_array
	move	$t1, $v0	# $t1 now contains address of the allocated array
	jal	read_n_element
	
handle_menu:
	jal	print_menu
	jal	get_option
	beq	$v0, 1, L1
	beq	$v0, 2, L2
	beq	$v0, 3, L3
	beq	$v0, 4, L4
	beq	$v0, 5, L5
	j	L6	

L1:
	jal	print_all_ele
	j 	handle_menu
L2:
	jal	calculate_sum
	move	$a0, $v0
	jal 	print_ele
	j	handle_menu
L3:
L4:
	jal	find_max
	move	$a0, $v0
	jal	print_ele
	j	handle_menu
L5:	
	jal	get_input_int
	move	$a0, $v0
	jal	find_ele_pos
	move	$a0, $v0
	jal	print_ele
	j	handle_menu
L6:
	li	$v0, 10		# exit
	syscall

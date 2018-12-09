.data
	arr:	.space	24
.text
j	main

swap:	#swap data of value cointained in address $a0 and $a1
	lw	$t0, 0($a0)
	lw	$t1, 0($a1)
	sw	$t0, 0($a1)
	sw	$t1, 0($a0)	
	jr	$ra

qsort:	# $a0: arr, $a1: left, $a2: right
	ble	$a2, $a1, return
	sll	$s0, $a1, 2	# low = left
	sll	$s1, $a2, 2	# high = right
	sub	$s3, $a2, $a1	# temp = right - left
	srl	$s3, $s3, 1	# temp /= 2
	add	$s4, $a1, $s3	# mid = left + temp
	sll	$s3, $s4, 2
	add	$s3, $s3, $a0
	lw	$s3, 0($s3)	# pivot = a[mid]
partition_loop:
	blt	$s1, $s0, recursive	# right > left -> skip while loops
left_loop:
	add	$t0, $a0, $s0
	lw	$t1, 0($t0)
	ble	$s3, $t1, right_loop	# while a[lo] < pivot
	add	$s0, $s0, 4
	j	left_loop
right_loop:
	add	$t0, $a0, $s1
	lw	$t1, 0($t0)
	ble	$t1, $s3, check_and_swap # while a[hi] > pivot
	sub	$s1, $s1, 4
	j	right_loop
check_and_swap:
	ble	$s1, $s0, recursive	# hi <= lo -> break
	add	$sp, $sp, -4			
	sw	$a0, 0($sp)
	add	$sp, $sp, -4
	sw	$a1, 0($sp)
	add	$sp, $sp, -4
	sw	$ra, 0($sp)
	add	$a1, $a0, $s1
	add	$a0, $a0, $s0
	jal	swap			# swap a[lo] and a[hi]
	lw	$ra, 0($sp)
	add	$sp, $sp, 4
	lw	$a1, 0($sp)
	add	$sp, $sp, 4
	lw	$a0, 0($sp)
	add	$sp, $sp, 4
	j	partition_loop
recursive:
	add	$sp, $sp, -4
	sw	$ra, 0($sp)
	add	$sp, $sp, -4
	sw	$a1, 0($sp)
	add	$sp, $sp, -4
	sw	$a2, 0($sp)
	add	$sp, $sp, -4
	sw	$s4, 0($sp)
	move	$a2, $s4
	jal	qsort		# qsort(arr, left, mid)
	lw	$s4, 0($sp)
	add	$sp, $sp, 4
	lw	$a2, 0($sp)
	add	$sp, $sp, 4
	lw	$a1, 0($sp)
	add	$sp, $sp, 4
	add	$a1, $s4, 1	# mid + 1
	jal	qsort		# qsort(arr, mid + 1, right)
	lw	$ra, 0($sp)
	add	$sp, $sp, 4
return:
	jr	$ra

main:
	la	$a0, arr
	li	$t0, 6
	sw	$t0, 0($a0)
	li	$t0, 5
	sw	$t0, 4($a0)
	li	$t0, 4
	sw	$t0, 8($a0)
	li	$t0, 3
	sw	$t0, 12($a0)
	li	$t0, 2
	sw	$t0, 16($a0)
	li	$t0, 1
	sw	$t0, 20($a0)
	li	$a1, 0
	li	$a2, 5
	jal	qsort
exit:
	li	$v0, 10
	syscall

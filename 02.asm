.data
int_arr: .space 4004
fin: .asciiz "input.txt"
fout: .asciiz "output.txt"
filename: .space 40
open_mode: .word
buffer: .space 5100
.text
	nop
	j		main

swap:	#swap data of value cointained in address $a0 and $a1
	lw	$t0, 0($a0)
	lw	$t1, 0($a1)
	sw	$t0, 0($a1)
	sw	$t1, 0($a0)	
	jr	$ra

qsort:	# $a0: arr, $a1: left, $a2: right
	ble	$a2, $a1, return_qsort
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
	addi	$s0, $s0, 4
	addi	$s1, $s1, -4
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
	move	$a2, $s1
	sra	$a2, $a2, 2
	jal	qsort		# qsort(arr, left, rightI)
	lw	$s4, 0($sp)
	add	$sp, $sp, 4
	lw	$a2, 0($sp)
	add	$sp, $sp, 4
	lw	$a1, 0($sp)
	add	$sp, $sp, 4
	sra	$a1, $s1, 2
	add	$a1, $a1, 1	# rightI + 1
	jal	qsort		# qsort(arr, mid + 1, rightI)
	lw	$ra, 0($sp)
	add	$sp, $sp, 4
return_qsort:
	jr	$ra

allocate:
	li		$v0, 9
	syscall 
	jr		$ra

file_open:	#a0 = file name string address, a1 = mode (0 is read, 1 is write)
	li	$v0, 13
	li	$a2, 0
	syscall
	jr	$ra
	
file_read:
	la	$a1, buffer
	li	$a2, 5020
	li	$v0, 14
	syscall
	move	$v0, $a1
	jr	$ra

file_write:	##a0 is address of write buffer
	move	$a1, $a0
	li	$a0, 0
	li	$v0, 15
	syscall
	jr	$ra
file_close:
	li	$v0, 16
	syscall
	jr	$ra

atoi:	
	move	$s0, $a1
    	or      $v0, $zero, $zero   # num = 0
   	 or      $t1, $zero, $zero   # isNegative = false
    	lb      $t0, 0($a0)
    	bne     $t0, '+', isPos      # consume a positive symbol
    	addi    $a0, $a0, 1
isPos:
    	lb      $t0, 0($a0)
    	bne     $t0, '-', numloop
    	addi    $t1, $zero, 1       # isNegative = true
    	addi    $a0, $a0, 1
numloop:
    	lb      $t0, 0($a0)
    	slti    $t2, $t0, 58       # *str <= '9'
    	slti    $t3, $t0, '0'       # *str < '0'
	beq	$t0, 32, saveVal
    	beq     $t2, $zero, .done
    	bne     $t3, $zero, .done
    	sll     $t2, $v0, 1
    	sll     $v0, $v0, 3
    	add     $v0, $v0, $t2       # num *= 10
    	addi    $t0, $t0, -48
    	add     $v0, $v0, $t0
    	addi    $a0, $a0, 1
    	j   numloop
saveVal:
	sw 	$v0, 0($s0)
	addi 	$s0, $s0, 4
	addi    $a0, $a0, 1
	li	$v0, 0
	j       numloop
.done:
	sw 		$v0, 0($s0)
	move		$v0, $s0
	move		$v1, $a0
    	beq     	$t1, $zero, exit    # if num = -num
    	sub     	$v0, $zero, $v0
exit:
    	jr      	$ra         # return

ints_to_str: # a0: address of int arr, a1: bytes size
	li		$s7, 0		# s7 is the bytes count, will be return at $v1
	add		$t0, $0, $a0
	add		$v0, $0, $a2
	addi		$s0, $0, 0
	addi		$t9, $0, 10
	addi		$t8, $0, 0
	addi		$s3, $0, 48
	addi		$sp, $sp, -1
	sb		$0,	0($sp)
huge_loop:
	beq		$s0, $a1, return #a1 number of byte read
	add		$t1, $t0, $s0
	lw		$s1, 0($t1)
	addi		$s0, $s0, 4
tiny_loop:
	addi		$s7, $s7, 1
	div		$s1, $t9
	mfhi		$s2
	mflo		$s1
	addi		$sp, $sp, -1
	add		$s2, $s2, $s3
	sb		$s2, 0($sp)
	beq		$s1, $0, string_process
	j		tiny_loop
string_process:
	lb		$s6, 0($sp)
	beq		$s6, $0, cut_number
	addi		$sp, $sp, 1
	add		$a2, $v0, $t8
	addi		$t8, $t8, 1
	sb		$s6, 0($a2)	
	j		string_process
cut_number:
	add		$a2, $v0, $t8
	addi		$t8, $t8, 1
	addi		$s4, $0, 32
	sb		$s4, 0($a2)
	addi		$s7, $s7, 1
	j		huge_loop
return:
	# TODO: add 'EOF' to end of stringbuffer
	addi		$t8, $t8, -1 #subject to change
	add		$a2, $a2, $t8
	li		$s1, 10
	sb		$s1, 0($a2)
	addi		$sp, $sp, 1
	add		$v1, $s7, $0
	jr		$ra
main:
	la	$a0, fin
	li	$a1, 0
	jal	file_open
	li	$a0, 0
	jal	file_read
	move	$t0, $v0	# $t0 now contain input string
	jal	file_close
	move	$a0, $t0
	la	$a1, int_arr
	jal	atoi
	move	$t1, $v0
	move	$t0, $v1
	lw	$s0, 0($t1)
	addi	$t0, $t0, 2
	move	$a0, $t0
	la	$a1, int_arr
	addi	$sp, $sp, -4
	sw	$s0, 0($sp)
	jal	atoi
	lw	$s0, 0($sp)
	addi	$sp, $sp, 4
	nop	
	la 	$a0, int_arr
	li	$a1, 0
	move	$a2, $s0
	addi	$a2, $a2, -1
	addi	$sp, $sp, -4
	sw	$s0, 0($sp)
	jal	qsort
	lw	$s0, 0($sp)
	addi	$sp, $sp, 4
	nop

	la	$a0, int_arr
	move	$a1, $s0
	sll	$a1, $a1, 2
	la	$a2, buffer
	jal	ints_to_str
	move	$s1, $v1
	la	$a0, fout
	li	$a1, 1
	jal	file_open
	la	$a0, buffer
	addi	$a2, $s1, -1
	jal	file_write
	jal	file_close
	
program_exit:
	li	$v0, 10
	syscall
	nop

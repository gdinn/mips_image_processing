.data 0x10008000

vetor:	.word 1 2 3 4 5 6 7 8 9

.text

li $a0, 3
la $a1, 0x10008000
jal rotate90l
li $v0, 10
syscall

#for an nxm matrix where n=m
#https://en.wikipedia.org/wiki/In-place_matrix_transposition

#for n = 0 to N - 2
#    for m = n + 1 to N - 1
#        swap A(n,m) with A(m,n)

rotate90l:
	#	Register usage:
	#		a0: image height or width in pixels(since they are equal doesnt matter) 
	#		a1:	start address of the image
	#
	#		t0: line iterative index (n)
	#		t1: number of matrix lines (N)
	#		t2: stop condition of the upper for (forNminus2)
	#		t3: column iterative index (m)
	#		t4: stop condidition of the lower for (forNminus1)
	#		t5: byte A(n,m) address
	#		t6: byte A(m,n) address
	#		t7: line break address amount
	#		t8: start address for iterating A(n,n)
	#		t9: stack for saving registers before swapTerms call
	#			0($t9):  t0
	#			4($t9):  t1
	#			8($t9):  t2
	#			12($t9): t3
	#			16($t9): t4
	#			20($t9): t5
	#			24($t9): t6
	#			28($t9): t7
	#			32($t9): t8
	#			36($t9): ra (return address)

#for n = 0 to N - 2
#    for m = n + 1 to N - 1
#        swap A(n,m) with A(m,n)

	li $t0, 0 				#t0 will be n
	add $t1, $a0, $zero		 	#t1 will be N
	add $t1, $t1, 1 		#Will correct the zero-indexing of the matrix address
	add $t2, $t1, -2		#t2 will be the stop conditon of forNminus2
	mul $t7, $a0, 4			#t7 will be \n address amount
	add $t8, $a1, $zero		#t8 will be the A(n,n) adress
	forNminus2:
		beq $t0, $t2, end_forNminus2
		add $t3, $t0, 1		#t3 will be m
		add $t4, $t1, -1	#t4 will be the stop condition of forNminus1
		add $t5, $t8, $zero	#refresh the address of A(n,m)
		add $t6, $t8, $zero #refresh the address of A(m,n)
		forNminus1:
			beq $t3, $t4, end_forNminus1
			add $t5, $t5, 4
			add $t6, $t6, $t7
			#registerSave:
				add $sp, $sp, -40
				add $t9, $sp, $zero
				sw $t0, 0($t9)
				sw $t1, 4($t9)
				sw $t2, 8($t9)
				sw $t3, 12($t9)
				sw $t4, 16($t9)
				sw $t5, 20($t9)
				sw $t6, 24($t9)
				sw $t7, 28($t9)
				sw $t8, 32($t9)
				sw $ra, 36($t9)
			#end registerSave
			add $a0, $t5, $zero
			add $a1, $t6, $zero
			jal swapTerms
			#registerRecovery:				
				lw $t0, 0($t9)
				lw $t1, 4($t9)
				lw $t2, 8($t9)
				lw $t3, 12($t9)
				lw $t4, 16($t9)
				lw $t5, 20($t9)
				lw $t6, 24($t9)
				lw $t7, 28($t9)
				lw $t8, 32($t9)
				lw $ra, 36($t9)
				add $sp, $sp, 40
			#end registerRecovery
			add $t3, $t3, 1
			j forNminus1
		end_forNminus1:
		#end
		add $t8, $t8, $t7
		add $t8, $t8, 4
		add $t0, $t0, 1
		j forNminus2
	end_forNminus2:
	#end
	jr $ra
#end rotate90l

swapTerms:
	#	Register usage:
	#		a0: address of the first term
	#		a1: address of the second term
	lw $t0, 0($a0)
	lw $t1, 0($a1)
	sw $t1, 0($a0)
	sw $t0, 0($a1)
	jr $ra
#end swapTerms
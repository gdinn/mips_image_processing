.data 0x10000000

strMenuWait: .asciiz "\n\n\n\n Please wait ....... \n\n\n\n\n"
strMenuHr: .asciiz " \n"
strMenuOpts: .asciiz "Select an option: \n"
srtMenuOp1: .asciiz "1 - Reset image \n"
strMenuOp2: .asciiz "2 - Rotate colors \n"
strMenuOp3: .asciiz "3 - Rotate image 90 degree left \n"
strMenuOp4: .asciiz "4 - Rotate image 90 degree right \n"
strMenuOp5: .asciiz "5 - Mirror image through x axis \n"
strMenuOp6: .asciiz "6 - Mirror image through y axis \n"
strMenuOp7: .asciiz "7 - Invert colors \n"
strMenuOp8: .asciiz "8 - Greyscale \n"
strMenuOp9: .asciiz "9 - Greenscale \n"
strMenuOp10: .asciiz "10 - Histogram \n"
strMenuOp11: .asciiz "11 - Pixel average filter\n"
strMenuOp12: .asciiz "12 - Contrast adjust\n"
strMenuOp13: .asciiz "Other - Exit \n"

strErrOpenFile: .asciiz "Error opening the file. Are you sure that the name is correct?\n"
strErrReadFile: .asciiz "Error reading the file. Are you sure that it is a bmp compatible file? \n"
filename: .asciiz "img.bmp"
header: .space 54	#54 bytes is the standard header size for a true color bmp image 
					#		to read
					# The pixel size must bit 3 bytes (24bits) too.
					# Uncompressed image as well
.text

main:

	jal loadImage
	#Will read the image at the same directory as mars is located and loads and copy at $sp and
	#	$gp. The idea behind it is making two copies is that one of these will be the displayed 
	#	image with (or without) filters applied. If the user chooses he can reset the image to 
	#	the the original state wich means a copy of the data at $sp to $gp.
	#	Use: $a0~$a2, $t0~$t9, $v0 and $v1. $v0 and $v1 will be the returns with the address to the
	#		data info and the data.

	add $s0, $v0, $zero
	add $s1, $v1, $zero

	menuOptsScr:
		li $v0, 4
		la $a0, strMenuHr
		syscall

		li $v0, 4
		la $a0, strMenuOpts
		syscall

		li $v0, 4
		la $a0, srtMenuOp1
		syscall

		li $v0, 4
		la $a0, strMenuOp2
		syscall

		li $v0, 4
		la $a0, strMenuOp3
		syscall

		li $v0, 4
		la $a0, strMenuOp4
		syscall

		li $v0, 4
		la $a0, strMenuOp5
		syscall

		li $v0, 4
		la $a0, strMenuOp6
		syscall

		li $v0, 4
		la $a0, strMenuOp7
		syscall

		li $v0, 4
		la $a0, strMenuOp8
		syscall		

		li $v0, 4
		la $a0, strMenuOp9
		syscall	

		li $v0, 4
		la $a0, strMenuOp10
		syscall

		li $v0, 4
		la $a0, strMenuOp11
		syscall		

		li $v0, 4
		la $a0, strMenuOp12
		syscall

		li $v0, 4
		la $a0, strMenuOp13
		syscall


		li $v0, 5
		syscall

		add $t0, $v0, $zero

		li $v0, 4
		la $a0, strMenuWait
		syscall		
		
		beq $t0, 1, resetImageCall
		beq $t0, 2, rotateColorsCall
		beq $t0, 3, rotate90lCall
		beq $t0, 4, rotate90rCall
		beq $t0, 5, flipXCall
		beq $t0, 6, flipYCall
		beq $t0, 7, invertColorsCall
		beq $t0, 8, greyScaleCall
		beq $t0, 9, greenScaleCall
	
		bgt $t0, 13, endProgram
	#end menuOptsScr


	resetImageCall:
		add $a0, $s0, $zero
		add $a1, $s1, $zero	
		jal dispOriginal
		j menuOptsScr
	#end resetImageCall

	rotateColorsCall:
		add $a0, $s0, $zero
		add $a1, $s1, $zero		
		jal rotateColors
		j menuOptsScr
	#end rotateColorsCall

	rotate90lCall:
		lw $a0, 4($s0)	
		la $a1, 0x10008000
		jal rotate90l
		add $a0, $s0, $zero
		la $a1, 0x10008000
		jal flipX		
		j menuOptsScr		
	#end rotate90lCall
	
	rotate90rCall:
		lw $a0, 4($s0)	
		la $a1, 0x10008000
		jal rotate90r
		add $a0, $s0, $zero
		la $a1, 0x10008000
		jal flipX		
		j menuOptsScr
	#end rotate90rCall

	flipXCall:
		add $a0, $s0, $zero
		la $a1, 0x10008000
		jal flipX
		j menuOptsScr
	#end rotateXCall

	flipYCall:
		add $a0, $s0, $zero
		la $a1, 0x10008000
		jal flipY
		j menuOptsScr
	#end rotateXCall

	invertColorsCall:
		add $a0, $s0, $zero
		la $a1, 0x10008000
		jal invertColors
		j menuOptsScr
	#end invertColorsCall

	greyScaleCall:
		add $a0, $s0, $zero
		la $a1, 0x10008000
		jal greyScale
		j menuOptsScr
	#end invertColorsCall

	greenScaleCall:	
		add $a0, $s0, $zero
		la $a1, 0x10008000
		jal greenScale
		j menuOptsScr
	#end invertColorsCall	

	#//jal rotateColors
	#Will read the image from the display segment ($gp) and will apply the rotateColors filter.
	#	Use: $a0 and $a1 which are the image properties and data, respectively.

	#//add $a0, $s0, $zero
	#//add $a1, $s1, $zero
	#//jal dispOriginal
	#Will read the image data from the stack and clean the display image
	#	Use $t0, $t1, $t2, $t3, $t4, $t5, $t8 and $t9.	

	#//lw $a0, 4($s0)	
	#//la $a1, 0x10008000
	#//jal rotate90r
	#Will rotate the displayed image 90 degree do the right

	#//lw $a0, 4($s0)	
	#//la $a1, 0x10008000
	#//jal rotate90l
	#Will rotate the displayed image 90 degree do the left

	jal endProgram #Lembrar de devolver toda a memória
#end main

greyScale:
	#	Register usage:
	#		t0: data info address backup
	#		t1: data address backup
	#		t2: screen iterative address beggining by 0x10008000
	#			t3(temporary): height of the image
	#			t4(temporary): width of the image
	#		t3: max number of iterations
	#		t4: iterative index
	#		t5: image byte
	

	add $t0, $a0, $zero
	add $t1, $a1, $zero
	

	la $t2, 0x10008000		#t2: screen start address (iterative)

	lw $t3, 4($t0)			
	lw $t4, 8($t0)			
	mul $t3, $t3, $t4

	li $t4, 1				#t4: iterative index

	
	loop_greyScale:
		beq $t3, $t4, end_loop_greyScale
		lbu $t5, 0($t2)
		mul $t5, $t5, 1140
		div $t5, $t5, 10000
		lbu $t6, 1($t2)	 
		mul $t6, $t6, 5870
		div $t6, $t6, 10000
		#sll $t6, $t6, 8
		add $t5, $t5, $t6
		lbu $t7, 2($t2)	
		mul $t7, $t7, 2989
		div $t7, $t7, 10000		
		#sll $t7, $t7, 16
		add $t5, $t5, $t7

		add $t6, $t5, $zero
		sll $t6, $t6, 8
		add $t7, $t5, $zero
		sll $t7, $t7, 16

		add $t5,$t5, $t6
		add $t5,$t5, $t7

		sw $t5, 0($t2)

		add $t2, $t2, 4
		add $t4, $t4, 1
		j loop_greyScale
	end_loop_greyScale:		
	#end	

	jr $ra

#end greyScale

greenScale:
	#	Register usage:
	#		t0: data info address backup
	#		t1: data address backup
	#		t2: screen iterative address beggining by 0x10008000
	#			t3(temporary): height of the image
	#			t4(temporary): width of the image
	#		t3: max number of iterations
	#		t4: iterative index
	#		t5: image byte
	

	add $t0, $a0, $zero
	add $t1, $a1, $zero
	

	la $t2, 0x10008000		#t2: screen start address (iterative)

	lw $t3, 4($t0)			
	lw $t4, 8($t0)			
	mul $t3, $t3, $t4

	li $t4, 1				#t4: iterative index

	
	loop_greenScale:
		beq $t3, $t4, end_loop_greenScale
		lbu $t5, 0($t2)
		mul $t5, $t5, 1140
		div $t5, $t5, 10000
		lbu $t6, 1($t2)	 
		mul $t6, $t6, 5870
		div $t6, $t6, 10000
		sll $t6, $t6, 8
		add $t5, $t5, $t6
		lbu $t7, 2($t2)	
		mul $t7, $t7, 2989
		div $t7, $t7, 10000		
		sll $t7, $t7, 16
		addu $t5, $t5, $t7
		sw $t5, 0($t2)
		sb $zero, 4($t2)
		add $t2, $t2, 4
		add $t4, $t4, 1
		j loop_greenScale
	end_loop_greenScale:		
	#end	

	jr $ra

#end greenScale


invertColors:
	#	Register usage:
	#		t0: data info address backup
	#		t1: data address backup
	#		t2: screen iterative address beggining by 0x10008000
	#			t3(temporary): height of the image
	#			t4(temporary): width of the image
	#		t3: max number of iterations
	#		t4: iterative index
	#		t5: image byte
	#		$t9: 255

	add $t0, $a0, $zero
	add $t1, $a1, $zero
	li $t9, 255

	la $t2, 0x10008000		#t2: screen start address (iterative)

	lw $t3, 4($t0)			
	lw $t4, 8($t0)			
	mul $t3, $t3, $t4

	li $t4, 1				#t4: iterative index

	loop_invertColors:
		beq $t3, $t4, end_loop_invertColors
		lb $t5, 0($t2)
		sub $t5, $t9, $t5
		lb $t6, 1($t2)	
		sub $t6, $t9, $t6
		sll $t6, $t6, 8 
		add $t5, $t5, $t6
		lb $t7, 2($t2)	
		sub $t7, $t9, $t7
		sll $t7, $t7, 16
		add $t5, $t5, $t7
		sw $t5, 0($t2)
		add $t2, $t2, 4
		add $t4, $t4, 1
		j loop_invertColors
	end_loop_invertColors:		
	#end	

	jr $ra
#end invertColors

rotate90r:
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

	li $t0, 0 				#t0 will be n
	add $t1, $a0, $zero		 	#t1 will be N
	add $t1, $t1, 1 		#Will correct the zero-indexing of the matrix address
	add $t2, $t1, -2		#t2 will be the stop conditon of forNminus2
	mul $t7, $a0, 4			#t7 will be \n address amount
	add $t8, $a1, $t7		#t8 will be the A(n,n) adress
	add $t8, $t8, -4
	forNminus2r:
		beq $t0, $t2, end_forNminus2r
		add $t4, $t0, 1		#t3 will be m
		add $t3, $t1, -1	#t4 will be the stop condition of forNminus1
		add $t5, $t8, $zero #refresh the address of A(n,m)
		add $t6, $t8, $zero #refresh the address of A(m,n)
		forNminus1r:
			beq $t3, $t4, end_forNminus1r
			sub $t5, $t5, 4
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
			sub $t3, $t3, 1
			j forNminus1r
		end_forNminus1r:
		#end
		add $t8, $t8, $t7
		sub $t8, $t8, 4
		add $t0, $t0, 1
		j forNminus2r
	end_forNminus2r:
	#end
	jr $ra
#end rotate90r

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

flipY:
	#	Register usage:
	#		a0: data info
	#		a1:	start address of the image
	#
	#		t0: column iteration index
	#		t1: column limit of iterations (width/2)
	#		t2: line iteration index
	#		t3: line limit of iterations (height)
	#		t4: line start address
	#		t5: line break
	#		t6: left byte addres
	#		t7: right byte addres
	#		t8: left byte
	#		t9:  right byte
	li $t0, 0
	lw $t1, 4($a0)
	div $t1, $t1, 2
	li $t2, 0
	lw $t3, 8($a0)
	add $t4, $a1, $zero
	mul $t5, $t3, 4
	add $t6, $t4, $zero
	add $t7, $t4, $t5
	add $t7, $t7, -4
	loop_flixY:
		beq $t2, $t3, end_loop_flipY
		beq $t0, $t1, refreshFlipY		
		lw $t8, 0($t6)
		lw $t9, 0($t7)
		sw $t9, 0($t6)
		sw $t8, 0($t7)

		add $t6, $t6, 4
		add $t7, $t7, -4
		add $t0, $t0, 1


		j loop_flixY
	end_loop_flipY:
	#end

	
	jr $ra

	refreshFlipY:
		li $t0, 0
		add $t2, $t2, 1
		add $t4, $t4, $t5
		add $t6, $t4, $zero
		add $t7, $t6, $t5
		add $t7, $t7, -4
		j loop_flixY
	#end refreshFlipY
#end flipY

flipX:
	#	Register usage:
	#		a0: data info
	#		a1:	start address of the image
	#
	#		t0: column iteration index
	#		t1: column limit of iterations (width)
	#		t2: line iteration index
	#		t3: line limit of iterations (height/2)
	#		t4: upper byte address
	#		t5: lower byte address
	#		t6: line break address for the lower byte
	#		t7: uper byte 
	#		t8: lower byte
	#		t9: 

	li $t0, 0				#t0: column iteration index
	lw $t1, 4($a0)			#t1: column limit of iterations (width)
	li $t2, 0				#t2: line iteration index
	lw $t3, 8($a0)			
	add $t4, $a1, $zero 	#t4: upper byte address
	mul $t5, $t3, $t1		
	mul $t5, $t5, 4		
	add $t5, $t5, $t4	
	add $t5, $t5, -4	
	mul $t7, $t1, 4
	sub $t5, $t5, $t7
	add $t5, $t5, 4			#t5: lower byte address
	mul $t6, $t1, 8			#t6: line break address for the lower byte
	

	div $t3, $t3, 2			#t3: line limit of iterations (height/2)


	loop_flipX:
		beq $t0, $t1, refreshFlipX
		beq $t2, $t3, end_loop_flipX

		lw $t7, 0($t4)
		lw $t8, 0($t5)
		sw $t8, 0($t4)
		sw $t7, 0($t5)

		add $t4, $t4, 4
		add $t5, $t5, 4
		add $t0, $t0, 1		
		j loop_flipX
	end_loop_flipX:
	#end

	jr $ra

	refreshFlipX:
		add $t0, $zero $zero
		add $t2, $t2, 1
		sub $t5, $t5, $t6 
		j loop_flipX
	#end refreshFlipX
#end flipX

rotateColors:
	#	Register usage:
	#		t0: data info address backup
	#		t1: data address backup
	#		t2: screen iterative address beggining by 0x10008000
	#			t3(temporary): height of the image
	#			t4(temporary): width of the image
	#		t3: max number of iterations
	#		t4: iterative index
	#		t5: image byte


	add $t0, $a0, $zero
	add $t1, $a1, $zero

	la $t2, 0x10008000		#t2: screen start address (iterative)

	lw $t3, 4($t0)			
	lw $t4, 8($t0)			
	mul $t3, $t3, $t4

	#lw $t3, 0($t0)

	#mul $t3, $t3, 4			#t3: max number of iterations

	li $t4, 1				#t4: iterative index

	loop_rotateColors:
		beq $t3, $t4, end_loop_rotateColors
		lb $t5, 2($t2)			#ou lb $t5, 2($t2)
		lb $t6, 0($t2)			#ou lb $t6, 0($t2)
		sll $t6, $t6, 8 
		add $t5, $t5, $t6
		lb $t7, 1($t2)			#ou lb $t7, 1($t2)
		sll $t7, $t7, 16
		add $t5, $t5, $t7
		sw $t5, 0($t2)
		add $t2, $t2, 4
		add $t4, $t4, 1
		j loop_rotateColors
	end_loop_rotateColors:		
	#end

	jr $ra	
#end rotateColors
	

loadImage:
	add $t6, $ra, $zero

	la $a0, filename
	jal openFile
		#openFile will take $a0 as the name of the file and will take care of
		#		the rest of the parameters to open the file.
		#Use: $a0, $a1, $v0. $v0 will return file descriptor

	la $a1, header 		# Address of the space to copy the file header
	li $a2, 54			# No. of bytes to read
	jal readHeader
		#readHeader will take openFile's return (file descriptor $v0) plus $a1 and $a2.
		#Use: $a0, $a1, $a2, $v0. $a0 will return the memory address with the raw data of the header
	
	add $t7, $a0, $zero #save file descriptor to use in storeImage procedure

	la $a0, header 		#$a0 will be the address of the readen data.
						#It's important that the header follow the 54 byte rule.
	jal analyseHeader
		#analyseHeader will analyse the info that was read by readHeader and will put the 
		#		most relevant info at $t8 and will alocate the suficient amount of stack
		#		to $t9 to store the file in storeImage procedure.
		#Use $t0, $t1, $t2, $t3, $t4. Will output $t8 as the relevant info and $t9 as the image data.


	jal storeImage
		#Use $a0, $a1, $a2, $t8, $t9, $t7 and $v0.

	add $a0, $t8, $zero
	add $a1, $t9, $zero
	jal dispOriginal
		#Use $t0, $t1, $t2, $t3, $t4, $t5, $t8 and $t9.

	add $v0, $t8, $zero 	#Return the data info
	add $v1, $t9, $zero 	#Return the data

	add $ra, $t6, $zero
	jr $ra
#end loadImage


dispOriginal:
	la $t0, 0x10008000		#screen address
	lw $t1, 4($a0)
	lw $t2, 8($a0)
	mul $t3, $t1, $t2
	mul $t3, $t3, 4
	add $t0, $t0, $t3 
	mul $t4, $t1, 4
	sub $t0, $t0, $t4
	
	#registerSave:
		add $sp, $sp, -12
		add $a0, $sp, $zero
		sw $s0, 0($a0)
		sw $s1, 4($a0)
		sw $s2, 8($a0)
		#s0 will be the iterative width index
		#s1 will be the limit of iterations
		#s2 will be the reverse line break
	#end registerSave	
	mul $t5, $t2, 4 
	li $s0, 0
	mul $s1, $t1, 4
	add $s2, $t5, $t5


	add $t1, $a1, $zero 	#iterative data address
	li $t2, 1 			#index
	add $t3, $zero, 0x10008000
	loop_dispOriginal:
		blt $t0, $t3, end_loop_dispOriginal
		beq $s0, $s1, nextLineDispOriginal

		lb $t4, 0($t1)

		lb $t5, 1($t1)
		sll $t5, $t5, 8
		add $t4, $t4, $t5

		lb $t5, 2($t1)
		sll $t5, $t5, 16
		add $t4, $t4, $t5

		sw $t4, 0($t0)
		add $t1, $t1, 3		
		add $s0, $s0, 4
		add $t0, $t0, 4		
		j loop_dispOriginal		
	end_loop_dispOriginal:
	#end
	#registerrecovery:		
		lw $s0, 0($a0)
		lw $s1, 4($a0)
		lw $s2, 8($a0)
		add $sp, $sp, 12
	#end registerRecovery
	jr $ra
#end dispOriginal

nextLineDispOriginal:
	li $s0, 0	
	sub $t0, $t0, $s2
j loop_dispOriginal

dispOriginal2:
	la $t0, 0x10008000		#screen address

	lw $t1, 4($a0)
	lw $t2, 8($a0)
	mul $t3, $t1, $t2
	mul $t3, $t3, 4
	add $t0, $t0, $t3 


	add $t1, $a1, $zero 	#iterative data address
	li $t2, 0 			#index
	lw $t3, 0($a0)			#limit number of iterations
	loop_dispOriginal2:
		beq $t2, $t3, end_loop_dispOriginal2

		lb $t4, 0($t1)

		lb $t5, 1($t1)
		sll $t5, $t5, 8
		add $t4, $t4, $t5

		lb $t5, 2($t1)
		sll $t5, $t5, 16
		add $t4, $t4, $t5

		sw $t4, 0($t0)
		add $t1, $t1, 3
		add $t0, $t0, -4
		add $t2, $t2, 3
		j loop_dispOriginal2		
	end_loop_dispOriginal2:
	#end
	jr $ra
#end dispOriginal2



storeImage:
	add $a1, $t9, $zero
	lw $a2, 0($t8)
	add $a0, $t7, $zero
	li $v0, 14			# read file parameter
	syscall				
	blt $v0, $zero, errReadFile
	jr $ra
#end storeImage

analyseHeader:
	la $t0, header

	#errorControl:
		#fileHeaderCheck
			#The first 2 bytes are suposed to be (424d)h
			lb $t1, 0($t0)	#Should be (42)h
			lb $t2, 1($t0)	#Should be (4D)h
			bne $t1, 0x42, errReadFile
			bne $t2, 0x4d, errReadFile

			#The 7th, 8th, 9th and 10th bytes are reserved and suposed to be 0
			#Since memory is zero-indexed we start by the address of number 6
			lb $t1, 6($t0)
			lb $t2, 7($t0)
			lb $t3, 8($t0)
			lb $t4, 9($t0)
			bne $t1, $zero, errReadFile
			bne $t2, $zero, errReadFile
			bne $t3, $zero, errReadFile
			bne $t4, $zero, errReadFile

			#Since we are dealing with a True Color bmp image, we should check if the
			#	BfOffSetBits field is (54)d as expected.
			lb $t1, 10($t0)
			bne $t1, 54, errReadFile
		#end fileHeaderCheck

		#bitmapHeaderCheck
			#Checking BiSize field that has a fixed value of (40)d
			lb $t1, 14($t0)
			bne $t1, 40, errReadFile

			#Checking the BiPlane field that has a fixed value of (1)d
			lb $t1, 26($t0)
			bne $t1, 1, errReadFile

			#Checking BiBitCount field, that says how much bits a pixel need
			#	If more or less than 24 the program will abort.
			lb $t1, 28($t0)
			bne $t1, 24, errReadFile

			#Checking BiCompress field, which must be zero
			lb $t1, 30($t0)
			bne $t1, 0, errReadFile
		#end bitmapHeaderCheck
	#end errorControl

	#At this point we already know that the image is the type we are looking for
	#Lets save some important data then!

	#dataSave:
		# $t8 will be the adress located in the stack that will store:
		#		0($t8) = Image start address
		# 		4($t8) = Image width (largura) in pixels
		#		8($t8) = Image height (altura) in pixels
		# This memory segment will be used as reference for the various operations
		#		that will be performed.

		addi $sp, $sp, -12
		add $t8, $sp, $zero

		#loadWidth:
			#Load each byte of the field and dislocate to compose the full int number
			lb $t1, 18($t0)
			lb $t2, 19($t0)
			sll $t2, $t2, 8
			add $t1, $t1, $t2
			lb $t2, 20($t0)
			sll $t2, $t2, 16
			add $t1, $t1, $t2
			lb $t2, 21($t0)
			sll $t2, $t2, 24
			add $t1, $t1, $t2
		#end loadWidth

		#loadHeight:
			#Load each byte of the field and dislocate to compose the full int number
			lb $t2, 22($t0)
			lb $t3, 23($t0)
			sll $t3, $t3, 8
			add $t2, $t2, $t3
			lb $t3, 24($t0)
			sll $t3, $t3, 16
			add $t2, $t2, $t3
			lb $t3, 25($t0)
			sll $t3, $t3, 24
			add $t2, $t2, $t3
		#end loadWidth		

		#I know that lwr would do the trick but since it wasnt working at the 
		#	time, i did this not so elegant thing with loadHeight and loadWidth that work.

		#loadSize: #Its important to know the size of the image for the apropriate
					# stack pointer decrement
			#Load each byte of the field and dislocate to compose the full int number
			lb $t3, 34($t0)
			lb $t4, 35($t0)
			sll $t4, $t4, 8
			add $t3, $t3, $t4
			lb $t4, 36($t0)
			sll $t4, $t4, 16
			add $t3, $t3, $t4
			lb $t4, 37($t0)
			sll $t4, $t4, 24
			add $t3, $t3, $t4

		#end loadSize	

		#Save obtained values at $t8
		sw $t3, 0($t8)
		sw $t1, 4($t8)
		sw $t2, 8($t8)

		#Allocate the size of the bitmap of the image in bytes at the stack.
		sub $sp, $sp, $t3
		add $t9, $sp, $zero


	#end dataSave	

	jr $ra

#end analyseHeader

openFile:
	#sycall for open the file
	li $v0, 13			# parametro p chamada de abertura
	li $a1, 0			# flags (0=read, 1=write)
	li $a2, 0			# mode = desnecessário
	syscall				# devolve o descritor (ponteiro) do arquivo em $v0
	blt $v0, $zero, errOpenFile
	jr $ra
#end openFile

readHeader:
	move $a0, $v0
	li $v0, 14			# parametro de chamada de leitura de arquivo	
	syscall				# devolve o número de caracteres lidos
	blt $v0, $zero, errReadFile
	jr $ra
#end readHeader


errOpenFile:
	#If the file does not exists this function will be triggered
	la $a0, strErrOpenFile
	jal printStr
	jal endProgram
#end errOpenFile

errReadFile:
	#If the file information does not come out as it should, this function will be triggered
	la $a0, strErrReadFile
	jal printStr
	jal endProgram
#end errReadFile

printStr:
	li $v0, 4
	syscall
	jr $ra
#end printStr

endProgram:
	li $v0, 10
	syscall



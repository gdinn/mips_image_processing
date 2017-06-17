.data

strErrOpenFile: .asciiz "Error opening the file. Are you sure that the name is correct?\n"
strErrReadFile: .asciiz "Error reading the file. Are you sure that it is a bmp compatible file? \n"
filename: .asciiz "img.bmp"
header: .space 540	#54 bytes is the standard header size for a true color bmp image 
					#		to read



.text

main:	
	la $a0, filename
	jal openFile
		#openFile will take $a0 as the name of the file and will take care of
		#		the rest of the parameters to open the file.

	la $a1, header 		# Address of the space to copy the file header
	li $a2, 54			# No. of bytes to read
	jal readHeader
		#readHeader will take openFile's return (file descriptor $v0) plus $a1 and $a2.

	la $a0, header 		#$a0 will be the address of the readen data.
						#It's important that the header follow the 54 byte rule.
	jal analyseHeader
		#analyseHeader will analyse the info that was read by readHeader and will put the 
		#		most relevant info at $s0.

	#encerra a execução do programa
	jal endProgram

		

analyseHeader:
	la $t0, header

	#errorControl:
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
	#end errorControl

	#At this point we already know that the image is the type we are looking for

	#dataSave:
	


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



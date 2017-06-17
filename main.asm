.data
cabecalho: .space 54
filename: .asciiz "lena.bmp"


.text
#abre arquivo
la $a0, filename	# endereço da string com o nome do arquivo
li $v0, 13			# parametro p chamada de abertura
li $a1, 0			# flags (0=read, 1=write)
li $a2, 0			# mode = desnecessário
syscall				# devolve o descritor (ponteiro) do arquivo em $v0

move $a0, $v0		# mode o descritor para $a0
li $v0, 14			# parametro de chamada de leitura de arquivo
la $a1, cabecalho	# endereço para armazenamento dos dados lidos
li $a2, 54			# tamanho máx de caracteres
syscall				# devolve o número de caracteres lidos

blt $v0, $zero, errOpenArchive


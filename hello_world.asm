.data

saludo: .asciiz "Hello, world"

.text

#Imprimo saludo	
la $a0, saludo
li $v0, 4
syscall
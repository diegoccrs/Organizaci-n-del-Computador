.data

saludo: .asciiz "Inserta un numero y te dare su factorial: " 


.text

main:

	#Saludo y pido input

	la $a0,saludo
	li $v0,4
	syscall
	
	li $v0,5
	syscall
	
	bltz $v0, main 
	
	#$t1 esta el input que me dio el usuario
	#$t2 esta el acumulado de la multiplicacion

	move $t1, $v0
	li $t2, 1
	
	bucle:
		#t2 = t2*t1
		mul $t2, $t2, $t1
		
		#t1 = t1 - 1
		subi $t1, $t1, 1
	
		beq $t1,1,exit
		b bucle
		
	exit: 
		
		move $a0, $t2
		li $v0, 1
		syscall
			
		b main
				
		li $v0, 10
		syscall
		
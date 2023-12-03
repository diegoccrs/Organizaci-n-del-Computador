.data

saludo: .asciiz "Hola, introduce un número y te dire si es primo: "
es_primo_mensaje: .asciiz "El numero es primo"
no_es_primo_mensaje: .asciiz "El numero no es primo"

.text

# $t1 => input


main: 

	#Aqui imprimo saludo	
	la $a0, saludo
	li $v0, 4	
	syscall
	
	#Aqui pido el input del usuario
	li $v0, 5
	syscall
	move $t1, $v0
	
	#t2 = t1 - 1
	subi $t2, $t1, 1
	
	bucle:
	
		#t1/t2
		div $t1, $t2
		
		#lo => me queda la division enter
		#hi => me queda mi residuo
		mfhi $t3
		
		#$t2 = t2 - 1
		subi $t2,$t2,1
		
		#Si t3 == 0 entonces es porque no es primo
		beqz $t3, no_es_primo
		
		#Si t2 > 1 es porque no he terminado de iterar
		bgt $t2, 1, bucle
		
		
		#Si llega hasta aqui es porque el numero es primo
		#Aqui imprimo que es primo
		la $a0, es_primo_mensaje
		li $v0, 4
		syscall
		b exit
		
		
		
		
	no_es_primo:
		#Aqui imprimo que no es primo
		la $a0, no_es_primo_mensaje
		li $v0, 4
		syscall
		
	exit:
	#Syscall 10
	li $v0, 10
	syscall
	
.data

cadena1: .asciiz "the quick brown fox jumped over the lazy dog"
vectorLetras: .space 26
respuesta: .asciiz "                                     "

.text

main: 

	#$t0 es el in	dice por el cual voy a buscar en cadena1
	li $t0, 0

	bucle: 

		#Cargo el valor de la letra en la posicion t0 del string
		lb $t1, cadena1($t0)
	
		#Si t1 es 0, entonces es porque ya no tiene nada que leer
		beqz $t1, listo
		beq $t1, 32, esEspacio
	
		#Convierto la letra a un valor numerico desde 0 hasta 25
		subi $t1, $t1, 97
	
		#Incremento la cantidad de letras correspondientes en 1
		lb $t2, vectorLetras($t1)
		addi $t2, $t2, 1
		sb $t2, vectorLetras($t1)
	
		
		addi $t0,$t0,1
	
		b bucle
	
	listo:
	
	#$t0 indice del vectorLetras
	#$t1 la cantidad de veces que tengo una letra en un posicion de vectorLetras
	#$t2 caracter a imprimir
	#$t3 va a guardar el numero de letra que le toca
	#$t4 indice de respuesta
	#$t5 indice de respuesta
	
	li $t0, 0
	li $t3, 0
	li $t5, 0
	
	
	imprimirChar:
	
	#Estoy cuardando el valor de vectorLetra{i} en t1
	lb $t1,vectorLetras($t0)
	
	#Recorro desde 0 a 26
	beq $t0, 26, exit
	
		
		imprimirLetra:
	
		#Si t1 vale 0 entonces es porque no hay ese caracter entonces va al siguiente
		beqz $t1, nextChar
		li $t4, 0
		#Convierto el valor que me dan en letra
		addi $t2, $t0, 97
	
		bucleLetra:
			
			#Guardo en la posicion respectiva la letra correspondiente
			sb $t2, respuesta($t5)
			
			#Le agrego 1 al contador de letras repetidas y de mi indice de respuestas
			addi $t4, $t4,1
			addi $t5, $t5, 1
			
			#Si mi contador de letras es menor a la cantidad de letras que tengo que imprimir entonces vuelve al bucle
			blt $t4, $t1, bucleLetra
	
	#Si no imprimo el proximo caracter
	nextChar:
	addi $t0,$t0,1
	b imprimirChar
	
	#Si es espacio va a cargar el primer elemento de vectorLetras y le sumará 1
	#luego lo volverá a cargar luego vuelve al bucle
	esEspacio:
	
		lb $t2, vectorLetras
		addi $t2, $t2, 1
		sb $t2, vectorLetras
		
		addi $t0,$t0,1
	
		b bucle
		
	exit:
	
	li $v0, 4
	la $a0, respuesta
	syscall
	
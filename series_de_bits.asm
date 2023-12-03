.data


msg: .asciiz "Hola, escribe una cadena de 32 bits: \n"
input: .asciiz "                                "
series_de_bits: .space 32
salto: .asciiz "\n"
msg2: .asciiz "Hay "
msg3: .asciiz " cadenas de "
msg4: .asciiz " bits."


.text

main:

	#Muestro mensaje y pido input
	li $v0, 4
	la $a0, msg
	syscall

	#Syscall 8 gaurda en a0 la direccion de lo que va a guardar y en a1 el límite mas 1 de caracteres
	li $v0, 8
	la $a0, input
	li $a1, 33
	syscall

	li $t0, 0

	#t0 índice por el que voy a ver en que caracter del input estoy
	#t1 el contador de veces que se repite un uno
	#t2 guardo lo que esta en la posicion t0 del input
	#t3 guarda el valor que esta en la posicion t1 de mis series_de_bits 
	
	loop:
	
		#Guarde el input en ascii, asi que lo convierto a 0 o 1 restandole 48(valor de 0 en ascii)
		lb $t2, input($t0)
		subi $t2, $t2, 48
	
		
		beqz $t2,es_cero
	
		addi $t1, $t1, 1
		addi $t0,$t0, 1
		blt $t0,32, loop	

		#Si lo que se recogió de la cadena de bits es 0, entonces es porque se rompió la cadena de bits
		#así que aumentaré en una unidad a la posición t1 de series_de_bits (lo que quiere decir es que 
		#hay una cadena mas de series de t1 bits
		es_cero:				

			lb $t3, series_de_bits($t1)
			addi $t3,$t3,1
			sb $t3, series_de_bits($t1)
			
			li $t1,0
			addi $t0,$t0,1

			#Cuando t0 sea 32 es porque ya visite todo el input, mientras no lo sea, lo sigo recorriendo
			blt $t0,32, loop


			li $v0, 4
			la $a0, salto
			syscall
			li $t0, 0

	
	#Ahora para imprimir la resspuesta debo de imprimir el mensaje desado por cada item no vacio de mi arreglo
	#serie_de_bits
	imprimir:
	

	lb $t5, series_de_bits($t0)

	bgt $t5, 0, imprimir_output

	continue:

	addi $t0,$t0,1

	blt $t0,32,imprimir

	li $v0,10
	syscall

	
	imprimir_output:

		li $v0, 4
		la $a0, msg2
		syscall

		li $v0,1
		move $a0, $t5
		syscall

		li $v0, 4
		la $a0, msg3
		syscall
	 
		li $v0,1
		move $a0, $t0
		syscall

		li $v0, 4
		la $a0, msg4
		syscall

		la $a0, salto
		syscall

		b continue
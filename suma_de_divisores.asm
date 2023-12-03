.data

saludo: .asciiz "Hola, dime un número: "
saludo2: .asciiz "La suma de sus divisores es "
es_deficiente_s: .asciiz ", es deficiente"
es_perfecto_s: .asciiz ", es perfecto"
es_abundante_s: .asciiz ", es abundante"

.text

main:

	#Saludo y pido input

	la $a0,saludo
	li $v0,4
	syscall
	
	li $v0,5
	syscall
	
	
	#$t1 esta el input que me dio el usuario
	#$t2 esta t1 - 1
	#$t3 esta el acumulado de la suma
	#$t4 el modulo
	
	move $t1, $v0
	subi $t2, $t1, 1
	li $t3, 0
	
	#Este bucle divide t1 entre cada uno de los numeros 
	#menores a el hasta llegar a 0. Si la division es 
	#propia lo añade al acumulador
	
	bucle:
	
		div $t1,$t2
		
		mfhi $t4
		beqz $t4, es_divisor
		
		subi $t2, $t2, 1
		bgtz $t2, bucle
		
		
	es_divisor:
	
		add $t3, $t3, $t2
		subi $t2, $t2, 1
		bgtz $t2, bucle 
		
		la $a0,saludo2
		li $v0,4
		syscall
		
		move $a0, $t3
		li $v0, 1
		syscall
		
		#Aqui empieza ejercicio 2
		
		
		#Guardo en v0 4 porque sea cual sea el caso voy a imprimir en el syscall
		
		
		li $v0, 4 
		
		#Si i acumulado es igual a t1, entonces es perfecto
		beq $t3, $t1, es_perfecto
		
		#Si i acumulado es mayo a t1, entonces es abundante
		bgt $t3, $t1, es_abundante
			
		#Si llego hasta aca es orque no es ni mayor ni igual
		#entonces es menor.
		la $a0, es_deficiente_s
		syscall
		b exit
		
		es_perfecto:
			
			la $a0, es_perfecto_s
			syscall
			b exit
			
		es_abundante:

			la $a0, es_abundante_s
			syscall
	
		exit: 
		
		li $v0,10
		syscall
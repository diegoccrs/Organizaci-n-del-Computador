#ESTA MACRO GENERA UN NUMERO ALEATORIO 
.macro numero_aleatorio(%maximo_del_rango,%registro_donde_quedara_guardado_el_numero_generado)
	li $v0,42
	li $a1,%maximo_del_rango
	syscall
	move %registro_donde_quedara_guardado_el_numero_generado,$a0
.end_macro

.macro decimal_hexadecimal(%numero)
	li $s0,0 #iterador
	li $s1,-1 #contador para imprimir
	move $t0, %numero
	loop:
#REALIZA UNA OPERACION "AND" ENTRE LOS ULTIMOS 4 BITS DEL NUMERO INGRESADO Y 1111(ESO ES 15 EN HEXADECIMAL= OXF).ESTO LO QUE HACE ES QUE TE GUARDA LOS ULTIMOS 4 BITS DEL NUMERO INGRESADO POR EL USUARIO EN BINARIO EN $T1
		andi $t1, $t0, 0xf
		
		#Guardamos en uno de los bytes reservados lo que esta en $t1	
		sb $t1,hexadecimal($s0)
		
		#$S0 IRA ITERANDO. $S0 ES EL QUE INDICA EN QUE BYTE DEL VECTOR RESERVADO SE IRA GUARDANDO CADA UNO DE LOS NIBBLES(MEDIOSBYTES) QUE SE VAN OBTENIENDO
		addi $s0,$s0,1
		
		#OPERACION SHIFT LOGICO DERECHO.BOTA LOS ULTIMOS 4BITS DE $T0,YA QUE NECESITAMOS QUE EN EL SIGUIENTE BUCLE LA OPERACION AND SE REALIZA CON LOS SIGUIENTES 4 BITS
		srl $t0,$t0,4
		
		addi $s1,$s1,1
		
		#FIN DEL BUCLE.SI $T0 ES IGUAL A CERO QUiere decir que ya no hay nada que nos interese el srl tiro todo a la basura
		beqz $t0,print
		
		#PARA QUE SIGA EL BUCLE
		j loop
	
	#LOS NUMEROS QUE HEMOS GUARDADO EN CADA BYTE DEL VECTOR ESTAN AL REVES,YA QUE HEMOS IDO GUARDANDO EN hexadecimal(0),hexadecimal(1),.... Y LEEMOS EL DIGITO DEL USUARIO DE DERECHA A IZQUIERDA
	
	print:
		lb $t3,hexadecimal($s1)
		li $v0,1
		move $a0,$t3
		syscall
		
		subi $s1,$s1,1
		
		beq $s1,-1,fin_de_la_macro
		
		j print
	
	exit:
		li $v0,10
		syscall
	fin_de_la_macro:
.end_macro 

.macro decimal_octal(%numero)
	move $t0,%numero #NUMERO QUE SERA CONVERTIDO A OCTAL
	li $t1,8 #constante
	li $t5,0 #sera el iterador que nos indicara en que posicion del array "octal" debemos guardar
	li $t4,-1#este contador nos servira para imprimir los numeros guardados en "octal"
	beq $t0,0,esCero #SI EL NUMERO DECIMAL ES 0 ENTONCES SOLO IMPRIMIREMOS UN 0 Y YA
	loop:
		div $t0,$t1 #dividimos el cociente entre 8
		
		mfhi $t2 #el residuo
		
		mflo $t3 #el cociente
		
		sb $t2,octal($t5)
		
		addi $t4,$t4,1
		
		addi $t5,$t5,1
		
		move $t0,$t3 #guardas el nuevo cociente
		
		bltu $t3,8,continua #SI EL COCIENTE ES MENOR A 8 ENTONCES TERMINAMOS
		
		j loop
	
	continua:
		#ESTA ETIQUETA GUARDA AL ULTIMO COCIENTE 
		sb $t3,octal($t5)
		addi $t4,$t4,1
	
	imprimir:
		#VAMOS DE ATRAS HACIA ADELANTE PORQUE NECESITAMOS IMPRIMIR DE DERECHA A IZQUIERDA
		lb $t9,octal($t4)
		#IMPRIMIMOS EL NUMERO OBTENIDO
		li $v0,1
		move $a0,$t9
		syscall
		
		subi $t4,$t4,1
		
		beq $t4,-1,fin_de_la_macro
		
		j imprimir
		
	esCero:
		li $v0,1
		li $a0,0
		syscall
		
	fin_de_la_macro:
.end_macro

.macro decimal_binario(%numero)
	move $t0,%numero #NUMERO QUE SERA CONVERTIDO A BINARIO
	li $t1,2 #constante
	li $t5,0 #sera el iterador que nos indicara en que posicion del array "binario" debemos guardar
	li $t4,-1#este contador nos servira para imprimir los numeros guardados en "binario"
	beq $t0,0,esCero #SI EL NUMERO DECIMAL ES 0 ENTONCES SOLO IMPRIMIREMOS UN 0 Y YA
	loop:
		div $t0,$t1 #dividimos el cociente entre 2
		
		mfhi $t2 #el residuo
		
		mflo $t3 #el cociente
		
		sb $t2,binario($t5)
		
		addi $t4,$t4,1
		
		addi $t5,$t5,1
		
		move $t0,$t3 #guardas el nuevo cociente
		
		beq $t3,1,continua
		
		j loop
	
	continua:
		#ESTA ETIQUETA ES PARA AGREGAR UN 1 AL FINAL DEL ARRAY "BINARIO",YA QUE AL FINAL DE LA CONVERSION SIEMPRE QUEDARA UN 1 DE RESIDUO
		li $a3,1
		sb $a3,binario($t5)
		addi $t4,$t4,1
	
	imprimir:
		#VAMOS DE ATRAS HACIA ADELANTE PORQUE NECESITAMOS IMPRIMIR DE DERECHA A IZQUIERDA
		lb $t9,binario($t4)
		#IMPRIMIMOS EL NUMERO OBTENIDO
		li $v0,1
		move $a0,$t9
		syscall
		
		subi $t4,$t4,1
		
		beq $t4,-1,fin_de_la_macro
		
		j imprimir
		
	esCero:
		li $v0,1
		li $a0,0
		syscall
	fin_de_la_macro:
	
.end_macro

.macro mover_enemigo(%posicion, %color_posicion, %contador)

	mov_enemigo:
		lw $s7,display(%posicion)#GUARDA EN $S7 EL COLOR ACTUAL DEL ENEMIGO
		bne $s7,0xff0000,saltar_al_siguiente_enemigo#SI EL COLOR DEL ENEMIGO NO ES ROJO SIGNIFICA QUE EL ENEMIGO ESTA MUERTO.POR LO TANTO, SALTAMOS A LA ETIQUETA "mover_siguiente_enemigo"
		continua:
			numero_aleatorio(4,$s7) #genera el numero aleatorio y lo guarda en $s7
			#DEPENDIENDO DEL NUMERO QUE TOCO ENTRARA EN ALGUNA DE ESTAS ETIQUETAS(EL NUMERO ALEATORIO ESTARA EN EL INTERVALO [0,3])
			beq $s7,3,abajo_enemigo #MUEVE AL ENEMIGO HACIA ABAJO
			beq $s7,1,arriba_enemigo #MUEVE AL ENEMIGO HACIA ARRIBA
			beq $s7,2,derecha_enemigo #MUEVE AL ENEMIGO HACIA LA DERECHA 
			beq $s7,0,izquierda_enemigo #MUEVE AL ENEMIGO HACIA LA IZQUIERDA
		
			movimiento_enemigo:
				lw $t3,display(%color_posicion) #OBTIENE EL COLOR QUE HAY ACTUALMENTE LA POSICION A LA QUE QUIERE IR EL ENEMIGO
				
				beq $t3,0xC0C0C0,mov_enemigo #SI ES GRIS DEVUELVETE Y NO HAGAS NADA
				beq $t3,0x00FF00,mov_enemigo #SI ES VERDE DEVUELVETE Y NO HAGAS NADA
				beq $t3,0xFFFF00,mov_enemigo #SI ES AMARILLO DEVUELVETE Y NO HAGAS NADA
				beq $t3,0xff0000,mov_enemigo #SI ES ROJO DEVUELVETE Y NO HAGAS NADA
				beq $t3,0xFF33FC,saltar_al_siguiente_enemigo #SI ES ROSADO SALTARA A LA ETIQUETA "saltar_al_siguiente_enemigo". ESTO SE DEBE A QUE EXISTE LA POSIBILIDAD DE QUE LAS 4 POSIBLES POSICIONES A LAS QUE QUIERE IR EL ENEMIGO SEAN DE LOS COLORES GRIS,AMARILLO,VERDE O ROSADO.SI ESTO OCURRIESE SE GENERARIA UN BUCLE INFINITO,YA QUE EL ENEMIGO NO PODRIA MOVERSE.
				beq $t3,0x0000ff,perder #SI ES AZUL ENTRA EN PERDER
				
				sw $t4,display(%posicion) #CAMBIA LA POSICION ACTUAL DEL ENEMIGO A BLANCO
				li $t0 0xff0000 #INICIALIZA EL ROJO
		
				sw $t0,display(%color_posicion) #COLOCA DE ROJO LA POSICION NUEVA DEL ENEMIGO
				move %posicion,%color_posicion #GUARDA LA NUEVA POSICION DEL ENEMIGO EN EL REGISTRO ESPECIFICADO PARA LA PROXIMA VEZ
		saltar_al_siguiente_enemigo:
			addi %contador, %contador, 1
			beq %contador,3,loop2 #SI EL CONTADOR ES 3 SIGNIFICA QUE YA SE MOVIO A TODOS LOS ENEMIGOS
			j mover_enemigos
			
		abajo_enemigo:
			addi %color_posicion,%posicion,64 #OBTIENE LA POSICION A LA QUE SE MOVERA EL ENEMIGO.SE DEBE SUMAR 64 A LA POSICION ACTUAL
			j movimiento_enemigo
		arriba_enemigo:
			subi %color_posicion,%posicion,64 #OBTIENE LA POSICION A LA QUE SE MOVERA EL ENEMIGO.PARA IR HACIA ABAJO DEBES SUMAR 64 A LA POSICION ACTUAL
			j movimiento_enemigo
		derecha_enemigo:
			addi %color_posicion,%posicion,4 #OBTIENE LA POSICION A LA QUE SE MOVERA EL ENEMIGO.PARA IR HACIA LA DERECHA DEBES SUMAR 4 A LA POSICION ACTUAL
			j movimiento_enemigo
	
		izquierda_enemigo:
			subi %color_posicion,%posicion,4 #OBTIENE LA POSICION A LA QUE SE MOVERA EL ENEMIGO.PARA IR HACIA LA DERECHA DEBES RESTAR 4 A LA POSICION ACTUAL
			j movimiento_enemigo
			
.end_macro

#ESTA MACRO RECIBE UN MAPA(UN ARRAY CON LOS COLORES RESPECTIVOS DE CADA POSICION) Y SE ENCARGA DE MOSTRARLO EN EL DISPLAY		
.macro cargar_mapa(%mapa, %iterador)
	verificar_color:
	
		lb $t2,%mapa(%iterador)
		
		#dependiendo del valor de $T2 va a entrar en alguno de estos condicionales
		beq $t2,0,color_blanco
		beq $t2,1,color_gris
		beq $t2,3,color_rojo
		beq $t2,4,color_azul
		beq $t2,5,color_verde
		
	color_gris:
		li $t0 0xC0C0C0 #GUARDA EL COLOR GRIS 
		
		mul $t3,%iterador,4 #se multiplica por 4 porque los espacios en el display van de 4 en 4 y en el arrary "mapa" van de 1 en 1.De esta forma obtenemos la posicion correspondiente en el display
	
		sw $t0,display($t3) #guardamos el color en la posicion correspondiente del display
	
		addi %iterador,%iterador,1 #incremetamos el iterador para la proxima vez que entre en el loop
	
	
		beq %iterador,256,fin_de_la_macro#si llega a 256 se termino el loop,ya que el array "mapa" solo tiene 256 elementos.Entrara en loop2 ya que ahi continua el programa
	
		j verificar_color #vuelve a entrar en el loop
		
	color_blanco:
		li $t0 0xFFFFFF #GUARDA EL COLOR BLANCO 
		
		mul $t3,%iterador,4
	
		sw $t0,display($t3)
	
		addi %iterador,%iterador,1
	
		beq %iterador,256,fin_de_la_macro
	
		j verificar_color
	
	color_verde:
		li $t0 0x00FF00 #GUARDA EL COLOR VERDE
		
		mul $t3,%iterador,4
	
		sw $t0,display($t3)
	
		addi %iterador,%iterador,1
	
		beq %iterador,256,fin_de_la_macro
	
		j verificar_color
		
	color_azul:
		li $t0 0x0000ff #GUARDA EL COLOR AZUL
		
		mul $t3,%iterador,4
	
		sw $t0,display($t3)
	
		addi %iterador,%iterador,1
		
	
		beq %iterador,256,fin_de_la_macro
	
		j verificar_color
		
	color_rojo:
		li $t0 0xff0000 #GUARDA EL COLOR ROJO
		
		mul $t3,%iterador,4
	
		sw $t0,display($t3)
	
		addi %iterador,%iterador,1
	
		beq %iterador,256,fin_de_la_macro
	
		j verificar_color
	
	fin_de_la_macro:
		

.end_macro


.data



display: .space 1024
mapa: .byte 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1     #Los 0 son espacios blancos
	    1 4 1 0 0 0 1 1 0 0 0 0 0 3 0 1	#Los 1 son espacios grises
	    1 0 1 1 1 0 1 1 0 1 1 1 0 0 0 1	#Los 2 son espacios amarillos
	    1 0 0 0 1 0 1 1 0 1 1 1 0 1 1 1	#Los 3 son espacios rojos(los enemigos)
	    1 0 1 0 0 0 0 0 0 0 0 0 0 1 0 1	#Los 4 son espacios azules(el muneco)
	    1 0 1 1 0 1 1 1 0 0 1 1 1 1 0 1	#Los 5 son espacios verdes(la meta)	    					
	    1 0 0 0 0 0 0 0 0 0 1 0 0 0 0 1	
	    1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 1	#ESTE ES EL MAPA DEL JUEGO
            1 0 0 0 0 0 1 0 0 0 0 0 1 0 1 1
	    1 0 1 1 1 0 1 1 0 1 1 0 1 0 0 1
	    1 0 0 1 1 0 1 1 0 0 0 0 1 0 1 1
	    1 0 1 1 1 0 1 1 0 0 1 1 1 0 0 1
	    1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
	    1 0 0 0 1 1 0 1 1 1 1 0 1 0 0 1
	    1 3 0 0 0 0 0 0 0 0 0 0 1 3 0 1
	    1 1 1 1 1 1 1 1 1 1 1 5 1 1 1 1
	    
mapa_win: .byte	5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5   #ESTE MAPA SE MOSTRARA PARA INDICARLE AL USUARIO QUE GANO
		5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5
	    	5 0 5 0 5 5 5 5 5 5 5 5 5 5 5 5
	   	5 0 5 0 5 5 5 0 5 5 0 5 5 5 5 5
	   	5 0 5 0 5 0 5 5 5 5 5 5 0 5 5 5
		5 0 5 0 5 5 0 5 5 5 5 0 5 5 5 5
	    	5 0 5 0 5 5 5 0 0 0 0 5 5 5 5 5
	   	5 0 0 0 5 5 5 5 5 5 5 5 5 5 5 5
	   	5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5
		5 0 5 5 5 0 5 0 0 0 5 0 5 5 0 5
	    	5 0 5 5 5 0 5 0 5 0 5 0 0 5 0 5
	   	5 0 5 0 5 0 5 0 5 0 5 0 5 0 0 5
	   	5 0 5 0 5 0 5 0 5 0 5 0 5 5 0 5
		5 0 5 0 5 0 5 0 5 0 5 0 5 5 0 5
	    	5 0 0 0 0 0 5 0 0 0 5 0 5 5 0 5
	   	5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5
	   	
mapa_los: .byte	3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3	  #ESTE MAPA SE MOSTRARA PARA INDICARLE AL USUARIO QUE PERDIO
		3 0 3 0 3 3 3 3 3 3 3 3 3 3 3 3
		3 0 3 0 3 3 3 3 3 3 3 3 3 3 3 3
		3 0 3 0 3 3 3 0 3 3 0 3 3 3 3 3
		3 0 3 0 3 3 3 3 3 3 3 3 3 3 3 3
		3 0 3 0 3 3 3 0 0 0 0 3 3 3 3 3
		3 0 0 0 3 3 0 3 3 3 3 0 3 3 3 3
		3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3
		3 0 3 3 0 0 0 3 0 0 0 3 0 0 0 3
		3 0 3 3 0 3 0 3 0 3 0 3 3 0 3 3
		3 0 3 3 0 3 0 3 0 3 3 3 3 0 3 3
		3 0 3 3 0 3 0 3 0 0 0 3 3 0 3 3
		3 0 3 3 0 3 0 3 3 3 0 3 3 0 3 3
		3 0 3 3 0 3 0 3 0 3 0 3 3 0 3 3
		3 0 0 3 0 0 0 3 0 0 0 3 3 0 3 3
		3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3
	    
	    
	  
		       
		       
input: .space 2
win: .asciiz "\nGanaste"
lost: .asciiz "\nPerdiste"
puntaje: .asciiz "\nTu puntaje es:\n"
salto: .asciiz "\n"

octal: .space 12
binario: .space 12
hexadecimal: .space 10

mdecimal: .asciiz " decimal"
mhexadecimal: .asciiz " hexadecimal"
mbinario: .asciiz " binario"
moctal: .asciiz " octal"

.text
	#GUARDAMOS LA POSICION DE LOS ENEMIGOS Y DEL MUNECO
	li $t6,116#ENEMIGO#1
	li $t7,900#ENEMIGO#2
	li $t8,948#ENEMIGO#3
	li $t9, 68#MUNECO AZUL
	
	li $s3, 0#ES EL ITERADOR DE LA ETIQUETA "mover_enemigos"
	li $s2, 0 #verifica si el jugador esta vivo o muerto
	li $t1 0 #es el iterador de la macro "cargar_mapa"
	li $s4, 0 #contador de monedas obtenidas por el jugador
	#CARGAMOS EL MAPA DEL JUEGO
	cargar_mapa(mapa,$t1)

	
	crear_monedas:
	
		beq $t2, 12, insertar_poder #si ya inserte todas las monedas voy a "insertar_poder"
		
		li $t0, 0xFFFF00 #cargo el color amarillo
		
		numero_aleatorio(256,$t5) #genera el numero aleatorio y lo guarda en $t5
		
		mul $t5, $t5, 4 #me muevo en el display
		
		lw $t3,display($t5) #veo lo que hay en esa posicion
		
		bne  $t3,0xFFFFFF, crear_monedas #si no es un espacio en blanco, me regreso
		
		sw $t0, display($t5) #si es blanco, inserto la moneda
		
		addi $t2, $t2, 1
		
		j crear_monedas

	insertar_poder: 
	
		li $t0 0xFF33FC #cargo el color rosado
		
		numero_aleatorio(256,$t5) #genera el numero aleatorio y lo guarda en $s7
		
		mul $t5, $t5, 4 #me muevo en el display
		
		lw $t3,display($t5) #veo lo que hay en esa posicion
		
		bne  $t3,0xFFFFFF, insertar_poder #si no es un espacio en blanco, me regreso
		
		sw $t0, display($t5) #si es blanco, inserto el poder
		
		j loop2

	loop2:
		beq $s2,1, exit #si no hemos muerto, seguimos
		li $t4 0xFFFFFF #inicializamos el color blanco
		
		#ESTE ES EL INPUT QUE RECIBE LA LETRA
		li $v0,8
		li $a1,2
		la $a0,input
		syscall
		
		#GUARDA LA LETRA QUE COLOCA EL USUARIO EN $t1
		li $t0,0
		lb $t1,input($t0)
		
		#DEPENDIENDO DE CUAL SEA LA LETRA ENTRARA EN ALGUNA DE ESTAS CONDICIONES QUE MOVERAN AL MUNECO A LA POSICION CORRESPONDIENTE
		beq $t1,115,abajo #s
		beq $t1,119,arriba #w
		beq $t1,100,derecha #d
		beq $t1,97,izquierda #a
		beq $t1,83,abajo #S
		beq $t1,87,arriba #W
		beq $t1,68,derecha #D
		beq $t1,65,izquierda #A
		
	abajo:
	 	addi $t5,$t9,64 #OBTIENE LA POSICION A LA QUE QUIERE IR EL USUARIO.SI EL USUARIO QUIERE IR HACIA ABAJO DEBES SUMAR 64 A LA POSICION ACTUAL
		j movimiento_jugador
	
	arriba:
	 	subi $t5,$t9,64 #OBTIENE LA POSICION A LA QUE QUIERE IR EL USUARIO.SI EL USUARIO QUIERE IR HACIA ARRIBA DEBES RESTAR 64 A LA POSICION ACTUAL
		j movimiento_jugador
	
	derecha:
		addi $t5,$t9,4 #OBTIENE LA POSICION A LA QUE QUIERE IR EL USUARIO. SI EL USUARIO QUIERE IR A LA DERECHA SE SUMA 4 A LA POSICION ACTUAL
		j movimiento_jugador
	izquierda:
		subi $t5,$t9,4 #OBTIENE LA POSICION A LA QUE QUIERE IR IR EL USUARIO. SI EL USUARIO QUIERE IR A LA IZQUIERDA SE RESTA 4 A LA POSICION ACTUAL
		j movimiento_jugador
	
	#LA POSICION A LA QUE QUIERE IR EL JUGADOR ESTA GUARDADA EN $t5
	movimiento_jugador:
		lw $t3,display($t5) #OBTIENE EL COLOR QUE HAY ACTUALMENTE EN LA POSICION A LA QUE QUIERE IR EL JUGADOR
		lw $t1,display($t9) #OBTIENE EL COLOR QUE HAY EN LA POSICION ACTUAL DEL JUGADOR
		
		#DEPENDIENDO DEL COLOR ACTUAL DEL JUGADOR ENTRARA EN UNA DE LAS DOS ETIQUETAS
		beq $t1,0x0000ff,movimiento_jugador_azul
		beq $t1,0xFF33FC,movimiento_jugador_rosado
		
		movimiento_jugador_azul:
			beq $t3,0xC0C0C0,loop2 #SI ES GRIS DEVUELVETE Y NO HAGAS NADA
			#beq $t3,0xFFFF00,moneda #SI ES UNA MONEDA AUMENTA EL PUNTAJE
			jal moneda
			beq $t3,0xff0000,perder #SI ES UN ENEMIGO MUERES
			beq $t3,0x00FF00,ganar #SI ES LA META GANAS
			
			
			#SI LA POSICION A LA QUE QUIERE IR EL JUGADOR NO ES GRIS,ROJO O VERDE. ENTONCES CONTINUAMOS
			sw $t4,display($t9) #CAMBIA LA POSICION ACTUAL DEL MUNECO A BLANCO
			
			#SI LA POSICION A LA QUE QUIERE IR EL JUGADOR ES ROSADO.ENTONCES SALTARA A LA ETIQUETA "siguiente"
			#ESTO SE DEBE A QUE NO HACE FALTA PONERLE COLOR AZUL A LA PROXIMA POSICION DEL JUGADOR
			beq $t3,0xFF33FC,siguiente #SI LA FUTURA POSICION ES ROSADA ENTRARA EN SIGUIENTE
			
			li $t0 0x0000ff #INICIALIZA EL AZUL
			sw $t0,display($t5) #COLOCA DE AZUL LA POSICION A LA QUE QUIERE IR EL JUGADOR
		
			siguiente:
				li $v1,0 #SE INICIALIZA EL REGISTRO QUE LLEVA LA CUENTA DE LOS MOVIMIENTOS DEL MUNECO CON EL SUPER PODER
				move $t9,$t5 #GUARDA EN $T9 LA POSICION NUEVA DEL MUNECO PARA LA SIGUIENTE ITERACION
				li $s3, 0 #SE REINICIA EL ITERADOR DE LA ETIQUETA "mover_enemigos"
				j mover_enemigos
		
		movimiento_jugador_rosado:
			
			beq $t3,0xC0C0C0,loop2 #SI ES GRIS DEVUELVETE Y NO HAGAS NADA
			jal moneda
			beq $t3,0x00FF00,ganar #SI ES LA META GANAS
		
			#SI LA POSICION A LA QUE QUIERE IR EL JUGADOR NO ES GRIS O VERDE. ENTONCES CONTINUAMOS
			sw $t4,display($t9) #CAMBIA LA POSICION ACTUAL DEL MUNECO A BLANCO
			li $t0 0xFF33FC #INICIALIZA EL ROSADO
		
			sw $t0,display($t5) #COLOCA DE ROSADO LA POSICION A LA QUE QUIERE IR EL JUGADOR
			move $t9,$t5 #GUARDA EN $T9 LA POSICION NUEVA DEL MUNECO PARA LA SIGUIENTE ITERACION
			li $s3, 0 #SE REINICIA EL ITERADOR DE LA ETIQUETA "mover_enemigos"
			addi $v1,$v1,1
			jal verificar_fin_del_poder
			j mover_enemigos
				
							
													
	#MUEVE A LOS ENEMIGOS
	mover_enemigos:
		# $s3 ES UN ITERADOR QUE INDICARA A QUE ENEMIGO CORRESPONDE MOVER Y CUANDO FINALIZAR
		beq $s3,0,mov_e1
		beq $s3,1,mov_e2
		beq $s3,2,mov_e3
		beq $s3,3,loop2 
		
	mov_e1:
		mover_enemigo($t6, $t5, $s3)
	mov_e2:
		mover_enemigo($t7, $t5, $s3)
	mov_e3:
		mover_enemigo($t8, $t5, $s3)	
	
			
	ganar:	
		addi $s4,$s4,100 #LE SUMAMOS 100 PUNTOS AL USUARIO POR LLEGAR A LA META
		addi $s2, $s2, 1
		la $a0, win
		li $v0, 4
		syscall
		jal mostrar_puntos
		li $t1,0
		cargar_mapa(mapa_win,$t1)
		j exit
		
	perder:
		addi $s2, $s2, 1
		la $a0, lost
		li $v0, 4
		syscall
		jal mostrar_puntos
		li $t1,0
		cargar_mapa(mapa_los,$t1)
		j exit
		
	
	exit:
		li $v0,10
		syscall
		
		
#SUBRUTINAS

verificar_fin_del_poder:
	beq $v1,40,continuamos #SOLO LE PERMITIMOS 40 MOVIMIENTOS
	jr $ra
	continuamos:
		li $t0 0x0000ff
		sw $t0,display($t9)
		jr $ra

#AUMENTA EL PUNTAJE
moneda:
	beq $t3,0xFFFF00, suma
	jr $ra
	suma:
		addi $s4, $s4, 10
		jr $ra

mostrar_puntos:
		la $a0, puntaje
		li $v0, 4 #"Tu puntaje es:"
		syscall
		
		li $v0, 1
		move $a0, $s4  #numero en decimal
		syscall
		
		la $a0, mdecimal
		li $v0, 4
		syscall
		
		la $a0, salto
		li $v0, 4
		syscall
		
		
		decimal_binario($s4)	#numero en octal
		
		la $a0, mbinario
		li $v0, 4
		syscall
		
		la $a0, salto
		li $v0, 4
		syscall
		
		
		decimal_octal($s4) #numero en binario
		
		la $a0, moctal
		li $v0, 4
		syscall
		
		la $a0, salto
		li $v0, 4
		syscall
		
		decimal_hexadecimal($s4)
		
		la $a0, mhexadecimal
		li $v0, 4
		syscall
		
		jr $ra

.data

saludo: .asciiz "Hola, pon un numero: \n"
saludo2: .asciiz "Pon otro numero: \n"
saludo3: .asciiz "El resultado de la suma es: "

.text


#$t1 => sumando 1
#$t2 => sumando 2
#$t3 => suma

#Aqui imprimo saludo
la $a0, saludo
li $v0, 4
syscall

#Aqui estoy pidiendo el primer input y lo guardo en $t1
li $v0, 5
syscall
move $t1, $v0

#Aqui imprimo saludo2
la $a0, saludo2
li $v0, 4
syscall


#Aqui estoy pidiendo el segundo input y lo guardo en $t2
li $v0, 5
syscall
move $t2, $v0

#Aqui $t3 = $t1 + $t2
add $t3,$t1,$t2

#Aqui imprimo saludo3
la $a0, saludo3
li $v0, 4
syscall

#$a0 = $t3
move $a0,$t3

#Syscall 1 (Imprimo lo que esta en $a0)
li $v0,1
syscall

li $v0, 10
syscall
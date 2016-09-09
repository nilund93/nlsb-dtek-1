  # timetemplate.asm
  # Written 2015 by F Lundevall
  # Copyright abandonded - this file is in the public domain.

.macro	PUSH (%reg)
	addi	$sp,$sp,-4
	sw	%reg,0($sp)
.end_macro

.macro	POP (%reg)
	lw	%reg,0($sp)
	addi	$sp,$sp,4
.end_macro

	.data
	.align 2
mytime:	.word 0x5957
timstr:	.ascii "text more text lots of text\0"
	.text
main:
	# print timstr
	la	$a0,timstr
	li	$v0,4
	syscall
	nop
	# wait a little
	li	$a0,2
	jal	delay
	nop
	# call tick
	la	$a0,mytime
	jal	tick
	nop
	# call your function time2string
	la	$a0,timstr
	la	$t0,mytime
	lw	$a1,0($t0)
	jal	time2string
	nop
	# print a newline
	li	$a0,10
	li	$v0,11
	syscall
	nop
	# go back and do it all again
	j	main
	nop
# tick: update time pointed to by $a0
tick:	lw	$t0,0($a0)	# get time
	addiu	$t0,$t0,1	# increase
	andi	$t1,$t0,0xf	# check lowest digit
	sltiu	$t2,$t1,0xa	# if digit < a, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0x6	# adjust lowest digit
	andi	$t1,$t0,0xf0	# check next digit
	sltiu	$t2,$t1,0x60	# if digit < 6, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0xa0	# adjust digit
	andi	$t1,$t0,0xf00	# check minute digit
	sltiu	$t2,$t1,0xa00	# if digit < a, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0x600	# adjust digit
	andi	$t1,$t0,0xf000	# check last digit
	sltiu	$t2,$t1,0x6000	# if digit < 6, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0xa000	# adjust last digit
tiend:	sw	$t0,0($a0)	# save updated result
	jr	$ra		# return
	nop

  # you can write your code for subroutine "hexasc" below this line
  #
 hexasc:
	#one register in $a0 with the 4 lsb
	#will return in $v0 the 7 LSB, all other bits must be 0.
	andi	$t0, $a0, 0xF 		#maska fram 4 lsb
	
	ble	$t0, 0x09, numbers 	#iom bokst�ver och siffror �r p� olika delar av ASCII-tabellen
				   	#s� g�r vi en till subrutin att g� till f�r att l�sa det
	
	addi	$t0, $t0, 0x37		#l�gg till 0x37 (allts� 55 dec) f�r att komma till de
					#bokst�verna i ascii-tabellen
	andi	$t0, $t0, 0x7f		#maska fram 7 lsb
	move	$v0, $t0		#flytta v�rdet i t0 till v0
	jr	$ra			#�terg� till main
numbers:
	addi	$t0, $t0, 0x30		#l�gg till 0x30 (48 dec) f�r att komma till de numeriska
					#v�rdena i ascii-tabellen
	andi	$t0, $t0, 0x7f		#maska fram 7 lsb
	move	$v0, $t0		#flytta v�rdet i t0 till v0
	jr	$ra			#�terg� till main
	
delay:
	jr	$ra
	nop 

time2string:
	#2 paramters, $a0, $a1
	#hela $a �r relevant ty det �r en minnesadress
	#$a1:s 16 lsb �r mest relevanta f�r oss, allts� 4 LSB
	#returnera ingenting
	#sekvensen ska skriva dit $a0 pekar
	#p� den adressen skall vi skriva:
	#1. 2 siffror
	#2. Kolon
	#3. 2 siffror
	#4. Nullbyte
	#hex, storebyte, shiftright, hex, storebyte, kolon(storebyte), shiftright, hex, storebyte, hex, storebyte, shiftright, SKRIV UT SKITEN
	
	#G�R EN LOOP SOM LOOPAR FYRA GGR
	#Efter den andra g�ngen storebytea ett kolon 
	la	$t2($a0)	#ladda adressen fr�n a0.
	
	andi	$a1, $a1, 0xFFFF #ta fram 4 LSB fr�n a1
	j	hexasc
	sb	$t0, 0x7F($v0)
	srl	$a1, $a1, 4	#shifta h�ger 4 bitar
	
	j	hexasc
	sb	$t0, 0x7F($v0)
	srl	$a1, $a1, 4	#shifta h�ger 4 bitar
	
	sb	$t0, 0x3A($v0)	#lagra v�rdet f�r : - G�R DEN DET?
	
	j	hexasc
	sb	$t0, 0x7F($v0)
	srl	$a1, $a1, 4	#shifta h�ger 4 bitar
	
	j	hexasc
	sb	$t0, 0x7F($v0)
	srl	$a1, $a1, 4	#shifta h�ger 4 bitar
	
	

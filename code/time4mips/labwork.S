  # labwork.S
  # Written 2015 by F Lundevall
  # Skeleton file for IS1200/IS1500 lab 1 2015-2016.
  # The macros PUSH and POP are in the public domain.

.macro	PUSH reg
	addi	$sp,$sp,-4
	sw	\reg,0($sp)
.endm

.macro	POP reg
	lw	\reg,0($sp)
	addi	$sp,$sp,4
.endm
  # You can add your own code here
  #
delay:
	li	$t0, 1000	#sätt $t0 = ms = 1000
while:	
	li	$t1, 0
for:
	beq	$t1, 1, forend	#Konstant som skall ändras.
	nop
	addi	$t1, $t1, 1
	j	for
	nop
forend:
	addi	$t0, $t0, -1
	bgtz	$t0, while	#om $t0 > 0, skicka tillbaka till while.
	nop
done:
	jr	$ra
	nop 

time2string:
	#sb data, imm(destination)
	PUSH	$ra
	move	$s0, $a0	#spara minnesadressen från a0 i s0
	move	$s1, $a1	#spara timestampen från a1 i s1
	
	srl	$a0, $a1, 12	#shifta höger 12 bitar för att få minut tiotal
	jal	hexasc
	nop		
	sb	$v0, 0($s0)	#lagrar hexasc returnvärde i s0.
	
	addi	$s0, $s0, 1	#lägg till 1 i adressen
	srl	$a0, $s1, 8	#shifta höger 8 bitar för att få minut ental
	jal	hexasc
	nop		
	sb	$v0, 0($s0)	
	
	addi	$s0, $s0, 1
	addi	$t1, $zero, 0x3A	
	sb	$t1, 0($s0)	#lagra värdet för :
	addi	$s0, $s0, 1

	srl	$a0, $s1, 4	#shifta höger 4 bitar för att få sekund tiotal 
	jal	hexasc
	nop
	sb	$v0, 0($s0)
	addi	$s0, $s0, 1
	
	srl	$a0, $s1, 0	#tar fram sekund ental
	jal	hexasc
	nop
	sb	$v0, 0($s0)
	addi	$s0, $s0, 1
	
	addi	$t1, $zero, 0x00 #lagra nullbyte
	sb	$t1, 0($s0)
	POP	$ra
	jr	$ra
	nop
	

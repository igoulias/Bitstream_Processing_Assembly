# Lab2
# Username: 	AEM:
# Username: 	AEM:

.data
array: .byte 0x70, 0x8C, 0xF3, 0x82, 0x1B, 0x9D, 0x49, 0x80, 0x50 # 

Str_msg1:
	.asciiz "\nEnter pointer: "

Str_msg2:
	.asciiz "\nEnter offset, 0<=offset<=7: "

Str_msg3:
	.asciiz "\nEnter nbits, 0<=nbits<=32: "

Str_msg4:
	.asciiz "\nHexadecimal Format: "

Str_msg5:
	.asciiz "\nBinary Format: "

.text
# Macro that prints the String str
.macro print_str(%str)
	la $a0, %str
	li $v0,4
	syscall
.end_macro

# Macro that print a Number 'n' on Format 'f' (35 for binary, 34 for hex, 1 for dec)
.macro print_num(%n, %f)
	move $a0, %n
	li $v0, %f
	syscall
.end_macro

.globl main

main: 
	print_str(Str_msg1)
	
	li $v0,5
	syscall		# Read pointer
	move $s0, $v0	# Store pointer to s0
	
read_offset:	# Read offset until 0<=offset<=32
	print_str(Str_msg2)
	li $v0,5 	
	syscall		# Read offset
	
	bltz $v0, read_offset 		# Check if offset is negative
	li $t0, 7
	bgt $v0, $t0, read_offset 	# Check if offset is greater than 7
	# Loop end ----
	move $s1, $v0			# Store offset to s1
	
read_nbits:	# Read nbits until 0<=offset<=32
	print_str(Str_msg3)
	li $v0,5
	syscall		# Read nbits
	bltz $v0, read_nbits		# Check if nbits is negative
	li $t0, 32
	bgt $v0, $t0, read_nbits	# Check if nbits is greater than 32
	# Loop end ----
	move $s2, $v0			# Store nbits to s2
#-- Load bytes --
	la $t0, array
	add $t0, $t0, $s0		# Pointer to the byte we want to load
	add $t1, $s1, $s2		# Number of bits we need to load (offset + nbits)
	move $s3, $zero
	# We load the first byte before entering the loop to aply the mask for the offset
	lbu $s3, 0($t0)			# Load unsign because we want the byte as its stored
	li $t3, 0xff			# Mask 00..0011111111
	srlv $t3, $t3, $s1		# Shift the mask to keep
	and $s3, $s3, $t3		# to keep bits after offset
	addi $t1, $t1, -8		# We just load 8 bits so we need 8 less to load
	addi $t0, $t0, 1		# To load next byte
	
	blez $t1, L1			# If t1 is less or eq to 0 we dont need/want to load more bytes
	li $t2, 3	# loops remain until we have loaded a word (4bytes), needed only if (offset + nbits)>32
loop:
	lbu $t3, 0($t0)		# Load unsign because we want the byte as its stored
	sll $s3, $s3, 8			# We sift left 8 bits (1 byte)...
	or $s3, $s3, $t3		# ... to combine
	addi $t1, $t1, -8		# We just load 8 bits so we need 8 less to load
	addi $t0, $t0, 1		# To load next byte
	addi $t2, $t2, -1	# 1 less loop til we have loaded a word
	blez $t1, L1			# If t1 is less or eq to 0 we dont need/want to load more bytes
	bgtz $t2,  loop
	# Loop end ----
#-- In case we have already loaded a word but haven't finish --
	
	sllv $s3, $s3, $t1		# We sift left to "get space" for the rest bits
	lbu $t3, 0($t0)		# Load unsign because we want the byte as its stored
	addi $t1, $t1, -8		# 
	sub $t1, $zero, $t1		
	srlv $t3, $t3, $t1		# We shift right (8 - t1) bits the byte we load..
	or $s3, $s3, $t3		# ... to combine
	j print
	
L1:	sub $t1, $zero, $t1		# Change sign, befor $t1 is 0 or negative, after is the num of bits to shift right
	srlv $s3, $s3, $t1		# Movint the bits we want to print to the least significant bits

print:
#-- Print result --
	print_str(Str_msg4)
	print_num($s3, 34)	# hexadecimal format
	
	print_str(Str_msg5)
	print_num($s3, 35)	# binary format
	
#-- Exit program --
	li $v0,10
	syscall
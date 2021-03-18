#CDA 4205 Project
#Name Pending
	.data 
		audio: .asciiz "all_shook_up.wav"
		output: .asciiz "output.wav"
		buffer: .space 15000	#Buffer for input info
		buffer2: .space 15000	#Buffer for output info
		message: .space 20	#Message buffer
		ask_op: .asciiz "\nWould you like to encode(e), decode(d) or exit(x): " 
		ask_message: .asciiz "\nEnter message you want encoded (max 20 chars): "
		ask_key: .asciiz "Enter the key for the message (max 20): "
		coded_mes: .asciiz "\nThe encoded message is: "
		invalid: .asciiz "\nInput was invalid: "
		file_size: .asciiz " bytes were read\n"
	.text
	
	#Ask for operation
start:	li $v0, 4
	la $a0, ask_op
	syscall
	li $v0, 12
	syscall
	move $s4, $v0
	beq $s4, 'e', encode
	beq $s4, 'd', decode
	beq $s4, 'x', exit
	li $v0, 4
	la $a0, invalid
	syscall
	j start
	
	#Encode message
	
	#open a file for reading
encode:	li   $v0, 13       # system call for open file
	la   $a0, audio    # board input file name
	li   $a1, 0        # Open for reading
	li   $a2, 0
	syscall            # open a file (file descriptor returned in $v0)
	move $s6, $v0      # save the file descriptor 
	
	#read from file
	li   $v0, 14       # system call for read from file
	move $a0, $s6      # file descriptor 
	la   $a1, buffer   # address of buffer to which to read
	li $a2, 15000
	syscall            # read from file
	move $s1, $a1
	add $t0, $v0, $zero
	
	li $v0, 11
	li $a0, 10
	syscall 
	li $v0, 1
	add $a0, $t0, $zero
	syscall
	li $v0, 4
	la $a0, file_size
	syscall
	
	# Close the file 
	li   $v0, 16       # system call for close file
	move $a0, $s6      # file descriptor to close
	syscall            # close file
	
	#Ask for nessage
	li $v0, 4
	la $a0, ask_message
	syscall
	li $v0, 8
	la $a0, message
	li $a1, 20
	syscall
	move $s0, $a0
	
	#Ask for key
	li $v0, 4
	la $a0, ask_key
	syscall
	li $v0, 5
	syscall
	add $t1, $v0, $zero	#Sets Key for decrements 
	add $s5, $t1, $zero	#Permanent Key value
	
	addi $s2,$zero, 43	#Iterator for buffer
	add $s3, $zero, $zero	#Iterator for message
	addi $t9, $zero, 20
	
	addu $t2, $s3, $s0
	lbu $t7, 0($t2)
	addi $t3, $zero, 8	#Size of mesage byte
	
loop:	addi $t1, $t1, -1	#Decrement key
	addi $s2, $s2, 1	#Go to next byte of file
	bne $t1, $zero, loop	#If key != 0, go to loop
	add $t0, $s2, $s1	#addr of buffer[i] in $t0
	lbu $t6, 0($t0)		#load byte from buffer
	bne $t3, $zero, cont	#If not at end of message byte, go to cont
	addi $t3, $zero, 8	#Reset byte size
	addi $s3, $s3, 1	#Else go to next byte
	addi $t9, $t9, -1	#Decrement remaining message bytes
	addu $t2, $s3, $s0	#addr of message[i] in $t2
	lbu $t7, 0($t2)		#load byte from message
	addu $t8, $zero, $zero	#Reset bit used
cont:	andi $t5, $t7, 128	#Get msb of message
	srl $t5, $t5, 7		#Shift msb to lsb
	sll $t7, $t7, 1 	#Shift byte left to get next bit		
	andi $t4, $t6, 1	#gets lsb and puts it in $t4
	addi $t3, $t3, -1	#Decremnt message byte size
	beq $t4, $t5, reset	#if lsb is same as bit from message, skip next ins
	xori $t6, $t6, 1	#Changes lsb
	sb $t6, 0($t0)  	#Save byte
reset:	addu $t1, $s5, $zero	#Reset key
	beq $t9, $zero, end	#when there are no more bits in message, go to end		
	j loop
	
	# Open file to be written
end:	li   $v0, 13       # system call for open file
	la   $a0, output   # board output file name
	li   $a1, 1     # Open for writing (flag)
	li   $a2, 0	   # (mode)
	syscall            # open a file (file descriptor returned in $v0)
	move $s7, $v0      # save the file descriptor 

	# write to file
	li $v0, 15 	   # syscall for write to file
	move $a0, $s7	   # file descriptor
	la $a1, buffer
	li $a2, 15000	   # number of characters to write
	syscall
	
	li   $v0, 16       # system call for close file
	move $a0, $s7      # file descriptor to close
	syscall            # close file
	
	j start
	
	#Retrieve message	
	#open a file for reading
decode:	li   $v0, 13       # system call for open file
	la   $a0, output   # board input file name
	li   $a1, 0        # Open for reading
	li   $a2, 0
	syscall            # open a file (file descriptor returned in $v0)
	move $s6, $v0      # save the file descriptor 
	
	#read from file
	li   $v0, 14       # system call for read from file
	move $a0, $s6      # file descriptor 
	la   $a1, buffer2   # address of buffer to which to read
	li $a2, 15000
	syscall            # read from file
	move $s1, $a1
	
	# Close the file 
	li   $v0, 16       # system call for close file
	move $a0, $s6      # file descriptor to close
	syscall            # close file
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	#Ask for key
	li $v0, 4
	la $a0, ask_key
	syscall
	li $v0, 5
	syscall
	addu $t1, $v0, $zero	#Sets Key for decrements 
	addu $s5, $t1, $zero	#Permanent Key value
	
	
	addi $s2, $zero, 43	#Iterator for buffer
	addu $s3, $zero, $zero	#Iterator for message
	
	addi $t9, $zero, 8	#size of a message byte
	addi $t3, $zero, 20
	

	li $v0, 4		#syscall for print string
	la $a0, coded_mes
	syscall
	add $t7, $zero, $zero
	
loop2:	addi $t1, $t1, -1	#Decrement key
	addi $s2, $s2, 1	#go to next byte of buffer2
	bne $t1, $zero, loop2	#If key != 0, go to loop2
	addu $t1, $s5, $zero	#reset key
	addu $t0, $s2, $s1	#addr of buffer2[i] in $t0
	lbu $t6, 0($t0)		#load byte from buffer2
	andi $t6, $t6, 1	#get lsb of buffer byte
	or $t7, $t7, $t6	#save buffer bit to message byte
	addi $t9, $t9, -1	#Decrement byte size
	beqz $t9, skip
	sll $t7, $t7, 1 	#Shift bits left	
skip:	bne $t9, $zero, loop2	#If all bits are placed in message byte, go to
	addi $t9, $zero, 8	#Reset byte size
	addi $t3, $t3, -1	#Decrement message size left
	li $v0, 11		#syscall for print string
	move $a0, $t7
	syscall
	andi $t7, $t7, 0
	beq $t3, $zero, start	#when there is no more space for message, got to end	
	j loop2
	
exit:	li $v0, 10
	syscall

	

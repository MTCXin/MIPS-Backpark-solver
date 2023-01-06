.data
buffer: .space 2048
infile: .asciiz "test.dat"

.text
#open file and get file discriptor
la $a0, infile
li $a1, 0
li $a2, 0
li $v0, 13
syscall
#read 2048bytes to buffer
move $a0, $v0
la $a1,buffer
li $a2,2048
li $v0,14
syscall
#close file
li $v0,16
syscall
#read item_num and knapsack_capacity
lw $a2,0($a1)
lw $a0,4($a1)
addi $a1,$a1,8
jal recursion
#print result
move $a0,$v0
li $v0,1
syscall
move $v0,$a0
j exit

recursion:
#if itemnum~a0 ==0, v0=0, return
bgtz $a0,anchor1
li $v0,0
jr $ra

anchor1:
li $t0,1
bne $a0,$t0,anchor2
lw $t0,0($a1)  #t0~weight[0]
lw $t1,4($a1)   #t1~value[0]
sub $t2,$t0,$a2
bgtz $t2,anchor3
move $v0,$t1 #return item_list[0].value
jr $ra
#elsewise, return 0
anchor3:
li $v0,0
jr $ra

#when item_num isn't 0 nor 1
anchor2: #first fetch valout and val_in
addi $sp,$sp,-16
sw $ra,0($sp)
sw $a0,4($sp)
sw $a1,8($sp)
sw $a2,12($sp)  #save the value
addi $a0,$a0,-1
addi $a1,$a1,8
jal recursion

addi $sp,$sp,-4
sw $v0,0($sp) #save val_out to stack
lw $ra,4($sp)
lw $a0,8($sp)
lw $a1,12($sp)
lw $a2,16($sp)
lw $t0,0($a1)  #t0~weight[0]
addi $a0,$a0,-1
addi $a1,$a1,8
sub $a2,$a2,$t0
jal recursion

move $t1,$v0    # val_in stored in t1
lw $t0,0,($sp)  #t0~val-out
lw $a1,12($sp)
lw $ra,4($sp)
lw $a0,8($sp)
lw $a2,16($sp) #restore capacity to a2
lw $t2,4($a1)   # t2~value[0]
lw $t3,0($a1)  #t3~weight[0]
add $t1,$t1,$t2

sub $t4,$a2,$t3
bgez $t4,anchor4
#return valout
move $v0,$t0
addi $sp,$sp,20
jr $ra

anchor4: #else return 
sub $t5,$t0,$t1 #t5=valout-valin
bgtz $t5,anchor5
move $v0,$t1    #return value_in
addi $sp,$sp,20
jr $ra

anchor5: #return value_out
move $v0,$t0
addi $sp,$sp,20
jr $ra
exit:
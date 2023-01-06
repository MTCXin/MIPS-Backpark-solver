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
jal dploop
#print result
move $a0,$v0
li $v0,1
syscall
move $v0,$a0
j exit

dploop: addi $sp,$sp,-256 #make space for cache_ptr
li $t0,0
li $t1,0
move $t2,$sp
#initialize the cache_ptr
loop1: 
sw $t1 0($t2)
addi $t2,$t2,4
addi $t3,$t0,-64
bgez $t3,loop1

li $t0,0
loop2:  #the i loop
    lw $t2,0($a1) #t2 here is weight
    lw $t3,4($a1) #t3 here is value
    addi $a1,$a1,8

    move $t1,$a2
    loop3:  #the j loop
        # compare if j >= weight
        sub $t4,$t2,$t1
        bgtz $t4,anchor1


        sub $t4,$t1,$t2
        sll $t4,$t4,2
        sub $t4,$sp,$t4
        addi $t4,$t4,252
        lw $t4,0($t4)
        add $t5,$t4,$t3 #here we get cache_ptr[j - weight] + val
        move $t4,$t1
        sll $t4,$t4,2
        sub $t4,$sp,$t4
        addi $t4,$t4,252 #here we get cache_ptr[j] at t4
        move $t7,$t4
        lw $t4,0($t4)
        sub $t6,$t4,$t5
        bgtz $t6,anchor1
        sw $t5,0($t7)
        anchor1: addi $t1,$t1,-1
        bgez $t1,loop3
    addi $t0,$t0,1
    bne $t0,$a0,loop2
sll $a2,$a2,2
sub $a2,$sp,$a2
addi $a2,$a2,252
lw $v0,0($a2)
jr $ra

exit:
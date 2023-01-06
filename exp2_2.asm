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
jal search
#print result
move $a0,$v0
li $v0,1
syscall
move $v0,$a0
j exit

search:
li $v0,0 #v0~val-max
li $t0,1 #initialize t0
sllv $t0,$t0,$a0
li $t1,0 #t1~state-cnt
loop1:
    li $t2,0 #t2~i
    li $t5,0 #t5~weight
    li $t6,0 #t6~val
    move $t3,$t1 # temp store statecnt to t3
    loop2:
        li $t4,1
        and $t4,$t4,$t3
        beqz $t4,anchor
        # obtain item_list[i].weight and item_list[i].value
        move $t7,$t2
        sll $t7,$t7,3
        add $t7,$a1,$t7
        lw $t8,4($t7) #value stored in t8
        lw $t7,0($t7) #weight stored in t7
        #add up
        add $t5,$t5,$t7
        add $t6,$t6,$t8
        anchor: addi $t2,$t2,1 #i++
        srl $t3,$t3,1 #state-cnt>>1

    bne $t2,$a0,loop2
    addi $t1,$t1,1
    #check if weight <= knapsack_capacity && val > val_max
    sub $t9,$t5,$a2
    bgtz $t9,anchor2
    sub $t9,$v0,$t6
    bgtz $t9,anchor2
    #val_max = val
    move $v0,$t6
anchor2:
bne $t1,$t0,loop1
jr $ra
exit:



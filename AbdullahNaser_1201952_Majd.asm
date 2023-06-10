################ About The Project ################
	# THIS PROJECT DONE BY : 
# STUDENT NAME: Abdullah Sami Naser    STUDENT ID: 1201952 
# STUDENT NAME: Majd Riyad Abdeddin    STUDENT ID: 1202923

	# COMPUTER ARCHITECTURE - FIRST PROJECT      
# PROJCT NAME: Dictionary-based Compression and Decompression using MIPS assembly 

	# INSTRUCTOR AND SECTION 
# INSTRUCTOR NAME: Dr.Aziz Qaroush 
# SECTION NO.: 2

	# NOTES 
#[1] The project done using MARS emulator and this the only file of the project 
#[2] I tried to comment all parts and divide it into sections 
#[3] The files dictionary,input,compressed,decompressed must be in the directory of MARS and .asm file 
#[4] I Don't make the menu as infinite loop because I use the same buffer for compression and decompression so in order 
# to decompress after the compression , run again 
#[5] But, it can be done by using another buffer , it the instructor needs that , I will do it in the discussion (No problem) 
#[6] There is a limit on the size of the file , buffer = 1024 (so maximum 1024 char) , this can be increased if the buffer size increased 

################ Data Section ################
.data 
.align 4 
welcome_prompt : 
	.asciiz "************WELCOME TO DICTIONARY-BASED COMPRESSION AND DE COMPRESSION PROGRAM ************\n"
ask_dict_prompt :
	.asciiz ">> AT THE FIRST, DO YOU HAVE A DICTIONARY TEXT FILE? [1 for Yes / 0 for No]\n"
ask_filename : 
	.asciiz ">> PLEASE ENTER THE FILE NAME (ex: data.txt) : \n"
opened_success_msg : 
	.asciiz ">> FILE OPENED SUCCESSFULLY \n"
open_error_msg : 
	.asciiz ">> ERROR: PLEASE CHECK THE FILE NAME OR BE SURE THAT THE FILE EXISTS IN THIS PROJECT DIRECTORY\n>> ENTER NAME AGAIN: \n"
write_success_msg :
	.asciiz ">> DICTIONARY FILE CREATED SUCCESSFULLY\n"
write_error_msg : 
	.asciiz ">> ERROR OCCURED , DICTIONARY FILE CAN'T BE CREATED\n"
file_name: 
	.space 30
file_buffer:
	.space 8192
dict_file : 
	.asciiz "dictionary.txt"
#-----------------------Menu Choices----------------------------
compress_choices : 
	.asciiz "c","C","compress","Compress","Compression","compression",""
decompress_choices : 
	.asciiz "d","D","decompress","Decompress","decompression","Decompression",""
quit_choices : 
	.asciiz "q","Q","quit","Quit",""
space_msg :
	.asciiz "************ PROGRAM MEUN ***********\n"
prog_menu_msg : 
	.asciiz ">> WHAT DO YOU WANT TO DO ?\n*[1] Compress A File (c,compress or compression)\n*[2] Decompress A File (d,decompress or decompression)\n*[3] Quit (q or quit)\n>> "
user_choice : 
	.space 30 
quit_msg : 
	.asciiz ">> GOOD LUCK , YOU ARE WELCOME\n" 
choice_error_msg : 
	.asciiz ">> ERROR : YOUR CHOICE DOES NOT EXIST , PLEASE RUN THE PROGRAM AGAIN AND CHOOSE ONE CORRECT\n"
null_out : 
	.asciiz ">"
#----------------------- Compression ----------------------------
.align 2
num_of_char : 
	.space 4
.align 4 
output :
	.space 8192
comp_fbuffer : 
	.space 8192 	
compress_enter_msg : 
	.asciiz "************ COMPRESS OPERATION ************\n" 
ask_user_compfile :
	.asciiz ">> PLEASE ENTER THE FILE NAME YOU WANT TO COMPRESS IT: \n" 
comp_fname :
	.space 30 
comp_file_error :
	.asciiz "\n>> THE FILE CAN'T BE OPENED , PLEASE ENTER THE FILE NAME AGAIN : \n"
comp_file_open :
	.asciiz "\n>> THE FILE OPENED SUCCESSFULLY\n>   COMPRESSION OPERATION STARTED\n" 
outOne_file :
	.asciiz "Compressed.txt"
.align 4
temp_num : 
	.space 4
done_msg : 
	.asciiz ">> THE COMPRESS OPERATION FINISHED , CHECK FILE NAMED ( Compressed.txt )\n"
uncomp_size_msg :
	.asciiz ">> THE UNCOMPRESSED FILE SIZE (IN BITS) =  "
comp_size_msg : 
 	.asciiz "\n>> THE COMPRESSED FILE SIZE (IN BITS ) =  "
comp_ratio_msg : 
 	.asciiz "\n>> COMPRESS RATIO = "

#----------------------- DeCompression ----------------------------
decompress_enter_msg : 
	.asciiz "************ DECOMPRESS OPERATION ************\n" 
ask_user_decompfile :
	.asciiz ">> PLEASE ENTER THE FILE NAME YOU WANT TO DE-COMPRESS IT: \n" 
decomp_file_error :
	.asciiz "\n>> THE FILE CAN'T BE OPENED , PLEASE ENTER THE FILE NAME AGAIN : \n"
decomp_file_open :
	.asciiz "\n>> THE FILE OPENED SUCCESSFULLY\n>   DECOMPRESSION OPERATION STARTED\n" 
outTwo_file :
	.asciiz "DeCompressed.txt"
no_decomp_msg: 
	.asciiz ">> CODE DOES NOT EXIST IN THE DICTIONARY FILE . ((DECOMPRESS OPERATION FAILED))\n"
decomp_done_msg :
	.asciiz ">> DECOMPRESS OPERATION FINISHED SUCCESSFULY , CHECK FILE NAMED (Decompressed.txt)\n"
	
################ Code Section ################

.text
.globl main
main:

# Printing Welcome Message 
	la $a0, welcome_prompt		
	li $v0, 4
	syscall

# Ask user about dict file 
	la $a0,ask_dict_prompt
	li $v0,4 
	syscall 

# get the user choice (Yes or No)
	li $v0,5 
	syscall 
	li $t0,1 
	bne $v0,$t0,create_dict_file

# ask the user to enter filename 
	la $a0,ask_filename 
	li $a1,30
	li $v0,4 
	syscall 

read_fname:
# reading the filename entered by user 
	la $a0, file_name
	li $v0, 8
	syscall

# print the file name again to make sure that we read it correctly 
	li $v0, 4
	syscall
#replace filename newline with null 
	la $a0, file_name
	jal replace_newline_withnull_func 


# Open the file 
	la $a0, file_name
	la $a1, 0
	la $a2, 0
	li $v0,13 
	syscall

#Check if the file opened or not 
	bltz $v0,error_msg 
	la $a0,opened_success_msg 
	move $s0,$v0
	li $v0,4
	syscall 
	j next


error_msg : 
	la $a0,open_error_msg 
	li $v0,4 
	syscall 
	li $a1,30
	j read_fname


#create dict file if user choice 0 
create_dict_file : 
	la $a0,dict_file 
	li $a1,1 
	li $v0,13
	syscall 

#check if the file created or not 
	bltz $v0,write_error
	move $s0,$v0
	la $a0,write_success_msg
	li $v0,4 
	syscall 
	move $a0,$s0
	j next

write_error:
	la $a0,write_error_msg 
	li $v0,4 
	syscall 
	j exit_prog



next :     
# Close file
	move $a0, $s0    
	li $v0,16    
	syscall
# ----> $s0 dictionary file 

exit :
####################Program Menu###########################

#print space message 
	la $a0,space_msg 
	li $v0,4 
	syscall 

#print menu 
	la $a0,prog_menu_msg
	li $v0,4 
	syscall 

#get user choice 
	la $a0,user_choice 
	li $a1,30 
	li $v0,8 
	syscall 


#replace newline with null in user choice 
	la $a0,user_choice 
	jal replace_newline_withnull_func 

#compare user choice with the comp choices 
	la $a0,user_choice
	la $a1,compress_choices  
	li $t5,1 

comp_ch_loop : 
	jal string_cmp_func 
	beq $v1,$t5,compression 
	lb $t2,($a1)
	beqz $t2,decomp_ch
	la $a0,user_choice 
	j comp_ch_loop 

#compare user choice with decomp choices 
decomp_ch:
	la $a0,user_choice
	la $a1,decompress_choices  
	li $t5,1 

decomp_ch_loop : 
	jal string_cmp_func 
	beq $v1,$t5,decompression 
	lb $t2,($a1)
	beqz $t2,quit_ch
	la $a0,user_choice 
	j decomp_ch_loop 

#compare user choice with quit choices 

quit_ch :
	la $a0,user_choice
	la $a1,quit_choices  
	li $t5,1 

quit_ch_loop : 
	jal string_cmp_func 
	beq $v1,$t5,quit
	lb $t2,($a1)
	beqz $t2,other_ch
	la $a0,user_choice 
	j quit_ch_loop 

#if the user choice was not correct 
other_ch :
	la $a0,choice_error_msg 
	li $v0,4 
	syscall 
	j exit_prog

############################Functions####################################
# replacine the newline char to null char (in order to make the file name be or user input correct) (null-terminated string) 
replace_newline_withnull_func : 

	li $t2, '\n'
fname_loop:
	lb $t3, 0($a0) #\n
	add $a0, $a0, 1
	bne $t3, $t2, fname_loop
	sb $zero, -1($a0) # -1 here because in the last statemnt we increment by one 

end_func : 
	jr $ra 

# -----------------------------------------------
# this function will compare two strings and return a value in $v1 
# $v1 = 0 not equal , $v1 = 1 equal , and it will move the pointer a1 to the next word in menu 
string_cmp_func : 

string_loop : 
	lb $t0,($a0)
	lb $t1,($a1) 
	bne $t0,$t1,not_equal
	addi $a0,$a0,1 
	addi $a1,$a1,1 
	beqz $t1,equal 
	j string_loop 

not_equal : 
	li $t4,0x20
move_to_next_of_$a1 : 
	lb $t1,($a1) 
	addi $a1,$a1,1 
	bnez $t1,move_to_next_of_$a1 
	li $v1,0 
	jr $ra 
equal : 
	li $v1,1 
	jr $ra 
# -----------------------------------------------
#this function will take a pointer to a word in the uncompressed file , and it will search in the dictionary 
# it will return a code in v1 if the word exists in the dictionary , otherwise it will add the word with a new code and return the code 
#used in compress operation 

get_code_func :
	#check if a0 points to null
	lb $t0,($a0)
	beq $t0,$zero,end_codes
	#initialize the counter (code) 
	move $s4,$zero 
	#save $a0 in $s2
	move $s2,$a0 

	#initialize 
	move $v1,$zero 
	move $v0,$zero 
	
	#move byte byte and compare then return the code 
comparing_loop : 
	lb $t0,($a0)
	#check if the word it self is special char 
	move $s0,$ra 
	jal check_notalphab 
	move $ra,$s0
	sne $t6,$v0,$zero 
	
	lb $t1,($a1) 
	beq $t1,$zero,generate_code #if the dictionary file is empty then generate a new code 
	bne $t0,$t1,next_word
	addi $a0,$a0,1 
	addi $a1,$a1,1 
	#check if the words are equal
	lb $t0,($a0) 
	move $s0,$ra #save return address
	jal check_notalphab 
	move $ra,$s0 #return address
	lb $t1,($a1)
	li $t3,0x2d
	seq $t2,$t1,$t3
	bnez $t6,spec_char
	bne $v0,$t2,next_word
	j both_one
	spec_char : 
	beq $t2,1,return_code
	
	both_one:
	#checi if both are 1
	beq $v0,1,return_code
	j comparing_loop

	
	
	next_word:
	#loop will move until find the null character
	li $t0,0x0a
	final_of_a1_loop:
	lb $t1,1($a1)
	addi $a1,$a1,1
	bne $t1,$t0,final_of_a1_loop 
	addi $a1,$a1,1
	#increment counter (code) 
	addi $s4,$s4,1
	#now $a1 points to null
	move $a0,$s2
	j comparing_loop
	
	
	




return_code : 
	move $s0,$ra
	jal int_to_string_func
	move $ra,$s0 
	jr $ra
	
generate_code : 
	#get the code 
	move $s0,$ra 
	jal int_to_string_func 
	move $ra,$s0
	#now the code is in $v1 
	#store the word pointed by a0 
	move $t9,$ra
	loop_on_a0word:
	lb $t0,($a0)
	sb $t0,($a1)
	addi $a1,$a1,1
	addi $a0,$a0,1
	#check if the word itself is space 
	jal check_notalphab
	bnez $v0,store_mid
	lb $t0,($a0)
	jal check_notalphab	
	beqz $v0,loop_on_a0word
	store_mid:
	#store - and the code 
	li $t3,0x2d 
	sb $t3,($a1)
	addi $a1,$a1,1 
	#store the code 
	srl $t1,$v1,24
	sb $t1,($a1)
	addi $a1,$a1,1
	srl $t1,$v1,16
	sb $t1,($a1)
	addi $a1,$a1,1
	srl $t1,$v1,8 
	sb $t1,($a1)
	addi $a1,$a1,1
	sb $v1,($a1)
	addi $a1,$a1,1
	#store \r and \n 
	move $t1,$zero 
	li $t1,0x0d #\r
	sb $t1,($a1)
	addi $a1,$a1,1 
	move $t1,$zero 
	li $t1,0x0A 
	sb $t1,($a1) 
	addi $a1,$a1,1 
	#store null
	sb $zero,($a1)
	
	move $s2,$a0
	#refresh dictionary 
	jal REFRESH_DICT
	#nop to make some delay after refreshing the file 
	nop 
	nop 
	nop 
	nop 
	nop
	#pop values 
	move $ra,$t9 
	move $a0,$s2
	jr $ra
	

end_codes :
	move $v1,$zero 
	jr $ra
	
# -----------------------------------------------
#this function will refresh the dictionary file 
REFRESH_DICT :

	# Open file for writing
    	li $v0, 13       
    	la $a0,dict_file
    	li $a1, 1         # mode for writing
    	syscall          
    
    	# Get file descriptor
    	move $s0, $v0    
    
    	# Write string to file
    	li $v0, 15       
    	move $a0, $s0    
    	la $a1,file_buffer
    	li $a2, 8192      
    	syscall          
    
    	# Close file
    	li $v0, 16       
    	move $a0, $s0    
    	syscall          

    	jr $ra
# ----------------------------------------------- 
# this will convert an integer stored in $s4 into string stored in $v1 and return the value 
int_to_string_func : 
  	li $t0,16
  	la $t3,temp_num
  	#store null in t3(DELETE CONTENTS OF IT) 
  	sb $zero,($t3)
  	sb $zero,1($t3)
  	move $t2,$zero #loop counter
intloop : 
	divu $s4,$t0
	mfhi $t1 #get remainder 
	bge $t1,10,conv_to_lett
	addiu $t1,$t1,0x30 
	j nxt 
	conv_to_lett: 
	addiu $t1,$t1,55 
	nxt:
	sb $t1,0($t3)
	addi $t3,$t3,1 
	addi $t2,$t2,1
	mflo $s4 
	bnez $s4,intloop 
	
	#get value in $v1 
	la $t3,temp_num
	lw $v1,($t3)
	
	#fill with zeros 
	bne $t2,1,two
	li $t1,0x30303000
	or $v1,$v1,$t1 
	j finish_conv
	
	two:
	bne $t2,2,three 
	li $t1,0x30300000
	or $v1,$v1,$t1 
	j finish_conv
	
	three:
	bne $t2,3,finish_conv
	li $t1,0x30000000
	or $v1,$v1,$t1 
	
	
	finish_conv: 	
	jr $ra
# ----------------------------------------------- 
#this function will check if the character is alphabatecal or not 
# if its special char then v1=1 otherwise v1=0

check_notalphab: 
	#check if less than 65 so special char
	blt $t0,65,ret_1
	#check if greater than 90 
	bgt $t0,90,check_smallletters
	li $v0,0
	jr $ra 
	check_smallletters :
	#check if less than 97 or greater than 122so special char
	blt $t0,97,ret_1 
	bgt $t0,122,ret_1
	li $v0,0
	jr $ra 
	
	ret_1: 
	li $v0,1
	jr $ra

# ----------------------------------------------- 
#this function will write the output buffer to either compressed.txt or decompressed.txt file 
#called after finish the operation of compression and decompression 
	
write_output :

	# Open file for writing
	#a0 contains the address of output buffer 
    	li $v0, 13      
    	li $a1, 1         
    	syscall          
    
    	# Get file descriptor
    	move $s0, $v0    
    
    	# Write string to file
    	li $v0, 15       
    	move $a0, $s0    
    	la $a1,output
    	li $a2, 8192       
    	syscall          
    
    	# Close file
    	li $v0, 16       
    	move $a0, $s0    
    	syscall          

    	jr $ra	
# ----------------------------------------------- 
#this function will have a pointer to a code in the compressed file , it will search in dictionary and return a pointer a1 to the word with this code
# if there is no word it will return a flag to tell that and so the decompress operation failed 

get_pointer_to_word_func : 

	#check if the file is empty 
	lb $t0,($a0)
	beqz $t0,done_pointer 
	move $t0,$zero #initialize 
	
	#load the code into $t0 with Big Endian
	# Swapping the byte order to big endian
	lbu $t1, 0($a0)   
	lbu $t2, 1($a0)   
	lbu $t3, 2($a0)   
	lbu $t4, 3($a0)   

	# Shift contents
	sll $t1, $t1, 24  
	sll $t2, $t2, 16  
	sll $t3, $t3, 8  

	 # Combine the bytes into $t0
	or $t0, $t0, $t1  
	or $t0, $t0, $t2
	or $t0, $t0, $t3
	or $t0, $t0, $t4
	
	#increment pointer a0 to move on next code 
	addi $a0,$a0,8 
	
	#convert string stored in $t0 into integer 
	move $s0,$ra 
	jal string_to_int_func 
	move $ra,$s0
	#now the value is stored in $s4 
	#loop to move s4 words in dictionary 
	
	beqz $s4,ret_pointer 
	
	my_loop: 
	j next_word_dict
	bnez $s4,my_loop
	j ret_pointer
	
	next_word_dict:
	#loop will move until find the null character
	li $t0,0x0a
	final_loop:
	lb $t1,1($a1)
	addi $a1,$a1,1
	bne $t1,$t0,final_loop 
	addi $a1,$a1,1
	addiu $s4,$s4,-1 
	bnez $s4,my_loop
	j ret_pointer

ret_pointer: 
	move $v1,$zero
	jr $ra

done_pointer : 
	li $v1,1 
	jr $ra
# ----------------------------------------------- 
#this function works like int to string func but now string to int 
#we will use it to convert the code read from compressed file as string into integer to be the counter 
#note here assume that the number maximum of three digits 

string_to_int_func : 
	li $t2,0xff #we will use it to mask upper bits 
	move $t1,$zero #initialize 
	move $t5,$zero #counter 
	move $t6,$zero
	
	convert_loop:
	and $t3,$t0,$t2 #get the first byte 
	beq $t3,$zero,done_conver
	bge $t3,65,its_char 
    	sub $t3, $t3, 48        # Convert the ASCII digit to its numerical value
    	j complete_conver
    	its_char: 
    	addiu $t3,$t3,-55 
    	
    	complete_conver:
    	bgtz $t5,by_16
    	li $t1,1
    	
    	j multip
    	by_16: 
    	bgt $t5,1,by_16sq
    	li $t1,16 
    	j multip 
    	
    	by_16sq: 
    	li $t1,256
    	j multip 
    	
    	
    	
    	
    	multip:
    	mul $t3, $t3, $t1        # Multiply the current value by 10
    	add $t6, $t6, $t3       # Add the current digit to the integer value

    	srl $t0,$t0,8 
    	addi $t5,$t5,1
    	j convert_loop          # Jump back to the beginning of the loop
  
done_conver  :
	move $s4,$t6
 	jr $ra
 # ----------------------------------------------- 
   	
#####Compression###################################
compression :

#enter compress welcome message 
	la $a0,compress_enter_msg 
	li $v0,4 
	syscall 

#ask user to enter path name 
	la $a0,ask_user_compfile 
	li $v0,4 
	syscall 

read_comp_filename : 
#read fname 
	la $a0,comp_fname 
	li $a1,30 
	li $v0,8 
	syscall 

#replace newline with null 
	jal replace_newline_withnull_func 

#print file name again to ensure the input is correct 
	la $a0,comp_fname 
	li $v0,4 
	syscall 

# Open the file 
	la $a0, comp_fname
	la $a1, 0
	la $a2, 0
	li $v0,13 
	syscall

#check if the opened success or not 
	bltz $v0,comp_open_error 
	la $a0,comp_file_open 
	li $v0,4 
	syscall 
	move $s1,$v0 #uncompressed file descriptor 
# read the contents of it and store in the buffer 
	move $a0,$s0
	la $a1,comp_fbuffer 
	li $a2,8192 
	li $v0,14 
	syscall 
	#store number of characters read
	la $t0,num_of_char 
	sh $v0,($t0)
	j comp_operation 

comp_open_error:
	la $a0,comp_file_error
	li $v0,4 
	syscall 
	j read_comp_filename

comp_operation : 

# open the dictionary file and store it 
	# Open the file 
	la $a0, dict_file
	la $a1, 0
	la $a2, 0
	li $v0,13 
	syscall
	
	# store contents of dict file into buffer 
	move $s0,$v0
	move $a0,$s0
	la $a1,file_buffer 
	li $a2,8192
	li $v0,14 
	syscall 
	
	 # Close file
    	li $v0, 16       # system call code for close
   	move $a0, $s0    # file descriptor
    	syscall          # close file
	
# COMPRESS PROCESS 
	#load address of output buffer 
	la $t8,output
	la $a0,comp_fbuffer 
move_on_uncomp_loop :
	la $a1,file_buffer
	jal get_code_func 
	beq $v1,$zero,done_comp
	addi $s5,$s5,1 #number of binary codes
	#store the code 
	srl $t1,$v1,24
	sb $t1,($t8)
	addi $t8,$t8,1
	srl $t1,$v1,16
	sb $t1,($t8)
	addi $t8,$t8,1
	srl $t1,$v1,8 
	sb $t1,($t8)
	addi $t8,$t8,1
	sb $v1,($t8)
	addi $t8,$t8,1
	#store 3 spaces and \n
	li $t1,0x20 
	sb $t1,($t8)
	sb $t1,1($t8)
	sb $t1,2($t8)
	li $t1,0x0A 
	sb $t1,3($t8)
	addi $t8,$t8,4 
	j move_on_uncomp_loop
	
	
	done_comp:
	la $a0,outOne_file
	jal write_output
	# display done msg 
	la $a0,done_msg 
	li $v0,4
	syscall 
	
	la $t0,num_of_char 
	lh $s2,($t0)
	#calculate uncompress size and display it 
	subu $s2,$s2,1 
	mulu $s2,$s2,16
	la $a0,uncomp_size_msg 
	li $v0,4 
	syscall 
	move $a0,$s2 
	li $v0,1
	syscall 
	
	#calculate compress size and display it 
	mulu $s5,$s5,16 
	la $a0,comp_size_msg 
	li $v0,4
	syscall 
	move $a0,$s5 
	li $v0,1
	syscall 
	
	#calculate ratio and display it 
	move $t0,$s2 
	mtc1 $t0,$f1 
	move $t0,$s5
	mtc1 $t0,$f2
	div.s $f12,$f1,$f2
	la $a0,comp_ratio_msg 
	li $v0,4 
	syscall 
	li $v0,2 
	syscall 
	
	
	j exit_prog
	
	
############################DeCompression###################################
decompression :
	
#enter decompress welcome message 
	la $a0,decompress_enter_msg 
	li $v0,4 
	syscall 

#ask user to enter path name 
	la $a0,ask_user_decompfile 
	li $v0,4 
	syscall 

read_decomp_filename : 
#read fname 
	la $a0,comp_fname 
	li $a1,30 
	li $v0,8 
	syscall 

#replace newline with null 
	jal replace_newline_withnull_func 

#print file name again to ensure the input is correct 
	la $a0,comp_fname 
	li $v0,4 
	syscall 

# Open the file 
	la $a0, comp_fname
	la $a1, 0
	la $a2, 0
	li $v0,13 
	syscall

#check if the opened success or not 
	bltz $v0,decomp_open_error 
	la $a0,decomp_file_open 
	li $v0,4 
	syscall 
	move $s1,$v0 #uncompressed file descriptor 
# read the contents of it and store in the buffer 
	move $a0,$s0
	la $a1,comp_fbuffer 
	li $a2,8192 
	li $v0,14 
	syscall 
	j decomp_operation 

decomp_open_error:
	la $a0,decomp_file_error
	li $v0,4 
	syscall 
	j read_decomp_filename

decomp_operation : 

# open the dictionary file and store it 
	# Open the file 
	la $a0, dict_file
	la $a1, 0
	la $a2, 0
	li $v0,13 
	syscall
	
	# store contents of dict file into buffer 
	move $s0,$v0
	move $a0,$s0
	la $a1,file_buffer 
	li $a2,8192
	li $v0,14 
	syscall 
	
	 # Close file
    	li $v0, 16       # system call code for close
   	move $a0, $s0    # file descriptor
    	syscall          # close file
#DECOMPRESSION 
	#load the output buffer address and address of codes 
	la $a0,comp_fbuffer 
	la $t8,output 
	
	loop_on_codes : 
	la $a1,file_buffer 
	jal get_pointer_to_word_func 
	#check if the file is done 
	bnez $v1,end_decompress
	#check if the word is null (this code does not exist in the dictionary) 
	lb $t0,($a1) 
	beqz $t0,no_decomp_operation
	#store the word 
	loop_to_store_out_word:
	lb $t0,($a1)
	sb $t0,($t8)
	addi $t8,$t8,1 
	addi $a1,$a1,1 
	li $t1,0x2d # - separator 
	lb $t0,($a1)
	bne $t0,$t1,loop_to_store_out_word
	j loop_on_codes

	end_decompress:
	la $a0,outTwo_file 
	jal write_output
	la $a0,decomp_done_msg
	li $v0,4 
	syscall
	j exit_prog	
			
				
					
														
no_decomp_operation: 
	la $a0,no_decomp_msg 
	li $v0,4
	syscall 											
	j exit_prog
############################Quit##################################
quit : 
	la $a0,quit_msg 
	li $v0,4 
	syscall 
	j exit_prog


############################EXIT#################################
exit_prog: 
# exiting the program
	#save these addressed to look at the memory and what happen to it only 
	la $a0,comp_fbuffer
	la $a1,file_buffer
	#syscall for exit 
	li $v0, 10
	syscall

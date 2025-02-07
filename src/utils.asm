; hehe most of this is stolen oops


section .text
global _itoa
global print
global read_line
global str_startswith
global _strlen

_ret:
    ret

_reverse: 			;; (rsi, r10)
	mov rdx,0
	mov rax,r10
	mov r11,2
	div r11
	mov r11,rax
	mov rcx,0
	call __reverse
	sub rsi,rcx
	mov rax,rsi
	ret
__reverse:
	cmp rcx,r11
	je _ret
	mov r9b, byte [rsi]
	mov r8, rsi
	add r8, r10
	dec r8
	mov rax,2
	mul rcx
	sub r8, rax
	mov dil, byte [r8]
	mov byte [rsi], dil
	mov byte [r8], r9b
	inc rsi
	inc rcx
	jmp __reverse

_strlen: 			;; String length (rsi)
	mov rcx,0
	call __strlen
	sub rsi,rcx
	mov rax,rcx
	ret
__strlen:
	cmp byte [rsi],0
	je _ret
	inc rsi
	inc rcx
	jmp __strlen

_itoa: 				;; Int to String (rsi, r10)
	mov r9,0
	mov rax,rsi
	mov rcx,0
	call __itoa
	sub r10,r9
	mov rsi,r10
	call _strlen
	mov r10,rax
	call _reverse
	ret
__itoa:
	mov rdx,0
	mov rcx,10
	div rcx
	add rdx,48
	mov [r10],rdx
	cmp rax,0
	je _ret
	inc r10
	inc r9
	jmp __itoa


print:
    ; rdi = address of the string
    ; rsi = boolean for new line (0 = true, * = false) 
    
    ; push bool onto the stack
    push rsi 
    
    ; initiate syscall
    mov rax, 1              ; 1 -> sys_write
    mov rsi, rdi            ; string address
    mov rdi, 1              ; 1 -> stdout
    
    ; calculate string length
    mov rcx, 0             ; clear rcx
.next_char:
    cmp byte [rsi + rcx], 0 ; have we reached a zero?
    je .done_len            ; if so, jump to the end of the loop
    inc rcx                 ; otherwise increment rcx
    jmp .next_char          ; and loop
.done_len:
    ; print the string with the calculated length
    mov rdx, rcx            ; string length in rdx
    syscall                 ; call write
    
    ; print new line logic
    pop rsi                 ; retrieve 2nd argument from the stack into rsi
    cmp rsi, 0              ; compare if rsi is equal to 0 (true)
    jne .exit               ; if not, jump to the end
    push 0xA                ; otherwise push a newline (0xA) onto the stack
    ; initiate syscall
    mov rax,1               ; 1 -> sys_write
    mov rsi, rsp            ; top of the stack
    mov rdx, 1              ; length in bytes
    syscall                 ; call write
    add rsp, 8              ; cleanup the stack
.exit:
    ret

read_line:
    ; rdi = file pointer
    ; return values:
    ; rax = char*
    ; rdx = buffer size

    ; store rdi for later
    push rdi

    ; allocate 4096 bytes
    mov rax, 9          ; 9 -> sys_mmap
    mov rdi, 0          ; 0 -> address (let the kernel choose)
    mov rsi, 4096       ; 4096 -> amount of bytes
    mov rdx, 3          ; PROT_READ | PROT_WRITE
    mov r10, 0x22       ; MAP_PRIVATE | MAP_ANONYMOUS
    mov r8, -1          ; fd -> -1 (required for anonymous mapping)
    mov r9, 0           ; offset -> 0 (required for anonymous mapping)
    syscall
    ; error checking
    cmp rax, -1
    je .error

    ; store memory in r8
    mov r8, rax

    ; reset counter
    mov r9, 0

    pop r10             ; retrieve file pointer from stack
.loop:
    ;add r8, r9          ; add counter to the buffer pointer

    ; read 1 byte from the file pointer
    mov rax, 0
    mov rdi, r10
    ;mov rsi, r8
    lea rsi, [r8+r9]
    mov rdx, 1
    syscall

    ; end of file
    cmp rax, 0
    je .exit

    ; check if newline is found
    cmp byte [r8+r9], 0xA
    je .exit

    inc r9              ; r9++
    cmp r9, 4096       
    jne .loop
.exit:
    ; null terminate
    mov byte [r8+r9], 0

    mov rax, r8
    mov rdx, r9
    
    ret

.error:
    mov rax, -1
    mov rdx, -1
    ret

str_startswith:
    ; rdi = base string
    ; rsi = substring
    ; return values:
    ; rax = boolean (0 = true, 1 = false)

    push rdi               ; save base string
    push rsi               ; save substring

    ; calculate length of substring
    call _strlen
    mov r9, rax            ; r9 = length of substring

    ; calculate length of base string
    mov rsi, rdi           ; restore base string into rdi
    call _strlen
    mov r8, rax            ; r8 = length of base string

    ; retrieve rdi and rsi from the stack
    pop rsi                ; restore substring
    pop rdi                ; restore base string

    ; check if the base string is smaller than the substring
    cmp r8, r9
    jb .false              ; if base string is smaller, return false


    ; loop through substring 
    mov r11, 0             ; r11 = loop index
.loop:
    cmp r11, r9            ; check if all characters have been compared
    je .true               ; if yes, return true

    mov al, byte [rdi + r11]  
    cmp al, byte [rsi + r11]  
    je .next_char          ; if equal, continue with next character

    ; if it does not match, return false
.false:
    mov rax, 1             
    ret

.next_char:
    inc r11                ; increment counter
    jmp .loop                

.true:
    mov rax, 0              
    ret


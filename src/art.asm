section .data
    arch        db "arch", 0      
    arch_art:      incbin "./resources/arch.bin"
    debian      db "debian", 0
    debian_art:    incbin "./resources/debian.bin"
    ubuntu      db "ubuntu", 0
    ubuntu_art:    incbin "./resources/ubuntu.bin"
    linuxmint   db "linuxmint", 0
    linuxmint_art: incbin "./resources/linuxmint.bin"
    linuxlite   db "linuxlite", 0
    linuxlite_art: incbin "./resources/linuxlite.bin"
    popos       db "pop", 0
    popos_art:     incbin "./resources/pop.bin"
    gentoo      db "gentoo", 0
    gentoo_art:    incbin "./resources/gentoo.bin"
    unknown_art:   incbin "./resources/unknown.bin"

section .bss
    id resq 1

section .text
    global print_art
    extern print
    extern str_startswith

print_art:
    ; rdi = string pointer for distro id
    ; return values:
    ; rax = amount of newlines

    ; store id string
    mov qword [id], rdi

    ; big chain of comparisons
    lea rsi, [arch] 
    mov rdi, qword [id]   
    call str_startswith
    cmp rax, 0
    je .arch

    lea rsi, [debian] 
    mov rdi, qword [id]   
    call str_startswith
    cmp rax, 0
    je .debian

    lea rsi, [ubuntu] 
    mov rdi, qword [id]   
    call str_startswith
    cmp rax, 0
    je .ubuntu

    lea rsi, [linuxmint] 
    mov rdi, qword [id]   
    call str_startswith
    cmp rax, 0
    je .linuxmint

    lea rsi, [linuxlite] 
    mov rdi, qword [id]   
    call str_startswith
    cmp rax, 0
    je .linuxlite

    lea rsi, [popos] 
    mov rdi, qword [id]   
    call str_startswith
    cmp rax, 0
    je .popos

    lea rsi, [gentoo] 
    mov rdi, qword [id]   
    call str_startswith
    cmp rax, 0
    je .gentoo
    ; none found
.none:
    lea rdi, [unknown_art+8] 
    mov rsi, 1
    call print
    mov rax, qword [unknown_art]
    ret

.arch:
    lea rdi, [arch_art+8] 
    lea rsi, 1
    call print
    mov rax, qword [arch_art]
    ret
.debian:
    lea rdi, [debian_art+8] 
    lea rsi, 1
    call print
    mov rax, qword [debian_art]
    ret
.ubuntu:
    lea rdi, [ubuntu_art+8] 
    lea rsi, 1
    call print
    mov rax, qword [ubuntu_art]
    ret
.linuxmint:
    lea rdi, [linuxmint_art+8] 
    lea rsi, 1
    call print
    mov rax, qword [linuxmint_art]
    ret
.linuxlite:
    lea rdi, [linuxlite_art+8] 
    lea rsi, 1
    call print
    mov rax, qword [linuxlite_art]
    ret
.popos:
    lea rdi, [popos_art+8] 
    lea rsi, 1
    call print
    mov rax, qword [popos_art]
    ret
.gentoo:
    lea rdi, [gentoo_art+8] 
    lea rsi, 1
    call print
    mov rax, qword [gentoo_art]
    ret

%include "./src/colors.inc"

%define MOVECUR 0x1b, "[20C"

%define SEPERATOR SEP_COLOR, "->", RESET

section .data
    os_line     db MOVECUR, KEY_COLOR, "os      ", SEPERATOR, "  ", VALUE_COLOR, 0
    host_line   db MOVECUR, KEY_COLOR, "host    ", SEPERATOR, "  ", VALUE_COLOR, 0
    kernel_line db MOVECUR, KEY_COLOR, "kernel  ", SEPERATOR, "  ", VALUE_COLOR, 0
    uptime_line db MOVECUR, KEY_COLOR, "uptime  ", SEPERATOR, "  ", VALUE_COLOR, 0
    cpu_line    db MOVECUR, KEY_COLOR, "cpu     ", SEPERATOR, "  ", VALUE_COLOR, 0
    gpu_line    db MOVECUR, KEY_COLOR, "gpu     ", SEPERATOR, "  ", VALUE_COLOR, 0
    memory_line db MOVECUR, KEY_COLOR, "memory  ", SEPERATOR, "  ", VALUE_COLOR, 0
    unknown db "unknown", 0

    mib_str     db " MiB", 0
    mib_spacer  db " / ", 0
    uptime_secs db " Seconds", 0

    os_release_path db  "/etc/os-release", 0
    os_release_name db  "NAME=", 0
    os_release_id   db  "ID=", 0

    utsname_buffer: times 390 db 0  ; allocate space for utsname struct 
    sysinfo_buffer: times 128 db 0  ; allocate space for sysinfo struct 

    mem_total_str:   times 25 db 0  ; allocate 25 bytes for mem_total string + null terminator
    mem_used_str:    times 25 db 0  ; allocate 25 bytes for mem_free string + null terminator

    uptime_str:      times 25 db 0  ; allocate 25 bytes for uptime string + null terminator

    distro_lines:    times 8  db 0
    lines_printed:   times 8  db 0
    upbuf:           times 25 db 0
    moveup1         db  0x1b, "[", 0
    moveup2         db "A", 0
    os_fp:           times 8  db 0  ; file pointer
    os_str:          times 8  db 0  ; string pointer
    id_fp:           times 8  db 0  ; file pointer
    id_str:          times 8  db 0  ; string pointer
    
    
    pciids:          incbin "./resources/pciids.out"
    gpu_id:          times 13 db 0   ; 12 bytes + null terminator   

section .bss
    cpu_name resb 49    ; 48 bytes + null terminator
 
section .text
    global _start
    extern _itoa
    extern print
    extern read_line
    extern str_startswith
    extern _strlen
    extern print_art

get_gpu:
    ; return values:
    ; rax = char* GPU name

    ; TODO loop through /sys/bus/pci/devices/

    ; to not brick anything for now
    lea rax, [unknown]
    ret

_start:
    ; open file
    mov rax, 2
    lea rdi, [os_release_path]
    mov rsi, 0
    mov rdx, 0
    syscall
    mov qword [id_fp], rax
.id_loop:
    ; readline
    mov rdi, qword [id_fp]
    call read_line
    mov qword [id_str], rax
    cmp rdx, 0
    jne .id_found
    lea rax, [unknown]
    mov qword [id_str], rax
    jmp .id_noquote
.id_found:
    ; check if line starts with ID=
    mov rdi, qword [id_str]
    lea rsi, [os_release_id] 
    call str_startswith
    cmp rax, 0
    jne .id_loop
.id_end:
    ; cleanup string
    mov rax, qword [id_str]
    add rax, 3              ; remove ID=
    mov qword [id_str], rax
    push rax
    mov rsi, rax
    call _strlen
    mov rbx, rax
    pop rax
    cmp byte [rax+rbx-1], 0x22
    jne .id_noquote
    mov byte [rax+rbx-1], 0

    cmp byte [rax], 0x22
    jne .id_noquote
    inc rax
    mov qword [id_str], rax
.id_noquote:
    ; print distro art
    mov rdi, qword [id_str]
    call print_art
    mov qword [distro_lines], rax

    lea rdi, [moveup1]
    mov rsi, 1
    call print

    ; move up
    mov rsi, qword [distro_lines]
    ;dec rsi
    lea r10, [upbuf]
    call _itoa

    lea rdi, [upbuf]
    mov rsi, 1
    call print

    lea rdi, [moveup2]
    mov rsi, 1
    call print
    

    ; print OS line
    mov rdi, os_line
    mov rsi, 1
    call print
    ; open file
    mov rax, 2
    lea rdi, [os_release_path]
    mov rsi, 0
    mov rdx, 0
    syscall
    mov qword [os_fp], rax
.os_loop:
    ; readline
    mov rdi, qword [os_fp]
    call read_line
    mov qword [os_str], rax
    cmp rdx, 0
    jne .os_found
    lea rax, [unknown]
    mov qword [os_str], rax
    jmp .os_noquote
.os_found:
    ; check if line starts with NAME=
    mov rdi, qword [os_str]
    lea rsi, [os_release_name] 
    call str_startswith
    cmp rax, 0
    jne .os_loop
.os_end:
    ; cleanup string
    mov rax, qword [os_str]
    add rax, 5              ; remove NAME=
    mov qword [os_str], rax
    push rax
    mov rsi, rax
    call _strlen
    mov rbx, rax
    pop rax
    cmp byte [rax+rbx-1], 0x22
    jne .os_noquote
    mov byte [rax+rbx-1], 0

    cmp byte [rax], 0x22
    jne .os_noquote
    inc rax
    mov qword [os_str], rax
.os_noquote:
    ; print OS info
    mov rdi, qword [os_str]
    mov rsi, 0
    call print
    add qword [lines_printed], 1

    ; print host line
    mov rdi, host_line
    mov rsi, 1
    call print
    ; get utsname struct using syscall
    mov rax, 63                 ; 63 -> sys_uname
    lea rdi, [utsname_buffer]   ; utsname buffer pointer
    syscall                     ; call sys_uname
    ; print host info
    lea rdi, [utsname_buffer+65]
    mov rsi, 0
    call print
    add qword [lines_printed], 1

    ; print kernel line
    mov rdi, kernel_line
    mov rsi, 1
    call print
    ; print kernel type
    lea rdi, [utsname_buffer] 
    mov rsi, 1
    call print
    ; print space
    push 0x20                   ; ASCII space
    mov rdi, rsp
    mov rsi, 1
    call print
    sub rsp, 8
    ; print kernel release
    lea rdi, [utsname_buffer+130] 
    mov rsi, 0
    call print
    add qword [lines_printed], 1

    ; print uptime line
    mov rdi, uptime_line
    mov rsi, 1
    call print
    ; get sys_info struct
    mov rax, 99
    lea rdi, [sysinfo_buffer] 
    syscall
    ; get uptime from struct
    mov qword rax, [sysinfo_buffer]
    ; convert int to string
    mov rsi, rax
    lea r10, [uptime_str]
    call _itoa
    ; print uptime info
    lea rdi, [uptime_str]
    mov rsi, 1
    call print
    ; print time format
    lea rdi, [uptime_secs]
    mov rsi, 0
    call print
    add qword [lines_printed], 1

    ; print cpu line
    mov rdi, cpu_line
    mov rsi, 1
    call print

    ; read first 16 bytes of CPU name
    mov eax, 0x80000002
    cpuid
    mov [cpu_name], eax
    mov [cpu_name+4], ebx
    mov [cpu_name+8], ecx
    mov [cpu_name+12], edx
    ; read second 16 bytes of CPU name
    mov eax, 0x80000003
    cpuid
    mov [cpu_name+16], eax
    mov [cpu_name+20], ebx
    mov [cpu_name+24], ecx
    mov [cpu_name+28], edx
    ; read third 16 bytes of CPU name
    mov eax, 0x80000004
    cpuid
    mov [cpu_name+32], eax
    mov [cpu_name+36], ebx
    mov [cpu_name+40], ecx
    mov [cpu_name+44], edx
    ; null terminate the cpu_name
    mov byte [cpu_name+48], 0

    ; print cpu info
    mov rdi, cpu_name
    mov rsi, 0
    call print
    add qword [lines_printed], 1

    ; print gpu line
    mov rdi, gpu_line
    mov rsi, 1
    call print
    ; TODO get gpu info
    call get_gpu
    ; print gpu info
    mov rdi, rax
    mov rsi, 0
    call print
    add qword [lines_printed], 1

    ; print memory line
    mov rdi, memory_line
    call print
    ; read raminfo into rax
    mov qword rax, [sysinfo_buffer+32]  ; totalram
    push rax                ; push rax into the stack for later use
    mov qword rcx, [sysinfo_buffer+40]  ; freeram
    sub rax, rcx                        ; rax = totalram - freeram
    mov qword rcx, [sysinfo_buffer+48]  
    sub rax, rcx                        ; rax = totalram - freeram - sharedram
    mov qword rcx, [sysinfo_buffer+56]  
    sub rax, rcx                        ; rax = totalram - freeram - sharedram - bufferam
    mov rcx, 1048576        ; 1024 * 1024
    mov rdx, 0              ; important for unsigned division
    div rcx                 ; convert bytes into MiB

    mov rsi, rax            ; move result into rsi
    ; convert num into int
    lea r10, [mem_used_str]
    call _itoa
    ; print totalram 
    lea rdi, [mem_used_str]
    mov rsi, 1
    call print
    ; print "MiB / "
    lea rdi, [mib_str]
    mov rsi, 1
    call print
    lea rdi, [mib_spacer]
    mov rsi, 1
    call print
    ; print total ram
    pop rax                 ; retrieve totalram from the stack
    mov rcx, 1048576        ; convert into MiB
    mov rdx, 0              ; important for unsigned vicision
    div rcx                 
    mov rsi, rax            
    lea r10, [mem_total_str]   
    call _itoa                  ; convert to a string
    lea rdi, [mem_total_str]
    mov rsi, 1
    call print           ; print string
    ; print " MiB"
    lea rdi, [mib_str]
    mov rsi, 0
    call print
    add qword [lines_printed], 1

    ; print lines to be sure to not cut off the distro art
    mov r8, qword [distro_lines]      
    mov r9, qword [lines_printed]      
    cmp r8, r9
    jb .exit
    je .exit
    mov r10, 0
    sub r8, r9
.newline_loop:
    push r8
    push r10
    mov rax, 0x0A00
    push rax
    mov rdi, rsp
    mov rsi, 1
    call print
    pop rax
    pop r10
    pop r8
    inc r10
    cmp r8, r10
    jne .newline_loop

.exit:
    sub rsp, 5
    mov byte [rsp], 0x1b
    mov byte [rsp+1], "["
    mov byte [rsp+2], "0"
    mov byte [rsp+3], "m"
    mov byte [rsp+4], 0
    mov rdi, rsp
    mov rsi, 1
    call print
    pop rax
    add rsp, 5
    ; exit syscall
    mov rax, 60            ; syscall: exit
    xor rdi, rdi           ; status: 0
    syscall


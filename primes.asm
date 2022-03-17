%define TRUE 1
%define FALSE 0

    section .data

range_min: dq 0
range_max: dq 10000

result: db "Total primes: "
result_length: equ $ - result

    section .text

global _start

; Writes unsigned integer to stdout
; @arg   rax   Target integer
; @use   rax, rdi, rsi, rdx
write_uint:
    dec rsp
    mov byte [rsp], 0

.push_digit:
    xor rdx, rdx
    mov rcx, 10
    div rcx

    dec rsp
    mov byte [rsp], dl
    add byte [rsp], "0"

    or rax, rax
    jnz .push_digit

.write_digit:
    cmp byte [rsp], 0
    je .exit

    mov rax, 1
    mov rdi, 1
    mov rsi, rsp
    mov rdx, 1
    syscall

    inc rsp
    jmp .write_digit

.exit:
    inc rsp
    ret

; Writes character to stdout
; @in    rax   Target character
; @use   rax, rdi, rsi, rdx
write_character:
    dec rsp
    mov byte [rsp], al

    mov rax, 1
    mov rdi, 1
    mov rsi, rsp
    mov rdx, 1
    syscall

    inc rsp
    ret

; Writes newline character (\n) to stdout
; @use   rax, rdi, rsi, rdx
write_newline:
    mov byte [rsp - 1], 0xa

    mov rax, 1
    mov rdi, 1
    lea rsi, [rsp - 1]
    mov rdx, 1
    syscall

    ret

; Returns TRUE if unsigned integer is prime or FALSE if not
; @in    rax   Target integer
; @out   rax   TRUE if prime or FALSE if not
; @use   rax, rcx, rdx, r8, r9, r10
is_uiprime:
    cmp rax, 2
    jl .exit_false

    mov r9, rax

    xor rdx, rdx
    mov rcx, 2
    div rcx

    mov r8, rax
    mov r10, 1

.loop:
    inc r10
    cmp r10, r8
    jg .exit_true

    mov rax, r9
    xor rdx, rdx
    mov rcx, r10
    div rcx

    or rdx, rdx
    jz .exit_false

    jmp .loop

.exit_true:
    mov rax, TRUE
    ret

.exit_false:
    mov rax, FALSE
    ret

_start:
    mov r8, [range_min]

    xor rcx, rcx
    push rcx

.loop:
    push r8

    mov rax, r8
    call is_uiprime

    pop r8

    cmp rax, FALSE
    je .advance

    pop rcx
    inc rcx
    push rcx

    mov rax, r8
    call write_uint
    call write_newline

.advance:
    inc r8
    cmp r8, [range_max]
    jne .loop

.exit:
    mov rax, "["
    call write_character

    mov rax, 1
    mov rdi, 1
    mov rsi, result
    mov rdx, result_length
    syscall

    pop rax
    call write_uint

    mov rax, "]"
    call write_character
    call write_newline

    mov rax, 60
    xor rdi, rdi
    syscall

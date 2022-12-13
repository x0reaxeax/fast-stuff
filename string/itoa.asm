%define MUL_MAGIC   0xcccccccccccccccd

; void itoa(uint64_t num, char *outbuf);
global itoa

section .text

; convert uint64 to array of characters
itoa:
    push    rbx
    push    rdi
    call    ndigits

    test    al, al
    jz      .end

    mov     bl, al                  ; counter
                                    ; `- rbx = ndigits = i
                                    ; rdi = num => num /= 10
.loop:
    call    get_last_digit
    mov     r12, rdi                ; save num
    mov     edi, eax
    call    dtoc                    ; convert digit to char
    mov     BYTE [rsi + rbx - 1], al

    mov     rdi, r12
    call    divu10_64
    mov     rdi, rax

    dec     bl
    test    bl, bl
    jnz     .loop
.end:
    pop     rdi
    pop     rbx
    ret


; count digits in integer
; uint8_t ndigits(uint64_t num);
ndigits:
    push    rdi
    xor     ecx, ecx        ; count
    inc     cl
.loop:
    call    divu10_64
    mov     rdi, rax
    test    rax, rax
    jz      .end
    inc     cl
    jmp     .loop
.end:
    pop     rdi
    movzx   eax, cl
    ret

; extracts last digit from an integer
get_last_digit:
    push    rdi
    call    divu10_64
    mov     edx, 0xa
    mul     rdx
    sub     rdi, rax
    xchg    rdi, rax
    pop     rdi
    ret

; convert int digit to char representation
dtoc:
    lea eax, [rdi + 0x30]   ; +48
    ret

; fast divide by 10, without `div` instruction
divu10_64:
    mov     rdx, MUL_MAGIC
    mov     rax, rdi
    mul     rdx
    mov     rax, rdx
    shr     rax, 0x3
    ret

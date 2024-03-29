[bits 64]

create_thread:  push    rbp             ; C overhead
                mov     rbp,    rsp
                mov     rdx,    rsi     ; Stack pointer
                sub     rdx,    8       ; Align stack
                mov     rsp,    rdx     ; Set stack pointer
                mov     [rsp],  rdi     ; Function pointer
                mov     rsp,    rbp     ; C lowerhead
                pop     rbp

                ret
join_threads:
                push    rbp
                mov     rbp,    rsp
                mov     r14,    rdi
join_thread_lp: cmp     r14,    rdi
                jne     join_thread_lp
                mov     r14
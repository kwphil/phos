[bits 64]

create_thread:  push    rbp
                mov     rsp,    rbp
                mov     rdx,    rsi
                sub     rdx,    8
                mov     rsp,    rdx
                mov     [rsp],  rdi
                mov     rsp,    rbp
                pop     rbp

                ret
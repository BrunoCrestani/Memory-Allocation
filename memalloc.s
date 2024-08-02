.section .data
original_brk: .quad 0
current_brk: .quad 0

.section .text

.global original_brk
.global current_brk

.global setup_brk
.global dismiss_brk
.global memory_alloc
.global memory_free

setup_brk:
    movq $0, original_brk # Atribui 0 ao brk original
    movq original_brk, %rdi # Atribui brk original (0) ao rdi
    movq $12, %rax # syscall de brk
    syscall
    movq %rax, current_brk  # Atribui o endereço de brk consultado em brk current
    movq %rax, original_brk # Atribui o endereço de brk consultado em brk original 
    ret

dismiss_brk:
    movq original_brk, %rdi # Atribui o brk original a rdi
    movq $12, %rax # syscall de brk
    syscall
    movq %rdi, current_brk # Atribui rdi ao brk original
    ret

memory_alloc:
    # Tamanho de alocacao solicitado esta em rdi
    movq original_brk, %r8 #Armazena o valor original de brk em r8
    movq current_brk, %r9 #Armazena o valor atual de rbk em r9
    movq %rdi, %r10 #Salva o rdi(argumento)
    cmpq %r8, %r9 # Se current == brk ja estamos em um bloco vazio
    je alloc_block 

    movq %r8, %r11 #Armazena o valor original de rbk em r11
    movq $0, %r14 #r14 sera responsavel por guardar o endereco
    movq $0, %r15 #r15 sera responsavel por guardar o tamanho

    .finding:
    cmpq $0, (%r11) #Verifica se o bloco esta vazio
    jne .next_block

    cmpq 8(%r11), %rdi #Verifica se o bloco atual é maior ou igual o tamanho solicitado
    jg .next_block

    cmpq 8(%r11), %r15 #Verifica se o bloco atual é maior do que o maior bloco encontrado
    jg .next_block
 
    movq 8(%r11), %r15 #Salva o tamanho do bloco em r15
    movq %r11, %r14 #Salva o endereco do bloco em r14 
    jmp .next_block

fit:
    movq $1, (%r14) #Indica que o bloco agora esta ocupado
    
    movq %r15, %r12 #r12 recebe o tamanho do bloco atual
    subq %r10, %r12 #diminui o rdi do tamanho
    cmpq $17, %r12
    jge .splitting

    addq $16, %r14
    movq %r14, %rax
    ret

alloc_block:
    addq $16, %r9 #Endereco a ser retornado
    movq %r9, %r12 #salva o endereco
    addq %rdi, %r9 #Adiciona o tamanho do bloco solicitado na posicao pos tags

    movq %r9, %rdi

    movq $12, %rax
    syscall

    movq current_brk, %r8 # Endereco do novo bloco
    movq $1, (%r8) # current brk recebe 1
    movq %r10, 8(%r8) 
    movq %r9, current_brk # novo current brk apos o novo bloco

    movq %r12, %rax #retornar endereco do novo bloco
    ret

.next_block:
    addq 8(%r11), %r11 #Adiciona qual for o tamanho do bloco ocupado no endereco que estamos (vai ate o fim do bloco - 9)
    addq $16, %r11  #Pula os 16 bits restantes

    cmpq %r9, %r11 #Verifica se ainda estamos dentro da Heap
    jl .finding

    cmpq $0, %r14 #se r14 == 0, podemos alocar um bloco
    je alloc_block

    jmp fit

.splitting:
    movq %r10, 8(%r14) #Demarca o espaco do primeiro bloco
    addq $16, %r14 #Espaco das tags
    movq %r14, %r13 #Salva o endereco do primeiro bloco

    addq %r10, %r14 #r14 = r14 + o tamanho requerido
    movq $0, (%r14) #demarca o bit para 0

    subq $16, %r12
    movq %r12, 8(%r14)

    movq %r13, %rax
    ret

memory_free:
  movq original_brk, %r8 #Armazena o valor original de brk em rbx
  movq current_brk, %r9 #Armazena o valor atual de brk em rcx
  cmpq %rdi, %r8 
  jg .alloc_fail
  cmpq %rdi, %r9
  jl .alloc_fail
  movq $0, -16(%rdi) #Define o bit de marcacao como livre
  ret

.alloc_fail:
  movq $0, %rax
  ret

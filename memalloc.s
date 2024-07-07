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
  movq original_brk, %rbx #Armazena o valor original de brk em rbx
  movq current_brk, %r8 #Armazena o valor atual de rbk em r8 
  movq %rdi, %r9 #Salva o rdi(argumento)
  
  cmpq %rbx, %r8 # Se current == brk ja estamos em um bloco vazio
  je .alloc_block

  movq %rbx, %r10 #Armazena o valor original de rbk em r10
  
  .finding:
  cmpq $0, (%r10) #Verifica se o bloco esta vazio
  jne .next_block

  cmpq 8(%r10), %r9 #Verifica se o tamanho do bloco e suficiente para o bloco
  jg .next_block

  movq $1, (%r10) #Demarca o primeiro bit como 1 para sinalizar a ocupacao do bloco
  movq 8(%r10), %r12 #Salva o tamanho do bloco em r12 
  subq %r9, %r12 # Diminui do tamanho o rdi
  cmpq $17, %r12 
  jg .splitting

  addq $16, %r10
  movq %r10, %rax
  ret

.alloc_block:
  addq $16, %r8 #Endereco a ser retornado
  movq %r8, %r12 #salva o endereco
  addq %rdi, %r8 #Adiciona o tamanho do bloco solicitado na posicao pos tags

  movq %r8, %rdi
  movq $12, %rax
  syscall

  movq current_brk, %rbx # Endereco do novo bloco
  movq $1, (%rbx) # current brk recebe 1
  movq %r9, 8(%rbx) 
  movq %r8, current_brk # novo current brk apos o novo bloco

  movq %r12, %rax #retornar endereco do novo bloco
  ret

  .next_block:
  addq 8(%r10), %r10 #Adiciona qual for o tamanho do bloco ocupado no endereco que estamos (vai ate o fim do bloco - 9)
  addq $16, %r10  #Pula os 9 bits restantes

  cmpq %r8, %r10 #Verifica se ainda estamos dentro da Heap
  jg .alloc_block

  jmp .finding

  .splitting:
  movq %r9, 8(%r10) #Demarca o espaco do primeiro bloco
  addq $16, %r10 #Espaco das tags
  movq %r10, %r11 #Salva o endereco do primeiro bloco

  addq %r9, %r10 #r10 = r10 + o tamanho requerido
  movq $0, (%r10) #demarca o bit para 0

  subq $16, %r12 
  movq %r12, 8(%r10)

  movq %r11, %rax
  ret

memory_free:
  movq original_brk, %rbx #Armazena o valor original de brk em rbx
  movq current_brk, %rcx #Armazena o valor atual de brk em rcx
  cmpq %rdi, %rbx 
  jg .alloc_fail
  cmpq %rdi, %rcx
  jl .alloc_fail
  movq $0, -16(%rdi) #Define o bit de marcacao como livre
  ret

.alloc_fail:
  movq $0, %rax
  ret

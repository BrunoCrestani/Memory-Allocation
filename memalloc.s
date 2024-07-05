.section .data
original_brk: .quad 0
brk_current: .quad 0

.section .text
.global setup_brk

.type setup_brk, @function
.global dismiss_brk

.type dismiss_brk, @function
.global original_brk
.global brk_current
.global memory_alloc

.type memory_alloc, @function
.global memory_free

.type memory_free, @function

setup_brk:
  movq $0, original_brk # Atribui 0 ao brk original
  movq original_brk, %rdi # Atribui brk original (0) ao rdi
  movq $12, %rax # syscall de brk
  syscall
  movq %rax, brk_current  # Atribui o endereço de brk consultado em brk current
  movq %rax, original_brk # Atribui o endereço de brk consultado em brk original 
  ret

dismiss_brk:
  movq original_brk, %rdi # Atribui o brk original a rdi
  movq $12, %rax # syscall de brk
  syscall
  movq %rdi, brk_current # Atribui rdi ao brk original
  ret

memory_alloc:
  # Atribui brk atual em rax
  mov brk_current, %rax 

  # Calcula o novo endereco com base no rdi recebido e o endereco atual(rax)
  add %rdi, %rax 

  # syscall do brk com o endereco atualizado
  mov $12, %rax 
  mov %rax, %rdi # argumento de brk(rdi = new_brk)
  syscall

  # verifica valor de rax
  test %rax, %rax 
  js alloc_fail ##Jump to alloc_fail  if less then zero 

  # Atualiza o brk atual e retorna o antigo
  mov brk_current, %rax
  mov %rdi, brk_current
  ret

alloc_fail:
  xor %rax, %rax 
  ret

alloc_new_block:

memory_free:
  xor %rax, %rax 
  ret

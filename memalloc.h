#ifndef MEMORY_FUNCTIONS_H
#define MEMORY_FUNCTIONS_H

/*
 * Obtém o endereço de brk
 */
void setup_brk(); 

/*
 * Restaura o endereço de brk
 */
void dismiss_brk(); 

/*
 * Executa brk para abrir um bloco de "bytes" bytes 
 */
void* memory_alloc(unsigned long int bytes); 

/*
 * Não executa nada
 */
int memory_free(void *pointer); 

#endif // MEMORY_FUNCTIONS_H  


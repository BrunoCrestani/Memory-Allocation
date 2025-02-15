/*
 * Obtém o endereço de brk
 */
void setup_brk();

/*
 * Restaura o endereço de brk
 */
void dismiss_brk();

/*1. Procura bloco livre com tamanho igual ou maior que a requisição 
 *2. Se encontrar, marca ocupação e retorna o endereço do bloco
 *3. Se não encontrar, abre espaço para um novo bloco
 */
void* memory_alloc(unsigned long int bytes); 

/*
 * Marca um bloco ocupado como livre
 */
int memory_free(void *pointer);

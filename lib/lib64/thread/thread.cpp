#include <stdlib.h>
#include "../mem/malloc.h"

#define DEFAULT_STACK_SIZE

extern "C" void create_thread( void *func_ptr, void *stack_ptr );

class thread {
    private:
        size_t _stackSize = DEFAULT_STACK_SIZE;
        char *_stack;
        void *_funcPtr;
    public:
        thread(size_t stackSize, void *funcPtr) {
            _stackSize = stackSize;
            _funcPtr = funcPtr;

            _stack = (char *)malloc(_stackSize);
        }

        thread(void *funcPtr) {
            _funcPtr = funcPtr;

            _stack = (char *)malloc(_stackSize);
        }

        void setFunc(void *funcPtr) {
            _funcPtr = funcPtr;
        }

        void fork() {
            create_thread( _funcPtr, _stack );
        }

        static void Fork( size_t stackSize, void *funcPtr ) {
            char *stack = (char *)malloc(stackSize);
            create_thread( stack, funcPtr );
        }

        static void Fork( void *funcPtr ) {
            char *stack = (char *)malloc(DEFAULT_STACK_SIZE);
            create_thread( stack, funcPtr );
        }
}
mod core::ffi

extern "C" {
    fn malloc(size: &c_size_t) -> u64;
    fn create_thread(func_ptr: *c_void, stack_ptr: *c_void);
}

struct thread {
    let _stack_size: c_size_t = 2048;
    let _stack: *c_void;
    let _func: *();

    static fn new(stack_size: u128, function: *()) {
        _stack_size = stack_size;
        _stack = malloc(_stack_size);
        _func = function;
    }

    static fn new(function: *()) {
        _stack = malloc(_stack_size);
        _func = function;
    }

    fn fork() {
        unsafe {
            create_thread(&function, malloc(&(_stack_size as c_size_t)));
        }
    }

    static fn Fork(stack_size: u128, function: *()) {
        unsafe {
            create_thread(&function, malloc(&(stack_size as c_size_t)));
        }
    }
}
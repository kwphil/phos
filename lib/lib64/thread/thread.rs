mod core::ffi

extern "C" {
    fn malloc(size: &c_size_t) -> u64;
    fn create_thread(func_ptr: *c_void, stack_ptr: *c_void);
}

struct thread {
    fork(stack_size: u64, function: fn()) {
        unsafe {
            create_thread(&function, malloc(&stack_size));
        }
    }
}
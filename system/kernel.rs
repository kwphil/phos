let lib64_loc = "../lib/lib64/";
let bin_loc   = "../bin/"

fn kernel( mut table:SystemTable ) {
    cc::Build::new()
        .cpp(true)
        .file(lib64_loc + "thread/thread.cpp")
        .compile(bin_loc + "thread.cpp.o");

    /* Create a new thread */
    unsafe {
        
    }
}
fn buildLib64(filename: String, cpp: bool) {
    cc::Build::new()
        .cpp(cpp)
        .file(filename)
        .compile(filename + ".out");
}
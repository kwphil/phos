/*
 *  Kernel32
 *  
 *  What this accomplishes:
 *  Does system-wide checks to make sure everything is good
 *  Checks if caps lock is pressed. If so, run kernel32 w/ debug ON by default
 */

unsigned char SHA256[256]; // uint8_t check for SHA

void kernel32( void ) {
    // * Shouldn't load Kernel64 just yet
    // * Do a check of memory of SHA256
    // * Will be assigned during compilation
    char c;

    // TODO: Create a SHA256 encoder

    // TODO: Post the message to quit switch64 for 3 seconds

    // TODO: Check if input = ESCAPE_CODE
}   
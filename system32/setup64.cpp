extern void switch_64( void ); /* Defined in switch64.asm */

void setup64( void ) {
    // TODO: Create a sha512 check. I know that we did this with 256, but do it again.
    shaCheck.check(sha);

    // * Here we are switching to 64 bit
    switch_64();
}

SHA512 shaCheck; /* Class dedicated to SHA512 */
char sha[512];
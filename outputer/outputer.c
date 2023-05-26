#include <stdio.h>
#include <stdarg.h>
#include "substitute.h"

int main(int argc, char const *argv[])
{
    int x = 0;
    //clear output file
    FILE *fp = fopen(OUTPUT, "w");
    fclose(fp);
    printfSplitter("Hello world! %c\n", 'x');
    scanfSplitter("%d", &x);
    printfSplitter("Num: %d", x);
    return 0;
}

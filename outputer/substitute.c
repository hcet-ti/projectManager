#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include "substitute.h"

int printfSplitter (const char *output, const char *format, ...)
{
    va_list arg;
    FILE *fp = fopen(output, "a");
    int done;

    va_start (arg, format);
    done = vfprintf (stdout, format, arg);
    vfprintf (fp, format, arg);
    va_end (arg);

    fclose(fp);
    return done;
}

int scanfSplitter(const char *output, const char *fmt, ...)
{
    int rc;

    va_list args;
    char input[2047] = "";
    scanf("%s", input);
    va_start(args, fmt);
    rc = vsscanf(input, fmt, args);
    va_end(args);
    
    strcat(input, "\n");
    FILE *fp = fopen(output, "a");
    fputs(input, fp);
    fclose(fp);

    return rc;
}
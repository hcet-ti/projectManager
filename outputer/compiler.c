#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <process.h>

// You must free the result if result is non-NULL.
char *strrep(char *orig, char *rep, char *with) {
    char *result; // the return string
    char *ins;    // the next insert point
    char *tmp;    // varies
    int len_rep;  // length of rep (the string to remove)
    int len_with; // length of with (the string to replace rep with)
    int len_front; // distance between rep and end of last rep
    int count;    // number of replacements

    // sanity checks and initialization
    if (!orig || !rep)
        return NULL;
    len_rep = strlen(rep);
    if (len_rep == 0)
        return NULL; // empty rep causes infinite loop during count
    if (!with)
        with = "";
    len_with = strlen(with);

    // count the number of replacements needed
    ins = orig;
    for (count = 0; tmp = strstr(ins, rep); ++count) {
        ins = tmp + len_rep;
    }

    tmp = result = malloc(strlen(orig) + (len_with - len_rep) * count + 1);

    if (!result)
        return NULL;

    // first time through the loop, all the variable are set correctly
    // from here on,
    //    tmp points to the end of the result string
    //    ins points to the next occurrence of rep in orig
    //    orig points to the remainder of orig after "end of rep"
    while (count--) {
        ins = strstr(orig, rep);
        len_front = ins - orig;
        tmp = strncpy(tmp, orig, len_front) + len_front;
        tmp = strcpy(tmp, with) + len_with;
        orig += len_front + len_rep; // move to next "end of rep"
    }
    strcpy(tmp, orig);
    return result;
}

int main(int argc, char const *argv[])
{
    char cmd[_MAX_PATH * 3 + 16] = "";
    FILE *fpre = NULL;
    FILE *fpin = NULL;
    FILE *fpout = NULL;
    char buff[255] = "";
    char *mod = NULL;
    char *comp = NULL;
    char tmp[255] = "";
    if ((fpin = fopen(argv[1], "r")) != NULL)
    {
        comp = strrep(argv[0], "compiler.exe", "output.txt");
        fpre = fopen(comp, "w");
        fclose(fpre);
        comp = strrep(argv[0], "compiler.exe", "moded.c");
        fpout = fopen(comp, "w");
        while (fgets(buff, 255, fpin) != NULL)
        {
            comp = strrep(argv[0], "compiler.exe", "substitute.h");
            strcpy(tmp, "#include <stdio.h>\n#include \"");
            strcat(tmp, comp);
            comp = strrep(argv[0], "compiler.exe", "output.txt");
            comp = strrep(comp, "\\", "\\\\");
            strcat(tmp, "\"\n#define OUTPUT \"");
            strcat(tmp, comp);
            strcat(tmp, "\"");
            mod = strrep(buff, "printf(", "printfSplitter(OUTPUT, ");
            mod = strrep(mod, "scanf(", "scanfSplitter(OUTPUT, ");
            mod = strrep(mod, "#include <stdio.h>", tmp);
            mod = strrep(mod, "#include<stdio.h>", tmp);
            fputs(mod, fpout);
            free(mod);
        }
        fclose(fpin);
        fclose(fpout);

        strcpy(cmd, "gcc \"");
        comp = strrep(argv[0], "compiler.exe", "substitute.c");
        strcat(cmd, comp);
        strcat(cmd, "\" \"");
        comp = strrep(argv[0], "compiler.exe", "moded.c");
        strcat(cmd, comp);
        strcat(cmd, "\" -o \"");
        comp = strrep(argv[0], "compiler.exe", "program.exe");
        strcat(cmd, comp);
        strcat(cmd, "\"");
        //printf("cmd: %s\n", cmd);
        system(cmd);
        free(comp);
    } else 
    {
        printf("Please provide an argument.\n");
    }
    
    return 0;
}

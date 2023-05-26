#include "pathTraverser.h"

int main(int argc, char const *argv[])
{
    struct Traverser traveler = initTraverser(argv[0]);

    printf("%s\n", getExeTraverser(&traveler));
    printf("%s\n", getRootTraverser(&traveler));
    printf("%s\n", getFileTraverser(&traveler, NULL, ""));
    printf("%s\n", getFileTraverser(&traveler, NULL, "main.c"));
    printf("%s\n", getFileTraverser(&traveler, NULL, "src" DIR_DELIMITER "main.c"));

    stopTraverser(&traveler);

    return 0;
}
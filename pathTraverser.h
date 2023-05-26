#ifndef PATH_TRAVERSER_H
#define PATH_TRAVERSER_H

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#if defined(WIN32) || defined(_WIN32) || defined(__WIN32) && !defined(__CYGWIN__)
#include <direct.h>
#define ChangeDir _chdir
#define GetCurrentDir _getcwd
#define DIR_DELIMITER "\\"
#define DIR_DELIMITER_CHAR '\\'
#else
#include <unistd.h>
#define ChangeDir chdir
#define GetCurrentDir getcwd
#define DIR_DELIMITER "/"
#define DIR_DELIMITER_CHAR '/'
#endif

#define TRAV_INIT_CAPACITY 6

#define TRAV_FAILURE 0
#define TRAV_SUCCESS 1

/// @brief Internal structure to hold all the references to the Traverser
struct TraverserList
{
    int capacity;
    int length;
    char **data;
};

/// @brief Traverser structure, used to manipulate filepaths.
/// @note Functions associated with Traverser: initTraverser, getFileTraverser, setRootTraverser, getRootTraverser, getExeTraverser, stopTraverser
struct Traverser
{
    char *root;
    char *exe;
    struct TraverserList references;
};

/// @brief Internal function to append a pointer to the Traverser, so that it can be freed later.
/// @param traveler pointer to the Traverser
/// @param reference char pointer to append to the Traverser
/// @return status (0 = Failure, 1 = Success)
int addReferenceTraverser(struct Traverser *traveler, char *reference)
{
    int status = TRAV_FAILURE;

    if (traveler->references.capacity <= traveler->references.length)
    {
        if ((traveler->references.data = (char **)realloc(traveler->references.data, traveler->references.capacity * 2 * sizeof(char *))) == NULL)
        {
            return status;
        }
        traveler->references.capacity *= 2;
    }
    traveler->references.data[traveler->references.length++] = reference;
    status = TRAV_SUCCESS;
    
    return status;
}

/// @brief Gets the full path to the provided filename.
/// @param traveler pointer to the Traverser
/// @param directory The directory to add the filename to. If NULL root is assumed
/// @param filename relative path to the file
/// @return a pointer to the full path of the filename. NULL if there is no more memory.
char *getFileTraverser(struct Traverser *traveler, char *directory, char *filename)
{
    char *filepath;

    if (directory == NULL)
    {
        directory = traveler->root;
    }

    if ((filepath = (char *)malloc(strlen(directory) + 1)) == NULL)
    {
        return NULL;
    }

    strcpy(filepath, directory);
    if (filepath[strlen(filepath) - 1] != DIR_DELIMITER_CHAR)
    {
        if ((filepath = (char *)realloc(filepath, strlen(filepath) + 2)) == NULL)
        {
            return NULL;
        }
        strcat(filepath, DIR_DELIMITER);
    }

    if ((filepath = (char *)realloc(filepath, strlen(filepath) + strlen(filename) + 1)) == NULL)
    {
        return NULL;
    }
    strcat(filepath, filename);

    addReferenceTraverser(traveler, filepath);
    
    return filepath;
}

/// @brief Manually sets the root of the Traverser to be used.
/// @param traveler pointer to the Traverser
/// @param root The new root to be used
/// @return status (0 = Failure, 1 = Success)
int setRootTraverser(struct Traverser *traveler, char *root)
{
    int status = TRAV_FAILURE;

    if (traveler->root == NULL)
    {
        if ((traveler->root = (char *)malloc(strlen(root) + 1)) == NULL)
        {
            return status;
        }
    }
    strcpy(traveler->root, root);

    return status;
}

/// @brief Return the root directory of the Traverser.
/// @param traveler pointer to the Traverser
/// @return the pointer to the root directory 
const char *getRootTraverser(struct Traverser *traveler)
{
    return traveler->root;
}

/// @brief Return the name of the executable.
/// @param traveler pointer to the Traverser
/// @return the pointer to the executable name (ex.: program.exe)
const char *getExeTraverser(struct Traverser *traveler)
{
    return traveler->exe;
}

/// @brief Internal function to automatically append the directory of the executable to the Traverser.
/// @param traveler pointer to the Traverser
/// @param argv0 the first element in the array of command-line arguments
/// @return status (0 = Failure, 1 = Success)
int detectRootTraverser(struct Traverser *traveler, const char *argv0)
{
    int status = TRAV_FAILURE;
    char buff[FILENAME_MAX] = "";
    char save[FILENAME_MAX] = "";
    const char *pathEnd;

    // save current directory
    if ((GetCurrentDir(save, FILENAME_MAX)) == NULL)
    {
        return status;
    }

    // extract exe path from argv[0] (possibly relative) and move into the directory
    pathEnd = strrchr(argv0, DIR_DELIMITER_CHAR);
    if (pathEnd == NULL) 
    {
        return status;
    }
    strncpy(buff, argv0, pathEnd - argv0);
    buff[pathEnd - argv0] = '\0';
    ChangeDir(buff);
    
    // get the absolute path of the current working directory
    if (GetCurrentDir(buff, FILENAME_MAX) != NULL)
    {
        if (setRootTraverser(traveler, buff) == TRAV_FAILURE)
        {
            return status;
        }
        status = TRAV_SUCCESS;
    }

    // change back to the saved directory
    ChangeDir(save);

    return status;
}

/// @brief Free all memory currently used by the Traverser.
/// @param traveler status (0 = Failure, 1 = Success)
void stopTraverser(struct Traverser *traveler)
{
    if (traveler->root != NULL)
    {
        free(traveler->root);
        traveler->root = NULL;
    }
    
    if (traveler->exe != NULL)
    {
        free(traveler->exe);
        traveler->exe = NULL;
    }

    if (traveler->references.data != NULL)
    {
        for (size_t i = 0; i < traveler->references.length; i++)
        {
            if (traveler->references.data[i] != NULL)
            {
                free(traveler->references.data[i]);
            }
        }
        
        free(traveler->references.data);
        traveler->references.data = NULL;
    }
    
}

/// @brief Initilize all default values for the Traverser and allocate the starting memory.
/// @return Traverser with default values
struct Traverser initTraverser(const char *argv0)
{
    struct Traverser traveler;
    struct TraverserList references;

    // set defaults
    traveler.root = NULL;
    references.capacity = TRAV_INIT_CAPACITY;
    references.length = 0;
    references.data = (char **)malloc(sizeof(char *) * references.capacity);
    traveler.references = references;
    traveler.exe = (char *)malloc(strlen(strrchr(argv0, DIR_DELIMITER_CHAR) + 1) + 1);
    strcpy(traveler.exe, strrchr(argv0, DIR_DELIMITER_CHAR) + 1);
    detectRootTraverser(&traveler, argv0);

    return traveler;
}

#endif
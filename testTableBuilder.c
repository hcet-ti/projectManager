#include "PDFGen-0.1.0/pdfgen.h"
#include "pathTraverser.h"
#include <conio.h>
#include <stdbool.h>
#include <process.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>

// misc
#define MAX_READ 1024
#define UI_PLACEHOLDER "   "
#define UI_TITLE_1 "input data"
#define UI_TITLE_2 "output data - target"
#define UI_TITLE_3 "output data - actual"

// cursor
#define CURSOR_UP 1
#define CURSOR_DOWN 2
#define CURSOR_LEFT 3
#define CURSOR_RIGHT 4

// states
#define TABL_FAILURE 0
#define TABL_SUCCESS 1

// entries (deprecated)
#define ENTRY_INPUT_VARS 1
#define ENTRY_INPUT_VALUES 2
#define ENTRY_TARGET_VARS 3
#define ENTRY_TARGET_VALUES 4
#define ENTRY_ACTUAL_VARS 5
#define ENTRY_ACTUAL_VALUES 6

// ids
#define ID_INPUT 0
#define ID_TARGET 1
#define ID_ACTUAL 2

// keycodes
#define START 18 // Ctrl-R
#define DONE 19 // Ctrl-S
#define RESIZE 20 // Ctrl-T
#define HELP 63
#define BACKSPACE 8
#define TAB 9
#define ENTER 13
#define SPECIAL_ARROW_UP 72
#define SPECIAL_ARROW_LEFT 75
#define SPECIAL_ARROW_RIGHT 77
#define SPECIAL_ARROW_DOWN 80
#define SPECIAL_DELETE 83
#define RIGHT_DOWN 218 // Box Drawing
#define LEFT_DOWN 191 // Box Drawing
#define RIGHT_UP 192 // Box Drawing
#define LEFT_UP 217 // Box Drawing
#define LEFT_RIGHT_DOWN 194 // Box Drawing
#define LEFT_RIGHT_UP 193 // Box Drawing
#define RIGHT_UP_DOWN 195 // Box Drawing
#define RIGHT_UP_DOWN 195 // Box Drawing
#define LEFT_RIGHT 196 // Box Drawing
#define INTERSECTION 197 // Box Drawing 
#define UP_DOWN 179 // Box Drawing
#define LEFT_UP_DOWN 180 // Box Drawing
#define DOUBLE_LEFT_RIGHT_UP_DOWN 216 // Box Drawing

// compatibility
#define POWERSHELL_SPECIAL 0
#define DOS_SPECIAL 224

// flags
#define FLAG_NONE 0
#define FLAG_SPECIAL 1

// Macros
#define PAUSE system("pause>nul|set/p =Press any key . . . ")

struct tableBuilder
{
    char ***matrix;
    size_t width;
    size_t height;

    int inputCount;
    int targetCount;
    int actualCount;
    int valueCount;

    int xCursor;
    int yCursor;
};

char *getstr(const char *prompt)
{
    char tmp[MAX_READ], *s = NULL;
    size_t n = 0, used = 0;
    
    if (prompt)
        fputs (prompt, stdout);
    
    while (1) { /* loop continually */
        if (!fgets (tmp, sizeof tmp, stdin))
            return s;
        tmp[(n = strcspn (tmp, "\n"))] = 0;
        if (!n)
            break;
        void *tmpptr = realloc (s, used + n + 1);
        if (!tmpptr) {
            perror ("realloc-getstr()");
            return s;
        }
        s = tmpptr;
        memcpy (s + used, tmp, n + 1); 
        used += n;
        if (n + 1 < sizeof tmp)
            break;
    }
    
    return s;
}

void clearscreen(void)
{
    HANDLE hConsole;
    COORD coord = {0, 0};
    CONSOLE_SCREEN_BUFFER_INFO csbi;
    DWORD dwConsoleSize, dwWriten;

    hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
    GetConsoleScreenBufferInfo(hConsole, &csbi);
    dwConsoleSize = csbi.dwSize.X * csbi.dwSize.Y;

    FillConsoleOutputCharacter(hConsole, (TCHAR)' ',
                               dwConsoleSize, coord, &dwWriten);
    FillConsoleOutputAttribute(hConsole, csbi.wAttributes,
                               dwConsoleSize, coord, &dwWriten);

    SetConsoleCursorPosition(hConsole, coord);
}

int resizeTable(struct tableBuilder *b, size_t width, size_t height)
{
    if (width >= b->width)
    {
        if (width != b->width)
        {
            b->matrix = realloc(b->matrix, sizeof(char **) * width);
        }
        for (size_t x = b->width; x < width; x++)
        {
            b->matrix[x] = malloc(sizeof(char *) * height);
            for (size_t y = 0; y < height; y++)
            {
                b->matrix[x][y] = NULL;
            }
        }
    }
    else
    {
        for (size_t x = width; x < b->width; x++)
        {
            for (size_t y = 0; y < b->height; y++)
            {
                free(b->matrix[x][y]);
                b->matrix[x][y] = NULL;
            }
            free(b->matrix[x]);
            b->matrix[x] = NULL;
        }
        b->matrix = realloc(b->matrix, sizeof(char **) * width);
    }
    
    if (height >= b->height)
    {
        if (height != b->height)
        {
            for (size_t x = 0; x < width; x++)
            {
                b->matrix[x] = realloc(b->matrix[x], sizeof(char *) * height);
                for (size_t y = b->height; y < height; y++)
                {
                    b->matrix[x][y] = NULL;
                }
            }
        }
    }
    else
    {
        for (size_t x = 0; x < width; x++)
        {
            for (size_t y = height; y < b->height; y++)
            {
                free(b->matrix[x][y]);
                b->matrix[x][y] = NULL;
            }
            b->matrix[x] = realloc(b->matrix[x], sizeof(char *) * height);
        }
    }
    
    b->width = width;
    b->height = height;

    if (b->inputCount + b->targetCount + b->actualCount < b->width)
    {
        b->actualCount = b->width - b->inputCount - b->targetCount;
    }
    else if (b->inputCount + b->targetCount + b->actualCount > b->width)
    {
        b->actualCount = 1;
        if (b->inputCount + b->targetCount + b->actualCount > b->width)
        {
            b->targetCount = 1;
            if (b->inputCount + b->targetCount + b->actualCount > b->width)
            {
                b->inputCount = 1; 
            }
        }
    }
}

int modifyTable(struct tableBuilder *b, int x, int y, char *entry)
{
    // validate input
    if (x < 0 || y < 0 || entry == NULL)
    {
        return TABL_FAILURE;
    }
    
    // expand table
    if (x >= b->width || y >= b->height)
    {
        resizeTable(b, x + 1, y + 1);
    }
    
    if ((b->matrix[x][y] = realloc(b->matrix[x][y], strlen(entry) + 1)) == NULL) return TABL_FAILURE;
    strcpy(b->matrix[x][y], entry);

    return TABL_SUCCESS;
}

struct tableBuilder initTableBuilder()
{
    struct tableBuilder b;

    b.xCursor = 0;
    b.yCursor = 0;
    b.inputCount = 1;
    b.targetCount = 1;
    b.actualCount = 1;
    b.valueCount = 1;
    b.width = b.inputCount + b.targetCount + b.actualCount;
    b.height = b.valueCount + 1;
    b.matrix = malloc(sizeof(char **) * b.width);
    for (size_t x = 0; x < b.width; x++)
    {
        b.matrix[x] = malloc(sizeof(char *) * b.height);
        for (size_t y = 0; y < b.height; y++)
        {
            b.matrix[x][y] = NULL;
        }
    }

    modifyTable(&b, 0, 0, "Title");
    modifyTable(&b, 1, 0, "Title");
    modifyTable(&b, 2, 0, "Title");
    modifyTable(&b, 0, 1, "Value");
    modifyTable(&b, 1, 1, "Value");
    modifyTable(&b, 2, 1, "Value");

    return b;
}

void renderTable(struct tableBuilder b)
{
    HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
    size_t *widthArray = calloc(b.width, sizeof(size_t));
    int highestWidth = 0;
    char *format = NULL;
    size_t length = 0;
    size_t total = 0;
    size_t x = 0;
    size_t y = 0;
    size_t i = 0;
    size_t inputWidth = 0;
    size_t targetWidth = 0;
    size_t actualWidth = 0;

    if (b.height < 2 || b.width < 3)
    {
        return;
    }

    for (x = 0; x < b.width; x++)
    {
        for (y = 0; y < b.height; y++)
        {
            length = b.matrix[x][y] != NULL ? strlen(b.matrix[x][y]) : strlen(UI_PLACEHOLDER);
            if (length > widthArray[x])
            {
                widthArray[x] = length;
            }
            if (length > highestWidth)
            {
                highestWidth = length;
            }
        }
        if (x < b.inputCount)
        {
            inputWidth += widthArray[x] + 3;
        }
        else if (x < b.inputCount + b.targetCount)
        {
            targetWidth += widthArray[x] + 3;
        }
        else
        {
            actualWidth += widthArray[x] + 3;
        }
    }
    inputWidth -= 1;
    targetWidth -= 1;
    actualWidth -= 1;

    if ((length = strlen(UI_TITLE_1) + 2) > inputWidth)
    {
        total = 0;
        for (i = 0; i < b.inputCount; i++)
        {
            total += 3 + (widthArray[i] = (widthArray[i] + 2.0f) / (inputWidth + 1) * (length + 1) - 2);
        }
        if (--total < length)
        {
            widthArray[i - 1] += length - total;
        }
        inputWidth = length;
    }
    if ((length = strlen(UI_TITLE_2) + 2) > targetWidth)
    {
        total = 0;
        for (i = b.inputCount; i < b.inputCount + b.targetCount; i++)
        {
            total += 3 + (widthArray[i] = (widthArray[i] + 2.0f) / (targetWidth + 1) * (length + 1) - 2);
        }
        if (--total < length)
        {
            widthArray[i - 1] += length - total;
        }
        targetWidth = length;
    }
    if ((length = strlen(UI_TITLE_3) + 2) > actualWidth)
    {
        total = 0;
        for (i = b.inputCount + b.targetCount; i < b.inputCount + b.targetCount + b.actualCount; i++)
        {
            total += 3 + (widthArray[i] = (widthArray[i] + 2.0f) / (actualWidth + 1) * (length + 1) - 2);
        }
        if (--total < length)
        {
            widthArray[i - 1] += length - total;
        }
        actualWidth = length;
    }

    putchar(RIGHT_DOWN);
    for (i = 0; i < inputWidth; i++)
    {
        putchar(LEFT_RIGHT);
    }
    putchar(LEFT_RIGHT_DOWN);
    for (i = 0; i < targetWidth; i++)
    {
        putchar(LEFT_RIGHT);
    }
    putchar(LEFT_RIGHT_DOWN);
    for (i = 0; i < actualWidth; i++)
    {
        putchar(LEFT_RIGHT);
    }
    putchar(LEFT_DOWN);
    putchar('\n');

    length = inputWidth + targetWidth + actualWidth + 14;
    if (length < highestWidth + 6)
    {
        length = highestWidth + 6;
    }
    format = malloc(length);

    snprintf(format, length, "%%c %%-%llus %%c %%-%llus %%c %%-%llus %%c\n", inputWidth - 2, targetWidth - 2, actualWidth - 2);
    printf(format, UP_DOWN, UI_TITLE_1, UP_DOWN, UI_TITLE_2, UP_DOWN, UI_TITLE_3, UP_DOWN);

    putchar(RIGHT_UP_DOWN);
    for (x = 0; x < b.width; x++)
    {
        for (size_t i = 0; i < widthArray[x] + 2; i++)
        {
            putchar(LEFT_RIGHT);
        }
        putchar(x == b.width - 1 ? LEFT_UP_DOWN : x == b.inputCount - 1 || x == b.inputCount + b.targetCount - 1 ? INTERSECTION : LEFT_RIGHT_DOWN);
    }
    putchar('\n');

    for (x = 0; x < b.width; x++)
    {
        sprintf(format, " %%-%llus ", widthArray[x]);
        putchar(UP_DOWN);
        if (x == b.xCursor && 0 == b.yCursor)
        {
            SetConsoleTextAttribute(hConsole, BACKGROUND_RED|BACKGROUND_GREEN|BACKGROUND_BLUE|BACKGROUND_INTENSITY);
            printf(format, b.matrix[x][0] != NULL ? b.matrix[x][0] : UI_PLACEHOLDER);
            SetConsoleTextAttribute(hConsole, FOREGROUND_RED|FOREGROUND_GREEN|FOREGROUND_BLUE);
        }
        else
        {
            printf(format, b.matrix[x][0] != NULL ? b.matrix[x][0] : UI_PLACEHOLDER);
        }
    }
    putchar(UP_DOWN);
    putchar('\n');

    putchar(RIGHT_UP_DOWN);
    for (x = 0; x < b.width; x++)
    {
        for (size_t i = 0; i < widthArray[x] + 2; i++)
        {
            putchar(LEFT_RIGHT);
        }
        putchar(x != b.width - 1 ? INTERSECTION : LEFT_UP_DOWN);
    }
    putchar('\n');

    for (y = 1; y < b.height; y++)
    {
        for (x = 0; x < b.width; x++)
        {
            sprintf(format, " %%-%llus ", widthArray[x]);
            putchar(UP_DOWN);
            if (x == b.xCursor && y == b.yCursor)
            {
                SetConsoleTextAttribute(hConsole, BACKGROUND_RED|BACKGROUND_GREEN|BACKGROUND_BLUE|BACKGROUND_INTENSITY);
                printf(format, b.matrix[x][y] != NULL ? b.matrix[x][y] : UI_PLACEHOLDER);
                SetConsoleTextAttribute(hConsole, FOREGROUND_RED|FOREGROUND_GREEN|FOREGROUND_BLUE);
            }
            else
            {
                printf(format, b.matrix[x][y] != NULL ? b.matrix[x][y] : UI_PLACEHOLDER);
            }
        }
        putchar(UP_DOWN);
        putchar('\n');
    }

    putchar(RIGHT_UP);
    for (x = 0; x < b.width; x++)
    {
        for (size_t i = 0; i < widthArray[x] + 2; i++)
        {
            putchar(LEFT_RIGHT);
        }
        putchar(x != b.width - 1 ? LEFT_RIGHT_UP : LEFT_UP);
    }
    putchar('\n');

    free(format);
    free(widthArray);
}

int moveCurser(struct tableBuilder *b, int direction)
{
    int status = TABL_FAILURE;

    switch (direction)
    {
        case CURSOR_UP:
            if (b->yCursor <= 0)
            {
                return status;
            }
            b->yCursor--;
            break;
        case CURSOR_DOWN:
            if (b->yCursor + 1 >= b->height)
            {
                resizeTable(b, b->width, b->height + 1);
            }
            b->yCursor++;
            break;
        case CURSOR_LEFT:
            if (b->xCursor <= 0)
            {
                return status;
            }
            b->xCursor--;
            break;
        case CURSOR_RIGHT:
            if (b->xCursor + 1 >= b->width)
            {
                resizeTable(b, b->width + 1, b->height);
            }
            b->xCursor++;
            break;
        default:
            return status;
    }
    status = TABL_SUCCESS;

    return status;
}

void uiDisplayHelp()
{
    clearscreen();
    printf(
        "ARROW KEYS:       Move the cursor.\n"
        "ENTER:            Edit the value of a cell.\n"
        "TAB:              Jump to the next cell.\n"
        "BACKSPACE/DELETE: Clear the current cell.\n"
        "CTRL-S:           Save and exit the table builder.\n"
        "CTRL-R:           Run your own program.\n"
        "CTRL-T:           Resize the table.\n"
        "?:                Display this help menu.\n"
        "\n"
    );
    PAUSE;
}

void uiResizeTable(struct tableBuilder *b, int *xCursor, int *yCursor)
{
    bool isInvalid = false;
    int choice = 0;
    size_t width = b->width;
    size_t height = b->height;

    do
    {
        printf(
            "1>  Width: %llu\n"
            "2>  Height: %llu\n"
            "3>  Amount of input variables: %d\n"
            "4>  Amount of target output variables: %d\n"
            "5>  Amount of actual output variables: %d\n"
            "6>  Exit Settings\n"
            "\n"
            "%s: ",
            b->width, b->height, b->inputCount, b->targetCount, b->actualCount, isInvalid ? "Invalid choice, enter new choice" : "Enter your choice"
        );
        fflush(stdin);
        scanf("%d", &choice);
        switch (choice)
        {
            case 1:
                printf("Enter new width: ");
                scanf("%llu", &width);
                while (width < 3)
                {
                    printf("Invalid width, please enter a width of 3 or more: ");
                    scanf("%llu", &width);
                }
                resizeTable(b, width, height);
                break;
            case 2:
                printf("Enter new height: ");
                scanf("%llu", &height);
                while (height < 2)
                {
                    printf("Invalid height, please enter a height of 2 or more: ");
                    scanf("%llu", &height);
                }
                resizeTable(b, width, height);
                break;
            case 3:
                printf("Amount of input variables: ");
                scanf("%d", &b->inputCount);
                while (b->inputCount < 1)
                {
                    printf("Invalid amount, please enter a number higher than 1: \n");
                    scanf("%d", &b->inputCount);
                }
                resizeTable(b, b->inputCount + b->targetCount + b->actualCount, b->height);
                break;
            case 4:
                printf("Amount of target output variables: ");
                scanf("%d", &b->targetCount);
                while (b->targetCount < 1)
                {
                    printf("Invalid amount, please enter a number higher than 1: \n");
                    scanf("%d", &b->targetCount);
                }
                resizeTable(b, b->inputCount + b->targetCount + b->actualCount, b->height);
                break;
            case 5:
                printf("Amount of actual output variables: ");
                scanf("%d", &b->actualCount);
                while (b->actualCount < 1)
                {
                    printf("Invalid amount, please enter a number higher than 1: \n");
                    scanf("%d", &b->actualCount);
                }
                resizeTable(b, b->inputCount + b->targetCount + b->actualCount, b->height);
                break;
            case 6:
                break;
            default:
                isInvalid = true;
                break;
        }
        clearscreen();
        renderTable(*b);
    } while (choice != 6);

    if ((*xCursor) >= width)
    {
        *xCursor = width - 1;
        b->xCursor = width - 1;
    }
    if ((*yCursor) >= height)
    {
        *yCursor = height - 1;
        b->yCursor = height - 1;
    }
}

void uiClearCell(struct tableBuilder *b, int x, int y)
{
    free(b->matrix[x][y]);
    b->matrix[x][y] = NULL;
}

void uiCallProgram(const char *exePath, bool runAsGdb)
{
    char cmd[FILENAME_MAX + 4] = "gdb ";

    if (!runAsGdb)
    {
        system(exePath);
        printf("\n");
        PAUSE;
    }
    else
    {
        strcat(cmd, exePath);
        system(cmd);
        printf("\n");
        PAUSE;
    }
}

void uiHandleTab(struct tableBuilder *b, int *xCursor, int *yCursor)
{
    if (b->width - 1 == *xCursor)
    {
        *xCursor = 0;
        b->xCursor = 0;
        if (moveCurser(b, CURSOR_DOWN)) (*yCursor)++;
    }
    else
    {
        if (moveCurser(b, CURSOR_RIGHT)) (*xCursor)++;
    }
}

void uiPromptInput(struct tableBuilder *b, int x, int y)
{
    char *input = getstr("Enter value: ");
    modifyTable(b, x, y, input);
    free(input);
}

struct table convertToTable(struct tableBuilder b)
{
    struct table t;
    size_t i, j;

    t.inputCount = b.inputCount;
    t.inputVars = malloc(sizeof(char *) * t.inputCount);
    t.inputValCount = b.height - 1;
    t.inputValues = malloc(sizeof(char **) * t.inputValCount);
    for (i = 0; i < t.inputCount; i++)
    {
        if (b.matrix[i][0] == NULL)
        {
            t.inputVars[i] = malloc(2);
            strcpy(t.inputVars[i], "");
        }
        else
        {
            t.inputVars[i] = malloc(strlen(b.matrix[i][0]) + 1);
            strcpy(t.inputVars[i], b.matrix[i][0]);
        }
        t.inputValues[i] = malloc(sizeof(char *) * t.inputValCount);
        for (j = 0; j < t.inputValCount; j++)
        {
            if (b.matrix[i][j + 1] == NULL)
            {
                t.inputValues[i][j] = malloc(2);
                strcpy(t.inputValues[i][j], "");
            }
            else
            {
                t.inputValues[i][j] = malloc(strlen(b.matrix[i][j + 1]) + 1);
                strcpy(t.inputValues[i][j], b.matrix[i][j + 1]);
            }
        }
    }

    t.targetCount = b.targetCount;
    t.targetVars = malloc(sizeof(char *) * t.targetCount);
    t.targetValCount = b.height - 1;
    t.targetValues = malloc(sizeof(char **) * t.targetValCount);
    for (i = 0; i < t.targetCount; i++)
    {
        if (b.matrix[i + t.inputCount][0] == NULL)
        {
            t.targetVars[i] = malloc(2);
            strcpy(t.targetVars[i], "");
        }
        else
        {
            t.targetVars[i] = malloc(strlen(b.matrix[i + t.inputCount][0]) + 1);
            strcpy(t.targetVars[i], b.matrix[i + t.inputCount][0]);
        }
        t.targetValues[i] = malloc(sizeof(char *) * t.targetValCount);
        for (j = 0; j < t.targetValCount; j++)
        {
            if (b.matrix[i + t.inputCount][j + 1] == NULL)
            {
                t.targetValues[i][j] = malloc(2);
                strcpy(t.targetValues[i][j], "");
            }
            else
            {
                t.targetValues[i][j] = malloc(strlen(b.matrix[i + t.inputCount][j + 1]) + 1);
                strcpy(t.targetValues[i][j], b.matrix[i + t.inputCount][j + 1]);
            }
        }
    }

    t.actualCount = b.actualCount;
    t.actualVars = malloc(sizeof(char *) * t.actualCount);
    t.actualValCount = b.height - 1;
    t.actualValues = malloc(sizeof(char **) * t.actualValCount);
    for (i = 0; i < b.actualCount; i++)
    {
        if (b.matrix[i + t.inputCount + t.targetCount][0] == NULL)
        {
            t.actualVars[i] = malloc(2);
            strcpy(t.actualVars[i], "");
        }
        else
        {
            t.actualVars[i] = malloc(strlen(b.matrix[i + t.inputCount + t.targetCount][0]) + 1);
            strcpy(t.actualVars[i], b.matrix[i + t.inputCount + t.targetCount][0]);
        }
        t.actualValues[i] = malloc(sizeof(char *) * t.actualValCount);
        for (j = 0; j < t.actualValCount; j++)
        {
            if (b.matrix[i + t.inputCount + t.targetCount][j + 1] == NULL)
            {
                t.actualValues[i][j] = malloc(2);
                strcpy(t.actualValues[i][j], "");
            }
            else
            {
                t.actualValues[i][j] = malloc(strlen(b.matrix[i + t.inputCount + t.targetCount][j + 1]) + 1);
                strcpy(t.actualValues[i][j], b.matrix[i + t.inputCount + t.targetCount][j + 1]);
            }
        }
    }

    return t;
}

void cleanupTableBuilder(struct tableBuilder b)
{
    for (size_t x = 0; x < b.width; x++)
    {
        for (size_t y = 0; y < b.height; y++)
        {
            if (b.matrix[x][y] != NULL)
            {
                free(b.matrix[x][y]);
            }
        }
        free(b.matrix[x]);
    }
    free(b.matrix);
}

struct table buildTable(const char *pathToExe)
{
    struct tableBuilder builder = initTableBuilder();
    struct table table;
    bool done = false;
    int sign = 0;
    int state = FLAG_NONE;
    int xCursor = 0;
    int yCursor = 0;

    while (!done)
    {
        // render
        clearscreen();
        renderTable(builder);

        // input
        fflush(stdin);
        sign = getch();

        switch (state)
        {
            case FLAG_NONE:
                switch (sign)
                {
                    case DOS_SPECIAL:
                    case POWERSHELL_SPECIAL:
                        state = FLAG_SPECIAL;
                        break;
                    case HELP:
                        uiDisplayHelp();
                        break;
                    case START:
                        uiCallProgram(pathToExe, false);
                        break;
                    case DONE:
                        done = true;
                        break;
                    case RESIZE:
                        uiResizeTable(&builder, &xCursor, &yCursor);
                        break;
                    case BACKSPACE:
                        uiClearCell(&builder, xCursor, yCursor);
                        break;
                    case ENTER:
                        uiPromptInput(&builder, xCursor, yCursor);
                        break;
                    case TAB:
                        uiHandleTab(&builder, &xCursor, &yCursor);
                        break;
                    default:
                        break;
                }
                break;
            case FLAG_SPECIAL:
                switch (sign)
                {
                    case SPECIAL_ARROW_UP:
                        if (moveCurser(&builder, CURSOR_UP)) yCursor--;
                        break;
                    case SPECIAL_ARROW_DOWN:
                        if (moveCurser(&builder, CURSOR_DOWN)) yCursor++;
                        break;
                    case SPECIAL_ARROW_LEFT:
                        if (moveCurser(&builder, CURSOR_LEFT)) xCursor--;
                        break;
                    case SPECIAL_ARROW_RIGHT:
                        if (moveCurser(&builder, CURSOR_RIGHT)) xCursor++;
                        break;
                    case SPECIAL_DELETE:
                        uiClearCell(&builder, xCursor, yCursor);
                        break;
                }
                state = FLAG_NONE;
                break;
        }
    }

    table = convertToTable(builder);
    cleanupTableBuilder(builder);

    return table;
}

int main(int argc, char const *argv[])
{
    struct Traverser traveler = initTraverser(argv[0]);
    struct table table;

    table = buildTable(getFileTraverser(&traveler, NULL, "outputer" DIR_DELIMITER "program.exe"));
    stopTraverser(&traveler);

    return 0;
}

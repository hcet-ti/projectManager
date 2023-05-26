#include <time.h>
#include <math.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include <process.h>
#include "PDFGen-0.1.0/pdfgen.h"
#include "pathTraverser.h"
#include "tableBuilder.h"

#define VERSION "0.1.2"

#if defined(_WIN32) || defined(WIN32)
#define PAUSE system("pause>nul|set/p =Press any key . . . ")
#include <windows.h>
bool spillDirectory(const char *sDir)
{
    WIN32_FIND_DATA fdFile;
    HANDLE hFind = NULL;

    char sPath[2048];
    int i = -2;

    //Specify a file mask. *.* = We want everything!
    sprintf(sPath, "%s\\*.*", sDir);

    if((hFind = FindFirstFile(sPath, &fdFile)) == INVALID_HANDLE_VALUE)
    {
        printf("Path not found: [%s]\n", sDir);
        return false;
    }

    do
    {
        ++i;
        //Find first file will always return "."
        //    and ".." as the first two directories.
        if(strcmp(fdFile.cFileName, ".") != 0
                && strcmp(fdFile.cFileName, "..") != 0)
        {
            //Build up our file path using the passed in
            //  [sDir] and the file/foldername we just found:
            sprintf(sPath, "%s\\%s", sDir, fdFile.cFileName);

            //Is the entity a File or Folder?
            if(fdFile.dwFileAttributes &FILE_ATTRIBUTE_DIRECTORY)
            {
                // This will cause problems with counting "i"
                //spillDirectory(sPath); //Recursion, I love it!
            }
            else
            {
                printf("%4d> %s\n", i, sPath);
            }
        }
    }
    while(FindNextFile(hFind, &fdFile)); //Find the next file.

    FindClose(hFind); //Always, Always, clean things up!

    return true;
}

bool getFile(const char *sDir, int index, char *dest)
{
    WIN32_FIND_DATA fdFile;
    HANDLE hFind = NULL;

    char sPath[2048];
    int i = -2;

    //Specify a file mask. *.* = We want everything!
    sprintf(sPath, "%s\\*.*", sDir);

    if((hFind = FindFirstFile(sPath, &fdFile)) == INVALID_HANDLE_VALUE)
    {
        printf("Path not found: [%s]\n", sDir);
        return false;
    }

    do
    {
        ++i;
        //Find first file will always return "."
        //    and ".." as the first two directories.
        if(strcmp(fdFile.cFileName, ".") != 0
                && strcmp(fdFile.cFileName, "..") != 0)
        {
            //Build up our file path using the passed in
            //  [sDir] and the file/foldername we just found:
            sprintf(sPath, "%s\\%s", sDir, fdFile.cFileName);

            //Is the entity a File or Folder?
            if(fdFile.dwFileAttributes &FILE_ATTRIBUTE_DIRECTORY)
            {
                // This will cause problems with counting "i"
                //return getFile(sPath, index, dest); //Recursion, I love it!
            }
            else
            {
                if (index == i)
                {
                    strcpy(dest, sPath);
                    return true;
                }
            }
        }
    }
    while(FindNextFile(hFind, &fdFile)); //Find the next file.

    FindClose(hFind); //Always, Always, clean things up!

    return false;
}

BOOL directoryExists(LPCTSTR szPath)
{
  DWORD dwAttrib = GetFileAttributes(szPath);

  return (dwAttrib != INVALID_FILE_ATTRIBUTES && 
         (dwAttrib & FILE_ATTRIBUTE_DIRECTORY));
}

char *getFullPath(const char *path)
{
    char *fullFilename = malloc(MAX_PATH);

    GetFullPathName(path, MAX_PATH, fullFilename, NULL);

    return fullFilename;
}

struct Settings
{
    char *firstName;
    char *familyName;
    char *schoolClass;
    int posGroup;
    bool askForDate; // false -> use today | true -> let user decide
    char *outputFolder;
    char *palettePath;
    int structogramProcurement;
};
#endif

bool exists(const char *fname)
{
    FILE *file;
    if ((file = fopen(fname, "r")))
    {
        fclose(file);
        return true;
    }
    return false;
}

void saveSettings(const char *path, struct Settings config)
{
    FILE *fp = NULL;

    if ((fp = fopen(path, "w")) == NULL)
    {
        printf("A problem occurred during the saving process, aborting...");
        system("pause>nul|set/p = ");
        exit(EXIT_FAILURE);
    }
    
    fprintf(fp, 
        "%s\n" // first name
        "%s\n" // family name
        "%s\n" // school class
        "%d\n" // POS group
        "%d\n" // ask for date?
        "%s\n" // output folder
        "%s\n" // theme / palette
        "%d\n" // structogram
        "\nAutomatically generated file.\n", // meta-data
        config.firstName, 
        config.familyName, 
        config.schoolClass, 
        config.posGroup, 
        config.askForDate, 
        config.outputFolder, 
        config.palettePath,
        config.structogramProcurement
    );

    fclose(fp);
}

struct Settings loadSettings(struct Traverser *traveler)
{
    FILE *fp = NULL;
    char *tmp = NULL;
    struct Settings config;

    // open
    if ((fp = fopen(getFileTraverser(traveler, NULL, "settings.cfg"), "r")) == NULL) { goto failSafe; }
    
    // first name
    if ((config.firstName = fgetstr(fp)) == NULL) { goto failSafe; }
    
    // family name
    if ((config.familyName = fgetstr(fp)) == NULL) { goto failSafe; }
    
    // school class
    if ((config.schoolClass = fgetstr(fp)) == NULL) { goto failSafe; }
    
    // POS group
    if ((tmp = fgetstr(fp)) == NULL) { goto failSafe; }
    config.posGroup = atoi(tmp);
    free(tmp);
    
    // ask for date?
    if ((tmp = fgetstr(fp)) == NULL) { goto failSafe; }
    config.askForDate = atoi(tmp);
    free(tmp);
    
    // output folder
    if ((config.outputFolder = fgetstr(fp)) == NULL) { goto failSafe; }
    
    // theme / palette
    if ((config.palettePath = fgetstr(fp)) == NULL) { goto failSafe; }
    
    // structogram
    if ((tmp = fgetstr(fp)) == NULL) { goto failSafe; }
    config.structogramProcurement = atoi(tmp);
    free(tmp);

    // do some checks
    if (!directoryExists(config.outputFolder)) { goto failSafe; }
    if (!exists(config.palettePath)) { goto failSafe; }

    return config;
    
failSafe:
    config.firstName = malloc(2);
    strcpy(config.firstName, "");
    config.familyName = malloc(2);
    strcpy(config.familyName, "");
    config.schoolClass = malloc(2);
    strcpy(config.schoolClass, "");
    config.posGroup = -1;
    config.askForDate = true;
    config.outputFolder = getFileTraverser(traveler, NULL, "");
    config.palettePath = getFileTraverser(traveler, NULL, "themes" DIR_DELIMITER "vscode-light.pmt");
    config.structogramProcurement = 1;

    return config;
}

void save(const char *path, struct theme data)
{
    FILE *fp = NULL;
    if ((fp = fopen(path, "w")) == NULL)
    {
        printf("Couldn't open the save file.\n");
        system("pause>nul|set/p = ");
        exit(EXIT_FAILURE);
    }

    fprintf(fp, "%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n\nAutomatically generated file.\n", 
    data.preproc, data.types, data.keywords, data.number, 
    data.string, data.comment, data.function, data.symbol);

    fclose(fp);
}

struct theme load(const char *path)
{
    FILE *fp = NULL;
    char buff[255] = "";
    struct theme data;

    // open
    if ((fp = fopen(path, "r")) == NULL)
    {
        printf("Couldn't open the load file.\n");
        system("pause>nul|set/p = ");
        exit(EXIT_FAILURE);
    }

    // preproc
    if ((fgets(buff, 255, fp) == NULL))
    {
        printf("No member \"preprocessing\" was found.\n");
        system("pause>nul|set/p = ");
        exit(EXIT_FAILURE);
    }
    data.preproc = (uint32_t)atoi(buff);

    // types
    if ((fgets(buff, 255, fp) == NULL))
    {
        printf("No member \"types\" was found.\n");
        system("pause>nul|set/p = ");
        exit(EXIT_FAILURE);
    }
    data.types = (uint32_t)atoi(buff);

    // keywords
    if ((fgets(buff, 255, fp) == NULL))
    {
        printf("No member \"keywords\" was found.\n");
        system("pause>nul|set/p = ");
        exit(EXIT_FAILURE);
    }
    data.keywords = (uint32_t)atoi(buff);

    // number
    if ((fgets(buff, 255, fp) == NULL))
    {
        printf("No member \"number\" was found.\n");
        system("pause>nul|set/p = ");
        exit(EXIT_FAILURE);
    }
    data.number = (uint32_t)atoi(buff);

    // string
    if ((fgets(buff, 255, fp) == NULL))
    {
        printf("No member \"string\" was found.\n");
        system("pause>nul|set/p = ");
        exit(EXIT_FAILURE);
    }
    data.string = (uint32_t)atoi(buff);

    // comment
    if ((fgets(buff, 255, fp) == NULL))
    {
        printf("No member \"comment\" was found.\n");
        system("pause>nul|set/p = ");
        exit(EXIT_FAILURE);
    }
    data.comment = (uint32_t)atoi(buff);

    // function
    if ((fgets(buff, 255, fp) == NULL))
    {
        printf("No member \"function\" was found.\n");
        system("pause>nul|set/p = ");
        exit(EXIT_FAILURE);
    }
    data.function = (uint32_t)atoi(buff);

    // symbol
    if ((fgets(buff, 255, fp) == NULL))
    {
        printf("No member \"symbol\" was found.\n");
        system("pause>nul|set/p = ");
        exit(EXIT_FAILURE);
    }
    data.symbol = (uint32_t)atoi(buff);

    fclose(fp);

    return data;
}

char *toLowercase(char *upper) {
    int len = strlen(upper);

    // Allocate space for new string
    char *lower = (char *) malloc(sizeof(char) * (len + 1));

    // Add null terminator to string
    lower[len] = '\0';

    // Convert characters to lowercase one by one
    for (int i = 0; i < len; i++) {
        lower[i] = tolower(upper[i]);
    }

    return lower;
}

char *toUppercase(char *lower) {
    int len = strlen(lower);

    // Allocate space for new string
    char *upper = (char *) malloc(sizeof(char) * (len + 1));

    // Add null terminator to string
    upper[len] = '\0';

    // Convert characters to uppercase one by one
    for (int i = 0; i < len; i++) {
        upper[i] = toupper(lower[i]);
    }

    return upper;
}

void powerOnSelfCheck(struct Traverser *traveler)
{
    char *errorMsg = NULL;
    char cmd[2 * _MAX_PATH + 19] = "";
    char *log = getFileTraverser(traveler, NULL, "logs" DIR_DELIMITER "log.log");
    char *structorizer = getFileTraverser(traveler, NULL, "Structorizer.Desktop" DIR_DELIMITER "Structorizer.bat");
    HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);

    // GCC
    sprintf(cmd, "gcc -v >> \"%s\" 2>&1", log);
    if (system(cmd) != 0)
    {
        printf("[");
        SetConsoleTextAttribute(hConsole, FOREGROUND_RED|FOREGROUND_INTENSITY);
        printf("ERROR");
        SetConsoleTextAttribute(hConsole, FOREGROUND_RED|FOREGROUND_GREEN|FOREGROUND_BLUE);
        printf("] GCC could not be found.\n");
    }
    else
    {
        printf("[");
        SetConsoleTextAttribute(hConsole, FOREGROUND_GREEN|FOREGROUND_INTENSITY);
        printf("OK");
        SetConsoleTextAttribute(hConsole, FOREGROUND_RED|FOREGROUND_GREEN|FOREGROUND_BLUE);
        printf("] GCC exists.\n");
    }

    // Java
    sprintf(cmd, "\"\"%s\" -h >> \"%s\" 2>&1\"", structorizer, log);
    if (system(cmd) != 0)
    {
        printf("[");
        SetConsoleTextAttribute(hConsole, FOREGROUND_RED|FOREGROUND_GREEN|FOREGROUND_INTENSITY);
        printf("WARNING");
        SetConsoleTextAttribute(hConsole, FOREGROUND_RED|FOREGROUND_GREEN|FOREGROUND_BLUE);
        printf("] There is a problem with Java or the Structorizer.\n");
    }
    else
    {
        printf("[");
        SetConsoleTextAttribute(hConsole, FOREGROUND_GREEN|FOREGROUND_INTENSITY);
        printf("OK");
        SetConsoleTextAttribute(hConsole, FOREGROUND_RED|FOREGROUND_GREEN|FOREGROUND_BLUE);
        printf("] Java version is good.\n");
    }

    // ImageMagick
    if (errorMsg = checkForMagick(getFileTraverser(traveler, NULL, "wizard.jpg")))
    {
        printf("[");
        SetConsoleTextAttribute(hConsole, FOREGROUND_RED|FOREGROUND_INTENSITY);
        printf("ERROR");
        SetConsoleTextAttribute(hConsole, FOREGROUND_RED|FOREGROUND_GREEN|FOREGROUND_BLUE);
        printf("] ImageMagick cannot be initilized. Original error message: %s\n", errorMsg);
        releaseErrorMsgMagick(errorMsg);
    }
    else
    {
        printf("[");
        SetConsoleTextAttribute(hConsole, FOREGROUND_GREEN|FOREGROUND_INTENSITY);
        printf("OK");
        SetConsoleTextAttribute(hConsole, FOREGROUND_RED|FOREGROUND_GREEN|FOREGROUND_BLUE);
        printf("] ImageMagick is working.\n");
    }
    
    putchar('\n');
}

void generate(const char *header1, const char *header2, const char *footer1, const char *footer2, char *imgPath, const char *codePath, struct Traverser *traveler, const char *outputFolder, const char *outputName, const char *palettePath, const char *structImgPath)
{
    int pageCounter = 0;
    float imageHeight = 0.0f;
    float textWidth = 0.0f;
    float cursorY = 0.0f;
    size_t width = 0;
    size_t height = 0;
    struct table table;
    char *compiler = NULL;
    char save[FILENAME_MAX] = "";
    struct theme palette = load(palettePath);
    struct pdf_info info = {
        .creator = "Maxims POS project manager",
        .producer = "Maxims POS project manager",
        .title = "",
        .author = "",
        .subject = "POS Homework",
        .date = ""
    };
    strcpy(info.title, header1);
    strcpy(info.author, outputName);
    struct pdf_doc *pdf = pdf_create(PDF_A4_WIDTH, PDF_A4_HEIGHT, &info);
    pdf_append_labeled_page(pdf, header1, header2, footer1, footer2, &pageCounter);
    cursorY = pdf_top(pdf, cursorY);

    // Task title
    pdf_move_cursor(pdf, &cursorY, 14, cm2pt(2.5), &pageCounter, header1, header2, footer1, footer2);
    pdf_set_font(pdf, "Helvetica-Bold");
    pdf_add_text(pdf, NULL, "Task:", 14, cm2pt(2.5), cursorY, PDF_BLACK);

    // Task underline
    pdf_move_cursor(pdf, &cursorY, 0, cm2pt(0.1), &pageCounter, header1, header2, footer1, footer2);
    pdf_get_font_text_width(pdf, "Helvetica-Bold", "Task:", 14, &textWidth);
    pdf_add_line(pdf, NULL, cm2pt(2.5), cursorY, textWidth + cm2pt(2.5), cursorY, 1, PDF_BLACK);

    // Task image
    imgPath = img_strip_alpha(imgPath, getFileTraverser(traveler, NULL, "outputer" DIR_DELIMITER "img" DIR_DELIMITER "task.jpg"));
    img_get_size(imgPath, &width, &height);
    imageHeight = cm2pt(16) * ((float) height / width);
    pdf_move_cursor(pdf, &cursorY, imageHeight, cm2pt(0.25), &pageCounter, header1, header2, footer1, footer2);
    if (pdf_add_image_file(pdf, NULL, cm2pt(2.5), cursorY, cm2pt(16), imageHeight, imgPath) < 0)
    {
        printf("Warning: there was a problem adding the exercise image. Please note that transparent PNGs are not supported.\n");
        system("pause>nul|set/p =Press any key . . . ");
    }

    // Code title
    pdf_move_cursor(pdf, &cursorY, 14, cm2pt(0.5), &pageCounter, header1, header2, footer1, footer2);
    pdf_add_text(pdf, NULL, "Code:", 14, cm2pt(2.5), cursorY, PDF_BLACK);

    // Code underline
    pdf_move_cursor(pdf, &cursorY, 0, cm2pt(0.1), &pageCounter, header1, header2, footer1, footer2);
    pdf_get_font_text_width(pdf, "Helvetica-Bold", "Code:", 14, &textWidth);
    pdf_add_line(pdf, NULL, cm2pt(2.5), cursorY, textWidth + cm2pt(2.5), cursorY, 1, PDF_BLACK);

    // Code
    pdf_move_cursor(pdf, &cursorY, 0, cm2pt(0.75), &pageCounter, header1, header2, footer1, footer2);
    pdf_add_code(pdf, codePath, 10.5, cm2pt(2.5), cursorY, header1, header2, footer1, footer2, &pageCounter, &cursorY, palette);

    // Screenshot title
    pdf_move_cursor(pdf, &cursorY, 14, cm2pt(0.5), &pageCounter, header1, header2, footer1, footer2);
    pdf_set_font(pdf, "Helvetica-Bold");
    pdf_add_text(pdf, NULL, "Screenshot:", 14, cm2pt(2.5), cursorY, PDF_BLACK);

    // Screenshot underline
    pdf_move_cursor(pdf, &cursorY, 0, cm2pt(0.1), &pageCounter, header1, header2, footer1, footer2);
    pdf_get_font_text_width(pdf, "Helvetica-Bold", "Screenshot:", 14, &textWidth);
    pdf_add_line(pdf, NULL, cm2pt(2.5), cursorY, textWidth + cm2pt(2.5), cursorY, 1, PDF_BLACK);

    // Screenshot
    /* compiler = findCompiler(thisFile); */
    compiler = getFileTraverser(traveler, NULL, "outputer" DIR_DELIMITER "compiler.exe");
    pdf_move_cursor(pdf, &cursorY, 0, cm2pt(0.25), &pageCounter, header1, header2, footer1, footer2);
    pdf_add_exe(pdf, codePath, compiler, getFileTraverser(traveler, NULL, "logs" DIR_DELIMITER "log.log"), cm2pt(2.5), &cursorY, header1, header2, footer1, footer2, &pageCounter);
    /* free(compiler); */

    // Test data title
    pdf_move_cursor(pdf, &cursorY, 14, cm2pt(0.1), &pageCounter, header1, header2, footer1, footer2);
    pdf_add_text(pdf, NULL, "Test data:", 14, cm2pt(2.5), cursorY, PDF_BLACK);

    // Test data underline
    pdf_move_cursor(pdf, &cursorY, 0, cm2pt(0.1), &pageCounter, header1, header2, footer1, footer2);
    pdf_get_font_text_width(pdf, "Helvetica-Bold", "Test data:", 14, &textWidth);
    pdf_add_line(pdf, NULL, cm2pt(2.5), cursorY, textWidth + cm2pt(2.5), cursorY, 1, PDF_BLACK);

    // Test data table
    table = buildTable(getFileTraverser(traveler, NULL, "outputer" DIR_DELIMITER "program.exe"));
    pdf_move_cursor(pdf, &cursorY, 0, cm2pt(0.25), &pageCounter, header1, header2, footer1, footer2);
    pdf_add_table(pdf, table, cm2pt(0.1), cm2pt(0.1), cm2pt(2.5), &cursorY, header1, header2, footer1, footer2, &pageCounter, 11, 0.5f);
    cleanupTable(table);

    // Structogram title
    pdf_set_font(pdf, "Helvetica-Bold");
    pdf_move_cursor(pdf, &cursorY, 14, cm2pt(0.5), &pageCounter, header1, header2, footer1, footer2);
    pdf_add_text(pdf, NULL, "Structogram:", 14, cm2pt(2.5), cursorY, PDF_BLACK);

    // Structogram underline
    pdf_move_cursor(pdf, &cursorY, 0, cm2pt(0.1), &pageCounter, header1, header2, footer1, footer2);
    pdf_get_font_text_width(pdf, "Helvetica-Bold", "Structogram:", 14, &textWidth);
    pdf_add_line(pdf, NULL, cm2pt(2.5), cursorY, textWidth + cm2pt(2.5), cursorY, 1, PDF_BLACK);

    // Structogram
    if (structImgPath != NULL)
    {
        pdf_move_cursor(pdf, &cursorY, 0, cm2pt(0.25), &pageCounter, header1, header2, footer1, footer2);
        pdf_add_structogram_by_path(pdf, structImgPath, cm2pt(2.5), &cursorY, header1, header2, footer1, footer2, &pageCounter, getFileTraverser(traveler, NULL, "outputer" DIR_DELIMITER "structorizer" DIR_DELIMITER "struct.jpg"));
    }
    else
    {
        pdf_move_cursor(pdf, &cursorY, 0, cm2pt(0.25), &pageCounter, header1, header2, footer1, footer2);
        pdf_structorize(pdf, getFileTraverser(traveler, NULL, "Structorizer.Desktop" DIR_DELIMITER "Structorizer.bat"), getFileTraverser(traveler, NULL, "outputer" DIR_DELIMITER "structorizer"), codePath, getFileTraverser(traveler, NULL, "logs" DIR_DELIMITER "log.log"), getFileTraverser(traveler, NULL, "Structorizer.Desktop"), cm2pt(2.5), &cursorY, header1, header2, footer1, footer2, &pageCounter);
    }

    // Page counter
    pdf_add_page_count(pdf, &pageCounter);

    // save
    snprintf(save, FILENAME_MAX, "%s.pdf", outputName);
    pdf_save(pdf, getFileTraverser(traveler, outputFolder, save));
    printf("Success! PDF is located at: %s\n", getFileTraverser(traveler, outputFolder, save));
    
    // free memory
    pdf_destroy(pdf);
    
    PAUSE;
}

uint32_t askForRGB()
{
    unsigned char red = 0;
    unsigned char green = 0;
    unsigned char blue = 0;

    printf("Red value: ");
    scanf("%hhu", &red);
    printf("Green value: ");
    scanf("%hhu", &green);
    printf("Blue value: ");
    scanf("%hhu", &blue);

    return (((red)&0xff) << 16) | (((green)&0xff) << 8) | (((blue)&0xff));
}

struct theme themeCreator(char **name)
{
    struct theme palette;

    printf("What's the name of the new theme? (Use '-' as a replacement for spaces)\n");
    if ((*name = getstr("Name: ")) == NULL)
    {
        *name = malloc(2);
        strcpy(*name, "");
    }
    printf("Input the RBG value for the preprocessing commands.\n");
    palette.preproc = askForRGB();
    printf("Input the RBG value for the types.\n");
    palette.types = askForRGB();
    printf("Input the RBG value for the keywords.\n");
    palette.keywords = askForRGB();
    printf("Input the RBG value for the numbers.\n");
    palette.number = askForRGB();
    printf("Input the RBG value for the strings.\n");
    palette.string = askForRGB();
    printf("Input the RBG value for the comments.\n");
    palette.comment = askForRGB();
    printf("Input the RBG value for the functions.\n");
    palette.function = askForRGB();
    printf("Input the RBG value for the symbol.\n");
    palette.symbol = askForRGB();

    return palette;
}

void selectTheme(const char *themeFolder, char *dest)
{
    int choice = -1;
    char *name;
    char path[MAX_PATH] = "";
    struct theme palette;

    printf("Select the theme: \n");
    printf("   0> Create your own theme\n");
    spillDirectory(themeFolder);
    
    while (true)
    {
        printf("Theme: ");
        scanf("%d", &choice);
        if (choice == 0)
        {
            palette = themeCreator(&name);
            strcpy(path, themeFolder);
            strcat(path, DIR_DELIMITER);
            strcat(path, name);
            free(name);
            strcat(path, ".pmt");
            save(path, palette);
            return selectTheme(themeFolder, dest);
        }
        else if (getFile(themeFolder, choice, dest) == true)
        {
            break;
        }
        else
        {
            printf("Invalid choice.\n");
        }
    }
}

void selectExercise(const char *imgFolder, char *dest)
{
    int choice = -1;

    printf("Select the exercise's image: \n");
    spillDirectory(imgFolder);
    
    while (true)
    {
        printf("Image: ");
        scanf("%d", &choice);
        if (getFile(imgFolder, choice, dest) == true)
        {
            break;
        }
        else
        {
            printf("Invalid choice.\n");
        }
        
    }

}

void settings(struct Traverser *traveler, struct Settings *config)
{
    int choice = -1;
    char posGroup[255] = "";
    char buff[255] = "";
    char *configPath = getFileTraverser(traveler, NULL, "settings.cfg");
    char *themesPath = getFileTraverser(traveler, NULL, "themes");

    while (true)
    {
        snprintf(posGroup, 255, "%d", config->posGroup);

        clearscreen();

        printf("1> First Name  : %s\n", strlen(config->firstName) <= 0 ? "<Ask the User>" : config->firstName);
        printf("2> Family Name : %s\n", strlen(config->familyName) <= 0 ? "<Ask the User>" : config->familyName);
        printf("3> Class       : %s\n", strlen(config->schoolClass) <= 0 ? "<Ask the User>" : config->schoolClass);
        printf("4> POS Group   : %s\n", config->posGroup <= 0 ? "<Ask the User>" : posGroup);
        printf("5> Auto Date   : %s\n", config->askForDate ? "off" : "on");
        printf("6> Output      : %s\n", config->outputFolder);
        printf("7> Theme       : %s\n", config->palettePath);
        printf("8> Structogram : %s\n", config->structogramProcurement == 1 ? "<Ask for Image>" : "<Auto generate>");
        printf("9> Save & Exit\n");
        
        printf("\nType your choice: ");
        scanf("%d", &choice);

        switch (choice)
        {
        case 1:
            // first name
            if (config->firstName != NULL)
                free(config->firstName);
            fflush(stdin);
            if ((config->firstName = getstr("First Name: ")) == NULL)
            {
                config->firstName = malloc(2);
                strcpy(config->firstName, "");
            }
            break;
        
        case 2:
            // family name
            if (config->familyName != NULL)
                free(config->familyName);
            fflush(stdin);
            if ((config->familyName = getstr("Family Name: ")) == NULL)
            {
                config->familyName = malloc(2);
                strcpy(config->familyName, "");
            }
            break;
        
        case 3:
            // class
            if (config->schoolClass != NULL)
                free(config->schoolClass);
            fflush(stdin);
            if ((config->schoolClass = getstr("Class: ")) == NULL)
            {
                config->schoolClass = malloc(2);
                strcpy(config->schoolClass, "");
            }
            break;
        
        case 4:
            // pos group
            printf("POS Group (number): ");
            scanf("%d", &config->posGroup);
            break;
        
        case 5:
            // auto date
            printf("Auto Date (y/N): ");
            scanf("%s", buff);
            config->askForDate = buff[0] == 'y' || buff[0] == 'Y' ? false : true;
            break;
        
        case 6:
            // output
            if (config->outputFolder != NULL)
                free(config->outputFolder);
            fflush(stdin);
            if ((config->outputFolder = getstr("Output Folder: ")) == NULL)
            {
                config->outputFolder = malloc(2);
                strcpy(config->outputFolder, "");
            }
            break;
        
        case 7:
            // theme
            config->palettePath = realloc(config->palettePath, _MAX_PATH);
            selectTheme(themesPath, config->palettePath);
            break;
        
        case 8:
            // structogram
            printf("1> Ask for a path leading to the picture to be used as the structogram\n");
            printf("2> Automatically parse the code with structurizer (Only works with ANSI-C99 compliant code)\n");
            printf("Enter your choice: ");
            scanf("%d", &config->structogramProcurement);
            while (config->structogramProcurement < 1 || config->structogramProcurement > 2)
            {
                printf("Please enter a valid choice: ");
                scanf("%d", &config->structogramProcurement);
            }
            break;
        
        case 9:
            // save & exit
            saveSettings(configPath, *config);
            return;
        
        default:
            break;
        }
    }
}

void version()
{
    printf("POS project manager [Version %s]: a small program to more easily document small c programs as PDF files.\n", VERSION);
    printf("Copyright (C) 2023 Maxim Garber\n");
    printf("\n");
}

void license(struct Traverser *traveler)
{
    clearscreen();
    version();
    printf(
        "This program is free software: you can redistribute it and/or modify \n"
        "it under the terms of the GNU General Public License as published by \n"
        "the Free Software Foundation, either version 3 of the License, or \n"
        "(at your option) any later version.\n"
        "\n"
        "This program is distributed in the hope that it will be useful, \n"
        "but WITHOUT ANY WARRANTY; without even the implied warranty of \n"
        "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the \n"
        "GNU General Public License for more details.\n"
        "\n"
        "You should have received a copy of the GNU General Public License \n"
        "along with this program.  If not, see <http://www.gnu.org/licenses/>.\n"
        "\n"
        "A full copy of the GNU General Public License can be found at \"%s\".\n"
        "\n"
        "This program uses ImageMagick software. \n"
        "A full version of the ImageMagick license can be found at \"%s\".\n"
        "\n",
        getFileTraverser(traveler, NULL, "LICENSE"),
        getFileTraverser(traveler, NULL, "ImageMagick-License.txt")
    );
    PAUSE;
}

void help(struct Traverser *traveler)
{
    char *upperExecutable = toUppercase(getExeTraverser(traveler));

    printf("Creates a PDF file from c source code.\n");
    printf("\n");
    printf("%s [/PATH] [/VERSION] [/HELP]\n", upperExecutable);
    printf("\n");
    printf("PATH       The path to the c source code file.\n");
    printf("VERSION    Shows the version.\n");
    printf("HELP       Shows this help page.\n");
    printf("\n");
    printf("NOTE: The controls for the table editor can be brought up by typing \"?\" in the table editor.\n");
    printf("NOTE: If no parameters were specified, then the application will launch in interactive mode.\n");
    printf("\n");

    free(upperExecutable);
}

void convert(const char *code, struct Traverser *traveler, struct Settings config)
{
    char *header1;
    char *footer1;
    char *footer2;
    
    int hwNumber = 0;
    char *fullName;
    char *firstName;
    char *familyName;
    char *lowerFamilyName;
    int posGroup = 0;
    char *schoolClass;
    char date[255] = "";
    char exerciseImg[FILENAME_MAX] = "";
    char *imgFolder = NULL;
    char *outFolder = NULL;
    char *structImgPath = NULL;

    // image folder
    imgFolder = getFileTraverser(traveler, NULL, "img");

    // output folder
    if (strlen(config.outputFolder) <= 0)
    {
        outFolder = getFileTraverser(traveler, NULL, "");
    }
    else
    {
        outFolder = config.outputFolder;
    }    

    // homework number
    printf("Input your Homework Number: ");
    scanf("%d", &hwNumber);
    fflush(stdin);
    if (hwNumber > 99) 
    { 
        hwNumber = 99; 
    }
    else if (hwNumber < 0)
    {
        hwNumber = 0;
    }

    // first name
    if (strlen(config.firstName) <= 0)
    {
        if ((firstName = getstr("Input your first Name (for example: \"John\"): ")) == NULL)
        {
            firstName = malloc(2);
            strcpy(firstName, "");
        }
        fflush(stdin);
    }
    else
    {
        firstName = malloc(strlen(config.firstName) + 1);
        strcpy(firstName, config.firstName);
    }

    // family name
    if (strlen(config.familyName) <= 0)
    {
        if ((familyName = getstr("Input your family Name (for example: \"Doe\"): ")) == NULL)
        {
            familyName = malloc(2);
            strcpy(familyName, "");
        }
        fflush(stdin);
    }
    else
    {
        familyName = malloc(strlen(config.familyName) + 1);
        strcpy(familyName, config.familyName);
    }

    // pos group
    if (config.posGroup <= 0)
    {
        printf("Input your POS group: ");
        scanf("%d", &posGroup);
        fflush(stdin);
    }
    else
    {
        posGroup = config.posGroup;
    }

    // school class
    if (strlen(config.schoolClass) <= 0)
    {
        if ((schoolClass = getstr("Input your class: ")) == NULL)
        {
            schoolClass = malloc(2);
            strcpy(schoolClass, "");
        }
        fflush(stdin);        
    }
    else
    {
        schoolClass = malloc(strlen(config.schoolClass) + 1);
        strcpy(schoolClass, config.schoolClass);
    }

    // date
    if (config.askForDate)
    {
        printf("Input the date (DD/MM/YYYY) (\"0\" for today): ");
        scanf("%s", date);
        fflush(stdin);
    }
    else
    {
        strcpy(date, "0");
    }
    
    // exercise image
    selectExercise(imgFolder, exerciseImg);

    // auto date
    if (strcmp(date, "0") == 0)
    {
        // current time
        time_t t;
        t = time(NULL);
        struct tm tm = *localtime(&t);
        snprintf(date, 255, "%d/%d/%d", tm.tm_mday, tm.tm_mon+1, tm.tm_year+1900);
    }

    // structogram path
    if (config.structogramProcurement == 1)
    {
        fflush(stdin);
        structImgPath = getstr("Input the path to the structogram image: ");
        while (!exists(structImgPath))
        {
            free(structImgPath);
            structImgPath = getstr("This file doesn't exist.\nInput the path to the structogram image: ");
        }
    }

    fullName = malloc(strlen(firstName) + strlen(familyName) + 2);
    strcpy(fullName, firstName);
    strcat(fullName, " ");
    strcat(fullName, familyName);

    footer2 = toUppercase(schoolClass);
    free(schoolClass);

    footer1 = toUppercase(firstName);
    free(firstName);

    lowerFamilyName = toLowercase(familyName);
    free(familyName);

    header1 = malloc(strlen(fullName) + (int)(floor(log10(abs(posGroup))) + 1) + strlen(footer2) + 24);
    sprintf(header1, "%s / POS%d / Homework_%02d / %s", fullName, posGroup, hwNumber, footer2);
    free(fullName);

    generate(header1, date, footer1, footer2, exerciseImg, code, traveler, outFolder, lowerFamilyName, config.palettePath, structImgPath);

    free(header1);
    free(footer1);
    free(footer2);
    free(lowerFamilyName);
}

bool isVersion(const char *string)
{
    const char commands[][10] = {
        "/v", 
        "-v", 
        "/V", 
        "-V", 
        "/version", 
        "/Version", 
        "/VERSION", 
        "-version", 
        "-Version", 
        "-VERSION", 
        "--version", 
        "--Version",
        "--VERSION"
    };
    int commandsLength = sizeof(commands) / sizeof(commands[0]);

    for (int i = 0; i < commandsLength; i++)
    {
        if (strcmp(commands[i], string) == 0)
        {
            return true;
        }
    }

    return false;
}

bool isHelp(const char *string)
{
    const char commands[][7] = {
        "/?", 
        "-?", 
        "/h", 
        "-h", 
        "/H", 
        "-H", 
        "/help", 
        "/Help", 
        "/HELP", 
        "-help", 
        "-Help", 
        "-HELP", 
        "--help", 
        "--Help",
        "--HELP"
    };
    int commandsLength = sizeof(commands) / sizeof(commands[0]);

    for (int i = 0; i < commandsLength; i++)
    {
        if (strcmp(commands[i], string) == 0)
        {
            return true;
        }
    }

    return false;
}

int menu()
{
    int choice = -1;

    printf("1> Convert to PDF\n");
    printf("2> Settings\n");
    printf("3> License\n");
    printf("4> Help\n");
    printf("5> Exit\n");

    printf("\nType your choice: ");
    fflush(stdin);
    scanf("%d", &choice);

    clearscreen();

    if (choice < 1 || choice > 5)
    { 
        choice = -1; 
    }

    return choice;
}

int main(int argc, char const *argv[])
{
    struct Traverser traveler = initTraverser(argv[0]);
    struct Settings config = loadSettings(&traveler);
    char *codePath;

    if (argc > 1 && isHelp(argv[1]))
    {           
        help(&traveler);
    }
    else if (argc > 1 && isVersion(argv[1]))
    {
        version();
    } 
    else if (argc > 1 && exists(argv[1]))
    {
        // "no" gui, just do the things
        powerOnSelfCheck(&traveler);
        convert(argv[1], &traveler, config);
    } 
    else 
    {
        // open gui
        clearscreen();
        powerOnSelfCheck(&traveler);
        bool done = false;

        while (!done)
        {
            switch (menu())
            {
            case 1:
                // convert
                while (true)
                {
                    fflush(stdin);
                    codePath = getstr("Enter the path to the c source file: ");
                    if (codePath != NULL && exists(codePath))
                    {
                        break;
                    }
                    else
                    {
                        printf("This file doesn't exist.\n");
                    }
                }
                convert(codePath, &traveler, config);
                free(codePath);
                break;
            
            case 2:
                // settings
                settings(&traveler, &config);
                break;
            
            case 3:
                // license
                license(&traveler);
                break;
            
            case 4:
                // help
                help(&traveler);
                PAUSE;
                break;
            
            case 5:
                // exit
                done = true;
                break;
            
            default:
                printf("Invalid choice\n");
                break;
            }

            clearscreen();
        }

    }

    // cleanup
    stopTraverser(&traveler);

    return 0;
}

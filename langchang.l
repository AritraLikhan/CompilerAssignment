%{
#include <stdio.h>
#include <string.h>

int slcnt = 0;
int mlcnt = 0;
int idcnt = 0;
int kwdcnt = 0;
int intcnt = 0;
int fltcnt = 0;
int opcnt = 0;
int strcnt = 0;
int vstrcnt = 0;
int dlmcnt = 0;
int errcnt = 0;


const char* keywords[] = {
    "assume", "pin", "process", "is", "oris", "or",
    "loop", "ret", "flash", "block", "bind", "trap", "check", "diff", "focus"
};

#define NUM_KWD (sizeof(keywords) / sizeof(keywords[0]))

int is_keyword(const char* word) {
    for (int i = 0; i < NUM_KWD; ++i) {
        if (strcmp(word, keywords[i]) == 0) {
            return 1; // keyword found
        }
    }
    return 0; // not a keyword
}
%}

IDENTIFIER    [a-zA-Z_][a-zA-Z0-9_]*
VSTRING       \`([^`\$]|(\$\{[a-zA-Z_][a-zA-Z0-9_]*\}))*\`
STRING        \"[^\"]*\"
FLOAT         [0-9]+\.[0-9]+
INTEGER       [0-9]+
OPERATOR      [-+*/=<>!&|]
DELIMITER     [,\(\)\[\]\{\}\\;\.]
SLC           ##.*
MLC           \#\$.*\$#

%%

[\t\n]+ 

"assume"      { printf("VARIABLE    -> %s\n", yytext); kwdcnt++; }
"pin"         { printf("CONST       -> %s\n", yytext); kwdcnt++; }
"process"     { printf("FUNCTION    -> %s\n", yytext); kwdcnt++; }
"is"          { printf("IF          -> %s\n", yytext); kwdcnt++; }
"oris"        { printf("ELSE_IF     -> %s\n", yytext); kwdcnt++; }
"or"          { printf("ELSE        -> %s\n", yytext); kwdcnt++; }
"loop"        { printf("FOR         -> %s\n", yytext); kwdcnt++; }
"ret"         { printf("RETURN      -> %s\n", yytext); kwdcnt++; }
"flash"       { printf("PRINT       -> %s\n", yytext); kwdcnt++; }
"block"       { printf("ARRAY       -> %s\n", yytext); kwdcnt++; }
"bind"        { printf("INCLUDE     -> %s\n", yytext); kwdcnt++; }
"trap"        { printf("CATCH       -> %s\n", yytext); kwdcnt++; }
"check"       { printf("TRY         -> %s\n", yytext); kwdcnt++; }
"diff"        { printf("EXCEPTION   -> %s\n", yytext); kwdcnt++; }
"focus"       { printf("SCANF       -> %s\n", yytext); kwdcnt++; }
{SLC}         { printf("Single Line Comment   -> %s\n", yytext); slcnt++;}
{MLC}         { printf("Multi Line Comment    -> %s\n", yytext); mlcnt++; }
{FLOAT}       { fltcnt++; }
{INTEGER}     { intcnt++; }
{STRING}      { strcnt++; }
{VSTRING}     { vstrcnt++; }
{OPERATOR}    { opcnt++; }
{DELIMITER}   { dlmcnt++; }
{IDENTIFIER}  {
                  if (!is_keyword(yytext)) {
                      printf("IDENTIFIER  -> %s\n", yytext);
                      idcnt++;
                  }
              }
.             { errcnt++; }

%%

int yywrap() {
    return 1;
}

int main(int argc, char **argv) {
    if (argc < 2) {
        printf("Usage: %s <input-file>\n", argv[0]);
        return 1;
    }

    FILE *file = fopen(argv[1], "r");
    if (!file) {
        perror(argv[1]);
        return 1;
    }

    char outfile[256];
    snprintf(outfile, sizeof(outfile), "%s.out", argv[1]);
    freopen(outfile, "w", stdout);

    yyin = file;
    yylex();
    fclose(file);

    printf("Keywords: %d\n", kwdcnt);
    printf("Identifiers: %d\n", idcnt);
    printf("Integers: %d\n", intcnt);
    printf("Floats: %d\n", fltcnt);
    printf("Strings: %d\n", strcnt);
    printf("VStrings: %d\n", vstrcnt);
    printf("Operators: %d\n", opcnt);
    printf("Delimiters: %d\n", dlmcnt);
    printf("Errors: %d\n", errcnt);

    return 0;
}

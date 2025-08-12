%{
#include <stdio.h>
#include <stdlib.h>

/* Declare lexer function */
int lexer(void);

/* Override yylex to use lexer */
#define yylex lexer

/* Error reporting */
void error(const char *s);
%}

%token ID CONST

%left '+' 
%left '*'

%%

E : E '+' T
  | T
  ;

T : T '*' F
  | F
  ;

F : '(' E ')'
  | ID
  | CONST
  ;

%%

void error(const char *s) {
    printf("Parse error: %s\n", s);
}

int main() {
    printf("Enter expression:\n");
    if (yyparse() == 0)
        printf("Parsing completed successfully.\n");
    else
        printf("Parsing failed.\n");
    return 0;
}

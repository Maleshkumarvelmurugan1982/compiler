%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

void error(const char *s);
int lexer(void);

#define yylex lexer
%}

%union {
    int ival;
    double dval;
}

%token <ival> ICONST
%token <dval> FCONST

%type <dval> E

%left '+' '-'
%left '*' '/' '%'
%right '^'
%right UMINUS

%%

input:
    | input line
    ;

line:
    '\n'
    | E '\n'    { printf("= %lf\n", $1); }
    ;

E:
      E '+' E    { $$ = $1 + $3; }
    | E '-' E    { $$ = $1 - $3; }
    | E '*' E    { $$ = $1 * $3; }
    | E '/' E    {
                    if ($3 == 0) {
                        error("Division by zero");
                        $$ = 0;
                    } else {
                        $$ = $1 / $3;
                    }
                 }
    | E '%' E    {
                    if ((int)$3 == 0) {
                        error("Modulo by zero");
                        $$ = 0;
                    } else {
                        $$ = (int)$1 % (int)$3;
                    }
                 }
    | E '^' E    { $$ = pow($1, $3); }
    | '(' E ')'  { $$ = $2; }
    | '-' E %prec UMINUS { $$ = -$2; }
    | ICONST     { $$ = (double)$1; }
    | FCONST     { $$ = $1; }
    ;

%%

void error(const char *s) {
    printf("Error: %s\n", s);
}

int main() {
    printf("Basic Calculator (supports +, -, *, /, %%, ^, unary -)\n");
    printf("Enter expressions followed by ENTER, Ctrl+D to exit.\n");
    yyparse();
    return 0;
}

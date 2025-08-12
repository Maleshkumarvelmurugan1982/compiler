%{
#include "expr.tab.h"
#include <stdlib.h>

extern int yylval;
int lexer(void);
%}

%%

[ \t\n]+               ; /* skip whitespace */

"("                    { return '('; }
")"                    { return ')'; }
"+"                    { return '+'; }
"*"                    { return '*'; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval = 0; return ID; }
[0-9]+                 { yylval = atoi(yytext); return CONST; }

.                      { printf("Unknown character: %s\n", yytext); }

%%

int lexer(void) {
    return yylex();
}

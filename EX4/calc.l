%{
#include "calc.tab.h"
#include <stdlib.h>

int lexer(void);
%}

DIGIT   [0-9]

%%

[ \t]+                  ; /* skip whitespace */

{DIGIT}+                { yylval.ival = atoi(yytext); return ICONST; }

{DIGIT}+"."{DIGIT}+      { yylval.dval = atof(yytext); return FCONST; }

"("                     { return '('; }
")"                     { return ')'; }
"+"                     { return '+'; }
"-"                     { return '-'; }
"*"                     { return '*'; }
"/"                     { return '/'; }
"%"                     { return '%'; }
"^"                     { return '^'; }

\n                      { return '\n'; }

.                       { printf("Unknown character: %s\n", yytext); }

%%

int lexer(void) {
    return yylex();
}

%{
#include "y.tab.h"
#include <string.h>
#include <stdlib.h>
%}

digit   [0-9]
id      [a-zA-Z_][a-zA-Z0-9_]*
ws      [ \t\r\n]+

%%

"if"            { return IF; }
"else"          { return ELSE; }
"while"         { return WHILE; }
"for"           { return FOR; }
"do"            { return DO; }
"switch"        { return SWITCH; }
"case"          { return CASE; }
"default"       { return DEFAULT; }
"break"         { return BREAK; }
"continue"      { return CONTINUE; }

"=="            { return EQ; }
"!="            { return NE; }
"<="            { return LE; }
">="            { return GE; }
"<"             { return LT; }
">"             { return GT; }

"&&"            { return AND; }
"||"            { return OR; }
"!"             { return NOT; }

"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return MUL; }
"/"             { return DIV; }
"%"             { return MOD; }
"^"             { return POW; }
"="             { return ASSIGN; }

":"             { return COLON; }
"("             { return LPAREN; }
")"             { return RPAREN; }
"{"             { return LBRACE; }
"}"             { return RBRACE; }
";"             { return SEMI; }

{digit}+        { yylval.num = atoi(yytext); return NUMBER; }
{id}            { yylval.id = strdup(yytext); return ID; }
{ws}            { /* skip whitespace */ }
.               { return yytext[0]; }

%%

int yywrap(void) { return 1; }

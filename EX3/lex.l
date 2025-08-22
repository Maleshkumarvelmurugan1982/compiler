%{
#include <stdio.h>
int prev_token = 0;   /* 0 = start, 1 = operand, 2 = operator */
%}

%%
"for"       { printf("KEYWORD: %s\n", yytext); prev_token=2; }
"switch"    { printf("KEYWORD: %s\n", yytext); prev_token=2; }
"case"      { printf("KEYWORD: %s\n", yytext); prev_token=2; }
"break"     { printf("KEYWORD: %s\n", yytext); prev_token=2; }
"default"   { printf("KEYWORD: %s\n", yytext); prev_token=2; }
"int"       { printf("KEYWORD: %s\n", yytext); prev_token=2; }

\"([^\"\\]|\\.)*\"   { printf("STRING_LITERAL: %s\n", yytext); prev_token=1; }

[0-9]+      { printf("NUMBER: %s\n", yytext); prev_token=1; }
[a-zA-Z_][a-zA-Z0-9_]*  { printf("IDENTIFIER: %s\n", yytext); prev_token=1; }

"++"        { printf("OPERATOR: %s\n", yytext); prev_token=2; }
"--"        { printf("OPERATOR: %s\n", yytext); prev_token=2; }
"=="        { printf("OPERATOR: %s\n", yytext); prev_token=2; }
"<="        { printf("OPERATOR: %s\n", yytext); prev_token=2; }
">="        { printf("OPERATOR: %s\n", yytext); prev_token=2; }
"<"         { printf("OPERATOR: %s\n", yytext); prev_token=2; }
">"         { printf("OPERATOR: %s\n", yytext); prev_token=2; }
"="         { printf("OPERATOR: %s\n", yytext); prev_token=2; }
"+"         { printf("OPERATOR: %s\n", yytext); prev_token=2; }

"-" {
    if (prev_token == 0 || prev_token == 2) {
        printf("UNARY_OPERATOR: -\n");
    } else {
        printf("OPERATOR: -\n");
    }
    prev_token = 2;
}

"*"         { printf("OPERATOR: %s\n", yytext); prev_token=2; }
"/"         { printf("OPERATOR: %s\n", yytext); prev_token=2; }

";"         { printf("DELIMITER: %s\n", yytext); prev_token=2; }
":"         { printf("DELIMITER: %s\n", yytext); prev_token=2; }
","         { printf("DELIMITER: %s\n", yytext); prev_token=2; }
"{"         { printf("DELIMITER: %s\n", yytext); prev_token=2; }
"}"         { printf("DELIMITER: %s\n", yytext); prev_token=2; }
"("         { printf("DELIMITER: %s\n", yytext); prev_token=2; }
")"         { printf("DELIMITER: %s\n", yytext); prev_token=1; }

[ \t\n]+    ;   /* Ignore whitespace */
.           { printf("UNKNOWN: %s\n", yytext); prev_token=2; }
%%

int main() {
    yylex();
    return 0;
}

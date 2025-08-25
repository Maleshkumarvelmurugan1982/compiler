%{
#include <stdio.h>
FILE *yyin;
%}

%start BIN
%start UMINUS
%start UPLUS

%%

"if"      { BEGIN 0; printf("<keyword:%s>\n", yytext); }
"else"    { BEGIN 0; printf("<keyword:%s>\n", yytext); }
"while"   { BEGIN 0; printf("<keyword:%s>\n", yytext); }
"for"     { BEGIN 0; printf("<keyword:%s>\n", yytext); }
"switch"  { BEGIN 0; printf("<keyword:%s>\n", yytext); }
"case"    { BEGIN 0; printf("<keyword:%s>\n", yytext); }
"break"   { BEGIN 0; printf("<keyword:%s>\n", yytext); }
"default" { BEGIN 0; printf("<keyword:%s>\n", yytext); }
"int"     { BEGIN 0; printf("<keyword:%s>\n", yytext); }
"float"   { BEGIN 0; printf("<keyword:%s>\n", yytext); }
"return"  { BEGIN 0; printf("<keyword:%s>\n", yytext); }
"printf"  { BEGIN 0; printf("<function:%s>\n", yytext); }

","       { BEGIN UMINUS; printf("<comma:%s>\n", yytext); }
"*"       { BEGIN UMINUS; printf("<multiplication:%s>\n", yytext); }
"/"       { BEGIN UMINUS; printf("<division:%s>\n", yytext); }
"%"       { BEGIN UMINUS; printf("<modulus:%s>\n", yytext); }

"+="      { BEGIN UMINUS; printf("<addition assignment:%s>\n", yytext); }
"-="      { BEGIN UMINUS; printf("<subtraction assignment:%s>\n", yytext); }
"*="      { BEGIN UMINUS; printf("<multiplication assignment:%s>\n", yytext); }
"/="      { BEGIN UMINUS; printf("<division assignment:%s>\n", yytext); }
"%="      { BEGIN UMINUS; printf("<modulus assignment:%s>\n", yytext); }
"="       { BEGIN UMINUS; printf("<assignment:%s>\n", yytext); }

"=="      { BEGIN 0; printf("<equality:%s>\n", yytext); }
"!="      { BEGIN 0; printf("<inequality:%s>\n", yytext); }
"<="      { BEGIN 0; printf("<less than or equal:%s>\n", yytext); }
">="      { BEGIN 0; printf("<greater than or equal:%s>\n", yytext); }
"<"       { BEGIN 0; printf("<less than:%s>\n", yytext); }
">"       { BEGIN 0; printf("<greater than:%s>\n", yytext); }

[A-Za-z_][A-Za-z0-9_]*  { BEGIN 0; printf("<identifier:%s>\n", yytext); }

[0-9]+\.[0-9]+   { BEGIN BIN; printf("<float:%s>\n", yytext); }
[0-9]+           { BEGIN BIN; printf("<int:%s>\n", yytext); }
"\""([^"\n]*)"\"" { BEGIN 0; printf("<string:%s>\n", yytext); }
"#"              { BEGIN 0; printf("<hash:%s>\n", yytext); }

<BIN>"++" { BEGIN 0; printf("<post increment:%s>\n", yytext); }
<BIN>"--" { BEGIN 0; printf("<post decrement:%s>\n", yytext); }
"++"      { BEGIN 0; printf("<pre increment:%s>\n", yytext); }
"--"      { BEGIN 0; printf("<pre decrement:%s>\n", yytext); }

<UMINUS>"-"  { BEGIN 0; printf("<unary minus:%s>\n", yytext); }
<UPLUS>"+"   { BEGIN 0; printf("<unary plus:%s>\n", yytext); }

"+"       { BEGIN UPLUS; printf("<add:%s>\n", yytext); }
"-"       { BEGIN UMINUS; printf("<subtraction:%s>\n", yytext); }

";"       { BEGIN UMINUS; printf("<semicolon:%s>\n", yytext); }
"("       { BEGIN UMINUS; printf("<left parenthesis:%s>\n", yytext); }
")"       { BEGIN BIN;    printf("<right parenthesis:%s>\n", yytext); }
"{"       { BEGIN UMINUS; printf("<left brace:%s>\n", yytext); }
"}"       { BEGIN 0;      printf("<right brace:%s>\n", yytext); }
":"       { BEGIN 0;      printf("<colon:%s>\n", yytext); }

"\n"      { BEGIN UMINUS; printf("\n"); }
[ \t]+    { /* ignore whitespace */ }
.         { BEGIN 0; printf("<unknown:token:%s>\n", yytext); }
%%

int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            printf("Cannot open file %s\n", argv[1]);
            return 1;
        }
    }
    yylex();
    return 0;
}

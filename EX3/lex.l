%{
int prev_token = 0;   /* 0 = start, 1 = operand, 2 = operator */
FILE *yyin;
%}

%%

"for"       { printf("KEYWORD: for\n"); prev_token=2; }
"switch"    { printf("KEYWORD: switch\n"); prev_token=2; }
"case"      { printf("KEYWORD: case\n"); prev_token=2; }
"break"     { printf("KEYWORD: break\n"); prev_token=2; }
"default"   { printf("KEYWORD: default\n"); prev_token=2; }
"int"       { printf("KEYWORD: int\n"); prev_token=2; }
"float"     { printf("KEYWORD: float\n"); prev_token=2; }

\"([^\"\\]|\\.)*\"   { 
    printf("STRING_LITERAL: %s\n", yytext); 
    prev_token=1; 
}

[0-9]+      { printf("NUMBER: %s\n", yytext); prev_token=1; }

[a-zA-Z_][a-zA-Z0-9_]*  { printf("IDENTIFIER: %s\n", yytext); prev_token=1; }

"++"        { printf("INCREMENT: %s\n", yytext); prev_token=2; }
"--"        { printf("DECREMENT: %s\n", yytext); prev_token=2; }
"=="        { printf("EQUALITY: %s\n", yytext); prev_token=2; }
"<="        { printf("LESSEQ: %s\n", yytext); prev_token=2; }
">="        { printf("GREQ: %s\n", yytext); prev_token=2; }
"<"         { printf("LESS: %s\n", yytext); prev_token=2; }
">"         { printf("GREATER: %s\n", yytext); prev_token=2; }
"="         { printf("ASSIGN: %s\n", yytext); prev_token=2; }
"+"         { printf("PLUS: %s\n", yytext); prev_token=2; }

"-" {     
    if (prev_token == 0 || prev_token == 2) {
        printf("UNARY_MINUS: -\n");
    } else {
        printf("MINUS: -\n");
    }
    prev_token = 2; 
}

"*"         { printf("MULTIPLY: %s\n", yytext); prev_token=2; }
"/"         { printf("DIVIDE: %s\n", yytext); prev_token=2; }
";"         { printf("SEMICOLON: ;\n"); prev_token=2; }
":"         { printf("COLON: :\n"); prev_token=2; }
","         { printf("COMMA: ,\n"); prev_token=2; }
"{"         { printf("LBRACE: {\n"); prev_token=2; }
"}"         { printf("RBRACE: }\n"); prev_token=2; }
"("         { printf("LPAREN: (\n"); prev_token=2; }
")"         { printf("RPAREN: )\n"); prev_token=1; }

"#"         { printf("HASH: #\n"); prev_token=2; }

[ \t\n]+    ;   /* Ignore whitespace */

.           { printf("UNKNOWN: %s\n", yytext); prev_token=2; }

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

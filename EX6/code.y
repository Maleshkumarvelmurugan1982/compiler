%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int tempCount = 0;
int labelCount = 0;

/* stacks for loop/switch labels */
char* breakStack[100];
char* contStack[100];
int loopTop = -1;

char* newTemp() {
    char *buf = malloc(16);
    sprintf(buf, "t%d", tempCount++);
    return buf;
}

char* newLabel() {
    char *buf = malloc(16);
    sprintf(buf, "L%d", labelCount++);
    return buf;
}

int yylex(void);
void yyerror(const char *s);
%}

%union {
    char* id;
    int num;
}

%token <id> ID
%token <num> NUMBER
%token ASSIGN PLUS MINUS MUL DIV MOD POW SEMI
%token IF ELSE WHILE FOR DO
%token SWITCH CASE DEFAULT
%token BREAK CONTINUE
%token LPAREN RPAREN LBRACE RBRACE COLON
%token LT GT LE GE EQ NE
%token AND OR NOT

%type <id> expr stmt stmt_list

/* Precedence and associativity */
%right ASSIGN
%left OR
%left AND
%left EQ NE
%left LT LE GT GE
%left PLUS MINUS
%left MUL DIV MOD
%right POW
%right UMINUS NOT /* unary minus and logical not */

%%

program : stmt_list ;

stmt_list
    : stmt_list stmt
    | stmt
    ;

stmt
    : ID ASSIGN expr SEMI
        { printf("%s = %s\n", $1, $3); }

    | IF LPAREN expr RPAREN stmt
        {
            char* L = newLabel();
            printf("ifFalse %s goto %s\n", $3, L);
            printf("%s:\n", L);
        }

    | IF LPAREN expr RPAREN stmt ELSE stmt
        {
            char* Lelse = newLabel();
            char* Lend = newLabel();
            printf("ifFalse %s goto %s\n", $3, Lelse);
            printf("goto %s\n", Lend);
            printf("%s:\n", Lelse);
            printf("%s:\n", Lend);
        }

    | WHILE LPAREN expr RPAREN stmt
        {
            char* Lstart = newLabel();
            char* Lend = newLabel();

            loopTop++;
            contStack[loopTop] = Lstart;
            breakStack[loopTop] = Lend;

            printf("%s:\n", Lstart);
            printf("ifFalse %s goto %s\n", $3, Lend);
            printf("goto %s\n", Lstart);
            printf("%s:\n", Lend);

            loopTop--;
        }

    | DO stmt WHILE LPAREN expr RPAREN SEMI
        {
            char* Lstart = newLabel();
            char* Lend = newLabel();

            loopTop++;
            contStack[loopTop] = Lstart;
            breakStack[loopTop] = Lend;

            printf("%s:\n", Lstart);
            printf("if %s goto %s\n", $5, Lstart);
            printf("%s:\n", Lend);

            loopTop--;
        }

    | FOR LPAREN ID ASSIGN expr SEMI expr SEMI ID ASSIGN expr RPAREN stmt
        {
            char* Lstart = newLabel();
            char* Lend = newLabel();

            loopTop++;
            contStack[loopTop] = Lstart;
            breakStack[loopTop] = Lend;

            printf("%s = %s\n", $3, $5);          // init
            printf("%s:\n", Lstart);
            printf("ifFalse %s goto %s\n", $7, Lend);
            printf("%s = %s\n", $9, $11);         // increment
            printf("goto %s\n", Lstart);
            printf("%s:\n", Lend);

            loopTop--;
        }

    | SWITCH LPAREN expr RPAREN LBRACE case_list RBRACE
        {
            char* Lend = newLabel();
            printf("goto %s\n", Lend);
            printf("%s:\n", Lend);
        }

    | BREAK SEMI
        {
            if (loopTop >= 0)
                printf("goto %s\n", breakStack[loopTop]);
        }

    | CONTINUE SEMI
        {
            if (loopTop >= 0)
                printf("goto %s\n", contStack[loopTop]);
        }

    | LBRACE stmt_list RBRACE
        { }
    ;

case_list
    : case_list case_stmt
    | case_stmt
    ;

case_stmt
    : CASE NUMBER COLON stmt_list
        {
            char* Lcase = newLabel();
            printf("if switch_expr == %d goto %s\n", $2, Lcase);
            printf("%s:\n", Lcase);
        }
    | DEFAULT COLON stmt_list
        {
            char* Ldefault = newLabel();
            printf("goto %s\n", Ldefault);
            printf("%s:\n", Ldefault);
        }
    ;

expr
    : expr PLUS expr
        { char* t=newTemp(); printf("%s = %s + %s\n",t,$1,$3); $$=t; }
    | expr MINUS expr
        { char* t=newTemp(); printf("%s = %s - %s\n",t,$1,$3); $$=t; }
    | expr MUL expr
        { char* t=newTemp(); printf("%s = %s * %s\n",t,$1,$3); $$=t; }
    | expr DIV expr
        { char* t=newTemp(); printf("%s = %s / %s\n",t,$1,$3); $$=t; }
    | expr MOD expr
        { char* t=newTemp(); printf("%s = %s %% %s\n",t,$1,$3); $$=t; }
    | expr POW expr
        { char* t=newTemp(); printf("%s = pow(%s,%s)\n",t,$1,$3); $$=t; }

    | expr LT expr
        { char* t=newTemp(); printf("%s = %s < %s\n",t,$1,$3); $$=t; }
    | expr GT expr
        { char* t=newTemp(); printf("%s = %s > %s\n",t,$1,$3); $$=t; }
    | expr LE expr
        { char* t=newTemp(); printf("%s = %s <= %s\n",t,$1,$3); $$=t; }
    | expr GE expr
        { char* t=newTemp(); printf("%s = %s >= %s\n",t,$1,$3); $$=t; }
    | expr EQ expr
        { char* t=newTemp(); printf("%s = %s == %s\n",t,$1,$3); $$=t; }
    | expr NE expr
        { char* t=newTemp(); printf("%s = %s != %s\n",t,$1,$3); $$=t; }

    | expr AND expr
        { char* t=newTemp(); printf("%s = %s && %s\n",t,$1,$3); $$=t; }
    | expr OR expr
        { char* t=newTemp(); printf("%s = %s || %s\n",t,$1,$3); $$=t; }

    | NOT expr
        { char* t=newTemp(); printf("%s = ! %s\n",t,$2); $$=t; }
    | MINUS expr %prec UMINUS
        { char* t=newTemp(); printf("%s = - %s\n",t,$2); $$=t; }

    | NUMBER
        { char buf[16]; sprintf(buf,"%d",$1); $$=strdup(buf); }
    | ID
        { $$=$1; }
    | LPAREN expr RPAREN
        { $$=$2; }
    ;

%%

int main(int argc, char *argv[]) {
    if(argc < 2) {
        printf("Usage: %s <inputfile>\n", argv[0]);
        return 1;
    }

    FILE *fp = fopen(argv[1], "r");
    if(!fp) {
        perror("File opening failed");
        return 1;
    }

    yyin = fp;  // Flex input from file
    yyparse();

    fclose(fp);
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr,"Error: %s\n",s);
}

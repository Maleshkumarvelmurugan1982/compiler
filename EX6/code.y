%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);
extern FILE *yyin;

int tempCount = 0, labelCount = 0;

// Arrays for TAC and Quadruples
char tac[500][100];
char quad[500][100];
int tacIndex = 0, quadIndex = 0;

// Labels for control structures
char *currentLstart, *currentLtrue, *currentLfalse, *currentLend;
char *currentSwitchEnd, *currentCaseLabel;

// Track position for loop increment
int forIncrementTacStart = -1;
int forIncrementQuadStart = -1;

char* newTemp() {
    char *buf = malloc(10);
    sprintf(buf, "t%d", tempCount++);
    return buf;
}

char* newLabel() {
    char *buf = malloc(10);
    sprintf(buf, "L%d", labelCount++);
    return buf;
}

void addTAC(char *s) { strcpy(tac[tacIndex++], s); }
void addQuad(char *s) { strcpy(quad[quadIndex++], s); }

%}

%union {
    char *str;
}

%token <str> ID NUM
%token FOR SWITCH CASE DEFAULT BREAK
%token EQ NE LE GE LT GT ASSIGN ADD SUB MUL DIV COLON NEWLINE LPAREN RPAREN LBRACE RBRACE SEMICOLON COMMA

%type <str> expr condition

%%

program:
    stmt_list
    {
        printf("\n=== THREE ADDRESS CODE (TAC) ===\n");
        for (int i=0; i<tacIndex; i++) printf("%s\n", tac[i]);

        printf("\n=== QUADRUPLES ===\n");
        for (int i=0; i<quadIndex; i++) printf("%s\n", quad[i]);
    }
    ;

stmt_list:
      stmt_list stmt
    | stmt
    | /* empty */
    ;

stmt:
      ID ASSIGN expr NEWLINE
        {
            char line[100];
            sprintf(line, "%s = %s", $1, $3);
            addTAC(line);
            sprintf(line, "(ASSIGN, %s, -, %s)", $3, $1);
            addQuad(line);
        }

    | FOR LPAREN ID ASSIGN expr SEMICOLON condition SEMICOLON {
        // Mark where increment code generation will start
        forIncrementTacStart = tacIndex;
        forIncrementQuadStart = quadIndex;
    }
    ID ASSIGN expr RPAREN COLON NEWLINE {
        currentLstart = newLabel();   // L0
        currentLtrue = newLabel();    // L1
        currentLend = newLabel();     // L2

        char line[100];

        // Save the increment code that was just generated
        int incrTacCount = tacIndex - forIncrementTacStart;
        int incrQuadCount = quadIndex - forIncrementQuadStart;

        char savedTac[10][100];
        char savedQuad[10][100];

        for (int i = 0; i < incrTacCount; i++) {
            strcpy(savedTac[i], tac[forIncrementTacStart + i]);
        }
        for (int i = 0; i < incrQuadCount; i++) {
            strcpy(savedQuad[i], quad[forIncrementQuadStart + i]);
        }

        // Remove the increment code from current position
        tacIndex = forIncrementTacStart;
        quadIndex = forIncrementQuadStart;

        // Initialization: only assign loop variable
        sprintf(line, "%s = %s", $3, $5);   // i = 0
        addTAC(line);
        sprintf(line, "(ASSIGN, %s, -, %s)", $5, $3);
        addQuad(line);

        // Loop start label
        sprintf(line, "%s:", currentLstart);
        addTAC(line);

        // Now add the increment code INSIDE the loop
        for (int i = 0; i < incrTacCount; i++) {
            addTAC(savedTac[i]);
        }
        for (int i = 0; i < incrQuadCount; i++) {
            addQuad(savedQuad[i]);
        }

        // Condition check
        sprintf(line, "if %s goto %s", $7, currentLtrue);
        addTAC(line);
        sprintf(line, "(IF, %s, -, %s)", $7, currentLtrue);
        addQuad(line);

        // Goto loop end if condition false
        sprintf(line, "goto %s", currentLend);
        addTAC(line);
        sprintf(line, "(GOTO, -, -, %s)", currentLend);
        addQuad(line);

        // Loop body label
        sprintf(line, "%s:", currentLtrue);
        addTAC(line);
    }
    stmt_list
    {
        char line[100];

        // Jump back to loop start
        sprintf(line, "goto %s", currentLstart);
        addTAC(line);
        sprintf(line, "(GOTO, -, -, %s)", currentLstart);
        addQuad(line);

        // Loop end label
        sprintf(line, "%s:", currentLend);
        addTAC(line);
    }

    | SWITCH LPAREN expr RPAREN COLON NEWLINE {
        currentSwitchEnd = newLabel();
        char line[100];

        sprintf(line, "switch_expr = %s", $3);
        addTAC(line);
        sprintf(line, "(ASSIGN, %s, -, switch_expr)", $3);
        addQuad(line);
    }
    case_list default_part
    {
        char line[100];
        sprintf(line, "%s:", currentSwitchEnd);
        addTAC(line);
    }

    | BREAK NEWLINE
        {
            char line[100];
            sprintf(line, "goto %s", currentSwitchEnd ? currentSwitchEnd : currentLend);
            addTAC(line);
            sprintf(line, "(GOTO, -, -, %s)", currentSwitchEnd ? currentSwitchEnd : currentLend);
            addQuad(line);
        }

    | NEWLINE
    ;

case_list:
      case_list case_stmt
    | case_stmt
    | /* empty */
    ;

case_stmt:
      CASE NUM COLON NEWLINE {
        currentCaseLabel = newLabel();
        char line[100];

        sprintf(line, "if switch_expr == %s goto %s", $2, currentCaseLabel);
        addTAC(line);
        sprintf(line, "(IF_EQ, switch_expr, %s, %s)", $2, currentCaseLabel);
        addQuad(line);

        sprintf(line, "%s:", currentCaseLabel);
        addTAC(line);
    }
    stmt_list
    ;

default_part:
      DEFAULT COLON NEWLINE stmt_list
    | /* empty */
    ;

condition:
      expr EQ expr   {
                       char t[100];
                       sprintf(t, "%s == %s", $1, $3);
                       $$= strdup(t);
                     }
    | expr LT expr   {
                       char t[100];
                       sprintf(t, "%s < %s", $1, $3);
                       $$= strdup(t);
                     }
    | expr GT expr   {
                       char t[100];
                       sprintf(t, "%s > %s", $1, $3);
                       $$= strdup(t);
                     }
    | expr LE expr   {
                       char t[100];
                       sprintf(t, "%s <= %s", $1, $3);
                       $$= strdup(t);
                     }
    | expr GE expr   {
                       char t[100];
                       sprintf(t, "%s >= %s", $1, $3);
                       $$ = strdup(t);
                     }
    | expr NE expr   {
                       char t[100];
                       sprintf(t, "%s != %s", $1, $3);
                       $$ = strdup(t);
                     }
    ;

expr:
      expr ADD expr   { $$ = newTemp();
                        char t[100];
                        sprintf(t, "%s = %s + %s", $$, $1, $3);
                        addTAC(t);
                        sprintf(t, "(+, %s, %s, %s)", $1, $3, $$);
                        addQuad(t); }
    | expr SUB expr   { $$ = newTemp();
                        char t[100];
                        sprintf(t, "%s = %s - %s", $$, $1, $3);
                        addTAC(t);
                        sprintf(t, "(-, %s, %s, %s)", $1, $3, $$);
                        addQuad(t); }
    | expr MUL expr   { $$ = newTemp();
                        char t[100];
                        sprintf(t, "%s = %s * %s", $$, $1, $3);
                        addTAC(t);
                        sprintf(t, "(*, %s, %s, %s)", $1, $3, $$);
                        addQuad(t); }
    | expr DIV expr   { $$ = newTemp();
                        char t[100];
                        sprintf(t, "%s = %s / %s", $$, $1, $3);
                        addTAC(t);
                        sprintf(t, "(/, %s, %s, %s)", $1, $3, $$);
                        addQuad(t); }
    | ID              { $$ = strdup($1); }
    | NUM             { $$ = strdup($1); }
    ;

%%

void yyerror(const char *s) { fprintf(stderr, "Error: %s\n", s); }

int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) { perror("File open error"); return 1; }
    }
    yyparse();
    if (yyin && yyin != stdin) fclose(yyin);
    return 0;
}

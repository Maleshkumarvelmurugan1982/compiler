C:\Users\males>cat tac.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAX 100

typedef struct {
    char res[20];
    char op[5];
    char arg1[20];
    char arg2[20];
} TAC;

TAC code[MAX];
int n = 0;

// remove newline and carriage return
void trim(char *s) {
    int i = strlen(s) - 1;
    while (i >= 0 && (s[i] == '\n' || s[i] == '\r'))
        s[i--] = '\0';
}

// check if string is number
int isNumber(char *s) {
    if (!s[0]) return 0;
    for (int i = 0; s[i]; i++)
        if (!isdigit(s[i])) return 0;
    return 1;
}

// Constant folding
void constantFolding() {
    for (int i = 0; i < n; i++) {
        if (isNumber(code[i].arg1) && isNumber(code[i].arg2)) {
            int a = atoi(code[i].arg1);
            int b = atoi(code[i].arg2);
            int res = 0;
            if (strcmp(code[i].op, "+") == 0) res = a + b;
            else if (strcmp(code[i].op, "-") == 0) res = a - b;
            else if (strcmp(code[i].op, "*") == 0) res = a * b;
            else if (strcmp(code[i].op, "/") == 0 && b != 0) res = a / b;

            sprintf(code[i].arg1, "%d", res);
            strcpy(code[i].op, "=");
            strcpy(code[i].arg2, "");
        }
    }
}

// Copy and constant propagation
void copyPropagation() {
    for (int i = 0; i < n; i++) {
        if (strcmp(code[i].op, "=") == 0 && code[i].arg2[0] == '\0') {
            char src[20]; strcpy(src, code[i].arg1);
            char dst[20]; strcpy(dst, code[i].res);

            for (int j = i + 1; j < n; j++) {
                if (strcmp(code[j].arg1, dst) == 0)
                    strcpy(code[j].arg1, src);
                if (strcmp(code[j].arg2, dst) == 0)
                    strcpy(code[j].arg2, src);
            }
        }
    }
}

// Common Subexpression Elimination
void commonSubexpressionElimination() {
    for (int i = 0; i < n; i++) {
        for (int j = i + 1; j < n; j++) {
            if (strcmp(code[i].op, code[j].op) == 0 &&
                strcmp(code[i].arg1, code[j].arg1) == 0 &&
                strcmp(code[i].arg2, code[j].arg2) == 0) {
                for (int k = j + 1; k < n; k++) {
                    if (strcmp(code[k].arg1, code[j].res) == 0)
                        strcpy(code[k].arg1, code[i].res);
                    if (strcmp(code[k].arg2, code[j].res) == 0)
                        strcpy(code[k].arg2, code[i].res);
                }
                strcpy(code[j].op, "del");
            }
        }
    }
}

void printCode(const char *msg) {
    printf("\n--- %s ---\n", msg);
    for (int i = 0; i < n; i++) {
        if (strcmp(code[i].op, "del") == 0) continue;
        if (strcmp(code[i].op, "=") == 0 && code[i].arg2[0] == '\0')
            printf("%s = %s\n", code[i].res, code[i].arg1);
        else
            printf("%s = %s %s %s\n", code[i].res, code[i].arg1, code[i].op, code[i].arg2);
    }
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Usage: %s <inputfile>\n", argv[0]);
        return 1;
    }

    FILE *fp = fopen(argv[1], "r");
    if (!fp) {
        printf("Error: Cannot open %s\n", argv[1]);
        return 1;
    }

    char line[100];
    while (fgets(line, sizeof(line), fp)) {
        trim(line);
        if (strlen(line) < 3) continue;

        char res[20] = "", arg1[20] = "", op[5] = "", arg2[20] = "";
        int count = sscanf(line, "%s = %s %s %s", res, arg1, op, arg2);

        if (count == 2) { // e.g. x = y
            strcpy(code[n].res, res);
            strcpy(code[n].arg1, arg1);
            strcpy(code[n].arg2, "");
            strcpy(code[n].op, "=");
        } else {
            strcpy(code[n].res, res);
            strcpy(code[n].arg1, arg1);
            strcpy(code[n].op, op);
            strcpy(code[n].arg2, arg2);
        }
        n++;
    }
    fclose(fp);

    printCode("Original TAC");

    constantFolding();
    copyPropagation();
    commonSubexpressionElimination();

    printCode("Optimized TAC");

    return 0;
}

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define MAX 50
char states[MAX][20], inputs[MAX][20], finals[MAX][20], start[20];
int trans[MAX][MAX], n, ins, f;
int getIndex(char list[][20], int size, char *key) {
    for (int i = 0; i < size; i++) if (!strcmp(list[i], key)) return i;
    return -1;
}
int isFinal(char *st) {
    for (int i = 0; i < f; i++) if (!strcmp(st, finals[i])) return 1;
    return 0;
}

int main() {
    printf("No. of states: "); scanf("%d", &n);
    for (int i = 0; i < n; i++) { printf("State %d: ", i+1); scanf("%s", states[i]); }
    printf("Start state: "); scanf("%s", start);
    printf("No. of final states: "); scanf("%d", &f);
    for (int i = 0; i < f; i++) { printf("Final %d: ", i+1); scanf("%s", finals[i]); }
    printf("No. of input symbols: "); scanf("%d", &ins);
    for (int i = 0; i < ins; i++) { printf("Input %d: ", i+1); scanf("%s", inputs[i]); }
    
    for (int i = 0; i < n; i++)
        for (int j = 0; j < ins; j++) {
            char next[20]; printf("δ(%s, %s): ", states[i], inputs[j]); scanf("%s", next);
            trans[i][j] = (strcmp(next, "-") == 0) ? -1 : getIndex(states, n, next);
        }

    char line[200], tok[20]; int step;
    getchar(); printf("\nEnter input string (space-separated): "); fgets(line, sizeof(line), stdin);
    line[strcspn(line, "\n")] = 0;

    char token[200] = "";
    int cur = getIndex(states, n, start); step = 1;
    for (char *p = strtok(line, " "); p; p = strtok(NULL, " ")) {
        int inp = getIndex(inputs, ins, p);
        if (inp == -1 || cur == -1 || trans[cur][inp] == -1) { printf("Dead or invalid input.\n"); break; }
        printf("Step %d: %s --%s--> %s\n", step++, states[cur], p, states[trans[cur][inp]]);
        strcat(token, p); strcat(token, " "); cur = trans[cur][inp];
        if (isFinal(states[cur])) { printf("✅ Token accepted: %s\n", token); token[0] = 0; cur = getIndex(states, n, start); }
    }
    printf("🛑 End of input.\n");
}



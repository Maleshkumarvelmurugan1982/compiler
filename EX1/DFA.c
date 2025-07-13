#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>

#define MAX_STATES 50
#define MAX_INPUTS 50
#define MAX_NAME 10

// Utility functions
int getIndex(char list[][MAX_NAME], int count, char *target) {
    for (int i = 0; i < count; i++) {
        if (strcmp(list[i], target) == 0)
            return i;
    }
    return -1;
}

bool isFinalState(char *state, char finals[][MAX_NAME], int finalCount) {
    for (int i = 0; i < finalCount; i++) {
        if (strcmp(state, finals[i]) == 0)
            return true;
    }
    return false;
}

int main() {
    int n, ins;
    char states[MAX_STATES][MAX_NAME];
    char inputs[MAX_INPUTS][MAX_NAME];
    int trans[MAX_STATES][MAX_INPUTS];

    // DFA setup
    printf("Enter number of states: ");
    scanf("%d", &n);
    printf("Enter state names:\n");
    for (int i = 0; i < n; i++) {
        printf("State %d: ", i);
        scanf("%s", states[i]);
    }

    char start[MAX_NAME];
    printf("Enter start state: ");
    scanf("%s", start);

    int finalCount;
    char finals[MAX_STATES][MAX_NAME];
    printf("Enter number of final states: ");
    scanf("%d", &finalCount);
    printf("Enter final state names:\n");
    for (int i = 0; i < finalCount; i++) {
        printf("Final state %d: ", i);
        scanf("%s", finals[i]);
    }

    printf("Enter number of input symbols: ");
    scanf("%d", &ins);
    printf("Enter input symbols (single characters only):\n");
    for (int i = 0; i < ins; i++) {
        printf("Input %d: ", i);
        scanf("%s", inputs[i]);
    }

    printf("Enter transitions (use - for no transition):\n");
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < ins; j++) {
            char next[MAX_NAME];
            printf("δ(%s, %s): ", states[i], inputs[j]);
            scanf("%s", next);
            if (strcmp(next, "-") == 0) {
                trans[i][j] = -1;
            } else {
                int idx = getIndex(states, n, next);
                if (idx == -1) {
                    printf("Invalid state. Exiting.\n");
                    return 1;
                }
                trans[i][j] = idx;
            }
        }
    }

    // Consume newline from previous input
    getchar();

    while (1) {
        char str[200];
        printf("\nEnter the string input for DFA (use only input symbols, type 'exit' to quit): ");
        fgets(str, sizeof(str), stdin);
        str[strcspn(str, "\n")] = 0;

        if (strcmp(str, "exit") == 0)
            break;

        int cur = getIndex(states, n, start);
        if (cur == -1) {
            printf("Invalid start state. Exiting.\n");
            return 1;
        }

        bool dead = false;
        for (int i = 0; i < strlen(str); i++) {
            char symbolStr[2] = {str[i], '\0'};  // Convert char to string
            int inp_idx = getIndex(inputs, ins, symbolStr);
            if (inp_idx == -1) {
                printf("❌ Invalid input symbol: '%c'. Rejected.\n", str[i]);
                dead = true;
                break;
            }
            int next = trans[cur][inp_idx];
            if (next == -1) {
                printf("❌ Dead transition: %s --%c--> (none). Rejected.\n", states[cur], str[i]);
                dead = true;
                break;
            }
            printf("Step %d: %s --%c--> %s\n", i + 1, states[cur], str[i], states[next]);
            cur = next;
        }

        if (!dead) {
            if (isFinalState(states[cur], finals, finalCount)) {
                printf("✅ Final state '%s' reached. Input accepted!\n", states[cur]);
            } else {
                printf("❌ Final state not reached (ended at '%s'). Input rejected.\n", states[cur]);
            }
        }
    }

    printf("👋 Exiting. Thank you!\n");
    return 0;
}


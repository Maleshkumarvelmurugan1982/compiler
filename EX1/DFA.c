#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX 100
#define MAX_SYMBOL 20
#define MAX_NAME 20

// Get index of a string in a list
int getIndex(char list[][MAX_NAME], int size, char *str) {
    for (int i = 0; i < size; i++) {
        if (strcmp(list[i], str) == 0)
            return i;
    }
    return -1;
}

int main() {
    int nStates, nSymbols;

    // Input: States
    printf("Enter number of states: ");
    scanf("%d", &nStates);
    char states[MAX][MAX_NAME];
    printf("Enter state names:\n");
    for (int i = 0; i < nStates; i++) {
        printf("State %d: ", i + 1);
        scanf("%s", states[i]);
    }

    // Start state
    char startState[MAX_NAME];
    printf("Enter start state: ");
    scanf("%s", startState);

    // Final states
    int finalCount;
    char finalStates[MAX][MAX_NAME];
    printf("Enter number of final states: ");
    scanf("%d", &finalCount);
    printf("Enter final state names:\n");
    for (int i = 0; i < finalCount; i++) {
        printf("Final state %d: ", i + 1);
        scanf("%s", finalStates[i]);
    }

    // Input symbols
    printf("Enter number of input symbols: ");
    scanf("%d", &nSymbols);
    char inputSymbols[MAX_SYMBOL][MAX_NAME];
    printf("Enter input symbols:\n");
    for (int i = 0; i < nSymbols; i++) {
        printf("Symbol %d: ", i + 1);
        scanf("%s", inputSymbols[i]);
    }

    // Transition table
    int trans[MAX][MAX_SYMBOL];
    printf("Enter transition table (use '-' for no transition):\n");
    for (int i = 0; i < nStates; i++) {
        for (int j = 0; j < nSymbols; j++) {
            char target[MAX_NAME];
            printf("δ(%s, %s): ", states[i], inputSymbols[j]);
            scanf("%s", target);
            if (strcmp(target, "-") == 0) {
                trans[i][j] = -1;
            } else {
                int idx = getIndex(states, nStates, target);
                if (idx == -1) {
                    printf("❌ Invalid state name! Exiting.\n");
                    return 1;
                }
                trans[i][j] = idx;
            }
        }
    }

    // Input string
    char inputStr[1000];
    printf("\nEnter input string (space-separated tokens): ");
    getchar(); // Clear newline
    fgets(inputStr, sizeof(inputStr), stdin);
    inputStr[strcspn(inputStr, "\n")] = '\0'; // Remove newline

    char *token = strtok(inputStr, " ");
    int curState = getIndex(states, nStates, startState);
    if (curState == -1) {
        printf("❌ Invalid start state.\n");
        return 1;
    }

    char currentToken[200] = "";
    int step = 1;

    printf("\n🔄 DFA Execution Steps:\n");

    while (token != NULL) {
        int symbolIndex = getIndex(inputSymbols, nSymbols, token);
        if (symbolIndex == -1) {
            printf("❌ Invalid input symbol: %s\n", token);
            break;
        }

        int nextState = trans[curState][symbolIndex];
        if (nextState == -1) {
            printf("❌ Dead transition on (%s, %s). Rejected.\n", states[curState], token);
            break;
        }

        // Print transition step
        printf("Step %d: %s --%s--> %s\n", step++, states[curState], token, states[nextState]);

        // Append to current token
        strcat(currentToken, token);
        strcat(currentToken, " ");
        curState = nextState;

        // Final state check
        if (getIndex(finalStates, finalCount, states[curState]) != -1) {
            printf("✅ Token accepted: %s\n\n", currentToken);
            currentToken[0] = '\0';
            curState = getIndex(states, nStates, startState); // reset
        }

        token = strtok(NULL, " ");
    }

    printf("🛑 End of input.\n");
    return 0;
}



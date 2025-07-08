#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#define MAX 20

// Global variables
int numStates, numSymbols;
int transition[MAX][MAX];     // Transition table
char symbols[MAX];            // Input symbols
int startState;
int finalStates[MAX], numFinalStates;

// Get index of symbol from the symbol array
int getSymbolIndex(char c) {
    for (int i = 0; i < numSymbols; i++) {
        if (symbols[i] == c) return i;
    }
    return -1;
}

// Check if a state is a final state
bool isFinal(int state) {
    for (int i = 0; i < numFinalStates; i++) {
        if (finalStates[i] == state) return true;
    }
    return false;
}

// ------------------- DFA Minimization (Table Filling Method) -------------------
void minimizeDFA() {
    bool distinguishable[MAX][MAX] = {false}; // Table to mark distinguishable pairs

    // Step 1: Mark pairs where one is final and one is not
    for (int i = 0; i < numStates; i++) {
        for (int j = 0; j < numStates; j++) {
            if ((isFinal(i) && !isFinal(j)) || (!isFinal(i) && isFinal(j))) {
                distinguishable[i][j] = distinguishable[j][i] = true;
            }
        }
    }

    // Step 2: Iteratively mark pairs based on transition differences
    bool changed;
    do {
        changed = false;
        for (int i = 0; i < numStates; i++) {
            for (int j = 0; j < i; j++) {
                if (distinguishable[i][j]) continue;

                for (int k = 0; k < numSymbols; k++) {
                    int a = transition[i][k];
                    int b = transition[j][k];

                    if (a == -1 || b == -1) continue;

                    if (distinguishable[a][b]) {
                        distinguishable[i][j] = distinguishable[j][i] = true;
                        changed = true;
                        break;
                    }
                }
            }
        }
    } while (changed);

    // Step 3: Group equivalent states
    int stateMap[MAX];
    for (int i = 0; i < numStates; i++) stateMap[i] = i;

    for (int i = 0; i < numStates; i++) {
        for (int j = 0; j < i; j++) {
            if (!distinguishable[i][j]) {
                stateMap[i] = stateMap[j];
                break;
            }
        }
    }

    // Step 4: Assign new state numbers
    int newMap[MAX], newStateCount = 0;
    for (int i = 0; i < numStates; i++) {
        if (stateMap[i] == i) newMap[i] = newStateCount++;
        else newMap[i] = newMap[stateMap[i]];
    }

    // Step 5: Build new minimized transition table
    int newTransition[MAX][MAX];
    for (int i = 0; i < MAX; i++)
        for (int j = 0; j < MAX; j++)
            newTransition[i][j] = -1;

    for (int i = 0; i < numStates; i++) {
        int from = newMap[stateMap[i]];
        for (int j = 0; j < numSymbols; j++) {
            int to = transition[i][j];
            if (to != -1) {
                newTransition[from][j] = newMap[stateMap[to]];
            }
        }
    }

    // Step 6: Update final states
    int newFinal[MAX], newFinalCount = 0;
    for (int i = 0; i < numStates; i++) {
        if (isFinal(i)) {
            int rep = newMap[stateMap[i]];
            bool alreadyAdded = false;
            for (int j = 0; j < newFinalCount; j++) {
                if (newFinal[j] == rep) {
                    alreadyAdded = true;
                    break;
                }
            }
            if (!alreadyAdded) newFinal[newFinalCount++] = rep;
        }
    }

    // Display the minimized DFA
    printf("\n✅ Minimized DFA:\n");
    printf("Start State: %d\n", newMap[stateMap[startState]]);
    printf("Final States: ");
    for (int i = 0; i < newFinalCount; i++) printf("%d ", newFinal[i]);
    printf("\nTransition Table:\n");
    for (int i = 0; i < newStateCount; i++) {
        for (int j = 0; j < numSymbols; j++) {
            if (newTransition[i][j] != -1)
                printf("δ(%d, %c) = %d\n", i, symbols[j], newTransition[i][j]);
        }
    }

    // Update DFA with minimized values
    numStates = newStateCount;
    memcpy(transition, newTransition, sizeof(newTransition));
    startState = newMap[stateMap[startState]];
    memcpy(finalStates, newFinal, sizeof(newFinal));
    numFinalStates = newFinalCount;
}

// ------------------- String Acceptance -------------------
bool isAccepted(char *input) {
    int state = startState;
    for (int i = 0; i < strlen(input); i++) {
        int symIdx = getSymbolIndex(input[i]);
        if (symIdx == -1 || transition[state][symIdx] == -1) return false;
        state = transition[state][symIdx];
    }
    return isFinal(state);
}

// ------------------- Main Function -------------------
int main() {
    // Input number of states
    printf("Enter number of states: ");
    scanf("%d", &numStates);
    getchar(); // Flush newline

    // Input number of input symbols
    printf("Enter number of input symbols: ");
    scanf("%d", &numSymbols);
    getchar(); // Flush newline

    // Input symbols
    printf("Enter input symbols (e.g., a b): ");
    for (int i = 0; i < numSymbols; i++) {
        scanf(" %c", &symbols[i]);
    }
    getchar(); // Flush newline

    // Initialize transition table
    for (int i = 0; i < MAX; i++)
        for (int j = 0; j < MAX; j++)
            transition[i][j] = -1;

    // Input transitions
    printf("\nEnter transitions in format: δ(state, symbol) = next_state;\n");
    printf("Enter total number of transitions: ");
    int t;
    scanf("%d", &t);
    getchar(); // Flush newline

    for (int i = 0; i < t; i++) {
        int from, to;
        char symbol;
        printf("Transition %d: ", i + 1);
        scanf("δ(%d , %c ) = %d;", &from, &symbol, &to);
        getchar(); // Flush newline

        int symIndex = getSymbolIndex(symbol);
        if (symIndex == -1) {
            printf("❌ Invalid symbol '%c'. Skipping.\n", symbol);
            continue;
        }
        transition[from][symIndex] = to;
    }

    // Input start state
    printf("Enter start state: ");
    scanf("%d", &startState);
    getchar();

    // Input final states
    printf("Enter number of final states: ");
    scanf("%d", &numFinalStates);
    getchar();

    printf("Enter final states: ");
    for (int i = 0; i < numFinalStates; i++) {
        scanf("%d", &finalStates[i]);
    }

    // Minimize the DFA
    minimizeDFA();

    // Check string for acceptance
    char inputStr[100];
    printf("\nEnter string to check: ");
    scanf("%s", inputStr);

    if (isAccepted(inputStr)) {
        printf("✅ String is ACCEPTED by the minimized DFA.\n");
    } else {
        printf("❌ String is REJECTED by the minimized DFA.\n");
    }

    return 0;
}

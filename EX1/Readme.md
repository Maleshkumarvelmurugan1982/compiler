

# ✅ FULL LINE-BY-LINE EXPLANATION

---

### Header files:

```c
#include <stdio.h>
```

➡️ Includes the **Standard Input Output** header. Needed for `printf()`, `scanf()`, etc.

```c
#include <stdlib.h>
```

➡️ Includes **Standard Library** functions like `malloc()`, `free()` (though unused here).

```c
#include <string.h>
```

➡️ Allows using string functions like `strlen()`, `memcpy()`.

```c
#include <stdbool.h>
```

➡️ Enables `bool`, `true`, `false` keywords in C.

---

### Constants and Global Variables

```c
#define MAX 20
```

➡️ Defines a constant `MAX = 20` — used as size limit for states, symbols, etc.

```c
int numStates, numSymbols;
```

➡️ `numStates`: number of states in DFA
➡️ `numSymbols`: number of symbols in the input alphabet

```c
int transition[MAX][MAX];
```

➡️ `transition[i][j]` = next state when DFA is in state `i` and reads symbol at index `j`

```c
char symbols[MAX];
```

➡️ Stores the list of input symbols (e.g., `a`, `b`)

```c
int startState;
```

➡️ The starting state of the DFA

```c
int finalStates[MAX], numFinalStates;
```

➡️ `finalStates[]`: list of accepting states
➡️ `numFinalStates`: how many final states there are

---

## 🔧 Helper: Get symbol index

```c
int getSymbolIndex(char c) {
    for (int i = 0; i < numSymbols; i++) {
        if (symbols[i] == c) return i;
    }
    return -1;
}
```

➡️ Given a symbol like `'a'`, it loops through `symbols[]` to find its index.
➡️ If found, returns the index
➡️ If not, returns `-1` (meaning: symbol not in DFA alphabet)

---

## 🔧 Helper: Is a state final?

```c
bool isFinal(int state) {
    for (int i = 0; i < numFinalStates; i++) {
        if (finalStates[i] == state) return true;
    }
    return false;
}
```

➡️ Loops through `finalStates[]`.
➡️ If the state is found in final states, returns `true`, else `false`.

---

## 🔥 DFA Minimization – Table Filling Method

```c
void minimizeDFA() {
```

Starts the function that will minimize the DFA.

---

### Step 1: Mark distinguishable final/non-final pairs

```c
bool distinguishable[MAX][MAX] = {false};
```

➡️ 2D array to mark if pair `(i, j)` of states are **distinguishable**
➡️ Initialized to `false` (i.e., all states assumed equivalent initially)

```c
for (int i = 0; i < numStates; i++) {
    for (int j = 0; j < numStates; j++) {
        if ((isFinal(i) && !isFinal(j)) || (!isFinal(i) && isFinal(j))) {
            distinguishable[i][j] = distinguishable[j][i] = true;
        }
    }
}
```

➡️ For each pair of states `(i, j)`
➡️ If **one is final and one is not**, mark them as distinguishable
➡️ Because they can't be equivalent

---

### Step 2: Iteratively mark more distinguishable pairs

```c
bool changed;
do {
    changed = false;
```

➡️ `changed` tracks if we found new distinguishable pairs in this iteration
➡️ The loop continues as long as new changes are found

```c
for (int i = 0; i < numStates; i++) {
    for (int j = 0; j < i; j++) {
        if (distinguishable[i][j]) continue;
```

➡️ We only process pairs where `i > j` and not already marked
➡️ If already distinguishable, skip it

```c
for (int k = 0; k < numSymbols; k++) {
    int a = transition[i][k];
    int b = transition[j][k];
```

➡️ For each input symbol `k`, find transitions from `i` and `j`
➡️ Let `a = δ(i, symbol[k])`, `b = δ(j, symbol[k])`

```c
if (a == -1 || b == -1) continue;
```

➡️ If transition not defined for that symbol, skip

```c
if (distinguishable[a][b]) {
    distinguishable[i][j] = distinguishable[j][i] = true;
    changed = true;
    break;
}
```

➡️ If transitions lead to distinguishable states, mark `i` and `j` as distinguishable
➡️ Set `changed = true` so that loop continues

---

### Step 3: Group equivalent states

```c
int stateMap[MAX];
for (int i = 0; i < numStates; i++) stateMap[i] = i;
```

➡️ `stateMap[i]` initially maps each state to itself
➡️ Will store representative state for each equivalence class

```c
for (int i = 0; i < numStates; i++) {
    for (int j = 0; j < i; j++) {
        if (!distinguishable[i][j]) {
            stateMap[i] = stateMap[j];
            break;
        }
    }
}
```

➡️ If `i` and `j` are not distinguishable, they are equivalent
➡️ Map `i` to `j`'s class

---

### Step 4: Assign new state numbers

```c
int newMap[MAX], newStateCount = 0;
for (int i = 0; i < numStates; i++) {
    if (stateMap[i] == i) newMap[i] = newStateCount++;
    else newMap[i] = newMap[stateMap[i]];
}
```

➡️ For each group, assign a unique number
➡️ `newMap[i]` = new state number assigned to state `i`

---

### Step 5: Build minimized transition table

```c
int newTransition[MAX][MAX];
for (int i = 0; i < MAX; i++)
    for (int j = 0; j < MAX; j++)
        newTransition[i][j] = -1;
```

➡️ Initialize `newTransition` table to -1

```c
for (int i = 0; i < numStates; i++) {
    int from = newMap[stateMap[i]];
    for (int j = 0; j < numSymbols; j++) {
        int to = transition[i][j];
        if (to != -1) {
            newTransition[from][j] = newMap[stateMap[to]];
        }
    }
}
```

➡️ Convert old transitions into minimized transitions
➡️ For each `i`, get its representative state in new map
➡️ Translate its transitions accordingly

---

### Step 6: Update final states

```c
int newFinal[MAX], newFinalCount = 0;
```

➡️ Array and counter for new final states

```c
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
```

➡️ For each final state in old DFA, get its minimized representative
➡️ Add to new final state list (if not already present)

---

### Print Result

```c
printf("\n✅ Minimized DFA:\n");
```

➡️ Start of output

```c
printf("Start State: %d\n", newMap[stateMap[startState]]);
```

➡️ Print minimized start state

```c
printf("Final States: ");
for (int i = 0; i < newFinalCount; i++) printf("%d ", newFinal[i]);
```

➡️ Print minimized final states

```c
printf("\nTransition Table:\n");
for (int i = 0; i < newStateCount; i++) {
    for (int j = 0; j < numSymbols; j++) {
        if (newTransition[i][j] != -1)
            printf("δ(%d, %c) = %d\n", i, symbols[j], newTransition[i][j]);
    }
}
```

➡️ Print minimized DFA transitions

```c
numStates = newStateCount;
memcpy(transition, newTransition, sizeof(newTransition));
startState = newMap[stateMap[startState]];
memcpy(finalStates, newFinal, sizeof(newFinal));
numFinalStates = newFinalCount;
```

➡️ Update global variables so minimized DFA replaces the original one

---

## ✅ Check String Acceptance

```c
bool isAccepted(char *input) {
    int state = startState;
    for (int i = 0; i < strlen(input); i++) {
        int symIdx = getSymbolIndex(input[i]);
        if (symIdx == -1 || transition[state][symIdx] == -1) return false;
        state = transition[state][symIdx];
    }
    return isFinal(state);
}
```

➡️ Start at `startState`
➡️ For each character, find the symbol index
➡️ Follow the transition
➡️ If at end you're in a final state → return `true`

---

## 🧑‍💻 Main Function

```c
int main() {
```

Begins execution

```c
printf("Enter number of states: ");
scanf("%d", &numStates);
getchar();
```

➡️ Take number of states

```c
printf("Enter number of input symbols: ");
scanf("%d", &numSymbols);
getchar();
```

➡️ Take number of input symbols (like `a`, `b`)

```c
printf("Enter input symbols (e.g., a b): ");
for (int i = 0; i < numSymbols; i++) {
    scanf(" %c", &symbols[i]);
}
getchar();
```

➡️ Read the actual symbols into `symbols[]`

```c
for (int i = 0; i < MAX; i++)
    for (int j = 0; j < MAX; j++)
        transition[i][j] = -1;
```

➡️ Initialize transition table to `-1` (meaning "undefined")

---

### Input transitions

```c
printf("\nEnter transitions in format: δ(state, symbol) = next_state;\n");
printf("Enter total number of transitions: ");
int t;
scanf("%d", &t);
getchar();
```

➡️ Ask how many transitions to input

```c
for (int i = 0; i < t; i++) {
    int from, to;
    char symbol;
    printf("Transition %d: ", i + 1);
    scanf("δ(%d , %c ) = %d;", &from, &symbol, &to);
    getchar();
```

➡️ Input transition like `δ(0 , a ) = 1;`

```c
    int symIndex = getSymbolIndex(symbol);
    if (symIndex == -1) {
        printf("❌ Invalid symbol '%c'. Skipping.\n", symbol);
        continue;
    }
    transition[from][symIndex] = to;
}
```

➡️ Store transition in `transition[from][symbolIndex] = to`

---

### Start and final states

```c
printf("Enter start state: ");
scanf("%d", &startState);
getchar();
```

➡️ Get start state

```c
printf("Enter number of final states: ");
scanf("%d", &numFinalStates);
getchar();

printf("Enter final states: ");
for (int i = 0; i < numFinalStates; i++) {
    scanf("%d", &finalStates[i]);
}
```

➡️ Get final states

---

### Minimize DFA and check input

```c
minimizeDFA();
```

➡️ Call the minimization function

```c
char inputStr[100];
printf("\nEnter string to check: ");
scanf("%s", inputStr);
```

➡️ Ask for string to check

```c
if (isAccepted(inputStr)) {
    printf("✅ String is ACCEPTED by the minimized DFA.\n");
} else {
    printf("❌ String is REJECTED by the minimized DFA.\n");
}
```

➡️ Use minimized DFA to check string acceptance

---

```c
return 0;
}
```

➡️ End of program

---


Purpose: This program simulates a Deterministic Finite Automaton (DFA) — it processes input strings based on states, transitions, and final states to check acceptance.

Data Structures:

states, inputs, and finals store the names of states, input symbols, and final states.

trans is a 2D array storing transitions: from each state with each input symbol, which next state to go to.

Input Reading:

Reads the number of states, their names, the start state, number of final states, final states’ names, and input symbols from the user.

For each state and input symbol, asks for the transition state.

Transition Representation:

The transition for a pair (state, input) is stored as an index in trans.

If there's no transition (indicated by "-"), it stores -1.

Helper Functions:

getIndex() finds the index of a string (state/input) in the corresponding array.

isFinal() checks if a given state is a final state.

Processing Input Strings:

Reads a sequence of input symbols separated by spaces.

For each symbol, it moves to the next state using the transition table.

Dead or Invalid Input:

If the input symbol is not recognized, or the current state has no valid transition, it prints "Dead or invalid input" and stops.

Token Acceptance:

Keeps track of accepted tokens (substrings that end in a final state).

When the DFA reaches a final state, it prints a “Token accepted” message, clears the token, and resets the DFA to the start state.

Output:

Prints each transition step, showing current state, input, and next state.

Marks accepted tokens and signals the end of input.

Overall Flow:

You build the DFA from user input, run it on a string, and get stepwise feedback including accepted tokens or errors.

#include <stdio.h>

int main() {
    int a = -10;
    float b = 20.5;
    int c;

    // arithmetic and assignment
    c = a + b;
    c -= 5;
    c *= 2;
    c /= 3;
    c %= 4;

    // relational
    if (c == 10) {
        printf("Equal\n");
    } else if (c != 0 && c <= 20) {
        printf("Condition met\n");
    } else {
        printf("Not equal\n");
    }

    // loop with switch
    for (int i = 0; i < 3; i++) {
        switch (i) {
            case 0:
                printf("Case 0\n");
                break;
            case 1:
                printf("Case 1\n");
                break;
            default:
                printf("Default case\n");
                break;
        }
    }

    return 0;
}

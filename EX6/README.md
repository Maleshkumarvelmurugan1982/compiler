flex code.l
yacc -d code.y
gcc lex.yy.c code.tab.c -o tac -lm
./tac input.txt


a = 5
b = 10
t0 = b * 2
t1 = a + t0
c = t1
t2 = - a
d = t2
t3 = - c
t4 = b - t3
e = t4
t5 = 10 % 3
f = t5
t6 = pow(2,3)
g = t6
t7 = a < b
ifFalse t7 goto L0
t8 = c + 1
c = t8
goto L1
L0:
t9 = a == b
ifFalse t9 goto L2
t10 = c - 1
c = t10
goto L1
L2:
c = 0
L1:
i = 0
L3:
t11 = i < 5
ifFalse t11 goto L4
t12 = i == 2
ifFalse t12 goto L5
goto L3
L5:
t13 = i == 4
ifFalse t13 goto L6
goto L4
L6:
t14 = i + 1
i = t14
goto L3
L4:
j = 0
L7:
t15 = j < 6
ifFalse t15 goto L8
t16 = j + 2
j = t16
goto L7
L8:
k = 0
L9:
t17 = k < 3
ifFalse t17 goto L10
t18 = a + k
a = t18
t19 = k + 1
k = t19
goto L9
L10:
x = 2
goto L11
L11:
if switch_expr == 1 goto L12
L12:
t20 = x + 10
x = t20
goto Lend
if switch_expr == 2 goto L13
L13:
t21 = x + 20
x = t21
goto Lend
goto L14
L14:
x = 100
Lend:


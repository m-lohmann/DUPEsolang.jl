# DUPEsolang

DUP esoteric programming language

[![Build Status](https://travis-ci.org/m-lohmann/DUPEsolang.jl.svg?branch=master)](https://travis-ci.org/m-lohmann/DUPEsolang.jl)

For instructions about how to use the program, please [scroll down](https://github.com/m-lohmann/DUPEsolang.jl#Using-DUP).

## Introduction

**DUP** is a variant of Wouter van Oortmerssen’s **FALSE** language developed by Ian Osgood. Like **FALSE**, **DUP** is a Forth-like language, and analogous to Oortmerssen’s **FALSE** language, Osgood named **DUP** after his own favorite Forth stack operator.
**DUP** adds a few functions to **FALSE** (and changes some) to make programming more convenient, most notably the access to the return stack, which enables **DUP** to be turing complete and enables the user to create additional control structures.

## Instructions

In the following explanations about syntax `<name>` or <address> mean the value or descriptor of a variable name or address value. Other descriptors are used in a similar fashion.

### Numbers

Numbers are pushed on the stack as encountered by the interpreter. Different integers are separated by one or more whitespace characters:

```
Numbers         data stack
9               [9]
1234            [1234]
12 34           [12, 34]
1 2 34          [1, 2, 34]
```

### Stack manipulation

The data stack in **DUP** can be manipulated with the following instructions:

```
$   DUP     Duplicate top stack item.
%   DROP    Pop top stack item.
^   OVER    DUP 2nd stack item . **New meaning in DUP, read character in FALSE**
\   SWAP    Swap 1st and 2nd stack items.
@   ROT     Rotate the first three stack items: move 3rd item on top.
ø   PICK    DUP the nth stack item. Top item is counted as the 0th item.
```

Examples:
```
            data stack
2$          [2,2]
1 2 3%      [1,2]
1 2^        [1,2,1]
1 7\        [7,1]
1 2 3@      [2,3,1]
4 3 2 1 3ø  [4,3,2,1,4]
```

### Arithmetic operators

**DUP** offers arithmetic operations, of course:

```
+   Add
-   Subtract
*   Multiply
/   Mod,Div     Pushes mod and integer division results on top of the stack.
                **Changed in DUP to mimic Forth’s /MOD operator**
```
Mod only and division only can be realized as follows:
```
/\%     Integer division only
/%      Mod only
```

Examples:
```
            data stack
5 3+        [8]
5 3-        [2]
5 3*        [15]
13 3/       [1,4]   Leaving [mod,div] on top of the stack.
13 3/\%     [4]     Integer division only.
13 3/%      [1]     Mod only.
```

### Logic operators and bit manipulation

The following logic and bit manipulation operators are available in **DUP**:

```
&   AND     Results in: 2nd AND 1st item.
|   XOR     Results in: 2nd XOR 1st item. **Changed from FALSE OR operator**
~   NOT     Results in: NOT 1st item.
»   LSR     Results in: 1st >>> 2nd item. **New instruction in DUP (JS version)**
«   ASL     Results in: 1st << 2nd item.  **New instruction in DUP (JS version)**
```
Inclusive OR can be realized by:
```
^~&|        OR
```

Examples:
```
            data stack
5 3&        [1]
5 3|        [6]     5 XOR 3
0~          [-1]    0 and -1 are also the truth values in DUP.
                    0 (no bits set) is FALSE, -1 (all bits set) is TRUE.
5 3^~&|     [7]     5 OR 3
136 3»      [17]
17 3«       [136]
```

### Comparison operators

**DUP** has three comparison operators `<`, `=` and `>` instead of only the two `=` and `>` operators in **FALSE**:

```
<   Less than (New in DUP)
=   Equal to
>   Greater than
```

Examples
```
            data stack
5 3<        [0]     (FALSE)
5 3>        [-1]    (TRUE)
5 3=        [0]     (FALSE)
5 5=        [-1]    (TRUE)
3 3<        [0]     (FALSE)
```

### Variable and numeric address assignemnt, fetch values

**DUP** allows to assign values to variables or numeric addresses. All alphabetic ASCII lowercase characters can be used as variable names. Furthermore, values can also assigned to all positive integer numbers including zero. Assigning values to numeric addresses is also used in string storage (see below).

#### Assign values to variables and numeric addresses

The colon operator `:` is used for value assignment to a variable or address. The proper syntax for assignment is:

`<value> <variable>:` or

`<value> <address>:`

Examples:
```
            variables or addresses
3 a:        a=3
3a: 2z:     a=3, z=2
10 0:9f:    f=9, 0=10, variable f equals 9
```

`:` pops a value from the data stack and assigns it to the variable or address given right before the `:` operator.

#### Fetch value from variables and addresses

The `;` operator is used to fetch values from addresses or variables. The proper syntax for fetching values is:

`<variable>;` or

`<address>;`:

Examples:
```
                            Resulting var/ind   Resulting data stack
3a: a;                      a=3                 [3]
3a: 2z: z;                  a=3, z=2            [2]
3 70: 7 z: 1 0: z; 0; 70;   0=1, 70=3, z=7      [7,1,3]
```

### Single character handling

Single charaters/their Unicode values can be pushed on the data stack by using a preceding single quote `'<character>`:

```
                Resulting data stack
'H'e'l'l'o      ['H','e','l','l','o'] / [72, 101, 108, 108, 111]
```
Input of single characters is done with the backtick character ` ` `. The character is then pushed on the data stack:

```
                data stack
`               ['H']/[72]                (when 'H' was entered in STDIN)
```
Originally, in **FALSE**, the character `^` is used for character input.


### String handling

In **DUP**, strings are not sent to STDOUT directly. Strings are stored in the variable array, using the following syntax: `<start_address>"<string>"`. This stores a string character by caharcter in the variable array, starting at the specified address, assigning the next character to the next address and so on. Finally, the length of the stored string is pushed on the data stack.
In my Julia implementation, assigning strings to an alphabetic start variable, follows the same principle, counting up in alphabetical order. This behavior is different from the [Javascript implementation](http://www.quirkster.com/iano/js/dup.html) at quirkster.com.

Examples:
```
                        data stack          variables
0"str"                  [3]                 0=115, 1=116, 2=114
0"str"^$;1+$;\1+;       [3,'s','t','r']     0=115, 1=116, 2=114
```
To print a string to SDTOUT, you need to append a `$` after the start address and you have to append `\[^^>][$;,1+]#%%` after the ending double quotes.

Example:
```
                            data stack      variables               STDOUT
7$"str"\[^^>][$;,1+]#%%     []              7=115, 8=116, 9=114     str
```

Originally, in **FALSE**, the "string" syntax is used for direct string output to STDOUT.


### Comments

Comments in **DUP** are put between curly braces. Comments can be put anywhere and are ignored by the interpreter.

```
                        data stack
1{sum of 1 and 2}2+     [3]
```

### Conditionals/program flow control

**DUP** has two flow control constructs: `if then else` and a `while loop`:

#### If Then Else

Unlike in **FALSE**, the *if then else* operator `?` takes *two* blocks by default: `condition[true][false]?`, with true meaning every value except `0`. The `true block` is executed if the condition is `not 0/true`, the `false block` is executed if the condition is `0/false`:

```
                data stack
1_['t]['f]?     ['t']/[116]
0 ['t]['f]?     ['f']/[102]
```

The **DUP** equivalent to the old **FALSE** `condition[do if true]?` construct looks like `condition[do if true][]?`, with an empty false block:

```
                data stack
2 1>['t][]?     ['t']               equivalent to FALSE:     2 1>['t]?

2 1<['t][]?     []                  equivalent to FALSE:     2 1>~['t]?
```


#### While Loop

While loops in **DUP** use the `#` operator, using the same syntax as in **FALSE**: `[condition][block]#`.
The `block` is executed until the condition is `0/false`.
Step-by-step Example:

```
                   data stack  return stack       STDOUT
4[$][$.44,1-]#0.
4                  [4]
 [                 [4,1]
    [              [4,1,4]
             #     [4,]        [13,1,4]
  $                [4,4]        
   ]               [4]         [13,1,4,1]
     $             [4,4]
      .            [4]                            4
       44          [4,44]   (44=ASCII for ',')
         ,         [4]                            4,
          1        [4,1]
           -       [3]
            ]      [3]         [13,1,4]
  $                [3,3]
   ]               [3]         [13,1,4,1]
     $             [3,3]
      .            [3]                            4,3
       44          [3,44]   (44=ASCII for ',')
         ,         [3]                            4,3,
     ...
     ...
              #0.  [0]                            4,3,2,1,0
```


### Lambdas, named functions, named operators

#### Lambdas

Lambdas are defined by putting them between square brackets. The definition puts the start of the lambda on the data stack:

```
        data stack
[]      [0]
7[2*]   [7,1]
```

Lambdas are executed by appending a `!` to them:
```
        data stack
7[2*]!  [17]
```

For **FALSE**, this is all there is to know, but the fact that the return stack is accessible in **DUP**, makes it necessary (or at least useful) to know how lambdas are executed in detail.
Let’s have a look at the example again. This time step by step. The `↓` marks the location of the instruction pointer.

```

location    data stack      return stack
012345
↓
7[2*]!      []              []

 ↓
7[2*]!      [7]             []

     ↓
7[2*]!      [7,1]           []

  ↓
7[2*]!      [7]             [5]

   ↓
7[2*]!      [7,2]           [5]

    ↓
7[2*]!      [14]            [5]

      ↓
7[2*]!      [14]            []
```
As you can see, the `!` command pushes the current ip location on the return stack and the ip is set to the location of the lambda start (which is stored on the data stack). This way, the IP knows where to return after executing a lambda. In this simple example it is not ambiguous, but in more complicated setups like nested functions etc. this is essential.
This transparency of the return stack also means that programs can manipulate return addresses. This is explained in the next section.

#### Named functions

Named functions work like lambdas, but can called by their variable name from any place in the program.

Assigning functions to variables is straightforward and works analogous to assigning values to variables.
Define a function `s` that squares numbers:

```
[$*]s:
```
Define a function `f` that halves numbers:
```
[2/\%]f:
```
Call function `s`:
```
s;!
```

Functions can also call other functions. In the next example, function `s` takes function `f` as argument:

```
                            data stack      variables
[f;!$*]s: 7$+ [2/\%]f: s;!  [49]            f=14, s=0
```

To understand the program more easily, put the functions in a more readable order. the `↓` shows the location of the IP after finishing each of the blocks:
```
                            data st.  ret. st.  vars      explanation
7$+ [2/\%]f: [f;!$*]s: s;!
7$+ ↓                       [14]                          put 14 on data stack
    [2/\%]f: ↓              [14]                f=4       define function f: divide argument by 2
             [f;!$*]s: ↓    [14]                f=4,s=13  define function s: call f, square result
              ↓        s;!  [14]      [25]      f=4,s=13  call s
     ↓        f;!           [14]      [25,16]   f=4,s=13  call f
     2/\%]       ↓          [7]       [25]      f=4,s=13  divide by 2
                 $*]      ↓ [49]      []        f=4,s=13  square number, end program
```

Functions can not only call other functions, but also themselves, of course. Here is an example of a recursive program that calculates the faculty of a given number:

```
[$1>[$1-f;!*][%1]?]f: 6f;!
```
It’s up to the reader to figure out how this program works ;)


#### Named operators

**DUP** has an operator to add new operators or to override existing operators. Operator names can, unlike function and variable names, be any Unicode symbol.
Operators are defined by using the syntax `[function]⇒name`. Define a new integer division only operator and apply it:

```
                data stack
[/\%]⇒÷ 10 5÷   [2]
```

At the cost of using the *3-byte unicode character* `⇒` for the operator definition (important to know for code golfing purposes), referencing operators is less costly because they are called just by `N` instead of the 3 bytes long `n;!` *name-fetch-execute* syntax for function calls. `N` and `n` are placeholders for operator and function names.

Minimum costs for definition and calling/referencing operators or functions:

*Function* definition: *2 bytes*: `n:`   Referencing: *3 bytes*: `n;!`
*Operator* definition: *4 bytes*: `⇒N`   Referencing: *1 byte* : `N`

### Return stack/continuation stack manipulation

In **DUP**, the return stack is used for tracing brackets and locations of functions, like in **FALSE**. Unlike in **FALSE** however, the return stack in **DUP** is entirely transparent and can exchange values with the data stack. This way, return addresses can be deleted, changed, or the return stack can be used just as a second data stack.
The `(` operator pops the tompost data stack value and pushes it on the return stack. The operator `(` pops the topmost return stack value and pushes it on the data stack.

Example using the return stack as second stack fro temporary storage:
```
            data Stack          return stack
2 3(4+)
2 3         [2,3]               []
   (        [2]                 [3]
    4       [2,4]               [3]
     +      [6]                 [3]
      )     [6,3]               []
```

Further examples, showing how some operators can be realized with the help of the return stack:
```
($)\                    alternative realization of the OVER operator ^
(\)\                    alternative realization of the ROT operator @
[$[1-\(p;!)\][%$]?]p:   alternative realization of the PICK operator ø
```

## Using DUP

### Preparations

Start with `using DUPEsolang` to load DUP into Julia. The first run might take a few seconds because DUP gets precompiled.

### Load and execute a dup program:

```
dup("program_name.dup")
```

### Run a string representing a DUP program directly:

```
dups("code_string")
```

If running `dups`, take care of escaping the characters `"`, `$` and `\` properly inside the code string. Escape every instance of these caracters as follows: `\"`, `\$`, `\\`.

#### Optional parameters

The `dup` and `dups` commands also take an optional parameter for different program modes:

`dup("program_name.dup","<parameter>")`

Available parameters are:

`"silent"`: The default mode to run a program. This parameter is automatically set if dup/dups are run without parameters.

`"eachstep"`: Outputs a wealth of information about calculated parameters etc.

`"fullstate"`: Outputs the program state (IP location, data stack, return stack, variables) for each program eval operation.

`"ds"`: Outputs the data stack only.
`"vars"`: Outputs the variables only.

### Run DUP code string with final state Outputs

```
duptest("code_string")
```

Basically runs `dups(codestring,"silent")` and returns the program state after the program is finished.
This mode is used for the `runtests.jl` script.

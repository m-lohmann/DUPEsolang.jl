#!/usr/bin/env julia

#Start Test Script
using DUPEsolang
using Test

    tests=[
        ("9"                           ,  [9]               )  ,   # [9]  # number recognition tests
        ("1234"                        ,  [1234]            )  ,   # [1234]
        ("12 34"                       ,  [12,34]           )  ,   # [12,34]
        ("2\$"                         ,  [2,2]             )  ,   # DUP  # stack manipulation tests
        ("1%"                          ,  []                )  ,   # POP
        ("1 2^"                        ,  [1,2,1]           )  ,   # OVER
        ("1 7\\"                       ,  [7,1]             )  ,   # FLIP
        ("1 2 3@"                      ,  [2,3,1]           )  ,   # ROT
        ("5 4 3 2 1 4ø"                ,  [5,4,3,2,1,5]     )  ,   # PICK 4th item, 1 = 0th item
        ("3 0ø\\\$\\%="                ,  [-1]              )  ,   # equivalence test 0ø=DUP
        ("2 3 1ø@@^\\%\\%="            ,  [-1]              )  ,   # equivalence test 1ø=OVER
        ("5 3+"                        ,  [8]               )  ,   # ADD  # arithmetic
        ("5 3-"                        ,  [2]               )  ,   # SUB
        ("5 3*"                        ,  [15]              )  ,   # MULT
        ("5 3/"                        ,  [2,1]             )  ,   # MOD,DIV
        ("5_"                          ,  [-5]              )  ,   # negate
        ("5 3&"                        ,  [1]               )  ,   # 101 AND 011  # bit manipulation
        ("5 3|"                        ,  [6]               )  ,   # 101 XOR 011
        ("0~"                          ,  [-1]              )  ,   # NOT 0
        ("136 3»"                      ,  [17]              )  ,   # LSR >>>: 136>>>3=17
        ("17 3«"                       ,  [136]             )  ,   # ASL << : 17<<3=136
        ("5 3<"                        ,  [0]               )  ,   # 5<3 = false  # comparisons
        ("5 3>"                        ,  [-1]              )  ,   # 5>3 = true
        ("5 5="                        ,  [-1]              )  ,   # 5=5 = true
        ("5 3="                        ,  [0]               )  ,   # equality check for unequal values
        ("8 8>"                        ,  [0]               )  ,   # unequality check for equal values
        ("3a:2z: 6a;z;"                ,  [6,3,2]           )  ,   # a=3, z=2, [6,a,z]  # variable and index assignment
        ("3 70: 7 z: 1 0: z; 0; 70;"   ,  [7,1,3]           )  ,   # 70=3, z=7, 0=1, [7,1,3]
        ("'0"                          ,  [48]              )  ,   # '0' or 48  # char output
        ("'a'b'c"                      ,  [97,98,99]        )  ,
        ("'a'b,'c'd,'e'f"              ,  [97,99,101,102]   )  ,
        ("0\$\"abc\""                  ,  [0,3]             )  ,                # string handling
        ("0\$\"str\"^\$;\\1+\$;\\1+;"  ,  [0,3,115,116,114] )  ,   # store string "str" in vars, fetch values.
        ("1{123\$}1="                  ,  [-1]              )  ,   # jump over comment, store jump in array s.ah
        ("{}"                          ,  []                )  ,
        ("1 2 3(4)"                    ,  [1,2,4,3]         )  ,   # data stack/return stack check    # parenthesis test - access to return stack
        ("[]"                          ,  [0]               )  ,   # empty lambda   # square brackets - lambdas
        ("1[2*]!"                      ,  [2]               )  ,   # execute lambda n=1 n->2*n
        ("0['t]['f]?"                  ,  [102]             )  ,   #  0=true ? ['t] : ['f] => false   # if-then-else
        ("1_['t]['f]?"                 ,  [116]             )  ,   # -1=true ? ['t] : ['f] => true
        ("5_['t]['f]?"                 ,  [116]             )  ,   # -5=true ?
        ("5['t]['f]?"                  ,  [116]             )  ,   #  5=true ?
        ("[\$1>[\$1-f;!*][%1]?]f: 6f;!",  [720]             )  ,   # recursive function, 6!=720   # recursive functions, function assignment and recursive execution
        ("3[\$][\$1-]#"                ,  [3,2,1,0]         )  ,   # while [$]>0 do[$1-]   # while condition != 0 do block
        ("[\$*]⇒²9²"                   ,  [81]              )  ,   # define new square operator, apply 9²=81   # operator definiton and overriding test
        ("[/\\%]⇒÷ 6 3÷"               ,  [2]               )  ,   # define new divide only operator; apply 6÷3=2
        ("[^~&|]⇒V 0 0V 0 1_V 1_0V1_1_V", [0,-1,-1,-1]      )  ,   # define new OR operator; test all combinations
        ("[2*]⇒B[1+B]⇒A 1A"            ,  [4]               )  ,   # nested operator definitions
        ("[1ø]⇒^ 2 1^"                 ,  [2,1,2]           )     # substitute existing OVER with (equivalent) 1ø
    ]
    for t in tests
        @test duptest(t[1]).ds==t[2]
    end

    #separate tests for vars checks

    tests2=[
        ("0\$\"abc\""                 ,  Dict(0=>97, 1=>98, 2=>99)) ,        # string handling vars check
        ("[1ø]⇒^3\$\"str\"^\$;\\1+\$;\\1+;" ,  Dict(3=>115, 4=>116, 5=>114))
    ]
    for t in tests2
        @test duptest(t[1]).vars==t[2]
    end

    @test 1==1

#!/usr/bin/env julia

#Start Test Script
using DUPEsolang
using Base.Test


# Run tests
@testset "dup number recognition tests" begin
    tests=Dict(
        "9"                           =>  [9]                 ,   # [9]
        "1234"                        =>  [1234]              ,   # [1234]
        "12 34"                       =>  [12,34]                 # [12,34]
    )
    for t in keys(tests)
        @test duptest(t).ds==tests[t]
    end
end

@testset "dup stack manipulation tests" begin
    tests=Dict(
        "2\$"                         =>  [2,2]               ,   # DUP
        "1%"                          =>  []                  ,   # POP
        "1 2^"                        =>  [1,2,1]             ,   # OVER
        "1 7\\"                       =>  [7,1]               ,   # FLIP
        "1 2 3@"                      =>  [2,3,1]             ,   # ROT
        "5 4 3 2 1 4ø"                =>  [5,4,3,2,1,5]       ,   # PICK 4th item, 1 = 0th item
        "3 0ø\\\$\\%="                =>  [-1]                ,   # equivalence test 0ø=DUP
        "2 3 1ø@@^\\%\\%="            =>  [-1]                    # equivalence test 1ø=OVER
    )
    for t in keys(tests)
        @test duptest(t).ds==tests[t]
    end
end

@testset "dup arithmetic tests" begin
    tests=Dict(
        "5 3+"                        =>  [8]                 ,   # ADD
        "5 3-"                        =>  [2]                 ,   # SUB
        "5 3*"                        =>  [15]                ,   # MULT
        "5 3/"                        =>  [2,1]               ,   # MOD,DIV
        "5_"                          =>  [-5]                    # negate
    )
    for t in keys(tests)
        @test duptest(t).ds==tests[t]
    end
end

@testset "dup logic and bit manipulation tests" begin
    tests=Dict(
        "5 3&"                        =>  [1]                 ,   # 101 AND 011
        "5 3|"                        =>  [6]                 ,   # 101 XOR 011
        "0~"                          =>  [-1]                ,   # NOT 0
        "136 3»"                      =>  [17]                ,   # LSR >>>: 136>>>3=17
        "17 3«"                       =>  [136]                   # ASL << : 17<<3=136
    )
    for t in keys(tests)
        @test duptest(t).ds==tests[t]
    end
end

@testset "dup comparison tests" begin
    tests=Dict(
        "5 3<"                        =>  [0]                 ,   # 5<3 = false
        "5 3>"                        =>  [-1]                ,   # 5>3 = true
        "5 5="                        =>  [-1]                ,   # 5=5 = true
        "5 3="                        =>  [0]                 ,   # equality check for unequal values
        "8 8>"                        =>  [0]                     # unequality check for equal values                      =>  [0]                 ,   # for equal values
    )
    for t in keys(tests)
        @test duptest(t).ds==tests[t]
    end
end

@testset "dup variable and index assignemnt tests" begin
    tests=Dict(
        "3a:2z: 6a;z;"                =>  [6,3,2]             ,   # a=3, z=2, [6,a,z]
        "3 70: 7 z: 1 0: z; 0; 70;"   =>  [7,1,3]                 # 70=3, z=7, 0=1, [7,1,3]
    )
    for t in keys(tests)
        @test duptest(t).ds==tests[t]
    end
end

@testset "dup char output and string handling/output tests" begin
    tests=Dict(
        "'0"                          =>  ['0']               ,   # '0' or 48
        "'a'b'c"                      =>  ['a','b','c']       ,
        "'a'b,'c'd,'e'f"              =>  ['a','c','e','f']   ,
        "0\$\"abc\""                  =>  [0,3]               ,
        "0\$\"str\"^\$;\\1+\$;\\1+;"  =>  [0,3,115,116,114]       # store string "str" in vars, fetch values.
    )
    for t in keys(tests)
        @test duptest(t).ds==tests[t]
    end
end

@testset "dup string handling variables storage test" begin
    tests=Dict(
        "0\$\"abc\""                  =>  Dict(0=>97, 1=>98, 2=>99) ,
        "3\$\"str\"^\$;\\1+\$;\\1+;"  =>  Dict(3=>115, 4=>116, 5=>114)
    )
    for t in keys(tests)
        @test duptest(t).vars==tests[t]
    end
end

@testset "dup comment test" begin
    tests=Dict(
        "1{123\$}1="                  =>  [-1]                ,  # jump over comment, store jump in array s.ah
        "{}"                          =>  []
    )
    for t in keys(tests)
        @test duptest(t).ds==tests[t]
    end
end

@testset "dup parenthesis test, access to return stack" begin
    tests=Dict(
        "1 2 3(4)"                    =>  [1,2,4,3]             # data stack/return stack check
    )
    for t in keys(tests)
        @test duptest(t).ds==tests[t]
    end
end

@testset "dup square bracket test, lambdas" begin
    tests=Dict(
        "[]"                          =>  [0]                 ,   # empty lambda
        "1[2*]!"                      =>  [2]                     # execute lambda n=1 n->2*n
    )
    for t in keys(tests)
        @test duptest(t).ds==tests[t]
    end
end

@testset "dup if/then test" begin
    tests=Dict(
        "0['t]['f]?"                  =>  ['f']               ,   #  0=true ? ['t] : ['f] => false
        "1_['t]['f]?"                 =>  ['t']               ,   # -1=true ? ['t] : ['f] => true
        "5_['t]['f]?"                 =>  ['t']               ,   # -5=true ?
        "5['t]['f]?"                  =>  ['t']                   #  5=true ?
    )
    for t in keys(tests)
        @test duptest(t).ds==tests[t]
    end
end

@testset "dup recursion test: if/then inside function, recursive call to function inside if/then" begin
    tests=Dict(
        "[\$1>[\$1-f;!*][%1]?]f: 6f;!"=>  [720]                   # recursive function, 6!=720
    )
    for t in keys(tests)
        @test duptest(t).ds==tests[t]
    end
end

@testset "dup while >0 do test: count down in a while loop from 3 to 0" begin
    tests=Dict(
        "3[\$][\$1-]#"                =>  [3,2,1,0]               # while [$]>0 do[$1-]
    )
    for t in keys(tests)
        @test duptest(t).ds==tests[t]
    end
end

@testset "dup operator definition/overriding test: define unicode symbols as operators" begin
    tests=Dict(
        "[\$*]⇒²9²"                   =>  [81]               ,   # define new square operator, apply 9²=81
        "[/\\%]⇒÷ 6 3÷"               =>  [2]                ,   # define new divide only operator; apply 6÷3=2
        "[^~&|]⇒V 0 0V 0 1_V 1_0V1_1_V"=> [0,-1,-1,-1]           # define new OR operator; test all combinations

    )
    for t in keys(tests)
        @test duptest(t).ds==tests[t]
    end
end

@testset "default test" begin
    @test 1==1
end

type State
    ip::Int64
    ah::Array{Int64}
    vars::Dict{Any,Int64}
    ds::Array{Int64}      #data stack, able to hold Chars and Ints
    rs::Array{Int64}      #return stack, able to hold Chars and Ints
    code::Array{Char}

    function State()
        new(Int64(0),Int64[],Dict{Any,Int64}(),Union{Char,Int64}[],Union{Char,Int64}[],Char[])
    end
end


"""
`dup("program_name")` loads the program `program_name` and executes it.
Equivalent to `dup("program_name",0,"slient")`.

Optional use:

`dup("program_name","program_mode")`

Available program modes are:

  `"silent"` - the default mode. The program runs normally without giving extra information.

  `"eachstep"` - verbose information about executed commands and partial program state information.

  `"fullstate"` - full program state information.

  `"ds"` - data stack information.

  `"vars"` - variables information.

Setting step limit:

 `dup("program_name",lim::Int,"program_mode")` runs the program for `lim` steps in the mode `program_mode`.

 `dup("program_name",lim::Int)` runs the program for `lim` steps in `silent` mode.

"""
function dup(name::AbstractString)
    dup(name,0,"silent")
end

function dup(name::AbstractString,modus::AbstractString)
    dup(name,0,modus)
end

function dup(name::AbstractString,lim::Int)
    dup(name,lim,"silent")
end

function dup(name::AbstractString,lim::Int,modus::AbstractString)
    codestring=load(name)
    dups(codestring,lim,modus)
end


"""
`dups("code_string")` loads the string `code_string` as DUP program and executes it.
    Proper escaping of the characters `\"`, `\$` and `\\` is necessary to run a string successfully:
    Escape every instance of these caracters as follows: `\\\"`, `\\\$`, `\\\\`.

Optional use:

`dups("code_string","program_mode")`

Available program modes are:

  `"silent"` - the default mode. The program runs normally without giving extra information.

  `"eachstep"` - verbose information about executed commands and partial program state information.

  `"fullstate"` - full program state information.

  `"ds"` - data stack information.

  `"vars"` - variables information.

Setting step limit:

`dups("program_name",lim::Int,"program_mode")` runs the code string for `lim` steps in the mode `program_mode`.

"""

function dups(codestring::AbstractString)
    dups(codestring,0,"silent")
end

function dups(codestring::AbstractString,lim::Int)
    dups(codestring,lim,"silent")
end

function dups(codestring::AbstractString,modus::AbstractString)
    dups(codestring,0,modus)
end

function dups(codestring::AbstractString,lim::Int,modus::AbstractString)
    s=initstate(codestring,lim,modus)
    rundup(s)
end


"""
`duptest("code_string")` loads the string `code_string` as DUP program and executes it.
    After execution the final program state is returned. Used for testing in runtests.jl.
"""
function duptest(codestring::AbstractString)
    dups(codestring,0,"silent")
    return s
end

function load(name::AbstractString)
    prog=open(name)
    cstring=readchomp(prog)
    close(prog)
    return cstring
end


#   initialize program state
function initstate(codestring::AbstractString,lim::Int,modus::AbstractString)
    global s = State()
    global mode = modus
    global limit = lim
    ini(s,codestring)
    return s
end

# initial program state values
function ini(state::State,codestring::AbstractString)
    state.ip    = 0                     #initialized
    state.vars  = Dict{Any,Int64}()
    state.ds    = sizehint!(Int64[],2048)
    state.rs    = sizehint!(Int64[],2048)
    state.code  = collect(codestring)
    state.ah    = ahead(state.code)
end

#run loop
function rundup(s)
    if s.ip >= length(s.code)
        #error("end of program")
        return
    end
    counter=1
    @inbounds while s.ip<length(s.code)
        evalcode(s)
        #mode=="laststate" ? (return s) :
        mode=="eachstep"  ? println("--- $counter ---") :
        mode=="fullstate" ? stateprint(counter) :
        mode=="ds"        ? (return s.ds):
        mode=="vars"      ? (return s.vars):
        mode=="silent"    ? nothing : nothing
        counter+=1
        limit !=0 && counter > limit ? break :
        limit ==0 ? nothing : nothing
    end
end

#print state info
function stateprint(counter)
    if s.ip<=length(s.code)-1
        print_with_color(:blue,"\n---- state ----")
        print_with_color(:blue,"\n -- $counter --\n")
        for i=1:length(s.code)
            i==s.ip+1 ? print_with_color(:blue,string(s.code[i])) : print(s.code[i])
        end
        println()
        println("ip: $(s.ip)")
        println("ds: $(s.ds)")
        println("rs: $(s.rs)")
        println("vars:")
        for (j,k) in s.vars
            println("$j → $k")
        end
    end
end

function evalcode(s)
    standardops=['$','%','ø','^','\\','@','(',')','+','-','*','/','_','«','»','&','|','~',
                 '>','<','=',':',';','\'','\"','{','}','[',']','!','?','#','`',',','.','ß',
                 '⇒','§']

    c=s.code[s.ip+1]
    mode=="eachstep"||mode=="fullstate" ? println("ev, c: $c") : nothing
    if c in standardops                  # check Dict with instructions
        #mode=="eachstep"||mode=="fullstate" ? println("ev key: $(c) => $(o[c])") : nothing
        operator(rcode(s),s)
    elseif isdigit(c)                       # parse number string
        num=0
        while isdigit(s.code[s.ip+1])
            num=10*num+parse(Int64,s.code[s.ip+1],10)
            if s.ip+1 == length(s.code)
                s.ip+=1;break
            else s.ip+=1
            end
        end
        push!(s.ds,num)
        mode=="eachstep"||mode=="fullstate" ? println("ev, ip++: $(s.ip)") : nothing
        mode=="eachstep"||mode=="fullstate" ? println(s.ds): nothing
        return
    elseif ismatch(r"\s",string(c))     # parse whitespace
        while ismatch(r"\s",string(s.code[s.ip+1])) && s.ip<length(s.code)
            s.ip+=1
            if s.ip==length(s.code)
                break
            end
        end
        mode=="eachstep"||mode=="fullstate" ? println("ev, ip++: $(s.ip)") : nothing
        mode=="eachstep"||mode=="fullstate" ? println(s.ds): nothing
        return
    else                                # if c is anything else
        push!(s.ds,c)                   # i.e. ascii and unicode charaters
    end                                 # for variable and operator definition
    s.ip+=1
    mode=="eachstep"||mode=="fullstate" ? println("ev, ip++: $(s.ip)") : nothing
    mode=="eachstep"||mode=="fullstate" ? println(s.ds): nothing
end

function rcode(s::State)
    #s.code[rind(s.ip)]
    s.code[s.ip+1]
end

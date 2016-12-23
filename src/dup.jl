type State
    ip::Int64
    ah::Array{Int64}
    vars::Dict{Any,Int64}
    ds::Array{Union{Char,Int64},1}      #data stack, able to hold Chars and Ints
    rs::Array{Union{Char,Int64},1}      #return stack, able to hold Chars and Ints
    code::Array{Char}

    function State()
        new(Int64(0),Int64[],Dict{Any,Int64}(),Union{Char,Int64}[],Union{Char,Int64}[],Char[])
    end
end


"""
`dup("program_name")` loads the program `program_name` and executes it.

Optional use:

`dup("program_name","program_mode")`

Available program modes are:

  `"silent"` - the default mode. The program runs normally without giving extra information.

  `"eachstep"` - verbose information about executed commands and partial program state information.

  `"fullstate"` - full program state information.

  `"ds"` - data stack information.

  `"vars"` - variables information.
"""
function dup(name::String,modus="silent")
    codestring=load(name)
    dups(codestring,modus)
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
"""
function dups(codestring::String,modus="silent")
    s=initstate(codestring,modus)
    rundup(s,o)
end

"""
`duptest("code_string")` loads the string `code_string` as DUP program and executes it.
    After execution the final program state is returned. Used for testing in runtests.jl.
"""
function duptest(codestring::String)
    dups(codestring,"silent")
    return s
end

function load(name::AbstractString)
    prog=open(name)
    cstring=readchomp(prog)
    close(prog)
    return cstring
end


#   initialize program state
function initstate(codestring::AbstractString,modus)
    global s = State()
    global mode = modus
    ini(s,codestring)
    return s
end

# initial program state values
function ini(state::State,codestring::String)
    state.ip    = 0                     #initialized
    state.vars  = Dict{Any,Int64}()
    state.ds    = sizehint!(Union{Char,Int64}[],2048)
    state.rs    = sizehint!(Union{Char,Int64}[],2048)
    state.code  = collect(codestring)
    state.ah    = ahead(state.code)
end

#run loop
function rundup(s,o)
    if s.ip >= length(s.code)
        #error("end of program")
        return
    end
    counter=1
    @inbounds while s.ip<length(s.code)
        evalcode(s,o)
        #mode=="laststate" ? (return s) :
        mode=="eachstep"  ? println("--- $counter ---") :
        mode=="fullstate" ? stateprint(counter) :
        mode=="ds"        ? (return s.ds):
        mode=="vars"      ? (return s.vars):
        mode=="silent"    ? nothing : nothing
        counter+=1
        counter>1e4 ? break : nothing
    end
end

function stateprint(counter)
    println("--- $counter ---")
    println("ip: $(s.ip), code: $(s.code[s.ip+1])")
    println("ds: $(s.ds)")
    println("rs: $(s.rs)")
    println("vars:")
    for (j,k) in s.vars
        println("$j → $k")
    end
end

function evalcode(s,o)
    c=s.code[s.ip+1]
    mode=="eachstep"||mode=="fullstate" ? println("ev, c: $c") : nothing
    if haskey(o,c)                  # check Dict with instructions
        mode=="eachstep"||mode=="fullstate" ? println("ev key: $(c) => $(o[c])") : nothing
        eval(@eval o[rcode(s)])
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
        while ismatch(r"\s",string(s.code[s.ip+1]))
            s.ip+=1
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

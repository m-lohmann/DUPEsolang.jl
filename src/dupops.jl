function operator(oc::Char,s)
    oc=='$' ? (dup(s)) :
    oc=='%' ? (del(s)) :
    oc=='ø' ? (pick(s)) :
    oc=='^' ? (over(s)) :
    oc=='\\' ? (swap(s)) :
    oc=='@' ? (rot(s)) :
    oc=='(' ? (tors(s)) :
    oc==')' ? (tods(s)) :
    oc=='+' ? (add(s)) :
    oc=='-' ? (sub(s)) :
    oc=='*' ? (mul(s)) :
    oc=='/' ? (moddiv(s)) :
    oc=='_' ? (negate(s)) :
    oc=='«' ? (asl(s)) :
    oc=='»' ? (lsr(s)) :
    oc=='&' ? (and_op(s)) :
    oc=='|' ? (xor_op(s)) :
    oc=='~' ? (not_op(s)) :
    oc=='>' ? (greaterthan(s)) :
    oc=='<' ? (lessthan(s)) :
    oc=='=' ? (equals(s)) :
    oc==':' ? (varpush(s)) :
    oc==';' ? (varassign(s)) :
    oc=='\'' ? (charpush(s)) :
    oc=='\"' ? (getstring(s)) :
    oc=='{' ? (opencurl(s)) :
    oc=='}' ? (closecurl(s)) :
    oc=='[' ? (openbracket(s)) :
    oc==']' ? (closebracket(s)) :
    oc=='!' ? (execute(s)) :
    oc=='?' ? (ifthenelse(s)) :
    oc=='#' ? (whiletrue(s)) :
    oc=='`' ? (inputchar(s)) :
    oc==',' ? (outputchar(s)) :
    oc=='.' ? (outputint(s)) :
    oc=='ß' ? (flush()) :
    oc=='⇒' ? (opassign(s,newops)) :
    oc=='§' ? (debugprint()) :
    nothing
end

dup(s) = push!(s.ds,s.ds[end])

del(s) = pop!(s.ds)

function pick(s)
    n=pop!(s.ds)
    push!(s.ds,s.ds[end-n])
end

over(s) = push!(s.ds,s.ds[end-1])

swap(s) = push!(s.ds,splice!(s.ds,length(s.ds)-1))

rot(s) = push!(s.ds,splice!(s.ds,length(s.ds)-2))

tors(s) =  push!(s.rs,pop!(s.ds))

tods(s) =  push!(s.ds,pop!(s.rs))

add(s) = push!(s.ds,pop!(s.ds)+pop!(s.ds))

sub(s) = push!(s.ds,-pop!(s.ds)+pop!(s.ds))

mul(s) = push!(s.ds,pop!(s.ds)*pop!(s.ds))

function moddiv(s)
    a=s.ds[end-1]
    b=s.ds[end]
    s.ds[end-1]=a%b
    s.ds[end]=div(a,b)
end

function negate(s)
    s.ds[end]=-s.ds[end]
end

function asl(s)
    ls=pop!(s.ds)
    push!(s.ds,pop!(s.ds)<<ls)
end

function lsr(s)
    rs=pop!(s.ds)
    push!(s.ds,pop!(s.ds)>>>rs)
end

and_op(s) = push!(s.ds,pop!(s.ds)&pop!(s.ds))

xor_op(s) = push!(s.ds,pop!(s.ds) ⊻ pop!(s.ds))

not_op(s) = push!(s.ds,~pop!(s.ds))

function greaterthan(s)
    pop!(s.ds) < pop!(s.ds) ? push!(s.ds,-1) : push!(s.ds,0)
end

function lessthan(s)
    pop!(s.ds) > pop!(s.ds) ? push!(s.ds,-1) : push!(s.ds,0)
end

function equals(s)
    pop!(s.ds) == pop!(s.ds) ? push!(s.ds,-1) : push!(s.ds,0)
end

function varpush(s)
    a=pop!(s.ds)
    if typeof(a)==Int
        s.vars[a]=pop!(s.ds)
    elseif isalpha(a) && isascii(a) && Int(a)<=122
        s.vars[a]=pop!(s.ds)
    else error("Illegal variable assignment '$a'.")
    end
end

varassign(s) = push!(s.ds,s.vars[pop!(s.ds)])

function charpush(s)
    push!(s.ds,Int64(s.code[s.ip+2]))
    s.ip+=1
end

function getstring(s)
    ind=pop!(s.ds) #varname/index
    typeof(ind)==Char ? error("Illegal assignment of string to character variable!") : nothing
    s.ip+=1
    start=s.ip
    @inbounds for s.ip=start:s.ah[start]-1
        s.vars[ind]=Int64(s.code[s.ip+1])
        ind+=1
    end
    s.ip+=1
    push!(s.ds,s.ip-start)
    if mode=="eachstep"||mode=="fullstate"
        a=sort(collect(s.vars))
        println("vars:")
        for n=1:length(a)
            println("$(a[n][1]) → $(a[n][2])")
        end
        println("string length: $(s.ds[end])")
    end
end

function opencurl(s)
    s.ip=s.ah[s.ip+1]
end

closecurl(s) = error("Unmatched '}' at address $(s.ip).")

function openbracket(s)
    push!(s.ds,Int64(s.ip))
    s.ip=s.ah[s.ip+1]
end

function closebracket(s)
    n=length(s.rs)-3
    if (n>=0)
        if (s.code[s.rs[n+1]+1]== '#')
            pop!(s.ds)!=0 ? mpush!(s.rs,s.rs[n+1+1],s.rs[n+2+1]) : mpop!(s.rs,2)
        end
    else
        mode=="eachstep"||mode=="fullstate" ? println("length s.rs = $(n+3) < 3") : nothing
    end
    s.ip=pop!(s.rs)
    mode=="eachstep"||mode=="fullstate" ? println("ip=pop!(rs)=$(s.ip)") : nothing
end

function execute(s)
    push!(s.rs,s.ip)
    s.ip=pop!(s.ds)
end

function ifthenelse(s)
    f=pop!(s.ds)        #false lambda bracket location
    t=pop!(s.ds)        #true  lambda bracket location
    push!(s.rs,s.ip)    #return address of '?'
    pop!(s.ds) == 0 ? s.ip=f : s.ip=t
end

# Handle [condition][do if condition !=0]# instruction
function whiletrue(s)
    mpush!(s.rs,s.ip,s.ds[end-1],pop!(s.ds)) # s.rs -> [..., ip, ds(end-1), ds(end)]
    s.ip=pop!(s.ds)
end

inputchar(s) = push!(s.ds,getchar())

function getchar()
    input=readline(STDIN)
    inp=Int64(input[1])
end

outputchar(s) = print(Char(pop!(s.ds)))

outputint(s) = print("$(Int64(pop!(s.ds)))")

flush() = nothing

function opassign(s,newops)
    oploc=pop!(s.ds)
    s.ip+=1
    if isempty(s.no)
        s.no=[s.code[s.ip+1] oploc]
        newops=[s.code[s.ip+1]]
    else
        if isempty(findin(s.no,s.code[s.ip+1])) #if op does not exist yet in no
            s.no=vcat(s.no,[s.code[s.ip+1] oploc])
            push!(newops,s.code[s.ip+1])
        else                                    #if op exists in no...
            s.no[findin(s.no,s.code[s.ip+1]),2]=oploc   #...overwrite op location
        end
    end
end

# print debug info, non-standard operator
function debugprint()
    if s.ip<=length(s.code)-1
        print_with_color(:blue,"\n--- debug info ---\n")
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
        println("new ops:")
        for i=1:length(s.no[:,1])
            println("$(s.no[i,1]) → $(s.no[i,2])")
        end
    end
end

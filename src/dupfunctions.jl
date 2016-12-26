function varpush(s)
    a=pop!(s.ds)
    if typeof(a)==Int
        s.vars[a]=pop!(s.ds)
    elseif isalpha(a) && isascii(a) && Int(a)<=122
        s.vars[a]=pop!(s.ds)
    else error("Illegal variable assignment '$a'.")
    end
end


# Store string character by character in s.vars Dict.
function getstring(s)
    ind=pop!(s.ds) #varname/index
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

# ` input character
function getchar()
    input=readline(STDIN)
    inp=Char(input[1])
end

function matchbrace(s)
    return s.ah[s.ip+1]
end

function ahead(code::Array)
	bracketstack=[]
    ah=zeros(Int64,length(code))

    @inbounds for ip=0:length(code)-1
		c=code[ip+1]
		if c=='['
			push!(bracketstack,ip)
		elseif c==']'
            if bracketstack==[]
                error("Unmatched open ']' @ $(ip)!")
            else
                ah[pop!(bracketstack)+1]=ip
            end
		end
	end
    if bracketstack !=[]
        for i=1:length(bracketstack)
            println("Unmatched '[' @ $(bracketstack[i])!")
        end
    end

    # curly braces can’t be nested
    a=0
    i=indexin(code,['{','}'])
    @inbounds for ip=0:length(i)-1
    	i[ip+1]==1? a=ip:
    	i[ip+1]==2? (ah[a+1]=ip;a=ip):nothing
    end

    #double quotes
    a=-1
    @inbounds for ip=0:length(i)-1
    	if code[ip+1]=='\"'
    		if a==-1
    			a=ip
    		else
    			ah[a+1]=ip
    			a=-1
    		end
    	end
    end
    return ah
end


function closedbracket(s)
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


# push multiple values on stack a, analogous to JS
function mpush!(a,val...)
    @inbounds for v in val
        push!(a,v)
    end
end


# pop multiple items from stack a
function mpop!(a,n)
    if n<= length(a)
        @inbounds for i=1:n
            pop!(a)
        end
    else error("Can’t pop more values ($n) than exist ($(length(a))).")
    end
end

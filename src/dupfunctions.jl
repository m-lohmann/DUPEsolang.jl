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
        i[ip+1]==2? (ah[a+1]=ip;a=ip) : nothing
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

o=Dict(
    '$' =>  :(push!(s.ds,s.ds[end])),
    '%' =>  :(pop!(s.ds)),
    'ø' =>  :(n=pop!(s.ds);push!(s.ds,s.ds[end-n])),
    '^' =>  :(push!(s.ds,s.ds[end-1])),
    '\\'=>  :(push!(s.ds,splice!(s.ds,length(s.ds)-1))),
    '@' =>  :(push!(s.ds,splice!(s.ds,length(s.ds)-2))),
    '(' =>  :(push!(s.rs,pop!(s.ds))),
    ')' =>  :(push!(s.ds,pop!(s.rs))),
    '+' =>  :(push!(s.ds,pop!(s.ds)+pop!(s.ds))),
    '-' =>  :(push!(s.ds,-pop!(s.ds)+pop!(s.ds))),
    '*' =>  :(push!(s.ds,pop!(s.ds)*pop!(s.ds))),
    '/' =>  :(a=s.ds[end-1];b=s.ds[end];s.ds[end-1]=a%b;s.ds[end]=div(a,b)),
    '_' =>  :(s.ds[end]=-s.ds[end]),
    '«' =>  :(ls=pop!(s.ds);push!(s.ds,pop!(s.ds)<<ls)),
    '»' =>  :(rs=pop!(s.ds);push!(s.ds,pop!(s.ds)>>>rs)),
    '&' =>  :(push!(s.ds,pop!(s.ds)&pop!(s.ds))),
    '|' =>  :(push!(s.ds,pop!(s.ds)$pop!(s.ds))),
    '~' =>  :(push!(s.ds,~pop!(s.ds))),
    '<' =>  :(pop!(s.ds)> pop!(s.ds)?push!(s.ds,-1):push!(s.ds,0)),
    '=' =>  :(pop!(s.ds)==pop!(s.ds)?push!(s.ds,-1):push!(s.ds,0)),
    '>' =>  :(pop!(s.ds)< pop!(s.ds)?push!(s.ds,-1):push!(s.ds,0)),
    ':' =>  :(varpush(s)),
    ';' =>  :(push!(s.ds,s.vars[pop!(s.ds)])),
    '\''=>  :(push!(s.ds,s.code[s.ip+2]);s.ip+=1),
    '\"'=>  :(getstring(s)),
    '{' =>  :(s.ip=s.ah[s.ip+1]),
    '}' =>  :(error("Unmatched '}' at address $(s.ip).")),
    '[' =>  :(push!(s.ds,Int64(s.ip));s.ip=s.ah[s.ip+1]),
    ']' =>  :(closedbracket(s)),
    '!' =>  :(push!(s.rs,s.ip);s.ip=pop!(s.ds)),
    '?' =>  :(ifthenelse(s)),
    '#' =>  :(whiletrue(s)),
    '`' =>  :(push!(s.ds,getchar())),
    ',' =>  :(print(Char(pop!(s.ds)))),
    '.' =>  :(print("$(pop!(s.ds))")),
    'ß' =>  :(nothing),
    # define new operators or override existing ones:
    '⇒' =>  :(op=pop!(s.ds);s.ip+=1;o[s.code[s.ip+1]]= :(push!(s.rs,s.ip);s.ip=$op)),
    # nonstandard debug operator, can be overridden
    '§' =>  :(debugprint())
)

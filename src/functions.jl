"""
    isequal(p::Node, q::Node)

Return `true` if node `p` equals node `q`.
Two nodes are equal if their indices (`i`) match.
"""
Base.isequal(p::Node, q::Node) = isequal(p.i, q.i)



"""
    isopen(n::Node)
    
Returns `true` if node `n` is open.
A `Node` is defined open if it is not being served.
"""
isopen(n::Node) = iszero(n.t) && iszero(n.h)
"""
    isclose(n::Node)
    
Returns `true` if node `n` is not open.
A `Node` is defined open if it is not being served.
"""
isclose(n::Node) = !isopen(n)



"""
    vectorize(s::Solution)

Returns `Solution` as a list of nodes in the order of visit.
"""
function vectorize(s::Solution)
    N = s.N
    V = Int64[]
    if all(isopen, N) return V end
    i  = findfirst(isclose.(N))
    nₒ = N[i]
    nₜ = nₒ
    nₕ = N[nₜ.h]
    push!(V, nₒ.i)
    while true
        push!(V, nₕ.i)
        if isequal(nₕ, nₒ) break end
        nₜ = nₕ
        nₕ = N[nₜ.h]
    end
    return V
end
"""
    hash(s::Solution)

Returns hash on vectorized `Solution`.
"""
Base.hash(s::Solution) = hash(vectorize(s))



"""
    f(s::Solution)

Returns objective function value (solution cost).
"""
f(s::Solution) = s.r.c



"""
    isfeasible(s::Solution)

Returns `true` if node service constraint, node flow constraint, and
sub-tour elimination constraint are not violated.
"""
function isfeasible(s::Solution) 
    N  = s.N
    X  = zeros(Int64, length(N))
    nₒ = N[1]
    while true
        k = nₒ.i
        if isone(X[k]) break end
        X[k] = 1
        nₒ = N[nₒ.h]
    end
    if any(iszero, X) return false end
    return true
end
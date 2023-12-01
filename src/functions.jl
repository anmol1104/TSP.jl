"""
    isequal(p::Node, q::Node)

Return `true` if node `p` equals node `q`.
Two nodes are equal if their indices (`i`) match.
"""
Base.isequal(p::Node, q::Node) = isequal(p.i, q.i)



"""
    isopen(n::Node)
    
Returns `true` if node `n` is open.
A `Node` is defined open if it is not being serviced.
"""
isopen(n::Node) = iszero(n.t) && iszero(n.h)
"""
    isclose(n::Node)
    
Returns `true` if node `n` is closed.
A `Node` is defined closed if it is being serviced.
"""
isclose(n::Node) = !isopen(n)



"""
    vectorize(s::Solution)

Returns `Solution` as a list of nodes in the order of visit.
"""
function vectorize(s::Solution)
    N = s.N
    V = Int[]
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
f(s::Solution) = s.c



"""
    isfeasible(s::Solution)

Returns `true` if all nodes are served on the route.
"""
isfeasible(s::Solution) = all(isclose, s.N)



"""
    relatedness(n¹::Node, n²::Node, s::Solution)

Returns a measure of similarity between nodes `n¹` and `n²` in solution `s`.
"""
function relatedness(n¹::Node, n²::Node, s::Solution)
    ϵ  = 1e-5
    φ  = 1
    q  = 0
    l  = s.A[(n¹.i,n².i)].c
    t  = 0
    z  = φ/(q + l + t + ϵ)
    return z
end
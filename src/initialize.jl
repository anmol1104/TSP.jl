"""
    initialsolution([rng], G, method)

Returns initial TSP solution using the given `method` for graph `G` given as a tuple of `Nodes` and `Arcs`.
Available methods include,
- Clarke and Wright Savings Algorithm   : `:cw`
- Random Initialization                 : `:random`

Optionally specify a random number generator `rng` as the first argument
(defaults to `Random.GLOBAL_RNG`).
"""
initialsolution(rng::AbstractRNG, G, method::Symbol)::Solution = getfield(TSP, method)(rng, G)
initialsolution(G, method::Symbol) = initialsolution(Random.GLOBAL_RNG, G, method)

# Clarke and Wright Savings Algorithm
# Create initial solution by merging routes that render the most savings until single route traversing all nodes remains
function cw(rng::AbstractRNG, G)
    N, A = G
    s = Solution(N, A)
    d = N[1]
    # Step 1: Initialize solution with routes to every node from the depot node (first node)
    K = length(N)
    D = [deepcopy(d) for _ ∈ 1:K]
    for k ∈ K:-1:1 insertnode!(N[k], D[k], D[k], s) end
    # Step 2: Merge routes iteratively until single route traversing all nodes remains
    X = fill(-Inf, (K,K))       # X[i,j]: Savings from merging route with tail node N[i] into route with tail node N[j]
    ϕ = ones(Int64, K)          # ϕ[k]  : if isone(ϕ[k]) implies route k is active else inactive
    for _ ∈ 3:K
        # Step 2.1: Iterate through every route-pair combination
        z = f(s)
        for i ∈ 2:K
            n₁ = N[i]
            d₁ = D[i]
            if !isequal(n₁.h, d₁.i) continue end
            for j ∈ 2:K
                # Step 2.1.1: Merge routes with tail node N[i] into route with tail node N[j]
                n₂ = N[j]
                d₂ = D[j]
                if isequal(n₁, n₂) continue end
                if !isequal(n₂.h, d₂.i) continue end
                if iszero(ϕ[i]) & iszero(ϕ[j]) continue end
                nₕ = d₂
                nₒ = n₁
                nₜ = isone(nₒ.t) ? d₁ : N[nₒ.t]
                while true
                    removenode!(nₒ, nₜ, d₁, s)
                    insertnode!(nₒ, n₂, nₕ, s)
                    if isequal(nₜ, d₁) break end
                    nₕ = nₒ
                    nₒ = nₜ
                    nₜ = isone(nₒ.t) ? d₁ : N[nₒ.t]
                end
                # Step 2.1.2: Compute savings from merging route with tail node N[i] into route with tail node N[j]
                z⁻ = f(s)
                Δ  = z - z⁻
                X[i,j] = Δ
                # Step 2.1.3: Unmerge routes with tail node N[i] into route with tail node N[j]
                nₜ = d₁
                nₒ = N[n₂.h]
                nₕ = isone(nₒ.h) ? d₂ : N[nₒ.h]
                while true
                    removenode!(nₒ, n₂, nₕ, s)
                    insertnode!(nₒ, nₜ, d₁, s)
                    if isequal(nₕ, d₂) break end
                    nₜ = nₒ
                    nₒ = nₕ
                    nₕ = isone(nₒ.h) ? d₂ : N[nₒ.h]
                end
            end
        end
        # Step 2.2: Merge routes that render highest savings
        i,j = Tuple(argmax(X))
        n₁ = N[i]
        d₁ = D[i]
        n₂ = N[j]
        d₂ = D[j]
        nₕ = d₂
        nₒ = n₁
        nₜ = isone(nₒ.t) ? d₁ : N[nₒ.t]
        while true
            removenode!(nₒ, nₜ, d₁, s)
            insertnode!(nₒ, n₂, nₕ, s)
            if isequal(nₜ, d₁) break end
            nₕ = nₒ
            nₒ = nₜ
            nₜ = isone(nₒ.t) ? d₁ : N[nₒ.t]
        end
        D[i] = D[j]
        # Step 2.3: Revise savings and selection vectors appropriately
        X[i, :] .= -Inf
        X[:, i] .= -Inf
        X[j, :] .= -Inf
        X[:, j] .= -Inf
        for k ∈ 1:K ϕ[k] = isequal(k, i) ? 1 : 0 end
    end
    for n ∈ N d.t = isequal(n.h, d.i) ? n.i : d.t end
    for n ∈ N d.h = isequal(n.t, d.i) ? n.i : d.h end
    # Step 3: Return initial solution
    return s
end

# Random Initialization
# Develop a randomized initial solution
function random(rng::AbstractRNG, G)
    N, A = G
    s  = Solution(N, A)
    d  = N[1]
    # Step 1: Intialize tail nₜ and head node nₕ as depot nodes
    nₜ = d
    nₕ = d
    while any(isopen, N)
        # Step 1.1: Randomly select a node nₒ to insert between tail node nₜ (depot node d) and head node nₕ
        nₒ = sample(rng, N, Weights(isopen.(N)))
        insertnode!(nₒ, nₜ, nₕ, s)
        # Step 1.2: Update head node nₕ as current node nₒ
        nₕ = nₒ
    end
    # Step 2: Return initial solution
    return s
end
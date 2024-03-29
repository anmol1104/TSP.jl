"""
    localsearch!([rng::AbstractRNG], k̅::Int, s::Solution, method::Symbol)

Returns solution `s` after performing local seach on the solution using 
given `method` for `k̅` iterations.

Available methods include,
- Move  : `:move!`
- Opt   : `:opt!`
- Swap  : `:swap!`

Optionally specify a random number generator `rng` as the first argument 
(defaults to `Random.GLOBAL_RNG`).
"""
localsearch!(rng::AbstractRNG, k̅::Int, s::Solution, method::Symbol)::Solution = isdefined(TSP, method) ? getfield(TSP, method)(rng, k̅, s) : getfield(Main, method)(rng, k̅, s)
localsearch!(k̅::Int, s::Solution, method::Symbol) = localsearch!(Random.GLOBAL_RNG, k̅, s, method)



"""
    move!(rng::AbstractRNG, k̅::Int, s::Solution)

Returns solution `s` after moving a randomly selected node 
to its best position if the move results in a reduction in 
objective function value, repeating for `k̅` iterations.
"""
function move!(rng::AbstractRNG, k̅::Int, s::Solution)
    # Step 1: Initialize
    N = s.N
    x = Inf                         # x   : insertion cost at best position
    p = (0, 0)                      # p   : best insertion postion
    # Step 2: Iterate for k̅ iterations
    for _ ∈ 1:k̅
        # Step 2.1: Randomly select a node
        z  = f(s)
        nₒ = sample(rng, N)
        # Step 2.2: Remove this node from its position between tail node nₜ and head node nₕ
        nₜ = N[nₒ.t]
        nₕ = N[nₒ.h]
        nₑ = nₜ
        x  = Inf
        p  = (0, 0)
        removenode!(nₒ, nₜ, nₕ, s)
        nₜ = nₕ
        nₕ = N[nₜ.h]
        # Step 2.3: Iterate through all possible insertion positions
        while true
            # Step 2.3.1: Insert node between tail node nₜ and head node nₕ
            insertnode!(nₒ, nₜ, nₕ, s)
            # Step 2.3.2: Compute insertion cost
            z′ = f(s)
            Δ  = z′ - z
            # Step 2.3.3: Revise least insertion cost and the corresponding best insertion position
            if Δ < x x, p = Δ, (nₜ.i, nₕ.i) end
            # Step 2.3.4: Remove node from its position between tail node nₜ and head node nₕ
            removenode!(nₒ, nₜ, nₕ, s)
            if isequal(nₜ, nₑ) break end
            nₜ = nₕ
            nₕ = N[nₜ.h]
        end
        # Step 2.4: Move the node to its best position (this could be its original position as well)
        t  = p[1]
        h  = p[2]
        nₜ = N[t]
        nₕ = N[h]
        insertnode!(nₒ, nₜ, nₕ, s)
    end
    # Step 3: Return solution
    return s
end



"""
    opt!(rng::AbstractRNG, k̅::Int, s::Solution)

Returns solution `s` after iteratively taking 2 arcs from the solution 
and reconfiguring them (total possible reconfigurations 2²-1 = 3) if the 
reconfiguration results in a reduction in objective function value, repeating 
for `k̅` iterations.
"""
function opt!(rng::AbstractRNG, k̅::Int, s::Solution)
    # Step 1: Initialize
    z = f(s)
    N = s.N
    # Step 2: Iterate for k̅ iterations until improvement
    for _ ∈ 1:k̅
        # Step 2.1: Reconfigure two randomly selected arcs
        # n₁ → n₂ → n₃ and n₄ → n₅ → n₆ 
        n₂, n₅ = sample(rng, N), sample(rng, N)
        n₁ = N[n₂.t]
        n₃ = N[n₂.h]
        n₄ = N[n₅.t]
        n₆ = N[n₅.h]
        if isequal(n₂, n₅) || isequal(n₁, n₅) continue end 
        q  = n₆
        nₒ = n₂
        p  = n₃
        while true
            removenode!(nₒ, n₁, p, s)
            insertnode!(nₒ, n₅, q, s)
            q  = nₒ
            nₒ = p
            p  = N[p.h]
            if isequal(nₒ, n₅) break end
        end
        # Step 2.2: Compute change in objective function value
        z′ = f(s)
        Δ  = z′ - z 
        # Step 2.3: If the swap results in reduction in objective function value then go to step 1, else go to step 1.4
        if Δ < 0 z = z′
        # Step 2.4: Reconfigure the two arcs to original state and go to step 1.1
        else
            q  = n₆
            nₒ = n₅
            p  = n₄
            while true
                removenode!(nₒ, n₁, p, s)
                insertnode!(nₒ, n₂, q, s)
                q  = nₒ
                nₒ = p
                p  = N[p.h]
                if isequal(nₒ, n₂) break end
            end
        end
    end
    # Step 3: Return solution
    return s
end



"""
    swap!(rng::AbstractRNG, k̅::Int, s::Solution)

Returns solution `s` after swapping two randomly selected 
nodes if the swap results in a reduction in objective 
function value, repeating for `k̅` iterations.
"""
function swap!(rng::AbstractRNG, k̅::Int, s::Solution)
    # Step 1: Initialize
    N = s.N
    z = f(s)
    # Step 2: Iterate for k̅ iterations
    for _ ∈ 1:k̅
        # Step 2.1: Swap two randomly selected nodes
        # n₁ → n₂ → n₃ and n₄ → n₅ → n₆
        n₂ = sample(rng, N)
        W  = [isequal(n₂, n₅) ? 0. : relatedness(n₂, n₅, s) for n₅ ∈ N]
        n₅ = sample(rng, N, Weights(W))
        if isequal(n₂, n₅) continue end
        n₁ = N[n₂.t]
        n₃ = N[n₂.h]
        n₄ = N[n₅.t]
        n₆ = N[n₅.h]
        # n₁ → n₂ (n₄) → n₃ (n₅) → n₆   ⇒   n₁ → n₃ (n₅) → n₂ (n₄) → n₆
        if isequal(n₃, n₅)
            removenode!(n₂, n₁, n₃, s)
            insertnode!(n₂, n₅, n₆, s)
        # n₄ → n₅ (n₁) → n₂ (n₆) → n₃   ⇒   n₄ → n₂ (n₆) → n₅ (n₁) → n₃   
        elseif isequal(n₂, n₆)
            removenode!(n₂, n₁, n₃, s)
            insertnode!(n₂, n₄, n₅, s)
        # n₁ → n₂ → n₃ and n₄ → n₅ → n₆ ⇒   n₁ → n₅ → n₃ and n₄ → n₂ → n₆
        else 
            removenode!(n₂, n₁, n₃, s)
            removenode!(n₅, n₄, n₆, s)
            insertnode!(n₅, n₁, n₃, s)
            insertnode!(n₂, n₄, n₆, s)
        end
        # Step 2.2: Compute change in objective function value
        z′ = f(s)
        Δ  = z′ - z 
        # Step 2.3: If the swap results in reduction in objective function value then go to step 1, else go to step 1.4
        if Δ < 0 z = z′
        # Step 2.4: Reswap the two nodes and go to step 2.1
        else
            # n₁ → n₂ (n₄) → n₃ (n₅) → n₆   ⇒   n₁ → n₃ (n₅) → n₂ (n₄) → n₆
            if isequal(n₃, n₅)
                removenode!(n₂, n₅, n₆, s)
                insertnode!(n₂, n₁, n₃, s)
            # n₄ → n₅ (n₁) → n₂ (n₆) → n₃   ⇒   n₄ → n₂ (n₆) → n₅ (n₁) → n₃   
            elseif isequal(n₂, n₆)
                removenode!(n₂, n₄, n₅, s)
                insertnode!(n₂, n₁, n₃, s)
            # n₁ → n₂ → n₃ and n₄ → n₅ → n₆ ⇒   n₁ → n₅ → n₃ and n₄ → n₂ → n₆
            else 
                removenode!(n₅, n₁, n₃, s)
                removenode!(n₂, n₄, n₆, s)
                insertnode!(n₂, n₁, n₃, s)
                insertnode!(n₅, n₄, n₆, s)
            end
        end
    end
    # Step 3: Return solution
    return s
end


        
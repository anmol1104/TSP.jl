[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Build Status](https://github.com/anmol1104/TSP.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/anmol1104/TSP.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![Coverage](https://codecov.io/gh/anmol1104/TSP.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/anmol1104/TSP.jl)

# Traveling Salesman Problem (TSP)

Given a graph `G = (N,A)` with set of nodes N and set of arcs `A` with arc traversal 
cost `cᵢⱼ ; (i,j) ∈ A`, the objective is to develop a least cost route visiting every 
node exactly once.

This package uses Adaptive Large Neighborhood Search (ALNS) algorithm to find an 
optimal solution for the Traveling Salesman Problem given ALNS optimization 
parameters,
- `n`     :   Number of ALNS iterations in an ALNS segment
- `k`     :   Number of ALNS segments
- `m`     :   Number of local search iterations
- `j`     :   Number of ALNS segments triggering local search
- `Ψᵣ`    :   Vector of removal operators
- `Ψᵢ`    :   Vector of insertion operators
- `Ψₗ`    :   Vector of local search operators
- `σ₁`    :   Score for a new best solution
- `σ₂`    :   Score for a new better solution
- `σ₃`    :   Score for a new worse but accepted solution
- `ω`     :   Start tempertature control threshold 
- `τ`     :   Start tempertature control probability
- `𝜃`     :   Cooling rate
- `C̲`     :   Minimum customer nodes removal
- `C̅`     :   Maximum customer nodes removal
- `μ̲`     :   Minimum removal fraction
- `μ̅`     :   Maximum removal fraction
- `ρ`     :   Reaction factor

and an initial solution developed using one of the following methods,
- Clarke and Wright Savings Algorithm   : `:cw`
- Random Initialization                 : `:random`

The ALNS metaheuristic iteratively removes a set of nodes using,
- Random Node Removal    : `:randomnode!`
- Related Node Removal   : `:relatednode!`
- Worst Node Removal     : `:worstnode!`

and consequently inserts removed nodes using,
- Precise Best Insertion    : `:bestprecise!`
- Perturb Best Insertion    : `:bestperturb!`
- Precise Greedy Insertion  : `:greedyprecise!`
- Perturb Greedy Insertion  : `:greedyperturb!`
- Regret-two Insertion      : `:regret2!`
- Regret-three Insertion    : `:regret3!`

In every few iterations, the ALNS metaheuristic performs local search with,
- Move  : `:move!`
- 2-Opt : `:opt!`
- Swap  : `:swap!`

See example.jl for usage

Additional initialization, removal, insertion, and local search methods can be defined.
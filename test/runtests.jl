using TSP
using Revise
using Test
using Random

@testset "TSP.jl" begin
    instances = ["att48", "a280"]
    methods   = [:random, :cw]
    χ   = ALNSParameters(
        k̲   =   1                       ,
        l̲   =   50                      ,
        l̅   =   125                     ,
        k̅   =   250                     ,
        Ψᵣ  =   [
                    :randomnode!    , 
                    :relatednode!   ,
                    :worstnode!   
                ]                       , 
        Ψᵢ  =   [
                    :bestprecise!   ,
                    :bestperturb!   ,
                    :greedyprecise! ,
                    :greedyperturb! ,
                    :regret2!       ,
                    :regret3!
                ]                       ,
        Ψₗ  =   [
                    :move!      ,
                    :opt!       ,
                    :swap!
                ]                       ,
        σ₁  =   15                      ,
        σ₂  =   10                      ,
        σ₃  =   3                       ,
        ω   =   0.05                    ,
        τ   =   0.5                     ,
        𝜃   =   0.9975                  ,
        C̲   =   4                       ,
        C̅   =   60                      ,
        μ̲   =   0.1                     ,
        μ̅   =   0.4                     ,
        ρ   =   0.1                     ,
    );
    for k ∈ 1:2
        instance = instances[k]
        method   = methods[k]
        println("\n Solving $instance")
        sₒ = initialsolution(instance, method)     
        S  = ALNS(χ, sₒ)
        s⃰  = S[end]
        @test isfeasible(sₒ)
        @test isfeasible(s⃰)
        @test f(s⃰) ≤ f(sₒ)
    end
    return
end

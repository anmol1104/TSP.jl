using TSP
using Revise
using Test
using Random

@testset "TSP.jl" begin
    χ = ALNSparameters(
        j   =   50                      ,
        k   =   5                       ,
        n   =   10                      ,
        m   =   1000                    ,
        Ψᵣ  =   [
                    :randomnode!        ,
                    :relatednode!       ,
                    :worstnode!
                ]                       ,
        Ψᵢ  =   [
                    :best!              ,
                    :precise!           ,
                    :perturb!           ,
                    :regret2!           ,
                    :regret3!
                ]                       ,
        Ψₗ  =   [
                    :move!              ,
                    :swap!              ,
                    :opt!
                ]                       ,
        σ₁  =   15                      ,
        σ₂  =   10                      ,
        σ₃  =   3                       ,
        μ̲   =   0.1                     ,
        C̲   =   4                       ,
        μ̅   =   0.4                     ,
        C̅   =   60                      ,
        ω̅   =   0.05                    ,
        τ̅   =   0.5                     ,
        ω̲   =   0.01                    ,
        τ̲   =   0.01                    ,
        θ   =   0.9985                  ,
        ρ   =   0.1
    );
    instances = ["att48", "a280"]
    for instance ∈ instances
        visualize(instance)
        println(instance)
        sₒ = initialize(instance)     
        s⃰  = ALNS(χ, sₒ)
        visualize(s⃰)
        @test isfeasible(s⃰)
        @test f(s⃰) ≤ f(sₒ)
    end   
    return
end

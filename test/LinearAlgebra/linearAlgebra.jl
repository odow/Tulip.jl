"""
    test_linalg(A, b, c, uind, uval, h)

Verify that the linear algebra operations are properly defined for the input
    data structures.
"""
function test_linalg(A::AbstractMatrix{Tv}) where{Tv<:Real}

    # Dimension check
    m = size(A, 1)
    n = size(A, 2)

    # Matrix-vector multiplication
    @testset "Required methods" begin
        @test hasmethod(*, Tuple{typeof(A), Vector{Tv}})
        @test hasmethod(*, Tuple{typeof(A'), Vector{Tv}})

        @test hasmethod(mul!, Tuple{Vector{Tv}, typeof(A), Vector{Tv}})
        @test hasmethod(mul!, Tuple{Vector{Tv}, typeof(A'), Vector{Tv}})
    end

    # Cholesky factorization
    @testset "AbstractLinearSolver" begin
        # Initialize linear solver
        ls = TLP.AbstractLinearSolver(A)

        # Update factorization
        θ = Tv(2) .* ones(Tv, n)
        regP = ones(Tv, n)
        regD = ones(Tv, m)

        TLP.TLPLinearAlgebra.update_linear_solver!(ls, θ, regP, regD)

        # solve linear system
        dx = zeros(Tv, n)
        dy = zeros(Tv, m)
        ξp = ones(Tv, m)
        ξd = ones(Tv, n)
        TLP.TLPLinearAlgebra.solve_augmented_system!(
            dx, dy, ls, ξp, ξd
        )

        # Check accuracy of solution
        resP = norm(ξp - A * dx - regD .* dy, Inf)
        resD = norm(ξd - dx ./ (θ .+ regP) - A' * dy, Inf)

        @test resP <= sqrt(eps(Tv))
        @test resD <= sqrt(eps(Tv))
    end

    return true
end

@testset "LinearAlgebra" begin

    # Test specific data structures
    include("dense.jl")     # Dense matrices
    include("sparse.jl")    # SparseMatrixCSC
    
    # include("unitBlockAngular.jl") # Specialized unit block-angular

end
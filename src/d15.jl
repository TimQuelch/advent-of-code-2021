module d15

using Chain
using InlineTest
using DataStructures

# Returns the indices of the neighbouring cells to i
function neighbours(d, i)
    neighbours = (CartesianIndices(d)[i],) .+ CartesianIndex.([(1, 0), (0, 1), (-1, 0), (0,-1)])
    neighbours = filter(n -> checkbounds(Bool, d, n), neighbours)
    return map(i -> LinearIndices(d)[i], neighbours)
end

function astar(d)
    dists = Dict{Int, Int}()
    b = LinearIndices(d)[begin]
    e = LinearIndices(d)[end]
    dists[b] = 0
    heuristic(p) = sqrt(
        (CartesianIndices(d)[e][1] - CartesianIndices(d)[p][1])^2 +
            (CartesianIndices(d)[e][2] - CartesianIndices(d)[p][2])^2
    )
    weight(p) = dists[p] + heuristic(b)
    queue = PriorityQueue{Int, Float64}()
    enqueue!(queue, b, weight(b))

    while !isempty(queue)
        i = dequeue!(queue)
        i == e && return dists[e]
        for j in neighbours(d, i)
            tentative_score = dists[i] + d[j]
            if j ∉ keys(dists) || tentative_score < dists[j]
                dists[j] = tentative_score
                j ∈ keys(queue) && delete!(queue, j)
                enqueue!(queue, j, weight(j))
            end
        end
    end
end

function expandgrid(d, N)
    increment = @chain N begin
        repeat(0:_-1, outer=[1, _])
        _ .+ _'
        repeat(inner=size(d))
    end

    return @chain d begin
        repeat(outer=[N, N])
        _ .+ increment
        mod.((1:9,))
    end
end

part1(d) = astar(d)
part2(d) = astar(expandgrid(d, 5))

parseinput(io) = mapreduce(vcat, eachline(io)) do l
    @chain l begin
        collect
        parse.(Int, _)
        permutedims
    end
end
solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    1163751742
    1381373672
    2136511328
    3694931569
    7463417111
    1319128137
    1359912421
    3125421639
    1293138521
    2311944581
    """
const testarr = [
    1 1 6 3 7 5 1 7 4 2
    1 3 8 1 3 7 3 6 7 2
    2 1 3 6 5 1 1 3 2 8
    3 6 9 4 9 3 1 5 6 9
    7 4 6 3 4 1 7 1 1 1
    1 3 1 9 1 2 8 1 3 7
    1 3 5 9 9 1 2 4 2 1
    3 1 2 5 4 2 1 6 3 9
    1 2 9 3 1 3 8 5 2 1
    2 3 1 1 9 4 4 5 8 1
]

@testset "d15" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 40
    @test part2(testarr) == 315
    @test solve(IOBuffer(teststr)) == (40, 315)
end

end

module d11

using Chain
using InlineTest

function neighbours(d, i)
    rel_neighbours = filter(!=(CartesianIndex(0, 0)),
                            CartesianIndex.(Iterators.product(-1:1, -1:1))[:])
    neighbours = (i,) .+ rel_neighbours
    return neighbours = filter(n -> checkbounds(Bool, d, n), neighbours)
end

function flash!(d, i)
    n = filter(i -> d[i] > 0, neighbours(d, i))
    d[n] .+= 1
    d[i] = 0
    return d
end

function iterate!(d)
    d .+= 1
    while any(>(9), d)
        i = findfirst(>(9), d)
        flash!(d, i)
    end
    flashes = count(==(0), d)
    return flashes
end

function part1(d)
    d = copy(d)
    flashes = 0
    for i in 1:100
        flashes += iterate!(d)
    end
    return flashes
end
function part2(d)
    d = copy(d)
    i = 0
    while !all(x -> x == first(d), d)
        iterate!(d)
        i += 1
    end
    return i
end

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
    5483143223
    2745854711
    5264556173
    6141336146
    6357385478
    4167524645
    2176841721
    6882881134
    4846848554
    5283751526
    """
const testarr = [
    5 4 8 3 1 4 3 2 2 3
    2 7 4 5 8 5 4 7 1 1
    5 2 6 4 5 5 6 1 7 3
    6 1 4 1 3 3 6 1 4 6
    6 3 5 7 3 8 5 4 7 8
    4 1 6 7 5 2 4 6 4 5
    2 1 7 6 8 4 1 7 2 1
    6 8 8 2 8 8 1 1 3 4
    4 8 4 6 8 4 8 5 5 4
    5 2 8 3 7 5 1 5 2 6
]

@testset "d11" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 1656
    @test part2(testarr) == 195
    @test solve(IOBuffer(teststr)) == (1656, 195)
end

end

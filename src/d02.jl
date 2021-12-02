module d02

using Chain
using InlineTest

# Lookup table for directions
const lookup = Dict(
    "forward" => (1, 0),
    "up" => (0, -1),
    "down" => (0, 1),
)

# Simply convert all to vectors and then sum them all up
function part1(d)
    vec =  mapreduce(
        t -> lookup[t[1]] .* t[2],
        .+,
        d
    )
    return prod(vec)
end

# The cumulative sum of the 'aim' is the aim after any change. Multiplying this by the forward
# motion gives us the vertical motion. Summing all vectors gives the final position
function part2(d)
    v = mapreduce(
        t -> collect(lookup[t[1]] .* t[2]),
        hcat,
        d
    )
    v[2, :] .=  (v[1, :] .* cumsum(v[2, :]))
    return sum(v; dims=2) |> prod
end

parseinput(io) = map(eachline(io)) do l
    @chain l begin
        split()
        (_[1], parse(Int, _[2]))
    end
end
solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    forward 5
    down 5
    forward 8
    up 3
    down 8
    forward 2
    """
const testarr = [
    ("forward", 5),
    ("down", 5),
    ("forward", 8),
    ("up", 3),
    ("down", 8),
    ("forward", 2),
]

@testset "d02" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 150
    @test part2(testarr) == 900
    @test solve(IOBuffer(teststr)) == (150, 900)
end

end

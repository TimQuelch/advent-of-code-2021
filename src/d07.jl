module d07

using Chain
using InlineTest

# Fuel usage for part 2 is the triangular numbers
triangular(n) = Int(n * (n + 1) // 2)

# Test each position and calculate the total fuel used
function minimum_fuel(d, fuel_usage_fn)
    @chain d begin
        minimum(_):maximum(_)
        map(x -> sum(fuel_usage_fn.(abs.(d .- x))), _)
        minimum
    end
end

# Only difference in parts is how fuel is consumed
part1(d) = minimum_fuel(d, identity)
part2(d) = minimum_fuel(d, triangular)

parseinput(io) = @chain io begin
    read(String)
    split(",")
    map(s -> parse(Int, s), _)
end
solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = "16,1,2,0,4,2,7,1,2,14"
const testarr = [16,1,2,0,4,2,7,1,2,14]

@testset "d07" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 37
    @test part2(testarr) == 168
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end

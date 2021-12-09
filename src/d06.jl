module d06

using Chain
using InlineTest
using DataStructures
using OffsetArrays

# Convert a list of values to a 0 indexed array of the counts of each number
function count_array(d)
    counts = counter(d)
    vals = map(i -> counts[i], 0:8)
    return OffsetArray(vals, 0:8)
end

# We maintain a small 9 element vector with the counts of each age, rather than an unbounded large
# vector with the ages themselves. This is much more efficient memory and time wise
function simulate(d, days)
    c = count_array(d)
    for i in 1:days
        nzero = c[0]            # Count how many new
        c[0:7] = c[1:8]         # Decrease all ages by 1
        c[8] = nzero            # Add newly added fish
        c[6] += nzero           # Reset timers of zeros
    end
    return sum(c)
end

# The only difference between the two parts is the number of days
part1(d) = simulate(d, 80)
part2(d) = simulate(d, 256)

parseinput(io) = @chain io begin
    read(String)
    split(",")
    map(s -> parse(Int, s), _)
end
solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = "3,4,3,1,2"
const testarr = [3,4,3,1,2]

@testset "d06" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test simulate(testarr, 18) == 26
    @test simulate(testarr, 80) == 5934
    @test simulate(testarr, 256) == 26984457539
    @test part1(testarr) == 5934
    @test part2(testarr) == 26984457539
    @test solve(IOBuffer(teststr)) == (5934, 26984457539)
end

end

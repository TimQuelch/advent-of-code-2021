module d01

using Chain
using DSP
using InlineTest

# Calculate differences between each successive pair of values, then count how
# many are positive
function part1(d)
    @chain d begin
        diff
        count(>(0), _)
    end
end

# Use a convolution with a uniform 3 wide window to calculate the moving window.
# This is slightly overkill, but this is where my digital signal processing
# brain went to for a solution
function part2(d)
    N = 3
    @chain d begin
        conv(_, ones(N))
        _[N:end-(N-1)]
        diff
        count(>(0), _)
    end
end

parseinput(io) = map(l -> parse(Int, l), eachline(io))
solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    199
    200
    208
    210
    200
    207
    240
    269
    260
    263
    """
const testarr = [
    199,
    200,
    208,
    210,
    200,
    207,
    240,
    269,
    260,
    263,
]

@testset "d01" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 7
    @test part2(testarr) == 5
    @test solve(testarr) == (7, 5)
    @test solve(IOBuffer(teststr)) == (7, 5)
end

end

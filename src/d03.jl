module d03

using Chain
using InlineTest
using StatsBase

function bitvec_to_int(b)
    scale = 1                   # First bit is 1
    a = 0
    for bit in reverse(b)       # Start at least significant bit (1)
        a += scale * bit        # Increment if bit is true
        scale <<= 1             # Each successive bit is 2x the previous
    end
    return a
end

function part1(d)
    gbits = mode.(eachrow(d))   # Calculate the mode of each bitrow
    ebits = .!(gbits)           # Negate the epsilon value
    return prod(bitvec_to_int.((gbits, ebits)))
end

# valid_value_fn is a function to determine the 'bit_criteria' for a bit vector of all bits in a
# single bit position position
function selector(d, valid_value_fn)
    indexes = collect(1:size(d, 2)) # Initial list of all indexes

    for m = 1:size(d, 1)
        length(indexes) == 1 && break # Check if we are finished
        keepval = valid_value_fn(d[m, indexes]) # Calculate which bit we want to keep
        # Filter the indices for the numbers that meet the bit criteria
        indexes = filter(i -> d[m, i] == keepval, indexes)
    end

    # Return the number that is in the final remaining index
    return bitvec_to_int(d[:, only(indexes)])
end


# These functions determine which bit is the one to keep for each O2 and C02
oxygen_keep_bit(bitvec) = count(identity, bitvec) >= (length(bitvec) / 2)
co2_keep_bit(bitvec) = !oxygen_keep_bit(bitvec)

# Calculate the oxygen and co2 values
oxygen_value(d) = selector(d, oxygen_keep_bit)
co2_value(d) = selector(d, co2_keep_bit)

part2(d) = oxygen_value(d) * co2_value(d)

parseinput(io) = mapreduce(hcat, eachline(io)) do l
    @chain l begin
        collect
        parse.(Bool, _)
    end
end
solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    00100
    11110
    10110
    10111
    10101
    01111
    00111
    11100
    10000
    11001
    00010
    01010
    """
const testarr = Bool[
    0 0 1 0 0
    1 1 1 1 0
    1 0 1 1 0
    1 0 1 1 1
    1 0 1 0 1
    0 1 1 1 1
    0 0 1 1 1
    1 1 1 0 0
    1 0 0 0 0
    1 1 0 0 1
    0 0 0 1 0
    0 1 0 1 0
]'

@testset "d03" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == (22 * 9)
    @test oxygen_value(testarr) == 23
    @test co2_value(testarr) == 10
    @test part2(testarr) == (10 * 23)
    @test solve(IOBuffer(teststr)) == (22*9, 10*23)
end

end

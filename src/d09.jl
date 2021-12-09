module d09

using Chain
using InlineTest
using DataStructures

# Returns the indices of the neighbouring cells to i
function neighbours(d, i)
    neighbours = (i,) .+ CartesianIndex.([(1, 0), (0, 1), (-1, 0), (0,-1)])
    return neighbours = filter(n -> checkbounds(Bool, d, n), neighbours)
end

# Check if d[i] is a low point
is_lowpoint(d, i) = all(d[i] .< d[neighbours(d, i)])

function part1(d)
    mapreduce(+, CartesianIndices(d)) do i
        is_lowpoint(d, i) ? 1 + d[i] : 0
    end
end

function part2(d)
    grid = zeros(Int, size(d))
    grid[d .== 9] .= -1         # '9' is the barrier
    current_basin = 1           # Initial basin basin
    for i in CartesianIndices(grid)
        grid[i] == -1 && continue # Skip this if it is a '9'

        n = neighbours(grid, i) # Get the neighbouring indices
        found_i = findall(>(0), grid[n]) # Are any of the neighbours allocated a basin?
        if isempty(found_i)
            # Allocate to a new basin if no neighbour is in a basin
            grid[i] = current_basin
            current_basin += 1
        else
            # Else allocate to the existing basin
            (first_i, rest_i) = Iterators.peel(found_i)
            grid[i] = grid[n[first_i]]

            # Merge basins. If we find multiple neighbours with different classes, we assign them
            # all to one class
            for b in unique(grid[n[collect(rest_i)]])
                grid[grid .== b] .= grid[n[first_i]]
            end
        end
    end

    @chain grid begin
        counter                 # Count number in each basin
        Dict                    # Convert to dict (Accumulator can't delete)
        delete!(-1)             # Remove the '9's (they aren't a basin)
        values                  # Get the size of each
        collect                 # Collect to array
        sort!(; rev=true)       # Sort in descending order
        _[1:3]                  # Take the first 3
        prod                    # Multiply them together
    end
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
    2199943210
    3987894921
    9856789892
    8767896789
    9899965678
    """
const testarr = [
    2 1 9 9 9 4 3 2 1 0
    3 9 8 7 8 9 4 9 2 1
    9 8 5 6 7 8 9 8 9 2
    8 7 6 7 8 9 6 7 8 9
    9 8 9 9 9 6 5 6 7 8
]

@testset "d09" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 15
    @test part2(testarr) == 1134
    @test solve(IOBuffer(teststr)) == (15, 1134)
end

end

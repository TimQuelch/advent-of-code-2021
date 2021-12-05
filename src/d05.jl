module d05

using Chain
using InlineTest
using DataStructures

# Same as a:b, however if b > a then it gives b:-1:a
interval(a, b) = a:(b >= a ? 1 : -1):b
interval(t) = interval(t...)

# Test if a line is either horizontal or vertical
isstraight(p) = p[1][1] == p[1][2] || p[2][1] == p[2][2]

function straight_line_points(ps)
    map(filter(isstraight, ps)) do p
        Iterators.product(interval(p[1]), interval(p[2]))
    end
end

function all_line_points(ps)
    slinepoints = straight_line_points(ps) # Straight line points

    # Diagonal line points
    dlinepoints = map(filter(!isstraight, ps)) do p
        zip(interval(p[1]), interval(p[2]))
    end

    # Combine straight and diagonal lines
    return Iterators.flatten((slinepoints, dlinepoints))
end

# Count the overlapping points
function count_overlaps(d, line_points_fn)
    @chain d begin
        map(p -> (([p[1][1], p[2][1]]), ([p[1][2], p[2][2]])), _) # (x1,y1),(x2,y2)->(x1,x2),(y1,y2)
        line_points_fn          # Use the appropriate fn to get all points
        Iterators.flatten
        counter                 # Count duplicate points
        values
        count(>(1), _)          # Count how many are duplicates
    end
end

# Only difference between the two parts is the type of points. Part 1 has only points from the
# straight lines, part 2 has points from straight and diagonal lines.
part1(d) = count_overlaps(d, straight_line_points)
part2(d) = count_overlaps(d, all_line_points)

parseinput(io) = mapreduce(vcat, eachline(io)) do l
    @chain l begin
        split(_, " -> ")
        map(_) do p
            @chain p begin
                split(_, ",")
                map(i -> parse(Int, i), _)
                tuple(_...)
            end
        end
        tuple(_...)
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    0,9 -> 5,9
    8,0 -> 0,8
    9,4 -> 3,4
    2,2 -> 2,1
    7,0 -> 7,4
    6,4 -> 2,0
    0,9 -> 2,9
    3,4 -> 1,4
    0,0 -> 8,8
    5,5 -> 8,2
    """
const testarr = [
    ((0,9), (5,9)),
    ((8,0), (0,8)),
    ((9,4), (3,4)),
    ((2,2), (2,1)),
    ((7,0), (7,4)),
    ((6,4), (2,0)),
    ((0,9), (2,9)),
    ((3,4), (1,4)),
    ((0,0), (8,8)),
    ((5,5), (8,2)),
]

@testset "d05" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 5
    @test part2(testarr) == 12
    @test solve(IOBuffer(teststr)) == (5, 12)
end

end

module d13

using Chain
using InlineTest
using OffsetArrays

function create_grid(p)
    maxx = maximum(p -> p[1], p)
    maxy = maximum(p -> p[2], p)
    g = zeros(Bool, (maxx, maxy) .+ 1)
    is = map(p) do point
        CartesianIndex(point .+ (1, 1))
    end
    g[is] .= true
    return g
end

function fold(g, fold)
    dir, pos = fold
    if dir == "x"
        flipping = g[pos+2:end, :]
        return g[begin:pos, :] .| flipping[end:-1:begin, :]
    elseif dir == "y"
        flipping = g[:, pos+2:end]
        return g[:, begin:pos] .| flipping[:, end:-1:begin]
    else
        error("Well shit, this isn't supposed to happen...")
    end

end

part1(d) = count(fold(create_grid(d[1]), first(d[2])))
part2(d) = foldl(fold, d[2], init=create_grid(d[1]))

function parseinput(io)
    ls = collect(eachline(io))
    points = @chain ls begin
        filter(l -> occursin(r"[0-9]+,[0-9]+", l), _)
        map(_) do l
            @chain l begin
                split(",")
                map(s -> parse(Int, s), _)
                tuple(_...)
            end
        end
    end
    folds = @chain ls begin
        filter(l -> occursin("fold along", l), _)
        map(_) do l
            @chain l begin
                match(r"([xy])=([0-9]+)", _)
                tuple(_[1], parse(Int, _[2]))
            end
        end
    end
    return (points, folds)
end
solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    6,10
    0,14
    9,10
    0,3
    10,4
    4,11
    6,0
    6,12
    4,1
    0,13
    10,12
    3,4
    3,0
    8,4
    1,10
    2,14
    8,10
    9,0

    fold along y=7
    fold along x=5
    """
const testarr = (
    [
        (6, 10),
        (0, 14),
        (9, 10),
        (0, 3),
        (10, 4),
        (4, 11),
        (6, 0),
        (6, 12),
        (4, 1),
        (0, 13),
        (10, 12),
        (3, 4),
        (3, 0),
        (8, 4),
        (1, 10),
        (2, 14),
        (8, 10),
        (9, 0),
    ],
    [
        ("y", 7),
        ("x", 5),
    ]
)
const res = OffsetArray(
    Bool[
        1  1  1  1  1  0  0
        1  0  0  0  1  0  0
        1  0  0  0  1  0  0
        1  0  0  0  1  0  0
        1  1  1  1  1  0  0
    ], 0, 0
)


@testset "d13" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 17
    @test part2(testarr) == res
    @test solve(IOBuffer(teststr)) == (17, res)
end

end

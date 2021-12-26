module d20

using Chain
using InlineTest
using OffsetArrays
using IterTools

bitvec2int(v) = 2 .^((length(v)-1):-1:0) .* v |> sum

function pad_input(m; padder=(m[begin] ? ones : zeros))
    a = OffsetArray(padder(Bool, size(m) .+ 4), -2, -2)
    a[1:size(m, 1), 1:size(m, 2)] .= OffsetArray(m, OffsetArrays.Origin(1))
    return a
end

function pad_output(lookup, m)
    outpad = (m[begin] ? lookup[end] : lookup[begin]) ? ones : zeros
    return OffsetArray(outpad(Bool, size(m) .+ 2), -1, -1)
end

function enhance(lookup, in)
    inpad = pad_input(in)
    output = pad_output(lookup, in)

    for i in CartesianIndices(output)
        subm = @view inpad[i[1]-1:i[1]+1, i[2]-1:i[2]+1]
        index = bitvec2int(vcat(eachrow(subm)...)) + 1
        output[i] = lookup[index]
    end

    return output
end

function enhance_ntimes(d, n)
    @chain d begin
        iterated(in -> enhance(_[1], in), pad_input(_[2], padder=zeros))
        nth(1 + n)
        count
    end
end

part1(d) = enhance_ntimes(d, 2)
part2(d) = enhance_ntimes(d, 50)

function parseinput(io)
    s = readline(io) |> collect
    @assert all(∈(('.', '#')), s)
    alg = map(c -> Bool(c == '#'), s)
    @assert sizeof(alg) == 512
    @assert eltype(alg) == Bool

    _ = readline(io)

    image = mapreduce(vcat, eachline(io)) do l
        @chain l begin
            collect
            map(c -> Bool(c == '#'), _)
            permutedims
        end
    end

    return alg, image
end
solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    ..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..###..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###.######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#..#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#......#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#.....####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#.......##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#

    #..#.
    #....
    ##..#
    ..#..
    ..###
    """
const testarr = (
    Bool[
        0, 0, 1, 0, 1, 0, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0,
        1, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0, 0,
        0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 0,
        1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 1, 1, 1, 0, 0, 0,
        1, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 1,
        1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 0, 1,
        0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 1, 0, 1, 1, 0, 0,
        0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 1, 0,
        1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
        0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0,
        1, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0,
        1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 0, 1, 1,
        1, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1,
        0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0,
        0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0,
        1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 1, 1, 1,
        0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0,
        0, 1,
    ],
    Bool[
        1 0 0 1 0
        1 0 0 0 0
        1 1 0 0 1
        0 0 1 0 0
        0 0 1 1 1
    ]
)

@testset "d20" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 35
    @test part2(testarr) == 3351
    @test solve(IOBuffer(teststr)) == (35, 3351)
end

end

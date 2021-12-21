module d14

using Chain
using InlineTest
using DataStructures

function iterate(in, lookup)
    out = Accumulator{String, Int128}()
    for (pair, count) in pairs(in)
        inserted = lookup[pair]
        inc!(out, pair[1] * inserted, count)
        inc!(out, inserted * pair[2], count)
    end
    return out
end

function simulate(str, lookup, N)
    paircount = counter(map(i -> str[collect(i)], zip(1:length(str)-1, 2:length(str))))
    for i in 1:N
        paircount = iterate(paircount, lookup)
    end
    lettercount = Accumulator{Char, Int128}()
    for (pair, count) in paircount
        inc!(lettercount, pair[1], count)
        inc!(lettercount, pair[2], count)
    end
    inc!(lettercount, str[begin])
    inc!(lettercount, str[end])
    return @chain lettercount begin
        values
        map(v -> v / 2, _)
        extrema
        -(_...)
        abs
        Int128
    end
end

part1(d) = simulate(d..., 10)
part2(d) = simulate(d..., 40)

function parseinput(io)
    seed = readline(io)
    _ = readline(io)
    lookup = @chain io begin
        eachline(_)
        map(_) do l
            @chain l begin
                split(" -> ")
                =>(_...)
            end
        end
        Dict
    end
    return seed, lookup
end
solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    NNCB

    CH -> B
    HH -> N
    CB -> H
    NH -> C
    HB -> C
    HC -> B
    HN -> C
    NN -> C
    BH -> H
    NC -> B
    NB -> B
    BN -> B
    BB -> N
    BC -> B
    CC -> N
    CN -> C
    """
const testarr = (
    "NNCB",
    Dict(
        "CH" => "B",
        "HH" => "N",
        "CB" => "H",
        "NH" => "C",
        "HB" => "C",
        "HC" => "B",
        "HN" => "C",
        "NN" => "C",
        "BH" => "H",
        "NC" => "B",
        "NB" => "B",
        "BN" => "B",
        "BB" => "N",
        "BC" => "B",
        "CC" => "N",
        "CN" => "C",
    )
)

@testset "d14" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 1588
    @test part2(testarr) == 2188189693529
    @test solve(IOBuffer(teststr)) == (1588, 2188189693529)
end

end

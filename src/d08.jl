module d08

using Chain
using InlineTest

function part1(d)
    @chain d begin
        mapreduce(l -> l[2], vcat, _)
        count(s -> length(s) ∈ (2, 3, 4, 7), _)
    end
end

# I promise this works. There's probably a million ways to do this. First I build up a dictionary of
# I -> Str, then I reverse this for the lookup table
function create_lookup(strs)
    d = Dict{Int, Set{Char}}()
    us = Set.(strs)
    d[1] = only(filter(s -> length(s) == 2, us))
    d[4] = only(filter(s -> length(s) == 4, us))
    d[7] = only(filter(s -> length(s) == 3, us))
    d[8] = only(filter(s -> length(s) == 7, us))

    d[9] = only(setdiff(filter(s -> (d[4] ∪ d[7]) ⊆ s, us), (d[8],)))
    d[6] = only(setdiff(filter(s -> setdiff(d[8], d[1]) ⊆ s, us), (d[8],)))
    d[0] = only(setdiff(filter(s -> length(s) == 6, us), (d[9], d[6])))

    d[2] = setdiff(d[8], d[6]) ∪ setdiff(d[8], d[0]) ∪ setdiff(d[8], d[4])
    d[3] = setdiff(d[8], setdiff(d[8], d[2] ∪ d[1]), setdiff(d[8], d[9]))
    d[5] = only(setdiff(us, values(d)))

    return Dict(v => k for (k, v) in d)
end

function lookup_output(strs, d)
    digits = map(s -> d[Set(s)], strs) # Lookup what digits each string represents
    return sum((10 .^(3:-1:0)) .* digits) # Convert to a single number
end

function part2(d)
    mapreduce(+, d) do l
        u, s = l
        d = create_lookup(u)
        lookup_output(s, d)
    end
end

parseinput(io) = mapreduce(vcat, eachline(io)) do l
    @chain l begin
        split(" | ")
        tuple(_...)
        split.(_)
    end
end
solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
    edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
    fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
    fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
    aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
    fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
    dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
    bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
    egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
    gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
    """
const testarr = [
    (["be", "cfbegad", "cbdgef", "fgaecd", "cgeb", "fdcge", "agebfd", "fecdb", "fabcd", "edb"], ["fdgacbe", "cefdb", "cefbgd", "gcbe"]),
    (["edbfga", "begcd", "cbg", "gc", "gcadebf", "fbgde", "acbgfd", "abcde", "gfcbed", "gfec"], ["fcgedb", "cgb", "dgebacf", "gc"]),
    (["fgaebd", "cg", "bdaec", "gdafb", "agbcfd", "gdcbef", "bgcad", "gfac", "gcb", "cdgabef"], ["cg", "cg", "fdcagb", "cbg"]),
    (["fbegcd", "cbd", "adcefb", "dageb", "afcb", "bc", "aefdc", "ecdab", "fgdeca", "fcdbega"], ["efabcd", "cedba", "gadfec", "cb"]),
    (["aecbfdg", "fbg", "gf", "bafeg", "dbefa", "fcge", "gcbea", "fcaegb", "dgceab", "fcbdga"], ["gecf", "egdcabf", "bgf", "bfgea"]),
    (["fgeab", "ca", "afcebg", "bdacfeg", "cfaedg", "gcfdb", "baec", "bfadeg", "bafgc", "acf"], ["gebdcfa", "ecba", "ca", "fadegcb"]),
    (["dbcfg", "fgd", "bdegcaf", "fgec", "aegbdf", "ecdfab", "fbedc", "dacgb", "gdcebf", "gf"], ["cefg", "dcbef", "fcge", "gbcadfe"]),
    (["bdfegc", "cbegaf", "gecbf", "dfcage", "bdacg", "ed", "bedf", "ced", "adcbefg", "gebcd"], ["ed", "bcgafe", "cdgba", "cbgef"]),
    (["egadfb", "cdbfeg", "cegd", "fecab", "cgb", "gbdefca", "cg", "fgcdab", "egfdb", "bfceg"], ["gbdfcae", "bgc", "cg", "cgb"]),
    (["gcafb", "gcf", "dcaebfg", "ecagb", "gf", "abcdeg", "gaef", "cafbge", "fdbac", "fegbdc"], ["fgae", "cfgab", "fg", "bagce"]),
]

@testset "d08" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 26
    @test part2(testarr) == 61229
    @test solve(IOBuffer(teststr)) == (26, 61229)
end

end

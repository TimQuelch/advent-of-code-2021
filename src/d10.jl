module d10

using Chain
using InlineTest
using DataStructures
using Polynomials
using Statistics

const chars = Dict(
    '(' => ')',
    '[' => ']',
    '<' => '>',
    '{' => '}',
)
# I spent hours debugging only to realise I had the } and > the wrong way around in this Dict
const corrupt_score = Dict(
    ')' => 3,
    ']' => 57,
    '}' => 1197,
    '>' => 25137,
)

function is_corrupted(l)
    s = Stack{Char}()
    for c in l
        if c ∈ keys(chars)
            push!(s, c)
        elseif isempty(s)       # This doesn't actually ever happen which is nice of them
            return corrupt_score[c]
        else # c ∈ values(chars)
            needs_to_be_closed = pop!(s)
            if chars[needs_to_be_closed] != c
                return corrupt_score[c]
            end
        end
    end
    return 0
end

const complete_score = Dict(
    '(' => 1,
    '[' => 2,
    '{' => 3,
    '<' => 4,
)
function complete_line(l)
    s = Stack{Char}()
    for c in l
        if c ∈ keys(chars)
            push!(s, c)
        else # c ∈ values(chars)
            pop!(s)
        end
    end
    return @chain s begin
        reverse_iter
        map(c -> complete_score[c], _)
        Polynomial
        _(5)
        Int
    end
end

part1(d) = mapreduce(is_corrupted, +, d)
function part2(d)
    @chain d begin
        filter(l -> is_corrupted(l) == 0, _)
        map(complete_line, _)
        median!
        Int
    end
end

parseinput(io) = collect(eachline(io))
solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    [({(<(())[]>[[{[]{<()<>>
    [(()[<>])]({[<{<<[]>>(
    {([(<{}[<>[]}>{[]{[(<()>
    (((({<>}<{<{<>}{[]{[]{}
    [[<[([]))<([[{}[[()]]]
    [{[{({}]{}}([{[{{{}}([]
    {<[[]]>}<{[{[{[]{()[[[]
    [<(<(<(<{}))><([]([]()
    <{([([[(<>()){}]>(<<{{
    <{([{{}}[<[[[<>{}]]]>[]]
    """
const testarr = [
    "[({(<(())[]>[[{[]{<()<>>",
    "[(()[<>])]({[<{<<[]>>(",
    "{([(<{}[<>[]}>{[]{[(<()>",
    "(((({<>}<{<{<>}{[]{[]{}",
    "[[<[([]))<([[{}[[()]]]",
    "[{[{({}]{}}([{[{{{}}([]",
    "{<[[]]>}<{[{[{[]{()[[[]",
    "[<(<(<(<{}))><([]([]()",
    "<{([([[(<>()){}]>(<<{{",
    "<{([{{}}[<[[[<>{}]]]>[]]",
]

@testset "d10" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test is_corrupted("()") == 0
    @test is_corrupted("(]") == corrupt_score[']']
    @test is_corrupted("]") == corrupt_score[']']
    @test is_corrupted("(<>()<>{})") == 0
    @test is_corrupted("(){}<>[]") == 0
    @test is_corrupted("((([[[<<<") == 0
    @test is_corrupted("{()()()>") == corrupt_score['>']
    @test is_corrupted("(((()))}") == corrupt_score['}']
    @test is_corrupted("<([]){()}[{}])") == corrupt_score[')']
    @test part1(testarr) == 26397
    @test part2(testarr) == 288957
    @test solve(IOBuffer(teststr)) == (26397, 288957)
end

end

module d10

using Chain
using InlineTest
using DataStructures

const chars = Dict(
    '(' => ')',
    '[' => ']',
    '<' => '>',
    '{' => '}',
)
# I spent hours debugging only to realise I had the } and > the wrong way around in this Dict
const score = Dict(
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
        elseif isempty(s)       # This doesn't actually every happen which is nice of them
            return score[c]
        else # c ∈ values(chars)
            needs_to_be_closed = pop!(s)
            if chars[needs_to_be_closed] != c
                return score[c]
            end
        end
    end
    return 0
end

part1(d) = mapreduce(is_corrupted, +, d)
part2(d) = nothing

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
    @test is_corrupted("(]") == score[']']
    @test is_corrupted("]") == score[']']
    @test is_corrupted("(<>()<>{})") == 0
    @test is_corrupted("(){}<>[]") == 0
    @test is_corrupted("((([[[<<<") == 0
    @test is_corrupted("{()()()>") == score['>']
    @test is_corrupted("(((()))}") == score['}']
    @test is_corrupted("<([]){()}[{}])") == score[')']
    @test part1(testarr) == 26397
    # @test part2(testarr) == nothing
    # @test solve(IOBuffer(teststr)) == (26397, nothing)
end

end

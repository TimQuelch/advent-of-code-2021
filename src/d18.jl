module d18

using Chain
using InlineTest
using AbstractTrees
using JSON

import Base.==
import Base.+
import Base.parse
import Base.show

abstract type SFNumber end

mutable struct SFRegular <: SFNumber
    i::Int
    parent::Union{SFNumber,Nothing}
end

mutable struct SFPair <: SFNumber
    l::SFNumber
    r::SFNumber
    parent::Union{SFNumber,Nothing}
end

# Recursive construction of numbers from 2 valued iterables and ints
SFNumber(x::Integer) = SFRegular(x, nothing)
SFNumber(x) = SFPair(SFNumber(x[1]), SFNumber(x[2]), nothing)

# Equality
==(a::SFRegular, b::SFRegular) = a.i == b.i
==(a::SFPair, b::SFPair) = a.l == b.l && a.r == b.r

# Define the tree structure
AbstractTrees.children(x::SFPair) = (x.l, x.r)
AbstractTrees.children(x::SFRegular) = tuple()

depth(x::SFNumber) = isnothing(x.parent) ? 1 : (1 + depth(x.parent))

# Nicer printing
show(io::IO, x::SFRegular) = print(io, "$(x.i)")
show(io::IO, x::SFPair) = print(io, "[$(x.l),$(x.r)]")

# Luckily these numbers are valid JSON so I can just steal their parsing logic
function parse(::Type{SFNumber}, s)
    s = JSON.parse(s)
    # @info "json" s
    SFNumber(s)
end

function resetparents!(num)
    num.parent = nothing
    for n in PreOrderDFS(num)
        cs = children(n)
        for c in cs
            c.parent = n
        end
    end
end

is_explodable(n) = typeof(n) == SFPair && depth(n) > 4
is_splitable(n) = typeof(n) == SFRegular && n.i > 9
is_reducible(n) = any(n -> is_explodable(n) || is_splitable(n), PostOrderDFS(n))

function explode!(n)
    ns = collect(PostOrderDFS(n))
    nums = filter(n -> typeof(n) == SFRegular, ns)
    pairs = filter(n -> typeof(n) == SFPair, ns)
    explodable_i = findfirst(is_explodable, pairs)

    @assert typeof(pairs[explodable_i]) == SFPair
    @assert typeof(pairs[explodable_i].l) == SFRegular
    @assert typeof(pairs[explodable_i].r) == SFRegular

    li = findfirst(n -> n === pairs[explodable_i].l, nums)
    ri = findfirst(n -> n === pairs[explodable_i].r, nums)
    pi = findfirst(n -> n === pairs[explodable_i].parent, pairs)
    isleftchild = pairs[pi].l === pairs[explodable_i]

    if isleftchild
        pairs[pi].l = SFNumber(0)
    else
        pairs[pi].r = SFNumber(0)
    end

    if checkbounds(Bool, nums, li - 1)
        nums[li - 1].i += nums[li].i
    end

    if checkbounds(Bool, nums, ri + 1)
        nums[ri + 1].i += nums[ri].i
    end
end

function split!(n)
    ns = collect(PostOrderDFS(n))
    nums = filter(n -> typeof(n) == SFRegular, ns)
    pairs = filter(n -> typeof(n) == SFPair, ns)
    splitable_i = findfirst(is_splitable, nums)
    pi = findfirst(n -> n === nums[splitable_i].parent, pairs)
    isleftchild = pairs[pi].l === nums[splitable_i]

    newchild = SFNumber((
        fld(nums[splitable_i].i, 2),
        cld(nums[splitable_i].i, 2)
    ))

    if isleftchild
        pairs[pi].l = newchild
    else
        pairs[pi].r = newchild
    end
end

function reduce!(n)
    resetparents!(n)
    while is_reducible(n)
        ns = collect(PostOrderDFS(n))
        explodable_i = findfirst(is_explodable, ns)
        if !isnothing(explodable_i)
            explode!(n)
        else
            split!(n)
        end
        resetparents!(n)
    end
end

function +(a::SFNumber, b::SFNumber)
    c = SFPair(deepcopy(a), deepcopy(b), nothing)
    reduce!(c)
    return c
end
+(::Nothing, b::SFNumber) = b

magnitude(x::SFRegular) = x.i
magnitude(x::SFPair) = 3 * magnitude(x.l) + 2 * magnitude(x.r)

part1(d) = magnitude(foldl(+, d))

function part2(d)
    pairs = Iterators.product(eachindex(d), eachindex(d))
    mags = map(ii -> magnitude(d[ii[1]] + d[ii[2]]), pairs)
    return maximum(mags)
end

parseinput(io) = mapreduce(vcat, eachline(io)) do l
    parse(SFNumber, l)
end
solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    [1,2]
    [[1,2],3]
    [9,[8,7]]
    [[1,9],[8,5]]
    [[[[1,2],[3,4]],[[5,6],[7,8]]],9]
    [[[9,[3,8]],[[0,9],6]],[[[3,7],[4,9]],3]]
    [[[[1,3],[5,3]],[[1,3],[8,7]]],[[[4,9],[6,9]],[[8,2],[7,3]]]]
    """
const teststr2 = """
    [[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
    [[[5,[2,8]],4],[5,[[9,9],0]]]
    [6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
    [[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
    [[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
    [[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
    [[[[5,4],[7,7]],8],[[8,3],8]]
    [[9,3],[[9,9],[6,[4,9]]]]
    [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
    [[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
    """
const testarr = [
    SFNumber([1,2]),
    SFNumber([[1,2],3]),
    SFNumber([9,[8,7]]),
    SFNumber([[1,9],[8,5]]),
    SFNumber([[[[1,2],[3,4]],[[5,6],[7,8]]],9]),
    SFNumber([[[9,[3,8]],[[0,9],6]],[[[3,7],[4,9]],3]]),
    SFNumber([[[[1,3],[5,3]],[[1,3],[8,7]]],[[[4,9],[6,9]],[[8,2],[7,3]]]]),
]

@testset "d18" begin
    @test parse(SFNumber, "[1,2]") == SFNumber((1, 2))
    @test parse(SFNumber, "[[[[1,2],[3,4]],[[5,6],[7,8]]],9]") == SFNumber([[[[1,2],[3,4]],[[5,6],[7,8]]],9])
    @test parse(SFNumber, "[[[[1,3],[5,3]],[[1,3],[8,7]]],[[[4,9],[6,9]],[[8,2],[7,3]]]]") == SFNumber([[[[1,3],[5,3]],[[1,3],[8,7]]],[[[4,9],[6,9]],[[8,2],[7,3]]]])
    @test parseinput(IOBuffer(teststr)) == testarr
    @test magnitude(SFNumber([[1,2],[[3,4],5]])) == 143
    @test magnitude(SFNumber([[[[0,7],4],[[7,8],[6,0]]],[8,1]])) == 1384
    @test magnitude(SFNumber([[[[1,1],[2,2]],[3,3]],[4,4]])) == 445
    @test magnitude(SFNumber([[[[3,0],[5,3]],[4,4]],[5,5]])) == 791
    @test magnitude(SFNumber([[[[5,0],[7,4]],[5,5]],[6,6]])) == 1137
    @test magnitude(SFNumber([[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]])) == 3488
    @test SFNumber([[[[4,3],4],4],[7,[[8,4],9]]]) + SFNumber([1, 1]) == SFNumber([[[[0,7],4],[[7,8],[6,0]]],[8,1]])
    @test foldl(+, SFNumber.([[1, 1], [2, 2], [3, 3], [4, 4]])) == SFNumber([[[[1,1],[2,2]],[3,3]],[4,4]])
    @test foldl(+, SFNumber.([[1, 1], [2, 2], [3, 3], [4, 4], [5, 5]])) == SFNumber([[[[3,0],[5,3]],[4,4]],[5,5]])
    @test foldl(+, SFNumber.([[1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6]])) == SFNumber([[[[5,0],[7,4]],[5,5]],[6,6]])
    @test part1(parseinput(IOBuffer(teststr2))) == 4140
    @test part2(parseinput(IOBuffer(teststr2))) == 3993
    @test solve(IOBuffer(teststr2)) == (4140, 3993)
end

end

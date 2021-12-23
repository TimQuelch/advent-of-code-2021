module d16

using Chain
using InlineTest
using AbstractTrees

function hex2bitvec(s)
    @chain s begin
        hex2bytes
        map(b -> digits(b, base=2, pad=8), _)
        map(reverse, _)
        reduce(vcat, _)
        map(Bool, _)
    end
end

bitvec2int(v) = 2 .^((length(v)-1):-1:0) .* v |> sum

abstract type AbstractPacket end

struct LiteralPacket
    version
    value
    bitvec
end

function LiteralPacket(v)
    version = bitvec2int(v[1:3])
    offset = 7
    num = []
    while v[offset] == true
        append!(num, v[offset+1:offset+4])
        offset += 5
    end
    append!(num, v[offset+1:offset+4])
    return LiteralPacket(version, bitvec2int(num), @view v[1:offset+4])
end

AbstractTrees.children(x::LiteralPacket) = []

struct OperatorPacket
    version
    type
    bitvec
    children
end

AbstractTrees.children(x::OperatorPacket) = x.children

function OperatorPacket(v)
    version = bitvec2int(v[1:3])
    type = bitvec2int(v[4:6])
    childtype = v[7]

    if childtype
        @info "Operator n children"
        @show nchildren = bitvec2int(v[8:(8+11-1)])
        children, clength = read_n_children(v[(8+11):end], nchildren)
    else
        @info "Operator n bits children"
        @show nbits = bitvec2int(v[8:(8+15-1)])
        children, clength = read_nbits_children(v[(8+15):end], nbits)
    end

    return OperatorPacket(version, type, v[1:(8+clength)], children)
end

function read_n_children(v, nchildren)
    offset = 1
    children = []
    for _ in 1:nchildren
        p, l = readpacket(v[offset:end])
        push!(children, p)
        offset += l
    end
    return children, offset - 1
end

function read_nbits_children(v, nbits)
    offset = 1
    children = []
    while offset < nbits
        p, l = readpacket(v[offset:end])
        push!(children, p)
        offset += l
    end
    @assert (offset-1) == nbits
    return children, nbits
end

function readpacket(v)
    @info "Reading packet" v
    type = bitvec2int(v[4:6])
    if type == 4
        @info "Reading literal"
        p = LiteralPacket(v)
        @info "Read literal packet" p
    else
        @info "Reading operator"
        p = OperatorPacket(v)
        @info "Read operator packet" p
    end
    return p, length(p.bitvec)
end

function versionsum(x)
    packets = collect(PostOrderDFS(x))
    return mapreduce(x -> x.version, +, packets)
end

part1(d) = nothing
part2(d) = nothing

parseinput(io) = mapreduce(vcat, eachline(io)) do l
    @chain l begin
        l
    end
end
solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

@testset "d16" begin
    @test hex2bitvec("D2FE28") == Bool[
        1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0
    ]
    @test hex2bitvec("38006F45291200") == Bool[
        0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 0,
        0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    ]
    @test bitvec2int(Bool[1,]) == 1
    @test bitvec2int(Bool[0, 1]) == 1
    @test bitvec2int(Bool[1, 1]) == 3
    @test bitvec2int(Bool[1, 0, 1]) == 5
    @test bitvec2int(Bool[1, 0, 0]) == 4
    @test readpacket(hex2bitvec("D2FE28"))[1].version == 6
    @test readpacket(hex2bitvec("D2FE28"))[1].value == bitvec2int([0, 1, 1, 1, 1, 1, 1, 0, 0, 1, 0, 1])
    @test readpacket(hex2bitvec("D2FE28"))[2] == length("VVVTTTAAAAABBBBBCCCCC")
    @test readpacket(hex2bitvec("38006F45291200"))[1].version == 1
    @test readpacket(hex2bitvec("38006F45291200"))[1].type == 6
    @test readpacket(hex2bitvec("38006F45291200"))[1].children |> length == 2
    @test readpacket(hex2bitvec("38006F45291200"))[1].children[1].value == 10
    @test readpacket(hex2bitvec("38006F45291200"))[1].children[2].value == 20
    @test readpacket(hex2bitvec("EE00D40C823060"))[1].version == 7
    @test readpacket(hex2bitvec("EE00D40C823060"))[1].type == 3
    @test readpacket(hex2bitvec("EE00D40C823060"))[1].children |> length == 3
    @test readpacket(hex2bitvec("EE00D40C823060"))[1].children[1].value == 1
    @test readpacket(hex2bitvec("EE00D40C823060"))[1].children[2].value == 2
    @test readpacket(hex2bitvec("EE00D40C823060"))[1].children[3].value == 3
    @test readpacket(hex2bitvec("8A004A801A8002F478"))[1] |> versionsum == 16
    # @test readpacket(hex2bitvec("620080001611562C8802118E34"))[1] |> versionsum == 12
    # @test readpacket(hex2bitvec("C0015000016115A2E0802F182340")) |> versionsum == 23
    # @test readpacket(hex2bitvec("A0016C880162017C3686B18A3D4780")) |> versionsum == 31
    # @test parseinput(IOBuffer(teststr)) == testarr
    # @test part1(testarr) == nothing
    # @test part2(testarr) == nothing
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end

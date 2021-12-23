module d17

using Chain
using InlineTest

xintarget(d, x) = (d[1][1] <= x <= d[1][2])
yintarget(d, y) = (d[2][1] <= y <= d[2][2])
intarget(d, p) = xintarget(d, p[1]) && yintarget(d, p[2])
xpointsvalid(d, xs) = any(x -> xintarget(d, x), xs)
ypointsvalid(d, ys) = any(y -> yintarget(d, y), ys)

function xpoints(v, max)
    p = [0]
    while p[end] <= max && (length(p) < 2 || p[end] != p[end-1])
        push!(p, p[end] + v)
        if v > 0
            v -= 1
        elseif v < 0
            v += 1
        end
    end
    return p
end

function ypoints(v, min)
    p = [0]
    while min <= p[end]
        push!(p, p[end] + v)
        v -= 1
    end
    return p
end

function xvals(d)
    maxx = d[1][2]+1
    for i in 1:maxx
        xp = xpoints(i, maxx)
        @show xp, xpointsvalid(d, xp)
    end
end

function yvals(d)
    miny = d[2][1]-1
    maxy = 30
    for i in miny:maxy
        yp = ypoints(i, miny)
        @show yp, ypointsvalid(d, yp)
    end
end

part1(d) = yvals(d)
part2(d) = nothing

function parseinput(io)
    s = readline(io)
    m = match(r"x=(-?[0-9]+)..(-?[0-9]+), y=(-?[0-9]+)..(-?[0-9]+)", s)
    v = parse.(Int, (m[1], m[2], m[3], m[4]))
    return ((v[1], v[2]), (v[3], v[4]))
end
solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = "target area: x=20..30, y=-10..-5"
const testarr = ((20, 30), (-10, -5))

@testset "d17" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    # @test part1(testarr) == nothing
    # @test part2(testarr) == nothing
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end

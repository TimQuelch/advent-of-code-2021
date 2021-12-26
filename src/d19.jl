module d19

using Chain
using InlineTest
using LinearAlgebra
using StatsBase

function calcrotations()
    permutations = [
        [1, 2, 3],
        [1, 3, 2],
        [2, 1, 3],
        [2, 3, 1],
        [3, 1, 2],
        [3, 2, 1],
    ]
    negatives = map([
        [0, 0, 0],
        [0, 0, 1],
        [0, 1, 0],
        [0, 1, 1],
        [1, 0, 0],
        [1, 0, 1],
        [1, 1, 0],
        [1, 1, 1],
    ]) do x
        2 .* x .- 1
    end
    @chain begin
        Iterators.product(permutations, negatives)
        map(_) do (p, n)
            m = diagm(n)
            for r in eachcol(m)
                permute!(r, p)
            end
            return m
        end
        filter(m -> det(m) == 1, _)
    end
end
const rotations = calcrotations()

function distmatrix(ps)
    map(Iterators.product(ps, ps)) do (a, b)
        norm(a .- b)
    end
end

centroid(ps) = reduce(+, ps) ./ length(ps)

function rand_submatrix(dmx, n)
    @assert size(dmx, 1) == size(dmx, 2)
    is = sample(1:size(dmx, 1), n, replace=false, ordered=true)
    return @view dmx[is, is]
end

function find_matching_points(ps1, ps2)
    N = 4
    dmx1, dmx2 = distmatrix.((ps1, ps2))
    for _ in 1:1000
        is1 = sample(1:size(dmx1, 1), n, replace=false, ordered=true)
        is2 = sample(1:size(dmx2, 1), n, replace=false, ordered=true)
        if isapprox(det(@view dmx1[is1, is1]), det(@view dmx2[is2, is2]))
            return [is1, is2]
        end
    end
    @info "No matches found"
end

function part1(d)
    beacons = d[1]              # Accept the first scanner as truth
    for i in 2:length(d)
        for j in 1:1000
            1
        end
    end
end

part2(d) = nothing

function parseinput(io)
    map(split(read(io, String), r"--- scanner [0-9]+ ---", keepempty=false)) do s
        map(split(s, "\n", keepempty=false)) do l
            @chain l begin
                split(",")
                map(x -> parse(Int, x), _)
            end
        end
    end
end
solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    --- scanner 0 ---
    404,-588,-901
    528,-643,409
    -838,591,734
    390,-675,-793
    -537,-823,-458
    -485,-357,347
    -345,-311,381
    -661,-816,-575
    -876,649,763
    -618,-824,-621
    553,345,-567
    474,580,667
    -447,-329,318
    -584,868,-557
    544,-627,-890
    564,392,-477
    455,729,728
    -892,524,684
    -689,845,-530
    423,-701,434
    7,-33,-71
    630,319,-379
    443,580,662
    -789,900,-551
    459,-707,401

    --- scanner 1 ---
    686,422,578
    605,423,415
    515,917,-361
    -336,658,858
    95,138,22
    -476,619,847
    -340,-569,-846
    567,-361,727
    -460,603,-452
    669,-402,600
    729,430,532
    -500,-761,534
    -322,571,750
    -466,-666,-811
    -429,-592,574
    -355,545,-477
    703,-491,-529
    -328,-685,520
    413,935,-424
    -391,539,-444
    586,-435,557
    -364,-763,-893
    807,-499,-711
    755,-354,-619
    553,889,-390

    --- scanner 2 ---
    649,640,665
    682,-795,504
    -784,533,-524
    -644,584,-595
    -588,-843,648
    -30,6,44
    -674,560,763
    500,723,-460
    609,671,-379
    -555,-800,653
    -675,-892,-343
    697,-426,-610
    578,704,681
    493,664,-388
    -671,-858,530
    -667,343,800
    571,-461,-707
    -138,-166,112
    -889,563,-600
    646,-828,498
    640,759,510
    -630,509,768
    -681,-892,-333
    673,-379,-804
    -742,-814,-386
    577,-820,562

    --- scanner 3 ---
    -589,542,597
    605,-692,669
    -500,565,-823
    -660,373,557
    -458,-679,-417
    -488,449,543
    -626,468,-788
    338,-750,-386
    528,-832,-391
    562,-778,733
    -938,-730,414
    543,643,-506
    -524,371,-870
    407,773,750
    -104,29,83
    378,-903,-323
    -778,-728,485
    426,699,580
    -438,-605,-362
    -469,-447,-387
    509,732,623
    647,635,-688
    -868,-804,481
    614,-800,639
    595,780,-596

    --- scanner 4 ---
    727,592,562
    -293,-554,779
    441,611,-461
    -714,465,-776
    -743,427,-804
    -660,-479,-426
    832,-632,460
    927,-485,-438
    408,393,-506
    466,436,-512
    110,16,151
    -258,-428,682
    -393,719,612
    -211,-452,876
    808,-476,-593
    -575,615,604
    -485,667,467
    -680,325,-822
    -627,-443,-432
    872,-547,-609
    833,512,582
    807,604,487
    839,-516,451
    891,-625,532
    -652,-548,-490
    30,-46,-14
    """
const testarr = [
    [
        (404,-588,-901),
        (528,-643,409),
        (-838,591,734),
        (390,-675,-793),
        (-537,-823,-458),
        (-485,-357,347),
        (-345,-311,381),
        (-661,-816,-575),
        (-876,649,763),
        (-618,-824,-621),
        (553,345,-567),
        (474,580,667),
        (-447,-329,318),
        (-584,868,-557),
        (544,-627,-890),
        (564,392,-477),
        (455,729,728),
        (-892,524,684),
        (-689,845,-530),
        (423,-701,434),
        (7,-33,-71),
        (630,319,-379),
        (443,580,662),
        (-789,900,-551),
        (459,-707,401),
    ],
    [
        (686,422,578),
        (605,423,415),
        (515,917,-361),
        (-336,658,858),
        (95,138,22),
        (-476,619,847),
        (-340,-569,-846),
        (567,-361,727),
        (-460,603,-452),
        (669,-402,600),
        (729,430,532),
        (-500,-761,534),
        (-322,571,750),
        (-466,-666,-811),
        (-429,-592,574),
        (-355,545,-477),
        (703,-491,-529),
        (-328,-685,520),
        (413,935,-424),
        (-391,539,-444),
        (586,-435,557),
        (-364,-763,-893),
        (807,-499,-711),
        (755,-354,-619),
        (553,889,-390),
    ],
    [
        (649,640,665),
        (682,-795,504),
        (-784,533,-524),
        (-644,584,-595),
        (-588,-843,648),
        (-30,6,44),
        (-674,560,763),
        (500,723,-460),
        (609,671,-379),
        (-555,-800,653),
        (-675,-892,-343),
        (697,-426,-610),
        (578,704,681),
        (493,664,-388),
        (-671,-858,530),
        (-667,343,800),
        (571,-461,-707),
        (-138,-166,112),
        (-889,563,-600),
        (646,-828,498),
        (640,759,510),
        (-630,509,768),
        (-681,-892,-333),
        (673,-379,-804),
        (-742,-814,-386),
        (577,-820,562),
    ],
    [
        (-589,542,597),
        (605,-692,669),
        (-500,565,-823),
        (-660,373,557),
        (-458,-679,-417),
        (-488,449,543),
        (-626,468,-788),
        (338,-750,-386),
        (528,-832,-391),
        (562,-778,733),
        (-938,-730,414),
        (543,643,-506),
        (-524,371,-870),
        (407,773,750),
        (-104,29,83),
        (378,-903,-323),
        (-778,-728,485),
        (426,699,580),
        (-438,-605,-362),
        (-469,-447,-387),
        (509,732,623),
        (647,635,-688),
        (-868,-804,481),
        (614,-800,639),
        (595,780,-596),
    ],
    [
        (727,592,562),
        (-293,-554,779),
        (441,611,-461),
        (-714,465,-776),
        (-743,427,-804),
        (-660,-479,-426),
        (832,-632,460),
        (927,-485,-438),
        (408,393,-506),
        (466,436,-512),
        (110,16,151),
        (-258,-428,682),
        (-393,719,612),
        (-211,-452,876),
        (808,-476,-593),
        (-575,615,604),
        (-485,667,467),
        (-680,325,-822),
        (-627,-443,-432),
        (872,-547,-609),
        (833,512,582),
        (807,604,487),
        (839,-516,451),
        (891,-625,532),
        (-652,-548,-490),
        (30,-46,-14),
    ]
]

@testset "d19" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    # @test part1(testarr) == nothing
    # @test part2(testarr) == nothing
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end

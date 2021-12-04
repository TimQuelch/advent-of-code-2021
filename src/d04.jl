module d04

using Chain
using InlineTest

# Check whether a board has won with a provided set of numbers. The mask of marked numbers is built
# each time every number for every board. A more efficient solution might incrementally build up the
# mask with each successive number (i.e. saving the mask between numbers), but this method performs
# well enough for our purposes
function checkboard(board, numbers)
    mask = map(in(numbers), board) # Find the numbers which are marked
    return any(all(mask, dims=1)) || any(all(mask, dims=2)) # Check rows and columns for win
end

function scoreboard(board, numbers)
    mask = map(!in(numbers), board) # 1 where numbers unmarked, 0 elsewhere
    return sum(mask .* board) * numbers[end]
end

function part1(d)
    order, boards = d
    # No board can win before at least 5 numbers drawn
    for i in 5:length(order)
        numbers = @view order[1:i] # The numbers which have been drawn so far
        # Check to see if any boards have won, return the index of winner, or nothing
        winner = findnext(b -> checkboard(b, numbers), boards, 1)
        # If winner, return the score of the winner
        if !isnothing(winner)
            return scoreboard(boards[winner], numbers)
        end
    end
    # Hopefully this never happens (it would mean no boards won. or i broke something)
    return nothing
end

function part2(d)
    order, boards = d
    for i in length(order):-1:5 # Start from the end of the numbers instead
        numbers = @view order[1:i]
        # Check to see if any boards hve not won yet
        winner = findnext(b -> !checkboard(b, numbers), boards, 1)
        if !isnothing(winner)
            # Return the score after the next number is drawn (triggering the actual win)
            return scoreboard(boards[winner], @view order[1:(i+1)])
        end
    end
    return nothing
end

function parseinput(io)
    # Read and parse the order of numbers
    orderstr = readline(io)
    order = map(s -> parse(Int, s), split(orderstr, ","))

    # Read the boards (bear with me here)
    boards = @chain eachline(io) begin
        map(split, _)                           # Split every line by whitespace
        filter(!isempty, _)                     # Remove the empty lines
        map(v -> map(s -> parse(Int, s), v), _) # Parse each number in each row to ints
        Iterators.partition(_, 5)               # Split into groups of 5 (the boards)
        map(board -> transpose(reduce(hcat, board)), _) # Combine each into a 5x5 matrix
    end

    return (order, boards)
end
solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

    22 13 17 11  0
    8  2 23  4 24
    21  9 14 16  7
    6 10  3 18  5
    1 12 20 15 19

    3 15  0  2 22
    9 18 13 17  5
    19  8  7 25 23
    20 11 10 24  4
    14 21 16 12  6

    14 21 17 24  4
    10 16 15  9 19
    18  8 23 26 20
    22 11 13  6  5
    2  0 12  3  7
    """
const testorder = [7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1]
const testboards = [
    [
        22 13 17 11  0
        8   2 23  4 24
        21  9 14 16  7
        6  10  3 18  5
        1  12 20 15 19
    ],
    [
        3  15  0  2 22
        9  18 13 17  5
        19  8  7 25 23
        20 11 10 24  4
        14 21 16 12  6
    ],
    [
        14 21 17 24  4
        10 16 15  9 19
        18  8 23 26 20
        22 11 13  6  5
        2   0 12  3  7
    ],
]

const exboard = [1 2 3; 4 5 6; 7 8 9]

@testset "d04" begin
    @test parseinput(IOBuffer(teststr))[1] == testorder
    @test parseinput(IOBuffer(teststr))[2] == testboards
    @test checkboard(exboard, [1, 2, 3]) == true
    @test checkboard(exboard, [7, 8, 9]) == true
    @test checkboard(exboard, [1, 4, 7, 1, 2, 3]) == true
    @test checkboard(exboard, [1, 5, 9]) == false
    @test checkboard(exboard, [5]) == false
    @test scoreboard(exboard, [1, 2, 3]) == sum(4:9) * 3
    @test scoreboard(exboard, [1, 4, 7, 1, 2, 3]) == sum([5, 6, 8, 9]) * 3
    @test part1((testorder, testboards)) == 4512
    @test part2((testorder, testboards)) == 1924
    @test solve(IOBuffer(teststr)) == (4512, 1924)
end

end

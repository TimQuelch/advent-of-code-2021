# Advent of Code 2021

My solutions to the [Advent of Code 2021](https://adventofcode.com) in Julia

## Running

Problems can be solved from the REPL

``` julia
] activate .
using AdventOfCode
solve() # solves all implemented problems with my data
solve(2) # solves a specific day with my data
AdventOfCode.d01.solve(open("path/to/data/file")) # solves day 1 with a specified data file
AdventOfCode.d02.solve(IOBuffer("datastring")) # solves day 2 with a data string
```

## Testing

To run all tests
``` julia
] activate .
] test
```

To run specific tests for a specific day
``` julia
using ReTest
using AdventOfCode
AdventOfCode.runtests() # All tests
AdventOfCode.d01.runtests() # Day 1 tests
```

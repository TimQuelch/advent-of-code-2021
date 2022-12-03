#!/bin/bash

day=$1
daystr=$(printf "%02d" $1)
cp "src/template.jl"  "src/d${daystr}.jl"
sed -i "s/DAYCODE/d${daystr}/g" "src/d${daystr}.jl"
sed -i "s/days = \[\(.*\)\]/days = \[\1, ${day}\]/g" "src/AdventOfCode2021.jl"
aocd "${day}" 2021 > "data/d${daystr}.txt"

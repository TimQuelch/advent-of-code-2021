#!/bin/bash

code=$1
cp "src/template.jl"  "src/${code}.jl"
sed -i "s/DAYCODE/${code}/g" "src/${code}.jl"

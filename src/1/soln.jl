using DelimitedFiles
using Chain
using Printf
using DSP

d = readdlm(joinpath(@__DIR__, "input.csv"), '\n', Int)[:]

@printf "Number of increases is %d\n" @chain d begin
    diff
    count(>(0), _)
end

N = 3
@printf "Number of increases in moving average is %d\n" @chain d begin
    conv(_, ones(N))
    _[N:end-(N-1)]
    diff
    count(>(0), _)
end

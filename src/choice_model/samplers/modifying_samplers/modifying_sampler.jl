# a modifying sampler modifies one or more distribution samplers or other modifying samplers
# TODO perhaps better name is "MetaSampler"?

abstract ModifyingSampler <: Sampler

paramranges(s::ModifyingSampler) = paramranges(s.subsampler)

getparams(s::ModifyingSampler) = getparams(s.subsampler)

setparams!(s::ModifyingSampler, params) = setparams!(s.subsampler, params)

function sample(s::ModifyingSampler, support, cc::ChoiceContext)
	x, trace = sample(s.subsampler, support, cc)
	x, Dict{Symbol, Any}(:sub=>trace)
end

estimateparams!(s::ModifyingSampler, traces) = estimateparams!(s.subsampler, map(trace->trace[:sub], traces))

amendtrace(s::ModifyingSampler, trace, x) = amendtrace(s.subsampler, trace[:sub], x)

# modifying samplers without a single subsampler, or with more info to display, will need to override
function show(io::IO, s::ModifyingSampler, indentdepth::Int=1)
	print(io, getsamplertypename(s) * " ")
	# note, no newline - keeping the entire output on one line if possible - the root subsampler(s) will handle the newline
	show(io, s.subsampler, indentdepth)
end

include("mixture_sampler.jl")
include("adjust_parameters_to_support_sampler.jl")
include("align_minimum_support_sampler.jl")
include("truncate_to_support_sampler.jl")
include("transform_sampler.jl")
include("constrain_parameters_sampler.jl")
include("conditional_sampler.jl")
include("recursion_depth_sampler.jl")


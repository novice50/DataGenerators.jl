# a distribution sampler samples from a named univariate parameter distribution; it ignores any support constraints
abstract DistributionSampler <: Sampler
abstract DiscreteDistributionSampler <: DistributionSampler
abstract ContinuousDistributionSampler <: DistributionSampler

paramranges(s::DistributionSampler) = copy(s.paramranges)

function sample(s::DistributionSampler, support, cc::ChoiceContext)
	x = rand(s.distribution)
	# we return both the sampled value, and a dict as trace information
	x, Dict{Symbol,Any}(:rnd=>x)
end

function extractsamplesfromtraces(s::DistributionSampler, traces)
	samples = map(trace->trace[:rnd], traces)
	convert(typeof(s) <: DiscreteDistributionSampler ? Vector{Int} : Vector{Float64}, samples)
end

# workaround for call to fit: it needs the unparameterised (primary) type of the distribution 
# otherwise function suffstats raises an error as there isn't a suitable method to use (in Distributions.jl 0.11.0+)
primarydistributiontype(d::Distribution) = typeof(d).name.primary

# for Normal, Uniform, and DiscreteUniform, there is a type-specific version that calls this with minsamples of 2
function estimateparams!(s::DistributionSampler, traces, minsamples::Int = 1)
	samples = extractsamplesfromtraces(s, traces)
	if length(samples) >= minsamples
		s.distribution = fit(primarydistributiontype(s.distribution), samples)
	end
end

amendtrace(s::DistributionSampler, trace, x) = trace[:rnd] = x

include("sampler_utils.jl")
include("bernoulli_sampler.jl")
include("categorical_sampler.jl")
include("discrete_uniform_sampler.jl")
include("geometric_sampler.jl")
include("normal_sampler.jl")
include("uniform_sampler.jl")
include("poisson_sampler.jl")

# pretty print the sampler
function show(io::IO, s::DistributionSampler, indentdepth::Int=1)
	# since this sampler will be a 'leaf' in the sampler tree, can finish with a new line
	println(io, getsamplertypename(s) * " $(getparams(s))")
end

minimumsupport(s::DistributionSampler) = minimum(s.distribution)

type TypeGenerationException <: Exception
	func::Symbol
	msg::AbstractString
	caught::Union{Exception, Void}
	function TypeGenerationException(func::Symbol, msg::AbstractString, caught::Union{Exception, Void}=nothing)
		new(func, msg, caught)
	end
end

include("type_utilities.jl")
include("type_parse.jl")
include("type_transform.jl")
include("type_build.jl")
include("type_generator_utilities.jl")

function type_rules(t::Type, supplementalts::Vector{Type}=Vector{Type}(), rulenameprefix="")
	ast = parse_type(t, supplementalts)
	transform_type_ast(ast)
	transform_ast(ast) # this standard transform (which analysis reachability) isn't really needed for a type, but included for consistency with other translators
	build_type_rules(ast, rulenameprefix)
end

function type_generator(io::IO, genname::Symbol, t::Type, supplementalts::Vector{Type}=Vector{Type}())
	rules = type_rules(t, supplementalts)
	description = "an instance of type $(t)"
	output_generator(io, genname, description, rules)
end

type_generator(genname::Symbol, t::Type, supplementalts::Vector{Type}=Vector{Type}()) = include_generator(genname, type_generator, t, supplementalts)
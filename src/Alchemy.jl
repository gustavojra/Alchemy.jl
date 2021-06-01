module Alchemy

using GLMakie
using GLMakie: GLFW, to_native
using Makie

abstract type AbstractMode end

struct SelectionMode <: AbstractMode end
struct InsertMode <: AbstractMode end

include("Particles.jl")
include("Interactions/Mouse.jl")
include("Interactions/Keyboard.jl")
include("Run.jl")

end # module
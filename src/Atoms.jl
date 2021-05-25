using Colors

import Base: push!

export Atom
export Bond
export Ensamble

include("Constants.jl")

struct Atom 
    sphere::Sphere{Float32}
    symbol::String
end

# Alias
Atoms = Vector{Atom}

struct Bond
    atom1::Atom
    atom2::Atom
    Bond(A1, A2) = A1 != A2 ? new(A1, A2) : error("Cannot create a bound withina single atom")
end

# Alias
Bonds = Vector{Bond}

function Atom(S::String, x::T, y::T, z::T) where T <: Number
    r = get_atom_radius(S)
    return Atom(Sphere(Point3f0(x,y,z), r), S)
end

struct Ensamble 
    scene::Scene
    atoms::Atoms
    bonds::Bonds
    drawn_atoms::Vector{Bool}
    drawn_bonds::Vector{Bool}
end

function Ensamble(atoms::Atoms = Atoms())
    s = Scene()
    bonds = find_bonds(atoms)
    drawn_atoms = [false for i = eachindex(atoms)]
    drawn_bonds = [false for i = eachindex(bonds)]
    return Ensamble(s, atoms, bonds, drawn_atoms, drawn_bonds)
end

function push!(E::Ensamble, A::Atom)
    push!(E.atoms, A)
    push!(E.drawn_atoms, false)
end

function push!(E::Ensamble, A::Bond)
    push!(E.bonds, A)
    push!(E.drawn_bonds, false)
end

function bind_atoms(E::Ensamble, i::Int, j::Int)
    A1 = E.atoms[i]
    A2 = E.atoms[j]
    push!(E, Bond(A1, A2))
end

function read_xyz(filename)

    out = Atom[]
    for l = eachline(filename)
        m = match(XYZ_REGEX, l)
        if m !== nothing
            S = String(m.captures[1])
            xyz = m.captures[2:end]
            @assert length(xyz) == 3
            xyz = parse.(Float32, xyz)
            push!(out, Atom(S, xyz...))
        end
    end
    return out
end

function find_bonds(As::Atoms)

    out = Bond[]
    for i in eachindex(As)
        r1 = get_center(As[i])
        for j in (i+1):length(As)
            r2 = get_center(As[j])
            d = √sum((r1 .- r2).^2)
            if d < 1.55
                push!(out, Bond(As[i], As[j]))
            end
        end
    end
    return out
end

delete!(E::Ensamble, n::Nothing) = nothing
function delete!(E::Ensamble, p::T) where T <: AbstractPlot
    i, = findall(x->x==p, E.scene.plots)
    delete!(E.scene, p)
    deleteat!(E.atoms, i)
    deleteat!(E.drawn_atoms, i)
end

get_center(A::Atom) = A.sphere.center
get_radius(A::Atom) = A.sphere.r

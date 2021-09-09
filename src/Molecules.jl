export @alchemy 

macro alchemy(block)
    mol = repr(block)
    mol = replace(mol, ";"=>"\n")
    mol = strip(filter(c->!occursin(c,"{}():"), mol))
    mol = String(mol)
    mol = Molecules.parse_string(mol)
    quote
        plot($mol)
    end
end

macro alchemy(mol::Symbol)
    return :(Alchemy.plot($mol)) |> esc
end

macro alchemy(fpath::String)
    mol = Molecules.parse_file(fpath)
    return :(Alchemy.plot($mol)) |> esc
end

function plot(atoms::Vector{T}) where T <: Molecules.Atom
    out = 0
    for i = eachindex(atoms)
        center = Point3f0(atoms[i].xyz)
        symbol = Molecules.symbol(atoms[i])
        r = symbol == "H" ? 0.3 : 0.5
        c = atom_color[symbol]

        sphere = Sphere(center, r)
        
        if i == 1
            out = mesh(sphere, show_axis=false, color=c)
        else    
            mesh!(sphere, color=c)
        end
    end

    # Add chemical bonds for close atoms
    for i in eachindex(atoms)
        A1 = atoms[i]
        r1 = A1.xyz
        for j in (i+1):length(atoms)
            A2 = atoms[j]
            r2 = A2.xyz
            d = √sum((r1 .- r2).^2)
            if d < 1.55
                xyz = [Point3f0(A1.xyz)]
                uvw = [Point3f0(A2.xyz - A1.xyz)]
                arrows!(xyz, uvw, linewidth=0.1, arrowsize=0.0, linecolor=stegeman)
            end
        end
    end

    return out
end


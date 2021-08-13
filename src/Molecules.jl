using PeriodicTable # TO BE REMOVED

function plot(atoms::Vector{T}) where T <: Molecules.Atom

    out = 0
    for i = eachindex(atoms)
        center = Point3f0(atoms[i].xyz)
        symbol = elements[atoms[i].Z].symbol # gross
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


export draw!

function draw!(E::Ensamble, A::Atom)
    mesh!(E.scene, A.sphere, show_axis=false, color=atom_color[A.symbol])
end

function draw!(E::Ensamble, B::Bond)
    xyz = get_center(B.atom1)
    uvw = get_center(B.atom2) - xyz
    arrows!(E.scene, [xyz],[uvw], linewidth=0.1, arrowsize=0.0, linecolor=stegeman)
end

function draw!(E::Ensamble)

    # Draw atoms
    for i = eachindex(E.atoms)
        if !E.drawn_atoms[i]
            draw!(E, E.atoms[i])
            E.drawn_atoms[i] = true
        end
    end

    # Draw bonds
    for i = eachindex(E.bonds)
        if !E.drawn_bonds[i]
            draw!(E, E.bonds[i])
            E.drawn_bonds[i] = true
        end
    end
end
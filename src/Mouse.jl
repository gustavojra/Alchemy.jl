function atom_under_mouse(E::Ensamble)
    obj, _ = mouse_selection(E.scene)
    if obj !== nothing
        for i = eachindex(E.atoms)
            if obj === E.atoms[i].plot
                return E.atoms[i]
            end
        end
    else
        return nothing
    end
end

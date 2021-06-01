using LinearAlgebra

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

function closest_atom(E::Ensamble, xyz::Point3f0)
    dist = zeros(Float32, length(E.atoms))
    for i = eachindex(dist)
        dist[i] = √sum((E.atoms[i].center .- xyz).^2)
    end
    return E.atoms[findmin(dist)[2]]
end

function create_atom_under_mouse(E::Ensamble)
    ori, dir = Makie.view_ray(E.scene)
    if length(E.atoms) > 0
        A = closest_atom(E, Point3f0(ori))
        xyz = ori .+ dir * norm(A.center .- ori)
        Atom(E, "N", xyz...)
    else
        xyz = ori .+ dir * 4
        Atom(E, "N", xyz...)
    end
end

function respond_mouse_event(E::Ensamble, M::SelectionMode, event)
    # Event involving left mouse
    if event.button == Mouse.left
        # On click
        if event.action == Mouse.press
            A = atom_under_mouse(E)
            if A === nothing
                clear_selection!(E)
                return false
            end
            select!(E, A)
            return false
        end
    end
    return false
end

function respond_mouse_event(E::Ensamble, M::InsertMode, event)
    # Event involving left mouse
    if event.button == Mouse.left
        # On click
        if event.action == Mouse.press
            A = atom_under_mouse(E)
            # If no atom under mouse, create one
            if A === nothing
                create_atom_under_mouse(E)
            end
            return true
        # On release
        else
            return false
        end
    end
    return false
end
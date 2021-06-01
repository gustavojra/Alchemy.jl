function respond_keyboard_event(E::Ensamble, M::SelectionMode, event)
    if event.key == Keyboard.i
        println("Insert Mode")
        E.mode = InsertMode()
    elseif event.key in (Keyboard.delete, Keyboard.d, Keyboard.x)
        to_be_deleted = Any[]
        for i in E.selected
            if i > 0
                push!(to_be_deleted, E.atoms[i])
            else
                push!(to_be_deleted, E.bonds[-i])
            end
        end

        for s in to_be_deleted
            delete!(E, s)
        end

        E.selected = Int[]
    end
    false
end

function respond_keyboard_event(E::Ensamble, M::InsertMode, event)
    if event.key == Keyboard.escape
        println("Selection Mode")
        E.mode = SelectionMode()
    end
    false
end
module Alchemy

using GLMakie
using GLMakie: GLFW, to_native
using Makie

include("Atoms.jl")
include("Mouse.jl")

function run(filename::String)
    E = Ensamble(filename)
    run(E)
end

function run(E::Ensamble=Ensamble())
    glfw_window = to_native(display(E.scene))

    on(E.scene.events.keyboardbutton) do event
        if event.key == Keyboard.escape
            GLFW.SetWindowShouldClose(glfw_window, true)
        elseif event.key == Keyboard.x
            println("x")
        end
        false
    end

    on(events(E.scene).mousebutton, priority=Int8(20)) do event
        # Event involving left mouse
        if event.button == Mouse.left
            # On click
            if event.action == Mouse.press
                nothing
            # On release
            else
                A = atom_under_mouse(E)
                if A === nothing
                    create_atom_under_mouse(E)
                end
            end
        elseif ispressed(E.scene, Mouse.right)
            A = atom_under_mouse(E)
            if A !== nothing
                delete!(E, A)
            end
        else
            nothing
        end
        false
    end
    
    E.scene
end

end # module
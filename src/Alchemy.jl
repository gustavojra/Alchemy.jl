module Alchemy

using GLMakie
using GLMakie: GLFW, to_native
using Makie

include("Atoms.jl")
include("Render.jl")

function run(filename::String)
    E = Ensamble(read_xyz(filename))
    run(E)
end

function run(E::Ensamble=Ensamble())
    glfw_window = to_native(display(E.scene))

    draw!(E)

    on(E.scene.events.keyboardbutton) do event
        if event.key == Keyboard.escape
            GLFW.SetWindowShouldClose(glfw_window, true)
        elseif event.key == Keyboard.x
            println("x")
        end
        false
    end

    on(events(E.scene).mousebutton, priority=Int8(20)) do event
        if ispressed(E.scene, Mouse.left)
            pos = mouseposition(E.scene)
            A = Atom("H", pos..., 0.0f0)
            push!(E, A)
            draw!(E)
        elseif ispressed(E.scene, Mouse.right)
            obj = mouse_selection(E.scene)
            delete!(E, obj[1])
        else
            nothing
        end
        false
    end
    
    E.scene
end


end # module
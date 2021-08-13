function run()
    E = Ensamble()
    run(E)
end
function run(filename::String)
    E = Ensamble(filename)
    run(E)
end

function run(E::Ensamble)
    #glfw_window = to_native(display(E.scene))

    #btn = Button(E.scene, label="Selection")

    #on(btn.clicks) do 
    #    E.mode = SelectionMode()
    #end

    # counts = Node([1, 4, 3, 7, 2])

    # fig[2, 1] = buttongrid = GridLayout(tellwidth = false)

    # buttonlabels = [@lift("Count: $($counts[i])") for i in 1:5]

    # buttons = buttongrid[1, 1:5] = [Button(fig, label = l) for l in buttonlabels]

    on(E.scene.events.keyboardbutton) do event
        respond_keyboard_event(E, E.mode, event)
    end

    on(events(E.scene).mousebutton, priority=Int8(20)) do event
        respond_mouse_event(E, E.mode, event)
    end

    E.scene
end
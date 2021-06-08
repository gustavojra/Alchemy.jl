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

    on(E.scene.events.keyboardbutton) do event
        respond_keyboard_event(E, E.mode, event)
    end

    on(events(E.scene).mousebutton, priority=Int8(20)) do event
        respond_mouse_event(E, E.mode, event)
    end

    E.scene
end
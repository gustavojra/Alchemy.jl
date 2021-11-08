using SphericalHarmonics
using LaTeXStrings
using Colors
using Distributions

export @fermiview

macro fermiview()
    quote
        try
            let mol = Fermi.Options.get("molstring")
                E = Ensamble()
                Alchemy.xyz_to!(E, mol)
                Alchemy.find_bonds!(E)
                Alchemy.run(E)
            end
        catch UndefVarError
            @error "Fermi.jl could not be found, try running `using Fermi` first."
        end
    end |> esc
end

function basis_function_eval(bf, x, y, z, ml)

    # Requested Ml must be less or greater than L
    @assert ml ≤ bf.l

    # If radius is zero, the result will be zero, except for S orbitals
    r2 = x^2 + y^2 + z^2

    if r2 < 1e-12 && bf.l > 0
        return 0.0
    end

    # Compute exponents
    out = exp.(-r2 .* bf.exp)
    # Multiply by coefficients
    out .*= bf.coef

    # Transform Cartesians to Sphericals for Harmonic calculation
    r = √r2
    θ = acos(z/r)
    ϕ = atan(y/x) + (x < 0 ? π : 0.0)

    Y = SphericalHarmonics.sphericalharmonic(θ, ϕ, bf.l, ml, SphericalHarmonics.RealHarmonics())

    return sum(out)*Y*r^bf.l
end

function get_position(bf, min, max, ml)
    while true
        x,y,z = rand(Uniform(min,max), 3)
        bf_val = basis_function_eval(bf, x, y, z, ml) ^ 2
        check_val = rand(Uniform(0,1))
        if bf_val > check_val
            return (x,y,z)
        end
    end
end

function plot_basis_function(bf, ml, grid_min, grid_max, grid_points, isovalue=:maximum)
    S = Scene()
    plot_basis_function!(S, bf, ml, grid_min, grid_max, grid_points, isovalue)
    return S
end

function plot_basis_function!(S::LScene, bf, ml, grid_min, grid_max, grid_points, isovalue=:maximum)


    if isovalue == :maximum
        iv = maximum(wf)
    else
        iv = isovalue
    end
    #ir = 0.05 * iv[]
    ir = 0.01

    negiv = lift(iv) do x
        -x
    end
    println(typeof(negiv))

    volume!(S, r, r, r, wf, algorithm = :iso, isorange = ir, isovalue =  iv)
    volume!(S, r, r, r, wf, algorithm = :iso, isorange = ir, isovalue = negiv)
    
    return S
end

function isoplot(bf, min, max, N)
    fig = Figure(resolution=(900,800))
    LScene(fig[1,1], tellheight=false, height=700, width=600)

    gui_grid = fig[1,2] = GridLayout(width = 250, tellheigth=false)

    # Ml select menu
    Label(gui_grid[1,1][1,1], L"m_l", textsize = 30.0f0)
    menu = Menu(gui_grid[1,1][1,2], options = collect(-bf.l:1:bf.l))

    # Isovalue slider
    ls = labelslider!(fig, "Isovalue", 0:0.01:0.5)#, tellheight = false)
    gui_grid[2,1] = ls.layout

    # Toggles
    togglegrid = gui_grid[3,1] = GridLayout(tellwidth=false)
    Toggle(togglegrid[1,1])
    Label(togglegrid[1,2], "Show axis")

    # Save button
    Button(gui_grid[4,1], label="Save", tellwidth=false)

    set_close_to!(ls.slider, 0.48)
    menu.selection[] = 0

    r = LinRange(min, max, N)

    iv = ls.slider.value
    negiv = lift(iv) do x
        -x
    end

    r = LinRange(min, max, N)
    wf = lift(menu.selection) do ml
        [basis_function_eval(bf, x, y, z, Integer(ml[])) for x = r, y = r, z = r]
    end

    volume!(r, r, r, wf, algorithm = :iso, isorange = 0.01, tellheight=false, 
            isovalue =  iv, show_axis=true, colormap = colormap("reds"), colorrange = (0, 0.5))
    volume!(r, r, r, wf, algorithm = :iso, isorange = 0.01, tellheight=false, 
            isovalue = negiv, show_axis=true, colormap = colormap("blues"), colorrange = (0, -0.5))

    return fig
end

function measure(bf, min, max, N)
    fig = Figure(resolution=(900,800))
    LScene(fig[1,1], tellheight=false, height=700, width=600)

    gui_grid = fig[1,2] = GridLayout(width = 250, tellheigth=false)

    # Ml select menu
    Label(gui_grid[1,1][1,1], L"m_l", textsize = 30.0f0)
    menu = Menu(gui_grid[1,1][1,2], options = collect(-bf.l:1:bf.l))

    add1 = Button(gui_grid[2,1][1,1], label="10")
    add10 = Button(gui_grid[2,1][1,2], label="100")
    add100 = Button(gui_grid[2,1][1,3], label="1000")

    addn = [add1, add10, add100]
    addvals = [10, 100, 1000]

    # Toggles
    togglegrid = gui_grid[3,1] = GridLayout(tellwidth=false)
    Toggle(togglegrid[1,1])
    Label(togglegrid[1,2], "Show axis")

    # Save button
    Button(gui_grid[4,1], label="Save", tellwidth=false)

    menu.selection[] = 0

    np = Node(N)

    points = lift(menu.selection) do ml 
        p = zeros(N,3)
        for i = 1:np[]
            p[i,:] .= get_position(bf, min, max, ml)
        end
        p
    end

    for i = eachindex(addn)
        on(addn[i].clicks) do n 
            newpoints = zeros(addvals[i],3)
            for j = 1:addvals[i]
                newpoints[j,:] .= get_position(bf, min, max, menu.selection[])
            end
            points[] = vcat(newpoints, points[])
        end
    end

    scatter!(points, color=:blue)#, ylims=(min, max))#, xlims=(min,max), zlims=(min,max))#, makersize=100.0)
    #xlims!(low = min, high = max)
    #xlims!(min, max)
    #zlims!(min, max)

    return fig
end

function animate_measure(bf, min, max, N, ml)
    fig = Figure(resolution=(900,800))
    lscene = LScene(fig[1,1], tellheight=false, height=700, width=600)

    init = 100
    points = Node(Point3f[])
    p = zeros(N,3)
    for i = 1:N
        p[i,:] .= get_position(bf, min, max, ml)
    end

    for i = 1:init
        push!(points[], Point3f(p[i,:]))
    end

    scatter!(p, axis=(; viewmode=:fit, limits=(min, max, min, max, min, max)))
    record(fig, "test.gif", init:N, framerate=60) do i
        push!(points[], Point3f(p[i,:]))
        notify(points)
    end
    return fig
end
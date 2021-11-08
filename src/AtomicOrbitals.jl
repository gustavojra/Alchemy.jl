using SphericalHarmonics
using LaTeXStrings
using Colors
using Distributions
import GaussianBasis: BasisFunction, BasisSet

function orbital_eval(bf::BasisFunction, x, y, z, ml; x0=0, y0=0, z0=0)

    # Requested Ml must be less or greater than L
    @assert ml ≤ bf.l

    # If radius is zero, the result will be zero, except for S orbitals
    X = x - x0
    Y = y - y0
    Z = z - z0

    r2 = X^2 + Y^2 + Z^2

    if r2 < 1e-12 && bf.l > 0
        return 0.0
    end

    # Compute exponents
    out = exp.(-r2 .* bf.exp)
    # Multiply by coefficients
    out .*= bf.coef

    # Transform Cartesians to Sphericals for Harmonic calculation
    r = √r2
    θ = acos(Z/r)
    ϕ = atan(Y/X) + (X < 0 ? π : 0.0)

    Y = SphericalHarmonics.sphericalharmonic(θ, ϕ, bf.l, ml, SphericalHarmonics.RealHarmonics())

    return sum(out)*Y*r^bf.l
end

function get_position(bf::BasisFunction, min, max, ml; x0=0, y0=0, z0=0)
    while true
        x,y,z = rand(Uniform(min,max), 3)
        bf_val = orbital_eval(bf, x, y, z, ml, x0=x0, y0=y0, z0=z0) ^ 2
        check_val = rand(Uniform(0,1))
        if bf_val > check_val
            return (x,y,z)
        end
    end
end

function isoplot(bf::BasisFunction, min, max, N; x0=0, y0=0, z0=0)
    fig = Figure(resolution=(900,800))
    lscene = LScene(fig[1,1], tellheight=false, height=700, width=600)

    gui_grid = fig[1,2] = GridLayout(width = 250, tellheigth=false)

    # Ml select menu
    Label(gui_grid[1,1][1,1], L"m_l", textsize = 30.0f0)
    menu = Menu(gui_grid[1,1][1,2], options = collect(-bf.l:1:bf.l))

    # Isovalue slider
    ls = labelslider!(fig, "Isovalue", 0:0.01:0.5)#, tellheight = false)
    gui_grid[2,1] = ls.layout

    # Toggles
    togglegrid = gui_grid[3,1] = GridLayout(tellwidth=false)
    ax_t = Toggle(togglegrid[1,1])
    Label(togglegrid[1,2], "Show axis")

    ax_t.active[] = true
    on(ax_t.active) do visible
        lscene.scene.plots[1].plots[1].visible[] = visible
        lscene.scene.plots[1].plots[2].visible[] = visible
    end

    # Save button
    sbut = Button(gui_grid[4,1], label="Save", tellwidth=false)
    on(sbut.clicks) do n
        lscene.scene.center = false
        save("atomicorbital.png", lscene.scene)
    end

    set_close_to!(ls.slider, 0.48)
    menu.selection[] = 0

    r = LinRange(min, max, N)

    iv = ls.slider.value
    negiv = lift(iv) do x
        -x
    end

    r = LinRange(min, max, N)
    wf = lift(menu.selection) do ml
        [orbital_eval(bf, x, y, z, Integer(ml[]), x0=x0, y0=y0, z0=z0) for x = r, y = r, z = r]
    end

    volume!(r, r, r, wf, algorithm = :iso, isorange = 0.01, tellheight=false, 
            isovalue =  iv, show_axis=true, colormap = colormap("reds"), colorrange = (0, 0.5))
    volume!(r, r, r, wf, algorithm = :iso, isorange = 0.01, tellheight=false, 
            isovalue = negiv, show_axis=true, colormap = colormap("blues"), colorrange = (0, -0.5))

    return fig
end

function scatter(bf, min, max, N; x0=0, y0=0, z0=0)
    fig = Figure(resolution=(900,800))
    lscene = LScene(fig[1,1], tellheight=false, height=700, width=600)

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
    ax_t = Toggle(togglegrid[1,1])
    Label(togglegrid[1,2], "Show axis")

    ax_t.active[] = true
    on(ax_t.active) do visible
        lscene.scene.plots[1].plots[1].visible[] = visible
        lscene.scene.plots[1].plots[2].visible[] = visible
    end

    # Save button
    sbut = Button(gui_grid[4,1], label="Save", tellwidth=false)
    on(sbut.clicks) do n
        lscene.scene.center = false
        save("atomicorbital.png", lscene.scene)
    end

    menu.selection[] = 0

    np = Node(N)

    points = lift(menu.selection) do ml 
        p = zeros(N,3)
        for i = 1:np[]
            p[i,:] .= get_position(bf, min, max, ml, x0=x0, y0=y0, z0=z0)
        end
        p
    end

    for i = eachindex(addn)
        on(addn[i].clicks) do n 
            newpoints = zeros(addvals[i],3)
            for j = 1:addvals[i]
                newpoints[j,:] .= get_position(bf, min, max, menu.selection[], x0=x0, y0=y0, z0=z0)
            end
            points[] = vcat(newpoints, points[])
        end
    end

    scatter!(points, color=:blue)
    return fig
end
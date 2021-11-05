using SphericalHarmonics
using LaTeXStrings
using Colors

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
    fig = Figure()
    lscene = LScene(fig[1:5,1:4])

    # Menus
    menu = Menu(fig, options = collect(-bf.l:1:bf.l), tellwidth = false)
    fig[1,5] = grid!(
        hcat(Label(fig, L"m_l", width = nothing, textsize = 30.0f0), menu),
        tellheight = false,
        width = 300
    )

    # Sliders
    lsgrid = labelslidergrid!(
        fig,
        ["Isovalue"],
        [0:0.01:0.5],
        formats = [x -> "$x"],
        tellheight = false
    )
    fig[2,5] = lsgrid.layout

    # Toggles
    toggles = [
        Toggle(fig, active = true)
    ]
    tlabels = [
        Label(fig, "Show axis")
    ]
    fig[3,5] = grid!(hcat(toggles, tlabels), tellheight = false)

    # Buttons
    fig[4, 5] = buttongrid = GridLayout(tellwidth = false)
    button = buttongrid[1,1] =[Button(fig, label = "Save")]
    on(button[1].clicks) do n
        lscene.scene.center = false
        save("atomicorbital.png", lscene.scene)
    end

    set_close_to!(lsgrid.sliders[1], 0.48)
    menu.selection[] = 0

    r = LinRange(-2.0, 2.0, 100)

    iv = lsgrid.sliders[1].value
    negiv = lift(iv) do x
        -x
    end

    r = LinRange(min, max, N)
    wf = lift(menu.selection) do ml
        [basis_function_eval(bf, x, y, z, Integer(ml[])) for x = r, y = r, z = r]
    end

    volume!(r, r, r, wf, algorithm = :iso, isorange = 0.01, 
            isovalue =  iv, show_axis=toggles[1].active, colormap = colormap("reds"), colorrange = (0, 0.5))
    volume!(r, r, r, wf, algorithm = :iso, isorange = 0.01, 
            isovalue = negiv, show_axis=toggles[1].active, colormap = colormap("blues"), colorrange = (0, -0.5))

    return fig
end
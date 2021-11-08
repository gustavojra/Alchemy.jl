import Fermi.Orbitals: AbstractRestrictedOrbitals

function orbital_eval(orb::AbstractRestrictedOrbitals, bset::BasisSet, x, y, z, n)

    atoms = orb.molecule.atoms

    # Initialize array with basis function value
    χ = zeros(bset.nbas)

    i = 1
    for a in eachindex(atoms)
        basis_on_atom_a = bset[a]
        x0, y0, z0 = atoms[a].xyz
        for b in eachindex(basis_on_atom_a)
            bf = basis_on_atom_a[b]
            if bf.l == 1
                ml_vals = [1, -1, 0]
            else
                ml_vals = collect(-bf.l:1:bf.l)
            end
            for ml in ml_vals
                χ[i] = orbital_eval(bf, x,y,z, ml, x0=x0, y0=y0, z0=z0)
                i += 1
            end
        end
    end

    Cμi = orb.C[:,n]

    return sum(Cμi .* χ)
end

function isoplot(orb::AbstractRestrictedOrbitals, min, max, N)

    fig = Figure(resolution=(900,800))
    lscene = LScene(fig[1,1], tellheight=false, height=700, width=600)

    plot!(lscene, orb.molecule.atoms)

    gui_grid = fig[1,2] = GridLayout(width = 250, tellheigth=false)

    # Orbital select menu
    Label(gui_grid[1,1][1,1], "Orbital")
    menu = Menu(gui_grid[1,1][1,2], options = collect(1:size(orb.C,1)))

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
    menu.selection[] = 1

    r = LinRange(min, max, N)

    iv = ls.slider.value
    negiv = lift(iv) do x
        -x
    end

    bset = BasisSet(orb.basis, orb.molecule.atoms)
    r = LinRange(min, max, N)
    wf = lift(menu.selection) do n
        [orbital_eval(orb, bset, x, y, z, Integer(n[])) for x = r, y = r, z = r]
    end

    volume!(r, r, r, wf, algorithm = :iso, isorange = 0.01, tellheight=false, 
            isovalue =  iv, show_axis=true, colormap = colormap("reds"), colorrange = (0, 0.5))
    volume!(r, r, r, wf, algorithm = :iso, isorange = 0.01, tellheight=false, 
            isovalue = negiv, show_axis=true, colormap = colormap("blues"), colorrange = (0, -0.5))

    return fig
end
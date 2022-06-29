using LinearAlgebra
using MKL
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
                ml_vals = [1, 0, -1]
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

    # Plot atoms
    atoms = orb.molecule.atoms
    plot!(lscene, atoms)

    gui_grid = fig[1,2] = GridLayout(width = 250, tellheigth=false)

    # Orbital select menu
    Label(gui_grid[1,1][1,1], "Orbital")
    menu = Menu(gui_grid[1,1][1,2], options = collect(1:size(orb.C,1)))

    # Isovalue slider
    ls = labelslider!(fig, "Isovalue", 0:0.01:0.5)#, tellheight = false)
    gui_grid[2,1] = ls.layout

    # Toggles: Show axis
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

    # Positive and negative isovalues conected as nodes
    iv = ls.slider.value
    negiv = lift(iv) do x
        -x
    end

    # Get basis set info
    bset = BasisSet(orb.basis, atoms)
    nbas = bset.nbas

    # Allocate array for basis set grids
    χ = zeros(Float32, N, N, N, size(orb.C,1))
    Cμi = Float32.(orb.C)

    bas_per_atom = Int[]
    for a in eachindex(atoms)
        basis_on_atom_a = bset[a]
        nbf = 0
        for b in basis_on_atom_a
            nbf += 2*b.l + 1
        end
        push!(bas_per_atom, nbf)
    end

    println(bas_per_atom)
    println(nbas)
    @assert sum(bas_per_atom) == nbas

    offset = [sum(bas_per_atom[1:(a-1)]) for a in eachindex(atoms)]

    # Compute χ(x,y,z,μ) rank-4 tensor: x,y,z are the cartesian coordinates
    # μ is the basis function index. Thus, this tensor stores the value of all 
    # basis functions over the whole grid
    r = LinRange(min, max, N)
    Threads.@threads for ix in 1:N
        x = r[ix]
        @inbounds for iy in 1:N, iz in 1:N
        y, z = r[iy], r[iz]
        for a in eachindex(atoms)
            basis_on_atom_a = bset[a]
            x0, y0, z0 = atoms[a].xyz
            μ = offset[a] + 1
            for b in eachindex(basis_on_atom_a)
                bf = basis_on_atom_a[b]

                if bf.l == 1
                    ml_vals = [1, -1, 0]
                else
                    ml_vals = collect(-bf.l:1:bf.l)
                end

                for ml in ml_vals
                    χ[ix,iy,iz,μ] = orbital_eval(bf, x,y,z, ml, x0=x0, y0=y0, z0=z0)
                    μ += 1
                end
            end
        end
        end
    end

    # Perform the AO -> MO transformation as a matrix multiplication
    # C(x,y,z;i) = χ(x,y,z;μ) * C(μ;i) 
    #Cmo = similar(χ)
    #Cmo .= 0
    #for ix in 1:N
    #    for iy in 1:N
    #        for iz in 1:N
    #            for i in 1:size(orb.C,1)
    #                for μ = 1:size(orb.C,1)
    #                    Cmo[ix,iy,iz,i] += χ[ix,iy,iz,μ]*Cμi[μ,i]
    #                end
    #            end
    #        end
    #    end
    #end
    χ = reshape(χ, (N^3, nbas))
    Cmo = reshape(χ * Cμi, (N, N, N, nbas))

    # The menu for orbital selection simply slice
    # the full tensor
    wf = lift(menu.selection) do n
        Cmo[:,:,:,n].^2
    end

    # Plot isosurfaces
    volume!(r, r, r, wf, algorithm = :iso, isorange = 0.01, tellheight=false, 
            isovalue =  iv, show_axis=true, colormap = colormap("reds"), colorrange = (0, 0.5))
    #volume!(r, r, r, wf, algorithm = :iso, isorange = 0.01, tellheight=false, 
    #        isovalue = negiv, show_axis=true, colormap = colormap("blues"), colorrange = (0, -0.5))

    return fig
end
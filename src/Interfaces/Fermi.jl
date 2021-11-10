export @fermiview

macro fermiview()
    quote
        try
            let mol = Molecule()
                Alchemy.plot(mol.atoms)
            end
        catch UndefVarError
            @error "Fermi.jl could not be found, try running `using Fermi` first."
        end
    end |> esc
end
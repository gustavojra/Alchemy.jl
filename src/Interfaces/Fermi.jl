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
const XYZ_REGEX = r"(\w{1,2})\s+?([+-]?\d*\.\d+)\s+?([+-]?\d*\.\d+)\s+?([+-]?\d*\.\d+)"
const creamery = RGB(214/255, 210/255, 196/255)
const stegeman = RGB(158/255, 162/255, 162/255)

function get_atom_radius(S::String)
    if S == "H"
        return 0.3
    else
        return 0.5
    end
end

const van_der_waals = Dict(
    "H" => 32,
    "He" => 46,
    "Li" => 133,
    "Be" => 102,
    "B" => 85,
    "C" => 75,
    "N" => 71,
    "O" => 63,
    "F" => 64,
    "Ne" => 67,
    "Na" => 155,
    "Mg" => 139,
    "Al" => 126,
    "Si" => 116,
    "P" => 111,
    "S" => 103,
    "Cl" => 99,
    "Ar" => 96,
    "K" => 196,
    "Ca" => 171,
    "Sc" => 148,
    "Ti" => 136,
    "V" => 134,
    "Cr" => 122,
    "Mn" => 120,
    "Fe" => 120,
    "Co" => 120,
    "Ni" => 120,
    "Cu" => 120,
    "Zn" => 120,
    "Ga" => 120,
    "Ge" => 120,
    "As" => 120,
    "Se" => 120,
    "Br" => 120,
    "Kr" => 120,
    "Rb" => 120,
    "Sr" => 120,
    "Y" => 120,
    "Zr" => 120,
    "Nb" => 120,
    "Mo" => 120,
    "Tc" => 120,
    "Ru" => 120,
    "Rh" => 120,
    "Pd" => 120,
    "Ag" => 120,
    "Cd" => 120,
    "In" => 120,
    "Sn" => 120,
    "Sb" => 120,
    "Te" => 120,
    "I" => 120,
    "Xe" => 120,
    "Cs" => 120,
    "Ba" => 120,
    "La" => 120,
    "Ce" => 120,
    "Pr" => 120,
    "Nd" => 120,
    "Pm" => 120,
    "Sm" => 120,
    "Eu" => 120,
    "Gd" => 120,
    "Tb" => 120,
    "Dy" => 120,
    "Ho" => 120,
    "Er" => 120,
    "Tm" => 120,
    "Yb" => 120,
    "Lu" => 120,
    "Hf" => 120,
    "Ta" => 120,
    "W" => 120,
    "Re" => 120,
    "Os" => 120,
    "Ir" => 120,
    "Pt" => 120,
    "Au" => 120,
    "Hg" => 120,
    "Tl" => 120,
    "Pb" => 120,
    "Bi" => 120,
    "Po" => 120,
    "At" => 120,
    "Rn" => 120,
    "Fr" => 120,
    "Ra" => 120,
    "Ac" => 120,
    "Th" => 120,
    "Pa" => 120,
    "U" => 120,
    "Np" => 120,
    "Pu" => 120,
    "Am" => 120,
    "Cm" => 120,
    "Bk" => 120,
    "Cf" => 120,
    "Es" => 120,
    "Fm" => 120,
    "Md" => 120,
    "No" => 120,
    "Lr" => 120,
    "Rf" => 120,
    "Db" => 120,
    "Sg" => 120,
    "Bh" => 120,
    "Hs" => 120,
    "Mt" => 120,
    "Ds" => 120,
    "Rg" => 120,
    "Cn" => 120,
    "Nh" => 120,
    "Fl" => 120,
    "Mc" => 120,
    "Lv" => 120,
    "Ts" => 120,
    "Og" => 120
)

const atom_color = Dict(
    "H" => color("whitesmoke"),
    "He" => 46,
    "Li" => 133,
    "Be" => 102,
    "B" => 85,
    "C" => color("gray19"),
    "N" => color("royalblue1"),
    "O" => RGB(0.7294117647058823,0.047058823529411764,0.1843137254901961),
    "F" => 64,
    "Ne" => 67,
    "Na" => 155,
    "Mg" => 139,
    "Al" => 126,
    "Si" => 116,
    "P" => 111,
    "S" => color("darkorange"),
    "Cl" => 99,
    "Ar" => 96,
    "K" => 196,
    "Ca" => 171
)
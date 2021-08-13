#using Alchemy

#Alchemy.run(joinpath(@__DIR__, "water.xyz"))

center = Point3f0(0,0,0)
center2 = Point3f0(0,3,0)

s1 = Sphere(center, 1)
s2 = Sphere(center2, 1)

p = mesh((s1, s2), show_axis=false)
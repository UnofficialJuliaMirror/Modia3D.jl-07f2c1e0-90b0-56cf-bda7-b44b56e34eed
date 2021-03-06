module Plot_SlidingFriction

#=




returns: vsmall     , if absv=0
         0.01*vsmall, if absv=vsmall
         0           , if absv=infinity
=#

# regularize(absv,vsmall) = vsmall*exp(log(0.01)*(absv/vsmall))

#=
regularize(absv,vsmall) = absv >= vsmall ? absv : absv*(absv/vsmall)*(1.0 - (absv/vsmall)/3.0) + vsmall/3.0


function resultantCor(cor1,cor2,abs_v_rel_n,vsmall)
    @assert(cor1 >= 0.0 && cor1 <= 1.0)
    @assert(cor2 >= 0.0 && cor2 <= 1.0)
    @assert(abs_v_rel_n >= 0.0)
    @assert(vsmall > 0)

    cor_min  = 0.001
    cor_mean = max(cor_min, (cor1 + cor2)/2.0)
    cor_res  = cor_mean + (cor_min - cor_mean)*exp(log(0.01)*(abs_v_rel_n/vsmall))
    return cor_res
end

function resultantDampingCoefficient(cor1, cor2, abs_v_rel_n,vsmall)
    @assert(cor1 >= 0.0 && cor1 <= 1.0)
    @assert(cor2 >= 0.0 && cor2 <= 1.0)
    @assert(abs_v_rel_n >= 0.0)
    @assert(vsmall > 0)

    cor   = resultantCor(cor1,cor2,abs_v_rel_n,vsmall)
    d_res = 8.0*(1.0 - cor)/(5*cor*regularize(abs_v_rel_n,vsmall))
    return d_res
end
=#


using PyCall
using PyPlot
using Modia3D

pyplot_rc = PyCall.PyDict(PyPlot.matplotlib."rcParams")
pyplot_rc["font.size"] = 10.0

vsmall = 0.01
cor0 = 1.0
cor1 = 0.7
cor2 = 0.3
cor3 = 0.1
cor4 = 0.01

vrela = collect(range(0.5*vsmall,4*vsmall,length=100))
vrelb = collect(range(0         ,  vsmall,length=500))
vrelc = collect(range(0         ,4*vsmall,length=100))
vreld = collect(range(0         ,2*vsmall,length=100))

d_res0a = zeros( length(vrela) )
d_res1a = zeros( length(vrela) )
d_res2a = zeros( length(vrela) )
d_res3a = zeros( length(vrela) )
d_res4a = zeros( length(vrela) )

d_res0b = zeros( length(vrelb) )
d_res1b = zeros( length(vrelb) )
d_res2b = zeros( length(vrelb) )
d_res3b = zeros( length(vrelb) )
d_res4b = zeros( length(vrelb) )

cor_res0 = zeros( length(vrelc) )
cor_res1 = zeros( length(vrelc) )
cor_res2 = zeros( length(vrelc) )
cor_res3 = zeros( length(vrelc) )
cor_res4 = zeros( length(vrelc) )

reg = zeros( length(vreld) )
w   = 0.0
for i in 1:length(vrela)
   d_res0a[i] = Modia3D.resultantDampingCoefficient(cor0,vrela[i],vsmall)
   d_res1a[i] = Modia3D.resultantDampingCoefficient(cor1,vrela[i],vsmall)
   d_res2a[i] = Modia3D.resultantDampingCoefficient(cor2,vrela[i],vsmall)
   d_res3a[i] = Modia3D.resultantDampingCoefficient(cor3,vrela[i],vsmall)
   d_res4a[i] = Modia3D.resultantDampingCoefficient(cor4,vrela[i],vsmall)
end

for i in 1:length(vrelb)
   d_res0b[i] = Modia3D.resultantDampingCoefficient(cor0,vrelb[i],vsmall)
   d_res1b[i] = Modia3D.resultantDampingCoefficient(cor1,vrelb[i],vsmall)
   d_res2b[i] = Modia3D.resultantDampingCoefficient(cor2,vrelb[i],vsmall)
   d_res3b[i] = Modia3D.resultantDampingCoefficient(cor3,vrelb[i],vsmall)
   d_res4b[i] = Modia3D.resultantDampingCoefficient(cor4,vrelb[i],vsmall)
end

for i in 1:length(vrelc)
   cor_res0[i] = Modia3D.resultantCoefficientOfRestitution(cor0,vrelc[i],vsmall)
   cor_res1[i] = Modia3D.resultantCoefficientOfRestitution(cor1,vrelc[i],vsmall)
   cor_res2[i] = Modia3D.resultantCoefficientOfRestitution(cor2,vrelc[i],vsmall)
   cor_res3[i] = Modia3D.resultantCoefficientOfRestitution(cor3,vrelc[i],vsmall)
   cor_res4[i] = Modia3D.resultantCoefficientOfRestitution(cor4,vrelc[i],vsmall)
end

for i in 1:length(vreld)
   reg[i] = Modia3D.regularize(vreld[i],vsmall)
end

figure(1)
clf()
plot(vrelc, cor_res0, vrelc, cor_res1, vrelc, cor_res2, vrelc, cor_res3, vrelc, cor_res4)
grid(true)
xlabel("\$\\dot{\\delta}^- \\; [m/s]\$")
ylabel("\$cor_{reg}\$")
legend(["\$cor = 1.0, v_{small}=0.01 \\; m/s\$",
        "\$cor = 0.7, v_{small}=0.01 \\; m/s\$",
        "\$cor = 0.3, v_{small}=0.01 \\; m/s\$",
        "\$cor = 0.1, v_{small}=0.01 \\; m/s\$",
        "\$cor = 0.0, v_{small}=0.01 \\; m/s\$"],loc="upper right")

figure(2)
clf()
plot(vrela, d_res0a, vrela, d_res1a, vrela, d_res2a, vrela, d_res3a, vrela, d_res4a)
grid(true)
xlabel("\$\\dot{\\delta}^- \\; [m/s]\$")
ylabel("\$d \\; [Ns/m]\$")
legend(["\$cor = 1.0, v_{small}=0.01 \\; m/s\$",
        "\$cor = 0.7, v_{small}=0.01 \\; m/s\$",
        "\$cor = 0.3, v_{small}=0.01 \\; m/s\$",
        "\$cor = 0.1, v_{small}=0.01 \\; m/s\$",
        "\$cor = 0.0, v_{small}=0.01 \\; m/s\$"],loc="upper right")

figure(3)
clf()
plot(vrelb, d_res0b, vrelb, d_res1b, vrelb, d_res2b, vrelb, d_res3b, vrelb, d_res4b)
grid(true)
xlabel("\$\\dot{\\delta}^- \\; [m/s]\$")
ylabel("\$d \\; [Ns/m]\$")
legend(["\$cor = 1.0, v_{small}=0.01 \\; m/s\$",
        "\$cor = 0.7, v_{small}=0.01 \\; m/s\$",
        "\$cor = 0.3, v_{small}=0.01 \\; m/s\$",
        "\$cor = 0.1, v_{small}=0.01 \\; m/s\$",
        "\$cor = 0.0, v_{small}=0.01 \\; m/s\$"],loc="upper right")

figure(4)
clf()
plot(vreld, reg)
grid(true)
xlabel("\$v_{abs}\$")
legend(["\$reg(v_{abs},0.1)\$"])

println("... success of Plot_cor.jl!")

end

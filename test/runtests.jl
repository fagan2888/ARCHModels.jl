using Base.Test

using ARCH
T = 10^4;
spec = GARCH{1, 1};
coefs = [1., .9, .05];
srand(1);
data = simulate(spec, T, coefs);
ht = zeros(data);
am = selectmodel(GARCH, data)
am2 = ARCHModel(spec, data, ht, coefs)
fit!(am2)
am3 = fit(am2)


@test loglikelihood(ARCHModel(spec, data, coefs)) ==  ARCH.loglik!(ht, spec, data, coefs)
@test nobs(am) == T
@test dof(am) == 3
@test coefnames(GARCH{1, 1}) == ["ω", "β₁", "α₁"]
@test all(isapprox.(coef(am), [0.9086850084210619, 0.9055267307122488, 0.050365843108442374], rtol=1e-4))
@test all(isapprox.(stderr(am), [0.14583357347889914, 0.01035533071207874, 0.005222909457230848], rtol=1e-4))
@test all(am2.coefs .== am.coefs)
@test all(am3.coefs .== am2.coefs)

e = @test_throws ARCH.NumParamError ARCH.loglik!(ht, spec, data, [0., 0., 0., 0.])
str = sprint(showerror, e.value)
@test startswith(str, "incorrect number of parameters")
@test_throws ARCH.NumParamError ARCH.sim!(ht, spec, data, [0., 0., 0., 0.])
e = @test_throws ARCH.LengthMismatchError ARCHModel(spec, data, coefs, coefs)
str = sprint(showerror, e.value)
@test startswith(str, "length of arrays does not match")
@test selectmodel(ARCH._ARCH, data).coefs == fit(ARCH._ARCH{3}, data).coefs
io = IOBuffer()
str = sprint(io -> show(io, am))
@test startswith(str, "\nGARCH{1,1}")

d = StdNormal()
@test ARCH.constraints(d) == (Float64[], Float64[])
mymean = mean(d)
@test mymean == 0.
@test mymean isa Float64
myvar = var(StdNormal(Float32))
@test myvar == 1.
@test myvar isa Float32
srand(1)
@test rand(d) ≈ 0.2972879845354616
@test ARCH.nparams(d) == 0
ARCH.logpdf(d, 1.) ≈ -1.4189385332046727

d = StdTDist(3)
@test ARCH.constraints(d) == ([2.0], [Inf])
mymean = mean(d)
@test mymean == 0.
@test mymean isa Float64
myvar = var(StdTDist(3.0f0))
@test myvar == 1.
@test myvar isa Float32
srand(1)
@test rand(d) ≈ 0.17647305710079372
@test ARCH.nparams(d) == 1
ARCH.logpdf(d, 1.) ≈ -1.6479184330021646

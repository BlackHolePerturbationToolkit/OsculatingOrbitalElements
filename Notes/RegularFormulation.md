# A regular formulation of the osculating geodesic equations in Kerr

This note describes a regular formulation of the osculating geodesic equations, and why it was chosen. The aim is no
special cases: the same equations handle circular, equatorial and polar orbits, and inspirals that pass through any of
them. Parts of it (the polar unit vector, the regular constants of motion, and the regular rate of $x$) do not seem to
be in the literature.

**Status.** `OsculatingInspiral` uses the radial variables (§2), the regular constants of motion (§4) and the regular
rate of $x$ (§5). For the polar motion it integrates $x$ and $\psi_\theta$, as the earlier solvers did, and treats
equatorial orbits as a special case: $x$ is held at exactly $\pm 1$, the polar equations are dropped, $\theta = \pi/2$,
and the force must have no $\theta$ component in the plane (nor a flux any rate of $x$). The polar unit vector (§3) and
its flux terms (§6) are on hold and may change; `OsculatingInspiral` used them at commit 7e644fe, and their code is
kept, unused, in `Kernel/Legacy/RegularPolar.wl`. In $(x, \psi_\theta)$ a force with a $\theta$ component makes the
equations stiff close to the equator: starting $10^{-6}$ from the plane under a constant $a_\theta$, an inspiral took
60 times longer than at $x = 0.99$, and at $10^{-10}$ NDSolve stopped as the system was stiff. The unit vector avoids
this.

Conventions: $G = c = M = 1$; Boyer–Lindquist coordinates; Mino time $\lambda$, with $d\tau = \Sigma\, d\lambda$; a
force per unit mass with covariant components $a_\mu$, orthogonal to the four-velocity, $u^\mu a_\mu = 0$. A geodesic
has energy $E$, angular momentum $L$, Carter constant $Q$, and $K = Q + (L - aE)^2$. Its elements are the semi-latus
rectum $p$, eccentricity $e$ and inclination $x = \cos\iota$, with $z_m = 1 - x^2$ and $\beta = a^2(1 - E^2)$, and its
phases are the Darwin phase $\psi_r$, with $r = p/(1 + e\cos\psi_r)$, and the Hughes phase $\psi_\theta$, with
$\cos\theta = \sqrt{z_m}\cos\psi_\theta$.

## 1. Where the usual variables fail

The usual osculating variables are $(p, e, x, \psi_r, \psi_\theta)$, with $\phi$. Three of them are coordinates on
a sphere or a plane, and fail where those coordinates do:

| Variables | Fail at | Because |
|---|---|---|
| $(e, \psi_r)$ | circular orbits, $e = 0$ | they are polar coordinates on the plane of $(e\sin\psi_r, e\cos\psi_r)$ |
| $(x, \psi_\theta)$ | equatorial orbits, $x = \pm 1$ | they are spherical coordinates, with the equatorial orbits at the poles |
| $\phi$ | orbits that pass near the axis, small $\lvert x\rvert$ | $d\phi/d\lambda \approx L/\sin^2\theta$ swings $\phi$ by nearly $\pi$ in a time of order $\lvert x\rvert$ |

At an equatorial orbit, for example, the $\psi_\theta$ equation contains $a_\theta/\sqrt{z_m}$, so in these variables
a force with a $\theta$ component cannot lift an orbit out of the plane.

## 2. Radial variables

The radial motion uses $p$ and the eccentricity components
$$\alpha_p = e\sin\psi_r, \qquad \beta_p = e\cos\psi_r,$$
so that $r = p/w$ with $w = 1 + \beta_p$. The geodesic rate of $\psi_r$ is $P = \sqrt{Z}$, where
$$Z = p - \frac{K(3 - e^2 + 2\beta_p)}{p} + \frac{a^2 Q(4 - e^2 + 4\beta_p + \beta_p^2)}{p^2}$$
is polynomial in $\alpha_p$ and $\beta_p$ (through $e^2 = \alpha_p^2 + \beta_p^2$). These are the REG equations,
already in the package:
$$\frac{d\beta_p}{d\lambda} = \frac{w}{p}\frac{dp}{d\lambda} - \alpha_p P,$$
$$\frac{d\alpha_p}{d\lambda} = \beta_p P + \frac{\Sigma\Delta w^2 a_r}{pP} + \frac{\alpha_p}{p}\frac{dp}{d\lambda}
 - \frac{\alpha_p}{2Z}\left[\Big(Z_p + \frac{w Z_\beta}{p}\Big)\frac{dp}{d\lambda} + Z_{e^2}\frac{de^2}{d\lambda}
 + Z_K\frac{dK}{d\lambda} + Z_Q\frac{dQ}{d\lambda}\right],$$
where $Z_p, Z_{e^2}, Z_\beta, Z_K, Z_Q$ are the partial derivatives of $Z$. None of these terms divides by $e$,
$\alpha_p$ or $\beta_p$. The rates of $p$ and $e^2$ come from those of $(E, L, Q)$ through a map that is itself regular
at $e = 0$ (`SlowElementRates` in `Kernel/Utilities.wl`): it gives $de^2/d\lambda$ rather than $de/d\lambda$.

## 3. Polar variables: a unit vector (on hold)

The polar motion uses the three components
$$\alpha_\theta = \sqrt{z_m}\sin\psi_\theta, \qquad \beta_\theta = \sqrt{z_m}\cos\psi_\theta = \cos\theta, \qquad x,$$
which satisfy
$$\alpha_\theta^2 + \beta_\theta^2 + x^2 = 1.$$
Geometrically, $(\alpha_\theta, \beta_\theta, x)$ is a point on the unit sphere, with $x$ the height and $\psi_\theta$
the longitude. $(x, \psi_\theta)$ are its spherical coordinates, so they fail at its poles, the equatorial orbits.
$(\alpha_\theta, \beta_\theta)$ alone fail at its equator, the polar orbits, where they cannot tell prograde from
retrograde. The unit vector itself is regular everywhere, including through prograde–retrograde transitions.

Write $\beta z_+ = Q + L^2 + \beta x^2$ for $\beta$ times the larger root of the polar potential, $\ell = L/x$, and
$$W = \sqrt{\beta z_+ - \beta\beta_\theta^2},$$
which is the geodesic rate $d\psi_\theta/d\lambda$. Then, with $\sin\theta = \sqrt{1 - \beta_\theta^2}$,
$$\frac{d\beta_\theta}{d\lambda} = -\alpha_\theta W,$$
$$\frac{d\alpha_\theta}{d\lambda} = \beta_\theta W + \frac{\Sigma}{\beta z_+ - \beta z_m}
 \left[\frac{x^2 W a_\theta}{\sin\theta} - \alpha_\theta\Big(a^2 E x^2 a_t + \frac{L a_\phi}{\sin^2\theta}\Big)\right],$$
$$\frac{dx}{d\lambda} = -\frac{\Sigma\,\alpha_\theta}{\beta z_+ - \beta z_m}
 \left[\frac{x W a_\theta}{\sin\theta} - \alpha_\theta\Big(a^2 E x a_t + \frac{\ell a_\phi}{\sin^2\theta}\Big)\right].$$
Here $\beta z_+ - \beta z_m = \ell^2 + \beta x^2$, which is positive for every bound orbit.

**Derivation.**

1. $\beta_\theta = \cos\theta$ is a coordinate. The osculating conditions keep the position and velocity continuous,
   so its rate is the geodesic rate, $-\sin\theta\, u_\theta = -\alpha_\theta W$, whatever the force. (In Mino time
   $d\theta/d\lambda = u_\theta = \alpha_\theta W/\sin\theta$.)
2. $z_m$ is defined by $Q = z_m(\beta + L^2/x^2)$, with $x^2 = 1 - z_m$. Differentiating, with dots for $d/d\lambda$,
   $\dot\beta = -2a^2E\dot E$, and $\beta z_+ - \beta z_m = \beta x^2 + \ell^2$,
   $$(\beta z_+ - \beta z_m)\,\dot z_m = x^2\left(\dot Q + 2a^2 E z_m \dot E - \frac{2 z_m L \dot L}{x^2}\right).$$
3. Write the rate of the Carter constant in its polar form, from $Q = u_\theta^2 + \cos^2\theta\,(\beta + L^2/\sin^2\theta)$
   at fixed position:
   $$\frac{dQ}{d\lambda} = 2\Sigma\left[u_\theta a_\theta + \cos^2\theta\Big(a^2 E a_t + \frac{L a_\phi}{\sin^2\theta}\Big)\right],$$
   with $\dot E = -\Sigma a_t$ and $\dot L = \Sigma a_\phi$. On the sphere, $z_m - \beta_\theta^2 = \alpha_\theta^2$ and
   $z_m/x^2 - \beta_\theta^2/\sin^2\theta = \alpha_\theta^2/(x^2\sin^2\theta)$, since $\sin^2\theta = x^2 + \alpha_\theta^2$.
   So every term of $\dot z_m$ carries a factor $\alpha_\theta$:
   $$\frac{dz_m}{d\lambda} = \frac{2\Sigma\,\alpha_\theta}{\beta z_+ - \beta z_m}
   \left[\frac{x^2 W a_\theta}{\sin\theta} - \alpha_\theta\Big(a^2Ex^2 a_t + \frac{L a_\phi}{\sin^2\theta}\Big)\right].$$
4. From $\alpha_\theta^2 = z_m - \beta_\theta^2$, $\dot\alpha_\theta = \beta_\theta W + \dot z_m/(2\alpha_\theta)$, and the
   factor $\alpha_\theta$ cancels. From $x^2 = 1 - z_m$, $\dot x = -\dot z_m/(2x)$, and the $1/x$ cancels against the $x^2$
   and $L = x\ell$.
5. The rates preserve $\alpha_\theta^2 + \beta_\theta^2 + x^2 = 1$ exactly, so any drift measures the integration error.

The polar form of $dQ/d\lambda$ agrees with the radial form, written with $u_r a_r$, only when $u^\mu a_\mu = 0$. The
radial elements use the radial form, so a force must be orthogonal to the velocity; `ForceModel` makes it so by
computing $a_t$ from orthogonality.

**Checks**, made while `OsculatingInspiral` used these equations (commit 7e644fe; the current tests do not cover
them). Mapped by the chain rule, these rates agree with the $(x, \psi_\theta)$ equations to $10^{-13}$ or better for
$a = 0, 0.5, 0.9$, prograde and retrograde, $x$ from $0.8$ down to $\pm 0.01$, and near the axis. In a solve, a
$\theta$ force lifts an equatorial orbit out of the plane with the vector at unit length to $10^{-13}$, the solution
is continuous at the equator, and a torque drives an inspiral from prograde to retrograde through $x = 0$, agreeing
with the earlier REG solver in $p$, $e$, $x$ and $r$.

## 4. Constants of motion that are regular at $e = 0$ and $x = 0$

The equations need $E$, $L$ and $Q$ as functions of $(p, e, x)$. The usual closed forms are $0/0$ at $x = 0$, and need
a separate branch at $e = 0$. Schmidt's construction (as in KerrGeodesics) writes the conditions $R(r_i) = 0$ at the
turning points $r_{1,2} = p/(1 \mp e)$ as
$$f(r)E^2 - 2g(r)EL - h(r)L^2 - d(r) = 0,$$
with $f = r^4 + a^2(r(r+2) + z_m\Delta)$, $g = 2ar$, $h = r(r-2) + z_m\Delta/x^2$ and $d = (r^2 + a^2 z_m)\Delta$,
and solves the pair for $E^2$ and $L$. Two changes make it regular:

- **$x = 0$:** write $L = x\ell$, with $\ell = L/x$ finite (and positive, since $L$ and $x$ have the same sign). Then
  $hL^2 = \tilde h\ell^2$ with $\tilde h = x^2 h = r^2 - 2r + a^2 z_m$, a polynomial.
- **$e = 0$:** replace the two conditions by their mean and their divided difference,
  $F_\pm$, with $F_+ = (F(r_1) + F(r_2))/2$ and $F_- = (F(r_1) - F(r_2))/(r_1 - r_2)$. For a polynomial these are sums
  of products of $r_1$ and $r_2$ with positive coefficients, so nothing cancels as $r_1 \to r_2$. Every quantity below
  is a $2\times 2$ determinant of these rows, so the linear change of rows changes them all by the same factor, which
  cancels.

With $g/(2a) = r$ factored out, so that $a = 0$ needs no special case, define the determinants
$\kappa = [d, \tilde h]$, $\rho = [f, \tilde h]$, $\epsilon = [d, r]$, $\eta = [f, r]$ and $\sigma = [r, \tilde h]$, where
$[u, v] = u_+ v_- - u_- v_+$. Then
$$E^2 = \frac{\kappa\rho + 8a^2x^2\epsilon\sigma - 4\lvert a\rvert x\sqrt{\sigma\big(4a^2x^2\sigma\epsilon^2 + \rho\epsilon\kappa - \eta\kappa^2\big)}}{\rho^2 + 16a^2x^2\eta\sigma},
\qquad \ell^2 = \frac{\epsilon - \eta E^2}{\sigma},$$
and $L = x\ell$, $Q = (1 - x^2)(a^2(1 - E^2) + \ell^2)$. At $x = 0$, $E^2 = \kappa/\rho$. These agree with KerrGeodesics
to all 50 digits at generic points, and to $10^{-13}$ in machine precision, including at $e = 10^{-8}$, $x = 10^{-8}$
and $x = 0$ (`RegularEnergy` and `RegularLOverX`).

## 5. The rate of $x$ from rates of $(E, L, Q)$

A flux given as rates of $(E, L, Q)$ needs $\dot x = -\dot z_m/(2x)$, which is $0/0$ at $x = 0$. With $L = x\ell$ the
factor $x$ cancels:
$$\frac{dx}{dt} = -\frac{x\dot K - 2(\ell - axE)(\dot L - ax^2\dot E)}{2(\ell^2 + \beta x^2)},
\qquad \dot K = \dot Q + 2(L - aE)(\dot L - a\dot E),$$
which at $x = 0$ is $\dot L/\ell$ (`RegularXRate`).

## 6. Fluxes in these variables

A flux is an orbit-averaged rate of the slowly varying elements, with respect to coordinate time. It changes $e$ and
$x$ but not the phases. `OsculatingInspiral` adds $\dot p$ and $\dot x$ to the rates of $p$ and $x$, and
$(\dot e/e)(\alpha_p, \beta_p)$ to those of the eccentricity components, with nothing for $\psi_\theta$; on an
equatorial orbit it checks that $\dot x = 0$. With the polar unit vector (on hold) a flux contributes
$$\frac{d}{dt}(\alpha_p, \beta_p) \mathrel{+}= \frac{\dot e}{e}(\alpha_p, \beta_p), \qquad
\frac{d}{dt}(\alpha_\theta, \beta_\theta) \mathrel{+}= \frac{\dot z_m}{2z_m}(\alpha_\theta, \beta_\theta) = -\frac{x\dot x}{z_m}(\alpha_\theta, \beta_\theta),$$
alongside $\dot p$ and $\dot x$. These ratios are finite for a physical flux, which has $\dot e \propto e$ near $e = 0$
and $\dot x \propto z_m$ near the equator. Taking $z_m = \alpha_\theta^2 + \beta_\theta^2$ keeps the unit length exact. At
exactly $e = 0$, or on an equatorial orbit, the contributions are set to zero. A flux given for $(E, L, Q)$ gives
$\dot e/e = (de^2/dt)/(2e^2)$, which loses accuracy like $10^{-16}/e^2$ for nearly circular orbits.

The orbit average of a force is a flux. In Mino time the radial and polar motions separate,
$d\psi_r/d\lambda = P(\psi_r)$ and $d\psi_\theta/d\lambda = W(\psi_\theta)$, so for a non-resonant orbit the Mino-time
average is a double integral over the phases with weight $1/(PW)$, and the average with respect to $t$ divides by the
average of $dt/d\lambda$. The integrals converge exponentially with the number of points (`FluxModel[force]`); the
weights reproduce KerrGeodesics' $\Gamma$ and $\Upsilon_\phi$ to $10^{-9}$.

## 7. The azimuth near the axis

$\phi$ is integrated directly. An orbit with small $\lvert x\rvert$ passes $\sin\theta = \lvert x\rvert$ from the axis,
where $d\phi/d\lambda \approx L/\sin^2\theta$, and $\phi$ swings by nearly $\pi$ in a time of order $\lvert x\rvert$.
NDSolve's default multistep method can step over such a swing entirely: at its default goals, $\phi$ was wrong by
0.4 rad for a gas-drag inspiral at $x = 0.01$. An explicit 8th-order Runge–Kutta method with goals of 11 or more
resolves it down to $\lvert x\rvert = 0.001$, and is the default.

Two alternatives were considered:

- Evolving $u = \sin\theta\, e^{i\phi}$ instead of $\phi$, which moves smoothly through the axis. Its equation,
  $du/d\lambda = (-\beta_\theta\dot\beta_\theta + iL)/\bar u + iu\,(\dot\phi - L/\sin^2\theta)$, is regular only on the
  constraint $\lvert u\rvert^2 = x^2 + \alpha_\theta^2$, and near the axis it amplifies any inconsistency with the polar
  variables by $1/\lvert u\rvert$. It did worse.
- Evolving the node angle $\Omega = \phi - \chi$, with $\chi = \arg(-\alpha_\theta + i x\beta_\theta)$. In Schwarzschild
  $\chi$ is exactly the azimuth measured from the node, and in Kerr the geodesic rate of $\Omega$ is the bounded
  $-x\beta/(\ell + W)$ plus the smooth frame-dragging terms, so no variable swings and $\lvert x\rvert$ can be arbitrarily
  small. $\Omega$ is undefined for equatorial orbits, so this needs two patches, switching when $\lvert x\rvert$ crosses
  a threshold. It is not implemented.

Orbits that start exactly polar, $x = 0$, pass through the axis and are not supported.

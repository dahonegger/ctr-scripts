function [K,eps0,tau,epsInf,sigma] = dielecEllison(f,T,S)

a1 = 81.820-6.0503E-2.*T-3.1661E-2.*T.^2+3.1097E-3.*T.^3-1.1791E-4.*T.^4+1.4838E-6.*T.^5;
a2 = 0.12544+9.4037E-3.*T-9.5551E-4.*T.^2+9.0888E-5.*T.^3-3.6011E-6.*T.^4+4.7130E-8.*T.^5;
b1 = 17.303-0.66651.*T+5.1482E-3.*T.^2+1.2145E-3.*T.^3-5.0325E-5.*T.^4+5.8272E-7.*T.^5;
b2 = -6.272E-3+2.357E-4.*T+5.075E-4.*T.^2-6.3983E-5.*T.^3+2.463E-6.*T.^4-3.0676E-8.*T.^5;
c1 = 0.086374+0.030606.*T-0.0004121.*T.^2;
c2 = 0.077454+0.001687.*T+0.00001937.*T.^2;

% Conductivity term
sigma = c1+c2.*S;

% High frequency dielectric constant
epsInf = 6.4587-0.04203.*T-0.0065881.*T.^2+0.00064924.*T.^3-1.2328E-5.*T.^4+5.0433E-8.*T.^5;

% Static dielectric constant
eps0 = a1+a2.*S;

% Relaxation time
tau = b1+b2.*S;

% Permittivity of free space
epsStar = 8.8419E-12;

%% Main equations

Kreal = epsInf+(eps0-epsInf)./(1+4*pi^2.*f.^2.*tau.^2);

Kimag = ((eps0-epsInf).*2*pi*f.*tau)./(1+4*pi^2.*f.^2.*tau.^2)+sigma./(2*pi*epsStar.*f);

K = Kreal+1i.*Kimag;
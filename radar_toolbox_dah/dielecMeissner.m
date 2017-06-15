function epsOut = dielecMeissner(nu,T,S)

% **Relative** dielectric constant for water as a function of wavelength nu (GHz),
% temperature T (centigrade) and salinity S (ppt)

% Fit constants
a = [
    5.7230
    2.2379E-2
    -7.1237E-4
    5.0478
    -7.0315E-2
    6.0059E-4
    3.6143
    2.8841E-2
    1.3652E-1
    1.4825E-3
    2.4166E-4];

b = [
    -3.56417E-3
     4.74868E-6
     1.15574E-5
     2.39357E-3
    -3.13530E-5
     2.52477E-7
    -6.28908E-3
     1.76032E-4
    -9.22144E-5
    -1.99723E-2
     1.81176E-4
    -2.04625E-3
     1.57883E-4];
 
c = [
    2.903602
    8.607E-2
    4.738817E-4
    -2.991E-6
    4.3047E-9
    37.5109
    5.45216
    1.4409E-2
    1004.75
    182.283
    6.9431
    3.2841
    -9.9486E-2
    84.850
    69.024
    49.843
    -0.2276
    0.198E-2];

d = [
    3.70886E4
    -8.2168E1
    4.21854E2];

%% Begin filling in parameters

epsS_TS0 = (d(1)-d(2).*T)./(d(3)+T);
eps1_TS0 = a(1)+a(2).*T+a(3).*T.^2;
nu1_TS0  = (45+T)./(a(4)+a(5).*T+a(6).*T.^2);
epsInf_TS0 = a(7)+a(8).*T;
nu2_TS0 = (45+T)./(a(9)+a(10).*T+a(11).*T.^2);

sigma_TS35 = c(1)+c(2).*T+c(3).*T.^2+c(4).*T.^3+c(5).*T.^4;
R15 = S.*(c(6)+c(7).*S+c(8).*S.^2)./(c(9)+c(10).*S+S.^2);
alpha0 = (c(11)+c(12).*S+c(13).*S.^2)./(c(14)+c(15).*S+S.^2);
alpha1 = c(16)+c(17).*S+c(18).*S.^2;
RTR15 = 1+alpha0.*(T-15)./(alpha1+T);

%% Final parameters

sigma_TS = sigma_TS35.*R15.*RTR15;
epsS_TS = epsS_TS0.*exp(b(1).*S+b(2).*S.^2+b(3).*T.*S);
nu1_TS = nu1_TS0.*(1+S.*(b(4)+b(5).*T+b(6).*T.^2));
eps1_TS = eps1_TS0.*exp(b(7).*S+b(8).*S.^2+b(9).*T.*S);
nu2_TS = nu2_TS0.*(1+S.*(b(10)+b(11).*T));
epsInf_TS = epsInf_TS0.*(1+S.*(b(12)+b(13).*T));

constTerm = 17.97510; % GHz*m/S;

epsOut = (epsS_TS-eps1_TS)./(1+1i.*nu./nu1_TS)+(eps1_TS-epsInf_TS)./(1+1i.*nu./nu2_TS)+epsInf_TS-1i.*sigma_TS.*constTerm./nu;
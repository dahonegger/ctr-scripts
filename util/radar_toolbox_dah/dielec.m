%DIELEC.M Calculated dielectric constant of sea water
%
%         This code calculates the dielectric constant of seawater using the
%         equations shown in the paper of Stogryn (1973), but correcting a
%         typographical error in the original paper.
%
%
%  INPUT VARIABLES
%        
%  T      Temperature in degrees Celsius
%  S      Salinity in ppm
%  efe    frequency of the EM incident wave
%
%  OUTPUT VARIABLES
%
%  eka1   Real part of dielectric constant
%  eka2   Imaginary part of dielectric constant (eka2<0)
%
%  So the real constant can be written as
%  e = eka1 +  i*eka2  , where (eka1<0)
%
%  Example:
%
%     [eka1,eka2]=dielec(25,34,6e9)   %6e9  corresponds to a wavelength of
%                                     %5 cm (C band)
%     eka1 =
%
%   -63.4640
%
%
%     eka2 =
%
%   32.2627
%
% Author:  R. Hernandez-Walls (rwalls@uabc.mx)
%          FCM-UABC
%          Ensenada B.C. México
%
% CITAR COMO:
%
%  R. Hernandez-Walls. (2010). DIELEC: Calculated dielectric constant of sea water.
%    A MATLAB file. [WWW document].URL http://www.mathworks.com/matlabcentral/fileexchange/26294
%
%
%
function [eka1, eka2]= dielec(T,S,efe)

einf=4.9;               % dielectric constant for high frequency
ecea=8.859e-12;         % Permittivity of free space
del=25-T;
% Normality of seawater
xnor=S.*(1.707e-2+1.205e-5*S+4.058e-9*S.^2);
% ecec is the dielectric constant for freshwater. Here I changed the
% value of 4.0008 by 0.40008 of the original article because a
% typographical error was detected.
ecec=87.74-0.40008*T+9.398e-4*T.*T+1.41e-6*T.^3;
% acn y bcn are constants to convert the static permittivity and relaxation
% time in terms of normality
acn=1-0.2551*xnor+5.151e-2*xnor.*xnor-6.889e-3*xnor.^3;
bcn=0.1463e-2*xnor.*T+1-0.04896*xnor-...
    0.2967*xnor.*xnor+5.644e-3*xnor.^3;
% is the relaxation time at zero salinity conditions
tac=1.1109e-10 -3.824e-12*T+6.938e-14*T.*T-5.096e-16*T.^3;
% static permittivity and relaxation time in terms of normality
ecece=ecec.*acn;
taco=tac.*bcn;
% for seawater analysis Weyl has shown that the conductivity at 25 degrees
% Celsius and any normality can be written as
s25n=10.394-2.3776*xnor+0.68258*xnor.*xnor-0.13538*xnor.^3+1.0086e-2*xnor.^4;
s25n=xnor.*s25n;
%the conductivity  in function of Temperature and salinity
al1=3.02e-5+3.922e-5*del+xnor.*(1.721e-5-6.584e-6*del);
al1=-del.*xnor.*al1;
als2=al1+1-1.962e-2*del+8.08e-5*del.^2;
sits=s25n.*als2;
% dielectric constant of sea water
ee=einf+(ecece-einf)./(1-i*taco*efe)+i*sits./(2*pi*ecea*efe);
eka1=-real(ee);
eka2=imag(ee);
%  

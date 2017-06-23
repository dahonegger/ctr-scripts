function [Y,f] = myfft(y,t,Np)
% [Y,f] = myfft(y,t,Np)
% IN:
	% t: Intependent variable (time)
	% y: Dependent variable
	% Np: [optional] Zero-padded total number of samples for higher FFT resolution
% OUT:
	% f: Output Fourier frequencies
	% Y: Discrete Fourier Transform at the Fourier frequencies

% Enforce verticality
if size(y,1)==1;y = y';end
if size(t,1)==1;t = t';end
    
N = length(y);	% Record length
% dt = diff(t(1:2));	% Sample spacing
dt = max(diff(t)); % maximum spacing

if nargin==3
	Y = fft(y,Np)/N;
    Y = fftshift(Y);
    if mod(N,2)==0
        j = -Np/2:Np/2-1;
    else
        j = -floor(Np/2):floor(Np/2);
    end
	f = j/Np/dt;
else
	Y = fft(y)/N;
    Y = fftshift(Y);
    if mod(N,2)==0
        j = -N/2:N/2-1;
    else
        j = -floor(N/2):floor(N/2);
    end
	f = j/N/dt;
end
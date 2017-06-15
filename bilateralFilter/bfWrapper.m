function frameOut = bfWrapper(frameIn)
%
% This function serves as a wrapper for bilateralFilter.m. Wrapper code
% inspired by Seth Zuckerman (Arete)
% 
%

edgeBoostFactor = 1.25; % Higher numbers boost edges LESS
%
eq0 = find(frameIn==0);
frameIn = frameIn-min(frameIn(:));
frameIn = frameIn+10;
L = log(frameIn);

B = bilateralFilter(L,[],min(L(:)),edgeBoostFactor*max(L(:)),...
    [],[],min(size(L))/64);

D = L-B;
L1 = B/100+D;
frameOut = exp(L1);
frameOut = frameOut-min(frameOut(:));

frameOut = frameOut/max(frameOut(:));
frameOut = frameOut*255;
frameOut(eq0)=0;
%%function to compute the mean of 2D matrices that may contain NaN values
%function [y,sd]=mymean(x,dim)
function [y,sd,Npts]=mymean(x,dim)

%finding the no nan-points
nanpts=ones(size(x))-isnan(x); %1 for no NaN, 0 for NaN.
x2=x.*nanpts; %removing the NaN signal
dummy=find(isnan(x)==1); %these are the bad points
x2(dummy)=0; %

if nargin==1, 
  % Determine which dimension SUM will use
  dim = min(find(size(x)~=1));
  if isempty(dim), dim = 1; end

  y = sum(x2)./sum(nanpts,dim);
else
  y = sum(x2,dim)./sum(nanpts,dim);
end


[rows,cols]=size(x);
%creating the Mean matrix (copying the mean)
if dim==1 %
    mn=repmat(y,rows,1);
elseif dim==2
    mn=repmat(y,1,cols);
end

%computing the variance
x3=(x2-mn).^2; %removing the mean
x3(dummy)=0; %assigning zeros to bad points
sd= sum(x3,dim)./(sum(nanpts,dim)-1); %computing the unbiased standard deviation
sd=sd.^.5;
Npts=sum(nanpts,dim)-1;
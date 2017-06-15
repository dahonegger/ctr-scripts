function [varOut,sumOut,sumSqOut,nOut] = ...
    newVar(dataIn,sumIn,sumSqIn,nIn)

nextDim = length(size(dataIn))+1;
sumOut = squeeze(nansum(cat(nextDim,sumIn,dataIn),nextDim));
sumSqOut = squeeze(nansum(cat(nextDim,sumSqIn,dataIn.^2),nextDim));
nOut = squeeze(nansum(cat(nextDim,nIn,double(~isnan(dataIn))),nextDim));

% varOut = (1./(nOut-1)).*(sumOutSq-sumOut);
varOut = (1./(nOut-1)).*(sumSqOut-1./nOut.*sumOut.^2);

end


% if k==1
%     Mnew = zeros(size(data));
%     idx = ~isnan(data);
%     Mtmp = squeeze(double(data(idx)));
%     Mnew(idx) = Mtmp;
%     Qnew = zeros(size(data));
%     varOut = Qnew./k;
%     knew = k+double(idx);
% else
%     Qnew = Q;
%     Mnew = M;
%     varOut = oldVar;
%     idx = ~isnan(data);
%     Qtmp = Q(idx)+((k(idx)-1).*(double(data(idx))-M(idx)).^2)./k(idx);
%     Qnew(idx) = Qtmp;
%     Mtmp = M(idx)+(double(data(idx))-M(idx))./k(idx);
%     Mnew(idx) = Mtmp;
%     varTmp = Qnew(idx)./(k(idx)-1);
%     varOut(idx) = varTmp;
%     knew = k+double(idx);
% end

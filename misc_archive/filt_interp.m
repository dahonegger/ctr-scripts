function [yi, rmsi, dof] = filt_interp(t,y,ti,hwid, filtername)

% SMOOTHE A CURVE WITH HANNING OR OTHER WINDOW
% ignore missing data (tagged with NAN)
% replaces orriginal, irreg spaced data with filtered and interpolated data
%
% [yi, rmsi, m] = filt_interp(t,y,ti,hwid,filtername)
%
% Input
%    t, sample times (irregularly spaced) (Nxm)
%    y, the sample values 
%    hwid, the smoothing window size (1xm)
%    ti, are the times to interpolate to
%    filtername, such as 'hanning'
%
% Output
%   yi, filtered time series
%   rmsi, rmserror between input and filtered values
%   dof, number of dof per estimate

if(~exist('fitername'))
    filtername = 'hanning'; % default
end

% remove the bad values
id = find(finite(y));
y = y(id);
y = y(:);
t = t(id,:);
[n,m] = size(t);
if(n==1 | m==1)
   t = t(:);
end

% interpolate to these points
[ni,mi] = size(ti);
yi=repmat(nan,ni,1);
rmsi=nan*yi;
dof=zeros(ni,1);

% scale input and output
t = t*diag(1./hwid);
ti = ti*diag(1./hwid);

for i = 1:ni
    t_prime = t-ti(i,:);
    id = find(((t_prime.^2)*ones(m,1))<=1);
    dof(i) = length(id);
    if(dof(i)>0)
        switch filtername
        case 'hanning'
            w = hanning_wt(t_prime(id));
        case 'loess'
            w = loess_wt(t_prime(id));
        case 'boxcar'
            w = ones(dof(i),1);
        end
        dof(i) = sum(w);
        w = w/dof(i);
        yi(i) = sum(y(id).*w);
        rmsi(i) = std(y(id)-yi(i));
    end
end

% function to interpolate the time series from the radar, assuming that it
% had 10 millisecond accuracy, typical of a windows XP machine.
%function to be called from inside readAfileTime.m

function [ntime]=interpolTimeVector(base,itime,header);

%%
%first we need to identify the location of the non-repeated times from the
%original time vector
[dummy,i]=unique(itime);

%we save the location of the two last changes 
ilast=i(end-2:end-1);ilast(2)=ilast(2)+1;
%now we need to reestructure the index, to be able to interpolate. To do
%so, we select the first occurrence of each time in the vector. since
%unique detects the last occurrence, we need to add a shift of 1 index
%location
if i(end-1)+1~=i(end)
    i=[1;i(1:end-1)+1;i(end)];
else
    i=[1;i(1:end-1)+1];
end

%now we interpolate
ntime=interp1(base(i),itime(i),base);

%now we extrapolate the slope of the last points, since they were not
%interpolated
p=polyfit(base(ilast(1):ilast(2)),ntime(ilast(1):ilast(2)),1);
ntime(ilast(2)+1:end)=polyval(p,base(ilast(2)+1:end));

%now we reshape it to be consistent with each azimuth
ntime=reshape(ntime,[header.collectionsMod,header.rotations]);
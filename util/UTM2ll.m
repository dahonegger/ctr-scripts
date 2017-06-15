function[Lat, Long] = UTM2ll(UTMNorthing, UTMEasting, ZoneNumber, refellip, a, eccSquared)
%
%  function[Lat, Long] = UTM2ll(UTMNorthing, UTMEasting, ZoneNumber, refellip)
%
%  converts from UTM Northing and UTM Easting to the lat a long according
%  to a reference ellipsoid refellip.  UTM zone must be specified.
%  If approximate lat-long is known, it can be found by
%       UTMZone = utmzone(Lat, Long);
%  refellip is 23 for WGS84.

% from Lippmann, 10/01

% Modified 2013-10-04 by Randall Pittman to allow for a and eccSquared to
% be provided externally, thereby bypassing the need to use the ellipsoid
% function.

%% UTM2ll
narginchk(3, 6);
k0 = 0.9996;
if nargin < 6
    if nargin < 4
        refellip = 'WGS-84';
    end
    [a, eccSquared, ~] = ellipsoid(refellip); % part of radar_toolbox, not the mapping toolbox.
end

%%% Replace NaNs with 0s. We'll set these back to NaN later.
nan_N = isnan(UTMNorthing);
nan_E = isnan(UTMEasting);
UTMNorthing(nan_N) = 0;
UTMEasting(nan_E) = 0;
if ~iscell(ZoneNumber), ZoneNumber = {ZoneNumber}; end
nan_Z = cellfun(@isempty, ZoneNumber);
ZoneNumber(nan_Z) = {1};

e1 = (1-sqrt(1-eccSquared))/(1+sqrt(1-eccSquared));

x = UTMEasting - 500000.0; %%//remove 500,000 meter offset for longitude
y = UTMNorthing;

%NorthernHemisphere = 1;  %%//point is in northern hemisphere
%%% Convert Zones to just zone numbers
char_zones = cellfun(@ischar, ZoneNumber);
ZoneNumber(char_zones) = cellfun(...
    @(x)sscanf(x,'%d%*c'), ZoneNumber(char_zones), ...
    'UniformOutput', false);
ZoneNumber = cell2mat(ZoneNumber);

LongOrigin = (ZoneNumber - 1)*6 - 180 + 3;  %%//+3 puts origin in middle of zone

eccPrimeSquared = (eccSquared)/(1-eccSquared);

M = y ./ k0;
mu = M/(a*(1-eccSquared/4-3*eccSquared*eccSquared/64-5*eccSquared*eccSquared*eccSquared/256));

phi1Rad = mu	+ (3*e1/2-27*e1*e1*e1/32)*sin(2*mu) ...
    + (21*e1*e1/16-55*e1*e1*e1*e1/32)*sin(4*mu)...
    +(151*e1*e1*e1/96)*sin(6*mu);
% phi1 = phi1Rad*180/pi;

N1 = a./sqrt(1-eccSquared.*sin(phi1Rad).*sin(phi1Rad));
T1 = tan(phi1Rad).*tan(phi1Rad);
C1 = eccPrimeSquared.*cos(phi1Rad).*cos(phi1Rad);
R1 = a.*(1-eccSquared)./((1-eccSquared.*sin(phi1Rad).*sin(phi1Rad)).^1.5);
D = x./(N1.*k0);

Lat = phi1Rad - (N1.*tan(phi1Rad)./R1).*(D.*D./2-(5+3.*T1+10.*C1-4.*C1.*C1-9.*eccPrimeSquared).*D.*D.*D.*D./24 ...
    +(61+90.*T1+298.*C1+45.*T1.*T1-252.*eccPrimeSquared-3.*C1.*C1).*D.*D.*D.*D.*D.*D./720);
Lat = Lat * 180/pi;

Long = (D-(1+2.*T1+C1).*D.*D.*D./6+(5-2.*C1+28.*T1-3.*C1.*C1+8.*eccPrimeSquared+24.*T1.*T1) ...
    .*D.*D.*D.*D.*D./120)./cos(phi1Rad);
Long = LongOrigin + Long * 180/pi;

%%% Restore NaNs.
Lat(nan_N | nan_E | nan_Z) = NaN;
Long(nan_N | nan_E | nan_Z) = NaN;

return;

%
% Copyright by Oregon State University, 2002
% Developed through collaborative effort of the Argus Users Group
% For official use by the Argus Users Group or other licensed activities.
%
% $Id: UTM2ll.m,v 1.1 2004/08/20 20:31:09 stanley Exp $
%
% $Log: UTM2ll.m,v $
% Revision 1.1  2004/08/20 20:31:09  stanley
% Initial revision
%
%
%key coordinate
%comment  Converts UTM to lat/long
%

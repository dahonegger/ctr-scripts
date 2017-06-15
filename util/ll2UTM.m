function [UTMNorthing, UTMEasting, UTMZone] = ll2UTM(Lat, Long, refellip, a, eccSquared)

%  function [UTMNorthing, UTMEasting, UTMZone] = ll2UTM(Lat, Long, refellip, a, eccSquared)
%
%	lat = latitude in fraction deg.
%	lon = longitude in fraction deg. (West of Grenwich are negative!)
%	refellip = ref. ellipsoid identifier (see refellip_menu.m) %%(now optional if using WGS-84 ellipsoid)
%	a = Equatorial Radius (optional)
%	eccSquared = eccentricity squared (optional)
%
%	if a and eccSquared are included, then refellip is ignored and a & eccSquared are
% 	used for the radius and eccentricity squared
%
%	utmNorthings = Northings (in fraction meters)
%	utmEastings = Eastings (or Westings if lon negative) (in fraction meters)
%	utmZ = zone(s) (ie, 10T). Returns a string if only one lat/lon pair.
%          Returns a cell array of strings otherwise.
%
%	Program to convert lat-lon data to UTM coordinates.
%	Uses subroutine written by Chuck Gantz downloaded from the
%	GPSy web site.
%
%	Note:  Westings have negative longitudes.
%
%   This function has been modified so that when only the lat and long are
%   input, the WGS-84 ellipsoid (ellipsoid #23) is assumed.  The various
%   reference ellipsoids can be seen in the CIL routine
%   /home/ruby/matlab/CIL/ephemeris/ellipsoid.m under the variable name 'enlist'.
%   C. Paden
%   10/23/03

%% deg2rad function
deg2rad = @(deg)deg.*pi./180;


%% Inputs
if nargin < 5
    if nargin < 3
        refellip = 'WGS-84';
    end
    [a, eccSquared, ~] = ellipsoid(refellip); % part of radar_toolbox package--not from Mapping Toolbox.
end

%%	lltoutm.c
%%	14 April 1999
%%	T. C. Lippmann

%%% Replace NaNs with 0s. We'll set these back to NaN later.
nan_Lat = isnan(Lat);
nan_Long = isnan(Long);
Lat(nan_Lat) = 0;
Long(nan_Long) = 0;

k0 = 0.9996;

LatRad = deg2rad(Lat);
LongRad = deg2rad(Long);

LongOrigin = zeros(size(Long));
dy = Long > -6 & Long <= 0;
LongOrigin(dy) = -3;
dy = Long < 6 & Long > 0;
LongOrigin(dy) = 3;
dy = abs(Long) >= 6;
LongOrigin(dy) = sign(Long(dy)).*floor(abs(Long(dy))/6)*6 + 3*sign(Long(dy));
LongOriginRad = deg2rad(LongOrigin);

%% compute the UTM Zone from the latitude and longitude*/
if nargout > 2
    UTMZone = ll2UTMZone(Lat,Long);
    %%% Set the zone for any NaN lat/lons to an empty string.
    if iscell(UTMZone)
        UTMZone(nan_Lat | nan_Long) = {''};
    elseif any(nan_Lat | nan_Long)
        UTMZone = '';
    end    
end

%% Compute the Northings and Eastings
eccPrimeSquared = (eccSquared)./(1-eccSquared);

N = a./sqrt(1-eccSquared.*sin(LatRad).*sin(LatRad));
T = tan(LatRad).*tan(LatRad);
C = eccPrimeSquared.*cos(LatRad).*cos(LatRad);
A = cos(LatRad).*(LongRad-LongOriginRad);

M = a.*((1 - eccSquared/4 - 3*eccSquared*eccSquared/64- 5*eccSquared*eccSquared*eccSquared/256).*LatRad ...
    - (3*eccSquared/8 + 3*eccSquared*eccSquared/32 + 45*eccSquared*eccSquared*eccSquared/1024).*sin(2*LatRad) ...
    + (15*eccSquared*eccSquared/256 + 45*eccSquared*eccSquared*eccSquared/1024).*sin(4*LatRad) ...
    - (35*eccSquared*eccSquared*eccSquared/3072).*sin(6*LatRad));

UTMEasting = (k0.*N.*(A+(1-T+C).*A.*A.*A/6 ...
    + (5-18.*T+T.*T+72.*C-58.*eccPrimeSquared).*A.*A.*A.*A.*A/120) ...
    + 500000.0);

UTMNorthing = (k0.*(M+N.*tan(LatRad).*(A.*A/2+(5-T+9.*C+4.*C.*C).*A.*A.*A.*A/24 ...
    + (61-58.*T+T.*T+600.*C-330.*eccPrimeSquared).*A.*A.*A.*A.*A.*A/720)));

dy = find(Lat < 0);
UTMNorthing(dy) = UTMNorthing(dy) + 10000000.0; %%10000000 meter offset for southern hemisphere*/

%%% Restore NaNs.
UTMNorthing(nan_Lat | nan_Long) = NaN;
UTMEasting(nan_Lat | nan_Long) = NaN;

%
% Copyright by Oregon State University, 2002
% Developed through collaborative effort of the Argus Users Group
% For official use by the Argus Users Group or other licensed activities.
%
% $Id: ll2UTM.m,v 1.2 2005/03/24 22:54:06 stanley Exp $
%
% $Log: ll2UTM.m,v $
% Revision 1.2  2005/03/24 22:54:06  stanley
% moved comment so help works right.
%
% Revision 1.1  2004/08/20 20:31:09  stanley
% Initial revision
%
%
%key coordinate
%comment  Converts lat/long to UTM
%

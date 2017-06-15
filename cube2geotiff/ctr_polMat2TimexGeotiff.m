function ctr_polMat2TimexGeotiff(cubeName,geotiffName)

% User options
outputDirectory    = '../';        % Path to saved kmz
radarLatitude      = 41.271747; % Leave blank [] to use UTM coordinates in Cube.results
radarLongitude     = -72.343472; % Leave blank [] to use UTM coordinates in Cube.results
headingOffset      = -5.25;         % If cube's internal heading is wrong, apply this offset: newHeading = oldHeading + headingOffset;
maxHeading         = 260;        % Set maximum heading value (clockwise from North) for footprint
cartGrid_dx        = 10;          % kmz requires cartesian grid - this is spatial resolution
cartGrid_dy        = 10;          % kmz requires cartesian grid - this is spatial resolution
colorAxisLimits    = [10 200];    % caxis
doIncludeColormap  = true;

% Brief prepwork
if ~exist(outputDirectory,'dir')
    mkdir(outputDirectory)
end

%% Load data

[~,namestr,~] = fileparts(cubeName);
fprintf('Loading %s:\n',namestr)
load(cubeName,'Azi','Rg','data','results','timeInt')

%% Get rotation vector
minTime  = epoch2Matlab(min(timeInt(:)));
meanTime = epoch2Matlab(mean(timeInt(:)));
maxTime  = epoch2Matlab(max(timeInt(:)));

%% Rectify
iMinRg = find(Rg>0,1,'first');


[AZI,RG] = meshgrid(90-Azi-(results.heading+headingOffset),Rg(iMinRg:end));
[xRadarGrid,yRadarGrid] = pol2cart(AZI*pi/180,RG);
if isempty(radarLatitude*radarLongitude)
    xutmOrigin = results.XOrigin;
    yutmOrigin = results.YOrigin;
    zone = results.UTMZone;
    [radarLatitude,radarLongitude] = UTMtoll(yutmOrigin,xutmOrigin,str2double(zone(1:2)));
else
    [yutmOrigin,xutmOrigin,zone] = lltoUTM(radarLatitude,radarLongitude);
end
xRadarGrid = xRadarGrid + xutmOrigin;
yRadarGrid = yRadarGrid + yutmOrigin;
[Lats,Lons] = UTMtoll(yRadarGrid,xRadarGrid,str2double(zone(1:2)));

%% Regular grid
fprintf('Rectifying: ')

[latd,lond] = UTMtoll(yutmOrigin+cartGrid_dy,xutmOrigin+cartGrid_dx,str2double(zone(1:2)));
latd = latd - radarLatitude;
lond = lond - radarLongitude;
LATv = min(Lats(:)):latd:max(Lats(:));
LONv = min(Lons(:)):lond:max(Lons(:));
[LON,LAT] = meshgrid(LONv,LATv);

timex = mean(data,3);
Fint = scatteredInterpolant(Lons(:),Lats(:),reshape(double(timex(iMinRg:end,:)),[],1),'linear','none');
timexData = Fint(LON,LAT);
fprintf('\n')


%% Mask the Pacman

% iCut = size(Lons,1);
iCut = find(abs(wrapTo360(Azi+results.heading+headingOffset)-maxHeading)==min(abs(wrapTo360(Azi+results.heading+headingOffset)-maxHeading)));

pmLons = [Lons(1,1);Lons(end,1:iCut)';Lons(1,1)];
pmLats = [Lats(1,1);Lats(end,1:iCut)';Lats(1,1)];
inpm = inpolygon(LON,LAT,pmLons,pmLats);

INPM = repmat(inpm,1,1,size(timexData,3));
timexData(~INPM) = -1;

%% Generate the GeoTIFF

fprintf('Writing GeoTIFFS: ')
R = georefpostings([min(LATv),max(LATv)],[min(LONv),max(LONv)],size(timexData));

scaledData = (timexData-colorAxisLimits(1))/colorAxisLimits(2)*255;
scaledData(scaledData>=255) = 255;
if doIncludeColormap
    geotiffwrite(fullfile(outputDirectory,geotiffName),uint8(scaledData),hot(255),R)
else
    geotiffwrite(fullfile(outputDirectory,geotiffName),uint8(scaledData),R)
end

fprintf('\nDone.\n')

end

function [UTMNorthing, UTMEasting, UTMZone] = lltoUTM(Lat, Long)
%%function [UTMNorthing, UTMEasting, UTMZone] = lltoutm(Lat, Long, refellip, a, eccSquared)
%%	lltoutm.c
%%  Consolidated  29,August 2006.  B. Woodward
%%	14 April 1999
%%	T. C. Lippmann
%%
%%	lat = latitude in fraction deg.
%%	lon = longitude in fraction deg. (West of Grenwich are negative!)
%%	refellip = ref. ellipsoid identifier (see refellip_menu.m)
%%	a = Equatorial Radius (optional)
%%	eccSquared = eccentricity squared (optional)
%%
%%	if a and eccSquared are included, then refellip is ignored and a & eccSquared are
%% 	used for the radius and eccentricity squared
%%
%%	utmNorthings = Northings (in fraction meters)
%%	utmEastings = Eastings (or Westings if lon negative) (in fraction meters)
%%	utmZ = zone (ie, 10T)
%%
%%	Program to convert lat-lon data to UTM coordinates.
%%	Uses subroutine written by Chuck Gantz downloaded from the
%%	GPSy web site.  
%%
%%	Note:  Westings have negative longitudes.
%%

%%%%%%%%  CONSTANTS  %%%%%%%%%
deg2rad = pi/180;
rad2deg = 180/pi;
ellipsoidName = 'WGS-84';
a = 6378137;
eccSquared = 0.00669438;
k0 = 0.9996;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	LatRad = Lat*deg2rad;
	LongRad = Long*deg2rad;

        LongOrigin = zeros(size(Long));
	dy = find(Long > -6 & Long <= 0);
        LongOrigin(dy) = -3; 
	dy = find(Long < 6 & Long > 0);
        LongOrigin(dy) = 3; 
        dy = find(abs(Long) >= 6);
        LongOrigin(dy) = sign(Long(dy)).*floor(abs(Long(dy))/6)*6 + 3*sign(Long(dy));
	LongOriginRad = LongOrigin * deg2rad;

	%% compute the UTM Zone and Grid from the latitude and longitude*/
	UTMZone = sprintf('%d%c', floor((Long(1) + 180)/6) + 1, UTMLetterDesignator(Lat(1)));
	
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
return;
end

function [LetterDesignator] = UTMLetterDesignator(Lat)
%%function [letdes] = UTMLetterDesignator(Lat)
%%This routine determines the correct UTM letter designator for the given latitude
%%returns 'Z' if latitude is outside the UTM limits of 80N to 80S
%% //Written by Chuck Gantz- chuck.gantz@globalstar.com

        if((80 >= Lat) & (Lat > 72)) LetterDesignator = 'X';
        else if((72 >= Lat) & (Lat > 64)) LetterDesignator = 'W'; 
        else if((64 >= Lat) & (Lat > 56)) LetterDesignator = 'V'; 
        else if((56 >= Lat) & (Lat > 48)) LetterDesignator = 'U'; 
        else if((48 >= Lat) & (Lat > 40)) LetterDesignator = 'T'; 
        else if((40 >= Lat) & (Lat > 32)) LetterDesignator = 'S'; 
        else if((32 >= Lat) & (Lat > 24)) LetterDesignator = 'R'; 
        else if((24 >= Lat) & (Lat > 16)) LetterDesignator = 'Q'; 
        else if((16 >= Lat) & (Lat > 8)) LetterDesignator = 'P'; 
        else if(( 8 >= Lat) & (Lat > 0)) LetterDesignator = 'N'; 
        else if(( 0 >= Lat) & (Lat > -8)) LetterDesignator = 'M'; 
        else if((-8>= Lat) & (Lat > -16)) LetterDesignator = 'L'; 
        else if((-16 >= Lat) & (Lat > -24)) LetterDesignator = 'K'; 
        else if((-24 >= Lat) & (Lat > -32)) LetterDesignator = 'J'; 
        else if((-32 >= Lat) & (Lat > -40)) LetterDesignator = 'H'; 
        else if((-40 >= Lat) & (Lat > -48)) LetterDesignator = 'G'; 
        else if((-48 >= Lat) & (Lat > -56)) LetterDesignator = 'F'; 
        else if((-56 >= Lat) & (Lat > -64)) LetterDesignator = 'E'; 
        else if((-64 >= Lat) & (Lat > -72)) LetterDesignator = 'D'; 
        else if((-72 >= Lat) & (Lat > -80)) LetterDesignator = 'C'; 
        else LetterDesignator = 'Z'; %%This is here as an error flag 
				     %%to show that the Latitude is 
				     %%outside the UTM limits
	end; end; end; end; end; end; end; end; end; end;
	end; end; end; end; end; end; end; end; end; end;
return;
end

function[Lat, Long] = UTMtoll(UTMNorthing, UTMEasting, ZoneNumber)
%%%%%%%%  CONSTANTS  %%%%%%%%%
deg2rad = pi/180;
rad2deg = 180/pi;
ellipsoidName = 'WGS-84';
a = 6378137;
eccSquared = 0.00669438;
k0 = 0.9996;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	e1 = (1-sqrt(1-eccSquared))/(1+sqrt(1-eccSquared));

	x = UTMEasting - 500000.0; %%//remove 500,000 meter offset for longitude
	y = UTMNorthing;

	NorthernHemisphere = 1;  %%//point is in northern hemisphere

	LongOrigin = (ZoneNumber - 1)*6 - 180 + 3;  %%//+3 puts origin in middle of zone

	eccPrimeSquared = (eccSquared)/(1-eccSquared);

	M = y ./ k0;
	mu = M/(a*(1-eccSquared/4-3*eccSquared*eccSquared/64-5*eccSquared*eccSquared*eccSquared/256));

	phi1Rad = mu	+ (3*e1/2-27*e1*e1*e1/32)*sin(2*mu) ...
				+ (21*e1*e1/16-55*e1*e1*e1*e1/32)*sin(4*mu)...
				+(151*e1*e1*e1/96)*sin(6*mu);
	phi1 = phi1Rad*180/pi;

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
    
end

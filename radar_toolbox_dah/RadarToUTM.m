%%function [E,N,Z,Radar_e,Radar_n]=RadarToUTM(data,range,azim,Heading,Lat,Long)
%% Objective:
%% Function to put the radar data in a georeferenced UTM system. Right now is
%% assumed that the reference ellipsoid is WGS-84. If no lat-long data is
%% passed, it will orient the data in Northing and Eastings
%% 
%% Type: Function
%%
%% Call ins: ll2UTM.m 
%%
%% Inputs:
%% data     : Radar data, in range-theta space
%% range    : range domain
%% azim     : azimuthal domain (relative to radar zero heading)
%% Heading  : Radar heading orientation relative to the True North, 
%%            positive counterclockwise (optional)
%% Lat      : Latitude of the radar (optional)
%% Long     : Longitude of the radar (optional)
%% 
%% Outputs:
%% E        : Eastings Matrix 
%% N        : Northings Matrix
%% Z        : Data Matrix, compatible with E and N
%% Radar_e  : Radar origin, UTM eastings
%% Radar_n  : Radar origin, UTM northings


function [E,N,Z,Radar_e,Radar_n]=RadarToUTM(data,range,azim,Heading,Lat,Long)

%creating the polar meshgrid 
[R,THT]=meshgrid(range,azim);
R=R';THT=THT';

if nargin==6 %we have all the information to use UTM coordinates
%Converting to UTM the radar location
[Radar_n,Radar_e]=ll2UTM(Lat,180-Long,23); %assumes Western hemisphere
elseif nargin==4    %no Lat no Long
    Radar_n=0;
    Radar_e=0;
elseif nargin<=3 %no heading info, nor Lat Lon
    Heading=180;Radar_n=0;  Radar_e=0;
end

%converts from relative domain (radar, clockwise), to Matlab friendly
%domain, with the x-axis being the eastings, and rotating counterclokwise
THT=+90-THT+Heading;

[E,N,Z]=pol2cart(THT/180*pi,R,data); %transforming from polar to cartesian coordinates

%offseting the data
E=Radar_e+E;
N=Radar_n+N;






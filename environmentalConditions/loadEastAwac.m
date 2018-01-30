function awac = loadEastAwac(fname)
% awac = loadEastAwac(fname)
% 
% [Optional]
% fname: filename of awac matfile. Defaults to 
% 				../../supportData/moorings/awac_east.mat

if nargin==0
	fname 		= fullfile('../..','supportData','moorings','awac_east.mat');
end

load(fname)

awac.dateNum 	= dn + 4/24; % EDT to UTC

% Rotate to East/North
theta 			= -14; % See geyer/jurisa/honegger correspondence
awac.east  		= u*cosd(-theta) - v*sind(-theta); % negative theta b/c rotating basis
awac.north 		= u*sind(-theta) + v*cosd(-theta);

% Keep pca along/cross channel components
awac.ur 		= ur;
awac.vr 		= vr;

awac.amp 		= amp;
awac.depth 		= depth;

% Remove deployment time series
idx = awac.dateNum > datenum([2017 05 21 0 0 0]);
awac.dateNum    = awac.dateNum(idx);
awac.east       = awac.east(idx);
awac.north      = awac.north(idx);
awac.ur         = awac.ur(idx);
awac.vr     	= awac.vr(idx);
awac.amp        = awac.amp(idx);
awac.depth      = awac.depth(idx);
function awac = loadEastAwac(fname)
% awac = loadEastAwac(fname)
% 
% [Optional]
% fname: filename of awac matfile. Defaults to 
% 				../../supportData/moorings/awac_east.mat

if nargin==0
	fname 		= fullfile('../..','supportData','moorings','awac_west.mat');
end

load awac_east

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
awac.readme 	= readme;
%% LOAD GPS
gpsPath = '/nfs/attic/hallerm/RADAR_DATA/CTR/supportData/vesselData/ctr_dawntreader_nav/surfboard_gps/';
gps = load(fullfile(gpsPath,'nav_surfboard.mat'));

gps.dnutc = gps.dn+4/24; % EDT2UTC
gps.dvutc = datevec(gps.dnutc);
%% June 28th

idx28 = find(gps.dvutc(:,3)==28);

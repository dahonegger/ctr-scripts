%% USRS Connecticut River May-June 2017 environmental conditions
% David Honegger 2017-09-20


%% Support Data Directory
if isunix
    atticBase = fullfile('/nfs','attic');
elseif ispc
    atticBase = fullfile('\\attic.engr.oregonstate.edu');
end
supportDir = fullfile(atticBase,'hallerm','RADAR_DATA','ctr','supportData');

%% Scripts Directory
dirParts = strsplit(fileparts(mfilename('fullpath')),filesep);
scrDir = fullfile(dirParts{1:end-1});
if ispc
    scrDir = fullfile(filesep,filesep,scrDir);
elseif isunix
    scrDir = fullfile(filesep,scrDir);
end
addpath(genpath(scrDir))

%% Predicted CTR tide current
[rrCurr.u,rrCurr.dn] = railroadBridgeCurrentLocal;
disp('rrCurr: [dn], [u] Railroad Bridge XTide Current')

%% FTTech Wind Sensor
fttech = loadFTTechWind_ctr2017;
disp('fttech: [dn], [wspd10], [wdir] Lynde Pt wind sensor')

%% LIS NDBC 
ndbc = loadNDBC44039_MayJune2017;
ndbc.z = 3.5;
ndbc.wspd10 = ndbc.wspd .* (10/ndbc.z).^(1/7);
disp('ndbc: [dn], [wspd10], [wdir], [wvht], [dpd], etc. Central LIS Buoy')


%% R/V Armstrong
arm = loadArmstrong;
arm.met.z = 18;
arm.met.wspd10 = arm.met.wspd_true .* (10/arm.met.z).^(1/7);
disp('arm: [time], [met.wspd10], [met.wdir_true], etc. R/V Armstrong all data')


%% Cleanup
rmpath(genpath(scrDir))
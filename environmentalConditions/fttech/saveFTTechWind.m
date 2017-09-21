%% This scripts loads into memory the FTTech wind sensor data and saves to disk
% David Honegger 2017-09-21

%% Wind Data Directory
if isunix
    atticBase = fullfile('/nfs','attic');
elseif ispc
    atticBase = fullfile('\\attic.engr.oregonstate.edu');
end
baseDir = fullfile(atticBase,'hallerm2','usrs','ctr','wind','raw');
saveDir = strsplit(baseDir,filesep);
if isunix
    saveDir = fullfile(filesep,saveDir{1:end-1});
elseif ispc
    saveDir = fullfile(filesep,filesep,saveDir{1:end-1});
end
saveFileName = fullfile(saveDir,'fttech_ctr2017.mat');

%% Scripts Directory
dirParts = strsplit(fileparts(mfilename('fullpath')),filesep);
scrDir = fullfile(dirParts{1:end-1});
addpath(genpath(scrDir))

%% Load and populate wind structure
[wind.dn,wind.wspd,wind.wdirM] = loadFTTechWind_allfiles(baseDir);

wind.z = 5;
wind.u10 = wind.wspd .* (10/wind.z).^(1/7);

ctrDeclination = -13 + 50/60; % magnetic declination
wind.wdir = wrapTo360(wind.wdirM + ctrDeclination);

wind.units = {...
    'dn:     matlab datenum UTC';
    'wspd:   sensor wind speed [m/s]';
    'wdirM:  magnetic wind directino coming from (nautical) [degrees]';
    'z:      sensor elevation above water level [m]';
    'wspd10: wind speed scaled to 10m elevation [m/s]';
    'wdir:   degrees true coming from (nautical)'};

%% Save to file
save(saveFileName,'wind')

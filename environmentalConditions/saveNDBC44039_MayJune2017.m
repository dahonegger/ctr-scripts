function saveNDBC44039_MayJune2017
%% Load and save NDBC 44039 (Central Long Island Sound)


% Data Directory
if isunix
    atticBase = fullfile('/nfs','attic');
elseif ispc
    atticBase = fullfile('\\attic.engr.oregonstate.edu');
end
baseDir = fullfile(atticBase,'hallerm','RADAR_DATA','ctr','supportData','ndbc44039');
saveDir = baseDir;
saveFileName = fullfile(saveDir,'ndbc44039_ctr2017.mat');

%% Scripts Directory
dirParts = strsplit(fileparts(mfilename('fullpath')),filesep);
scrDir = fullfile(dirParts{1:end-1});
addpath(genpath(scrDir))

ndbc44039 = importdata(fullfile(baseDir,'May-June2017.txt'));

dv = cat(2,ndbc44039.data(:,1:5),0*ndbc44039.data(:,1));
ndbc44039.dn = datenum(dv);
ndbc44039.wdir = ndbc44039.data(:,6);
ndbc44039.wspd = ndbc44039.data(:,7);
ndbc44039.wgst = ndbc44039.data(:,8);
ndbc44039.wvht = ndbc44039.data(:,9);
ndbc44039.dpd  = ndbc44039.data(:,10);
ndbc44039.apd  = ndbc44039.data(:,11);
ndbc44039.mwd  = ndbc44039.data(:,12);
ndbc44039.atmp = ndbc44039.data(:,14);

ndbc44039.wdir(ndbc44039.wdir==999) = nan;
ndbc44039.wspd(ndbc44039.wspd==99)  = nan;
ndbc44039.wgst(ndbc44039.wgst==99)  = nan;
ndbc44039.wvht(ndbc44039.wvht==99)  = nan;
ndbc44039.dpd(ndbc44039.dpd==99)  = nan;
ndbc44039.apd(ndbc44039.apd==99)  = nan;
ndbc44039.mwd(ndbc44039.mwd==99)  = nan;
ndbc44039.atmp(ndbc44039.atmp==99)  = nan;

ndbc44039.readme = [...
    'Long Island Sound NDBC buoy 44039, May-June 2017:                ';
    'dn   = matlab datenum in utc                                     ';
    'wdir = wind direction in degrees true (nautical convention)      ';
    'wspd = wind speed in m/s                                         ';
    'wgst = wind gust in m/s                                          ';
    'wvht = significant wave height in m                              ';
    'dpd  = dominant wave period in s                                 ';
    'apd  = average wave period in s                                  ';
    'mwd  = mean wave direction in degrees true (nautical convention) ';
    'atmp = air temperature in degrees Celsius                        '];
    
ndbc44039 = rmfield(ndbc44039,{'data','textdata','colheaders'});
save(saveFileName,'-v7.3','ndbc44039')
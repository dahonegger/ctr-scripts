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
addpath(genpath(scrDir))

%% Predicted CTR tide current
[rrCurr.u,rrCurr.dn] = railroadBridgeCurrent;
disp('rrCurr: [dn], [u] Railroad Bridge XTide Current')

%% 


%% Cleanup
rmpath(genpath(scrDir))
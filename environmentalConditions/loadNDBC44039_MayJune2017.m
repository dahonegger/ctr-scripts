function ndbc44039 = loadNDBC44039_MayJune2017

% Data Directory
if isunix
    atticBase = fullfile('/nfs','attic');
elseif ispc
    atticBase = fullfile('\\attic.engr.oregonstate.edu');
end
baseDir = fullfile(atticBase,'hallerm','RADAR_DATA','ctr','supportData','ndbc44039');
fileName = fullfile(baseDir,'ndbc44039_ctr2017.mat');

load(fileName) % Variable already named ndbc44039
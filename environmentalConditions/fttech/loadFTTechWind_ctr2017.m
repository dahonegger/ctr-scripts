function wind = loadFTTechWind_ctr2017
%% This script just loads the matfile saved by saveFTTechWind.matfile

if ispc
    atticDir = '\\attic.engr.oregonstate.edu';
elseif isunix
    atticDir = '/nfs/attic';
end

folderName = fullfile(atticDir,'hallerm2','usrs','ctr','wind');

fileName = fullfile(folderName,'fttech_ctr2017.mat');

load(fileName) % Output already has wind variable name
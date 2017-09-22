function armstrong = loadArmstrong
% Data compiled into matfile by Joe Jurisa 2017-08-31

% Data Directory
if isunix
    atticBase = fullfile('/nfs','attic');
elseif ispc
    atticBase = fullfile('\\attic.engr.oregonstate.edu');
end
baseDir = fullfile(atticBase,'hallerm','RADAR_DATA','ctr','supportData','armstrong');
fileName = fullfile(baseDir,'ctr_armstrong_data_merged.mat');

load(fileName)

armstrong = dat; % Rename data structure
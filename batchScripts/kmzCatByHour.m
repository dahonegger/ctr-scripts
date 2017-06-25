%% Get Files
files = getFiles('E:\DAQ-data\processed\');
kmzStackBase = pwd;

if ispc
    attic = '\\attic.engr.oregonstate.edu\hallerm';
else
    attic = '/nfs/attic/hallerm';
end

% kmzConcatenate
% addpath(fullfile('..','kmzConcatenate'));
% addpath(fullfile('..','util'));
% datestr_3dago = datestr(timezone_convert(now-3, [], 'UTC'), 'yyyy-mm-dd');
% 
% kmzBase = fullfile(attic,'RADAR_DATA','CTR','site_push','kmz');
% kmzStackBase = fullfile(attic,'RADAR_DATA','CTR','site_push','kmzStack');
if ~exist(kmzStackBase,'dir');mkdir(kmzStackBase);end

dayDirs = dir(fullfile(kmzBase, '20*-*-*'));

% Get existing kmzStack files
exgKmzDayStacks = dir(fullfile(kmzStackBase, 'kmzStack_20*-*-*.kmz'));

for i = 1:numel(dayDirs)
    fprintf('Stacking %s...', dayDirs(i).name);
    dayDir = dayDirs(i).name;
    dayKmzs = dir(fullfile(kmzBase, dayDir, '*.kmz'));
    if isempty(dayKmzs)
        fprintf('Day empty.\n');
        continue
    end
    stackName = ['kmzStack_', dayDir, '.kmz'];
    if ismember(stackName, {exgKmzDayStacks.name}) && strlte(dayDir, datestr_3dago)
        fprintf('Exists.\n');
        continue
    end
    kmzConcatenate(dayKmzs,fullfile(kmzStackBase,stackName))
    fprintf('Done.\n')
end

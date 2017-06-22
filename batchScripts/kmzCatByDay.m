%% Get Files
if ispc
    attic = '\\attic.engr.oregonstate.edu\hallerm';
else
    attic = '/nfs/attic/hallerm';
end

% kmzConcatenate
addpath(fullfile('..','kmzConcatenate'));

kmzBase = fullfile(attic,'RADAR_DATA','CTR','site_push','kmz');
kmzStackBase = fullfile(attic,'RADAR_DATA','CTR','site_push','kmzStack');
if ~exist(kmzStackBase,'dir');mkdir(kmzStackBase);end

dayDirs = dir(fullfile(kmzBase, '20*-*-*'));

% Get existing kmzStack files
exgKmzDayStacks = dir(fullfile(kmzStackBase, 'kmzStack_20*-*-*.kmz'));

for i = 1:numel(dayDirs)
    fprintf('Stacking %s...', dayDirs(i).name);
    dayDir = dayDirs(i).name;
    stackName = ['kmzStack_', dayDir, '.kmz'];
    if ismember(stackName, {exgKmzDayStacks.name}) && i < numel(dayDirs)-3
        fprintf('Exists.\n');
        continue
    end
    dayKmzs = dir(fullfile(kmzBase, dayDir, '*.kmz'));
    kmzConcatenate(dayKmzs,fullfile(kmzStackBase,stackName))
    fprintf('Done.\n')
end

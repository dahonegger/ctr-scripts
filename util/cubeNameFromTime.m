function [fileToGrab,timeDiff] = cubeNameFromTime(dnIn,sourceDir,grabRule,threshold)
%
% This function reads in a time (UTC) and loads the Cube that is nearest in
% time (or inclusive of the time) provided.

% dataSource = fullfile('D:','Data','CTR','postprocessed','rectCubes',filesep);
% dataSource = fullfile('E:','LyndePt');

persistent dnList fileList;
% dnList = [];fileList = [];

dataSource = sourceDir;

% Defaults
defaultThreshold = 20/60/24; % 20 mins
defaultGrabRule = 'absolute';
if nargin<3
    grabRule = defaultGrabRule;
    threshold = defaultThreshold;
elseif nargin<4
    threshold = defaultThreshold;
end

if isempty(dnList) || isempty(fileList)
    fileList = dir([dataSource,'*.mat']);

    doLoopThruDays = false;
    if isempty(fileList)
    %     fprintf('No matfiles in source directory. Assuming archive file structure.\n')
        doLoopThruDays = true;
    end


    if doLoopThruDays
        fileList = dir(fullfile(dataSource, '20*-*-*', '*.mat'));

    end
    if ~isfield(fileList,'folder')
        [fileList(:).folder] = deal(dataSource);
    end
    dnList = dnFromTimeStamps(fileList);
end

timeDiffVec = dnList - dnIn;

doThrowWarning = false;
switch grabRule
    case 'absolute' % Whatever is closest
        [timeDiff,fileIdx] = min(abs(timeDiffVec));
    case 'after'
        timeDiffVec(timeDiffVec<0)=max(timeDiffVec);
        [timeDiff,fileIdx] = min(timeDiffVec);
    case 'before'
        timeDiffVec(timeDiffVec>0) = min(timeDiffVec);
        [timeDiff,fileIdx] = max(timeDiffVec);
end


if abs(timeDiff) < threshold
    fileToGrab = fullfile(fileList(fileIdx).folder,fileList(fileIdx).name);
else
    doThrowWarning = true;
end

if doThrowWarning
    %
%     warning('Nearest run, %s, is %.0f min from the input time of %s.\nThis exceeds threshold of %.0f min.\n',...
%                 fileList(fileIdx).name,abs(timeDiff)*24*60,datestr(dnIn),threshold*24*60)
    fileToGrab = [];
end

end

function dnList = dnFromTimeStamps(fileList)
    % Extract timestamps
    dn_strs = regexp({fileList.name}, '20\d{9}', 'match', 'once');
    dt_vals = cellfun(@(C) sscanf(C, '%4f%3f%2f%2f'), dn_strs, 'UniformOutput', false);
    dnList = cellfun(@(C) datenum([C(1), 0, C(2:4)', 0]), dt_vals);
end
function [Cube,timeDiff] = grabCubeFromTime(dnIn,grabRule,threshold)
%
% This function reads in a time (UTC) and loads the Cube that is nearest in
% time (or inclusive of the time) provided.

% dataSource = fullfile('D:','Data','CTR','postprocessed','rectCubes',filesep);
dataSource = fullfile('E:','LyndePt');

% Defaults
defaultThreshold = 10/60/24; % 10 mins
defaultGrabRule = 'absolute';
if nargin<2
    grabRule = defaultGrabRule;
    threshold = defaultThreshold;
elseif nargin<3
    threshold = defaultThreshold;
end
    
fileList = dir([dataSource,'*.mat']);

doLoopThruDays = false;
if isempty(fileList)
    fprintf('No matfiles in source directory. Assuming archive file structure.\n')
    doLoopThruDays = true;
end
    

if doLoopThruDays
    folderList = dir(fullfile(dataSource,'2017-*'));
    if ~isfield(folderList,'folder');[folderList(:).folder] = deal(dataSource);end
    
    dnList = [];
    folderNum = [];
    fileNum = [];
    for iDay = 1:length(folderList)
        folderList(iDay).fileList = dir(fullfile(folderList(iDay).folder,folderList(iDay).name,'*.mat'));
        
        folderList(iDay).dnList = dnFromTimeStamps(folderList(iDay).fileList);
        dnList = [dnList;folderList(iDay).dnList];
        folderNum = [folderNum;0*folderList(iDay).dnList+iDay];
        fileNum = [fileNum,1:length(folderList(iDay).dnList)];
    end
else
    if ~isfield(fileList,'folder');[fileList(:).folder] = deal(dataSource);end
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
    if doLoopThruDays
        fileToGrab = fullfile(folderList(folderNum(fileIdx)).fileList(fileNum(fileIdx)).name);
    else
        fileToGrab = fullfile(fileList(fileIdx).folder,fileList(fileIdx).name);
    end
    fprintf('Grabbing %s. Deltatime = %.1f min\n',fileToGrab,timeDiff*24*60)
else
    doThrowWarning = true;
end

if doThrowWarning
   warning(sprintf('Nearest run, %s, is %.0f min from the input time of %s.\nThis exceeds threshold of %.0f min.\n',...
                fileList(fileIdx).name,abs(timeDiff)*24*60,datestr(dnIn),threshold*24*60))
end

Cube = load(fileToGrab);
end

function dnList = dnFromTimeStamps(fileList)
    % Extract timestamps
    yy = zeros(size(fileList));
    [yd,HH,MM,SS] = deal(yy);
    dnList = nan(size(fileList(:)));
    for i = 1:length(fileList)
        key = '20';
        strIdx = strfind(fileList(i).name,key);
        yy(i) = str2double(fileList(i).name(strIdx:strIdx+3));
        yd(i) = str2double(fileList(i).name(strIdx+4:strIdx+6));
        HH(i) = str2double(fileList(i).name(strIdx+7:strIdx+8));
        MM(i) = str2double(fileList(i).name(strIdx+9:strIdx+10));

        dnList(i) = datenum([yy(i) 0 yd(i) HH(i) MM(i) SS(i)]);
    end
end
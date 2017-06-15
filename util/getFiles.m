function [dirs] = getFiles(goToPath,searchStr,filetype)

if ~exist('goToPath','var') || isempty(goToPath)
    goToPath = './';
end
if ~exist('searchStr','var') || isempty(searchStr)
    searchStr = '*';
end
if ~exist('filetype','var') || isempty(filetype)
    filetype = '*';
end

[FileName,PathName] = uigetfile(sprintf('%s%s.%s',goToPath,searchStr,filetype),'multiselect','on');

if iscell(FileName)
    for i = 1:length(FileName)
        dirs(i).name = char(FileName(i));
        dirs(i).path = char(PathName);
        dirs(i).folder = char(PathName);
    end
else
    if FileName == 0
        dirs.name = [];
        dirs.path = [];
    else
        dirs.name = char(FileName);
        dirs.path = char(PathName);
        dirs.folder = char(PathName);
    end
end
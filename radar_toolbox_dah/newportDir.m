function [file] = newportDir(dateNumStart,dateNumEnd,cubeType,decim)

file = [];

if nargin<3
    cubeType = 'pol';
    decim = 1;
elseif nargin<4
    decim = 1;
end

if isunix
    newportRemoteRadarDir = fullfile(filesep,'nfs','attic','hallerm','RADAR_DATA','Newport','RemoteRadar',filesep);
elseif ispc
    newportRemoteRadarDir = fullfile('\\attic.engr.oregonstate.edu','hallerm','RADAR_DATA','Newport','RemoteRadar',filesep);
end

% Parse input dateNums
dateVecStart = datevec(dateNumStart);
dateVecEnd = datevec(dateNumEnd);

years = unique([dateVecStart(1),dateVecEnd(1)]);
if length(years)==1
    months = dateVecStart(2):dateVecEnd(2);
elseif length(years)==2
    months = [dateVecStart(2):12,1:dateVecEnd(2)];
elseif length(years)>2
    months = [dateVecStart(2):12,repmat(1:12,1,length(years)-2),1:dateVecEnd(2)];
end

count = 1;
for yy = years
    for mm = months
        for dd = 1:31
            folderName = sprintf('%s%04d%s%04d-%02d-%02d%s',...
                newportRemoteRadarDir,yy,filesep,yy,mm,dd,filesep);
            if exist(folderName,'dir')
                switch cubeType
                    case 'pol'
                        dirOut = dir([folderName,'*pol*.mat']);
                        for i = 1:length(dirOut)
                            dirOut(i).ddd = str2double(dirOut(i).name(17:19));
                            dirOut(i).HH = str2double(dirOut(i).name(20:21));
                            dirOut(i).MM = str2double(dirOut(i).name(22:23));
                            dirOut(i).dateNumStamp = datenum([yy,0,dirOut(i).ddd,dirOut(i).HH,dirOut(i).MM,0]);
                            
                            if dirOut(i).dateNumStamp>=dateNumStart && dirOut(i).dateNumStamp<=dateNumEnd
                                file(count).path = folderName;
                                file(count).name = dirOut(i).name;
                                
                                count = count+1;
                            end
                        end
                end
            end
        end
    end
end

file = file(1:decim:end);
        
if isempty(file)
    error('No files found')
end
end
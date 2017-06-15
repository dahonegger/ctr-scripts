kmzBase = fullfile('\\attic.engr.oregonstate.edu','hallerm','RADAR_DATA','CTR','postprocessed','rectKmz');
kmzFullList = dir(fullfile(kmzBase,'*.kmz'));
if ~isfield(kmzFullList,'folder');[kmzFullList(:).folder] = deal(kmzBase);end
    

kmzStackBase = fullfile(kmzBase,'..','kmzStack');
if ~exist(kmzStackBase,'dir');mkdir(kmzStackBase);end

% Extract timestamps
yy = zeros(size(kmzFullList));
yd = yy;
mm = yy;
dd = yy;
for i = 1:length(kmzFullList)
    
    key = '20';
    strIdx = strfind(kmzFullList(i).name,key);
    yy(i) = str2double(kmzFullList(i).name(strIdx:strIdx+3));
    yd(i) = str2double(kmzFullList(i).name(strIdx+4:strIdx+6));
    
    dv = datevec(datenum([yy(i) 0 yd(i) 0 0 0]));
    mm(i) = dv(2);
    dd(i) = dv(3);
    
end

% Separate by day
yearDayList = unique(yd);
for iDay = 1:length(yearDayList)
    
    thisYearDay = yearDayList(iDay);
    kmzIdxList = find(yd==thisYearDay);
    
    thisYear = yy(kmzIdxList(1));
    thisMonth = mm(kmzIdxList(1));
    thisDay = dd(kmzIdxList(1));
    
    concatKmzName = sprintf('kmzStack_%sUTC.kmz',datestr([thisYear thisMonth thisDay 0 0 0],'yyyy-mmm-dd'));
    
    kmzConcatenate(kmzFullList(kmzIdxList),fullfile(kmzStackBase,concatKmzName))
    
end
    
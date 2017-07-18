%% Get Files
% scrDir = fullfile('C','Data','CTR','ctr-scripts');
scrDir = fullfile(depotDir,'haller','shared','honegger','radar','usrs','connecticut','ctr-scripts');
inputDir = fullfile(atticDir,'hallerm','RADAR_DATA','CTR','site_push','kmz',filesep);


addpath(genpath(scrDir));
files = getFiles(inputDir,'','kmz');


% kmzStackBase = fullfile('C:','Data','CTR','kmzStackByHour');
kmzStackBase = files(1).folder;
% if ~exist(kmzStackBase,'dir');mkdir(kmzStackBase);end


clear yyyy ddd HH
for i = 1:numel(files)
    yyyy(i) = str2double(files(i).name(9:12));
    ddd(i) = str2double(files(i).name(13:15));
    HH(i) = str2double(files(i).name(16:17));
end

dn = datenum([yyyy(:) 0*ddd(:)+1 ddd(:) HH(:) 0*HH(:) 0*HH(:)]);
dv = datevec(dn);

[uniqueHrs] = unique(HH);

for i = 1:numel(uniqueHrs)
    idx = find(HH==uniqueHrs(i));
    files2stacker = files(idx);
    
    
    kmzStackName = sprintf('LyndePt_%s-Hr%s',datestr(dn(idx(1)),'yyyymmmdd'),datestr(dn(idx(1)),'HH'));
    
    kmzStackFile = fullfile(kmzStackBase,[kmzStackName,'.kmz']);
    
    kmzConcatenate(files2stacker,kmzStackFile)
end

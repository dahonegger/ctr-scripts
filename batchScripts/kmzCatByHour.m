%% Get Files
scrDir = addpath(genpath(fullfile('C:','Data','CTR','ctr-scripts')));
files = getFiles('D:\DAQ-data\processed\','','kmz');
kmzStackBase = fullfile('C:','Data','CTR','kmzStackByHour');
if ~exist(kmzStackBase,'dir');mkdir(kmzStackBase);end


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
    
    
    kmzStackName = sprintf('LyndePt_%s-Hour-%s',datestr(dn(idx(1)),'ddmmmm'),datestr(dn(idx(1)),'HH'));
    
    kmzStackFile = fullfile(kmzStackBase,[kmzStackName,'.kmz']);
    
    kmzConcatenate(files2stacker,kmzStackFile)
end

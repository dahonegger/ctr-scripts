function [dn,dv,timeStampOut] = parseTimestamp(timeStamp,yr,timezoneOffset)

% Input:
% timeStamp: string (dddhhmm), where ddd is yearday
% yr: double, helps determine if is leap year or not
% timezoneOffset: #hours to change for output date vector (e.g. EDT=>UTC =
% +4)
% timeStampOut = output timestamp (only helpful if timezone is changed)

if nargin<2
    [yr,~,~,~,~,~] = datevec(now);
    timezoneOffset = 0;
elseif nargin<3
    timezoneOffset = 0;
end

ddd = str2double(timeStamp(1:3));
HH = str2double(timeStamp(4:5));
MM = str2double(timeStamp(6:7));

dn = datenum([yr 0 ddd HH+timezoneOffset MM 0]);
dv = datevec(dn);

isLeap = ~logical(mod(yr,4));
ddd2 = yearday(dv(2),dv(3),isLeap);
timeStampOut = sprintf('%03d%02d%02d',ddd2,dv(4),dv(5));
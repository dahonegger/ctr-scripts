function [dnWind,vWind,dirWind] = loadWindStation(fname, tquery)
%loadWindStation loads and reads a .csv file of wind data downloaded from
%Meso West (http://mesowest.utah.edu/) 

%  input variables: 
    %   fname: file name (likely 'SABC3.csv')
    %   tquery UTC (optional): time desired from file (likely 'nowTime')
        
%  output variables:
    %   dnWind: datenum time (UTC)
    %   vWind: velocity of wind (m/s)
    %   dirWind: direction of wind (cardinal degrees)

% Alex Simpson 6/14/17

fid=fopen(fname);
for i = 1:8
    [~] = fgetl(fid);
end
tline = fgetl(fid);
k=1;
while ~feof(fid)
    tmp = textscan(tline,'%4c%f,%2f/%2f/%4f %2f:%2f %3c,%f,%f');
    if ~isempty(tmp{9}) && ~isempty(tmp{10})
    dnWind(k) = datenum([tmp{5} tmp{3} tmp{4} tmp{6} tmp{7} 0]); %UTC
    vWind(k) = double(tmp{9});
    dirWind(k) = double(tmp{10});
    else
    end
    tline = fgetl(fid);
    k=k+1;
end
fclose(fid);

if nargin > 1
    tmp = abs(dnWind-tquery);
    if tmp > 60 %when file runs out...
%         msg = 'There is no wind information available within 60 mins of the radar file.';
%         error(msg);
        [idx idx] = 0; %index of closest value
        dnWind = tquery; %closest time 
        vWind = 0;
        dirWind = 0;
   
    else
        [idx idx] = min(tmp); %index of closest value
        dnWind = dnWind(idx); %closest time 
        vWind = vWind(idx);
        dirWind = dirWind(idx);
    end
else
end


% Syntax of wind .csv file:
% SABC3,05/05/2017 19:00 UTC,7.87,92.0
% '%4c%f,%2f/%2f/%4f %2f:%2f %3c,%1.2f,%2.1f'
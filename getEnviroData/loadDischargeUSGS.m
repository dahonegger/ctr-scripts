function [ dnDischarge,rawDischarge,trDischarge ] = loadDischargeUSGS(fname)
%loadDischarge loads and reads USGS discharge data from the .txt file

%   input:
    %   fname: file name of .txt file (maybe 'CTdischarge_Site01193050.txt')
%   outputs:
    %   dnDischarge: datenum time UTC **note that USGS reported is EDT,
        %      this function converts from EDT to UTC
    %   rawDischarge: raw discharge
    %   trDischarge: tidally referenced discharge reported by USGS

	% Alex Simpson 6/14/17

fid=fopen(fname);
for i = 1:30
    [~] = fgetl(fid);
end
tline = fgetl(fid);
k=1;
while ~feof(fid)   
 
    tmp = textscan(tline,'%4c\t%f\t%4f-%2f-%2f %2f:%2f\t%3c %f\t%c\t%f%t%c');
    dnDischarge(k) = datenum([tmp{3} tmp{4} tmp{5} tmp{6} tmp{7} 0]) + (4/24); % time converted to UTC
    rawDischarge(k) = tmp{9};
    if ~isempty(tmp{11})
        trDischarge(k) = tmp{11};
    else
        trDischarge(k) = NaN;
    end
        tline = fgetl(fid);
    k=k+1;
end

fclose(fid);


end


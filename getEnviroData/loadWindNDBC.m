function [dnWind,vWind,dirWind] = loadWindNDBC(fname, tquery)
%loadWindNDBC loads and reads .txt file of NDBC met data
%   file e.g. http://www.ndbc.noaa.gov/data/realtime2/44039.txt

%  input variables: 
    %   fname: file name (possibly 'MetData_NDBC44039.txt')
    %   tquery UTC (optional): time desired from file (possibly 'nowTime' variable)
        
%  output variables:
    %   dnWind: datenum time (UTC)
    %   vWind: velocity of wind (m/s)
    %   dirWind: direction of wind (cardinal degrees wind is coming from)

% Alex Simpson 6/17/17


fid=fopen(fname);
for i = 1:2
    [~] = fgetl(fid);
end
tline = fgetl(fid);
k=1;
while ~feof(fid)
    tmp = sscanf(tline,'%4f %02d %02d %02d %02d %f %f',7);
    if numel(tmp)==7
    dnWind(k) = datenum([tmp(1) tmp(2) tmp(3) tmp(4) tmp(5) 0]); %UTC
    vWind(k) = double(tmp(7));
    dirWind(k) = double(tmp(6));
    else
    end
    tline = fgetl(fid);
    k=k+1;
end
fclose(fid);
if nargin > 1
    
    tmp = min(abs(dnWind-tquery));
    if tmp > 60 %when file runs out...
        % KEEP ERROR IF YOU WANT PROCESSING TO STOP
        msg = 'There is no wind information available within 60 mins of the radar file.';
        fprintf(msg);
%         error(msg);
        % UNCOMMENT BELOW IF YOU WANT PROCESSING TO CONTINUE, WITHOUT WIND DATA
        dnWind = tquery; %closest time 
        vWind = 0.1;
        dirWind = 0;
    else
          [dnWind, index] = unique(dnWind);  
          dirWind = interp1(dnWind,dirWind(index),tquery);
          vWind = interp1(dnWind,vWind(index),tquery);
          dnWind = tquery;
          if vWind == 0 || isnan(vWind)
              vWind = 0.1;
          else
          end
        
        
%         [idx idx] = min(tmp); %index of closest value
%         dnWind = dnWind(idx); %closest time 
%         vWind = vWind(idx);
%         dirWind = dirWind(idx);
   
    end
else
end


end


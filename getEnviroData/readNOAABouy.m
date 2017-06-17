function [bouyTime,bouyWSPD,bouyWDIR,bouyPRES]=readNOAABouy(bouyNum,numYears)
%% Copyright 2016 The MathWorks, Inc.
% Download historical bouy wind data to train the Neural Network.  Note 
% that the buoy provides wind data with a delay of just over one hour. The data 
% stored on the NOAA website is availble for the past 45 days, by month for the 
% current year, and by year historically.  The formats are sightly different.
% 
% Start by downloading the past 45 days. Headings are:
% 
% |#YY  MM DD hh mm WDIR WSPD GST  WVHT   DPD   APD MWD   PRES  ATMP  WTMP  
% DEWP  VIS PTDY  TIDE |
% 
% |#yr  mo dy hr mn degT m/s  m/s     m   sec   sec degT   hPa  degC  degC  
% degC  nmi  hPa    ft|

url=strcat('http://www.ndbc.noaa.gov/data/realtime2/',num2str(bouyNum),'.txt');
bouyLast45=webread(url);
%% 
% Read char 188 onwards for realtime data to ignore the headings. Replace 
% missing data 'MM' with an unlikely number so that str2num will work and so that 
% it can be replaced later with NaNs.

bouyLast45 = regexprep(bouyLast45(188:end),'MM','12345.4321 ');
bouyLast45 = str2num(bouyLast45);
%% 
% Replace 12345.4321 with NaN

index=find(abs(bouyLast45-12345.4321)<0.1);
bouyLast45(find(abs(bouyLast45-12345.4321)<0.1))=NaN;
%% 
% Next download the current year of data by month. Note that the most
% recent (last) month has a different url. The last month's data is not
% updated exactly at the beginning of the month. Headings are:
% 
% |#YY  MM DD hh mm WDIR WSPD GST  WVHT   DPD   APD MWD   PRES  ATMP  WTMP
% DEWP  VIS  TIDE |
% 
% |#yr  mo dy hr mn degT m/s  m/s     m   sec   sec deg    hPa  degC  degC
% degC  nmi    ft|

bouyCurrentYear = [];

if day(now)<=15
    dataMonth = month(now)-1;
else
    dataMonth = month(now);
end

for mm=1:dataMonth-1
    if isequal(mm,dataMonth-1)
        lastMonth = datestr([2016,dataMonth-1,1,1,1,1],'mmm');
        url = horzcat('http://www.ndbc.noaa.gov/data/stdmet/',lastMonth,'/',num2str(bouyNum),'.txt');        
    else        
    monthName = datestr([2016,mm,1,1,1,1],'mmm');
    monthnum = num2str(mm);
    yearnum = num2str(year(now)); 
    url = horzcat('http://www.ndbc.noaa.gov/view_text_file.php?filename=',num2str(bouyNum),monthnum,yearnum,'.txt.gz&dir=data/stdmet/',monthName,'/');
    end

bouyDat=webread(url);   
%% 
% Read char 179 onwards for realtime data to ignore the headings. Replace 
% missing data 'MM' with an unlikely number so that str2num will work and so that 
% it can be replaced later with NaNs.

    bouyDat = regexprep(bouyDat(179:end),'MM','12345.4321 ');
    bouyDat = str2num(bouyDat);
%% 
%     Replace 12345.4321 with NaN

    index=find(abs(bouyDat-12345.4321)<0.1);
    bouyDat(find(abs(bouyDat-12345.4321)<0.1))=NaN;
    
    bouyCurrentYear = vertcat(bouyCurrentYear,bouyDat);
    
end

%% 
% Download data from previous years.  http://www.ndbc.noaa.gov/view_text_file.php?filename=44020h2015.txt.gz&dir=data/historical/stdmet/
% 
% Headings are:
% 
% |#YY  MM DD hh mm WDIR WSPD GST  WVHT   DPD   APD MWD   PRES  ATMP  WTMP  
% DEWP  VIS  TIDE |
% 
% |#yr  mo dy hr mn degT m/s  m/s     m   sec   sec degT   hPa  degC  degC  
% degC   mi    ft|

bouyPastYears = [];
numYears=1;

for yy=year(now)-numYears:year(now)-1
    yearnum = num2str(yy); 
    url = horzcat('http://www.ndbc.noaa.gov/view_text_file.php?filename=',num2str(bouyNum),'h',yearnum,'.txt.gz&dir=data/historical/stdmet/');

bouyDat=webread(url);
%% 
% Read char 179 onwards for realtime data to ignore the headings. Replace 
% missing data 'MM' with an unlikely number so that str2num will work and so that 
% it can be replaced later with NaNs.

    bouyDat = regexprep(bouyDat(179:end),'MM','12345.4321 ');
    bouyDat = str2num(bouyDat);
%% 
%     Replace 12345.4321 with NaN

    index=find(abs(bouyDat-12345.4321)<0.1);
    bouyDat(find(abs(bouyDat-12345.4321)<0.1))=NaN;
    
    bouyPastYears = vertcat(bouyPastYears,bouyDat);
    
end
%% 
% Delete the unique 'PTDY' data column in the 45 day data, combine the data 
% into one matrix, remove the duplicate rows and sort.

bouyLast45(:,18) = [];

bouyData = vertcat(bouyLast45,bouyCurrentYear,bouyPastYears);
%% 
% Duplicate times have slight data differences so filter only on the date 
% fields.

[C,ia,ic] = unique(bouyData(:,1:4),'rows');
bouyData = bouyData(ia,:);
%% 
% Extract the time, wind and pressure data.

bouyTime = datetime(bouyData(:,1),bouyData(:,2),bouyData(:,3),bouyData(:,4),bouyData(:,5),0);
bouyTime.TimeZone = 'UTC';

bouyWSPD = bouyData(:,7);
bouyWDIR = bouyData(:,6);
bouyPRES = bouyData(:,13);

end

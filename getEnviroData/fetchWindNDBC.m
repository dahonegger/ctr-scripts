function [ ] = fetchWindNDBC(buoyNum,saveDir,fname)
%fetchWindNDBC downloads a .txt file of met data from NDBC webpage
% buoy number is the buoy you want (e.g. 44039 for Central Long Island Sound)
% saveDir is where you want to save it
% fname is the file name you want to save it as

% Alex Simpson 6/17/17

filename = [saveDir,'\',fname];
url = ['http://www.ndbc.noaa.gov/data/realtime2/',num2str(buoyNum),'.txt']; 
websave(filename, url);

end


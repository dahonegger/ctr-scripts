function [ ] = fetchDischargeUSGS(saveDir,fname)
%fetchDischargeUSGS specifically designed for fetching this discharge file:
% 'https://waterdata.usgs.gov/nwis/uv?cb_00060=on&cb_72137=on&format=rdb&site_no=01193050&period=&begin_date=2017-05-15&end_date=2017-06-16'
% USGS 01193050 CONNECTICUT RIVER AT MIDDLE HADDAM, CT
% starting may 15, 2017
% ending at time function is run 

% saveDir = fullfile('E:\','SupportData','Discharge');
% fname = 'CTdischarge_Site01193050.txt';

filename = fullfile(saveDir,fname);
start_day_str = '2017-05-15';
c=clock;
end_day_str = [num2str(c(1)),'-',num2str(c(2)),'-',num2str(c(3))];
url = ['https://waterdata.usgs.gov/nwis/uv?cb_00060=on&cb_72137=on&format=rdb&site_no=01193050&period=&begin_date=',start_day_str,'&end_date=',end_day_str];

websave(filename, url);

% sprintf(['The USGS discharge file ',fname,' has been saved.']) 

end


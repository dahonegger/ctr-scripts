

baseDir = 'E:\DAQ-data\wind\raw\';
[FFTdnWind, FFTmagWind, FFTdirWind] = loadFFTechWind_allfiles(baseDir);

% dayFolder = dir([baseDir,'2017*']);
% 
% FFTdnWind = [];
% FFTmagWind = [];
% FFTdirWind = [];
% 
% for iDay = 1:length(dayFolder)
%     directory_name = fullfile('E:\','DAQ-data','wind','raw',dayFolder(iDay).name);
%     files = dir(directory_name);
%     fileIndex = find(~[files.isdir]);
%     for iRun = 1:length(fileIndex)
%         
%         fileName = files(fileIndex(iRun)).name;
%         
%         wind = loadFTTechLog(fullfile(directory_name,fileName));
%         
%         FFTdnWind = horzcat(FFTdnWind,wind.dateNum);
%         FFTmagWind = horzcat(FFTmagWind,wind.speed);
%         FFTdirWind = horzcat(FFTdirWind,wind.direction);
%         
%     end
%     
%     
% end

%% load NDBC
[NDBCdnWind,NDBCmagWind,NDBCdirWind] = loadWindNDBC('E:\SupportData\Wind\MetData_NDBC44039.txt');

%% make plot

figure
subplot(2,1,1)
hold on
plot(NDBCdnWind,NDBCmagWind,'.r','markersize',8)
plot(FFTdnWind,FFTmagWind,'.b')
legend('NDBC','FFTech')
xlim([min(FFTdnWind) max(FFTdnWind)])
datetick('x','keepticks','keeplimits')
ylabel('Wind Speed [m/s]')

subplot(2,1,2)
hold on
plot(NDBCdnWind,NDBCdirWind,'.r','markersize',8)
plot(FFTdnWind,FFTdirWind,'.b')
legend('NDBC','FFTech')
xlim([min(FFTdnWind) max(FFTdnWind)])
datetick('x','keepticks','keeplimits')


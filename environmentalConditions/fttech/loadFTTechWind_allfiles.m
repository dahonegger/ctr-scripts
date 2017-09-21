function [FFTdnWind, FFTmagWind, FFTdirWind] = loadFTTechWind_allfiles( baseDir )
%LOADFFTECHWIND_ALLFILES uses 'loadFTTechLog.m' which loads one .csv wind
    %   file to load all wind files from a directory 'baseDir'

% INPUTS
%baseDir is the directory that contains the day folders (which contain the
    %   csv files)
    
% e.g. baseDir = 'E:\DAQ-data\wind\raw\';

% OUTPUTS 
% dnWind = matlab time vector in UTC
% dirWind = direction winds are coming from
% magWind = magnitude of winds [m/s]

% Alex Simpson %6/23/17

dayFolder = dir(fullfile(baseDir,'2017*'));

FFTdnWind = [];
FFTmagWind = [];
FFTdirWind = [];

for iDay = 1:length(dayFolder)
    directory_name = fullfile(baseDir,dayFolder(iDay).name);
    files = dir(directory_name);
    fileIndex = find(~[files.isdir]);
    for iRun = 1:length(fileIndex)
        
        fileName = files(fileIndex(iRun)).name;
        try
            wind = loadFTTechLog(fullfile(directory_name,fileName));

            FFTdnWind = horzcat(FFTdnWind,wind.dateNum);
            FFTmagWind = horzcat(FFTmagWind,wind.speed);
            FFTdirWind = horzcat(FFTdirWind,wind.direction);
        end
    end  
end

end


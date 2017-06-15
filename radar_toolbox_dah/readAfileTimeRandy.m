function [AZI,results,header,timeMat]=readAfileTime(fname,year,utcOffset,header)
%% Import own package
% import +radar_toolbox
[~, pkgdir] = fileparts(fileparts(mfilename('fullpath')));
if pkgdir(1) == '+', import([pkgdir(2:end) '.*']); end

%% Read in the A File
fid=fopen(['A' fname(2:8) '.txt']); %opening the text file.

%read the first three lines--throw away
[~] = textscan(fid, '%s %s %s %s %s %s %s', 3);
%now we collect all the data at once
A = textscan(fid,'%f %f %f %f %f %f', header.rotations*header.collections);
%A = textscan(fid,'%d %d%6*s%2d%8*c%2d%8*c%2d%14*c%3d',[header.rotations*header.collections]);%use this one if characters are inlcuded

%and the run length
B = textscan(fid,'%f', 1);
results.RunLength = B{1}; %this is the total number of seconds it took to collect data

fclose(fid); clear B

%% Get out preliminary info from the A file data
results.TrueRPM = header.rotations/(results.RunLength/60); %this is the average RPM for this collection.
results = GetGMTfromRadarFilename(fname,year,utcOffset,results); % This gets the start date and time from the file name, adjusted to UTC (GMT).

% Columns 3, 4, 5, and 6 of the A file are a UTC timestamp. We'll use the
% first one to set the h, m, and s values of the starttime. Note that this
% overwrites someo of the values acquired in GetGMTfromRadarFileName
results.startTime.hour    = A{3}(1);     %this is GMT hour
results.startTime.minute  = A{4}(1);   %
results.startTime.seconds = A{5}(1) + A{6}(1)/1000;

%check if change the day
if (A{3}(1) == 23) && (A{3}(end) == 0) %we had a change of day
    next_day = (A{3} == 0); % these azimuths have a time stamp for the next day
else
    next_day = zeros(size(A{3}));
end
    
results.startTime.epoch = ...
    matlab2Epoch(results.startTime.year, results.startTime.month, ...
    results.startTime.day, results.startTime.hour, ...
    results.startTime.minute, results.startTime.seconds);
results.startTime.dateNum = epoch2Matlab(results.startTime.epoch);
results.startTime.Zone='UTC';
% Now we'll re-structure the variable A
%   first column is the counter
%   second column is the azimuth counter
%   third column is the number of seconds, counted since midnight
A = [A{1} + 1, A{2}, (A{3}*3600 + 3600*24*next_day + A{4}*60 + A{5} + A{6}/1000)];

%correcting the number of collections based on the azimuths file
header.collectionsMod = round(length(A)/header.rotations);

% A is now [the counter, the heading, and the time in seconds, but is
% affected by the wrapping of the hour about the change of day]
clear dummy pos cont fsize %Matlab didn't like to use the structure below if not cleared

%% Calculate the average number of degrees covered in each recorded frame
PRF = 2000; % Pulse Repetition Frequency - number of radar pulses per second
spec_RPM = 44; % number of rpms, 44 in fast mode, 22 in slow (spec'd - not actual)
PPF = header.collections * header.waveforms; % Pulses per frame, or number of pulses recorded for each rotation

True_RPS = results.TrueRPM/60; % rotations per second, with TrueRPM
True_PPR = PRF/True_RPS; % average number of pulses per rotation, with TrueRPM
results.Azimuth_True_rpm = 360*PPF/True_PPR; % average Azimuthal range collected in degrees, per frame. with True RPM

spec_RPS = spec_RPM/60; % rotations per second
spec_PPR = PRF/spec_RPS; % number of pulses per rotation (summed), at 44 RPM
results.Azimuth_44_rpm = 360*PPF/spec_PPR; % average Azimuthal range collected in degrees, per frame. with 44 rpm

%calculating the theoretical Delta t
%theoretical degrees per second.
results.DegreesXSecond = spec_RPS*360; % number of degrees rotated each second, assuming 44 RPM
results.DeltaT = header.waveforms/PRF; % seconds per collection

%% Get the azimuth values converted to degrees and split into rotations

%resetting the counter, we assume it started at theta=0
A(:,2) = A(:,2) - A(1,2);

%now converting to degrees
A(:,2) = A(:,2)*360/4096; %headings in degrees (there are 4096 azimuth ticks per rotation)

%creating the AZImuths matrix
AZI_Old = reshape(A(:,2), [header.collectionsMod,header.rotations]);

%% Make each rotation's azimuths offset from heading zero
% We can do this one of two ways. Either we can assume that the
% first azimuth in every rotation is at heading zero, (which probably
% isn't true), or we can find the smallest first azimuth of each rotation
% and count that to be heading zero. We'll show both here, but use the
% second.

% This is with each first azimuth assumed to be heading zero
AZI_zero_forced = AZI_Old - repmat(AZI_Old(1,:), header.collectionsMod, 1); %removing the crossing of each one (%forcing zero crossing)

%%% Now we'll find the smallest heading zero and use that instead.
% Get the multiples of 360 degrees for each rotation
heading_zeros = (0:header.rotations-1)*360;

% Convert azimuths to a fraction of 360 degrees
offset_AZIs = bsxfun(@minus,AZI_Old,heading_zeros);

% Get the smallest first degrees azimuth value for each rotation
min_heading_zero = min(offset_AZIs(1,:));

% Offset all the heading values by the smallest heading zero value
AZI_zero_smallest = offset_AZIs - min_heading_zero;

%%% Assign the output
AZI = AZI_zero_smallest;

%% Get the average RPM and the RPM error
%calculating the differences
B = diff(A(:,2));
%now transforming that in rotation rate
B = B/results.DeltaT*(60/360); %in rpm

%filtering the wrapping points. Finding the maximum azimuth, and allowing
%+-10 % errors
filterLimits = round(results.Azimuth_True_rpm/10)*10*[0.9 1.1];
filterLimits = (360-filterLimits)*60/360/results.DeltaT;
u = (B <= filterLimits(1)) & (B >= filterLimits(2));
B(u) = 0*Inf;

clear filterLimits u dummy
%computing the average rotation rate of individual rotations
results.AverageRPM = mymean(B);

%difference between the rotation rates, (assuming the elapsed time is more
%accurate). Positive means the antenna rotated slower
results.ErrorRPM = (results.TrueRPM - results.AverageRPM)./results.TrueRPM*100;

%% Time vector interpolation

%now we interpolate the time
timeMat = interpolTimeVector(A(:,2),A(:,3),header);

%convert into epoch time
timeMat = timeMat-timeMat(1)+results.startTime.epoch;

%clear dropped maxAzi B A

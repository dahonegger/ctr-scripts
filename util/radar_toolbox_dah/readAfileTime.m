function [AZI,results,header,timeMat]=readAfileTime(fname,year,utcOffset,header)
%%
%okay, first we do the trick to get the data, since it is in a complicated
%ASCCI formatting
eval(['fid=fopen(''A',fname(2:8),'.txt'');']) %opening the text file.

%read the first three lines, full of crap
A = textscan(fid, '%s %s %s %s %s %s %s', [3]);
%now we collect all the data at once
A = textscan(fid,'%d %d %d %d %d %d', [header.rotations*header.collections]);
%A = textscan(fid,'%d %d%6*s%2d%8*c%2d%8*c%2d%14*c%3d',[header.rotations*header.collections]);%use this one if characters are inlcuded
%and the run length
B = textscan(fid,'%d', [1]);
results.RunLength=double(B{1}); %this is the total number of seconds it took to collect data

fclose(fid); clear B
%%

results.TrueRPM=header.rotations./(results.RunLength/60); %this is the average RPM for this collection.

%%added Apr 21, 2008. Also store the day and epoch time of midnight
% results.startTime.year=2008;
% %the hour in the filename is EST, which is 5 hours off from GMT.we need to
% %correct the day accordingly
% dummyhour=str2num(fname(5:6))+5; %convert to GMT
% if dummyhour>=24
%     dummyhour=str2num(fname(2:4))+1; %fix the day, rolling over the next day in GMT time
% else
%     dummyhour=str2num(fname(2:4));
% end
% [results.startTime.month,results.startTime.day]=yearday2MonthDay(dummyhour,results.startTime.year); %note we assume 2008!
[results]=GetGMTfromRadarFilename(fname,year,utcOffset,results);

%Additionally, the file has some values not related with the rotation at the
%beginning. Here we remove them, but we store the info
results.startTime.hour=double(A{3}(1));     %this is GMT hour
results.startTime.minute=double(A{4}(1));   %
results.startTime.seconds=double(A{5}(1))+double(A{6}(1))/1000;

%check if change the day
if double(A{3}(1))==23 & double(A{3}(end))==0 %we had a change of day
    idx=(double(A{3})==0);
else
    idx=zeros(size(double(A{3})));
end
    
results.startTime.epoch=matlab2Epoch(results.startTime.year,results.startTime.month,results.startTime.day, results.startTime.hour, results.startTime.minute, results.startTime.seconds);
results.startTime.dateNum = epoch2Matlab(results.startTime.epoch);
results.startTime.Zone='GMT';
%reestructuring the variable A
%first column is the counter
%second column is the azimuth counter
%third column is the number of seconds, counted since midnight (
A=[double(A{1})+1 double(A{2}) double(A{3})*3600+3600*24*idx+double(A{4})*60+double(A{5})+double(A{6})/1000];
%A=[A(2:end,:);A(end,:)];
%A is now [the counter, the heading and the time in seconds, but is
%affected by the wrapping of the hour about the change of day]
clear dummy pos cont fsize%Matlab didn't like to use the structure below if not cleared

%%
dummy.nts=2000; % number of triggers per second
dummy.rpm=44; % number of rpms, 44 in fast mode, 22 in slow
ntr=60/results.TrueRPM*dummy.nts./header.waveforms;% number of avg triggers per rotation, with True RPM
results.Azimuth_True_rpm=360*header.collections/ntr; % total Azimuthal range collected, degrees. with True RPM
ntr=60/dummy.rpm*dummy.nts./header.waveforms;% number of avg triggers per rotation
results.Azimuth_44_rpm=360*header.collections/ntr; % total Azimuthal range collected, degrees. assuming 44 rpm

%calculating the theoretical Delta t
%theoretical degrees per second.
results.DegreesXSecond=dummy.rpm*360/60;
results.DeltaT=(header.waveforms/(dummy.nts));

%resetting the counter, we assume it started at theta=0
A(:,2)=A(:,2)-A(1,2);

%%

%now creating the base time domain
tbase=A(:,2)*results.RunLength/(4096*header.rotations); %this is a vector with the time

%now converting to degrees
A(:,2)=A(:,2)*360/4096; %headings in degrees

%correcting the number of collections based on the azimuths file
header.collectionsMod=round(length(A)/header.rotations);

%calculating the differences
B=diff(A(:,2));
%now transforming that in rotation rate
B=B/results.DeltaT*(60/360); %in rpm

%filtering the wrapping points. Finding the maximum azimuth, and allowing
%+-10 % errors
filterLimits=round(results.Azimuth_True_rpm/10)*10*[0.9 1.1];
filterLimits=(360-filterLimits)*60/360/results.DeltaT;
u=find(B<=filterLimits(1)&B>=filterLimits(2));
B(u)=0*Inf;

clear filterLimits u dummy
%computing the average rotation rate of individual rotations
results.AverageRPM=mymean(B);

%difference between the rotation rates, (assuming the elapsed time is more
%accurate). Positive means the antenna rotated slower
results.ErrorRPM=(results.TrueRPM-results.AverageRPM)./results.TrueRPM*100;

%creating the AZImuths matrix
AZI_Old=reshape(A(:,2),[header.collectionsMod,header.rotations]);
AZI=AZI_Old-repmat(AZI_Old(1,:),header.collectionsMod,1); %removing the crossing of each one (%forcing zero crossing)

%%%%%%%%%%%% RANDY'S INPUT %%%%%%%%%%%%%%%%%%%%% Now we'll find the smallest heading zero and use that instead.
% % Get the multiples of 360 degrees for each rotation
% heading_zeros = (0:header.rotations-1)*360;
% 
% % Convert azimuths to a fraction of 360 degrees
% offset_AZIs = bsxfun(@minus,AZI_Old,heading_zeros);
% 
% % Get the smallest first degrees azimuth value for each rotation
% min_heading_zero = min(offset_AZIs(1,:));
% 
% % Offset all the heading values by the smallest heading zero value
% AZI_zero_smallest = offset_AZIs - min_heading_zero;
% 
% %%% Assign the output
% AZI = AZI_zero_smallest;

%%%%%%%%%%%%% END RANDY'S INPUT %%%%%%%%%%%

% now reshaping the matrix, but without forcing the zero-crossing
B=[0:header.rotations-1]*360;
B=repmat(B,header.collectionsMod,1);
AZI_Old=AZI_Old-B;
%%

%now we interpolate the time
timeMat=interpolTimeVector(A(:,2),A(:,3),header);

%convert into epoch time
timeMat=timeMat-timeMat(1)+results.startTime.epoch;

%clear dropped maxAzi B A

function [AZI,results,header,timeMat]=readAfileTimeCOR(fname,header)
%%
%okay, first we do the trick to get the data, since it is in a complicated
%ASCCI formatting

eval(['A=dlmread(''A',fname(2:8),'.txt'');']) %opening the text file.

results.RunLength=A(end,1); %this is the total number of seconds it took to collect data

%remove the first three lines and the last one
A=A(4:end-1,:);


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
[results]=GetGMTfromRadarFilename(fname,2010,results);

%Additionally, the file has some values not related with the rotation at the
%beginning. Here we remove them, but we store the info
results.startTime.hour=double(A(1,3));     %this is GMT hour
results.startTime.minute=double(A(1,4));   %
results.startTime.seconds=double(A(1,5))+double(A(1,6))/1000;



results.startTime.epoch=matlab2Epoch(results.startTime.year,results.startTime.month,results.startTime.day, results.startTime.hour, results.startTime.minute, results.startTime.seconds);
results.startTime.Zone='GMT';
%reestructuring the variable A
%first column is the counter
%second column is the azimuth counter
%third column is the number of seconds, counted since midnight (

A=[double(A(:,1))+1 double(A(:,2)) double(A(:,3))*3600+double(A(:,4))*60+double(A(:,5))+double(A(:,6))/1000];
%A=[A(2:end,:);A(end,:)];

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
A(:,2)=A(:,2)*360/4096;

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

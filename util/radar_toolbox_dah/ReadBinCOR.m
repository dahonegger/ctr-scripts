% Code: ReadBinCOR.m
% Objective: To read the raw radar data contained in Bin and Txt files, eventually
%correcting for missing azimuths if the information is provided. It contains other nested functions
%inside the code to apply all the corrections
%
% Type: Function [Cube]=ReadBinCOR(fname,radar_loc,intoption,xdomR,ydomR)
%
% Call ins: readAfileTime.m
%
% Inputs:
%
%   fname       = file to be loaded, with formatting 2701315 (number)
%   radar_loc   = Radar origin, in meters relative to a reference system. The format is
%                [x_origin, y_origin, heading, doughnut, elev], where the origin is in meters, and the heading
%               is the true heading relative to y-axis, in degrees CW. Doughnut is the number of pixels to
%               removed. It must be at least 1.
%                If the system is relative to the radar itself, set to [0,0,0, doughnut, 0]
%
%   intoption   = Optional argument.
%               -If omitted and xdomR,ydomR are NOT passed on, it assumes that no
%                    interpolation is required.
%               -If omitted and xdomR, ydomR, it assumes that interpolation is
%               required only to get a cartesian map (equivalent to explicit value 2).
%               - If explicit, it can take values:
%                   0: No interpolation at all. Raw Cubes
%                   1: For azimuthal interpolation only.
%                   2: For cartesian interpolation.
%                   3: For azimuthal and snap interpolation
%                   4: Cartesian with snap.
%
%   xdomR       = the physical domain where we will store the data. In
%               meters. Formated as a vector with the grid points
%   ydomR       =  ditto
%
%
% Outputs: Rectified data cubes, in a Matlab structure.
%
%ChangeLog: -Based on ReadRadarBin.m, updated to be more portable on Jan 17, 2007
%           -May 29, 2007: Massive make up: allowed for several interpolation options,
%           included time reading from A.TXT, changing from radar scan to
%           radar snap.
%           - Oct 8, 2007: Added CheckZipper Effect.
%Pending:   Inclusion of jumps files for removal of missing azimuths.


function [Cube]=ReadBinCOR(fname,site,intopt,xdomR,ydomR,nframes)

keeptime = tic;

% Turn all warnings off
warning off all

eval(site)
radar_loc(1) = siteParams.antennaLocation(1);
radar_loc(2) = siteParams.antennaLocation(2);
radar_loc(3) = siteParams.heading;
radar_loc(4) = siteParams.CORdonut;
radar_loc(5) = siteParams.elevation;

switch nargin
%   Only filename given
    case 1
        disp('You have chosen the basic option.')
        disp('Radar is located at origin.')
        disp('Doughnut value is 1.')
        disp('No interpolation will be performed.')
        radar_loc = [0 0 0 1 0];
        intopt = 0;
%   Filename and site given
    case 2
        disp('Interpolation option was neglected. No interpolation will be performed.')
        intopt = 0;
%   User forgot to ask for Cartesian interpolation (intopt = 2)
    case 3
        if ismember(intopt,[0 1 3])
            disp('No x- or y- domains needed')
        elseif ismember(intopt,[2 4])
            disp('Cartesian interpolation was chosen but no domains specified.')
            xdomR = input('Enter xdom:');
            ydomR = input('Enter ydom:');
        end 
end

% Ensure the doughnut value is greater than zero
if radar_loc(4)<1
    disp('The doughnut value must be at least 1. I changed it')
    radar_loc(4)=1;
end

%% opening the file
if (fname)>=1000000 %checking the file name
    fname=['V',num2str(fname),'.bin'];
else
    fname=['V0',num2str(fname),'.bin'];
end

fid = fopen(fname,'r');
while fid < 0
    fprintf('I tried opening %s/%s because I''m looking in the current directory.\n',pwd,fname);
    fullname = input('File open failed. Please enter the .bin folder location. Leave blank to exit.\n','s');
    if isempty(fullname)
        disp('Exiting ReadBin.m')
        return
    else
        fid = fopen(sprintf('%s/%s',fullname,fname),'r');
    end
end



[dummy,count]=fread(fid,[10 1],'uint16');


% assigning the relevant info from the header to be displayed later
header.file=fname;
header.rotations=dummy(2);
header.samples=dummy(4)/2;
header.collections=dummy(5);%+1;
header.gatedelay=dummy(7);
header.waveforms=dummy(8);
%header;
2*(header.rotations*header.collections*header.samples)+10*2;
%%
try %first try to run the non-time a.txt reader. If it fails, call the timed
    [AZI,results,header]=readAfile(fname,header); %calling internal function to read the A.TXT file
    timeMat=[];
catch
    [AZI,results,header,timeMat]=readAfileTimeCOR(fname,header); %calling External function to read the A.TXT file
    disp('Azimuth file read OK, using External Function!');
end
header.collectionsMod=header.collectionsMod*2;

%setting up the cartesian domain (interpolation values 2 or 4)
if intopt==2 | intopt==4
    %now we update the coordinates to make them relative to the radar
    xdomR=xdomR-radar_loc(1);
    ydomR=ydomR-radar_loc(2);

    %and we create the domain as a meshgrid
    [X_D,Y_D]=meshgrid(xdomR,ydomR);
    if intopt==4
        DataInt=zeros([header.samples-radar_loc(4)+1,header.collectionsMod,header.rotations],'uint16');%preallocating, removing the doughnut
    else
        DataInt=zeros([[size(X_D)],header.rotations],'uint16');%preallocating
        disp('interpolating to uniform grid!');
    end
else
    disp('No interpolation to cartesian, data saved in range theta')
    DataInt=zeros([header.samples-radar_loc(4)+1,header.collectionsMod,header.rotations],'uint16');%preallocating, removing the doughnut
end
%%
%for debugging, we use less header rotations
if 0
    header.rotations=10;
    fprintf('Debug Mode: I am going to do %i rotations only \n',header.rotations);
end
%initizize
cont=1;Ifail=[]; zip=0;
%%
for jj=1:header.rotations %we read all the rotations
    %    try
    clear DR
    if exist('jumps')==1
        %first we get how many frames have been missed before
        missedBef=length(find((jumps+1)<=jj)); %we add one to find how many missed BEFORE
        %filePos(jj)=2*(11+2048*484*(jj-1)-missedBef)-1; %position in the file of the beginning of the record
        %fseek(fid,filePos,'bof'); %positioning the file
        missedNow(jj)=length(find(jumps==jj));
    else
        missedNow(jj)=0;
    end
    % pos2(jj)=ftell(fid);
    [DR,count]=fread(fid,[header.samples header.collectionsMod-missedNow(jj)],'uint16'); %this the RAW data
    %  figure;imagesc(DR,[0 255*header.waveforms]);pause
    
    %Check for the Zipper Effect
    [DR,zip]=CheckZipper(DR,17);

    % figure;imagesc(DR,[0 255*header.waveforms]);pause
    %removing the doughnut
    DR=DR(radar_loc(4):end,:);

    range_pol=[1:size(DR,1)]*3; %note that range is hardcoded
    %Calculate the ground range
    sgr	=	radar_loc(5)./range_pol;													%	sine of	grazing	angle
    cgr	=	sqrt(1-sgr.^2);								%	cos	of grazing angle
    Rg = real(range_pol.*cgr);

    DataInt(:,:,jj)=uint16(DR./header.waveforms);
     
     
    
    % imagesc(squeeze(DataInt(:,:,jj)));pause(.1)
    %    catch
    %        Ifail(cont)=jj; %record which rotations were not read
    %        cont=cont+1; %
    %    end

%     Call external function that shows progress
    ShowProgress(jj,header.rotations,5);
end
fclose(fid);

%% Average 7 waveforms, only for MURI
DR=0;
% for jj=1:7
%     DR=DR+double(DataInt(:,jj:end-(7-jj),:))/7;
% end 
for jj = 1:7
    DR=DR+uint16(DataInt(:,jj:end-(7-jj),:))/7;
end 
idx=1:6:header.collections-7/2;
DataInt=uint16(DR(:,idx,:));clear DR;

idx=2:3:header.collectionsMod/2-3;
header.collectionsMod=numel(idx);
AZI=AZI(idx,:);
timeMat=timeMat(idx,:);
disp('Done with Averaging');
%% Now we perform the interpolations in azimuth
if intopt~=0
for jj=1:header.rotations
            DR=double(DataInt(:,:,jj));

if intopt==2

        theta_pol=squeeze(AZI(:,jj));
        %creating the meshgrid for the conversion
        [RR,TT]=meshgrid(Rg,theta_pol);
        RR=RR';TT=TT';
        %and convert into cartesian grid
        [YY,XX,ZZ]=pol2cart(-(TT+radar_loc(3))/180*pi,RR,DR);
        XX=-XX;

        DR=griddata(XX,YY,ZZ,X_D,Y_D,'nearest');
        DataInt(:,:,jj)=uint16(DR./header.waveforms);
    elseif intopt==1 | intopt==3 |intopt==4
        theta_pol=squeeze(AZI(:,jj));
        if jj==1 %only the first rotation, we define the new azimuthal domain (uniform)
            AziU=min(AZI(end,:)); %getting the minimum of the maximum azimuth
            AziU=[0:AziU/(header.collectionsMod-1):AziU];
        end
        newdata=zeros(size(DR,1),header.collectionsMod)*0*Inf; %preallocate with NaNs
        %and now, we interpolate
        if 0
            for kk=1:size(DR,1) %(all ranges), acknowledge the doughnut removal
                newdata(kk,:)=interp1(theta_pol,DR(kk,:),AziU);
            end
        else %this is faster
            [ri,ai]=meshgrid(range_pol,AziU);
            newdata=interp2(range_pol,theta_pol,DR',ri,ai);
            newdata=newdata';
        end

        %we also need to interpolate the time, if present

        if ~isempty(timeMat)
            timeInt(:,jj)=interp1(theta_pol,timeMat(:,jj),AziU);
        end
        DataInt(:,:,jj)=uint16(newdata./header.waveforms);
    
       
    end
end
end

%%

%now we add the option to interpolate to a fixed time domain, in snapshot
%mode
if intopt==3 | intopt==4
    [DataInt,snapTime]=RadarScanToSnap(DataInt,timeInt);
    Cube.snapTime=snapTime;
else
    if ~isempty(timeMat)
        Cube.time=timeMat;
        if exist('timeInt')
            Cube.timeInt=timeInt;
        end
    else
        Cube.time=[];
    end
end
if intopt==3 | intopt==1 %interpolation of azimuths
    Cube.Azi=AziU;
elseif intopt==0
    Cube.Azi=AZI;
end


%now we add the option to convert to cartesian the snap
if intopt==4
    dummy=DataInt;
    DataInt=zeros([[size(X_D)],size(dummy,3)],'uint16');%preallocating

    for jj=1:size(dummy,3)
        if(rem(jj,header.rotations/10)==0)
            fprintf('..Transforming Snapshots to Cartesian...done %d of %d..\n', jj,header.rotations)
        end
        range_pol=[1:size(dummy,1)]*3; %note that range is hardcoded
        %Calculate the ground range
        sgr	=	radar_loc(5)./range_pol;													%	sine of	grazing	angle
        cgr	=	sqrt(1-sgr.^2);								%	cos	of grazing angle
        Rg = real(range_pol.*cgr);
        theta_pol=AziU;
        %creating the meshgrid for the conversion
        [RR,TT]=meshgrid(Rg,theta_pol);
        RR=RR';TT=TT';
        %and convert into cartesian grid
        DR=double(squeeze(dummy(:,:,jj)));
        [YY,XX,ZZ]=pol2cart(-(TT+radar_loc(3))/180*pi,RR,DR);
        XX=-XX;
        DR=griddata(XX,YY,ZZ,X_D,Y_D,'nearest');
        DataInt(:,:,jj)=uint16(DR);
    end
end
clear dummy DR;

Cube.data=DataInt;
Cube.timex=mean(DataInt,3)*size(DataInt,3)/header.rotations;

Cube.whencreated=datestr(now);
Cube.type='RADAR';
Cube.header=header;
Cube.results=results;
Cube.results.heading=radar_loc(3);
Cube.results.XOrigin=radar_loc(1);
Cube.results.YOrigin=radar_loc(2);
Cube.Rg=Rg;
if numel(radar_loc)==5;Cube.results.ZOrigin=radar_loc(5);end;
Cube.results.doughnut=radar_loc(4);

Cube.ZipperCorrected=zip;
Cube.fail_to_read=Ifail;
if intopt==2 | intopt==4
    Cube.xdom=xdomR+radar_loc(1);
    Cube.ydom=ydomR+radar_loc(2);
end

switch intopt
    case 0
        Cube.DataType = 'Raw';
    case 1
        Cube.DataType = 'Interpolated Azimuth';
    case 2
        Cube.DataType = 'Interpolated Cartesian';
    case 3
        Cube.DataType = 'Interpolated Azimuth with Snap';
    case 4
        Cube.DataType = 'Interpolated Cartesian with Snap';
end

Cube.Azi = Cube.Azi';

warning('on');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [AZI,results,header]=readAfile(fname,header)
%%
eval(['A=dlmread(''A',fname(2:8),'.txt'');']) %reading the text file.
results.RunLength=A(end,1); %this is the total number of seconds it took to collect data
results.TrueRPM=header.rotations./(results.RunLength/60); %this is the average RPM for this collection.
%Additionally, the file has some values not related with the rotation at the
%beginning. Here we remove them
dummy=find(A(:,1)==1); %to do so, we look for all the rows that have a counter value "1"
A=A(dummy(end):end-1,:); %we trim those bad values and the run length.
clear dummy %Matlab didn't like to use the structure below if not cleared

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

%now creating the base time domain
tbase=A(:,2)*results.RunLength/(4096*header.rotations); %this is a vector with the time

%now converting to degrees
A(:,2)=A(:,2)*360/4096;

%correcting the number of collections based on the azimuths file
header.collectionsMod=length(A)/header.rotations;

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

clear dropped maxAzi B A

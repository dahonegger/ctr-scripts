%% Code: ReadColumbiaSouthJettyBin.m
% Objective: To read the raw radar data contained in Bin and Txt files, eventually
%correcting for missing azimuths if the information is provided. It contains other nested functions
%inside the code to apply all the corrections
%
% Type: Function [Cube]=ReadColumbiaSouthJettyBin(fname,radar_loc,intoption,xdomR,ydomR)
%
% Call ins: readAfileTime.m
%
% 	EXAMPLE:
%
% [Cube]=ReadColumbiaSouthJettyBin('1890000',[(415281.912896239),(4940646.596603123),57,18,14.144],1,1,1);
%
%
% 	INPUT:
%
%   fname       = 	File-date to be read, with formatting 2701315 (string)
%
%   radar_loc   = 	Radar origin, in meters relative to a reference system.
% 					Format: [x_origin, y_origin, heading, doughnut, elev]
%                	where the origin is in meters, and the heading is the true heading 
%  					relative to y-axis, in degrees CW. Doughnut is the number of pixels to be
%              		removed. It must be at least 1.
%                	If the coordinate system is relative to the antenna itself, 
% 					set radar_loc to: [0,0,0, doughnut, 0].
%
%   intoption   = 	Optional argument.
%               	- If omitted and xdomR,ydomR are NOT passed on, it assumes that no
%                     interpolation is required.
%               	- If omitted and xdomR, ydomR, it assumes that interpolation is
%               	  required only to get a cartesian map (equivalent to explicit value 2).
%               	- If explicit, it can take values:
%                   	0: No interpolation at all. Raw Cubes
%                   	1: For azimuthal interpolation only.
%                   	2: For cartesian interpolation.
%                   	3: For azimuthal and snap interpolation
%                   	4: Cartesian with snap.
%
%   xdomR       = 	Physical x-domain where we will store the interpolated Cartesian data. In
%                 	meters. Formatted as a horizontal or vertical vector with the grid points.
%
%   ydomR       = 	Physical y-domain where we will store the interpolated Cartesian data. In
%                 	meters. Formatted as a horizontal or vertical vector with the grid points.
%
%
% 	OUTPUT: 
%
%	Cube		=	Rectified data (Matlab structure).
%
% 	ChangeLog:      - Changed specifically for South Jetty, header.rotations=15,
%                   line 169 AziU=min(AZI(end,:)); 
%                   - Based on ReadRadarBin.m, updated to be more portable on Jan 17, 2007
%                   - May 29, 2007: Massive make up: allowed for several interpolation options,
%                   included time reading from A.TXT, changing from radar scan to
%                   radar snap.
%                   - Oct 8, 2007: Added CheckZipper Effect.
%                   - July 9, 2010: Added operating system invariance for directory path
%	Pending:        Inclusion of jumps files for removal of missing azimuths.


function [Cube]=ReadColumbiaSouthJettyBin(fname,radar_loc,intopt,xdomR,ydomR)



%% CHANGE THESE PATHS TO THE DATA DIRECTORY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% path to input file: change as appropriate or make a copy of this script under a different name.
if isunix
    pathname = '/nfs/lennon/u1/haller/shared/RADAR_DATA/Columbia_SJ_data';
elseif ispc
    pathname = '\\lennon/u1/haller/shared/RADAR_DATA/Columbia_SJ_data';
elseif ismac
    disp('Really? You''re using a mac? Game over.')
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






%% CHECK INPUT/ESTABLISH DEFAULTS

% Turn all warnings off
warning off all

switch nargin
%   Only filename given
    case 1
        disp('You have chosen the basic option.')
        disp('Radar is located at origin.')
        disp('Doughnut value is 1.')
        disp('No interpolation will be performed.')
        radar_loc = [0 0 0 1 0];
        intopt = 0;
%   Filename and radar_loc given
    case 2
        disp('Interpolation option was neglected. No interpolation will be performed.')
        intopt = 0;
%   User forgot to ask for Cartesian interpolation (intopt = 2)
    case 4
        disp('Explicit Cartesian interpolation was not provided.')
        disp('The script is assuming you wanted Cartesian interpolation')
        disp('and is trying to make up for your error')
%         Actual ydomR data was provided as xdomR argument
        ydomR=xdomR;
%         Actual xdomR data was provided as intopt argument
        xdomR=intopt;
%         Assume user wanted simple Cartesian interpolation
        intopt=2;
end

% Ensure the doughnut value is greater than zero
if radar_loc(4)<1
    disp('The doughnut value must be at least 1. I changed it')
    radar_loc(4)=1;
end

% File names always have 7 digits. User may have neglected a leading zero.
if (fname) >= 1000000 
     fname=['M',num2str(fname),'.bin'];
else
    fname=['M0',num2str(fname),'.bin'];
end

%% OPEN .BIN FILE, READ HEADER
fid = fopen(sprintf('%s/%s',pathname,fname),'r');

% Check if file-load failed
if fid<0;
    disp('Cannot open data file: either file is not present or corrupted.');
    return
end

% Read header from file
[header_data]=fread(fid,[11 1],'uint16');

% Assigning the relevant info from the header to be displayed later
header.file=fname;
header.rotations=header_data(2);
header.samples=header_data(4);
header.collections=header_data(5);%+1;
header.gatedelay=header_data(6);
header.waveforms=header_data(7);
clear header_data

%% OPEN .TXT FILE USING EXTERNAL FUNCTION
try %first try to run the non-time a.txt reader. If it fails, call the timed
     [AZI,results,header]=readAfile(fname,header); %calling internal function to read the A.TXT file
     timeMat=[];
catch ME
    [AZI,results,header,timeMat]=readAfileTime(fname,header); %calling External function to read the A.TXT file
    disp('Azimuth file read OK, using External Function!');
end
if ~isempty(ME)
    disp('peachy')
end

%% SET UP THE DOMAINS
if intopt==2 || intopt==4
    % Update the coordinates to make them relative to the radar
    xdomR=xdomR-radar_loc(1);
    ydomR=ydomR-radar_loc(2);

    % Create the domain as a meshgrid
    [X_D,Y_D]=meshgrid(xdomR,ydomR);
    if intopt==4
		%preallocating, removing the doughnut
        DataInt=zeros([header.samples-radar_loc(4)+1,header.collectionsMod,header.rotations],'uint8');
    else
		%preallocating
        DataInt=zeros([size(X_D),header.rotations],'uint8');
        disp('Interpolating to uniform grid!');
    end
else
    disp('No interpolation to Cartesian, data saved in range/theta')
%     Preallocate the data array: [range,theta,sweeps]. Only preallocate
%     the ranges we know will be used (hence doughnut number is removed)
    DataInt=zeros([header.samples-radar_loc(4)+1,header.collectionsMod,header.rotations],'uint8');
end
%%
%for debugging, we use less header rotations
%if 1
    %header.rotations=5;
    %fprintf('Debug Mode: I am going to do %i rotations only \n',header.rotations);
%end
%initizize
cont=1;Ifail=[]; zip=0;

%% READ IN THE DATA

% =======================
% All-at-once no interpolation option ... doesn't work yet
% if intopt == 0
% %     Read all data at once
%     disp('Loading binary data')
%     [rawdata,count]=fread(fid,[header.samples*header.rotations header.collectionsMod],'uint16');
%     for jj = 1:header.rotations
%         ShowProgress(jj,header.rotations);
%         DataInt(:,:,jj) = rawdata((jj-1)*header.samples+1:jj*header.samples,:);
%     end
%     DataInt = uint8(DataInt/header.waveforms);
% else
% =======================


for jj=1:header.rotations
%     Call external function that shows progress
    ShowProgress(jj,header.rotations);
    
    
% =========================
%     Pseudocode to deal with files that have less than the expected
%     number of rotations:

    %    try
%     if exist('jumps')==1
%         first we get how many frames have been missed before
%         missedBef=length(find((jumps+1)<=jj)); %we add one to find how many missed BEFORE
%         filePos(jj)=2*(11+2048*484*(jj-1)-missedBef)-1; %position in the file of the beginning of the record
%         fseek(fid,filePos,'bof'); %positioning the file
%         missedNow(jj)=length(find(jumps==jj));
%     else
%         missedNow(jj)=0;
%     end
% =========================

%     Save current fileread position
    pos2(jj)=ftell(fid);
    
%     =====================
%     Scratch code from jumps issue:
%     [DR,count]=fread(fid,[header.samples
%     header.collectionsMod-missedNow(jj)],'uint16'); %this the RAW data
%     =====================

%     This the RAW data
    [DR,count]=fread(fid,[header.samples header.collectionsMod],'uint16'); 
    
    %figure;imagesc(DR,[0 255*header.waveforms]);
    %Check for the Zipper Effect
    [DR,zip]=CheckZipper(DR,17);

    %figure;imagesc(DR,[0 255*header.waveforms]);
    %removing the doughnut
    DR=DR(radar_loc(4):end,:);

%     The line-of-sight range from antenna is hardcoded to 3m resolution
    range_pol=3*(1:size(DR,1));
    
%     Calculate the ground range from line-of-sight and antenna height
    sgr	=	radar_loc(5)./range_pol;%	sine of	grazing	angle
    cgr	=	sqrt(1-sgr.^2);			%	cos	of grazing angle
    Rg = real(range_pol.*cgr);

    if intopt==2

        theta_pol=squeeze(AZI(:,jj));
        %creating the meshgrid for the conversion
        [RR,TT]=meshgrid(Rg,theta_pol);
        RR=RR';TT=TT';
        %and convert into cartesian grid
        DR=double(DR);
        [YY,XX,ZZ]=pol2cart(-(TT+radar_loc(3))/180*pi,RR,DR);
        XX=-XX;

        DR=griddata(XX,YY,ZZ,X_D,Y_D,'nearest');
        DataInt(:,:,jj)=uint8(DR./header.waveforms);
    elseif intopt==1 || intopt==3 || intopt==4
        theta_pol=squeeze(AZI(:,jj));
        if jj==1 %only the first rotation, we define the new azimuthal domain (uniform)
            AziU=min(AZI(end,:)); %getting the minimum of the maximum azimuth
            AziU=(0:AziU/(header.collectionsMod-1):AziU)';
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
        DataInt(:,:,jj)=uint8(newdata./header.waveforms);
    elseif intopt==0
        DataInt(:,:,jj)=uint8(DR./header.waveforms);
    end

    % imagesc(squeeze(DataInt(:,:,jj)));pause(.1)
    %    catch
    %        Ifail(cont)=jj; %record which rotations were not read
    %        cont=cont+1; %
    %    end

end

fclose(fid);

%%

%now we add the option to interpolate to a fixed time domain, in snapshot
%mode
if intopt==3 || intopt==4
    
    [DataInt,snapTime]=RadarScanToSnap(DataInt,timeInt);
    Cube.snapTime=snapTime;
else
    if ~isempty(timeMat)
        Cube.time=timeMat;
        if exist('timeInt','var')
            Cube.timeInt=timeInt;
        end
    else
        Cube.time=[];
    end
end
if intopt==3 || intopt==1 %interpolation of azimuths
    Cube.Azi=AziU;
elseif intopt==0
    Cube.Azi=AZI;
end


%now we add the option to convert to cartesian the snap
if intopt==4
    dummy=DataInt;
    DataInt=zeros([[size(X_D)],size(dummy,3)],'uint8');%preallocating

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
        DataInt(:,:,jj)=uint8(DR);
    end
end
clear DR;

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
warning on all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [AZI,results,header]=readAfile(fname,header)
%%
%eval(['A=dlmread(sprintf('/nfs/lennon/scratch/haller-shipops/SouthJetty/%s/%s',datestr(date,29),(''A',fname(2:8),'.txt''));']) 
fname=['A',num2str(fname(2:8)),'.txt'];
A=dlmread(sprintf('/nfs/lennon/u1/haller/shared/RADAR_DATA/Columbia_SJ_data/%s',fname));
%reading the text file.
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

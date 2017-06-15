function Cube2FirstLastMaxMinTimexVar(Cube,varargin)

% Batch process Cube data to the standard products: First Snap, Last Snap,
% Maximum, Minimum, Timex, and Variance (really Standard Deviation, but
% var is easier to say)
%
% Usage:
% Cube2FirstLastMaxMinTimexVar(Cube,varargin)
%
% INPUT: (Required)
%
%   Cube            =   Radar data cube (as make by ReadBin.m)
%
%        (Optional, in varargin format. Insert {first, last, max, min, 
%           vimex, or var} in place of [*]):
%
%   plotLimits      =   Plotting axes [xmin xmax ymin ymax]. Default is 
%                       maximum range from antenna.  
%   [*]ColorMap     =   Name of colormap (e.g. 'gray'). Default is jet.
%   [*]ColorAxis    =   Color axis (e.g. [50 200]). Default is 'auto'.
%   imagePath       =   Path where to save images. Default is [.\images\].
%   matPath         =   Path where to save matfiles. Default is [.\matfiles\].
%                       
% 
% David Honegger
% 
% Note: As of 4/4/2013 NRI radar data are rotated 3 degrees CCW to conform best
% with LARC survey depths. This angle was found via cBathy output.

%% Define defaults

if ~isfield(Cube,'xdom');
    Cube = cartCube(Cube);
end
[x,y] = meshgrid(Cube.xdom,Cube.ydom);
plotLims = [Cube.results.XOrigin-max(Cube.Rg),Cube.results.XOrigin+max(Cube.Rg),...
    Cube.results.YOrigin-max(Cube.Rg) Cube.results.YOrigin+max(Cube.Rg)];
cmapNameFirst = 'jet';
cmapNameLast = 'jet';
cmapNameMax = 'jet';
cmapNameMin = 'jet';
cmapNameTimex = 'jet';
cmapNameVar = 'jet';
climFirst = 'auto';
climLast = 'auto';
climMax = 'auto';
climMin = 'auto';
climTimex = 'auto';
climVar = 'auto';
imageDir = [pwd,filesep,'images',filesep];
matDir = [pwd,filesep,'matfiles',filesep];
% imageDir = fullfile(lennonDir,'u1','haller','shared','RADAR_DATA','MURI','NewRiverInlet','WIMR','Products','cartInterp','images',filesep);
% matDir = fullfile(lennonDir,'u1','haller','shared','RADAR_DATA','MURI','NewRiverInlet','WIMR','Products','cartInterp','matfiles',filesep);

%%%%%%%%%%%%%%%% NRI Rotation %%%%%%%%%%%%%%%%
doRotate = 0;
NRI_locationStrings = {'paramsNRI_CORradIncoherent_A','paramsNRI_CORradIncoherent_B','paramsNRI_WestCoastIncoherent'};
if sum(strcmp(Cube.location,NRI_locationStrings)) ~= 0
    doRotate = 1;
end
if doRotate
    A = makeRotMat(3); % 3 degree rotation CCW
    [X,Y] = meshgrid(Cube.xdom,Cube.ydom);
    XYr = A*[X(:)';Y(:)'];
    x = reshape(XYr(1,:),size(X));
    y = reshape(XYr(2,:),size(Y));
end
%%%%%%%%%%%%%%%% NRI Rotation %%%%%%%%%%%%%%%%

%% Deal with user inputs

while ~isempty(varargin)
    switch varargin{1}
        case 'plotLimits'
            plotLims = varargin{2};
        case 'firstColorMap'
            cmapNameFirst = varargin{2};
        case 'lastColorMap'
            cmapNameLast = varargin{2};
        case 'maxColorMap'
            cmapNameMax = varargin{2};
        case 'minColorMap'
            cmapNameMin = varargin{2};
        case 'timexColorMap'
            cmapNameTimex = varargin{2};
        case 'varColorMap'
            cmapNameVar = varargin{2};
        case 'firstColorAxes'
            climFirst = varargin{2};
        case 'lastColorAxes'
            climLast = varargin{2};
        case 'maxColorAxes'
            climMax = varargin{2};
        case 'minColorAxes'
            climMin = varargin{2};
        case 'timexColorAxes'
            climTimex = varargin{2};
        case 'varColorAxes'
            climVar = varargin{2};
        case 'imagePath'
            imageDir = varargin{2};
        case 'matPath'
            matDir = varargin{2};
    end
    varargin([1 2])=[]; 
end

%% Directory Bookkeeping

if ~exist(matDir,'dir')
	mkdir(matDir)
end
if ~exist(imageDir,'dir')
    mkdir(imageDir)
end

%% Prep variables for saving/plotting

header.timeStamp = Cube.header.file(2:8);
header.dateNum = epoch2Matlab(Cube.results.startTime.epoch);
header.rotations = Cube.header.rotations;
header.rangeBins = Cube.header.samples;
header.aziBins = Cube.header.collections;
header.runLength = Cube.results.RunLength;
header.rpm = Cube.results.TrueRPM;
header.heading = Cube.results.heading;
header.origin = [Cube.results.XOrigin,Cube.results.YOrigin,Cube.results.ZOrigin];
%     x = Cube.xdom;    % This was done above
%     y = Cube.ydom;    % This was done above
firstImg = double(squeeze(Cube.data(:,:,1)));
lastImg = double(squeeze(Cube.data(:,:,end)));
maxImg = double(max(Cube.data,[],3));
minImg = double(min(Cube.data,[],3));
timexImg = double(sum(Cube.data,3))/Cube.header.rotations;
varImg = sqrt(varOnePass(Cube.data));
README = [...
'% Metadata:                                                             ';
'% header       = Metadata structure with fields:                        ';
'%    timeStamp = Timestamp when data was collected [dddhhmm,            ';
'%                [Julian Day, Eastern Daylight Time]                    ';
'%    dateNum   = Timestamp of first data point [Matlab datenum, UTC]    ';
'%    rotations = # antenna rotations collected                          ';
'%    rangeBins = # bins in the range direction (aka samples)            ';
'%    aziBins   = # bins in the azimuth direction (aka collections)      ';
'%    runLength = Total # seconds of data collected                      ';
'%    rpm       = Average rotations per minute (runLength/#rotations/60) ';
'%    heading   = Antenna heading wrt a local (or global) datum          ';
'%    origin    = Antenna position wrt a local (or global) datum         ';
'% x            = Cartesian X array in local/global coordinates [m]      ';
'% y            = Cartesian Y array in local/global coordinates [m]      ';
'%                                                                       ';
'% Radar products:                                                       ';
'% firstImg     = First rotation:                                        ';
'%                  Cube.data(:,:,1)                                     ';
'% lastImg      = Last rotation:                                         ';
'%                  Cube.data(:,:,end)                                   ';
'% maxImg       = Maximum intensity:                                     ';
'%                  max(Cube.data,[],3)                                  ';
'% minImg       = Minimum intensity:                                     ';
'%                  min(Cube.data,[],3)                                  ';
'% timexImg     = Time exposure:                                         ';
'%                  sum(Cube.data,3)/Cube.header.rotations               ';
'% varImg       = Variance (actually standard deviation):                ';
'%                  sqrt(variance(Cube.data,3))                          ';
    ];


if doRotate
    README = [README;
'%                                                                       ';
'% Note: This data was rotated 3 degrees CCW to match LARC depth surveys.';
    ];
end

%% Save all data in matfile
fprintf('Saving Image Matfile for TimeStamp %s\n',header.timeStamp)
% save(sprintf('%s\\Img%s_%dUTC',matDir,header.timeStamp,matlab2Epoch(Cube.time(1,1))),...
%     'README',...
%     'header',...
%     'x',...
%     'y',...
%     'firstImg',...
%     'lastImg',...
%     'maxImg',...
%     'minImg',...
%     'timexImg',...
%     'varImg')

%% Plot images
    
fprintf('Plotting and saving figures for TimeStamp %s\n',header.timeStamp)
        
%%% Timex %%%
figure(1)
clf
set(1,...
    'renderer','zbuffer',...
    'visible','off',...
    'position',[0 0 800 600],...
    'paperpositionmode','auto')

    pcolor(x,y,timexImg)
        axis equal
        shading interp
        caxis(climTimex)
        eval(sprintf('colormap(%s)',cmapNameTimex))
        hc = colorbar;
        axis(plotLims)
            title({'\bfTimex',header.timeStamp})
            xlabel('\bfX_{NRI} [m]')
            ylabel('\bfY_{NRI} [m]')
            ylabel(hc,'\bfReturn Intensity')
print('-dpng',sprintf('%s\\Timex%s_%dUTC',imageDir,header.timeStamp,matlab2Epoch(Cube.time(1,1))))
    
%%% First %%%
figure(1)
% clf
set(1,...
    'renderer','zbuffer',...
    'visible','off',...
    'position',[0 0 800 600],...
    'paperpositionmode','auto')
    
    pcolor(x,y,firstImg)
        axis equal
        shading interp
        caxis(climFirst)
        eval(sprintf('colormap(%s)',cmapNameFirst))
        hc = colorbar;
        axis(plotLims)
            title({'\bfFirst Rotation',header.timeStamp})
            xlabel('\bfX_{NRI} [m]')
            ylabel('\bfY_{NRI} [m]')
            ylabel(hc,'\bfReturn Intensity')
print('-dpng',sprintf('%s\\First%s_%dUTC',imageDir,header.timeStamp,matlab2Epoch(Cube.time(1,1))))
    
%%% Last %%%
figure(1)
% clf
set(1,...
    'renderer','zbuffer',...
    'visible','off',...
    'position',[0 0 800 600],...
    'paperpositionmode','auto')
    
    pcolor(x,y,lastImg)
        axis equal
        shading interp
        caxis(climLast)
        eval(sprintf('colormap(%s)',cmapNameLast))
        hc = colorbar;
        axis(plotLims)
            title({'\bfLast Rotation',header.timeStamp})
            xlabel('\bfX_{NRI} [m]')
            ylabel('\bfY_{NRI} [m]')
            ylabel(hc,'\bfReturn Intensity')
print('-dpng',sprintf('%s\\Last%s_%dUTC',imageDir,header.timeStamp,matlab2Epoch(Cube.time(1,1))))
            
%%% Max %%%
figure(1)
% clf
set(1,...
    'renderer','zbuffer',...
    'visible','off',...
    'position',[0 0 800 600],...
    'paperpositionmode','auto')
    
    pcolor(x,y,maxImg)
        axis equal
        shading interp
        caxis(climMax)
        eval(sprintf('colormap(%s)',cmapNameMax))
        hc = colorbar;
        axis(plotLims)
            title({'\bfMaximum Intensity',header.timeStamp})
            xlabel('\bfX_{NRI} [m]')
            ylabel('\bfY_{NRI} [m]')
            ylabel(hc,'\bfReturn Intensity')
print('-dpng',sprintf('%s\\Max%s_%dUTC',imageDir,header.timeStamp,matlab2Epoch(Cube.time(1,1))))

%%% Min %%%
figure(1)
% clf
set(1,...
    'renderer','zbuffer',...
    'visible','off',...
    'position',[0 0 800 600],...
    'paperpositionmode','auto')
    
    pcolor(x,y,minImg)
        axis equal
        shading interp
        caxis(climMin)
        eval(sprintf('colormap(%s)',cmapNameMin))
        hc = colorbar;
        axis(plotLims)
            title({'\bfMinimum Intensity',header.timeStamp})
            xlabel('\bfX_{NRI} [m]')
            ylabel('\bfY_{NRI} [m]')
            ylabel(hc,'\bfReturn Intensity')
print('-dpng',sprintf('%s\\Min%s_%dUTC',imageDir,header.timeStamp,matlab2Epoch(Cube.time(1,1))))

%%% Variance (Std) %%%
figure(1)
% clf
set(1,...
    'renderer','zbuffer',...
    'visible','off',...
    'position',[0 0 800 600],...
    'paperpositionmode','auto')
    
    pcolor(x,y,varImg)
        axis equal
        shading interp
        caxis(climVar)
        eval(sprintf('colormap(%s)',cmapNameVar))
        hc = colorbar;
        axis(plotLims)
            title({'\bfVariance',header.timeStamp})
            xlabel('\bfX_{NRI} [m]')
            ylabel('\bfY_{NRI} [m]')
            ylabel(hc,'\bfReturn Intensity')
print('-dpng',sprintf('%s\\Var%s_%dUTC',imageDir,header.timeStamp,matlab2Epoch(Cube.time(1,1))))

    
close(1)

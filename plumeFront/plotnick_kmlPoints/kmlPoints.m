% KMLPOINTS place lat-lon points as distinct placemarks in kml file
%
% kmlPoints(outputFile,lon,lat) will write the lat-lon pairs to the file
% 'outputFile.kml'. The placemarks will be white by default, use the
% road_shield3 icon, have an altitude of zero (relative to ground), an
% alpha of 1, and no name or description. The default folder name is
% 'Vehicle Path w/ timestamps'. Will overwrite an existing file of the same
% name. NOTE: lat/lon must be vectors of the same length.
%
% -------------------------------------------------------------------------
% Syntax
% -------------------------------------------------------------------------
% Takes a number of name-value pair arguments in the form 
% kmlPoints(outputFile,lon,lat,varargin)
% 
% ====== Name Value Pairs =======
%
% The simplest are:
% 'folderName' - ['Vehicle Path w/ Timestamps'] -  char, name of the
% folder within the kml file. 
%
% 'folderDescription' - [] - char, description for the folder. 
%
% ////////// More Complicated Inputs ///////////////
%
% Most of the rest of these can be entered in a number of formats. They can
% typically be: 
% 
% - empty, in which case either the default value is used, or the item
% isn't written at all
%
% - single value, in which case that value will be used for all of the
% placemarks.
%
% - a cell array, in which case each placemark will take its parameter
% value from the corresponding cell. Note: empty cells will use the default
% value, or not write the parameter at all. Also, if using a cell array,
% its length must = 1 OR the length of lat/lon vectors. When using cell
% arrays, make sure they contain one character string each (excepting
% iconDescription).
%
% - a numerical vector, which will be converted into the appropriate
% char-string format and then into a cell array. Details below. 
%
% ====== More  Name Value Pairs ==========
%
% 'alt' - 0 - char/num/cell, altitude relative to ground. Defaults to zero.
% If it is a char, make sure that is the output of a num2str operation so
% that it corresponds to a numeric value. (meters, I think)
%
% 'time' - [] - char/num/cell, time of each placemark. If left empty, will
% not write a <when> line for that placemark. If it is a numerical vector,
% it assumes the vector is in datenum format, and will convert that to the
% appropriate UTC string for Google Earth and place that in a cell array.
% If it is a cell-array, it assumes you have already done this step: each
% cell must contain a UTC formatted datestring. If a char is given, it
% assumes that char is a UTC datestring, and uses the same time for all
% placemarks. 
%
% 'iconStyle' - 'road_shield3' - char, icon to use for the placemark in
% google earth. Defaults to road_shield3, the same as VIP. This can be
% changed to any of the icons in the "http://maps.google.com/mapfiles/kml/shapes/" 
% package. To find the name of an icon, try right clicking on a placemark
% in GE, pressing properties, clicking the icon symbol to the right of
% 'name', and selecting an icon. The shape name is the part before *.png at
% the address at the top. 
%
% 'iconScale' - 0.5 - numeric, size of each icon. If given a vector of
% scales, will convert these to the appropriate cell array of char-strings.
% Allows you to encode information into icon size.
%
% 'iconColor' - [1,1,1] - numeric. Either a 1x3 or Nx3 array (N being the
% length of the lat/lon vectors). Defaults to white. Must be in [r,g,b]
% notation. Will be combined with iconAlpha and converted into the correct
% hexadecimal format used by GE. Numeric arrays only please. 
%
% 'iconAlpha' - 1 - numeric, the alpha (opacity) of the icon. Defaults to 1
% for all icons, but a numeric vector of length N could also be used if
% you want to encode information into opacity. Using a single value will 
% use theat value for all placemarks. Must be on range [0,1]. 
%
% 'iconName' - [] - char/cell, name of each placemark. Warning, this will
% show up on the GE overlay, so lots of these can make the screen very
% cluttered. Theres is probably a way to turn that off, I don't know it
% offhand. 
%
% 'iconDescription' - [] - char/cell/struct. This one is a little
% different. If a char is provided, will use that description for all
% placemarks. If a struct is provided, will loop through the struct and
% write a description formatted in the same style as the VIP output, with
% the fieldame - fieldvalue being paired together. This is a nice way of
% writing in a lot of other information to that placemark. If a cell array
% is given, for each cell: empties will not have a description, chars will
% just go in as the char-string, and structures will be parsed as above.
% There is a lot of flexibility here. 
%
% -Dan Plotnic, APL-UW, 5-1-17

function kmlPoints(outputFile,lon,lat,varargin)
% =========================================================================
% Input Parser
% -------------------------------------------------------------------------
p = inputParser();

addParameter(p,'alt',0,@(x) ischar(x) || isnumeric(x) || iscell(x));
addParameter(p,'time',[],@(x) ischar(x) || isnumeric(x) || iscell(x));

addParameter(p,'folderName','Vehicle Path w/ Timestamps',@ischar);
addParameter(p,'folderDescription', ' ',@ischar);

addParameter(p,'iconStyle','road_shield3', @(x) ischar(x) || iscell(x));
addParameter(p,'iconScale',0.5,@isnumeric);
addParameter(p,'iconColor',[1,1,1]);
addParameter(p,'iconAlpha',1,...
    @(x) isnumeric(x) && max(x)<=1 && min(x)>=0);

addParameter(p,'iconName',[],@(x) ischar(x) || iscell(x));
addParameter(p,'iconDescription',[],@(x) ischar(x) || iscell(x) || isstruct(x));

parse(p,varargin{:});


alt = p.Results.alt;
time = p.Results.time;
folderName = p.Results.folderName;
folderDescription= p.Results.folderDescription;
iconStyle = p.Results.iconStyle;
iconScale = p.Results.iconScale;
iconColor = p.Results.iconColor;
iconAlpha = p.Results.iconAlpha;
iconName = p.Results.iconName;
iconDescription = p.Results.iconDescription;

% =========================================================================
% Check sizes
% -------------------------------------------------------------------------

% Check lat/lon
assert(numel(lat) == max(size(lat)),'Lat/lon should be vectors');
assert(length(lat) == length(lon),'Lat and Lon lengths do not match');
npoints = length(lat);
lat = conLatLon(lat);
lon = conLatLon(lon);
% =========================================================================
% Error/size/format check other types
% -------------------------------------------------------------------------
% This block will convert all of the various inputs into cell arrays of
% length npoints, where each cell contains a character string corresponding
% to the value to be written to that particular parameter: e.g. time.

% \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Time vector
time = formatTime(time,npoints);

% \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Altitude
alt = formatAlt(alt,npoints);

% \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Icon style
iconStyle = formatStyle(iconStyle,npoints);

% \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Icon scale
iconScale = formatScale(iconScale,npoints);

% \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Icon color
iconColor = formatColor(iconColor,iconAlpha,npoints);

% \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Icon Name
iconName = formatName(iconName, npoints);

% \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Icon Description
iconDescription= formatDescription(iconDescription, npoints);

% =========================================================================
% Open/Create file
% -------------------------------------------------------------------------

kmlfile = fopen([outputFile,'.kml'],'w');

% =========================================================================
% Create Header
% -------------------------------------------------------------------------

fprintf(kmlfile, '<?xml version="1.0" encoding="UTF-8"?>\n');
% fprintf(kmlfile, '<Dan Plonticks KML point toolbox>\n');
% fprintf(kmlfile, '<APL-UW, 4-28-17>\n');
fprintf(kmlfile, ['\n']);
fprintf(kmlfile, '<Document>\n');

% =========================================================================
% Start folder structure
% -------------------------------------------------------------------------
fprintf(kmlfile, ['<Folder>\n']);
fprintf(kmlfile, ['<name>', folderName, '</name>\n']);
fprintf(kmlfile, ['<description>',folderDescription,'</description>\n']);
fprintf(kmlfile, ['\n']);

% =========================================================================
% Loop through points
% -------------------------------------------------------------------------
for ii = 1:npoints
    addPlacemark(kmlfile,lon{ii},lat{ii},alt{ii},time{ii},...
        iconStyle{ii},iconScale{ii},iconColor{ii},...
        iconName{ii},iconDescription{ii});
end

% =========================================================================
% Close folder structure
% -------------------------------------------------------------------------
fprintf(kmlfile, ['</Folder>\n']);
fprintf(kmlfile, '</Document>\n');
fclose(kmlfile);

end


function addPlacemark(kmlfile,lon,lat,alt,time,iconStyle,...
    iconScale,iconColor,iconName,iconDescription)

fprintf(kmlfile, '<Placemark>\n');

if ~isempty(iconName)
    fprintf(kmlfile,['<name>',iconName,'</name>\n']);
end

if ~isempty(iconDescription)
    fprintf(kmlfile,'<description>\n');
    if ~isstruct(iconDescription)
        fprintf(kmlfile,iconDescription);
    else
        writeDescription(kmlfile,iconDescription);
    end
    fprintf(kmlfile,'</description>\n');
end

fprintf(kmlfile, '<altitudeMode>relativeToGround</altitudeMode>\n');

if ~isempty(time)
    fprintf(kmlfile, ['<TimeStamp><when>',time,'</when></TimeStamp>\n']);
end

fprintf(kmlfile,'<Style>\n');
fprintf(kmlfile,'<IconStyle>\n');
fprintf(kmlfile,[' <color>',iconColor,'</color>\n']);
fprintf(kmlfile,[' <scale>',iconScale,'</scale>\n']);
fprintf(kmlfile,[' <Icon>',iconStyle,'</Icon>\n']);
fprintf(kmlfile,'</IconStyle>\n') ;
fprintf(kmlfile,'</Style>\n') ;

fprintf(kmlfile, ['<Point>\n']);

fprintf(kmlfile, ['<coordinates>',lon,',',lat,',',alt,'</coordinates>\n']);
fprintf(kmlfile, ['</Point>\n']);
fprintf(kmlfile, ['</Placemark>\n']);
fprintf(kmlfile,'\n');

end

% =========================================================================
% Convert lat/lon
% -------------------------------------------------------------------------
function out = conLatLon(in)
out = cell(length(in),1);
for ii = 1:numel(in)
    out{ii} = num2str(in(ii));
end
end



% =========================================================================
% Convert datenum to appropriate char-string in zulu time
% -------------------------------------------------------------------------
function time = formatTime(time,npoints)
% \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Time vector
assert(isempty(time)||...
    ischar(time) ||...
    (...
    (isnumeric(time) || iscell(time)) && ...
    (numel(time) == 1 || numel(time) == npoints) ...
    ),...
    'Time must be a numeric vector or cell vector of length 1 or the',...
    ' same size as lat, OR empty, OR a single character string');

% Convert time vector to either cell array or numeric array of correct
% length.
if ischar(time)
    time = {time};
elseif isempty(time)
    time = {[]};
elseif isnumeric(time) && ~isempty(time)
    time = conTime(time);
end

if numel(time) == 1
    time = repmat(time,npoints,1);
end
end


function out = conTime(in)
out = cell(length(in),1);
for ii = 1:numel(in)
    if ~isnan(in(ii))
        timel = datestr(in(ii),31);
        timel = strrep(timel,' ','T');
        out{ii} = [timel,'Z'];
    else
        out{ii} = NaN;
    end
end
end

% =========================================================================
% Convert alt to char-string
% -------------------------------------------------------------------------
function alt = formatAlt(alt,npoints)

if ischar(alt)
    alt = {alt};
end

assert(numel(alt) == 1 || numel(alt) == npoints,...
    'Alt needs to be of size 1 or equal to the length of lat/lon');

if ~iscell(alt)
    alt = conAlt(alt);
end

if numel(alt) == 1
    alt = repmat(alt,npoints,1);
end
end

function out = conAlt(in)
out = cell(numel(in),1);
for ii = 1:numel(in)
    if ~isnan(in(ii))
        out{ii} = num2str(in(ii));
    else
        out{ii} = 0; % default to zero if alt is a nan
    end
end
end



% =========================================================================
% Convert style
% -------------------------------------------------------------------------
function iconStyle = formatStyle(iconStyle,npoints)
if ischar(iconStyle)
    iconStyle = {iconStyle};
end

assert(numel(iconStyle) == 1 || numel(iconStyle) == npoints,...
    'iconStyle needs to be of size 1 or equal to the length of lat/lon');

iconStyle = conStyle(iconStyle);
if numel(iconStyle) == 1
    iconStyle = repmat(iconStyle,npoints,1);
end
end

function out = conStyle(in)
out = cell(numel(in),1);
for ii = 1:numel(in)
    iconStyle = in{ii};
    if ~isempty(iconStyle)
        out{ii} = ['<href>http://maps.google.com/mapfiles/kml/shapes/',iconStyle,'.png</href>'];
    else
        out{ii} = '<href>http://maps.google.com/mapfiles/kml/shapes/road_shield3.png</href>'; % default
    end
end
end

% =========================================================================
% Convert scale to cell of char-strings
% -------------------------------------------------------------------------
function iconScale = formatScale(iconScale,npoints)
assert(numel(iconScale) == 1 || numel(iconScale) == npoints,...
    'iconScale needs to be of size 1 or equal to the length of lat/lon');
if ~iscell(iconScale)
    iconScale = conScale(iconScale);
end
if numel(iconScale) == 1
    iconScale = repmat(iconScale,npoints,1);
end
end

function out = conScale(in)
out = cell(numel(in),1);
for ii = 1:numel(in)
    if ~isnan(in(ii))
        out{ii} = num2str(in(ii));
    else
        out{ii} = 0.5; % default to .5 if alt is a nan
    end
end
end

% =========================================================================
% Convert color cell char-string
% -------------------------------------------------------------------------
function iconColor = formatColor(iconColor,iconAlpha,npoints)
assert(size(iconColor,1) == npoints || size(iconColor,1) == 1,...
    'iconColor needs to be of size Nx3, where N = 1 or length of lat/lon');
assert(numel(iconAlpha) == 1 || numel(iconAlpha) == npoints,...
    'iconAlpha needs to be of size 1 or equal to the length of lat/lon');
if size(iconColor,1) == 1
    iconColor = repmat(iconColor,npoints,1);
end
if numel(iconAlpha) == 1
    iconAlpha = repmat(iconAlpha,npoints,1);
end
[iconColor] = rgb2hex(iconColor,iconAlpha);
iconColor = conColor(iconColor);
end

function out = conColor(in)
out = cell(size(in,1),1);
for ii = 1:size(in,1)
    out{ii} = in(ii,:);
end
end
% =========================================================================
% Convert icon name to cell array
% -------------------------------------------------------------------------

function iconName = formatName(iconName, npoints)
if ischar(iconName) || isempty(iconName)
    iconName = {iconName};
end
assert(numel(iconName) == 1 || numel(iconName) == npoints,...
    ['iconName needs to be a char string, OR cell of size 1 or equal to',...
    ' the length of lat/lon']);

if numel(iconName) == 1;
    iconName = repmat(iconName,npoints,1);
end
end

% =========================================================================
% Convert icon name to cell array
% -------------------------------------------------------------------------

function iconDescription= formatDescription(iconDescription, npoints)
if ischar(iconDescription) || isempty(iconDescription) || isstruct(iconDescription)
    iconDescription = {iconDescription};
end
assert(numel(iconDescription) == 1 || numel(iconDescription) == npoints,...
    ['iconDescription needs to be a char string, OR cell of size 1 or equal to',...
    ' the length of lat/lon']);

if numel(iconDescription) == 1;
    iconDescription = repmat(iconDescription,npoints,1);
end
end

% =========================================================================
% Write Description from Structure.
% -------------------------------------------------------------------------
function writeDescription(kmlfile,iconDescription)
fnames = fieldnames(iconDescription);
fprintf(kmlfile,'<![CDATA[<b>Vehicle Data</b>\n');
fprintf(kmlfile,' <table border="0" >\n');

for ii = 1:length(fnames)
    fname = fnames{ii};
    value = iconDescription.(fname);
    if isnumeric(value) && numel(value) == 1
        value = num2str(value);
    end
    if ischar(value)
        fprintf(kmlfile,...
            [' <tr> <td>',fname,'</td>  <td>',value,'</td> </tr>\n']);
    end
end
fprintf(kmlfile,'</table>]]>\n');
end


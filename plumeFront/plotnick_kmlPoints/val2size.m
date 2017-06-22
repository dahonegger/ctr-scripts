% VAL2SIZE map value to size suitable for google earth icons
%
% sze = val2size(val) will interpolate value onto a size range [0.3 2.5].
% sze will have the same size as val. 
%
% sze = val2size(val,[smin smax]) will interpolate val onto size range 
% [smin smax].
%
% sze = val2size(val,[smin smax], [vmin vmax]) will use value-min/max's;
% all points below vmin will be set to smin, above vmax set to vmax. 
%
% sze = val2size(val,[], [vmin vmax]) will use the default size range 
% [0.3 2.5]
%
% -------------------------------------------------------------------------
% Details
% -------------------------------------------------------------------------
% sze = val2size(val,varargin) performs a linear interpolation from value
% to size, allowing value to encode the size of an icon in e.g. a google
% earth kml file. It will also round sze to the nearest 0.1. 
%
% It will work with an N-D array, if for some reason you want to use one. 
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
% %%
% close all
% val = rand(100,1);
% 
% % Defaults 
% sze1 = val2size(val);
% figure; plot(sze1,'.');
% 
% % Change icon size range. 
% sze2 = val2size(val,[1 5]); 
% figure; plot(sze2,'.');
% 
% % Change value limits. Use default icon size range
% sze3 = val2size(val,[],[0.25 0.75]); 
% figure; plot(sze3,'.');
% 
% % Change value limits and icon size range
% sze4 = val2size(val,[0.5 4],[0.25 0.75]); 
% figure; plot(sze4,'.');


function sze = val2size(val,varargin)
% =========================================================================
% Parse inputs
% -------------------------------------------------------------------------
p = inputParser;
addOptional(p,'srange',[0.3 2.5]); % Size range of icons 
addOptional(p,'vrange',[nanmin(val(:)), nanmax(val(:))]); % Value range to cover
parse(p,varargin{:});

srange = p.Results.srange;
vrange = p.Results.vrange;

% Use default if srange is skipped. 
if isempty(srange)
    srange = [0.3 2.5];
end
% =========================================================================
% Error Checking
% -------------------------------------------------------------------------
assert(isnumeric(val) && isreal(val),...
    'Input value must be a real numeric array');

assert(isnumeric(vrange) && isreal(vrange) && numel(vrange) == 2 && ...
    vrange(2) > vrange(1),...
    'Input vrange must be real numeric of the form [min, max]');

assert(isnumeric(srange) && isreal(srange) && numel(srange) == 2 && ...
    srange(2) > srange(1),...
    'Input vrange must be real numeric of the form [min, max]');

% =========================================================================
% Set up spaces
% -------------------------------------------------------------------------
% sze = zeroes(size(val));
y = linspace(srange(1),srange(2),numel(val));
x = linspace(vrange(1),vrange(2),numel(val)); 

% =========================================================================
% Interpolate
% -------------------------------------------------------------------------
sze = interp1(x,y,val); 

% =========================================================================
% Take care of end values
% -------------------------------------------------------------------------
sze(val<vrange(1)) = srange(1);
sze(val>vrange(2)) = srange(2); 

% =========================================================================
% Round to nearest 0.1
% -------------------------------------------------------------------------
sze = round(sze,1); 
end
% VAL2RGB convert value to rgb triplet using a colormap
%
% rgb = val2rgb(val) will return val as an rgb matrix using a jet colormap.
% 
% rgb = val2rgb(val,'range',[min max]) will use min max as the range of the
% colormap, similar to caxis.
%
% rgb = val2rgb(val,'cmap','cmapName') will use a Matlab default colormap
% of the name 'cmapName', rather than Jet. 
%
% rgb = val2rgb(val,'cmap','custom','customMap',[r,g,b]) will use the
% custom colormap defined by the Nx3 array [r,g,b].
%
% -------------------------------------------------------------------------
% Details
% -------------------------------------------------------------------------
%
% rgb = val2rgb(val,varargin) will take the values 'val' and return the rgb
% matrix 'rgb'. The input 'val' may be a 1-D or 2-D real numeric array. By
% default, the color range will be [nanmin(val), nanmax(val)]. The code
% will default to Jet as the colormap. 
%
% Takes the following name-value argument (varargin) pairs:
%
% 'cmap' - ['jet'] - @ischar, character string corresponding to the
% function call for the colormap. Examples: 'jet', 'parula', 'hsv', 'bone',
% etc. ALTERNATIVELY, 'custom' will declare that you want to use a custom
% colormap, and you will need to provide the rgb colormap to the code. See
% below. 
%
% 'range' - [nanmin(val),nanmax(val)] - 2 element numeric, the range across
% which colormap is placed. Equivalent to 'caxis'. Values outside of this
% range will be set to the corresponding upper/lower rgb values of the
% colormap. 
%
% 'customMap' - [] - @isnumeric & is N-by-3 array. If cmap is 'custom', 
% this allows you to input an N-by-3 array as a custom color map. This is
% required if cmap is 'custom'. 
%
% -Dan Plotnick, APL-UW, 5-1-2017
% 
% -------------------------------------------------------------------------
% EXAMPLES:
% %% 
% img = imread('peppers.png');
% img = rgb2gray(img);
% 
% rgb1 = val2rgb(img); 
% figure; imshow(rgb1);
%
% rgb2 = val2rgb(img,'cmap','parula','range',[50 200]);
% figure; imshow(rgb2); 
%
% x = linspace(0,pi,256).';
% ccmap = [cos(x).^2, cos(x+pi/3).^2, cos(x+2*pi/3).^2];
% rgb3 = val2rgb(img, 'cmap','custom','customMap',ccmap);
% figure; imshow(rgb3); 
% -------------------------------------------------------------------------

function rgb = val2rgb(val,varargin)

% =========================================================================
% Parse inputs
% -------------------------------------------------------------------------
p = inputParser;
addParameter(p,'cmap','jet',@ischar);
addParameter(p,'range',[nanmin(val(:)),nanmax(val(:))],@isnumeric);
addParameter(p,'customMap',[],@isnumeric);
parse(p,varargin{:});

range = p.Results.range;

% =========================================================================
% Error Checking
% -------------------------------------------------------------------------
assert(isnumeric(val),'Input value must be a numeric array'); 
assert(isreal(val),'Input value must be real');
assert(ndims(val)>0 && ndims(val)<=2,...
    'Input value must be a 1- or 2-D array');

assert(range(1)<range(2) & numel(range) == 2,...
    'Range must be in format [min, max]');

% =========================================================================
% Class checking
% -------------------------------------------------------------------------
% Need this for the interpolation to work
if ~isa(val,'double')
    val = double(val);
    range = double(range);
end


% =========================================================================
% Use colormap name as function handle, or use custom color map
% -------------------------------------------------------------------------
cmap = p.Results.cmap;
switch cmap
    case 'custom'
        assert(~isempty(p.Results.customMap),...
            'Must provide custom color map in [r,g,b] format');
        assert(size(p.Results.customMap,2) == 3,...
            'Custom color map does not have 3 columns, ',...
            'must be in [r,g,b] format');
        assert(size(p.Results.customMap,1)>1,...
            'You have only provided one color in your colormap');
        cmap = p.Results.customMap;
    otherwise
        cmap = str2func(cmap);
        cmap = cmap(256);
end

% =========================================================================
% Set up spaces
% -------------------------------------------------------------------------
x = linspace(range(1),range(2),size(cmap,1)); % Colors cover linear space 
                                              % within the given range
                                              
rgb = zeros(size(val,1),size(val,2),3);       % Return NxMx3 rgb array

% =========================================================================
% Interpolate colormap onto values
% -------------------------------------------------------------------------
rgb(:,:,1) = interp1(x,cmap(:,1),val); % r
rgb(:,:,2) = interp1(x,cmap(:,2),val); % g
rgb(:,:,3) = interp1(x,cmap(:,3),val); % b

% =========================================================================
% Take care of values outside of range
% -------------------------------------------------------------------------
I_low = val<range(1); 
I_high = val>range(2);
[M,N,~] = size(rgb);

rgb = reshape(rgb,[],1,3);
I_low = reshape(I_low,[],1);
I_high = reshape(I_high,[],1);

rgb(I_low,1,1) = cmap(1,1);
rgb(I_low,1,2) = cmap(1,2);
rgb(I_low,1,3) = cmap(1,3);

rgb(I_high,1,1) = cmap(end,1);
rgb(I_high,1,2) = cmap(end,2);
rgb(I_high,1,3) = cmap(end,3);

rgb = squeeze(reshape(rgb,M,N,3));
end



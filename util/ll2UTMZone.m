function UTMZone = ll2UTMZone(lat,lon)

if any(lat(:) < -80) || any(lat(:) > 84)
    error('ll2UTMZone:invalid_lat','The zone for one or more of the latitudes cannot be determined.');
end

if any(lon(:) < -180) || any(lon(:) > 180)
    warning('ll2UTMZone:lon_too_big','One or more (absolute) longitude values are too big. Modulo by 360 will be applied.');
    lon = mod(lon + 180,360) - 180;
end

lat_bands = ['C':'H', 'J':'N', 'P':'X'];  % 'I' and 'O' are removed so as not to be confused with 1 and 0.
lon_bands = arrayfun(@(x)sprintf('%.f',x), 1:60, 'UniformOutput', false);

lat_band = num2cell(lat_bands(floor((lat + 80)/8) + 1));
lon_band = lon_bands(floor((lon + 180)/6) + 1);

UTMZone = cellfun(@(latb,lonb) sprintf('%s%s',lonb,latb),lat_band,lon_band,'UniformOutput',false);

% Return string instead of cell array if we're only checking for one
% lat/lon pair.
if numel(UTMZone) == 1
    UTMZone = UTMZone{1};
end
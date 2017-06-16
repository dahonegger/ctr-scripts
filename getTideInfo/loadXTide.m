function [zetaOut,timeOut,meta] = loadXTide(fname,timeIn)

if nargin==1
    timeOut = 'native';
else
    timeOut = timeIn;
end

if ~exist(fname,'file')
    error('File does not exist')
    return
end


% Load file
fid = fopen(fname);
% Remove header
isHead = true;
while isHead
    txtLine = fgetl(fid);
    try
        lineDate = datenum(txtLine(1:10));
        if lineDate>datenum('1900-01-01') && lineDate<datenum('3000-01-01')
            isHead = false;
        end
    end
end

A = textscan(txtLine,'%04.f-%2d-%2d  %2d:%2d %3c %f');
dnIn(1) = datenum(double([A{1} A{2} A{3} A{4} A{5} 0]));
timeZone = A{6};
zetaIn(1) = A{7};

B = textscan(fid,'%04.f-%2d-%2d  %2d:%2d %3c %f');

dnIn = [dnIn;...
    datenum(double([B{1} B{2} B{3} B{4} B{5} 0*B{1}]))];
zetaIn = [zetaIn;B{7}];

if strcmp(timeOut,'native')
    timeOut = dnIn;
    zetaOut = zetaIn;
else
    if timeIn(1)<dnIn(1)
        disp('Warning: Beginning of requested record lies outside data record. Expect NaNs.')
    end
    if timeIn(end)>dnIn(end)
        disp('Warning: End of requested record lies outside data record. Expect NaNs.')
    end
    zetaOut = interp1(dnIn,zetaIn,timeOut,'linear');
end

meta.timeZone = timeZone;
fclose(fid);
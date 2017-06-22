function [datenum_out, TZ_in_off, TZ_out_off, out_is_DST] = timezone_convert(datenum_in,TZ_ID_in,TZ_ID_out)
% FUNCTION timezone_convert
% Purpose:
%   This function converts a MATLAB datenum from one timezone to another.
%   Uses Java, and should be platform-independent. Timezone IDs are from
%   the IANA Time Zone Database. More info in NOTES section.
%
% Usage:
%   datenum_out = timezone_convert(datenum_in,TZ_ID_in,TZ_ID_out)
%
% Inputs:
%   - datenum_in:   MATLAB datenum to be converted to a new timezone.
%                   Any-dimensional.
%   - TZ_ID_in:     (Optional) Timezone string specifying the timezone of
%                   datenum_in. If not specified, the PC's current timezone 
%                   will be used.
%                   Acceptable timezone strings are listed by the command
%                   java.util.TimeZone.getAvailableIDs().
%   - TZ_ID_out:    (Optional) Timezone string specifying the timezone of
%                   datenum_out. If not specified, the PC's current 
%                   timezone will be used.
%                   Acceptable timezone strings are listed by the command
%                   java.util.TimeZone.getAvailableIDs().
%
% Outputs:
%   - datenum_out:  MATLAB datenum, changed from the timezone specified by
%                   TZ_ID_in, to that specified by TZ_ID_out.
%   - TZ_in_off:    Offset, in hours, of the input datenum in the input
%                   timezone (TZ_ID_in) from UTC. For example, the offset
%                   for Pacific Daylight Time is -7.
%   - TZ_in_off:    Offset, in hours, of the input datenum in the output
%                   timezone (TZ_ID_out) from UTC.
%
% Examples:
%   To convert a UTC datenum to the local timezone, use the function as
%   follows:
%       local_datenum = timezone_convert(UTC_datenum,'UTC',[]);
%   -or-
%       local_datenum = timezone_convert(UTC_datenum,'UTC');
%
%   To convert a datenum in the local timezone to UTC, use the function as
%   follows:
%       UTC_datenum = timezone_convert(local_datenum,[],'UTC');
%
%   To convert a datenum from Eastern Time to Pacific Time, use the 
%   function as follows:
%       Pac_datenum = timezone_convert(East_datenum,'US/Eastern','US/Pacific');
%
% NOTES:
%   1. The time will be automatically converted to daylight or standard
%      time, as is appropriate for the given date.
%   2. To determine the timeone identifier to use, Wikipedia may have the
%      correct offsets for some of the time zones here:
%      http://en.wikipedia.org/wiki/List_of_tz_database_time_zones
%      To be certain, however, the Java version number must be
%      known, from which can be determined the Time Zone Database version.
%       a. To get the Java version used by MATLAB, use the command
%          "version -java".
%       b. This page contains a matrix of java versions to versions of the
%          Time Zone Database:
%          http://www.oracle.com/technetwork/java/javase/tzdata-versions-138805.html
%       c. The IANA Time Zone Database may be found here:
%          http://www.iana.org/time-zones/
%
% Author:
%   Randall Pittman
% 
% Credits:
% Used this local_time_to_utc.m as a reference: http://www.mathworks.com/matlabcentral/fileexchange/22295
% 

%% Java Imports
import java.util.GregorianCalendar
import java.util.TimeZone

%% Input checking
% Check number of arguments
narginchk(1,3);

% Get all the available TimeZone IDs and put them in a cell array of
% strings
avail_IDs = TimeZone.getAvailableIDs;
avail_IDs_str = cell(size(avail_IDs));
for i = 1:numel(avail_IDs);
    avail_IDs_str{i} = char(avail_IDs(i).toString);
end

if exist('TZ_ID_in','var') && ~isempty(TZ_ID_in)
    if ~ischar(TZ_ID_in) || ~any(ismember(TZ_ID_in,avail_IDs_str))
        % If the timezone is not a string or is not one of the available
        % timezone IDs, throw an error.
        error('timezone_convert:invalid_TZ_ID_in', ...
            ['The provided TZ_ID_in value is invalid. ' ...
            'Run java.util.TimeZone.getAvailableIDs() ' ...
            'for a list of valid strings.']);
    end
end

if exist('TZ_ID_out','var') && ~isempty(TZ_ID_out)
    if ~ischar(TZ_ID_out) || ~any(ismember(TZ_ID_out,avail_IDs_str))
        % If the timezone is not a string or is not one of the available
        % timezone IDs, throw an error.
        error('timezone_convert:invalid_TZ_ID_out', ...
            ['The provided TZ_ID_out value is invalid. ' ...
            'Run java.util.TimeZone.getAvailableIDs() ' ...
            'for a list of valid strings.']);
    end
end

%% Create TimeZone and Calendar objects

%%% Create Timezones
if ~exist('TZ_ID_in','var') || isempty(TZ_ID_in)
    % If the input timezone does not exist or is empty, use the local time zone
    TZ_in = TimeZone.getDefault();
else
    TZ_in = TimeZone.getTimeZone(TZ_ID_in);
end

if ~exist('TZ_ID_out','var') || isempty(TZ_ID_out)
    % If the timezone does not exist or is empty, use the local time zone
    TZ_out = TimeZone.getDefault();
else
    TZ_out = TimeZone.getTimeZone(TZ_ID_out);
end

%%% Create Calendar
cal = GregorianCalendar.getInstance(TZ_in);

%% Get zone info and generate outputs
datenum_out = zeros(size(datenum_in));
TZ_in_off = zeros(size(datenum_in));
TZ_out_off = zeros(size(datenum_in));
out_is_DST = false(size(datenum_in));
for i=1:length(datenum_in)
    [year_in, month_in, day_in, hour_in, minute_in, second_in] = datevec(datenum_in(i));
    cal.set(year_in, month_in - 1, day_in, hour_in, minute_in, second_in);
    out_is_DST(i) = TZ_out.inDaylightTime(cal.getTime());

    TZ_in_off(i) = TZ_in.getOffset(cal.getTimeInMillis()) / 3600 / 1000;
    TZ_out_off(i) = TZ_out.getOffset(cal.getTimeInMillis()) / 3600 / 1000;

    offset_hrs = TZ_out_off(i) - TZ_in_off(i);

    % We can just modify the number of hours. MATLAB is smart enough to roll
    % over where necessary.
    datenum_out(i) = datenum([year_in, month_in, day_in, (hour_in + offset_hrs), minute_in, second_in]);
end
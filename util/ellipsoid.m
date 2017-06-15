function [er, es, en] = ellipsoid(refellip)
%
%function [er, es, en] = ellipsoid(refellip)
%
%  reference ellipsoid for utm calculations
%  Use refellip = 23 for WGS84

% modified for style from Lippmann-supplied code
% 2001 by Holman

erlist = [6377563; 6378160; 6377397; 6377484; 6378206; 6378249;
    6377276; 6378166; 6378150; 6378160; 6378137; 6378200;
    6378270; 6378388; 6378245; 6377340; 6377304; 6378155;
    6378160; 6378165; 6378145; 6378135; 6378137];
eslist = [0.00667054; 0.006694542; 0.006674372; 0.006674372; 0.006768658;
    0.006803511; 0.006637847; 0.006693422; 0.006693422; 0.006694605;
    0.00669438; 0.006693422; 0.00672267; 0.00672267; 0.006693422;
    0.00667054; 0.006637847; 0.006693422; 0.006694542; 0.006693422;
    0.006694542; 0.006694318; 0.00669438];
enlist = {'Airy', 'Australian National', 'Bessel 1841', 'Bessel 1841 (Nambia)',...
    'Clarke 1866', 'Clarke 1880', 'Everest', 'Fischer 1960 (Mercury) ',...
    'Fischer 1968', 'GRS 1967', 'GRS 1980', 'Helmert 1906', 'Hough',...
    'International', 'Krassovsky', 'Modified Airy', 'Modified Everest', ...
    'Modified Fischer 1960','South American 1969', 'WGS 60', 'WGS 66', ...
    'WGS-72', 'WGS-84'};
if ischar(refellip)
    for i = 1:numel(enlist)
        if strcmpi(enlist{i},refellip)
            refellip = i;
            break
        end
    end
end

if ((refellip<1) || (refellip>23))
    error('illegal reference ellipsoid number in function ellipsoid');
end
er = erlist(refellip);
es = eslist(refellip);
en = enlist(refellip);

%
% Copyright by Oregon State University, 2002
% Developed through collaborative effort of the Argus Users Group
% For official use by the Argus Users Group or other licensed activities.
%
% $Id: ellipsoid.m,v 1.1 2004/08/19 23:05:25 stanley Exp $
%
% $Log: ellipsoid.m,v $
% Revision 1.1  2004/08/19 23:05:25  stanley
% Initial revision
%
%
%key CILEphemeris
%comment  Reference ellipsoid for UTM calculations
%

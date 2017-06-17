function [dnWind,vWind,dirWind] = loadWindNDBC(fname, tquery)
%UNTITLED Summary of this function goes here
%   NDBC wind data, e.g. http://www.ndbc.noaa.gov/data/realtime2/44039.txt

fname = 'MetData_NDBC44039.txt';

tmp = fileread(fname);
index=find(abs(tmp-12345.4321)<0.1);
tmp(find(abs(tmp-12345.4321)<0.1))=NaN;






end


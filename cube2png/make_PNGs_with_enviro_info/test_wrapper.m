close all; clear all;

addpath(genpath('C:\Data\ISDRI\isdri-scripts')) %github path

% cubeFile='E:\DAQ-data\processed\2017-05-19\LyndePt_20171390000_pol';%before fail %works
% cubeFile='E:\DAQ-data\processed\2017-05-27\LyndePt_20171470315_pol';%during fail %BAD
% cubeFile='E:\DAQ-data\processed\2017-05-28\LyndePt_20171480000_pol';%during fail %ok
% cubeFile='E:\DAQ-data\processed\2017-05-30\LyndePt_20171500941_pol';%during mega fail %works
imFile='DJI_0002.JPG'; %after fail

timexFile= 'D:\Data\CTR\postprocessed\timex_tides\LyndePt_20171610000_pol_timex.png';

cube2timex_tides_windTS(cubeFile,timexFile)


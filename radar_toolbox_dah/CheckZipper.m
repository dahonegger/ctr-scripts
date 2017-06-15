% Code: CheckZipper.m
% Objective: To check in the raw radar data the presence of the zipper
% effect.  Is done on a frame by frame basis, since it affects the
% computation of the time exposures and the rectification.
%
% Type: Function [DR]=CheckZipper(this,doughnut)
%
% Call ins: readAfileTime.m
%
% Inputs:
%
%   this       = a radar snap
%   doughnut   = the number of pixels to be left out in the doughnut. 
%
%
% Outputs: Zipper Corrected Image,
%
%ChangeLog: -Created Oct 8, 2007, PCM

function [this2,zipperIsHere]=CheckZipper(this,doughnut)
%%
%first, we extract the size of the image
[ns,ncol]=size(this);
zipperIsHere=0;
this2=this;
%now we analize the line previous to the data. If the values are nonzero, 
%it means that the zipper effect is here.

strip=squeeze(this(doughnut,:));

if mean(strip)~=0 %strip
    ind=find(strip~=0); %these are the indeces causing problems
    %so we shift them, pushing them back
    this2(5:end,ind)=this(1:end-4,ind);
    zipperIsHere=1;
end
    
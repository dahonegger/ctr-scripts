%function to print on screen the evolution of a for loop, in %
%increments
%function []=ShowProgress(current value,total_value);
function []=ShowProgress(counter,target,increment)
if isempty(increment)
    increment = 5;
end
% if(rem(counter,floor(target/increment))==0)
fracdone = counter/target;
% if fracdone >= (increment/100)
if rem(counter,floor(target*increment/100))==0
%     timeleft = nowtoc/fracdone - nowtoc;
    fprintf('..done %d of %d.. at %s\n', counter,target,datestr(now))
end
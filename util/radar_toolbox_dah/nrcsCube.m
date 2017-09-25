function Cube = nrcsCube(Cube)

if ~isfield(Cube,'xdom')
    Cube = cartCube(Cube);
end

% Calculate slant range to targets
slantR = sqrt(Cube.results.ZOrigin^2+(Cube.xdom-Cube.results.XOrigin).^2+...
    (Cube.ydom-Cube.results.YOrigin).^2);
% Calculate slant angle of targets
slantTh = asin(Cube.results.ZOrigin./slantR);

% Loop through rotations to conserve memory
Cube.NRCS = double(Cube.data); % Preallocate
for j = 1:Cube.header.rotations
    Iin = double(squeeze(Cube.data(:,:,j)));
    Iin(Iin==0) = nan;
    % beta is hardcoded from RiverRad cross-calibration from Duck2008
    beta = [0.1973 135.7561];
    Iout = NRCSModel(beta,[Iin(:),slantR(:),slantTh(:)]);
    Iout = reshape(Iout,size(Iin));
    
    Cube.NRCS(:,:,j) = Iout;
    
end

Cube.NRCStimex = db(nanmean(10.^(0.1*Cube.NRCS),3),'power');

end
           


%%
%NRCS model for the marine radar. Typicaly called from CalibrateMarineRadar
% X is a 3 column matrix, with X(:,1)=I, X(:,2)=R, X(:,3)=Grazing angle.
%function [NRCS]=NRCSModel(beta,I,R,Grang);
function [NRCS]=NRCSModel(beta,X)
    NRCS=beta(1)*X(:,1)-beta(2)+db(X(:,2).^3,'power')-db(cos(X(:,3)),'power');
end
%%
% function [output]=dB(input);
% output=10*log10(input);
% end

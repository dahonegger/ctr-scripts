function Cube = cartCube(Cube)

if isfield(Cube,'Azi')
    Heading = Cube.results.heading;
    r = Cube.Rg;
%   Subtract heading and convert Azimuth (degrees) to theta (radians). The 90
%   degree shift is because pol2cart wants to define North along +x-axis
    if isfield(Cube,'AziReg')
        tht = (90-Heading-Cube.AziReg) * pi/180;
    elseif numel(Cube.Azi)==length(Cube.Azi)
        tht = (90-Heading-Cube.Azi(:)) * pi/180;
    else
        tht = (90-Heading-Cube.Azi(:,1)) * pi/180;
    end
    [R,T]=meshgrid(r,tht);
    [X,Y]=pol2cart(T',R');
    Cube.xdom = X+Cube.results.XOrigin;
    Cube.ydom = Y+Cube.results.YOrigin;
end

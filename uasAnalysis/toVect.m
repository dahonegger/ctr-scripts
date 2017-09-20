function v = toVect(A,decim)
% v = toVect(A,dim)
%
% Flattens the array A to a vector and outputs it along dimension "dim"
%
% dim=1 => vertical vector (default)
% dim=2 => horizontal vector


v = A(:);

if nargin>1
    v = v(1:decim:end);
end
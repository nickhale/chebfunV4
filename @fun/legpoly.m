function out = legpoly(f,n)
% LEGPOLY   Legendre polynomial coefficients.
% A = LEGPOLY(F) returns the coefficients such that
% F = a_N P_N(x)+...+a_1 P_1(x)+a_0 P_0(x) where P_N(x) denotes the N-th
% normalized Legendre polynomial.
%
% See http://www.comlab.ox.ac.uk/chebfun for chebfun information.

% Copyright 2009 by The Chebfun Team. 

ends = f.map.par(1:2);
f.exps = [0 0];

E = chebfun;
% Legendre matrix
for k = 0:f.n-1
    E(:,k+1) = legpoly(k,ends);  
end

% Coefficients are computed using inner products.
norm2 = (ends(2)-ends(1))./(2*(0:f.n-1)+1).'; % 2-norm squared
out = flipud((E'*chebfun(f))./norm2).';
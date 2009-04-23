function out = legpoly(f,n)
% LEGPOLY   Legendre polynomial coefficients.
% A = LEGPOLY(F) returns the coefficients such that
% F_1 = a_N P_N(x)+...+a_1 P_1(x)+a_0 P_0(x) where P_N(x) denotes the N-th
% normalized Legendre polynomial and F_1 denotes the first fun of chebfun F.
%
% A = LEGPOLY(F,i) returns the coefficients for the i-th fun.
%
% There is also a LEGPOLY command in the chebfun trunk directory, which
% computes the chebfun corresponding to the Legendre polynomial P_n.
%
% See http://www.comlab.ox.ac.uk/chebfun for chebfun information.

% Copyright 2009 by The Chebfun Team. 
 
if numel(f)>1, error('CHEBPOLY does not handle chebfun quasi-matrices'), end
 
% Select fun!
if nargin == 1
    if f.nfuns>1
        warning(['Chebfun has more than one fun. Only the Chebyshev' ...
                 ' coefficients of the first one are returned.' ...
                 ' Use CHEBPOLY(F,1) to suppress this warning.'])
    end
    g = f.funs(1);
    ends = [f.ends(1) f.ends(2)];
else
    if n>f.nfuns
        error(['Chebfun only has ',num2str(f.nfuns),' funs'])
    else
        g = f.funs(n);
        ends = [f.ends(n) f.ends(n+1)];
    end
end

% Legendre matrix
for k = 0:g.n-1
    E(:,k+1) = legpoly(k,ends);  
end

% Coefficients are computed using inner products.
norm2 = (ends(end)-ends(1))./(2*(0:g.n-1)+1).'; % 2-norm squared
out = flipud((E'*chebfun(g,ends))./norm2).';



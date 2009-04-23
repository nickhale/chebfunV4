function g = ceil(f)
% CEIL   Pointwise ceiling of a chebfun.
% G = CEIL(F) returns the chebfun G such that G(X) = CEIL(F(X)) for each
% X in the domain of F.
%
% See also CHEBFUN/FLOOR, CHEBFUN/ROUND, CHEBFUN/FIX, CEIL.
%
% See http://www.comlab.ox.ac.uk/chebfun for chebfun information.

% Copyright 2002-2008 by The Chebfun Team. 

g = -floor(-f);

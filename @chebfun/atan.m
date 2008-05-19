function Fout = atan(F)
% ATAN   Arctangent of a chebfun.

% Copyright 2002-2008 by The Chebfun Team. See www.chebfun.org.

Fout = comp(F, @(x) atan(x));

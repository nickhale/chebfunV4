function Fout = asech(F)
% ASECH   Inverse hyperbolic cosecant of a chebfun.
%

% Copyright 2002-2008 by The Chebfun Team. See www.chebfun.org.

Fout = comp(F, @(x) asech(x));

function Fout = cot(F)
% COT   Cotangent of a chebfun.

% Copyright 2002-2008 by The Chebfun Team. See www.chebfun.org.

Fout = comp(F, @(x) cot(x));

function Fout = erfcx(F)
% ERFCX  Scaled complementary error function of a chebfun.

% Copyright 2002-2008 by The Chebfun Team. See www.comlab.ox.ac.uk/chebfun.

Fout = comp(F, @(x) erfcx(x));
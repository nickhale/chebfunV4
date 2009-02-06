function [out,i] = min(g)
% MIN	Global minimum on [-1,1]
% MIN(G) is the global minimum of the fun G on [-1,1].
% [Y,X] = MIN(G) returns the value X such that Y = G(X), Y the global minimum.

% Copyright 2002-2008 by The Chebfun Team. See www.comlab.ox.ac.uk/chebfun/

[out,i] = max(-g);
out=-out;
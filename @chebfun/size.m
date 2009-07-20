function varargout = size(F,dim)
% SIZE   Size of a chebfun quasimatrix.
%   D = SIZE(F) returns a two-element row vector D = [M,N]. If F is a column
%   quasimatrix, M is infinity and N is the number of columns. For a
%   row quasimatrix, M is the number of rows and N is infinity.
%
%   [M,N] = SIZE(F)  returns the dimensions of F as separate output
%   variables.
%
%   M = SIZE(F,DIM) returns the dimension specified by the scalar DIM.
%
%   See http://www.comlab.ox.ac.uk/chebfun for chebfun information.

% Copyright 2002-2008 by The Chebfun Team. 

if F(1).trans
  if isempty(F(1).ends)
    m = 0;
  else
    m = numel(F);
  end
  n = inf;
else
  if isempty(F(1).ends)
    n = 0;
  else
    n = numel(F);
  end
  m = inf;
end

if nargin == 1 
    if nargout == 2
        varargout = {m ,n};
    else
        varargout = {[m ,n]};
    end
elseif dim==1
    varargout = {m};
else
    varargout = {n};
end

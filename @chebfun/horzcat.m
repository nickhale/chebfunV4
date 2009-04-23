function Fout = horzcat(varargin)
% HORZCAT   Chebfun vertical concatenation.
% [F1 F2] is the vertical concatenation of quasimatrices F1 and F2.
%
% For row chebfuns, F = HORZCAT(F1,F2,...) concatenates any number of
%   chebfuns by translating their domains to, in effect, create a piecewise
%   defined chebfun F.
%
% For column chebfuns, F = VERTCAT(F1,F2,...) returns a quasi-matrix
%   whose columns are F1, F2, ....
%
% See also CHEBFUN/VERTCAT, CHEBFUN/SUBSASGN.
%
% See http://www.comlab.ox.ac.uk/chebfun for chebfun information.

% Copyright 2002-2008 by The Chebfun Team. 

for k = 1:nargin, varargin{k} = varargin{k}.'; end
Fout = vertcat(varargin{:}).';
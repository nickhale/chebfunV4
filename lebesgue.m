function [L,Lconst] = lebesgue(x,varargin)  
%  L = LEBESGUE(X), where X is a set of points in [-1,1],
%  returns the Lebesgue function associated with polynomial
%  interpolation in those points.
%
%  L = LEBESGUE(X,D), where D is a domain and X is a set of points
%  in D, returns the Lebesgue function associated with polynomial
%  interpolation in those points in that domain.
%
%  L = LEBESGUE(X,a,b) or LEBESGUE(X,[a,b]) does the same with
%  D = domain(a,b).
%
%  [L,Lconst] = LEBESGUE(X) etc. also returns the Lebesgue constant.
%
%  For example, these commands compare the Lebesgue functions and
%  constants for 8 Chebyshev, Legendre, and equispaced points in [-1,1]:
%
%  n = 8;
%  [L,c] = lebesgue(chebpts(n));
%  subplot(1,3,1), plot(L), title(['Chebyshev: ' num2str(c)])
%  grid on, axis([-1 1 0 8])
%  [L,c] = lebesgue(legpts(n));
%  subplot(1,3,2), plot(L), title(['Legendre: ' num2str(c)])
%  grid on, axis([-1 1 0 8])
%  [L,c] = lebesgue(linspace(-1,1,n));
%  subplot(1,3,3), plot(L), title(['Equispaced: ' num2str(c)])
%  grid on, axis([-1 1 0 8])

%  See http://www.comlab.ox.ac.uk/chebfun for chebfun information.

%  Copyright 2009 by The Chebfun Team. 
%
%  This version of LEBESGUE lives in the chebfun trunk directory.
%  There is a companion code in @domain.
%
%  Nick Trefethen,  22/07/2009
 
if nargin==1
  d = domain(-1,1);
elseif nargin==2
  d = domain(varargin{1});
elseif nargin==3
  d = domain(varargin{1},varargin{2}); 
else
  error('wrong number of arguments in lebesgue');
end

% barycentric weights
w = bary_weights(x);
% set preferences
pref = chebfunpref; pref.sampletest = false; pref.maxdegree = length(x)-1;
% ill-conditioned computations may prevent convergence to high accuracy.
warning('off','CHEBFUN:auto')
% Lebesgue function (breakpoints at interpolation nodes)
L = chebfun(@(t) lebfun(t,x(:),w), unique([x(:);d.ends.']), pref);
warning('on','CHEBFUN:auto')

% Lebesgue constant
if nargout==2, Lconst = norm(L,inf); end


function L = lebfun(t,xk,w)
% Lebesgue function: xk are nodes, w are weights, t evaluation points
% Based on barycentric formula.
L = ones(size(t)); % Note: L(xk) = 1
mem = ismember(t,xk);
for i = 1:numel(t)
    if ~mem(i)
        xx = w./(t(i)-xk);
        L(i) = sum(abs(xx))/abs(sum(xx));
    end
end
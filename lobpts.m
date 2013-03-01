function [x, w, v] = lobpts(n,varargin)
%LOBPTS  Gauss-Legendre-Lobatto Quadrature Nodes and Weights.
%  LOBPTS(N) returns N Legendre-Lobatto points X in (-1,1).
%
%  [X,W] = LOBPTS(N) returns also a row vector W of weights for
%  Gauss-Legendre-Lobatto quadrature.
%
%  [X,W,V] = LOBPTS(N) returns additionally a column vector V of weights in
%  the barycentric formula corresponding to the points X. The weights are
%  scaled so that max(abs(V)) = 1.
%
%  [X,W] = LOBPTS(N,METHOD) allows the user to select which method to use.
%    METHOD = 'REC' uses the recurrence relation for the Legendre 
%       polynomials and their derivatives to perform Newton iteration 
%       on the WKB approximation to the roots. Default for N < 100.
%    METHOD = 'ASY' uses the Hale-Townsend fast algorithm based up
%       asymptotic formulae, which is fast and accurate. Default for 
%       N >= 100.
%    METHOD = 'GLR' uses the Glaser-Liu-Rokhlin fast algorithm [2], which
%       is fast and can give better relative accuracy for the -.5<x<.5
%       than 'ASY' (although the accuracy of the weights is usually worse).
%    METHOD = 'GW' will use the traditional Golub-Welsch eigenvalue method, 
%       which is maintained mostly for historical reasons.
%
%  See also chebpts, legpts, jacpts, legpoly, radaupts.

%% Nodes
[x, w, v] = jacpts(n-2,1,1,varargin{:});
x = [-1 ; x ; 1];

if nargout < 2, return, end

%% Quadrature weights

% Initialise
Pm2 = 1; Pm1 = x;
% Use recurrence relation
for k = 1:n-2, 
    P = ((2*k+1)*Pm1.*x-k*Pm2)/(k+1);
    Pm2 = Pm1; 
    Pm1 = P; 
end   
w = 2./(n*(n-1)*P.^2);
w([1 end]) = 2/(n*(n-1));

if nargout < 3, return, end

%% Barycentric weights
vv = bary_weights(x);
v = v./(1-x(2:n-1).^2);
v = v/max(abs(v));
v = [vv(1) ; v ; vv(end)];
function [x w] = lagpts(n,method)
%LAGPTS  Laguerre points and Gauss-Laguerre Quadrature Weights.
%  LAGPTS(N) returns N Laguerre points X in (-1,1).
%
%  [X,W] = LAGPTS(N) also returns a row vector of weights for Gauss-Laguerre 
%  quadrature.
%
%  [X,W] = LAGPTS(N,METHOD) allows the user to select which method to use.
%  METHOD = 'GW' will use the traditional Golub-Welsch eigenvalue method,
%  which is best for when N is small. METHOD = 'FAST' will use the
%  Glaser-Liu-Rokhlin fast algorithm, which is much faster for large N.
%  By default LEGPTS uses 'GW' when N < 128.
%
%  See also chebpts, legpts, and jacpts.
%
%  See http://www.maths.ox.ac.uk/chebfun for chebfun information.

%  'GW' by Nick Trefethen, March 2009 - algorithm adapted from [1].
%  'FAST' by Nick Hale, March 2010 - algorithm adapted from [2].
%
%  Copyright 2002-2009 by The Chebfun Team. 
%  Last commit: $Author: hale $: $Rev: 1022 $:
%  $Date: 2010-01-25 14:06:01 +0000 (Mon, 25 Jan 2010) $:
%
%  References:
%   [1] G. H. Golub and J. A. Welsch, "Calculation of Gauss quadrature
%       rules", Math. Comp. 23:221-230, 1969, 
%   [2] A. Glaser, X. Liu and V. Rokhlin, "A fast algorithm for the 
%       calculation of the roots of special functions", SIAM Journal  
%       on Scientific Computing", 29(4):1420-1438:, 2007.

if nargin == 1
    method = 'default';
end

% decide to use GW or FAST
if (n < 128 || strcmpi(method,'GW')) && ~strcmpi(method,'fast') % GW, see [1]
   alpha = (2*(1:n)-1);  beta = 1:n-1;   % 3-term recurrence coeffs
   T = diag(beta,1) + diag(alpha) + diag(beta,-1);  % Jacobi matrix
   [V,D] = eig(T);                       % eigenvalue decomposition
   [x,indx] = sort(diag(D));             % Laguerre points
   w = V(1,indx).^2;                     % weights
else                                                            % Fast, see [2]
   [x ders] = alg0_Lag(n);               % nodes and L_n'(x)
   w = exp(-x)./(x.*ders.^2);            % weights
   w = w';
end
w = (1/sum(w))*w;                        % normalise so that sum(w) = 1

% -------------------- Routines for FAST algorithm ------------------------

function [x ders] = alg0_Lag(n)
x = zeros(n,1); 
ders = zeros(n,1);
xs = 1/(2*n+1);
n1 = 20;
n1 = min(n1, n);
x = zeros(n,1);
for k = 1:n1
    [xs ders(k)] = alg3_Lag(n,xs);
    x(k) = xs;  
    xs = 1.1*xs;
end
[x ders] = alg1_Lag(x,ders,n,n1);


% --------------------------- UNSCALED VERSION ------------------------------

function [roots ders] = alg1_Lag(roots,ders,n,n1)
m = 30;
u = zeros(1,m+1); up = zeros(1,m+1);
for j = n1:n-1
    x = roots(j);
    h = rk2_Lag(pi/2,-pi/2,x,n) - x;

    r = x.*(n+.5 -.25*x);  p = x.^2;
    u(1:2) = [0; ders(j)]; 
    u(3) = (-x*u(2)/2-r*u(1))/p;
    u(4) = (-x*u(3)-(1+r)*u(2)/6-(n+.5-.5*x)*u(1))/p;
    up(1:3) = [u(2) ; 2*u(3) ; 3*u(4)];

    for k = 2:m-2
%         u(k+3)=(-x*(2*k+1)*u(k+2)-(k*k+r)*u(k+1)-k*(n+.5-.5*x)*u(k)+.25*k*(k-1)*u(k-1))/p;
        u(k+3)=(-x*(2*k+1)*(k+1)*u(k+2)-(k*k+r)*u(k+1)-(n+.5-.5*x)*u(k)+.25*u(k-1))/(p*(k+2)*(k+1));
        up(k+2) = (k+2)*u(k+3);
    end    
   
    for l = 1:5
%         hh = [1;cumprod(h*ones(m,1))];
        hh = [1;cumprod(h+zeros(m,1))];
        h = h - (u*hh)./(up*hh);
    end
    
    roots(j+1) = roots(j) + h;
    ders(j+1) = up*[1;cumprod(h*ones(m,1))];

end

% -------------------------------------------------------------------------

function [x1 d1] = alg3_Lag(n,xs)
[u up] = eval_Lag(xs,n);
theta = atan(sqrt(xs/(n+.5-.25*xs))*up/u);
x1 = rk2_Lag(theta,-pi/2,xs,n);

for k = 1:10
    [u up] = eval_Lag(x1,n);
    x1 = x1 - u/up;
end
[ignored d1] = eval_Lag(x1,n);

% -------------------------------------------------------------------------

function [L Lp] = eval_Lag(x,n)
Lm2 = 0; Lm1 = exp(-x/2); Lpm2 = 0; Lpm1 = 0;
for k = 0:n-1
    L = ((2*k+1-x).*Lm1-k*Lm2)/(k+1);
    Lp = ((2*k+1-x).*Lpm1-Lm1-k*Lpm2)/(k+1);
    Lm2 = Lm1; Lm1 = L; Lpm2 = Lpm1; Lpm1 = Lp;
end

% -------------------------------------------------------------------------

function x = rk2_Lag(t,tn,x,n)
m = 5; h = (tn-t)/m;
for j = 1:m
    f1 = (n+.5-.25*x);
    k1 = -h/(sqrt(f1/x)+.25*(1/x-.25/f1)*sin(2*t));
    t = t+h;  x = x+k1;   f1 = (n+.5-.25*x);
    k2 = -h/(sqrt(f1/x)+.25*(1/x-.25/f1)*sin(2*t));
    x = x+.5*(k2-k1);
end
% rpc19 Computation of Pade coefficients from its chebfun.
%
% Given a chebfun and values L and M, this program computes the
% coefficients of the [L/M]-Pade approximation. The c_j Taylor coefficient
% is given by
%
% c_j  =  (2*pi*i)^(-1) INT z^-(j+1) f(z) dz
%
% and the integral is evaluated by the N-point trapezoidal rule (see the
% code 'taylor_coeffs.m' from Trefethen's paper "Ten Digit Algorithms").
%
% RPC - 08/07
clear, clc
f = chebfun(@(z) exp(z)./(z+2));
L = 5;
M = 5; 
% Taylor coefficients -----------------------------------------------------
r = 15*log(10)/(2*(length(f)-1));              % radius where function error is 1e-12
N = 41;  % <- what is the appropiate # here?   % # of points to evaluate the integral
z = r*exp(2i*pi*(0:N-1)/N);                    % roots of unity
t = fft(f(z))/N;                               % FFT of f evaluated at roots of unity
t = real(t);                                   % t must be real by symmetry
t = t./r.^(0:length(t)-1);                     % Taylor coefficients
c = [zeros(1,M-L-1) t(max(1,L-M+2):L+M+1)]';   % c = [c_{L-M+1} ... c{L+M}]' 
%--------------------------------------------------------------------------
H = hankel(c(1:M),c(M:end-1));
b = [H\-c(M+1:2*M)]';                          % b  = [b_M b_{M-1} ... b_2 b_1]'
c = t(L+1:-1:1);                               % c  = [c_L c_{L-1} ... c_1 c_0]'
if length(c) > 1, cb = conv(b,c(2:end)); else cb = []; end
a = c + [cb(max(M,1):end) 0]; 
x = chebfun('x',domain(f));
p = polyval(a,x); q = polyval([b 1],x);
r = p./q;
disp(['degree of [',num2str(L),'/',num2str(M),']-chebfun: ']), disp(length(r))
disp('numerator coeffs:'), disp(a)
disp('denominator coeffs:'), disp([b 1])
disp('poles :'),disp(roots(q))
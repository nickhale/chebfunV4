% ------------------------------------------------
% CHEBFUN DEMO
%
% visit http://web.comlab.ox.ac.uk/projects/chebfun/
% ------------------------------------------------

f = chebfun('sin(20*x)./(1+exp(x)+x.^2)',[-2 2]);
length(f)
plot(f,'.-')
sum(f)
norm(f)
ff = f.^2+2*f-1;
length(ff)
hold on
plot(ff,'r.-')
half = chebfun(-.1,1.1,[-2 0 2]); % step function
hold off
plot(half)
plot(diff(half)) % Dirac Delta
x = chebfun('x',[-2 2]);
h = half.*f + .3*(abs(x)-.2*x);
struct(h)
length(h)
hold off, plot(h,'.-'), hold on, grid on
[a,b] = max(h), plot(b,a,'or','markersize',14);
[a,b] = min(h), plot(b,a,'or','markersize',14);
r = roots(h-.2), plot(r,0*r+.2,'*k','markersize',14);
hold off
% ------------------------------------------------
clear, clf
f = chebfun('real(airy(x))',[-15 5]);
length(f)
plot(f,'.-')
g = chebfun('-.1*sin(x/4)+.03',[-15 5]);
length(g)
hold on
plot(g,'k.-')
g = abs(g);
h = max(f,g);
struct(h)
plot(h,'r.-')
hold off, plot(h,'.-'), hold on, grid on
[a,b] = max(h), plot(b,a,'or','markersize',14);
[a,b] = min(h), plot(b,a,'or','markersize',14);
r = roots(h-.2), plot(r,0*r+.2,'*k','markersize',14);
hold off
% ------------------------------------------------
% Cornu spiral
t = chebfun(@(t) t,[-10 10]);
x = cumsum(cos(t.^2/2));
plot(x,'.-')
y = cumsum(sin(t.^2/2));
hold on
plot(y,'r.-')
hold off
plot(x,y)
comet(x,y)
% ------------------------------------------------
% Pick some points
rpc18 % a recreational M-file
length(f)
hold off
plot(1i*f)
plot(sin(f))
plot(cumsum(f))
plot(diff(f))
plot(sqrt(f))
function pass = chebfun2_interpaccuracy
% Test the Chebfun2 constructor with a few functions.
% Alex Townsend, March 2013. 

j=1; tol = chebfun2pref('eps');

% Mohsin's bugs. 
f = @(x,y) exp(pi*(x+y)); 
x=.995; y=.99; 
g = chebfun2(f); 
pass(j) = (abs(f(x,y)-g(x,y))<3000*tol); j=j+1; 

% composing the same function. 
x = chebfun2(@(x,y)x); y = chebfun2(@(x,y)y); 
f = exp(pi*(x+y)); 
x=.995; y=.99;
pass(j) = (abs(f(x,y)-g(x,y))<1e4*tol); j=j+1; 


% Nick T's function 
f = @(x,y) exp(-100*( x.^2 - x.*y + 2*y.^2 - 1/2).^2);
g = chebfun2(f);
twonorm = 0.545563608722019;
pass(j) = (abs(norm(g)-twonorm)<100*tol); j=j+1; 

x=.995; y=.99;
pass(j) = (abs(f(x,y)-g(x,y))<100*tol); j=j+1; 


f = chebfun2(@(x,y) exp(3*(cos(x-.1)+cos(y-.2))));
pass(j) = (abs(f(.1,.2) - exp(6))<1e4*tol); j=j+1; 

end
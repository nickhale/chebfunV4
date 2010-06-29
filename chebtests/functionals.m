function pass = functionals

%  Toby Driscoll

%  Last commit: $Author$ $Rev$
%  $ID$

[d,x] = domain(-1,2);
f = cos(x)./(1+x.^2);
S = sum(d);
A = [S; -2*S];
pass(1) = norm( sum(f)*[1;-2] - A*f ) < 100*chebfunpref('eps');

E = feval(d,2);
F = feval(d,[-1;0]);
A = [E;F];
pass(2) = norm( f([2;-1;0]) - A*f ) < 100*chebfunpref('eps');

end
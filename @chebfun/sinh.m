function F = sinh(f)
% SINH Hyperbolic sine.
% SINH(F) is the hyperbolic sine of F. Effect of impulses is ignored.
%
% Ricardo Pachon and Lloyd N. Trefethen, 2007, Chebfun Version 2.0
F = f;
nfuns = length(f.funs);
for i = 1:nfuns
    F.funs{i} = sinh(F.funs{i});
end
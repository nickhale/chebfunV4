function F = subsref(f,S)
% SUBSREF   subscripted reference
% F(X) returns the values of the chebfun F evaluated on the array X. The 
% function at the right of a breakpoint x is used for the evaluation of F
% on x.
%
% Ricardo Pachon and Lloyd N. Trefethen, 2007, Chebfun Version 2.0
nfuns = length(f.funs);
ends = f.ends;
s = S.subs{1};
[X,I] = rescale(s,ends);
F = zeros(size(s));
if nfuns == 0
    % This is an old safeguard. It might be removed
    ffuns = f.funs;
    F = ffuns(X);
    warning('Safeguard in SUBSREF has been used. Please contact support.')
else
    for i = 1:nfuns
        ffun = f.funs{i};
        pos = find(I==i);
        F(pos) = ffun(X(pos));
    end
end
if any(f.imps(1,:))
    s = s(:).';
    [val,loc,pos] = intersect(s,ends);
    F(loc(any(f.imps(:,pos)>0,1))) = inf;
    F(loc(any(f.imps(:,pos)<0,1))) = -inf;
end
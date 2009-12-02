function [g1 ish] = minus(g1,g2)
% -	Minus
% G1 - G2 subtracts fun G1 from G2 or a scalar from a fun if either
% G1 or G2 is a scalar.
%
% See http://www.comlab.ox.ac.uk/chebfun for chebfun information.

% Copyright 2002-2008 by The Chebfun Team.
% Last commit: $Author$: $Rev$:
% $Date$:

%if (isempty(g1) || isempty(g2)), gout=fun; return; end

% The exponents of g1 and g2 are automatically summed. Perhaps
% some checking should be done for cancellation??

ish = true; % We're usually happy!

% Scalar case:
if isa(g1,'double') 
    if ~any(g2.exps)
        g2.vals = g1-g2.vals; g2.scl.v = max(g2.scl.v,norm(g2.vals,inf)); 
        g1 = g2;
        return
    else
        if g1 == 0, g1 = g2; return, end
        g1 = fun(g1,g2.map);
    end
elseif isa(g2,'double') 
    if ~any(g1.exps)
        g1.vals = g1.vals-g2; g1.scl.v = max(g1.scl.v,norm(g1.vals,inf));
        return;
    else
        if g2 == 0; return, end
        g2 = fun(g2,g1.map);
    end
end

% Deal with maps
exps1 = g1.exps; exps2 = g2.exps;
ends = g1.map.par(1:2);

% Same maps and exponents are easy
if samemap(g1,g2) && all(exps1==exps2);
    % use standard procedure:
    gn1 = g1.n;
    gn2 = g2.n;
    if (gn1 > gn2)
        g2 = prolong(g2,gn1);
        vals = g1.vals - g2.vals;
    elseif gn1 < gn2
        g1 = prolong(g1,gn2);
        vals = g1.vals - g2.vals;
    elseif (g1.vals == g2.vals)
        vals = 0;
    else
        vals = g1.vals - g2.vals;
    end
    
    g1.vals = vals;
    g1.scl.h = max(g1.scl.h,g2.scl.h);
    g1.scl.v = max([g1.scl.v,g2.scl.v,norm(vals,inf)]);
    g1.n = length(vals);
    
    if any(g1.exps < 0) || any(isinf(ends))
        g1 = checkzero(g1);
    end
    return
end

% If two maps are different, but no exponents then call constructor.
if ~samemap(g1,g2) && ~any([exps1 exps2])
    scl.v = max(g1.scl.v,g2.scl.v);
    scl.h = g1.scl.h;
    pref = chebfunpref;
    if pref.splitting
        pref.splitdegree = 8*pref.splitdegree;
    end
    pref.resampling = false;
    [g1,ish] = fun(@(x) feval(g1,x)-feval(g2,x),ends,pref,scl);
    if ~ish
        warning('fun:minus:failtoconverge','Operation may have failed to converge');
    end
    return
end

% integer exponents is semi-easy special case.
% (Linear map is an even simplier special case?)
% if round([exps1 exps2]) == [exps1 exps2] % 'new way' is more general!
if round(exps1-exps2) == exps1-exps2
    g1.exps = [0 0]; g2.exps = [0 0];
    pref = chebfunpref; 
    pref.exps = {0 0};
    pref.resampling = false;
    
    scl.h = max(g1.scl.h,g2.scl.h);
    scl.v = max(g1.scl.v,g2.scl.v);
    
% old way!
%     % Reduce exponents greater that +1
%     g1 = replace_roots(g1);
%     g2 = replace_roots(g2);
%
%     exps1 = -exps1; exps2 = -exps2;
%     g1 = g1.*fun(@(x) (x-ends(1)).^exps2(1).*(ends(2)-x).^exps2(2),g1.map,pref,scl) - ...
%         g2.*fun(@(x) (x-ends(1)).^exps1(1).*(ends(2)-x).^exps1(2),g2.map,pref,scl);
%     g1.exps = -sum([exps1 ; exps2]);

% new way!
    a1 = max(exps1(1),exps2(1)); a2 = min(exps1(1),exps2(1)); 
    b1 = max(exps1(2),exps2(2)); b2 = min(exps1(2),exps2(2)); 
    a12 = a1-a2; b12 = b1-b2;
    a = ends(1); b = ends(2);
    
    s = (2./diff(ends));
    c1 = s^(sum(exps1)-a2-b2);
    c2 = s^(sum(exps2)-a2-b2);
    
    g1 = g1.*fun(@(x) c1*(x-a).^((a1==exps1(1))*a12).*(b-x).^((b1==exps1(2))*b12),g1.map,pref,scl) - ...
        g2.*fun(@(x) c2*(x-a).^((a1==exps2(1))*a12).*(b-x).^((b1==exps2(2))*b12),g2.map,pref,scl);
    g1.exps = [a2 b2];
    
    g1.scl = scl; 
    g1.scl.v = max(g1.scl.v,norm(g1.vals,inf));
    g1.n = length(g1.vals);
    
    if any(g1.exps < 0) || any(isinf(ends))
        g1 = checkzero(g1);
        g1 = extract_roots(g1);
    end
    return
end

% ------------- Difficult case: -------------
% non-integer exponents which don't match

pref = chebfunpref;
if pref.splitting
    pref.splitdegree = 8*pref.splitdegree;
end
pref.resampling = false;
pref.blowup = 1;

scl.h = max(g1.scl.h,g2.scl.h);
scl.v = max(g1.scl.v,g2.scl.v);

% Choose the correct singmap
dexps = exps1 - exps2;
newexps = [0 0];
pows = [0 0 ];       % will be the powers in the sing map
lr = 0;
% left
if round(dexps(1)) ~= dexps(1) % then trouble at the left
    lr = -1;        % flag for sing.m
    expsl = sort([exps1(1) exps2(1)]);
    if expsl(1) < 0 % ==> blow up, so use exponents in new representation
        newexps(1) = expsl(1);
        pows(1) = expsl(2)-expsl(1);
    else            % ==> no blow up, so use largest power
        pows(1) = expsl(2);
    end
else
%     error('can''t do this yet');
%     [expsl idx] = sort([exps1(1) exps2(1)]);
end
% right (as above)
if round(dexps(2)) ~= dexps(2)
    lr = lr + 1; 
    expsr = sort([exps1(2) exps2(2)]);
    if expsr(1) < 0
        newexps(2) = expsr(1);
        pows(2) = expsr(2)-expsr(1);
    else
        pows(2) = expsr(2);
    end
else
%     error('can''t do this yet');
%     [expsr idx] = sort([exps1(2) exps2(2)])
%     newexps(2) = expsr(1);
%     multl
end

% The new map
map = maps({'sing',pows},ends);
% The new exponents
pref.exps = {newexps(1) newexps(2)};
pref.sampletest = 0;

% Call the fun constructor
[g1,ish] = fun(@(x) feval(g1,x)-feval(g2,x),map,pref,scl);

if ~ish
    warning('fun:minus:failtoconverge','Operation may have failed to converge');
end
    
if any(g1.exps < 0)
    g1 = checkzero(g1);
end

function g1 = checkzero(g1)
% With exps, if the relative deifference is O(eps) we set it to zero.
% Same goes for unbounded domains.
if all(abs(g1.vals) < 10*g1.scl.v*chebfunpref('eps'))
    g1.vals = 0;
    g1.n = 1; 
    g1.exps = [0 0];
    g1.scl.v = 0;
end




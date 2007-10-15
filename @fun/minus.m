function F = minus(f,g)
% -	Minus
% F - G subtracts fun G from F or a scalar from a fun if either
% F or G is a scalar.

% Copyright 2003 Zachary Battles, Chebfun Version 1.0
if (isempty(f) | isempty(g)), F=fun; return; end
if isa(f,'double')
  F=g;
  F.val=f-g.val;
  return;
elseif isa(g,'double')
  F=f;
  F.val=f.val-g;
  return;
end
fn=f.n;
gn=g.n;
if (fn > gn)
  F=f;
  g=prolong(g,fn);
  F.val=f.val-g.val;
elseif fn < gn
  F=g;
  f=prolong(f,gn);
  F.val=f.val-g.val;
elseif (f.val==g.val)
  F=f;
  F.val=0;
  F.n=0;
else
  F=f;
  F.val=f.val-g.val;
end

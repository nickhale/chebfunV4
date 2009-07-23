function x = bary(x,gvals,xk,ek)  
% BARY  Barycentric interpolation with arbitrary weights/nodes.
%  P = BARY(X,GVALS,XK,W) interpolates the values PK at nodes 
%  XK in the point X using the barycentric weights EK. 
%
%  P = BARY(X,GVALS) assumes Chebyshev nodes and weights. 
%
%  All inputs should be column vectors.
%
%  See http://www.comlab.ox.ac.uk/chebfun for chebfun information.

%  Copyright 2002-2009 by The Chebfun Team. 
%  Last commit: $Author$: $Rev$:
%  $Date$:

n = length(gvals);

if n == 1               % The function is a constant
    x = gvals*ones(size(x));
    return;
end

if nargin < 4           % Default to Chebyshev weights
    ek = [1/2; ones(n-2,1); 1/2].*(-1).^((0:n-1)'); 
end
if nargin < 3           % Default to Chebyshev nodes
    xk = chebpts(n);
end

[mem,loc] = ismember(x,xk);
    
if length(x) < length(xk)
    for i = 1:numel(x)
        if ~mem(i)
            xx = ek./(x(i)-xk);
            x(i) = (xx.'*gvals)/sum(xx);
        end
    end      
else
     xnew = x(~mem);
     num = zeros(size(xnew)); denom = num;
     for i = 1:numel(xk)
          y = ek(i)./(xnew-xk(i));
          num = num+(gvals(i)*y);
          denom = denom+y;
     end
     x(~mem) = num./denom;
end

x(mem) = gvals(loc(mem));


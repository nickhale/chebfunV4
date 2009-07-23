function F = fred(k,d)
% FRED  Fredholm integral operator.
% F = FRED(K,D) constructs a chebop representing the Fredholm integral
% operator with kernel K for functions in domain D=[a,b]:
%    
%      (F*v)(x) = int( K(x,y)*v(y), y=a..b )
%  
% The kernel function K(x,y) should be smooth for best results.
%
% K must be defined as a function of two inputs X and Y. These may be
% scalar and vector, or they may be matrices defined by NDGRID to represent
% a tensor product of points in DxD, so K must be vectorized accordingly.
% In the matrix case, some kernels can be evaluated much more efficiently
% using X(:,1) and Y(1,:) instead of the full matrices. For example, the
% separable kernel K(x,y) = exp(x-y) might be coded as
%
%   function K = kernel(X,Y)
%   if all(size(X)>1)       % matrix input
%     x = X(:,1);  y = Y(1,:);
%     K = exp(x)*exp(-y);   % vector outer product
%   else
%     K = exp(X-Y);
%   end
%
%  See also volt, chebop.

% Copyright 2009 by Toby Driscoll and Folkmar Bornemann.
% See http://www.comlab.ox.ac.uk/chebfun for chebfun information.
% $Id$

F = chebop(@matrix,@op,d);

% Functional form. At each x, do an adaptive quadrature.
  function v = op(u)
    % Result can be resolved relative to norm(u).
    scale = norm(u);
    int = @(x) sum(u.*chebfun(@(y) k(x,y),d,'resampling',false,'splitting',true));
    v = chebfun( vec(@(x) scale+int(x)), d,'sampletest',false,'resampling',false );
    v = v-scale;
  end

% Matrix form. At given n, multiply function values by CC quadrature
% weights, then apply kernel as inner products. 
  function A = matrix(n)
    x = chebpts(n,d);
    [X,Y] = ndgrid(x);
    s = clencurt(d.ends(1),d.ends(2),n);
    A = k(X,Y) * spdiags(s',0,n,n);
  end
    
end
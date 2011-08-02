function varargout = svds(A,k,sigma)
%SVDS  Find some singular values and vectors of a compact linop.
% S = SVDS(A) returns a vector of 6 nonzero singular values of the
% linear compact chebop A, such as the FRED or VOLT operator.
% SVDS will attempt to return the largest singular values. If A is not
% linear and/or seems to be unbounded, an error is returned.
%
% [U,S,V] = SVDS(A) returns a diagonal 6x6 matrix D and two orthonormal
% quasi-matrices such that A*V = U*S.
%
% Note that an integral operator smoothest the right-singular vectors V.
% Hence finding these vectors is a problem with possibly large backward
% errors and one must expect that the vectors in V are not accurate to
% machine eps. However, the left sing. vectors U have fine accuracy.
%
% SVDS(A,K) computes the K largest singular values of A.
%
% SVDS(A,K,SIGMA) tries to compute K singular values closest to a scalar
% shift SIGMA. Note, however, that for compact operators there are
% infinitely many singular values close to or at zero!
%
%
% Example:
%
% [d,x] = domain(0,pi);
% A = fred(@(x,y)sin(2*pi*(x-2*y)),d);
% [U,S,V] = svds(A);
%
% See also linop/eigs.

% Copyright 2011 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.


if nargin < 2, k = 6; end;
if nargin < 3 || strcmp(sigma,'L'), sigma = inf; end;

d = domain(A);

U = []; S = []; V = []; flag = 0; pts = [];

tol = 1e-13;
pref = chebfunpref;
pref.eps = tol;
Sold = -inf;

ignored = chebfun(@(x) drive(x),'splitting','off','sampletest','off',...
    'vectorcheck','off','minsamples',33,'resampling','on','eps',tol);

U = simplify(chebfun(U,d));
V = Minv*(spdiags(1./D,0,pts,pts)*V);
V = chebfun(V,d);

if nargout <= 1,
    varargout = { S };
else
    varargout = { U,diag(S),V, flag };
end;

    function u = drive(x)
        
        if numel(x) > 1100,
            %warning('chebfun:linop:svds','Left singular vectors not resolved to machine precision.');
            u = 0*x;
            flag = 1;
            return;
        end;
        
        % get collocation matrix
        pts = numel(x); 
        Apts = feval(A,pts);
        
        if diff(size(Apts)),
            error('chebfun:linop:svds','Nonsquare collocation currently not supported.')
        end;
        
        
        % SVD in L2 inner product
        [M,D,Minv] = getL2InnerProductMatrix(pts,d);
        Apts = full(full(spdiags(D,0,pts,pts)*M)*Apts*full(Minv*spdiags(1./D,0,pts,pts)));
        [U,S,V] = svd(Apts);
        S = diag(S);
        
        % sort and truncate
        S = S(S>tol/10*S(1)); % ignore these, as singular vectors are noisy
        [dummy,ind] = sort(abs(sigma - S),'ascend'); % singvals closest to sigma
        ind = ind(1:min(k,length(ind)));
        ind = sort(ind);
        V = V(:,ind);
        U = U(:,ind);
        S = S(ind);

        if length(S) ~= length(Sold),
            u = x; u(2:2:end) = -u(2:2:end);
            Sold = S;
            return
        elseif norm((S-Sold)./S(1),inf) > tol,
            u = x; u(2:2:end) = -u(2:2:end);
            Sold = S;
            return
        end
        Sold = S;
        
        % create L2-orthonormal Chebfuns from U,V (V actually outside of drive)
        U = Minv*(spdiags(1./D,0,pts,pts)*U);
        K = 1./(1:length(ind))';
        u = U*K;        
    end
end





function [M,D,Minv] = getL2InnerProductMatrix(pts,d)
% Returns matrices M,Minv such that for two vectors x,y of
% length pts we have
% y'*x = chebfun(diag(D)*M*y)'*chebfun(diag(D)*M*x).
% Minv is the inverse of M.

x = chebpts(pts,d);
[y,w,v] = legpts(pts,d);
M = barymat(y,x);
D = sqrt(w(:));
Minv = barymat(x,y,v);
end


function M = getL2InnerProductMatrix_old(pts,d)

x = chebpts(pts,d).';
[y,w] = legpts(pts,d);
n = ceil(pts/2);  % need only compute the upper half of M
Y = [ repmat(y,1,n) ; x(1:n) ]; % evaluation points
M = ones(pts+1,n); % will contain function values
for j = 1:pts,  % evaluate Lagrange polynomials at Gauss notes
    MM = Y - x(j);
    if j <= n, MM(:,j) = 1; end;
    M = M.*MM;
end;
M = full(M(1:pts,:)*spdiags(1./M(pts+1,:)',0,n,n)); % normalize
M = full(spdiags(sqrt(w(:)),0,pts,pts)*M); % scale by Gauss weights
M = [ M , M(pts:-1:1,floor(pts/2):-1:1) ];
end



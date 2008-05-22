function varargout = svd(A,econ)
% SVD   Singular value decomposition.
% [U,S,V] = SVD(A,0), where A is a column quasimatrix with n columns,
% produces an n x n diagonal matrix S with nonnegative diagonal
% elements in nonincreasing order, a column quasimatrix U with n
% orthonormal columns, and an n x n  unitary matrix V such that
% A = U*S*V'.
%
% If A is a row quasimatrix with n rows, then U is a unitary matrix
% and V is a row quasimatrix.
%
% S = SVD(A) produces a vector containing the singular values.

% Copyright 2002-2008 by The Chebfun Team. See www.comlab.ox.ac.uk/chebfun.

% The computation is carried out by orthogonalization operations
% following Battles' 2006 thesis.

if ((nargout>1)&(nargin~=2)) | ((nargin==2) & (econ~=0))
    error('chebfun:svd:twoargs',...
          'Use svd(A,0) for SVD of quasimatrix.');
end
if A(1).trans                 % A is a row quasimatrix
    [Q,R] = qr(A',0);
    [V,S,U] = svd(R,0);
    V = Q*V;
else
    [Q,R] = qr(A,0);          % A is a column quasimatrix
    [U,S,V] = svd(R,0);
    U = Q*U;
end
if (nargout==3)
    varargout{1}=U; varargout{2}=S; varargout{3}=V;
elseif (nargout==1 | nargout==0)
    varargout{1}=diag(S);
end

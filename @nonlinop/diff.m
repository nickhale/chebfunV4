function J = diff(N,u)
%DIFF    Jacobian (Frechet derivative) of nonlinear operator.
% J = DIFF(N,U) for a nonlinop N and chebfun U, returns a chebop
% represening the Jacobian (i.e., the Frechet derivative) of N evaluated at
% U. More specifically, J is the operator such that 
%
%   || N(u+delta) - N(u) - J*delta || / ||delta|| -> 0
%
% in the limit ||delta|| -> 0. If U is a quasimatrix and/or N.op is a
% quasimatrix with multiple chebfun columns, then J has a block operator
% structure.
%
% Note that J includes boundary conditions, if any are specified for N.
% Each condition, given in the form g(u)=0, produces a linear boundary
% condition in J in the form g'(u)*delta. The operator g'(u) is assigned
% as a corresponding boundary condition of J (with homogeneous value).
%
% Example: A basic Newton iteration to solve u''-exp(u)=0, subject to
%          u(0)=1, u(1)*u'(1)=1
%
%   [d,x] = domain(0,1);
%   u = 1-x;
%   lbc = @(u) u-1;  rbc = @(u) u.*diff(u)-1;
%   N = nonlinop(d,@(u)diff(u,2)-exp(u),lbc,rbc);
%   for k = 1:6
%     r = N(u);  J = diff(N,u);
%     J.lbc(1) = {J.lbc(1).op, -feval(lbc(u),0)};
%     J.rbc(1) = {J.rbc(1).op, -feval(rbc(u),1)};
%     delta = -J\r;  u = u+delta;
%   end
%   plot(u), title(sprintf('|| residual || = %.3e',norm(N(u))))
%  
% See also chebfun/diff. 

% Copyright 2009 by Toby Driscoll.
% See http://www2.maths.ox.ac.uk/chebfun/ for more on chebfun.

%  Last commit: $Author$: $Rev$:
%  $Date$:

% Functional part
Nu = N.op(u);
J = diff(Nu,u);

% Left BC
if ~isempty(N.lbc)
  if ~iscell(N.lbc), lbc = {N.lbc};   % wrap singleton in cell
  else lbc = N.lbc;
  end
  for j = 1:length(lbc)
    gu = lbc{j}(u);
    J.lbc(j) = diff(gu,u);
  end
end

% Right BC
if ~isempty(N.rbc)
  if ~iscell(N.rbc), rbc = {N.rbc};   % wrap singleton in cell
  else rbc = N.rbc;
  end
  for j = 1:length(rbc)
    gu = rbc{j}(u);
    J.rbc(j) = diff(gu,u);
  end
end

end
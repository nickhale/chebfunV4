function A = subsref(A,s)
%SUBSREF  Extract information from a chebop.
% A{N} returns a realization of the chebop A at dimension N. If N is
% infinite, the functional form of the operator is returned as a function
% handle. If N is finite, any boundary conditions on A will be applied to
% some rows of A. (This is equivalent to the output of FEVAL(A,N,'bc').)
%
% A(I,J) returns a chebop that selects certain rows or columns from the
% finite-dimensional realizations of A. A(1,:) and A(end,:) are examples of
% valid syntax. Normally this syntax is not needed at the user level, but 
% it may be useful for expressing nonseparated boundary conditions, for
% example.
%
% A.bc returns a structure describing the boundary conditions expected for 
% functions in the domain of A. The result has fields 'left' and 'right',
% each of which is itself an array of structs with fields 'op' describing
% the operator on the solution at the boundary and 'val' with the imposed
% value there.
%
% A.scale returns the global scale set for linear system solution, as
% described in the documentation for mldivide.
%
% See also chebop/subsasgn, chebop/feval, chebop/and.

% Copyright 2008 by Toby Driscoll.
% See www.comlab.ox.ac.uk/chebfun.

valid = false;
switch s(1).type
  case '{}'                              
  case '()'                          
    t = s(1).subs;
    if length(t)==2
      % Will return first row, last row, or both only.
      firstrow = t{1}==1;
      lastrow = isinf(t{1}) & real(t{1})==0;
      pts = [];
      if any(firstrow), pts = [pts; A.fundomain(1)]; end
      if any(lastrow), pts = [pts; A.fundomain(2)]; end
      if isequal(t{2},':') && ~isempty(pts)
        mat = subsref(A.varmat,s);
        op = @(u) feval(A*u,pts);
        A = chebop(mat,op,A.fundomain );
        valid = true;
      end
    elseif length(t)==1 && isnumeric(t{1})  % return a realization (feval)
      if A.numbc > 0
        A = feval(A,t{1},'bc');
      else
        A = feval(A,t{1});
      end
      valid = true;
   end
  case '.'
    switch(s(1).subs)
      case 'bc'
        A = getbc(A);
        valid = true;
      case 'scale'
        A = A.scale;
        valid = true;
      case 'numbc'
        A = A.numbc;
        valid = true;            
    end
 end

if ~valid
  error('chebop:subsref:invalid','Invalid reference syntax.')
end

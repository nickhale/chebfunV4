function varargout = domain(f)
% DOMAIN   Domain of definition.
% I = DOMAIN(F) returns the domain of definition of the chebfun F. This
% includes breakpoint information if F is a single chebfun, but not if F is
% a quasimatrix.
% 
% [A,B] = DOMAIN(F) returns the endpoints of the domain as scalars.
%
% See also domain/domain.

% Copyright 2002-2008 by The Chebfun Team. See www.comlab.ox.ac.uk/chebfun.

if numel(f) == 1
    if isempty(f)
        varargout = {domain};
    elseif(nargout<=1)
        varargout{1} = domain(f.ends);
    else
        varargout{1} = f.ends(1);
        varargout{2} = f.ends(end);
    end
elseif nargout <= 1
    % Return interval as a domain without breakpoints.
    varargout = { domain(f(1).ends([1 end])) };
elseif nargout == 2
    varargout{1} = f(1).ends(1);
    varargout{2} = f(1).ends(end);
else
    varargout = {[f(1).ends(1),f(1).ends(end)]};
end

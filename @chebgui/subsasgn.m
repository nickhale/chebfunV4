function varargout = subsasgn(cg,index,varargin)
% SUBSASGN   Modify a chebgui

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Allow calls on the form guifile.options.plotting
idx = index(1).subs;
if size(index,2) > 1 && strcmp(idx1m,'options')
    idx = index(2).subs;
end

vin = varargin{:};
switch index(1).type
    case '.'
        varargout = {set(cg,idx,vin) };
    otherwise
        error('CHEBGUI:subsasgn:indexType',['Unexpected index.type of ' index(1).type]);
end
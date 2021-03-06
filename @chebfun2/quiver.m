function varargout = quiver(f1,f2,varargin)
%QUIVER Quiver plot of a chebfun2.
%
% QUIVER(F,G) plots the vector velocity field of (F,G). QUIVER automatically
% attempts to scale the arrows to fit within the grid. The arrows start
% on a uniform grid. This returns the same plot as QUIVER([F;G]).
%
% QUIVER(F,G,S) automatically scales the arrows to fit within the grid 
% and then stretches them by S. Use S=0 to plot the arrows without the 
% automatic scaling.  The arrows are on a uniform grid.
%
% QUIVER(X,Y,F,G,...) is the same as QUIVER(F,G,...) except the arrows 
% are on the grid given in X and Y.  If X and Y are chebfun2 objects the
% arrows are on the image of the uniform grid of X and Y.
%
% QUIVER(...,'numpts',N) plots arrows on a N by N uniform grid.
%
% QUIVER(...,LINESPEC) uses the plot linestyle specified for
% the velocity vectors.  Any marker in LINESPEC is drawn at the base
% instead of an arrow on the tip.  Use a marker of '.' to specify
% no marker at all.  See PLOT for other possibilities.
%
% H = QUIVER(...) returns a quivergroup handle.
%
% See also CHEBFUN2V/QUIVER.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

numpts = 10; 


if ( isempty(varargin) )
    varargin={};
end


% Number of points to plot
j = 1; argin = {};
while ( ~isempty(varargin) )
    if strcmpi(varargin{1},'numpts')
        numpts = varargin{2};
        varargin(1:2) = [];
    else
        argin{j} = varargin{1};
        varargin(1) = [];
        j = j+1;
    end
end
varargin = argin; 

% There are many different cases to check for:

if ( isa(f1, 'chebfun2') && isa(f2, 'chebfun2') )  % quiver(f,g)
    
    if nargin == 2
        % calls quiver([x;y]) in Chebfun2v
        h = quiver([f1;f2], varargin{:});  % pass on option, if any.
        
    elseif ( nargin == 3 )                          % quiver(f,g,S)
        % third argument should be a stretching parameter, a Chebfun2v or linespec.
        if ( isa(varargin{1}, 'chebfun2v') )        % quiver(x,y,F)
            varargin{2} = {};
            [xx yy] = new_data_locations(f1,f2,numpts);
            h = quiver(xx,yy,varargin{:});   % call chebfun2v/quiver.
        elseif ~isa(varargin{1}, 'chebfun2')         % quiver(x,y,S) or quiver(x,y,'linespec')
            h = quiver([f1;f2], varargin{:});
        else
            error('CHEBFUN2:QUIVER:INPUT','Stretching parameter should not be a chebfun2 object.');
        end
        
    elseif nargin > 3
        
        [xx yy] = new_data_locations(f1,f2,numpts);  % generate new arrow locations.
        
        f3 = varargin{1}; f4 = varargin{2};
        
        if (isa(f3, 'chebfun2') && isa(f4, 'chebfun2') )  % quiver(x,y,f,g,...)
            if any( f1.corners - f3.corners )
                error('CHEBFUN2:QUIVER:DOMAINCHECK','Chebfun2 objects not on the same domain.');
            end
            h = quiver(xx,yy,[f3;f4],varargin{3:end});
        else
            h = quiver(xx,yy,varargin{3:end});   % quiver(f,g,'linespec')
        end
    end
elseif isa(f1,'double') && isa(f2,'double')
    if nargin < 4
        error('CHEBFUN2:QUIVER:NARGIN','Not enough input arguments.');
    end
    f3 = varargin{1}; f4 = varargin{2};
    if (isa(f3, 'chebfun2') && isa(f4, 'chebfun2') )  % quiver(x,y,f,g,...)
        h = quiver(f1,f2,[f3;f4],varargin{3:end});
    else
        error('CHEBFUN2:QUIVER:ONECHEBFUN2','Two chebfun2 object were not passed to quiver.');
    end
else
    error('CHEBFUN2:QUIVER:INPUTS','Data locations not prescribed.');
end

if nargout == 1
    varargout = {h};
end

end



function [xx yy] = new_data_locations(f1,f2,numpts)
% Generate new arrow location if first two inputs are chebfun2 objects. 

% check the chebfun2 objects are on the same domain.
rect = f1.corners; rectcheck = f2.corners;
if ( any(rect - rectcheck) )
    error('CHEBFUN2:QUIVER','Chebfun2 object are not on the same domain.');
end
% mesh 'em up for the quiver arrows.
x = linspace(rect(1),rect(2),numpts);
y = linspace(rect(3),rect(4),numpts);
[xx,yy] = meshgrid(x,y);
xx = feval(f1,xx,yy); yy = feval(f2,xx,yy);    % use chebfun2 to generate data locations.

end
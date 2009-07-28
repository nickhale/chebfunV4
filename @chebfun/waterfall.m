function varargout = waterfall(u,varargin)
%WATERFALL Waterfall plot for quasimatrices.
%
%  WATERFALL(U) or WATERFALL(U,T) where LENGTH(T) = MIN(SIZE(U))
%
%  See http://www.comlab.ox.ac.uk/chebfun for chebfun information.

%  Copyright 2002-2009 by The Chebfun Team. 
%  Last commit: $Author$: $Rev$:
%  $Date$:

numpts = 51;

trans = u(:,1).trans;
if trans
    u = u.';
end
n = min(size(u,2));
t = 1:n;

if nargin > 1 && isnumeric(varargin{1}) && length(varargin{1}) == size(u,2)
    t = varargin{1}; t = t(:);
    varargin = {varargin{2:end}};
end

if length(t)~=n
    error('chebfun:waterfall:szet', ...
        'Length of T should equal the number of quasimatrices in U');
end

if ~isreal(u) || ~all(isreal(t))
    warning('chebfun:waterfall:imaginary',...
        'Imaginary parts of complex T and/or U arguments ignored');
    u = real(u); t = real(t);
end       

% get the data
[data ignored data3] = plotdata([],u,[],numpts);
uu = data{2:end};
xx = repmat(data{1},1,n);
tt = repmat(t,length(xx(:,1)),1);


% mask the NaNs
mm = find(isnan(uu));
uu(mm) = uu(mm+1);

% plot the waterfall
if ~trans
    h = waterfall(xx.',tt.',uu.',varargin{:});
else
    h = waterfall(xx,tt,uu,varargin{:});
end

% hide the jumps
if ~trans
    x = []; y = []; z = [];
    for k = 1:2:2*n
        x = [x ; data3{k}];
        y = [y ; t((k+1)/2)*ones(length(data3{k}),1)];
        z = [z ; data3{k+1}];
    end
    ish = ishold;    hold on
    plot3(x,y,z,'w');
    if ~ish, hold off; end
end
    
if nargout > 0
    varargout{1} = h;
end
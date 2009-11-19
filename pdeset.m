function varargout = pdeset(varargin)
% Set options for pde15s
%
% (At the moment it wont retain inputs as
%   opts = odeset(opts, ...);
% does!)

Names = ['Eps     ' 
         'Plot    '
         'HoldPlot'];
m = size(Names,1);

% initialise
opts = {};
pdeopts = {};

if nargin == 0,
    if nargout == 0
        odeset;
        fprintf('             Eps: [ positive scalar {1e-6} ]\n')
        fprintf('            Plot: [ {on} | off ]\n')
        fprintf('        HoldPlot: [ on | {off} ]\n')
    else
        % Get the ode opts
        opts = odeset;
        % Add empty pde opts
        for j = 1:m
            opts.(strtrim(Names(j,:))) = [];
        end
        varargout{1} = opts;
    end      

    return
end

% Is an odeset / pdeset structure being passed?
if isstruct(varargin{1})
    opts = varargin{1};
    varargin(1) = [];
end

if isfield(opts,'Eps')
    ee = opts.('Eps');
end
if isfield(opts,'Plot')
    doplot = opts.('Plot');
end
if isfield(opts,'Plot')
    dohold = opts.('HoldPlot');
end

% Parse the remaining input
k = 1;
while k < length(varargin)
    if ~any(strcmpi(fieldnames(odeset),varargin{k}))
        if strcmpi(varargin{k},'Plot') || strcmpi(varargin{k},'HoldPlot')
            if ~ischar(varargin{k+1})
                if logical(varargin{k+1})
                    varargin{k+1} = 'on';
                else
                    varargin{k+1} = 'off';
                end
            end
        end
        pdeopts = [pdeopts {varargin{k:k+1}}];
        varargin(k:k+1) = [];
    else
        k = k+2;
    end
end

% Get the ode opts
opts = odeset(varargin{:});

% Add empty pde opts
for j = 1:m
    opts.(strtrim(Names(j,:))) = [];
end
    
% Attach the pde opts
for k = 1:2:length(pdeopts)
    for j = 1:m
        if strcmpi(pdeopts{k},strtrim(Names(j,:)))
            opts.(strtrim(Names(j,:))) = pdeopts{k+1};
            break
        end
        if j ==m 
            error(['Unknown input sequence: ',pdeopts{k},'.'])
        end
    end
end

varargout{1} = opts;
        
    
    
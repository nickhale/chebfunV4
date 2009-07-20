function f = ctor_3(f,ops,ends,n)

% Copyright 2002-2008 by The Chebfun Team. See www.comlab.ox.ac.uk/chebfun/

if length(ends) ~= length(ops)+1
    error(['Unrecognized input sequence: Number of intervals '...
        'do not agree with number of funs'])
end
if length(n) ~= length(ops)
    error(['Unrecognized input sequence: Number of Chebyshev '...
        'poins was not specified for all the funs.'])
end
if any(diff(ends)<0), 
    error(['Vector of endpoints should have increasing values.'])
end
if any(n-round(n))
    error(['Vector with number of Chebyshev points should consist of'...
        ' integers.'])
end

funs = [];
scl = 0;
for i = 1:length(ops)
    op = ops{i};
    switch class(op)
        case 'double'
            error(['Generating fun from a numerical vector. '...
                'Associated number of Chebyshev points is not used.']);
        case 'fun'
            if numel(op) > 1
            error(['A vector of funs cannot be used to construct '...
                ' a chebfun.'])
            end
            error(['Generating fun from another. '...
                'Associated number of Chebyshev points is not used.']);
        case 'char'
            if ~isempty(str2num(op))
                error(['A chebfun cannot be constructed from a string with '...
                    ' numerical values.'])
            end
            a = ends(i); b = ends(i+1);
            op = inline(op);
            vectorcheck(op,[a b]);
            g = fun(op, [a b], n(i));
            funs = [funs g];
            scl = max(scl, g.scl.v);
        case 'function_handle'
            a = ends(i); b = ends(i+1);   
            vectorcheck(op,[a b]);
            g = fun(op, [a b], n(i));
            funs = [funs g];
            scl = max(scl, g.scl.v);
        case 'chebfun'
            a = ends(i); b = ends(i+1); 
            if op.ends(1) > a || op.ends(end) < b
                error('chebfun:c_tor3:domain','chebfun is not defined in the domain')
            end
            g = fun(@(x) feval(op,x), [a b], n(i));
            funs = [funs g];
            scl = max(scl, norm(g.vals,inf));
        case 'cell'
            error(['Unrecognized input sequence: Attempted to use '...
                'more than one cell array to define the chebfun.'])
        case 'chebfun'
            error(['Unrecognized input sequence: Attempted to construct '...
                'a chebfun from another in an inappropriate way.'])
        otherwise
            error(['The input argument of class ' class(op) ...
                'cannot be used to construct a chebfun object.'])
    end
end
switch class(op)
    case 'double', imps(end+1) = op(end);
    case 'fun'   , imps(end+1) = op.vals(end);
end

imps = jumpvals(funs,ends,op); 
f = set(f,'funs',funs,'ends',ends,'imps',imps,'trans',0,'scl',scl);
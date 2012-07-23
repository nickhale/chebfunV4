function Fout = times(F1,F2)
% .*   Chebfun multiplication.
% F.*G multiplies chebfuns F and G or a chebfun by a scalar if either F or G is
% a scalar.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information. 
        
if (isempty(F1) || isempty(F2)), Fout = chebfun; return; end

% Double times chebfun
if isnumeric(F1) || isnumeric(F2)
    [m1 n1] = size(F1);
    [m2 n2] = size(F2);
    if (n1~=n2 && m1~=m2) % Allow pointwise muliplication via scalars and scalar chebfuns
        if all([m2 n2] == 1)     % F2 is a scalar
            for k = 1:n1
                Fout(k) = mtimes(F1(k),F2);
            end
        elseif all([m1 n1] == 1) % F1 is a scalar
            for k = 1:n1
                Fout(k) = mtimes(F1,F2(k));
            end
        else
            error('CHEBFUN:times:quasi','Quasimatrix dimensions must agree.')
        end
    else      % Standard pointwise multiplication (domainesions add up)
        for k = 1:min(max(m1,n1),max(m2,n2))
            Fout(k) = mtimes(F1(k),F2(k));
        end
    end
else 
% Product of two chebfuns
    if any(size(F1)~=size(F2))
        error('CHEBFUN:times:quasi','Quasimatrix dimensions must agree.')
    end
    for k = 1:numel(F1)
        Fout(k) = timescol(F1(k),F2(k));
    end
end

% -------------------------------
function h = timescol(f,g)

%make copies of original f and g in F and G
F = f;
G = g;

funreturn = f.funreturn || g.funreturn;
f.funreturn = 0; g.funreturn = 0;

% product of two chebfuns
[f,g] = overlap(f,g);
ffuns = [];
scl = 0;
for k = 1:length(f.ends)-1
    tmp = f.funs(k).*g.funs(k);
    ffuns = [ffuns tmp];
    scl = max(scl,ffuns(end).scl.v); % update scale variable
end

% Deal with impulse matrix:
%------------------------------------------------
% The variables degf_delta and degg_delta used below denote the order of
% derivative of delta functions in f and g respectively. Note that 
% degf_delta = 0 would mean the zeroth derivative of the delta function
% in f and so on.
degf_delta = find(sum(abs(f.imps), 2) > eps*f.scl, 1, 'last') - 2;
degg_delta = find(sum(abs(g.imps), 2) > eps*g.scl, 1, 'last') - 2;
if(isempty(degg_delta)), degg_delta = -1; end
if(isempty(degf_delta)), degf_delta = -1; end

% if both f and g have deltas at a common point, then the multiplication
% f.*g is undefined

if((degg_delta >= 0) && (degf_delta >= 0) )
    error( 'CHEBFUN:times:Delta functions can not be multiplied with each other' );
end

% if g has delta functions
if( degg_delta >= 0 )
    Hgimps = zeros(size(g.imps));
    for j = degg_delta+2:-1:2
        df = F; % notice that this is not f
        hgimps = zeros(size(g.imps));
        for k = j-2:-1:0
            hgimps(k+2, :) = nchoosek(j-2, k)*((-1)^k)*feval(df, g.ends).*g.imps(j, :);
            df = diff(df);            
        end
        Hgimps = Hgimps + (-1)^(j-2)*hgimps;
    end
    % update imps in the final output
    imps = Hgimps + f.imps;
end

% if f has delta functions
if( degf_delta >= 0 )    
    Hfimps = zeros(size(f.imps));
    for j = degf_delta+2:-1:2
        dg = G; % note that this is not g
        hfimps = zeros(size(f.imps));
        for k = j-2:-1:0
            hfimps(k+2, :) = nchoosek(j-2,k)*((-1)^k)*feval(dg, f.ends).*f.imps(j, :);
            dg = diff(dg);            
        end
        Hfimps = Hfimps + (-1)^(j-2)*hfimps;
    end
    % update imps in the final output
    imps = Hfimps + g.imps;
end

% Update first row of h.imps (function values)
% this seems to be slow:
% imps(1,:) = feval(f,f.ends).*feval(g,g.ends);
% replaced with
tmp = f.imps(1,:).*g.imps(1,:);

tol = 10*f.scl.*chebfunpref('eps');
if any(isinf(tmp))
    for k = 1:length(tmp)
        if isinf(tmp(k)) && (f.imps(1,k)<tol || g.imps(1,k)<tol)
            tmp(k) = NaN;
        end
    end   
end
imps(1,:) = tmp;
    
% % If there are deltas, then function value is + or - inf. (or should it
% be nan in some cases?)
% if size(imps,1)>1
%     for k = 1:f.nfuns+1
%         ind = find(imps(2:end,k),1,'first');
%         if ~isempty(ind)            
%             imps(1,k) = inf*sign(imps(ind+1,k));
%         end
%     end
% end

% update scales in funs:
for k = 1:f.nfuns-1
    funscl = ffuns(k).scl.v;
    ffuns(k).scl.v = scl;      % update scale field
    if  funscl < 10*scl        % if scales are significantly different, simplify!
        ffuns(k) = simplify(ffuns(k));
    end
end

% Set chebfun:
h = f;
% Promote jacobian info for chebconsts
if isa(f,'chebconst') && ~isa(g,'chebconst')
    f.jacobian = anon('[der nonConst] = diff(f,u,''linop''); if ~isnumeric(der), der = promote(der); end',{'f'},{f},1,'promote');
    f.ID = newIDnum();
    h = g;
elseif isa(g,'chebconst') && ~isa(f,'chebconst')
    g.jacobian = anon('[der nonConst] = diff(f,u,''linop''); if ~isnumeric(der),der = promote(der); end',{'f'},{g},1,'promote');
    g.ID = newIDnum();
end

% Set the jacobian
h.jacobian = anon('[Jfu nonConstJfu] = diff(f,u,''linop''); [Jgu nonConstJgu] = diff(g,u,''linop''); der = diag(f)*Jgu + diag(g)*Jfu; nonConst = (nonConstJgu | nonConstJfu) | ((~all(iszero(Jfu)) && ~all(iszero(Jgu))) & (~iszero(Jfu) | ~iszero(Jgu)));',{'f' 'g'},{f g},1,'times');
h.ID = newIDnum();

% Assign the funs, scale, etc
h.funs = ffuns; h.imps = imps; h.scl = scl; h.funreturn = funreturn;
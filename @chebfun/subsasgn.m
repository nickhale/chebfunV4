function varargout = subsasgn(f,index,varargin)
% SUBSASGN   Modify a chebfun.
%     F(I) = G assigns the chebfun G into the interval of the chebfun F specifed 
%     by the domain I. A(I,C) = F assigns the chebfun F to the column C of a 
%     quasi-matrix A.  A colon used as a subscript in the first argument, as in 
%     A(:,C) = F, indicates the entire chebfun column.
%  
%     F(PTS) = VALS assigns the values of vector VALS at locations
%     specified in vector PTS in the chebfun F. length(PTS) should be equal
%     to length(VALS). Subsasgn introduces new break-points in F at points
%     in PTS that were not before in F.ENDS. Similarly, A(PTS,C) = VALS
%     assigns values for specific points PTS of the column C of a
%     quasimatrix A.
%  
%     F{A,B} = G is a wrapper for the command DEFINE(F,[A,B],CHEBFUN(G,[A,B])).
%  
%     F.FIELD = B is a wrapper for the command SET(F,FIELD,B), where FIELD
%     is any of the chebfun fields.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

idx = index(1).subs;
vin = varargin{:};
switch index(1).type
    case '.'
        if length(index) > 2
            tmp = subsref(f,index(1:2));
            vin = subsasgn(tmp,index(3),vin);
            if strcmp(index(3).subs,'vals')
                vin = subsasgn(vin,struct('type','.','subs','n'),numel(vin));
            end
        end
        varargout = {set(f,idx,vin)};
    case '()'
        % --- transpose row chebfuns/quasimatrices -------
        trans = 0;
        if ~isempty(f) && get(f(1),'trans')
            trans = 1;
            f = f.';
            idx = fliplr(idx);
        end
        n = size(f,2);  
        s = idx{1};
        % ---- read input arguments -----------------------------
        if length(idx) == 1  
            % f(s), where s can be vector, domain or ':'
            % syntax is not allowed when f is a quasimatrix
            if n ~= 1
                error('CHEBFUN:subsasgn:dimensions',...
                    'Index missing for quasi-matrix assignment.')
            end
            col = 1;          
        elseif length(idx) == 2
            % f(s,col), where s can be domain, ':' or a vector
            % specifying the assigned columns.
            col = idx{2};
            if ischar(col) && col==':'
                col = 1:n;
            elseif max(col) > n
                % Create an empty chebfun if we're assigning to empty
                if isempty(f), f = chebfun; end
                % Domain check to make sure chebfuns have same domain
                if isempty(f(:,1)) || all(f(:,1).ends([1,end]) == vin(:,1).ends([1,end]))
                    f(:,n+1:max(col)) = repmat(chebfun(0,domain(vin)),1,max(col)-n);     
                else
                    error('CHEBFUN:subsasgn:domain','Inconsistent domains')
                end
                
            end
            
        else
            error('CHEBFUN:subsasgn:dimensions',...
                'Index exceeds chebfun dimensions.')
        end
        fcol = f(:,col);        
        % ---- assign values/chebfuns at given points/domains ---        
%         if isnumeric(s)
%             if ~isa(vin,'numeric')
%                 error('CHEBFUN:subsasgn:conversion',...
%                         ['Conversion to numeric from ',class(vin),...
%                         ' is not possible.'])
%             end
%             if length(vin) == 1
%                vin = vin*ones(length(s),length(col));
%             elseif length(col) == 1 && min(size(vin)) == 1 && ...
%                     length(vin)==length(s)
%                 vin = vin(:);
%             elseif length(s)~=size(vin,1) || length(col)~=size(vin,2)
%                 error('CHEBFUN:subsasgn:dimensions',...
%                         'Subscripted assignment dimension mismatch.')
%             end
%             ends = get(fcol(:,1),'ends'); a = ends(1); b = ends(end);
%             if min(s) < a || max(s) > b
%                 error('CHEBFUN:subsasgn:outbounds',...
%                     'Cannot introduce endpoints outside domain.')
%             end
%             stemp = s;    
%             s = setdiff(s,ends); impsends = zeros(length(col),2);
%             for k = 1:length(col)
%                 impsends(k,:) = fcol(:,k).imps(1,[1 end]);
%             end
%             for i = 1:length(s)
%                 fcol = [restrict(fcol,[a,s(i)]); restrict(fcol,[s(i),b])];
%             end 
%             for k = 1:length(col)
%                 fcol(:,k).imps([1 end]) = impsends(k,:);
%             end
%             for i = 1:length(col)   
%                 [mem,loc] = ismember(stemp,fcol(i).ends);
%                % fcol(:,i).imps(1,loc(find(loc))) = vin(find(mem),i); 
%                 fcol(:,i).imps(1,loc) = vin(mem,i); 
%             end
%         else
            if isa(s,'domain') || isnumeric(s)
            fcol = define(fcol,s,vin);
        elseif isequal(s,':')
            if isempty(fcol)
                fcol = define(fcol,domain(vin),vin);
            else
                %fcol = define(fcol,domain(fcol),vin);
                fcol = restrict(vin,domain(fcol));
            end
        else
            error('CHEBFUN:subsasgn:nonnumeric',...
              'Cannot evaluate chebfun for non-numeric type.')
        end
        % --- assign modified column to original chebfun/quasimatrix --
        % Check orientation
        if fcol(1).trans ~= trans
            error('CHEBFUN:subsasgn:trans','Inconsistent chebfun transpose fields')
        end
        f(:,col) = fcol;
        if trans, f = f.'; end
        varargout = { f };          
    case '{}'
        if length(idx) == 1
            if isequal(idx{1},':')
                s = domain(f); 
            elseif isa(idx{1},'domain')
                s = idx{1};                 
            else
                error('CHEBFUN:subsasgn:baddomain',...
                    'Invalid domain syntax.')
            end
        elseif length(idx) == 2
            s = domain(cat(2,idx{:}));
        else
            error('CHEBFUN:subsasgn:dimensions',...
                'Index exceeds chebfun dimensions.')
        end
        % s should be a domain here
        varargout = { define(f,s,vin) };
    otherwise
        error('CHEBFUN:subsasgn:indextype',['??? Unexpected index.type of ' index(1).type]);
end
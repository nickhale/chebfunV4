function out = roots(g,varargin)
% ROOTS	Roots in the interval [-1,1]
% ROOTS(G) returns the roots of the FUN G in the interval [-1,1].
% ROOTS(G,'all') returns all the roots.
%
% See http://www.maths.ox.ac.uk/chebfun for chebfun information.

% Copyright 2002-2009 by The Chebfun Team. 
% Last commit: $Author: hale $: $Rev: 1217 $:
% $Date: 2010-10-11 11:37:46 +0100 (Mon, 11 Oct 2010) $:

% Default preferences
rootspref = struct('all', 0, 'recurse', 1, 'prune', 0, 'polish', chebfunpref('polishroots'));
emm = -0.004849834917525;

% Filter-out the arguments
if nargin == 2
    if isstruct(varargin{1})
        rootspref = varargin{1};
    else
        rootspref.all = true;
    end
elseif nargin > 2
    rootspref.all = varargin{1};
    rootspref.recurse = varargin{2};
end
if nargin > 3
    rootspref.prune = varargin{3};
end

% Get stuff we'll need for the recursive call
c = flipud(chebpoly(g)) / g.scl.v;
% xpts = g.map.for(chebpts(g.n));
% df = max(diff(xpts),eps*g.scl.h);
% mdiff =  (g.scl.h/g.scl.v)*norm(diff(g.vals)./df,inf);
% tail_max = max(chebfunpref('eps'),eps*min(1e12,mdiff));

% Call the recursive rootsunit function
r = rootsunit_coeffs( c , g.scl.h );

% Prune the roots, if required
if rootspref.prune && ~rootspref.recurse
    rho = sqrt(eps)^(-1/g.n);
    rho_roots = abs(r+sqrt(r.^2-1));
    rho_roots(rho_roots<1) = 1./rho_roots(rho_roots<1);
    out = r(rho_roots<=rho);
else
    out = r;
end

% Map the roots to the correct interval
out = g.map.for(out);

% polish roots?
if rootspref.polish
    step = feval(g,out) ./ feval( diff(g) , out );
    % step = miniclenshaw( c , out ) ./ miniclenshaw( newcoeffs_der(c) , out );
    step( ~isfinite(step) ) = 0;
    out = out - step;
end



    function r = rootsunit_coeffs ( c , h  )
    % Computes the roots of the polynomial given by the coefficients
    % c on the unit interval.

        % Define these as persistent, need to compute only once.
        persistent Tleft Tright;

        % horizontal tolerance
        htol = 100 * h * eps;

        % Simplify the coefficients
        n = length(c);
        % subplot(2,1,1); semilogy(0:n-1,abs(c),'-b',[0;n],[tail_max,tail_max],'-r');
        % subplot(2,1,2); plot(linspace(-1,1,200),miniclenshaw(c,linspace(-1,1,200))); pause;
        % n = find( abs(c) > eps*norm(c,1) , 1 , 'last' );
        tail_max = eps*norm(c,1);
        while (n > 1) && (abs(c(n)) < tail_max), n = n - 1; end;
        
        % Wrap, don't just truncate.
        if n > 1 && n < length(c)
            nn = 2*n - 2;
            for j=n+1:length(c)
                k = abs( mod( j+n-3 , nn ) - n + 2 ) + 1;
                c(k) = c(k) + c(j);
            end
            c = c(1:n);
        end;

        % Trivial case, n == 1
        if ( n == 1 )

            % If the function is zero, then place a root in the middle
            if ( c(1) == 0 )
                r = 0.0;
            else
                r = [];
            end;

        % Trivial case, n == 2
        elseif ( n == 2 )

            % is the root in [-1,1]?
            r = -c(1) / c(2);
            if ( r < -(1+htol) ) || ( r > (1+htol) )
                r = [];
            end;

        % Is n small enough to compute the roots directly?
        elseif ~rootspref.recurse || ( n <= 50 )

            % adjust the coefficients for the colleague matrix
            c_old = c;
            c = -0.5 * c(1:end-1) / c(end);
            c(end-1) = c(end-1) + 0.5;
            oh = 0.5 * ones(length(c)-1,1);

            % Modified colleague matrix:
            A = diag(oh,1)+diag(oh,-1);
            A(end-1,end) = 1;
            A(:,1) = flipud(c);

            % compute roots as eig(A)
            r = eig(A);

            % Clean the roots up a bit
            if ~rootspref.all
            
                % Remove dangling imaginary parts
                mask = abs(imag(r)) < htol;
                r = real( r(mask) );
                % step = miniclenshaw( c_old , r ) ./ miniclenshaw( newcoeffs_der(c_old) , r );
                % step( ~isfinite(step) ) = 0;
                % r = r - step;
                % c_old, [ sort(r) , miniclenshaw( c_old , sort(r) ) ]
                
                % keep roots inside [-1 1]   
                r = sort( r(abs(r) <= 1+2*htol) );
                
                % Correct roots over ends
                if ~isempty(r)
                    r(1) = max(r(1),-1);
                    r(end) = min(r(end),1);
                end

            % Prune?
            elseif rootspref.prune
                rho = sqrt(eps)^(-1/n);
                rho_roots = abs(r+sqrt(r.^2-1));
                rho_roots(rho_roots<1) = 1./rho_roots(rho_roots<1);
                r = r(rho_roots<=rho);
            end
            
        % Can we compute the new coefficients with a cheap matrix-vector?
        elseif ( n <= 513 )

            % Have we assembled the matrices Tleft and Tright?
            if isempty( Tleft )

                % create the coefficients for Tleft using the fft directly.
                x = chebpts(513,[-1,emm]);
                Tleft = ones(513); Tleft(:,2) = x;
                for k=3:513, Tleft(:,k) = 2 * x .* Tleft(:,k-1) - Tleft(:,k-2); end;
                Tleft = [ Tleft(513:-1:2,:) ; Tleft(1:512,:) ];
                Tleft = real( fft( Tleft ) / 512 );
                Tleft = triu( [ 0.5*Tleft(1,:) ; Tleft(2:512,:) ; 0.5*Tleft(513,:) ] );

                % create the coefficients for Tright much in the same way
                x = chebpts(513,[emm,1]);
                Tright = ones(513); Tright(:,2) = x;
                for k=3:513, Tright(:,k) = 2 * x .* Tright(:,k-1) - Tright(:,k-2); end;
                Tright = [ Tright(513:-1:2,:) ; Tright(1:512,:) ];
                Tright = real( fft( Tright ) / 512 );
                Tright = triu( [ 0.5*Tright(1,:) ; Tright(2:512,:) ; 0.5*Tright(513,:) ] );

            end; % isempty(Tleft)

            % compute the new coefficients
            cleft = Tleft(1:n,1:n) * c;
            cright = Tright(1:n,1:n) * c;
            
            % eyeball-norm
            % xx = linspace(-1,1,200)';
            % plot( xx , miniclenshaw(c,xx) , '-b' , ...
            %     (emm-1)/2 + (emm+1)/2*xx , miniclenshaw(cleft,xx) , ':r' , ...
            %     (emm+1)/2 + (1-emm)/2*xx , miniclenshaw(cright,xx) , ':g' );
            % pause;

            % recurse
            r = [ (emm-1)/2 + (emm+1)/2*rootsunit_coeffs( cleft , h/2 )
                  (emm+1)/2 + (1-emm)/2*rootsunit_coeffs( cright , h/2 ) ];

        % Otherwise, split using more traditional methods
        else

            % get the coefficients on the left
            x = chebpts(n,[-1,emm]);
            cleft = miniclenshaw(c,x);
            cleft = [ cleft(n:-1:2) ; cleft(1:n-1) ];
            cleft = real( fft( cleft ) / (n-1) );
            cleft = [ 0.5*cleft(1) ; cleft(2:n-1) ; 0.5*cleft(n) ];

            % get the coefficients on the right
            x = chebpts(n,[emm,1]);
            cright = miniclenshaw(c,x);
            cright = [ cright(n:-1:2) ; cright(1:n-1) ];
            cright = real( fft( cright ) / (n-1) );
            cright = [ 0.5*cright(1) ; cright(2:n-1) ; 0.5*cright(n) ];

            % recurse
            r = [ (emm-1)/2 + (emm+1)/2*rootsunit_coeffs( cleft , h/2 )
                  (emm+1)/2 + (1-emm)/2*rootsunit_coeffs( cright , h/2 ) ];

        end;

    end;


    function v = miniclenshaw ( c , x )
    % A mini clenshaw evaluation

        % init the intermediates
        v = zeros(size(x)); vnp1 = zeros(size(x));
        x2 = 2 * x;

        % evaluate the recurrence
        for k=length(c):-1:1
            vnp2 = vnp1;
            vnp1 = v;
            v = c(k) + x2 .* vnp1 - vnp2;
        end;

        % adjust the final result
        v = v - x .* vnp1;

    end;
    

    function cout = newcoeffs_der(c)
    % C is the coefficients of a chebyshev polynomials (on [-1,1])
    % COUT are the coefficiets of its derivative

        c = flipud(c);
        n = length(c);
        cout = zeros(n+1,1);                % initialize vector {c_r}
        v = [0; 0; 2*(n-1:-1:1)'.*c(1:end-1)]; % temporal vector
        cout(1:2:end) = cumsum(v(1:2:end)); % compute c_{n-2}, c_{n-4},...
        cout(2:2:end) = cumsum(v(2:2:end)); % compute c_{n-3}, c_{n-5},...
        cout(end) = .5*cout(end);           % rectify the value for c_0
        cout = flipud(cout(3:end));

    end;

end

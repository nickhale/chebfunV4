function r = chebpade(f,L,M)

c = poly(prolong(f,L+M+1));
c = rot90([c zeros(1,1:M-L-1)]); % c = [c_{L-M+1} ... c{L+M}]'
row = (L-M+1):L;
col = (0:M-1)';
D = c(row(ones(M,1),:) + col(:,ones(M,1)));
b = [D\c(L+1:L+M); 1];    % b  = [b_M b_{M-1} ... b_2 b_1]'
c([1:M-L M+1:end]) = [];  % c  = [c_0 c_1 c_2 ... c_L]'
bL = flipdim(b,1);        % bL = [    b_1 b_2 ... b_M]'
bL(M+1:L) = zeros(L-M,1); % bL = [    b_1 b_2 ... b_L]'
cb = conv(b,c);
a = c + [0; cb(1:L)]; 
x = chebfun('x',domain(f));
r = polyval(a,x)./polyval(b,x);
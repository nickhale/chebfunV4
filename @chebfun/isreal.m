function isr=isreal(F)
% ISREAL True for real chebfun.
% ISREAL(F) returns logical true if F does not have an imaginary part
% and false otherwise.
%  
% ~ISREAL(F) detects chebfuns that have an imaginary part even if
% it is all zero.
%   
% See also CHEBFUN/REAL, CHEBFUN/IMAG.

%   Copyright 2002-2008 by The Chebfun Team. See www.comlab.ox.ac.uk/chebfun.

isr = true;
for k = 1:numel(F)
    isr = isr && isreal(get(F(k),'vals'));
end
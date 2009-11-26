function f = scribble(s)
%SCRIBBLE  Writing text with chebfuns
%  SCRIBBLE('STRING') returns a complex chebfun representing the text in
%  STRING. At the moment only upper case letters and minimal punctuation is
%  supported.
%
%  Example;
%   f = scribble('The quick brown fox jumped over the lazy dog. 123456789');
%   plot(f), axis equal
%
%  See http://www.comlab.ox.ac.uk/chebfun for chebfun information.

%  Copyright 2002-2009 by The Chebfun Team. 
%  Last commit: $Author$: $Rev$:
%  $Date$:

L = length(s);
f0 = chebfun;
for j = 1:L
   switch upper(s(j))
      case {'A'}, t = c([0 .4+1i .8 .6+.5i .2+.5i]);
      case {'B'}, t = c([0 1i .8+.9i .8+.6i .5i .8+.4i .8+.1i 0]);
      case {'C'}, t = c([.8+1i .8i .2i .8]);
      case {'D'}, t = c([0 .8+.1i .8+.9i 1i 0]);
      case {'E'}, t = c([.8+1i 1i .5i .5i+.7 .5i 0 .8]);
      case {'F'}, t = c([.8+1i 1i .5i .5i+.7 .5i 0]);
      case {'G'}, t = c([.8+1i .8i .2i .6 .6+.5i .4+.5i .8+.5i]);
      case {'H'}, t = c([0 1i .5i .5i+.8 .8+1i .8]);
      case {'I'}, t = c([0 .8 .4 .4+1i 1i .8+1i]);
      case {'J'}, t = c([0 .4 .4+1i 1i .8+1i]);
      case {'K'}, t = c([0 1i .5i .8+1i .5i .8]);
      case {'L'}, t = c([1i 0 .8]);
      case {'M'}, t = c([0 .1+1i .4 .7+1i .8]);
      case {'N'}, t = c([0 1i .8 .8+1i]);
      case {'O'}, t = c([0 1i .8+1i .8 0]);
      case {'Q'}, t = c([0 1i .8+1i .8 .6+.2i .9-.1i .8 0]);
      case {'P'}, t = c([0 1i .8+1i .8+.5i .5i]);
      case {'R'}, t = c([0 1i .8+1i .8+.6i .5i .8]);
      case {'S'}, t = c([.8+1i .9i .6i .8+.4i .8+.1i 0]);
      case {'T'}, t = c([.4 .4+1i 1i .8+1i]);
      case {'U'}, t = c([1i .1 .7 .8+1i]);
      case {'V'}, t = c([1i .4 .8+1i]);
      case {'W'}, t = c([1i .2 .4+1i .6 .8+1i]);
      case {'X'}, t = c([1i .8 .4+.5i .8+1i 0]);
      case {'Y'}, t = c([1i .4+.5i .8+1i .4+.5i .4]);
      case {'Z'}, t = c([1i .8+1i 0 .8]);
      case {'1'}, t = c([0 .8 .4 .4+1i .1+.8i]);
      case {'2'}, t = c([.8 0 .5i .8+.5i .8+1i 1i]);
      case {'3'}, t = c([1i .8+1i .8+.5i .1+.5i .8+.5i .8 0]);
      case {'4'}, t = c([1i .5i .8+.5i .8+1i .8]);
      case {'5'}, t = c([.8+1i 1i .5i .8+.5i .8 0]);          
      case {'6'}, t = c([.8+1i 1i 0 .8 .8+.5i .5i]);  
      case {'7'}, t = c([1i .8+1i .2]);  
      case {'8'}, t = c([1i .8+1i .8 0 .5i 1i .5i .8+.5i]);  
      case {'9'}, t = c([.8 .8+1i 1i .5i .8+.5i]); 
      case {'?'}, 
          t = [c([.6i 1i .8+1i .8+.5i .4+.5i .4+.2i]) ; ...
               c([.35 .45 .45+.05i .35+.05i .35])]; 
      case {'!'}, 
          t = [c([.4+1i .4+.2i]) ; ...
               c([.35 .45 .45+.05i .35+.05i .35])];
      case {'.'}, t = c([0 .05 .05+.05i .05i 0]);
      case {','}, t = c([-0.1-.15i -.05-.15i .1+.05i .05+.05i -.1-.15i]);
      case {' '}, t = [];
      otherwise, 
   end
   if ~isempty(t)
       f0 = [f0; t+(j-1)];
   end
end
f0 = 2*f0/L-1;     % rescale real part of range to [-1,1]
f = chebfun;
f{-1,1} = f0;      % rescale domain to [-1,1]

function cf = c(v)
    cf = chebfun;
    for k = 2:length(v)
       cf = [cf; chebfun(v([k-1 k]),[0 1])];
    end
end

end

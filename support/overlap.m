function [hi, hf, hg, ord] = overlap(fi,gi)
% OVERLAP Overlap of two vectors
% HI = OVERLAP(FI,GI) creates a sorted vector HI with the N non-repeating 
% elements of vectors FI and GI. Notice that FI(1) and FI(end) must be
% equal to GI(1) and GI(end) respectively.
% [HI, HF, HG, ORD] = OVERLAP(FI,GI) also creates the 2xN order matrix 
% ORD such that the interval [HI(i) HI(i+1)] is contained in both 
% [FI(ORD(1,i)) FI(ORD(1,i)+1)] and [GI(ORD(2,i)) GI(ORD(2,i)+1)] and the 
% 2x(N-1) coefficients matrices HF and HG with coefficients to scale each
% interval in FI and GI to an appropriate segment in [-1,1].
%
% Ricardo Pachon and Lloyd N. Trefethen, 2007, Chebfun Version 2.0
if not(isvector(fi))|not(isvector(gi))
    error('Inputs to OVERLAP should be vectors');
end
if fi(1)~=gi(1) & fi(end)~=gi(end)
    error('Domains of the two functions should coincide')
end
hi = unique([fi  gi]);
ord = cumsum([ismember(hi,fi);ismember(hi,gi)],2); 
hf = rescale(hi,fi); hg = rescale(hi,gi);
hf = [hf(1:end-1);hf(2:end)]; hg = [hg(1:end-1);hg(2:end)];
s = find(hf(2,:)==-1); t = find(hg(2,:)==-1);
hf(2,s) = ones(size(s)); hg(2,t) = ones(size(t));
hf(1,:) = .5*diff(hf); hg(1,:) = .5*diff(hg);
hf(2,:) = diff(hf); hg(2,:) = diff(hg);
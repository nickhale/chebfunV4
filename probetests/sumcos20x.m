function pass = sumcos20x

% TAD

f = chebfun('cos(20*x)');
pass = abs(sum(f)-sin(20)/10) < 1e-15;



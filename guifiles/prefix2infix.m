function infixOut = prefix2infix(prefIn)
prefixIn = prefIn; prefCounter = 1; %#ok<NASGU> Disable warning message
infixOut = getInfix();

function infixOut = getInfix()
next = char(prefixIn(prefCounter,2));
if ~isempty(strmatch('OP',next))
    prefCounter = prefCounter + 1;
    exp1 = getInfix();
    exp2 = getInfix();
    % We now return different outputs depending on which operator we have.
    switch next
        case 'OP+'
            infixOut = ['(', exp1, '+', exp2,')'];
        case 'OP-'
            infixOut = ['(', exp1, '-', exp2,')'];
        case 'OP*'
            infixOut = ['(', exp1, '.*', exp2,')'];
        case 'OP/'
            infixOut = ['(', exp1, './', exp2,')'];
        case 'OP^'
            infixOut = ['(', exp1, '.^', exp2,')'];
    end
elseif strcmp(next,'FUNC1')
    nextFun = char(prefixIn(prefCounter,1));
    prefCounter = prefCounter + 1;
    funcArg = getInfix();
    infixOut = [nextFun, '(', funcArg , ')'];
elseif strcmp(next,'FUNC2')
    nextFun = char(prefixIn(prefCounter,1));
    prefCounter = prefCounter + 1;
    funcArg1 = getInfix();
    funcArg2 = getInfix();
    infixOut = [nextFun, '(', funcArg1 , ',', funcArg2 ,  ')'];
elseif strcmp(next(1:end-1),'DER')
    prefCounter = prefCounter + 1;
    derivArg = getInfix();
    infixOut = ['diff(', derivArg , ',' num2str(next(end)) ')'];
elseif ~isempty(strmatch('UN',next))
     nextUnary = char(prefixIn(prefCounter,1));
     prefCounter = prefCounter + 1;
     unaryArg = getInfix();
     infixOut = [nextUnary, unaryArg];
else
    infixOut = char(prefixIn(prefCounter,1));
    prefCounter = prefCounter + 1;
end
end

prefixIn = []; prefCounter = []; % Clear global variables

end
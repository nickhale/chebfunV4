function F = auto(op,ends,n)

% Debugging controls: ---------------------------------------------------
deb1 = 1; % <-  show the iteration level
deb2 = 0; % <-  plot advance of the construction (blue = happy; red = sad)
% ---------------------------------------------------------------------
% Minimum allowed interval length
minlength = 1e-14;
% ---------------------------------------------------------------------

if isa(op,'double')||(isa(op,'char') && ~isempty(str2num(op)))
    f = fun(op,n); % make a fun from a constant or from a data string
    F = chebfun(f,ends);
elseif isa(op,'char')|| isa(op,'function_handle')|| isa(op,'inline')
    % make a fun from a string or from a function handle
    if isa(op,'char'), op = inline(op); end 
    [funs{1},hpy] = grow(op,ends);
    sad = not(hpy);
    count = 0;
    if deb2
        for i = 1:length(sad)
            xx = linspace(ends(i),ends(i+1),200);
            if sad(i)
                plot(xx,op(xx),'r');
            else 
                plot(xx,op(xx),'b');
            end
        end
        set(gca,'xgrid','on','xtick',ends,'fontsize',8)
        drawnow;
        %pause();
    end
    while any(sad)
        count = count + 1;
        if deb1
            disp(['level -> ',num2str(count)]);
        end
        i = find(sad);
        for i = i(end:-1:1)
            mdpt = mean(ends(i:i+1)); 
            tpdm = mdpt;
            if diff(ends(i:i+1)) < minlength
                ends(i) = mdpt; ends(i+1) = [];
                mdpt = [];
                child1 = {}; hpy1 = [];
                child2 = {}; hpy2 = [];
            else
                [child1,hpy1] = grow(op,[ends(i) mdpt]);
                [child2,hpy2] = grow(op,[mdpt, ends(i+1)]);
                child1 = {child1};
                child2 = {child2};
            
                if hpy1 && (i > 1) && not(sad(i-1))
                    [f,merged] = grow(op,[ends(i-1),mdpt]);
                    if merged
                        funs{i-1} = f; child1 = {};
                        ends(i) = mdpt; mdpt = [];
                        hpy1 = [];
                    end
                end
                if hpy2 && (i < length(sad)) && not(sad(i+1))
                    [f,merged] = grow(op,[tpdm,ends(i+2)]);
                    if merged
                        funs{i+1} = f; child2 = {};
                        if isempty(mdpt)
                            ends(i+1) = [];
                        else
                            ends(i+1) = mdpt; mdpt = [];
                        end
                        hpy2 = [];
                    end
                end
            end
            funs = [funs(1:i-1);child1;child2;funs(i+1:end)];
            ends = [ends(1:i) mdpt ends(i+1:end)];
            sad  = [sad(1:i-1) not(hpy1) not(hpy2) sad(i+1:end)];
            if deb2
                %disp(sad)
                %disp(ends')
                %disp(funs)
                hold off;
                for i = 1:length(sad)
                    xx = linspace(ends(i),ends(i+1),200);
                    if sad(i)
                        plot(xx,op(xx),'r');
                    else
                        plot(xx,op(xx),'b');
                    end
                    hold on;
                end
                set(gca,'xgrid','on','xtick',ends,'fontsize',8)
                drawnow;
                hold off;
                %pause();
            end
        end
    end
    F = chebfun(funs,ends);
end
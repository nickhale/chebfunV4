function plot(an)
% PLOT Plot the AD tree of an anon

% Obtain the anon tree of the input anon
at = anon2tree(an,'ans');

% Starting values for plotting
startx = .5;
deltax = .25;

% Layout the tree. The returned tree will store information about where
% it's supposed to be plotted. xy and str are used to display data boxes
% when the plot is clicked.
[at xy str] = layoutNodes(at,startx,deltax,at.height+1,at.height+1);
% 

% Create a figure, and plot the first node
fig = figure;
plot(at.x,at.y,'bo'); hold on

% Turn on datacursormode to make the plot clickable
h = datacursormode(fig);

% Set the update function, using the nested function below.
set(h,'UpdateFcn',@textfun,'SnapToDataVertex','on');

% Update function for the clicking of the plot
function txt = textfun(obj,event_obj)
    % Display 'Time' and 'Amplitude'
    pos = get(event_obj,'Position');
    
    % Find index of text to be display
    findLoc = find(((pos(1) == xy(:,1)) & (pos(2) == xy(:,2))) == 1);  
    txt = str{findLoc};
    
    % Get rid of the hyperlink from the txt string. If there is a
    % hyperlink, we know it's preceded by a % sign
    perc_sign_loc = strfind(txt,'%');
    % and it finishes at the end of the first line
    if ~isempty(perc_sign_loc)
        first_newline = min(strfind(txt,sprintf('\n')));
        txt(perc_sign_loc:first_newline-1) = [];
    end
end



plottree(at,h);

datacursormode on

xlim([0 1])
ylim([0 1])
hold off
end


function [tree xy str] = layoutNodes(tree,treex,deltax,currheight,maxheight)

tree.y = (currheight/(maxheight+1));
tree.x = treex;
xy = [tree.x tree.y];
str = tree.info;

% Lay out nodes recursively
switch tree.numleaves
    case 0
        % Do nothing        
    case 1
        [tree.center xyc strc] = layoutNodes(tree.center,treex,deltax,currheight-1,maxheight);
        xy = [xy;xyc];
        str = [str;strc];
    case 2
        [tree.left   xyl strl]  = layoutNodes(tree.left,treex-deltax,deltax/2,currheight-1,maxheight);
        [tree.right  xyr strr]  = layoutNodes(tree.right,treex+deltax,deltax/2,currheight-1,maxheight);
        xy = [xy;xyl;xyr];
        str = [str;strl;strr];
    case 3
        deltax = deltax / 2;
        [tree.left   xyl strl]  = layoutNodes(tree.left,treex-deltax,deltax/2,currheight-1,maxheight);
        [tree.center xyc strc] = layoutNodes(tree.center,treex,deltax/2,currheight-1,maxheight);
        [tree.right  xyr strr]  = layoutNodes(tree.right,treex+deltax,deltax/2,currheight-1,maxheight);
        xy = [xy;xyl;xyc;xyr];
        str = [str;strl;strc;strr];
end
end

function plottree(at,h)

switch at.numleaves
    case 0
        % Do nothing
    case 1
        plot(at.center.x,at.center.y,'bo');
        plot([at.x at.center.x],[at.y at.center.y],'b-')
        plottree(at.center,h)
    case 2
        plot(at.left.x,at.left.y,'bo');
        plot([at.x at.left.x],[at.y at.left.y],'b-')
        plottree(at.left,h)
        plot(at.right.x,at.right.y,'bo');
        plot([at.x at.right.x],[at.y at.right.y],'b-')
        plottree(at.right,h)
        
        % Here we could do some adjustments if we're not using the full
        % width. Store minx, maxx?
    case 3
        plot(h,at.left.x,at.left.y,'bo');
        plot([at.x at.left.x],[at.y at.left.y],'b-')
        plottree(at.left,h)
        plot(h,at.center.x,at.center.y,'bo');
        plot([at.x at.center.x],[at.y at.center.y],'b-')
        plottree(at.center,h)
        plot(h,at.right.x,at.right.y,'bo');
        plot([at.x at.right.x],[at.y at.right.y],'b-')
        plottree(at.right,h)
end
text(at.x+0.02,at.y-0.01,at.parent,'Interpreter','none')
end



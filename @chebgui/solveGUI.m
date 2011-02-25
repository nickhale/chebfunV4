function handles = solveGUI(guifile,handles)
% SOLVEGUI Called when a user hits the solve button of the chebfun GUI

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Check whether some input is missing
if isempty(guifile.DomLeft) || isempty(guifile.DomRight)
    errordlg('The endpoints of the domain must be defined.', 'Chebgui error', 'modal');
    resetComponents(handles);
    return
end
if isempty(guifile.DE)
    errordlg('The differential equation and its right-hand side can not be empty.', 'Chebgui error', 'modal');
    resetComponents(handles);
    return
end
if isempty(guifile.LBC) && isempty(guifile.RBC)
    errordlg('Boundary conditions must be defined.', 'Chebgui error', 'modal');
    resetComponents(handles);
    return
end

if strcmp(get(handles.button_solve,'string'),'Solve')   % In solve mode
    
    % Some basic checking of the inputs.
    a = str2num(guifile.DomLeft);
    b = str2num(guifile.DomRight);
    if b <= a
        s = sprintf('Error in constructing domain. [%s,%s] is not valid.',guifile.DomLeft,guifile.DomRight);
        errordlg(s, 'Chebgui error', 'modal');
        return
    end
    if strcmpi(guifile.type,'pde');
        tt = str2num(guifile.timedomain);
        if isempty(tt)
            s = sprintf('Error in constructing time interval.');
            errordlg(s, 'Chebgui error', 'modal');
        return
        end
        if isempty(guifile.init)
            s = sprintf('Initial condition is empty.');
            errordlg(s, 'Chebgui error', 'modal');
        return
        end
    end
    tol = guifile.tol;
    if ~isempty(tol)
        tolnum = str2num(tol);
        if isnan(tolnum) || isinf(tolnum) || isempty(tolnum)
            s = sprintf('Invalid tolerance, ''%s''.',tol);
            errordlg(s, 'Chebgui error', 'modal');
            return
        end
    end   
    if get(handles.button_eig,'Value')
        newString = handles.guifile.sigma;
    end
    
    % Disable buttons, figures, etc.
    set(handles.toggle_useLatest,'Enable','off');
    set(handles.button_figsol,'Enable','off');
    set(handles.button_fignorm,'Enable','off');
    if ~get(handles.button_eig,'Value') % STOP and PAUSE don't work in EIGS mode.
        % Pause button
    %     set(handles.button_clear,'Enable','off');
        set(handles.button_clear,'String','Pause');
        set(handles.button_clear,'BackgroundColor',[255 179 0]/256);
        % Stop button
        set(handles.button_solve,'String','Stop');
        set(handles.button_solve,'BackgroundColor',[214 80 80]/256);
    end
    drawnow
    set(handles.menu_demos,'Enable','off');
    % Call the private method solveguibvp, pde, or eig which do the work
    try
        if strcmpi(handles.guifile.type,'bvp')
            handles = solveguibvp(guifile,handles);
        elseif strcmpi(handles.guifile.type,'pde')
            handles = solveguipde(guifile,handles);
        else
            handles = solveguieig(guifile,handles);            
        end
    catch ME
        MEID = ME.identifier;
        errordlg(ME.message, 'Chebgui error', 'modal');
        if ~isempty(strfind(MEID,'Parse:')) || ~isempty(strfind(MEID,'LINOP:')) ...
                ||~isempty(strfind(MEID,'Lexer:')) || ~isempty(strfind(MEID,'Chebgui:'))
            errordlg(ME.message, 'Chebgui error', 'modal');
        elseif strcmp(MEID,'CHEBOP:solve:findguess:DivisionByZeroChebfun')
            errordlg(['Error in constructing initial guess. The the zero '...
                'function on the domain is not a permitted initial guess '...
                'as it causes division by zero. Please assign an initial '...
                'guess using the initial guess field.'], 'Chebgui error', 'modal');
        else
            resetComponents(handles);
            rethrow(ME);
        end
    end
    resetComponents(handles);
else   % In stop mode
    set(handles.button_clear,'String','Clear all');
    set(handles.button_clear,'BackgroundColor',0.701960784313725*[1 1 1]);
    set(handles.button_solve,'String','Solve');
    set(handles.button_solve,'BackgroundColor',[43 129 86]/256);
    set(handles.menu_demos,'Enable','on');
    drawnow
end


function resetComponents(handles)
% Enable buttons, figures, etc. Set button to 'solve' again
set(handles.button_solve,'String','Solve');
set(handles.button_solve,'BackgroundColor',[43 129 86]/256);
set(handles.button_clear,'String','Clear all');
set(handles.button_clear,'BackgroundColor',0.701960784313725*[1 1 1]);
set(handles.toggle_useLatest,'Enable','on');
set(handles.button_figsol,'Enable','on');
set(handles.button_fignorm,'Enable','on');
set(handles.menu_demos,'Enable','on');
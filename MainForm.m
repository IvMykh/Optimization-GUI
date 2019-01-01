function varargout = MainForm(varargin)
% MAINFORM MATLAB code for MainForm.fig
%      MAINFORM, by itself, creates a new MAINFORM or raises the existing
%      singleton*.
%
%      H = MAINFORM returns the handle to a new MAINFORM or the handle to
%      the existing singleton*.
%
%      MAINFORM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINFORM.M with the given input arguments.
%
%      MAINFORM('Property','Value',...) creates a new MAINFORM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MainForm_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MainForm_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MainForm

% Last Modified by GUIDE v2.5 01-Jan-2019 12:33:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MainForm_OpeningFcn, ...
                   'gui_OutputFcn',  @MainForm_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before MainForm is made visible.
function MainForm_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MainForm (see VARARGIN)

% Choose default command line output for MainForm
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MainForm wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MainForm_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in computeBtn.
function computeBtn_Callback(hObject, eventdata, handles)
% hObject    handle to computeBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    clc;
    tic;

    approxMethod = 'constant';
    approxStr = get(get(handles.approxButtonGroup,'SelectedObject'),'String');
    if strcmp(approxStr, 'Linear')
        approxMethod  = 'linear';
    end

    jStr = get(get(handles.modeluBg,'SelectedObject'),'String');
    
    j = 1;
    uFun = @(x) eval(get(handles.rTb,'String'));
    switch jStr
        case 'r(x)='
            j = 1;
            uFun = @(x) eval(get(handles.rTb,'String'));
        case 'g1(x)='
            j = 2;
            uFun = @(x) eval(get(handles.g1Tb,'String'));
        case 'g3(x)='
            j = 3;
            uFun = @(x) eval(get(handles.g3Tb,'String'));
        case 'fu(x)='
            j = 4;
            uFun = @(x) eval(get(handles.fuTb,'String'));
    end

    theX0 = str2num(get(handles.x0Tb,'String'));
    theXe = str2num(get(handles.xeTb,'String'));
    
    n = str2num(get(handles.nTb,'String'));
    xs = linspace(theX0, theXe, n);
    b0 = arrayfun(uFun, xs);

    method = get(get(handles.methodBtnGroup,'SelectedObject'),'String');
    
    q = GeneralProblem(b0, approxMethod, j);
    if strcmp(method,"FDM")
        q = FiniteDifferences(b0, approxMethod, j);
    elseif strcmp(method,"DDM")
        q = DirectDiff(b0, approxMethod, j);
    elseif strcmp(method,"AM")
        q = Adjoint(b0, approxMethod, j);
    end

    q.x0 = theX0;
    q.xE = theXe;
    
    q.gammaY = str2num(get(handles.gammaYTb,'String'));
    q.gammaU = str2num(get(handles.gammaUTb,'String'));

    q.uMin = str2num(get(handles.uMinTb,'String'));
    q.uMax = str2num(get(handles.uMaxTb,'String'));

    x0Bc = get(get(handles.x0ButtonGroup,'SelectedObject'),'String');
    xeBc = get(get(handles.xeButtonGroup,'SelectedObject'),'String');

    q.p = [str2num(get(handles.p1Tb,'String')),...
           str2num(get(handles.p2Tb,'String'))];

    q.k = str2num(get(handles.kTb,'String'));

    if (strcmp(x0Bc,'Dirichlet') && strcmp(xeBc,'Dirichlet'))
        q.bcType = [Helper.Dirichlet; Helper.Dirichlet];
    elseif (strcmp(x0Bc,'Dirichlet') && strcmp(xeBc,'Neumann'))
        q.bcType = [Helper.Dirichlet; Helper.Neumann];
    elseif (strcmp(x0Bc,'Neumann') && strcmp(xeBc,'Dirichlet'))
        q.bcType = [Helper.Neumann; Helper.Dirichlet];
    elseif (strcmp(x0Bc,'Neumann') && strcmp(xeBc,'Neumann'))
        q.bcType = [Helper.Neumann; Helper.Neumann];
    end

    % Model functions.
    q.r  = @(x) eval(get(handles.rTb,'String'));
    q.g1 = @(x) eval(get(handles.g1Tb,'String'));
    q.g3 = @(x) eval(get(handles.g3Tb,'String'));
    q.f0 = @(x) eval(get(handles.f0Tb,'String'));
    q.fu = @(x) eval(get(handles.fuTb,'String'));

    q.d = [str2num(get(handles.x0BcValue,'String')), ...
           str2num(get(handles.xeBcValue,'String'))];

    psi1Constr = get(handles.psi1ConstraintCb,'Value');
    
    q.replaceU();
    q.initConstraints();
    
    disp('Optimization: computation started ...');
    q.optimize(psi1Constr, true);
    disp('Optimization: computation finished!');
    %q.direct()
    q.b
    q.criteria()
    q.constraint()
    toc;

    plotResults(q, 'OPTIMIZATION RESULT')
catch err
   f = msgbox(getReport(err)); 
end



function xeBcValue_Callback(hObject, eventdata, handles)
% hObject    handle to xeBcValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xeBcValue as text
%        str2double(get(hObject,'String')) returns contents of xeBcValue as a double


% --- Executes during object creation, after setting all properties.
function xeBcValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xeBcValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function x0BcValue_Callback(hObject, eventdata, handles)
% hObject    handle to x0BcValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of x0BcValue as text
%        str2double(get(hObject,'String')) returns contents of x0BcValue as a double


% --- Executes during object creation, after setting all properties.
function x0BcValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x0BcValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in psi1ConstraintCb.
function psi1ConstraintCb_Callback(hObject, eventdata, handles)
% hObject    handle to psi1ConstraintCb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of psi1ConstraintCb



function g1Tb_Callback(hObject, eventdata, handles)
% hObject    handle to g1Tb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of g1Tb as text
%        str2double(get(hObject,'String')) returns contents of g1Tb as a double


% --- Executes during object creation, after setting all properties.
function g1Tb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to g1Tb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function g3Tb_Callback(hObject, eventdata, handles)
% hObject    handle to g3Tb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of g3Tb as text
%        str2double(get(hObject,'String')) returns contents of g3Tb as a double


% --- Executes during object creation, after setting all properties.
function g3Tb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to g3Tb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function f0Tb_Callback(hObject, eventdata, handles)
% hObject    handle to f0Tb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of f0Tb as text
%        str2double(get(hObject,'String')) returns contents of f0Tb as a double


% --- Executes during object creation, after setting all properties.
function f0Tb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f0Tb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fuTb_Callback(hObject, eventdata, handles)
% hObject    handle to fuTb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fuTb as text
%        str2double(get(hObject,'String')) returns contents of fuTb as a double


% --- Executes during object creation, after setting all properties.
function fuTb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fuTb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function uMinTb_Callback(hObject, eventdata, handles)
% hObject    handle to uMinTb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uMinTb as text
%        str2double(get(hObject,'String')) returns contents of uMinTb as a double


% --- Executes during object creation, after setting all properties.
function uMinTb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uMinTb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function uMaxTb_Callback(hObject, eventdata, handles)
% hObject    handle to uMaxTb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uMaxTb as text
%        str2double(get(hObject,'String')) returns contents of uMaxTb as a double


% --- Executes during object creation, after setting all properties.
function uMaxTb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uMaxTb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gammaYTb_Callback(hObject, eventdata, handles)
% hObject    handle to gammaYTb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gammaYTb as text
%        str2double(get(hObject,'String')) returns contents of gammaYTb as a double


% --- Executes during object creation, after setting all properties.
function gammaYTb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gammaYTb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gammaUTb_Callback(hObject, eventdata, handles)
% hObject    handle to gammaUTb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gammaUTb as text
%        str2double(get(hObject,'String')) returns contents of gammaUTb as a double


% --- Executes during object creation, after setting all properties.
function gammaUTb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gammaUTb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
%question = questdlg('Are you sure?','Question')
%if strcmp(question,'Yes')
    delete(hObject);
%end



function x0Tb_Callback(hObject, eventdata, handles)
% hObject    handle to x0Tb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of x0Tb as text
%        str2double(get(hObject,'String')) returns contents of x0Tb as a double


% --- Executes during object creation, after setting all properties.
function x0Tb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x0Tb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xeTb_Callback(hObject, eventdata, handles)
% hObject    handle to xeTb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xeTb as text
%        str2double(get(hObject,'String')) returns contents of xeTb as a double


% --- Executes during object creation, after setting all properties.
function xeTb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xeTb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function p1Tb_Callback(hObject, eventdata, handles)
% hObject    handle to p1Tb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of p1Tb as text
%        str2double(get(hObject,'String')) returns contents of p1Tb as a double


% --- Executes during object creation, after setting all properties.
function p1Tb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to p1Tb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function p2Tb_Callback(hObject, eventdata, handles)
% hObject    handle to p2Tb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of p2Tb as text
%        str2double(get(hObject,'String')) returns contents of p2Tb as a double


% --- Executes during object creation, after setting all properties.
function p2Tb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to p2Tb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function kTb_Callback(hObject, eventdata, handles)
% hObject    handle to kTb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of kTb as text
%        str2double(get(hObject,'String')) returns contents of kTb as a double


% --- Executes during object creation, after setting all properties.
function kTb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to kTb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ydTb_Callback(hObject, eventdata, handles)
% hObject    handle to ydTb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ydTb as text
%        str2double(get(hObject,'String')) returns contents of ydTb as a double


% --- Executes during object creation, after setting all properties.
function ydTb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ydTb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yMaxTb_Callback(hObject, eventdata, handles)
% hObject    handle to yMaxTb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yMaxTb as text
%        str2double(get(hObject,'String')) returns contents of yMaxTb as a double


% --- Executes during object creation, after setting all properties.
function yMaxTb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yMaxTb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rTb_Callback(hObject, eventdata, handles)
% hObject    handle to rTb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rTb as text
%        str2double(get(hObject,'String')) returns contents of rTb as a double


% --- Executes during object creation, after setting all properties.
function rTb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rTb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nTb_Callback(hObject, eventdata, handles)
% hObject    handle to nTb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nTb as text
%        str2double(get(hObject,'String')) returns contents of nTb as a double


% --- Executes during object creation, after setting all properties.
function nTb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nTb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ruRb.
function ruRb_Callback(hObject, eventdata, handles)
% hObject    handle to ruRb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ruRb


% --- Executes on button press in g1uRb.
function g1uRb_Callback(hObject, eventdata, handles)
% hObject    handle to g1uRb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of g1uRb


% --- Executes on button press in g3uRb.
function g3uRb_Callback(hObject, eventdata, handles)
% hObject    handle to g3uRb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of g3uRb


% --- Executes on button press in f0uRb.
function f0uRb_Callback(hObject, eventdata, handles)
% hObject    handle to f0uRb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of f0uRb


% --- Executes on button press in fuuRb.
function fuuRb_Callback(hObject, eventdata, handles)
% hObject    handle to fuuRb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fuuRb



function edit24_Callback(hObject, eventdata, handles)
% hObject    handle to g1Tb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of g1Tb as text
%        str2double(get(hObject,'String')) returns contents of g1Tb as a double


% --- Executes during object creation, after setting all properties.
function edit24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to g1Tb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit25_Callback(hObject, eventdata, handles)
% hObject    handle to g3Tb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of g3Tb as text
%        str2double(get(hObject,'String')) returns contents of g3Tb as a double


% --- Executes during object creation, after setting all properties.
function edit25_CreateFcn(hObject, eventdata, handles)
% hObject    handle to g3Tb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit26_Callback(hObject, eventdata, handles)
% hObject    handle to f0Tb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of f0Tb as text
%        str2double(get(hObject,'String')) returns contents of f0Tb as a double


% --- Executes during object creation, after setting all properties.
function edit26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f0Tb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit27_Callback(hObject, eventdata, handles)
% hObject    handle to fuTb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fuTb as text
%        str2double(get(hObject,'String')) returns contents of fuTb as a double


% --- Executes during object creation, after setting all properties.
function edit27_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fuTb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit28_Callback(hObject, eventdata, handles)
% hObject    handle to rTb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rTb as text
%        str2double(get(hObject,'String')) returns contents of rTb as a double


% --- Executes during object creation, after setting all properties.
function edit28_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rTb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in solveDirectBtn.
function solveDirectBtn_Callback(hObject, eventdata, handles)
% hObject    handle to solveDirectBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    clc;
    tic;
    
    approxMethod = 'constant';
    approxStr = get(get(handles.approxButtonGroup,'SelectedObject'),'String');
    if strcmp(approxStr, 'Linear')
        approxMethod  = 'linear';
    end

    jStr = get(get(handles.modeluBg,'SelectedObject'),'String');
    
    j = 1;
    uFun = @(x) eval(get(handles.rTb,'String'));
    switch jStr
        case 'r(x)='
            j = 1;
            uFun = @(x) eval(get(handles.rTb,'String'));
        case 'g1(x)='
            j = 2;
            uFun = @(x) eval(get(handles.g1Tb,'String'));
        case 'g3(x)='
            j = 3;
            uFun = @(x) eval(get(handles.g3Tb,'String'));
        case 'fu(x)='
            j = 4;
            uFun = @(x) eval(get(handles.fuTb,'String'));
    end

    theX0 = str2num(get(handles.x0Tb,'String'));
    theXe = str2num(get(handles.xeTb,'String'));
    
    n = str2num(get(handles.nTb,'String'));
    xs = linspace(theX0, theXe, n);
    b0 = arrayfun(uFun, xs);

    method = get(get(handles.methodBtnGroup,'SelectedObject'),'String');
    
    q = GeneralProblem(b0, approxMethod, j);
    if strcmp(method,"FDM")
        q = FiniteDifferences(b0, approxMethod, j);
    elseif strcmp(method,"DDM")
        q = DirectDiff(b0, approxMethod, j);
    elseif strcmp(method,"AM")
        q = Adjoint(b0, approxMethod, j);
    end

    q.x0 = theX0;
    q.xE = theXe;
    
    q.gammaY = str2num(get(handles.gammaYTb,'String'));
    q.gammaU = str2num(get(handles.gammaUTb,'String'));

    q.uMin = str2num(get(handles.uMinTb,'String'));
    q.uMax = str2num(get(handles.uMaxTb,'String'));

    x0Bc = get(get(handles.x0ButtonGroup,'SelectedObject'),'String');
    xeBc = get(get(handles.xeButtonGroup,'SelectedObject'),'String');

    q.p = [str2num(get(handles.p1Tb,'String')),...
           str2num(get(handles.p2Tb,'String'))];

    q.k = str2num(get(handles.kTb,'String'));

    if (strcmp(x0Bc,'Dirichlet') && strcmp(xeBc,'Dirichlet'))
        q.bcType = [Helper.Dirichlet; Helper.Dirichlet];
    elseif (strcmp(x0Bc,'Dirichlet') && strcmp(xeBc,'Neumann'))
        q.bcType = [Helper.Dirichlet; Helper.Neumann];
    elseif (strcmp(x0Bc,'Neumann') && strcmp(xeBc,'Dirichlet'))
        q.bcType = [Helper.Neumann; Helper.Dirichlet];
    elseif (strcmp(x0Bc,'Neumann') && strcmp(xeBc,'Neumann'))
        q.bcType = [Helper.Neumann; Helper.Neumann];
    end

    % Model functions.
    q.r  = @(x) eval(get(handles.rTb,'String'));
    q.g1 = @(x) eval(get(handles.g1Tb,'String'));
    q.g3 = @(x) eval(get(handles.g3Tb,'String'));
    q.f0 = @(x) eval(get(handles.f0Tb,'String'));
    q.fu = @(x) eval(get(handles.fuTb,'String'));

    q.d = [str2num(get(handles.x0BcValue,'String')), ...
           str2num(get(handles.xeBcValue,'String'))];

    psi1Constr = get(handles.psi1ConstraintCb,'Value');
    
    q.replaceU();
    q.initConstraints();
    
    disp('Direct problem: computation started ...');
    q.direct();
    disp('Direct problem: computation finished!');
    theB = q.b;
    theCrit = q.criteria();
    theConstr = q.constraint();
    
    myString = sprintf('b = %s\nPsi0 = %f\nPsi1 = %f', mat2str(theB), theCrit, theConstr);
    set(handles.directProblemText, 'String', myString);
    
    toc;
catch err
   f = msgbox(getReport(err)); 
end
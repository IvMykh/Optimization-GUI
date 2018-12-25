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

% Last Modified by GUIDE v2.5 25-Dec-2018 12:45:32

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
clc;

tic;
b0 = [
    1 
    1
 ];

method = get(get(handles.methodBtnGroup,'SelectedObject'),'String');

if strcmp(method,"FDM")
    q = FiniteDifferences(b0);
elseif strcmp(method,"DDM")
    q = DirectDiff(b0);
elseif strcmp(method,"AM")
    q = Adjoint(b0);
else
    q = GeneralProblem(b0);
end

% FiniteDifferences
% Adjoint
% DirectDiff
%q = GeneralProblem(b0);

x0Bc = get(get(handles.x0ButtonGroup,'SelectedObject'),'String');
xeBc = get(get(handles.xeButtonGroup,'SelectedObject'),'String');

if (strcmp(x0Bc,'Dirichlet') && strcmp(xeBc,'Dirichlet'))
    q.bcType = [Helper.Dirichlet; Helper.Dirichlet]
elseif (strcmp(x0Bc,'Dirichlet') && strcmp(xeBc,'Neumann'))
    q.bcType = [Helper.Dirichlet; Helper.Neumann]
elseif (strcmp(x0Bc,'Neumann') && strcmp(xeBc,'Dirichlet'))
    q.bcType = [Helper.Neumann; Helper.Dirichlet]
elseif (strcmp(x0Bc,'Neumann') && strcmp(xeBc,'Neumann'))
    q.bcType = [Helper.Neumann; Helper.Neumann]
end

q.d = [str2num(get(handles.x0BcValue,'String')), ...
       str2num(get(handles.xeBcValue,'String'))];

psi1Constr = get(handles.psi1ConstraintCb,'Value');
   
q.optimize(psi1Constr, true);
%q.direct()
q.b
q.criteria()
q.constraint()
toc;

plotResults(q, 'Title')



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

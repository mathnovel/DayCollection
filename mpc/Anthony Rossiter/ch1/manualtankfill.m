function varargout = manualtankfill(varargin)
% MANUALTANKFILL MATLAB code for manualtankfill.fig
%      MANUALTANKFILL, by itself, creates a new MANUALTANKFILL or raises the existing
%      singleton*.
%
%      H = MANUALTANKFILL returns the handle to a new MANUALTANKFILL or the handle to
%      the existing singleton*.
%
%      MANUALTANKFILL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MANUALTANKFILL.M with the given input arguments.
%
%      MANUALTANKFILL('Property','Value',...) creates a new MANUALTANKFILL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before manualtankfill_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to manualtankfill_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help manualtankfill

% Last Modified by GUIDE v2.5 29-Nov-2013 09:59:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @manualtankfill_OpeningFcn, ...
                   'gui_OutputFcn',  @manualtankfill_OutputFcn, ...
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


% --- Executes just before manualtankfill is made visible.
function manualtankfill_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to manualtankfill (see VARARGIN)

% Choose default command line output for manualtankfill
handles.output = hObject;
handles.cont=1;
handles.depth=0;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes manualtankfill wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%%%% Create tank object
axes(handles.axes1);
plot([0 0 1 1],[2 0 0 2],'k','linewidth',3);
xlim([-0.2,1.2]);
ylim([-0.2,2.2]);
set(handles.axes1,'xticklabel',{});
set(handles.axes1,'yticklabel',{});
hold on
plot([-0.1,1.1],[1.8 1.8],'r--','linewidth',2);


% --- Outputs from this function are returned to the command line.
function varargout = manualtankfill_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cont=1;
axes(handles.axes1);
depth=handles.depth;
b=fill([0 0 1 1],[depth 0 0 depth],'b');
set(handles.slider1,'value',1);
while cont==1;
    flow=get(handles.slider1,'value');
    depth=depth+flow/20;
    set(b,'Ydata',[depth,0,0,depth]);
    pause(0.1);
    if depth>2;cont=0;end
      handles.depth=depth;
      guidata(hObject,handles);
end
    
    handles.depth=0;
    guidata(hObject,handles);
    set(b,'Ydata',[0,0,0,0]);

    
    


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.slider1,'value',0);
%close(gcf); 
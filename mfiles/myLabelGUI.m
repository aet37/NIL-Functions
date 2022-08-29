function varargout = myLabelGUI(varargin)
% MYLABELGUI MATLAB code for myLabelGUI.fig
%      MYLABELGUI, by itself, creates a new MYLABELGUI or raises the existing
%      singleton*.
%
%      H = MYLABELGUI returns the handle to a new MYLABELGUI or the handle to
%      the existing singleton*.
%
%      MYLABELGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MYLABELGUI.M with the given input arguments.
%
%      MYLABELGUI('Property','Value',...) creates a new MYLABELGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before myLabelGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to myLabelGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help myLabelGUI

% Last Modified by GUIDE v2.5 18-Feb-2013 20:28:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @myLabelGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @myLabelGUI_OutputFcn, ...
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


% --- Executes just before myLabelGUI is made visible.
function myLabelGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to myLabelGUI (see VARARGIN)

set(handles.pushbutton1,'String','Neuron');

cla(handles.axes1);
show(varargin{1});
%image(imwlevel(varargin{1},[],1),'Parent',handles.axes1)
%colormap(handles.axes1,gray(256));

%plot(handles.axes2,vargin{2})

% Choose default command line output for myLabelGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes myLabelGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);
return;


% --- Outputs from this function are returned to the command line.
function varargout = myLabelGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output1;
delete(handles.figure1);
return;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);
handles.output1=1,
guidata(hObject, handles);
return;

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);
handles.output1=4,
guidata(hObject, handles);
return;

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);
handles.output1=5,
guidata(hObject, handles);
return;

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);
handles.output1=6,
guidata(hObject, handles);
return;

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);
handles.output1=7,
guidata(hObject, handles);
return;

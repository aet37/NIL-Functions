function varargout = alignImgs(varargin)
% ALIGNIMGS MATLAB code for alignImgs.fig
%      ALIGNIMGS, by itself, creates a new ALIGNIMGS or raises the existing
%      singleton*.
%
%      H = ALIGNIMGS returns the handle to a new ALIGNIMGS or the handle to
%      the existing singleton*.
%
%      ALIGNIMGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ALIGNIMGS.M with the given input arguments.
%
%      ALIGNIMGS('Property','Value',...) creates a new ALIGNIMGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before alignImgs_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to alignImgs_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help alignImgs

% Last Modified by GUIDE v2.5 10-Feb-2014 20:57:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @alignImgs_OpeningFcn, ...
                   'gui_OutputFcn',  @alignImgs_OutputFcn, ...
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



% --- Executes just before alignImgs is made visible.
function alignImgs_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to alignImgs (see VARARGIN)

% Choose default command line output for alignImgs
handles.output = hObject;

handles.refimg=varargin{1};
handles.srcimg=varargin{2};
handles.mp(1)=0;
handles.mp(2)=0;
handles.mp(3)=0;
handles.mp(4)=1;
handles.mp(5)=1;
handles.reflines=[];
handles.rsrcimg=applyAffine_5dof(handles.srcimg,handles.mp(1),handles.mp(2),handles.mp(3),handles.mp(4),handles.mp(5),handles.refimg);
updateImages(handles)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes alignImgs wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = alignImgs_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function xtrans_Callback(hObject, eventdata, handles)
% hObject    handle to xtrans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xtrans as text
%        str2double(get(hObject,'String')) returns contents of xtrans as a double

handles.mp(2) = str2double(get(handles.xtrans,'string'));
handles.rsrcimg=applyAffine_5dof(handles.srcimg,handles.mp(1),handles.mp(2),handles.mp(3),handles.mp(4),handles.mp(5),handles.refimg);
updateImages(handles)
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function xtrans_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xtrans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function ytrans_Callback(hObject, eventdata, handles)
% hObject    handle to ytrans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ytrans as text
%        str2double(get(hObject,'String')) returns contents of ytrans as a double

handles.mp(1) = str2double(get(handles.ytrans,'string'));
handles.rsrcimg=applyAffine_5dof(handles.srcimg,handles.mp(1),handles.mp(2),handles.mp(3),handles.mp(4),handles.mp(5),handles.refimg);
updateImages(handles)
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ytrans_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ytrans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zrot_Callback(hObject, eventdata, handles)
% hObject    handle to zrot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zrot as text
%        str2double(get(hObject,'String')) returns contents of zrot as a double

handles.mp(3) = str2double(get(handles.zrot,'string'));
handles.rsrcimg=applyAffine_5dof(handles.srcimg,handles.mp(1),handles.mp(2),handles.mp(3),handles.mp(4),handles.mp(5),handles.refimg);
updateImages(handles)
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function zrot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zrot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function iimg=applyAffine_5dof(img,xtrans,ytrans,zrot,xscale,yscale,space)
zrot=zrot*(pi/180);
if ~exist('space','var')
    [nx,ny,nz,nt]=size(img);
else
    [nx,ny,nz,nt]=size(space);
end
[ii,jj,kk,ll]=ndgrid(1:nx,1:ny,1:nz,1:nt);

% z rotation matrix
zrotmat=eye(4); zrotmat(1,1)=cos(zrot); zrotmat(2,2)=cos(zrot); zrotmat(1,2)=-sin(zrot); zrotmat(2,1)=sin(zrot);
% translation matrix
transmat=eye(4); transmat(1,4)=xtrans; transmat(2,4)=ytrans;
% scale matrix
scalemat=eye(4); scalemat(1,1)=xscale; scalemat(2,2)=yscale;


T=zrotmat*transmat*scalemat;

indmat=cat(1,reshape(ii,[1 nx*ny*nz*nt]),reshape(jj,[1 nx*ny*nz*nt]),reshape(kk,[1 nx*ny*nz*nt]),reshape(ll,[1 nx*ny*nz*nt]));

indmat=T*indmat;
xx=reshape(indmat(1,:),[nx,ny,nz,nt]);
yy=reshape(indmat(2,:),[nx,ny,nz,nt]);
zz=reshape(indmat(3,:),[nx,ny,nz,nt]);

if nz>1
    iimg=interp3(img,yy,xx,zz);
elseif nz==1
    iimg=interp2(img,yy,xx);
end

handles.rsrcimg=iimg;
% guidata(hObject, handles);

function updateImages(handles)

axes(handles.axes1)
imagesc(handles.refimg); colormap gray; axis image;
axes(handles.axes2)
imagesc(handles.rsrcimg); colormap gray; axis image;

if ~isempty(handles.reflines)
    axes(handles.axes1)
    hold on;
    line(handles.reflines(:,1:2)',handles.reflines(:,3:4)','color','r')
    axes(handles.axes2)
    hold on;
    line(handles.reflines(:,1:2)',handles.reflines(:,3:4)','color','r')
end

if get(handles.center_lines,'value')
    [ny,nx]=size(handles.refimg);
    axes(handles.axes1)
    hold on;
    plot([1 ny-1],ny/2*[1 1],'color','b')
    plot(ny/2*[1 1],[1 ny-1],'color','b')
    axes(handles.axes2)
    hold on;
    plot([1 ny-1],ny/2*[1 1],'color','b')
    plot(ny/2*[1 1],[1 ny-1],'color','b')
end

axes(handles.axes1); axis image;
axes(handles.axes2); axis image;

% --- Executes on button press in refLineButton.
function refLineButton_Callback(hObject, eventdata, handles)
% hObject    handle to refLineButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes1);
[~,xi,yi]=roipoly();
for ii=1:(length(xi)-2)
    handles.reflines = cat(1,handles.reflines,[xi(ii),xi(ii+1),yi(ii),yi(ii+1)]);
end
updateImages(handles)
guidata(hObject, handles);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if size(handles.reflines,1)>0
handles.reflines(end,:) = [];
updateImages(handles)
guidata(hObject, handles);
end

% --- Executes on button press in x_up_slow.
function x_up_slow_Callback(hObject, eventdata, handles)
% hObject    handle to x_up_slow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.mp(2)=handles.mp(2)+.1;
set(handles.xtrans,'string',num2str(handles.mp(2)));
handles.rsrcimg=applyAffine_5dof(handles.srcimg,handles.mp(1),handles.mp(2),handles.mp(3),handles.mp(4),handles.mp(5),handles.refimg);
updateImages(handles)
guidata(hObject, handles);

% --- Executes on button press in x_up_fast.
function x_up_fast_Callback(hObject, eventdata, handles)
% hObject    handle to x_up_fast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.mp(2)=handles.mp(2)+1;
set(handles.xtrans,'string',num2str(handles.mp(2)));
handles.rsrcimg=applyAffine_5dof(handles.srcimg,handles.mp(1),handles.mp(2),handles.mp(3),handles.mp(4),handles.mp(5),handles.refimg);
updateImages(handles)
guidata(hObject, handles);


% --- Executes on button press in x_down_slow.
function x_down_slow_Callback(hObject, eventdata, handles)
% hObject    handle to x_down_slow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.mp(2)=handles.mp(2)-.1;
set(handles.xtrans,'string',num2str(handles.mp(2)));
handles.rsrcimg=applyAffine_5dof(handles.srcimg,handles.mp(1),handles.mp(2),handles.mp(3),handles.mp(4),handles.mp(5),handles.refimg);
updateImages(handles)
guidata(hObject, handles);


% --- Executes on button press in x_down_fast.
function x_down_fast_Callback(hObject, eventdata, handles)
% hObject    handle to x_down_fast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.mp(2)=handles.mp(2)-1;
set(handles.xtrans,'string',num2str(handles.mp(2)));
handles.rsrcimg=applyAffine_5dof(handles.srcimg,handles.mp(1),handles.mp(2),handles.mp(3),handles.mp(4),handles.mp(5),handles.refimg);
updateImages(handles)
guidata(hObject, handles);


% --- Executes on button press in y_up_slow.
function y_up_slow_Callback(hObject, eventdata, handles)
% hObject    handle to y_up_slow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.mp(1)=handles.mp(1)+.1;
set(handles.ytrans,'string',num2str(handles.mp(1)));
handles.rsrcimg=applyAffine_5dof(handles.srcimg,handles.mp(1),handles.mp(2),handles.mp(3),handles.mp(4),handles.mp(5),handles.refimg);
updateImages(handles)
guidata(hObject, handles);

% --- Executes on button press in y_up_fast.
function y_up_fast_Callback(hObject, eventdata, handles)
% hObject    handle to y_up_fast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.mp(1)=handles.mp(1)+1;
set(handles.ytrans,'string',num2str(handles.mp(1)));
handles.rsrcimg=applyAffine_5dof(handles.srcimg,handles.mp(1),handles.mp(2),handles.mp(3),handles.mp(4),handles.mp(5),handles.refimg);
updateImages(handles)
guidata(hObject, handles);


% --- Executes on button press in y_down_slow.
function y_down_slow_Callback(hObject, eventdata, handles)
% hObject    handle to y_down_slow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.mp(1)=handles.mp(1)-.1;
set(handles.ytrans,'string',num2str(handles.mp(1)));
handles.rsrcimg=applyAffine_5dof(handles.srcimg,handles.mp(1),handles.mp(2),handles.mp(3),handles.mp(4),handles.mp(5),handles.refimg);
updateImages(handles)
guidata(hObject, handles);

% --- Executes on button press in y_down_fast.
function y_down_fast_Callback(hObject, eventdata, handles)
% hObject    handle to y_down_fast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.mp(1)=handles.mp(1)-1;
set(handles.ytrans,'string',num2str(handles.mp(1)));
handles.rsrcimg=applyAffine_5dof(handles.srcimg,handles.mp(1),handles.mp(2),handles.mp(3),handles.mp(4),handles.mp(5),handles.refimg);
updateImages(handles)
guidata(hObject, handles);


% --- Executes on button press in rot_up_slow.
function rot_up_slow_Callback(hObject, eventdata, handles)
% hObject    handle to rot_up_slow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.mp(3)=handles.mp(3)+.001;
set(handles.zrot,'string',num2str(handles.mp(3)));
handles.rsrcimg=applyAffine_5dof(handles.srcimg,handles.mp(1),handles.mp(2),handles.mp(3),handles.mp(4),handles.mp(5),handles.refimg);
updateImages(handles)
guidata(hObject, handles);

% --- Executes on button press in rot_up_fast.
function rot_up_fast_Callback(hObject, eventdata, handles)
% hObject    handle to rot_up_fast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.mp(3)=handles.mp(3)+.01;
set(handles.zrot,'string',num2str(handles.mp(3)));
handles.rsrcimg=applyAffine_5dof(handles.srcimg,handles.mp(1),handles.mp(2),handles.mp(3),handles.mp(4),handles.mp(5),handles.refimg);
updateImages(handles)
guidata(hObject, handles);


% --- Executes on button press in rot_down_slow.
function rot_down_slow_Callback(hObject, eventdata, handles)
% hObject    handle to rot_down_slow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.mp(3)=handles.mp(3)-.001;
set(handles.zrot,'string',num2str(handles.mp(3)));
handles.rsrcimg=applyAffine_5dof(handles.srcimg,handles.mp(1),handles.mp(2),handles.mp(3),handles.mp(4),handles.mp(5),handles.refimg);
updateImages(handles)
guidata(hObject, handles);

% --- Executes on button press in rot_down_fast.
function rot_down_fast_Callback(hObject, eventdata, handles)
% hObject    handle to rot_down_fast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.mp(3)=handles.mp(3)-.01;
set(handles.zrot,'string',num2str(handles.mp(3)));
handles.rsrcimg=applyAffine_5dof(handles.srcimg,handles.mp(1),handles.mp(2),handles.mp(3),handles.mp(4),handles.mp(5),handles.refimg);
updateImages(handles)
guidata(hObject, handles);


% --- Executes on button press in center_lines.
function center_lines_Callback(hObject, eventdata, handles)
% hObject    handle to center_lines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of center_lines
updateImages(handles)


% --- Executes on button press in delete_ref_lines.
function delete_ref_lines_Callback(hObject, eventdata, handles)
% hObject    handle to delete_ref_lines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.reflines=[];
updateImages(handles);
guidata(hObject,handles);



function xscale_Callback(hObject, eventdata, handles)
% hObject    handle to xscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xscale as text
%        str2double(get(hObject,'String')) returns contents of xscale as a double

handles.mp(5) = str2double(get(handles.xscale,'string'));
handles.rsrcimg=applyAffine_5dof(handles.srcimg,handles.mp(1),handles.mp(2),handles.mp(3),handles.mp(4),handles.mp(5),handles.refimg);
updateImages(handles)
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function xscale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yscale_Callback(hObject, eventdata, handles)
% hObject    handle to yscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yscale as text
%        str2double(get(hObject,'String')) returns contents of yscale as a double

handles.mp(4) = str2double(get(handles.yscale,'string'));
handles.rsrcimg=applyAffine_5dof(handles.srcimg,handles.mp(1),handles.mp(2),handles.mp(3),handles.mp(4),handles.mp(5),handles.refimg);
updateImages(handles)
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function yscale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in xscale_up_fast.
function xscale_up_fast_Callback(hObject, eventdata, handles)
% hObject    handle to xscale_up_fast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.mp(5) = handles.mp(5)+ .01;
handles.rsrcimg=applyAffine_5dof(handles.srcimg,handles.mp(1),handles.mp(2),handles.mp(3),handles.mp(4),handles.mp(5),handles.refimg);
updateImages(handles)
set(handles.xscale,'string',num2str(handles.mp(5)));
guidata(hObject, handles);

% --- Executes on button press in xscale_up_slow.
function xscale_up_slow_Callback(hObject, eventdata, handles)
% hObject    handle to xscale_up_slow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.mp(5) = handles.mp(5)+ .001;
handles.rsrcimg=applyAffine_5dof(handles.srcimg,handles.mp(1),handles.mp(2),handles.mp(3),handles.mp(4),handles.mp(5),handles.refimg);
updateImages(handles)
set(handles.xscale,'string',num2str(handles.mp(5)));
guidata(hObject, handles);


% --- Executes on button press in xscale_down_fast.
function xscale_down_fast_Callback(hObject, eventdata, handles)
% hObject    handle to xscale_down_fast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.mp(5) = handles.mp(5) - .01;
handles.rsrcimg=applyAffine_5dof(handles.srcimg,handles.mp(1),handles.mp(2),handles.mp(3),handles.mp(4),handles.mp(5),handles.refimg);
updateImages(handles)
set(handles.xscale,'string',num2str(handles.mp(5)));
guidata(hObject, handles);

% --- Executes on button press in xscale_down_slow.
function xscale_down_slow_Callback(hObject, eventdata, handles)
% hObject    handle to xscale_down_slow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.mp(5) = handles.mp(5) - .001;
handles.rsrcimg=applyAffine_5dof(handles.srcimg,handles.mp(1),handles.mp(2),handles.mp(3),handles.mp(4),handles.mp(5),handles.refimg);
updateImages(handles)
set(handles.xscale,'string',num2str(handles.mp(5)));
guidata(hObject, handles);


% --- Executes on button press in yscale_up_fast.
function yscale_up_fast_Callback(hObject, eventdata, handles)
% hObject    handle to yscale_up_fast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.mp(4) = handles.mp(4) + .01;
handles.rsrcimg=applyAffine_5dof(handles.srcimg,handles.mp(1),handles.mp(2),handles.mp(3),handles.mp(4),handles.mp(5),handles.refimg);
updateImages(handles)
set(handles.yscale,'string',num2str(handles.mp(4)));
guidata(hObject, handles);

% --- Executes on button press in yscale_up_slow.
function yscale_up_slow_Callback(hObject, eventdata, handles)
% hObject    handle to yscale_up_slow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.mp(4) = handles.mp(4) + .001;
handles.rsrcimg=applyAffine_5dof(handles.srcimg,handles.mp(1),handles.mp(2),handles.mp(3),handles.mp(4),handles.mp(5),handles.refimg);
updateImages(handles)
set(handles.yscale,'string',num2str(handles.mp(4)));
guidata(hObject, handles);

% --- Executes on button press in yscale_down_fast.
function yscale_down_fast_Callback(hObject, eventdata, handles)
% hObject    handle to yscale_down_fast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.mp(4) = handles.mp(4) - .01;
handles.rsrcimg=applyAffine_5dof(handles.srcimg,handles.mp(1),handles.mp(2),handles.mp(3),handles.mp(4),handles.mp(5),handles.refimg);
updateImages(handles)
set(handles.yscale,'string',num2str(handles.mp(4)));
guidata(hObject, handles);

% --- Executes on button press in yscale_down_slow.
function yscale_down_slow_Callback(hObject, eventdata, handles)
% hObject    handle to yscale_down_slow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.mp(4) = handles.mp(4) - .001;
handles.rsrcimg=applyAffine_5dof(handles.srcimg,handles.mp(1),handles.mp(2),handles.mp(3),handles.mp(4),handles.mp(5),handles.refimg);
updateImages(handles)
set(handles.yscale,'string',num2str(handles.mp(4)));
guidata(hObject, handles);
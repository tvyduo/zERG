%% Description
% zERG version 1.1
% Updated: 12/03/2020

%% Opening functions

function varargout = zERGv011(varargin)
% zERGv011 MATLAB code for zERGv011.fig
%      zERGv011, by itself, creates a new zERGv011 or raises the existing
%      singleton*.
%
%      H = zERGv011 returns the handle to a new zERGv011 or the handle to
%      the existing singleton*.
%
%      zERGv011('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in zERGv011.M with the given input arguments.
%
%      zERGv011('Property','Value',...) creates a new zERGv011 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before zERGv011_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to zERGv011_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help zERGv011

% Last Modified by GUIDE v2.5 28-Jan-2021 10:21:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @zERGv011_OpeningFcn, ...
    'gui_OutputFcn',  @zERGv011_OutputFcn, ...
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

% --- Executes just before zERGv011 is made visible.
function zERGv011_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to zERGv011 (see VARARGIN)

%Add code to path to run from any folder
code_dir_full=mfilename('fullpath');
split_path=strsplit(code_dir_full, "\");
num_length=length(split_path);
script_name=split_path{num_length};
assignin('base', 'script_name', script_name);
code_dir=erase(code_dir_full, script_name);
addpath(code_dir);

%Ask user to identify folder with data:
pathname=uigetdir();
assignin('base','pathname',pathname);
cd(pathname)
assignin('base','savepathname',pathname);
txtFiles = dir('*.txt');
matFiles = dir('*.mat');
for i = 1:length(txtFiles)
    currFileName = txtFiles(i).name;
    [pathstr,txtName,ext] = fileparts(currFileName);
    try
        %checking that the txt file actually works
        matrix = dlmread(currFileName);
        
        %ensuring no duplicate file are created
        toConvert = true;
        for j = 1:length(matFiles)
            matFileName = matFiles(j).name;
            [pathstr,matName,ext] = fileparts(matFileName);
            if strcmp(txtName, matName)
                toConvert = false;
            end
        end
        if toConvert
            %converting to a format which matches the .mat files
            blocktimes = 7.3748e+05;
            datastart = 1;
            data = matrix(:,2)';
            dataend = length(data);
            firstsampleoffset = 0;
            rangemax = 0.0020;
            rangemin = -0.0020;
            samplerate = 2000;
            tickrate = 2000;
            titles = 'Channel 4';
            unittext = 'V';
            unittextmap = 1;
            newName = strcat(txtName, 'fromtxt');
            save(newName, 'blocktimes', 'datastart', 'data', 'dataend', 'firstsampleoffset', 'rangemax', 'rangemin', 'samplerate', 'tickrate', 'titles', 'unittext', 'unittextmap');
        end
    catch
        %nothing to do here; the file doesn't need to be converted
    end
end
files=dir('*.mat');
assignin('base','files',files);

for ii=1:length(files)
    DataFiles{ii}=files(ii).name;
    allSelectedRect(ii,1:4)=[0,0,0,0];
    ROIcount(ii,1)=0;
    ROIcount(ii,2)=0;
    AllsubData{ii}=0;
    allAvgTraces{ii,1}=0;
    allPeaks{ii,1,1}=0;
    allPeaks{ii,1,2}=0;
    Thresh{ii,1}=0.5;
    allECGpk{ii,1}=0;
    allQRSwidth{ii,1}=0;
    subData_ptime{ii}=0;
end

assignin('base','allSelectedRect',allSelectedRect);
assignin('base','ROIcount',ROIcount);
assignin('base','AllsubData',AllsubData);
assignin('base','allPeaks',allPeaks);
assignin('base','Thresh',Thresh);
assignin('base','allAvgTraces',allAvgTraces);
assignin('base','allECGpk',allECGpk)
assignin('base','allQRSwidth',allQRSwidth)
assignin('base','subData_ptime', subData_ptime)

%Display filenames in listbox
set(handles.filelist,'String',DataFiles);

%x- and y-axis modifications for trace segments and average trace plots
set(handles.ROIaxes,'yticklabel',[])
set(handles.AverageAxes,'yticklabel',[])
set(handles.AverageAxes,'xticklabel',[])
set(handles.ROIaxes,'xticklabel',[]);
set(handles.AverageAxes,'FontSize',8)

%Display first data trace on axes
currentfile=files(1).name;
assignin('base', 'currentfile', currentfile);
load(currentfile)

% Plots ECG trace
[numchannels, numblocks] = size(datastart);
ptime = [];
ch=numchannels;
bl=numblocks;
assignin('base','ch',ch);
assignin('base','bl',bl);
assignin('base','samplerate',samplerate);
if (datastart(ch,bl) ~= -1)%empty blocks excluded
    DataInput = data(datastart(ch,bl):dataend(ch,bl));
    ptime = [0:size(DataInput,2)-1]/samplerate(ch,bl);
    axes(handles.FullDataAxes)
    %set(handles.FullDataAxes,'FontSize',0.5)
    plot(ptime,DataInput)
    set(handles.FullDataAxes,'FontSize',8)
    set(gcf,'toolbar','figure');
    
    % x-axis modifications
    xlabel('Time (s)');
    if (length(ptime) ~= 1)%exclude blocks with only one data point
        xlim([0 max(ptime)])
    end
    
    % y-axis modifications
    if (unittextmap(ch,bl) ~= -1)
        %unittext and unittextmap are matrices detailing which
        %channel (unittextmap) should have which unit (unittext)
        unit = unittext(unittextmap(ch,bl),:);
        ylabel(unit);
    end
    pmin = min(DataInput)-10^-5;
    pmax = max(DataInput)+10^-5;
    ylim([pmin pmax]);
    
end

% Choose default command line output for zERGv011
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%setting the default noise remover pop up frequency
assignin('base', 'PopUpFrequencyValue', 1);

% UIWAIT makes zERGv011 wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = zERGv011_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%% Filelist functions

% --- Executes on selection change in filelist.
function filelist_Callback(hObject, eventdata, handles)
% hObject    handle to filelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns filelist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from filelist

arrayfun(@cla,findall(0,'type','axes'));
set(handles.FullTrace, 'Value', 0);
set(handles.BeginPeak, 'Value', 0);
set(handles.AverageAxes,'xticklabel',[])

files=evalin('base','files');
selectedfile=get(handles.filelist,'Value');
ROIcount=evalin('base','ROIcount');

AllsubData=evalin('base','AllsubData');
allPeaks=evalin('base','allPeaks');
AllsubData=evalin('base','AllsubData');
allAvgTraces=evalin('base','allAvgTraces');
allECGpk=evalin('base','allECGpk');
allQRSwidth=evalin('base','allQRSwidth');
subData_ptime=evalin('base','subData_ptime');
ConfirmedPeaks=get(handles.AddAvgPeaksbutton,'UserData');
set(handles.SelectPeakButton,'UserData',[]);
set(handles.BoxPeaksButton,'UserData',[]);
assignin('base','selectedYellow',[]);
assignin('base','selectedArrythmias',[]);
assignin('base','selectedMinima',[]);
%axes(handles.AnalyzeAxes), cla

currentfile=files(selectedfile).name;
load(currentfile)
assignin('base','currentfile',currentfile)

% Plots ECG trace
[numchannels, numblocks] = size(datastart);
ptime = [];
ch=numchannels;
bl=numblocks;
if (datastart(ch,bl) ~= -1)%empty blocks excluded
    DataInput = data(datastart(ch,bl):dataend(ch,bl));
    ptime = [0:size(DataInput,2)-1]/samplerate(ch,bl);
    axes(handles.FullDataAxes)
    plot(ptime,DataInput), hold on
    set(handles.FullDataAxes,'FontSize',8)
    
    % x-axis modifications
    xlabel('Time (s)');
    if (length(ptime) ~= 1)%exclude blocks with only one data point
        xlim([0 max(ptime)])
    end
    
    % y-axis modifications
    if (unittextmap(ch,bl) ~= -1)
        %unittext and unittextmap are matrices detailing which
        %channel (unittextmap) should have which unit (unittext)
        unit = unittext(unittextmap(ch,bl),:);
        ylabel(unit);
    end
    pmin = min(DataInput)-10^-5;
    pmax = max(DataInput)+10^-5;
    ylim([pmin pmax]);
    
end

% --- Executes during object creation, after setting all properties.
function filelist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% Functions to select data to be analyzed
% --- Executes on button press in SelectDatabutton1.
function SelectDatabutton1_Callback(hObject, eventdata, handles)
% hObject    handle to SelectDatabutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Clear selected data
cla reset
arrayfun(@cla,findall(0,'type','axes'));
set(handles.FullTrace, 'Value', 0);
set(handles.BeginPeak, 'Value', 0);
set(handles.AverageAxes,'yticklabel',[])
set(handles.AverageAxes,'xticklabel',[])

% Read in start and end time (in seconds)
start_str=get(handles.StartTime,'String');
start_time=str2num(start_str);
end_str=get(handles.EndTime,'String');
end_time=str2num(end_str);

files=evalin('base','files');
currfile=get(handles.filelist,'Value');

currentfile=files(currfile).name;
load(currentfile)

% Plots ECG trace
axes(handles.FullDataAxes)
[numchannels, numblocks] = size(datastart);
ptime = [];
ch=numchannels;
bl=numblocks;
if (datastart(ch,bl) ~= -1)%empty blocks excluded
    DataInput = data(datastart(ch,bl):dataend(ch,bl));
    ptime = [0:size(DataInput,2)-1]/samplerate(ch,bl);
    axes(handles.FullDataAxes)
    plot(ptime,DataInput), hold on
    set(handles.FullDataAxes,'FontSize',8)
    set(handles.ROIaxes,'xticklabel',[]);
    
    % x-axis modifications
    xlabel('Time (s)');
    if (length(ptime) ~= 1)%exclude blocks with only one data point
        xlim([0 max(ptime)])
    end
    
    % y-axis modifications
    if (unittextmap(ch,bl) ~= -1)
        %unittext and unittextmap are matrices detailing which
        %channel (unittextmap) should have which unit (unittext)
        unit = unittext(unittextmap(ch,bl),:);
        ylabel(unit);
    end
    pmin = min(DataInput)-10^-5;
    pmax = max(DataInput)+10^-5;
    ylim([pmin pmax]);
    
end

% Draw rectangle around selected data
y_coord_rect_min=(min(DataInput));
y_coord_rect_max=(max(DataInput));
height=y_coord_rect_max-y_coord_rect_min;
width=end_time-start_time;
rect=rectangle('Position', [start_time y_coord_rect_min width height], 'EdgeColor', [0.6350 0.0780 0.1840], 'LineWidth', 2);
selected_time = ptime(ptime>=start_time & ptime<=end_time);
selected_data = DataInput(ptime>=start_time & ptime<=end_time);
%r=rectangle('Position',get(handles.DataRangetxt,'UserData'),'EdgeColor','red','LineWidth',3);
allSelectedRect=evalin('base','allSelectedRect');
allSelectedRect(currfile,1:4)=[start_time y_coord_rect_min width height];
assignin('base','allSelectedRect',allSelectedRect);
assignin('base','selected_time',selected_time);
assignin('base','selected_data',selected_data);

% --- Executes during object deletion, before destroying properties.
function ROIaxes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIaxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object deletion, before destroying properties.
function ROIaxes_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to ROIaxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function ROIinterval_Callback(hObject, eventdata, handles)
% hObject    handle to ROIinterval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROIinterval as text
%        str2double(get(hObject,'String')) returns contents of ROIinterval as a double


% --- Executes during object creation, after setting all properties.
function ROIinterval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIinterval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on mouse press over axes background.
function ROIaxes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to ROIaxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function StartTime_Callback(hObject, eventdata, handles)
% hObject    handle to StartTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StartTime as text
%        str2double(get(hObject,'String')) returns contents of StartTime as a double

% --- Executes during object creation, after setting all properties.
function StartTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StartTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function EndTime_Callback(hObject, eventdata, handles)
% hObject    handle to EndTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EndTime as text
%        str2double(get(hObject,'String')) returns contents of EndTime as a double

% --- Executes during object creation, after setting all properties.
function EndTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EndTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in FullTrace.
function FullTrace_Callback(hObject, eventdata, handles)
% hObject    handle to FullTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Clear selected data
%cla reset
arrayfun(@cla,findall(0,'type','axes'));
%set(handles.FullTrace, 'Value', 0);
%set(handles.BeginPeak, 'Value', 0);

files=evalin('base','files');
currfile=get(handles.filelist,'Value');

currentfile=files(currfile).name;
load(currentfile)
% Plots ECG trace
axes(handles.FullDataAxes)
[numchannels, numblocks] = size(datastart);
ptime = [];
ch=numchannels;
bl=numblocks;
if (datastart(ch,bl) ~= -1)%empty blocks excluded
    DataInput = data(datastart(ch,bl):dataend(ch,bl));
    ptime = [0:size(DataInput,2)-1]/samplerate(ch,bl);
    axes(handles.FullDataAxes)
    plot(ptime,DataInput), hold on
    set(handles.FullDataAxes,'FontSize',8)
    
    % x-axis modifications
    xlabel('Time (s)');
    if (length(ptime) ~= 1)%exclude blocks with only one data point
        xlim([0 max(ptime)])
    end
    
    % y-axis modifications
    if (unittextmap(ch,bl) ~= -1)
        %unittext and unittextmap are matrices detailing which
        %channel (unittextmap) should have which unit (unittext)
        unit = unittext(unittextmap(ch,bl),:);
        ylabel(unit);
    end
    pmin = min(DataInput)-10^-5;
    pmax = max(DataInput)+10^-5;
    ylim([pmin pmax]);
    
end

% Draw rectangle around selected data
%start_str=get(handles.StartTime,'String');
start_time=min(ptime);
%end_str=get(handles.EndTime,'String');
end_time=max(ptime);
y_coord_rect_min=(min(DataInput));
y_coord_rect_max=(max(DataInput));
height=y_coord_rect_max-y_coord_rect_min;
width=end_time-start_time;
rect=rectangle('Position', [start_time y_coord_rect_min width height], 'EdgeColor', [0.6350 0.0780 0.1840], 'LineWidth', 2);
selected_time = ptime(ptime>=start_time & ptime<=end_time);
selected_data = DataInput(ptime>=start_time & ptime<=end_time);
%r=rectangle('Position',get(handles.DataRangetxt,'UserData'),'EdgeColor','red','LineWidth',3);
allSelectedRect=evalin('base','allSelectedRect');
allSelectedRect(currfile,1:4)=[start_time y_coord_rect_min width height];
assignin('base','allSelectedRect',allSelectedRect);
assignin('base','selected_time',selected_time);
assignin('base', 'selected_data', selected_data);


%% Function to start Peak Analysis

% --- Executes on button press in BeginPeak.
function BeginPeak_Callback(hObject, eventdata, handles)
% hObject    handle to BeginPeak (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.AverageAxes,'yticklabel',[])
set(handles.AverageAxes,'xticklabel',[])

% Get start and end time of data to be analyzed (in seconds)
%intervalstr=get(handles.ROIinterval,'String');
selected_time=evalin('base', 'selected_time');
interval=max(selected_time);
%new
%interval=1;

currfile=get(handles.filelist,'Value');

allSelectedRect=evalin('base','allSelectedRect');
files=evalin('base','files');
ROIcount=evalin('base','ROIcount');
AllsubData=evalin('base','AllsubData');
Thresh=evalin('base','Thresh');
allAvgTraces=evalin('base','allAvgTraces');
allECGpk=evalin('base','allECGpk');
allQRSwidth=evalin('base','allQRSwidth');
selected_data=evalin('base', 'selected_data');

ROI(currfile,1)=0;
ROI(currfile,2)=0;

AllsubData{1,currfile}=0;

% Get position of rectangle
rPosition=allSelectedRect(currfile,:);
startsub=rPosition(1);
endsub=rPosition(1)+rPosition(3);

allPeaks=evalin('base','allPeaks');

currentfile=files(currfile).name;
load(currentfile)

% Read in ECG data
[numchannels, numblocks] = size(datastart);
ptime = [];
ch=numchannels;
bl=numblocks;
if (datastart(ch,bl) ~= -1)%empty blocks excluded
    DataInput = data(datastart(ch,bl):dataend(ch,bl));
    ptime = [0:size(DataInput,2)-1]/samplerate(ch,bl);
    pmin = min(DataInput)-10^-5;
    pmax = max(DataInput)+10^-5;
end

axes(handles.ROIaxes), cla
ii=1;
count=startsub:interval:endsub;
subData{ii}=selected_data;
subData_ptime=ptime(ptime>=startsub & ptime<=endsub);
allAvgTraces{currfile,ii}=0;
allECGpk{currfile,ii}=0;
allQRSwidth{currfile,ii}=0;
minVal = min(subData{ii});
maxVal = max(subData{ii});
subData{ii} = (subData{ii} - minVal) / ( maxVal - minVal );
allPeaks{currfile,ii,1}=0;
allPeaks{currfile,ii,2}=0;
Thresh{currfile,ii}=0.5;
segment_start_time = count(ii);
segment_end_time = endsub;

ROIcount(currfile,1)=ii-1;
ROIcount(currfile,2)=1;   %current plot

AllsubData{currfile}=subData;
clear subData
assignin('base','AllsubData', AllsubData);
%plot(subData_ptime, AllsubData{1,currfile}{1,1}); hold on
plot(AllsubData{1,currfile}{1,1}); hold on
%xlim([startsub endsub]);
%x-axis modifications
%xlabel('Time (s)');
set(handles.ROIaxes,'xticklabel',[])
%set(handles.ROIaxes,'FontSize',8);
%y-axis modification
set(handles.ROIaxes,'yticklabel',[])

currThresh=Thresh{currfile,1};
[row col]=size(AllsubData{1,currfile}{1,1});
line=imline(gca,[0,col],[currThresh,currThresh]);
setColor(line,[0 0 0]);
% % % handles.line=line;
% % % handles.ax=handles.ROIaxes;
% % % handles.currfile=currfile;
% % % handles.currROI=ROIcount(currfile,2);
% % % guidata(hObject,handles);
child_line=get(line, 'Children');
set(child_line(1),'MarkerSize',0.05);
set(child_line(2),'MarkerSize',0.05);

addNewPositionCallback(line,@(q) set(handles.FindPeaksButton,'UserData',q));

fcn2 = makeConstrainToRectFcn('imline',get(gca,'XLim'),get(gca,'YLim'));
setPositionConstraintFcn(line,fcn2);
% % lPosition=line.getPostion;
% Thresh{currfile,1}=lPosition(1,2);

assignin('base','ROIcount',ROIcount);
assignin('base','allPeaks',allPeaks);
assignin('base','Thresh',Thresh);
assignin('base','allECGpk',allECGpk);
assignin('base','allQRSwidth',allQRSwidth)
% set(handles.SegmentButton,'UserData',ROIcount);

%ROIstr=[num2str(ROIcount(currfile,2)),'/',num2str(ROIcount(currfile,1))];
%set(handles.CurrentROItext,'String',ROIstr);
assignin('base','Thresh',Thresh)
assignin('base','allAvgTraces',allAvgTraces)
assignin('base', 'startsub', startsub);
assignin('base', 'endsub', endsub);
assignin('base', 'minVal', minVal);
assignin('base', 'maxVal', maxVal);

%% Functions to find, add, or delete peaks

%function to plot all of the relevant points on the graph
function PlotAllRelevantPoints(allPeaks, currfile, ROIcount, tempData)
plot(allPeaks{currfile,ROIcount(currfile,2),1},tempData(allPeaks{currfile,ROIcount(currfile,2),1}),'r*','MarkerSize',10)
plot(allPeaks{currfile,ROIcount(currfile,2),2},tempData(allPeaks{currfile,ROIcount(currfile,2),2}),'k*','MarkerSize',10)
plot(allPeaks{currfile,ROIcount(currfile,2),9},tempData(allPeaks{currfile,ROIcount(currfile,2),9}),'m*','MarkerSize',10)
plot(allPeaks{currfile,ROIcount(currfile,2),5},tempData(allPeaks{currfile,ROIcount(currfile,2),5}),'y*','MarkerSize',7)
plot(allPeaks{currfile,ROIcount(currfile,2),7},tempData(allPeaks{currfile,ROIcount(currfile,2),7}),'g*','MarkerSize',5);



%function to set the y-axis muliplier appropriately
function [Y_AXIS_MULTIPLIER] = YAxisMultiplier(handles)
x = handles.ROIaxes.XLim;
y = handles.ROIaxes.YLim;
%the line below ensures that even if the user zooms in much more along one
%axis than another, his/her closeness to a peak is calculated based on the
%proportions that he/she sees on screen
Y_AXIS_MULTIPLIER = ((x(2) - x(1))/(y(2) - y(1)))/2.5;


% --- Executes on button press in FindPeaksButton.
function FindPeaksButton_Callback(hObject, eventdata, handles)
% hObject    handle to FindPeaksButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Finds P and QRS peaks in the data, labeling the P peaks red and the QRS
%peaks black. Labeling is done based on distance from both the next and
%previous peaks: peaks close to the next peak are labeled red, while peaks
%close to the previous peak are labeled black. Peaks that the program is
%not confident about are still labeled either red or black based on the
%previous peak, but a yellow marker is placed to indicate uncertainty. A
%yellow marker is also placed any time there are two peaks of the same
%color in a row.

currfile=get(handles.filelist,'Value');
AllsubData=evalin('base','AllsubData');
ROIcount=evalin('base','ROIcount');
allPeaks=evalin('base','allPeaks');
Thresh=evalin('base','Thresh');
storedThresh=get(handles.FindPeaksButton,'UserData');
subData_ptime=evalin('base', 'subData_ptime');
startsub=evalin('base', 'startsub');
endsub=evalin('base', 'endsub');

if length(storedThresh)>1
    Thresh{currfile,ROIcount(currfile,2)}=storedThresh(1,2);
end

TempData=AllsubData{1,currfile}{1,ROIcount(currfile,2)};
currThresh=Thresh{currfile,ROIcount(currfile,2)};

% Determine peaks: all peaks above the min peak height, and a distance of
% 80 + on the graph away from each other, are considered peaks
%[pa,pl]=findpeaks(TempData,'MinPeakHeight',currThresh, 'MinPeakDist',80);
minpeakdist_string=get(handles.changepeakdist,'String');
minpeakdist_value=str2num(minpeakdist_string);
%[pa,pl]=findpeaks(TempData,'MinPeakHeight',currThresh, 'MinPeakDist', minpeakdist_value, 'MinPeakWidth', 10, 'MaxPeakWidth', 30);
[pa,pl]=findpeaks(TempData,'MinPeakHeight',currThresh, 'MinPeakDist', minpeakdist_value);

%pa is y-coords of peaks, pl is x-coords of peaks
dist1=pl(2)-pl(1);
dist2=pl(3)-pl(2);

%boolean to keep track of which color to assign the next peak if it is far
%from other peaks
nextIsP = false;

%indices which need to be marked with a yellow point
problemInd = [];
pToQGap = 0;
qToPGap = 0;

if dist1<dist2
    pInd=[1];
    qInd=[2];
    pToQGap = dist1;
    qToPGap = dist2;
    nextIsP = true;
else
    pInd=[2];
    qInd=[1];
    pToQGap = dist2;
    qToPGap = dist1;
end

%any peak which occurs within CONSTANT * pToQGap of another peak is easily
%classified as red or black; the constant was arbitrarily chosen as it has
%worked well
CONSTANT = 2;

for index=3:length(pl) - 1
    if pl(index) - pl(index - 1) < pToQGap * CONSTANT
        qInd = [qInd index];
        if (nextIsP == true)
            problemInd = [problemInd index-1 index];
        end
        nextIsP = true;
    else
        if pl(index + 1) - pl(index) < pToQGap * CONSTANT
            pInd = [pInd index];
            if (nextIsP == false)
                problemInd = [problemInd index-1 index];
            end
            nextIsP = false;
        else
            %in this case, the peak is near no other peaks
            if nextIsP == true;
                pInd = [pInd index];
                nextIsP = false;
                problemInd = [problemInd index];
            else
                qInd = [qInd index];
                nextIsP = true;
                problemInd = [problemInd index];
            end
        end
    end
end

%labeling the last peak
if nextIsP == true
    pInd = [pInd length(pl)];
    nextIsP = false;
else
    qInd = [qInd length(pl)];
    nextIsP = true;
end

%removing duplicate points from problemInd
if length(problemInd) > 1
    newProblemInd = [problemInd(1)];
    for index=2:length(problemInd)
        if (problemInd(index-1)~=problemInd(index))
            newProblemInd = [newProblemInd problemInd(index)];
        end
    end
    problemInd = newProblemInd;
end

% Plot peaks (red = P wave; black = QRS)
axes(handles.ROIaxes), cla, plot(TempData), hold on
plot(pl(pInd),pa(pInd),'r*','MarkerSize',10)
plot(pl(qInd),pa(qInd),'k*','MarkerSize',10)
plot(pl(problemInd),pa(problemInd),'y*','MarkerSize',7), hold off
set(handles.ROIaxes,'xticklabel',[])
set(handles.ROIaxes,'yticklabel',[])

allPeaks{currfile,ROIcount(currfile,2),1}=pl(pInd); %P x-coords; order from left to right is maintained by all functions
allPeaks{currfile,ROIcount(currfile,2),2}=pl(qInd); %QRS x-coords; order from left to right is maintained by all functions
allPeaks{currfile,ROIcount(currfile,2),3}=pa(pInd); %P y-coords; order cooresponds to x-coords order
allPeaks{currfile,ROIcount(currfile,2),4}=pa(qInd); %QRS y-coords; order cooresponds to x-coords order
allPeaks{currfile,ROIcount(currfile,2),5}=pl(problemInd); %problematic x-coords
allPeaks{currfile,ROIcount(currfile,2),6}=pa(problemInd); %problematic y-coords; order cooresponds to x-coords order
allPeaks{currfile,ROIcount(currfile,2),7}=[]; %arrythmia x-coords
allPeaks{currfile,ROIcount(currfile,2),8}=[]; %arrythmia y-coords; order cooresponds to x-coords order
allPeaks{currfile,ROIcount(currfile,2),9}=[]; %qrs minima x-coords; order from left to right is maintained by all functions
allPeaks{currfile,ROIcount(currfile,2),10}=[]; %qrs minima y-coords; order cooresponds to x-coords order
assignin('base','allPeakXs', pl); %for use in noise removing
assignin('base','allPeakYs', pa); %for use in noise removing
assignin('base','allPeaks',allPeaks)
assignin('base','currfile',currfile)

%default values for avg trace window multipliers, to be used later
PQRS_GAP_MULTIPLIER = 2;
RR_MULTIPLIER = 0.6;

assignin('base','PQRS_GAP_MULTIPLIER',PQRS_GAP_MULTIPLIER)
assignin('base','RR_MULTIPLIER',RR_MULTIPLIER)

set(handles.SelectPeakButton,'UserData',[]);
set(handles.BoxPeaksButton,'UserData',[]);
assignin('base','selectedYellow',[]);
assignin('base','selectedArrythmias',[]);
assignin('base','selectedMinima',[]);

assignin('base','calculateAvgButtonPressed',false);
assignin('base','minimaAvgButtonPressed',false);

% --- Executes on button press in RemoveNoiseButton.
function RemoveNoiseButton_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveNoiseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Removes noise in noisy traces
%To be used after FindPeaksButton; removes all edits made since use of
%FindPeaksButton

%NOTE: all undo related things will be added in a future version of the
%code

currfile=get(handles.filelist,'Value');
AllsubData=evalin('base','AllsubData');
ROIcount=evalin('base','ROIcount');
peakXs = evalin('base', 'allPeakXs'); %note: takes peakXs from the original find peaks; running noise remover won't change this
peakYs = evalin('base', 'allPeakYs'); %ditto here
TempData=AllsubData{1,currfile}{1,ROIcount(currfile,2)};
pInd = [];
pIndYs = [];
qInd = [];
qIndYs = [];
problemInd = [];
problemIndYs = [];
unusedPeakXs = peakXs;
unusedPeakYs = peakYs;

%for later use
allPeaks=evalin('base','allPeaks');
PopUpFreq = evalin('base', 'PopUpFrequencyValue');
minimaXs = allPeaks{currfile,ROIcount(currfile,2),9};
minimaYs = allPeaks{currfile,ROIcount(currfile,2),10};

%the following allow for the user to go back to a previous checkpoint upon pressing the undo
%button
prevPInd = [];
prevPIndYs = [];
prevQInd = [];
prevQIndYs = [];
prevProblemInd = [];
prevProblemIndYs = [];
prevUnusedPeakXs = [];
prevUnusedPeakYs = [];
filler = []; %for cases where some of the values don't need to be adjusted

axes(handles.ROIaxes), cla, plot(TempData), hold on
plot(peakXs,peakYs,'c*','MarkerSize',10), hold on
set(handles.ROIaxes,'xticklabel',[])
set(handles.ROIaxes,'yticklabel',[])

set(handles.UndoStepButton,'Visible','Off'); %needs to be set on in future versions

%Create values for pop-up prompts
str1=[];
str2=[];
str3=[];

if PopUpFreq > 0
    response=questdlg('Between the P and R wave, does the amplitude of one wave exceeds the other for the duration of the selected trace to be analyzed?', '', 'Yes', 'No', 'Cancel', 'Cancel');
    switch response
        case 'Yes'
            str1 = 'Y';
        case 'No'
            str1 = 'N';
        case 'Cancel'
            PlotAllRelevantPoints(allPeaks, currfile, ROIcount, TempData), hold off
            return
    end
else
    prompt = 'Between the P and R wave, does the amplitude of one wave exceeds the other for the duration of the selected trace to be analyzed? Enter Y or N: ';
    str1 = input(prompt,'s');
end

if str1 == 'Y'
    pIsHigher = false;
    if PopUpFreq > 0
        response=questdlg('Which wave has the greater amplitude?', '', 'P Wave', 'R Wave', 'Cancel', 'Cancel');
        switch response
            case 'P Wave'
                str2 = 'P';
                pIsHigher = true;
            case 'R Wave'
                pIsHigher = false;
            case 'Cancel'
                PlotAllRelevantPoints(allPeaks, currfile, ROIcount, TempData), hold off
                return
        end
    else
        prompt = 'Which wave has the greater amplitude? Enter P or R: ';
        str2 = input(prompt,'s');
        if str2 == 'P' | str2 == 'p'
            pIsHigher = true;
        end
    end
    
    RR_GAP_CONSTANT_LEFT = 0.45;
    RR_GAP_CONSTANT_RIGHT = 0.45;
    RR_GAP_CONSTANT_LEFT_BACKUP_MULTIPLIER = 1;
    RR_GAP_CONSTANT_RIGHT_BACKUP_MULTIPLIER = 1;
    PQRS_GAP_CONSTANT = 0.15;
    
    if pIsHigher
        StandardPopUpOrDisp('Select the height of the P wave with the lowest amplitude.', PopUpFreq);
        h=drawpoint('Visible', 'off');
        drawline('Position', [0, h.Position(2); length(TempData), h.Position(2)]);
        lowestHeight = h.Position(2) - 0.02; %setting slightly lower in case the user doesn't realize the line is a little high
        
        StandardPopUpOrDisp('Select the first P Wave.', PopUpFreq);
        h=drawpoint('Visible','off');
        newPoint=h.Position;
        %finding the closest peak to the selected point
        [selectedPeak,selectedLoc]=min((unusedPeakXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(TempData(unusedPeakXs) - newPoint(2))).^2);
        plot(unusedPeakXs(selectedLoc),unusedPeakYs(selectedLoc),'r*','MarkerSize',10), hold on
        %set(handles.ROIaxes,'xticklabel',[])
        %set(handles.ROIaxes,'yticklabel',[])
        pInd = [pInd unusedPeakXs(selectedLoc)];
        pIndYs = [pIndYs unusedPeakYs(selectedLoc)];
        xHolder = unusedPeakXs(selectedLoc);
        unusedPeakXs(selectedLoc) = [];
        unusedPeakYs(selectedLoc) = [];
        
        if PopUpFreq == 1
            StandardPopUpOrDisp('Select the second P Wave. Note: further instructions will come through the console until all P waves are selected.', PopUpFreq);
        else
            StandardPopUpOrDisp('Select the second P Wave.', PopUpFreq);
        end
        h=drawpoint('Visible','off');
        newPoint=h.Position;
        %finding the closest peak to the selected point
        [selectedPeak,selectedLoc]=min((unusedPeakXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(TempData(unusedPeakXs) - newPoint(2))).^2);
        plot(unusedPeakXs(selectedLoc),unusedPeakYs(selectedLoc),'r*','MarkerSize',10), hold on
        %set(handles.ROIaxes,'xticklabel',[])
        %set(handles.ROIaxes,'yticklabel',[])
        pInd = [pInd unusedPeakXs(selectedLoc)];
        pIndYs = [pIndYs unusedPeakYs(selectedLoc)];
        prevX = unusedPeakXs(selectedLoc);
        prevGap =  prevX - xHolder;
        unusedPeakXs(selectedLoc) = [];
        unusedPeakYs(selectedLoc) = [];
        index = prevX + prevGap;
        prevHadProblem = false;
        
        %establish checkpoint here (undo button)
        
        while index < length(TempData)
            peaksInIntervalIndices= [];
            peaksInIntervalYs = [];
            for i = 1:length(unusedPeakXs)
                if unusedPeakXs(i) > index - round(RR_GAP_CONSTANT_LEFT*prevGap) && unusedPeakXs(i) < index + round(RR_GAP_CONSTANT_RIGHT*prevGap) && unusedPeakYs(i) > lowestHeight
                    peaksInIntervalIndices = [peaksInIntervalIndices i];
                    peaksInIntervalYs = [peaksInIntervalYs unusedPeakYs(i)];
                end
            end
            
            if length(peaksInIntervalIndices) == 0
                %trying again, but more liberal on the right side
                for i = 1:length(unusedPeakXs)
                    if unusedPeakXs(i) > index - round(RR_GAP_CONSTANT_LEFT*RR_GAP_CONSTANT_LEFT_BACKUP_MULTIPLIER*prevGap) && unusedPeakXs(i) < index + round(RR_GAP_CONSTANT_RIGHT*RR_GAP_CONSTANT_RIGHT_BACKUP_MULTIPLIER*prevGap) && unusedPeakYs(i) > lowestHeight
                        peaksInIntervalIndices = [peaksInIntervalIndices i];
                        peaksInIntervalYs = [peaksInIntervalYs unusedPeakYs(i)];
                    end
                end
            end
            
            if length(peaksInIntervalIndices) == 0
                if index + prevGap > length(TempData)
                    break
                end
                HighPopUpOrDisp('Please select the next P wave.');
                h=drawpoint('Visible','off');
                
                % check evalin('base', 'undoPressed') is false here; maybe
                % output this to the user, but not if the above
                % message is still applicable; no need to send user back to
                % start if checkpoint is start b/c user will be able to
                % adjust pqrs gap manually if that is the problem
                
                newPoint=h.Position;
                
                % establish checkpoint here
                
                %finding the closest peak to the selected point
                [selectedPeak,selectedLoc]=min((unusedPeakXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(TempData(unusedPeakXs) - newPoint(2))).^2);
                plot(unusedPeakXs(selectedLoc),unusedPeakYs(selectedLoc),'r*','MarkerSize',10), hold on
                %set(handles.ROIaxes,'xticklabel',[])
                %set(handles.ROIaxes,'yticklabel',[])
                pInd = [pInd unusedPeakXs(selectedLoc)];
                pIndYs = [pIndYs unusedPeakYs(selectedLoc)];
                if prevHadProblem == true
                    prevGap = round((unusedPeakXs(selectedLoc) - prevX + prevGap)/2);
                end
                prevX = unusedPeakXs(selectedLoc);
                problemInd = [problemInd prevX];
                problemIndYs = [problemIndYs TempData(prevX)];
                plot(prevX,TempData(prevX),'y*','MarkerSize',7), hold on
                %set(handles.ROIaxes,'xticklabel',[])
                %set(handles.ROIaxes,'yticklabel',[])
                unusedPeakXs(selectedLoc) = [];
                unusedPeakYs(selectedLoc) = [];
                index = prevX + prevGap;
                prevHadProblem = true;
            else
                prevHadProblem = false;
                [selectedPeak,selectedLoc]=max(peaksInIntervalYs);
                ii = peaksInIntervalIndices(selectedLoc);
                prevGap = round((unusedPeakXs(ii) - prevX + prevGap)/2);
                prevX = unusedPeakXs(ii);
                pInd = [pInd unusedPeakXs(ii)];
                pIndYs = [pIndYs unusedPeakYs(ii)];
                plot(unusedPeakXs(ii),unusedPeakYs(ii),'r*','MarkerSize',10), hold on
                %set(handles.ROIaxes,'xticklabel',[])
                %set(handles.ROIaxes,'yticklabel',[])
                unusedPeakXs(ii)=[];
                unusedPeakYs(ii)=[];
            end
            index = prevX + prevGap;
        end
        
        lastRRGap = prevGap;
        
        %allowing the user to edit the found P peaks; zooming out first
        xlim(size(TempData));
        ylim([0,1]);
        if PopUpFreq > 0
            response=questdlg('Would you like to edit the P waves?', '', 'Yes', 'No', 'No');
            switch response
                case 'Yes'
                    str3 = 'Y';
                case 'No'
                    str3 = 'N';
            end
        else
            prompt = 'Would you like to edit the P peaks? Enter Y or N: ';
            str3 = input(prompt,'s');
        end
        while str3 == 'Y'
            
            %maybe add restart and remove options (undo)
            if PopUpFreq > 0
                response=questdlg('Currently, only P waves already labeled in cyan may be added.', '', 'Add P Waves', 'Move on to QRS Selection', 'Move on to QRS Selection');
                switch response
                    case 'Add P Waves'
                        str3 = 'A';
                    case 'Move on to QRS Selection'
                        str3 = 'D';
                end
            else
                prompt = 'What would you like to do: add P waves (A), or are you done using the noise remover (D)? Enter A or D: ';
                str3 = input(prompt,'s');
                if str3 == 'D'
                    break
                end
            end
            if str3 == 'D'
                break
            end
            prompt=inputdlg('How many P waves would you like to add (1 to 5 at a time)? ');
            if PopUpFreq > 0
                x = str2num(prompt{1});
            else
                x = str2num(prompt{1});
            end
            if x < 1
                x = 1;
            end
            if x > 5
                x = 5;
            end
            StandardPopUpOrDisp('Select the P waves you would like to add.', PopUpFreq);
            for n = 1:x
                if str3 == 'A'
                    h=drawpoint('Visible','off');
                    newPoint=h.Position;
                    %finding the closest unused peak to the selected point
                    [selectedPeak,selectedLoc]=min((unusedPeakXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(TempData(unusedPeakXs) - newPoint(2))).^2);
                    xCoord = unusedPeakXs(selectedLoc);
                    yCoord = unusedPeakYs(selectedLoc);
                    unusedPeakXs(selectedLoc) = [];
                    unusedPeakYs(selectedLoc) = [];
                    %adding the peak in order
                    for index = 1:length(pInd)
                        if pInd(index) > xCoord
                            if index == 1
                                pInd = [xCoord pInd];
                                pIndYs = [yCoord pIndYs];
                            else
                                pInd = [pInd(1:index-1) xCoord pInd(index:end)];
                                pIndYs = [pIndYs(1:index-1) yCoord pIndYs(index:end)];
                            end
                            break;
                        end
                        if index == length(pInd)
                            pInd = [pInd xCoord];
                            pIndYs = [pIndYs yCoord];
                        end
                    end
                    plot(xCoord,yCoord,'r*','MarkerSize',10), hold on
                end
            end
            if str3 == 'A'
                str3 = 'Y';
            end
            %zooming out after edits
            xlim(size(TempData));
            ylim([0,1]);
        end
        
        StandardPopUpOrDisp('Select the first R Wave.', PopUpFreq);
        h=drawpoint('Visible','off');
        newPoint=h.Position;
        %finding the closest peak to the selected point
        [selectedPeak,selectedLoc]=min((unusedPeakXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(TempData(unusedPeakXs) - newPoint(2))).^2);
        plot(unusedPeakXs(selectedLoc),unusedPeakYs(selectedLoc),'k*','MarkerSize',10), hold on
        %set(handles.ROIaxes,'xticklabel',[])
        %set(handles.ROIaxes,'yticklabel',[])
        qInd = [qInd unusedPeakXs(selectedLoc)];
        qIndYs = [qIndYs unusedPeakYs(selectedLoc)];
        prevX = unusedPeakXs(selectedLoc);
        unusedPeakXs(selectedLoc) = [];
        unusedPeakYs(selectedLoc) = [];
        prevGap = prevX - pInd(1);
        pIndIndex = 2;
        while prevGap > lastRRGap * 0.5 || prevGap <= 0
            %if this loop is entered, prevGap, the PQRS gap, is in an
            %invalid range
            while prevGap > lastRRGap * 0.5
                %the graph must have started with multiple p peaks in a row, so
                %we must increment until we find the appropriate p peak
                prevGap = prevX - pInd(pIndIndex);
                pIndIndex = pIndIndex + 1;
            end
            secondLoopDone = false;
            while prevGap <= 0
                %need to find the next peak; the graph must have started with a
                %QRS so the program will continue until it finds the first QRS
                %peak after a P peak
                secondLoopDone = true;
                HighPopUpOrDisp('Please select the next R Wave.');
                h=drawpoint('Visible','off');
                newPoint=h.Position;
                %finding the closest peak to the selected point
                [selectedPeak,selectedLoc]=min((unusedPeakXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(TempData(unusedPeakXs) - newPoint(2))).^2);
                plot(unusedPeakXs(selectedLoc),unusedPeakYs(selectedLoc),'k*','MarkerSize',10), hold on
                %set(handles.ROIaxes,'xticklabel',[])
                %set(handles.ROIaxes,'yticklabel',[])
                qInd = [qInd unusedPeakXs(selectedLoc)];
                qIndYs = [qIndYs unusedPeakYs(selectedLoc)];
                prevX = unusedPeakXs(selectedLoc);
                unusedPeakXs(selectedLoc) = [];
                unusedPeakYs(selectedLoc) = [];
                prevGap = prevX - pInd(pIndIndex);
            end
            if secondLoopDone
                pIndIndex = pIndIndex + 1;
            end
        end
        
        while pIndIndex <= length(pInd)
            peaksInIntervalIndices= [];
            peaksInIntervalYs = [];
            problem = false;
            for i = 1:length(unusedPeakXs)
                if unusedPeakXs(i) > pInd(pIndIndex) + round(prevGap - PQRS_GAP_CONSTANT*prevGap) && unusedPeakXs(i) < pInd(pIndIndex) + round(prevGap + PQRS_GAP_CONSTANT*prevGap)
                    peaksInIntervalIndices = [peaksInIntervalIndices i];
                    peaksInIntervalYs = [peaksInIntervalYs unusedPeakYs(i)];
                end
            end
            if length(peaksInIntervalIndices) == 0
                %checking the next three peaks before making the user
                %step in
                added = 1;
                while added <= 3
                    if pIndIndex + added > length(pInd)
                        problem = true;
                        problemInd = [problemInd pInd(pIndIndex)];
                        problemIndYs = [problemIndYs pIndYs(pIndIndex)];
                        plot(pInd(pIndIndex),pIndYs(pIndIndex),'y*','MarkerSize',7), hold on
                        break
                    else
                        for i = 1:length(unusedPeakXs)
                            if unusedPeakXs(i) > pInd(pIndIndex + added) + round(prevGap - PQRS_GAP_CONSTANT*prevGap) && unusedPeakXs(i) < pInd(pIndIndex + added) + round(prevGap + PQRS_GAP_CONSTANT*prevGap)
                                peaksInIntervalIndices = [peaksInIntervalIndices i];
                                peaksInIntervalYs = [peaksInIntervalYs unusedPeakYs(i)];
                            end
                        end
                        if length(peaksInIntervalIndices) == 1
                            for  i = pIndIndex:pIndIndex+added-1
                                problemInd = [problemInd pInd(i)];
                                problemIndYs = [problemIndYs pIndYs(i)];
                                plot(pInd(i),pIndYs(i),'y*','MarkerSize',7), hold on
                            end
                            pIndIndex = pIndIndex + added;
                            break
                        end
                        added = added + 1;
                    end
                end
                if added == 4
                    problem = true;
                    problemInd = [problemInd pInd(pIndIndex)];
                    problemIndYs = [problemIndYs pIndYs(pIndIndex)];
                    plot(pInd(pIndIndex),pIndYs(pIndIndex),'y*','MarkerSize',7), hold on
                end
            end
            if length(peaksInIntervalIndices) > 1
                problem = true;
                problemInd = [problemInd pInd(pIndIndex)];
                problemIndYs = [problemIndYs pIndYs(pIndIndex)];
                plot(pInd(pIndIndex),pIndYs(pIndIndex),'y*','MarkerSize',7), hold on
                %set(handles.ROIaxes,'xticklabel',[])
                %set(handles.ROIaxes,'yticklabel',[])
            end
            if length(peaksInIntervalIndices) == 1
                ii = peaksInIntervalIndices(1);
                prevX = unusedPeakXs(ii);
                prevGap = round((prevX - pInd(pIndIndex) + prevGap)/2);
                qInd = [qInd unusedPeakXs(ii)];
                qIndYs = [qIndYs unusedPeakYs(ii)];
                plot(unusedPeakXs(ii),unusedPeakYs(ii),'k*','MarkerSize',10), hold on
                %set(handles.ROIaxes,'xticklabel',[])
                %set(handles.ROIaxes,'yticklabel',[])
                unusedPeakXs(ii)=[];
                unusedPeakYs(ii)=[];
            end
            while problem
                if pIndIndex == length(pInd)
                    break
                end
                HighPopUpOrDisp('Please select the next R Wave.');
                h=drawpoint('Visible','off');
                newPoint=h.Position;
                %finding the closest peak to the selected point
                [selectedPeak,selectedLoc]=min((unusedPeakXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(TempData(unusedPeakXs) - newPoint(2))).^2);
                plot(unusedPeakXs(selectedLoc),unusedPeakYs(selectedLoc),'k*','MarkerSize',10), hold on
                %set(handles.ROIaxes,'xticklabel',[])
                %set(handles.ROIaxes,'yticklabel',[])
                qInd = [qInd unusedPeakXs(selectedLoc)];
                qIndYs = [qIndYs unusedPeakYs(selectedLoc)];
                problemInd = [problemInd unusedPeakXs(selectedLoc)];
                problemIndYs = [problemIndYs unusedPeakYs(selectedLoc)];
                plot(unusedPeakXs(selectedLoc),unusedPeakYs(selectedLoc),'y*','MarkerSize',7), hold on
                %set(handles.ROIaxes,'xticklabel',[])
                %set(handles.ROIaxes,'yticklabel',[])
                prevX = unusedPeakXs(selectedLoc);
                unusedPeakXs(selectedLoc) = [];
                unusedPeakYs(selectedLoc) = [];
                oldGap = prevGap;
                prevGap = prevX - pInd(pIndIndex);
                while prevGap > 2 * oldGap
                    pIndIndex = pIndIndex + 1;
                    prevGap = prevX - pInd(pIndIndex);
                end
                if prevGap > 0 && prevGap < 2 * oldGap
                    problem = false;
                end
                if prevGap < 0
                    %may be better served by a while loop in case pIndIndex
                    %got too far ahead
                    prevGap = round(oldGap * 1.15); %allows the prevGap to grow when the PQRS gap is consistenly larger
                end
            end
            pIndIndex = pIndIndex + 1;
        end
        
    else
        %QRS peaks > P peaks
        StandardPopUpOrDisp('Select the height of the R Wave with the lowest amplitude.', PopUpFreq);
        h=drawpoint('Visible', 'off');
        drawline('Position', [0, h.Position(2); length(TempData), h.Position(2)]);
        lowestHeight = h.Position(2) - 0.02; %setting slightly lower in case the user doesn't realize the line is a little high
        
        StandardPopUpOrDisp('Select the first R Wave.', PopUpFreq);
        h=drawpoint('Visible','off');
        newPoint=h.Position;
        %finding the closest peak to the selected point
        [selectedPeak,selectedLoc]=min((unusedPeakXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(TempData(unusedPeakXs) - newPoint(2))).^2);
        plot(unusedPeakXs(selectedLoc),unusedPeakYs(selectedLoc),'k*','MarkerSize',10), hold on
        %set(handles.ROIaxes,'xticklabel',[])
        %set(handles.ROIaxes,'yticklabel',[])
        qInd = [qInd unusedPeakXs(selectedLoc)];
        qIndYs = [qIndYs unusedPeakYs(selectedLoc)];
        xHolder = unusedPeakXs(selectedLoc);
        unusedPeakXs(selectedLoc) = [];
        unusedPeakYs(selectedLoc) = [];

        if PopUpFreq == 1
            StandardPopUpOrDisp('Select the second R Wave. Note: further instructions will come through the console until all R waves are selected.', PopUpFreq);
        else
            StandardPopUpOrDisp('Select the second R Wave.', PopUpFreq);
        end
        h=drawpoint('Visible','off');
        newPoint=h.Position;
        %finding the closest peak to the selected point
        [selectedPeak,selectedLoc]=min((unusedPeakXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(TempData(unusedPeakXs) - newPoint(2))).^2);
        plot(unusedPeakXs(selectedLoc),unusedPeakYs(selectedLoc),'k*','MarkerSize',10), hold on
        %set(handles.ROIaxes,'xticklabel',[])
        %set(handles.ROIaxes,'yticklabel',[])
        qInd = [qInd unusedPeakXs(selectedLoc)];
        qIndYs = [qIndYs unusedPeakYs(selectedLoc)];
        prevX = unusedPeakXs(selectedLoc);
        prevGap =  prevX - xHolder;
        unusedPeakXs(selectedLoc) = [];
        unusedPeakYs(selectedLoc) = [];
        index = prevX + prevGap;
        prevHadProblem = false;
        while index < length(TempData)
            peaksInIntervalIndices= [];
            peaksInIntervalYs = [];
            for i = 1:length(unusedPeakXs)
                if unusedPeakXs(i) > index - round(RR_GAP_CONSTANT_LEFT*prevGap) && unusedPeakXs(i) < index + round(RR_GAP_CONSTANT_RIGHT*prevGap) && unusedPeakYs(i) > lowestHeight
                    peaksInIntervalIndices = [peaksInIntervalIndices i];
                    peaksInIntervalYs = [peaksInIntervalYs unusedPeakYs(i)];
                end
            end
            
            if length(peaksInIntervalIndices) == 0
                %trying again, but more liberal on the right side
                for i = 1:length(unusedPeakXs)
                    if unusedPeakXs(i) > index - round(RR_GAP_CONSTANT_LEFT*RR_GAP_CONSTANT_LEFT_BACKUP_MULTIPLIER*prevGap) && unusedPeakXs(i) < index + round(RR_GAP_CONSTANT_RIGHT*RR_GAP_CONSTANT_RIGHT_BACKUP_MULTIPLIER*prevGap) && unusedPeakYs(i) > lowestHeight
                        peaksInIntervalIndices = [peaksInIntervalIndices i];
                        peaksInIntervalYs = [peaksInIntervalYs unusedPeakYs(i)];
                    end
                end
            end
            
            if length(peaksInIntervalIndices) == 0
                if index + prevGap > length(TempData)
                    break
                end
                HighPopUpOrDisp('Please select the next R Wave.', PopUpFreq);
                h=drawpoint('Visible','off');
                newPoint=h.Position;
                
                %finding the closest peak to the selected point
                [selectedPeak,selectedLoc]=min((unusedPeakXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(TempData(unusedPeakXs) - newPoint(2))).^2);
                plot(unusedPeakXs(selectedLoc),unusedPeakYs(selectedLoc),'k*','MarkerSize',10), hold on
                %set(handles.ROIaxes,'xticklabel',[])
                %set(handles.ROIaxes,'yticklabel',[])
                qInd = [qInd unusedPeakXs(selectedLoc)];
                qIndYs = [qIndYs unusedPeakYs(selectedLoc)];
                if prevHadProblem == true
                    prevGap = round((unusedPeakXs(selectedLoc) - prevX + prevGap)/2);
                end
                prevX = unusedPeakXs(selectedLoc);
                problemInd = [problemInd prevX];
                problemIndYs = [problemIndYs TempData(prevX)];
                plot(prevX,TempData(prevX),'y*','MarkerSize',7), hold on
                %set(handles.ROIaxes,'xticklabel',[])
                %set(handles.ROIaxes,'yticklabel',[])
                unusedPeakXs(selectedLoc) = [];
                unusedPeakYs(selectedLoc) = [];
                index = prevX + prevGap;
                prevHadProblem = true;
            else
                prevHadProblem = false;
                [selectedPeak,selectedLoc]=max(peaksInIntervalYs);
                ii = peaksInIntervalIndices(selectedLoc);
                prevGap = round((unusedPeakXs(ii) - prevX + prevGap)/2);
                prevX = unusedPeakXs(ii);
                qInd = [qInd unusedPeakXs(ii)];
                qIndYs = [qIndYs unusedPeakYs(ii)];
                plot(unusedPeakXs(ii),unusedPeakYs(ii),'k*','MarkerSize',10), hold on
                %set(handles.ROIaxes,'xticklabel',[])
                %set(handles.ROIaxes,'yticklabel',[])
                unusedPeakXs(ii)=[];
                unusedPeakYs(ii)=[];
            end
            index = prevX + prevGap;
        end
        
        lastRRGap = prevGap;
        
        %allowing the user to edit the found QRS peaks; zooming out first
        xlim(size(TempData));
        ylim([0,1]);
        if PopUpFreq > 0
            response=questdlg('Would you like to edit the R waves?', '', 'Yes', 'No', 'No');
            switch response
                case 'Yes'
                    str3 = 'Y';
                case 'No'
                    str3 = 'N';
            end
        else
            prompt = 'Would you like to edit the R waves? Enter Y or N: ';
            str3 = input(prompt,'s');
        end
        while str3 == 'Y'
            if PopUpFreq > 0
                response=questdlg('Currently, only R waves already labeled in cyan may be added.', '', 'Add R Waves', 'Move on to P Wave Selection', 'Move on to P Wave Selection');
                switch response
                    case 'Add R Waves'
                        str3 = 'A';
                    case 'Move on to P Wave Selection'
                        break
                    case 'Cancel'
                        return
                end
            else
                prompt = 'What would you like to do: add R waves (A), or are you done (D)? Enter A or D: ';
                str3 = input(prompt,'s');
                if str3 == 'D'
                    break
                end
            end
            prompt=inputdlg('How many R waves would you like to add (1 to 5 at a time)? ');
            if PopUpFreq > 0
                x = str2num(prompt{1});
            else
                x = str2num(prompt{1});
            end
            if x < 1
                x = 1;
            end
            if x > 5
                x = 5;
            end
            StandardPopUpOrDisp('Select the R waves you would like to add.', PopUpFreq);
            for n = 1:x
                if str3 == 'A'
                    h=drawpoint('Visible','off');
                    newPoint=h.Position;
                    
                    %finding the closest unused peak to the selected point
                    [selectedPeak,selectedLoc]=min((unusedPeakXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(TempData(unusedPeakXs) - newPoint(2))).^2);
                    xCoord = unusedPeakXs(selectedLoc);
                    yCoord = unusedPeakYs(selectedLoc);
                    unusedPeakXs(selectedLoc) = [];
                    unusedPeakYs(selectedLoc) = [];
                    %adding the peak in order
                    for index = 1:length(qInd)
                        if qInd(index) > xCoord
                            if index == 1
                                qInd = [xCoord qInd];
                                qIndYs = [yCoord qIndYs];
                            else
                                qInd = [qInd(1:index-1) xCoord qInd(index:end)];
                                qIndYs = [qIndYs(1:index-1) yCoord qIndYs(index:end)];
                            end
                            break;
                        end
                        if index == length(qInd)
                            qInd = [qInd xCoord];
                            qIndYs = [qIndYs yCoord];
                        end
                    end
                    plot(xCoord,yCoord,'k*','MarkerSize',10), hold on
                    %set(handles.ROIaxes,'xticklabel',[])
                    %set(handles.ROIaxes,'yticklabel',[])
                end            
            end
            if str3 == 'A'
                str3 = 'Y';
            end
            %zooming out after edits
            xlim(size(TempData));
            ylim([0,1]);
        end
        
        StandardPopUpOrDisp('Select the first P Wave.', PopUpFreq);
        h=drawpoint('Visible','off');
        newPoint=h.Position;
        
        %finding the closest peak to the selected point
        [selectedPeak,selectedLoc]=min((unusedPeakXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(TempData(unusedPeakXs) - newPoint(2))).^2);
        plot(unusedPeakXs(selectedLoc),unusedPeakYs(selectedLoc),'r*','MarkerSize',10), hold on
        %set(handles.ROIaxes,'xticklabel',[])
        %set(handles.ROIaxes,'yticklabel',[])
        pInd = [pInd unusedPeakXs(selectedLoc)];
        pIndYs = [pIndYs unusedPeakYs(selectedLoc)];
        prevX = unusedPeakXs(selectedLoc);
        unusedPeakXs(selectedLoc) = [];
        unusedPeakYs(selectedLoc) = [];
        prevGap = qInd(1) - prevX;
        qIndIndex = 2;
        firstLoopDone = false;
        while prevGap > lastRRGap * 0.5 || prevGap <= 0
            %if this loop is entered, prevGap, the gap between a pair of
            %indices, is in an invalid range
            while prevGap > lastRRGap * 0.5
                %need to find the next P peak; the graph must have started with a
                %set of several P peaks in a row, and these need to be defined
                %by the user
                firstLoopDone = true;
                HighPopUpOrDisp('Please select the next P Wave.');
                h=drawpoint('Visible','off');
                newPoint=h.Position;
                
                %finding the closest peak to the selected point
                [selectedPeak,selectedLoc]=min((unusedPeakXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(TempData(unusedPeakXs) - newPoint(2))).^2);
                plot(unusedPeakXs(selectedLoc),unusedPeakYs(selectedLoc),'r*','MarkerSize',10), hold on
                %set(handles.ROIaxes,'xticklabel',[])
                %set(handles.ROIaxes,'yticklabel',[])
                pInd = [pInd unusedPeakXs(selectedLoc)];
                pIndYs = [pIndYs unusedPeakYs(selectedLoc)];
                prevX = unusedPeakXs(selectedLoc);
                unusedPeakXs(selectedLoc) = [];
                unusedPeakYs(selectedLoc) = [];
                %finding the nearest pInd before;
                prevGap = qInd(qIndIndex) - prevX;
            end
            if firstLoopDone == true
                qIndIndex = qIndIndex + 1;
            end
            %dealing with the case where the P peak is ahead of the QRS peak
            while prevGap <= 0
                prevGap = qInd(qIndIndex) - prevX;
                qIndIndex = qIndIndex + 1;
            end
        end
        %now that prevGap is in a valid range, we can proceed
        while qIndIndex <= length(qInd)
            peaksInIntervalIndices= [];
            peaksInIntervalYs = [];
            problem = false;
            for i = 1:length(unusedPeakXs)
                if unusedPeakXs(i) > qInd(qIndIndex) - round(prevGap + PQRS_GAP_CONSTANT*prevGap) && unusedPeakXs(i) < qInd(qIndIndex) - round(prevGap - PQRS_GAP_CONSTANT*prevGap)
                    peaksInIntervalIndices = [peaksInIntervalIndices i];
                    peaksInIntervalYs = [peaksInIntervalYs unusedPeakYs(i)];
                end
            end
            if length(peaksInIntervalIndices) == 0
                %checking the next three peaks before making the user
                %step in
                added = 1;
                while added <= 3
                    if qIndIndex + added > length(qInd)
                        problem = true;
                        problemInd = [problemInd qInd(qIndIndex)];
                        problemIndYs = [problemIndYs qIndYs(qIndIndex)];
                        plot(qInd(qIndIndex),qIndYs(qIndIndex),'y*','MarkerSize',7), hold on
                        %set(handles.ROIaxes,'xticklabel',[])
                        %set(handles.ROIaxes,'yticklabel',[])
                        break
                    else
                        for i = 1:length(unusedPeakXs)
                            if unusedPeakXs(i) > qInd(qIndIndex + added) - round(prevGap + PQRS_GAP_CONSTANT*prevGap) && unusedPeakXs(i) < qInd(qIndIndex + added) - round(prevGap - PQRS_GAP_CONSTANT*prevGap)
                                peaksInIntervalIndices = [peaksInIntervalIndices i];
                                peaksInIntervalYs = [peaksInIntervalYs unusedPeakYs(i)];
                            end
                        end
                        if length(peaksInIntervalIndices) == 1
                            for  i = qIndIndex:qIndIndex+added-1
                                problemInd = [problemInd qInd(i)];
                                problemIndYs = [problemIndYs qIndYs(i)];
                                plot(qInd(i),qIndYs(i),'y*','MarkerSize',7), hold on
                                %set(handles.ROIaxes,'xticklabel',[])
                                %set(handles.ROIaxes,'yticklabel',[])
                            end
                            qIndIndex = qIndIndex + added;
                            break
                        end
                        added = added + 1;
                    end
                end
                if added == 4
                    problem = true;
                    problemInd = [problemInd qInd(qIndIndex)];
                    problemIndYs = [problemIndYs qIndYs(qIndIndex)];
                    plot(qInd(qIndIndex),qIndYs(qIndIndex),'y*','MarkerSize',7), hold on
                    %set(handles.ROIaxes,'xticklabel',[])
                    %set(handles.ROIaxes,'yticklabel',[])
                end
            end
            if length(peaksInIntervalIndices) > 1
                problem = true;
                problemInd = [problemInd qInd(qIndIndex)];
                problemIndYs = [problemIndYs qIndYs(qIndIndex)];
                plot(qInd(qIndIndex),qIndYs(qIndIndex),'y*','MarkerSize',7), hold on
                %set(handles.ROIaxes,'xticklabel',[])
                %set(handles.ROIaxes,'yticklabel',[])
            end
            if length(peaksInIntervalIndices) == 1
                ii = peaksInIntervalIndices(1);
                prevX = unusedPeakXs(ii);
                prevGap = round((qInd(qIndIndex) - prevX + prevGap)/2);
                pInd = [pInd unusedPeakXs(ii)];
                pIndYs = [pIndYs unusedPeakYs(ii)];
                plot(unusedPeakXs(ii),unusedPeakYs(ii),'r*','MarkerSize',10), hold on
                %set(handles.ROIaxes,'xticklabel',[])
                %set(handles.ROIaxes,'yticklabel',[])
                unusedPeakXs(ii)=[];
                unusedPeakYs(ii)=[];
            end
            while problem
                if qIndIndex == length(qInd)
                    break
                end
                HighPopUpOrDisp('Please select the next P Wave.');
                h=drawpoint('Visible','off');
                newPoint=h.Position;
                
                %finding the closest peak to the selected point
                [selectedPeak,selectedLoc]=min((unusedPeakXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(TempData(unusedPeakXs) - newPoint(2))).^2);
                plot(unusedPeakXs(selectedLoc),unusedPeakYs(selectedLoc),'r*','MarkerSize',10), hold on
                %set(handles.ROIaxes,'xticklabel',[])
                %set(handles.ROIaxes,'yticklabel',[])
                pInd = [pInd unusedPeakXs(selectedLoc)];
                pIndYs = [pIndYs unusedPeakYs(selectedLoc)];
                problemInd = [problemInd unusedPeakXs(selectedLoc)];
                problemIndYs = [problemIndYs unusedPeakYs(selectedLoc)];
                plot(unusedPeakXs(selectedLoc),unusedPeakYs(selectedLoc),'y*','MarkerSize',7), hold on
                %set(handles.ROIaxes,'xticklabel',[])
                %set(handles.ROIaxes,'yticklabel',[])
                prevX = unusedPeakXs(selectedLoc);
                unusedPeakXs(selectedLoc) = [];
                unusedPeakYs(selectedLoc) = [];
                oldGap = prevGap;
                prevGap = qInd(qIndIndex) - prevX;
                while prevGap <= 0
                    qIndIndex = qIndIndex + 1;
                    prevGap = qInd(qIndIndex) - prevX;
                end
                if prevGap > 0 && prevGap < 2 * oldGap
                    problem = false;
                end
                if prevGap >= 2 * oldGap
                    %this may be better served with a while loop in case
                    %qIndIndex got too far ahead
                    prevGap = round(oldGap * 1.15); %allows the prevGap to grow when the PQRS gap is consistenly larger
                end
            end
            qIndIndex = qIndIndex + 1;
        end
    end
    
else
    RR_GAP_CONSTANT_LEFT = 0.5;
    RR_GAP_CONSTANT_RIGHT = 0.3;
    CONSERVATIVE_ADJUSTMENT_CONSTANT = 7; %higher means more conservative for these three
    MODERATE_ADJUSTMENT_CONSTANT = 3;
    LIBERAL_ADJUSTMENT_CONSTANT = 1;
    PQRS_GAP_CONSTANT = 0.15;
    PQRS_GAP_CONSTANT_BACKUP_MULTIPLIER = 2.5;
    
    StandardPopUpOrDisp('Select the first P Wave.', PopUpFreq);
    h=drawpoint('Visible','off');
    newPoint=h.Position;
    %finding the closest peak to the selected point
    [selectedPeak,selectedLoc]=min((unusedPeakXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(TempData(unusedPeakXs) - newPoint(2))).^2);
    plot(unusedPeakXs(selectedLoc),unusedPeakYs(selectedLoc),'r*','MarkerSize',10), hold on
    %set(handles.ROIaxes,'xticklabel',[])
    %set(handles.ROIaxes,'yticklabel',[])
    pInd = [pInd unusedPeakXs(selectedLoc)];
    pIndYs = [pIndYs unusedPeakYs(selectedLoc)];
    unusedPeakXs(selectedLoc) = [];
    unusedPeakYs(selectedLoc) = [];
    
    StandardPopUpOrDisp('Select the second P Wave.', PopUpFreq);
    h=drawpoint('Visible','off');
    newPoint=h.Position;
    %finding the closest peak to the selected point
    [selectedPeak,selectedLoc]=min((unusedPeakXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(TempData(unusedPeakXs) - newPoint(2))).^2);
    plot(unusedPeakXs(selectedLoc),unusedPeakYs(selectedLoc),'r*','MarkerSize',10), hold on
    %set(handles.ROIaxes,'xticklabel',[])
    %set(handles.ROIaxes,'yticklabel',[])
    pInd = [pInd unusedPeakXs(selectedLoc)];
    pIndYs = [pIndYs unusedPeakYs(selectedLoc)];
    unusedPeakXs(selectedLoc) = [];
    unusedPeakYs(selectedLoc) = [];
    
    StandardPopUpOrDisp('Select the first R Wave.', PopUpFreq);
    h=drawpoint('Visible','off');
    newPoint=h.Position;
    %finding the closest peak to the selected point
    [selectedPeak,selectedLoc]=min((unusedPeakXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(TempData(unusedPeakXs) - newPoint(2))).^2);
    plot(unusedPeakXs(selectedLoc),unusedPeakYs(selectedLoc),'k*','MarkerSize',10), hold on
    %set(handles.ROIaxes,'xticklabel',[])
    %set(handles.ROIaxes,'yticklabel',[])
    qInd = [qInd unusedPeakXs(selectedLoc)];
    qIndYs = [qIndYs unusedPeakYs(selectedLoc)];
    unusedPeakXs(selectedLoc) = [];
    unusedPeakYs(selectedLoc) = [];
    
    if PopUpFreq == 1
        StandardPopUpOrDisp('Select the second R Wave. Note: further instructions will come through the console until all waves are selected.', PopUpFreq);
    else
        StandardPopUpOrDisp('Select the second R Wave.', PopUpFreq);
    end
    h=drawpoint('Visible','off');
    newPoint=h.Position;
    %finding the closest peak to the selected point
    [selectedPeak,selectedLoc]=min((unusedPeakXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(TempData(unusedPeakXs) - newPoint(2))).^2);
    plot(unusedPeakXs(selectedLoc),unusedPeakYs(selectedLoc),'k*','MarkerSize',10), hold on
    %set(handles.ROIaxes,'xticklabel',[])
    %set(handles.ROIaxes,'yticklabel',[])
    qInd = [qInd unusedPeakXs(selectedLoc)];
    qIndYs = [qIndYs unusedPeakYs(selectedLoc)];
    unusedPeakXs(selectedLoc) = [];
    unusedPeakYs(selectedLoc) = [];
    
    problem = false;
    problemWasTrue = false;
    
    qrsGap = 0;
    rrGap = 0;
    
    %if the first two sets do not represent normal P/QRS pairings, then we
    %will continue into a problem loop
    if qInd(1) - pInd(1) < 0 || qInd(2) - pInd(2) < 0 || qInd(1) > pInd(2)|| qInd(1) - pInd(1) > 0.5 * (qInd(2) - qInd(1)) || qInd(2) - pInd(2) > 0.5 * (qInd(2) - qInd(1)) || qInd(2) - pInd(2) > (1+PQRS_GAP_CONSTANT) * (qInd(1) - pInd(1)) || qInd(1) - pInd(1) > (1+PQRS_GAP_CONSTANT) * (qInd(1) - pInd(1))
        problem = true;
        problemWasTrue = true;
    else
        qrsGap = qInd(1) - pInd(1);
        rrGap = qInd(2) - qInd(1);
    end
    
    %ensuring that the program does not automate peak-coloring without two
    %consecutive P-QRS peak pairings
    while problem
        while qInd(length(qInd)-1) > pInd(length(pInd))
            HighPopUpOrDisp('Select the next P Wave.', PopUpFreq);
            h=drawpoint('Visible','off');
            
            newPoint=h.Position;
            %finding the closest peak to the selected point
            [selectedPeak,selectedLoc]=min((unusedPeakXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(TempData(unusedPeakXs) - newPoint(2))).^2);
            plot(unusedPeakXs(selectedLoc),unusedPeakYs(selectedLoc),'r*','MarkerSize',10), hold on
            %set(handles.ROIaxes,'xticklabel',[])
            %set(handles.ROIaxes,'yticklabel',[])
            pInd = [pInd unusedPeakXs(selectedLoc)];
            pIndYs = [pIndYs unusedPeakYs(selectedLoc)];
            unusedPeakXs(selectedLoc) = [];
            unusedPeakYs(selectedLoc) = [];
        end
        while qInd(length(qInd)) < pInd(length(pInd))
            HighPopUpOrDisp('Select the next R Wave.', PopUpFreq);
            h=drawpoint('Visible','off');
            
            newPoint=h.Position;
            %finding the closest peak to the selected point
            [selectedPeak,selectedLoc]=min((unusedPeakXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(TempData(unusedPeakXs) - newPoint(2))).^2);
            plot(unusedPeakXs(selectedLoc),unusedPeakYs(selectedLoc),'k*','MarkerSize',10), hold on
            %set(handles.ROIaxes,'xticklabel',[])
            %set(handles.ROIaxes,'yticklabel',[])
            qInd = [qInd unusedPeakXs(selectedLoc)];
            qIndYs = [qIndYs unusedPeakYs(selectedLoc)];
            unusedPeakXs(selectedLoc) = [];
            unusedPeakYs(selectedLoc) = [];
        end
        p = length(pInd);
        q = length(qInd);
        %if the  following conditional is not met, then the last two elements of pInd and qInd do
        %not respectively represent normal P/QRS pairings
        if qInd(q-1) - pInd(p-1) < 0 || qInd(q) - pInd(p) < 0 || qInd(q-1) > pInd(p)|| qInd(q-1) - pInd(p-1) > 0.5 * (qInd(q) - qInd(q-1)) || qInd(q) - pInd(p) > 0.5 * (qInd(q) - qInd(q-1)) || qInd(q) - pInd(p) > (1+PQRS_GAP_CONSTANT) * (qInd(q-1) - pInd(p-1)) || qInd(q-1) - pInd(p-1) > (1+PQRS_GAP_CONSTANT) * (qInd(q) - pInd(p))
            problem = true;
            HighPopUpOrDisp('Select the next P Wave.', PopUpFreq);
            h=drawpoint('Visible','off');
            newPoint=h.Position;
            
            %finding the closest peak to the selected point
            [selectedPeak,selectedLoc]=min((unusedPeakXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(TempData(unusedPeakXs) - newPoint(2))).^2);
            plot(unusedPeakXs(selectedLoc),unusedPeakYs(selectedLoc),'r*','MarkerSize',10), hold on
            %set(handles.ROIaxes,'xticklabel',[])
            %set(handles.ROIaxes,'yticklabel',[])
            pInd = [pInd unusedPeakXs(selectedLoc)];
            pIndYs = [pIndYs unusedPeakYs(selectedLoc)];
            unusedPeakXs(selectedLoc) = [];
            unusedPeakYs(selectedLoc) = [];
            
            HighPopUpOrDisp('Select the next R Wave.', PopUpFreq);
            h=drawpoint('Visible','off');
            newPoint=h.Position;
            
            %finding the closest peak to the selected point
            [selectedPeak,selectedLoc]=min((unusedPeakXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(TempData(unusedPeakXs) - newPoint(2))).^2);
            plot(unusedPeakXs(selectedLoc),unusedPeakYs(selectedLoc),'k*','MarkerSize',10), hold on
            %set(handles.ROIaxes,'xticklabel',[])
            %set(handles.ROIaxes,'yticklabel',[])
            qInd = [qInd unusedPeakXs(selectedLoc)];
            qIndYs = [qIndYs unusedPeakYs(selectedLoc)];
            unusedPeakXs(selectedLoc) = [];
            unusedPeakYs(selectedLoc) = [];
        else
            problem = false;
        end
    end
    
    %may make more sense to use pairings to do this all at the end; unsure
    %yet
    if problemWasTrue
        problemInd = [pInd(1:length(pInd)-2) qInd(1:length(qInd)-2)];
        problemIndYs = [pIndYs(1:length(pIndYs)-2) qIndYs(1:length(qIndYs)-2)];
        plot(problemInd,problemIndYs,'y*','MarkerSize',7), hold on
        %set(handles.ROIaxes,'xticklabel',[])
        %set(handles.ROIaxes,'yticklabel',[])
    end
    
    %saving pInd and qInd pairings for later use; first row is pInd that
    %pair with second row qInd
    pairings = [length(pInd)-1 length(pInd) ; length(qInd)-1 length(qInd)];
    prevRRGap = qInd(length(qInd)) - qInd(length(qInd)-1);
    prevPQRSGap = qInd(pairings(2, 2)) - pInd(pairings(1, 2));
    adjustPQRS = true;
    qIndex = qInd(length(qInd)) + prevRRGap;
    pIndex = pInd(length(pInd)) + prevRRGap;
    times = 0; %failsafe for certain cases where the program gets stuck in the loop; assuming there are never more than 10000 peaks
    arrInARow = 0;
    ALLOWED_ARR_IN_A_ROW = 4;
    
    while(pIndex < length(TempData))
        times = times + 1;
        if (times > 10000)
            break
        end
        peaksInIntervalIndices= [];
        n = length(pairings);
        if adjustPQRS
            if qInd(pairings(2, n)) - pInd(pairings(1, n)) > 2 * prevPQRSGap
                prevPQRSGap = (qInd(pairings(2, n)) - pInd(pairings(1, n)) + CONSERVATIVE_ADJUSTMENT_CONSTANT*prevPQRSGap)/(CONSERVATIVE_ADJUSTMENT_CONSTANT + 1);
            else
                prevPQRSGap = (qInd(pairings(2, n)) - pInd(pairings(1, n)) + MODERATE_ADJUSTMENT_CONSTANT*prevPQRSGap)/(MODERATE_ADJUSTMENT_CONSTANT + 1); %still adjusts conservatively
            end
            arrInARow = 0;
        else
            adjustPQRS = true;
        end
        problem = false;
        for i = 1:length(unusedPeakXs)
            if unusedPeakXs(i) > pIndex - RR_GAP_CONSTANT_LEFT*prevRRGap && unusedPeakXs(i) < qIndex + RR_GAP_CONSTANT_RIGHT*prevRRGap
                peaksInIntervalIndices = [peaksInIntervalIndices i];
            end
        end
        if length(peaksInIntervalIndices) == 0 && qIndex + prevRRGap > length(TempData)
            break
        end
        %finding highest peak in the interval
        tallestPeakIndex = 0;
        tallestPeakHeight = 0;
        for i = 1:length(peaksInIntervalIndices)
            if TempData(unusedPeakXs(peaksInIntervalIndices(i))) > tallestPeakHeight
                tallestPeakHeight = TempData(unusedPeakXs(peaksInIntervalIndices(i)));
                tallestPeakIndex = peaksInIntervalIndices(i);
            end
        end
        %Appropriately spaced peaks indicies
        aspi = [];
        if tallestPeakIndex ~= 0
            %adding nearby peaks
            for i = 1:length(unusedPeakXs)
                if abs(unusedPeakXs(i) - unusedPeakXs(tallestPeakIndex)) < (1 + PQRS_GAP_CONSTANT)*prevPQRSGap
                    peaksInIntervalIndices = [peaksInIntervalIndices i];
                end
            end
            %removing duplicate points
            index = 1;
            while index <= length(peaksInIntervalIndices)-1
                index2 = index + 1;
                while index2 <= length(peaksInIntervalIndices)
                    if (peaksInIntervalIndices(index)==peaksInIntervalIndices(index2))
                        peaksInIntervalIndices(index2) = [];
                    else
                        index2 = index2 + 1;
                    end
                end
                index = index + 1;
            end
            for jj = 1:length(peaksInIntervalIndices)
                if peaksInIntervalIndices(jj) ~= tallestPeakIndex && abs(unusedPeakXs(tallestPeakIndex) - unusedPeakXs(peaksInIntervalIndices(jj))) < (1+PQRS_GAP_CONSTANT)*prevPQRSGap && abs(unusedPeakXs(tallestPeakIndex) - unusedPeakXs(peaksInIntervalIndices(jj))) > (1-PQRS_GAP_CONSTANT)*prevPQRSGap
                    aspi = [aspi peaksInIntervalIndices(jj)];
                end
            end
        end
        %disp(aspi)
        %If none were found, run a second check with a more liberal PQRS
        %gap
        if tallestPeakIndex ~= 0 && length(aspi) == 0
            %adding nearby peaks
            for i = 1:length(unusedPeakXs)
                if abs(unusedPeakXs(i) - unusedPeakXs(tallestPeakIndex)) < (1 + PQRS_GAP_CONSTANT * PQRS_GAP_CONSTANT_BACKUP_MULTIPLIER)*prevPQRSGap
                    peaksInIntervalIndices = [peaksInIntervalIndices i];
                end
            end
            %removing duplicate points
            index = 1;
            while index <= length(peaksInIntervalIndices)-1
                index2 = index + 1;
                while index2 <= length(peaksInIntervalIndices)
                    if (peaksInIntervalIndices(index)==peaksInIntervalIndices(index2))
                        peaksInIntervalIndices(index2) = [];
                    else
                        index2 = index2 + 1;
                    end
                end
                index = index + 1;
            end
            for jj = 1:length(peaksInIntervalIndices)
                if peaksInIntervalIndices(jj) ~= tallestPeakIndex && abs(unusedPeakXs(tallestPeakIndex) - unusedPeakXs(peaksInIntervalIndices(jj))) < (1+PQRS_GAP_CONSTANT*PQRS_GAP_CONSTANT_BACKUP_MULTIPLIER)*prevPQRSGap && abs(unusedPeakXs(tallestPeakIndex) - unusedPeakXs(peaksInIntervalIndices(jj))) > (1-PQRS_GAP_CONSTANT*PQRS_GAP_CONSTANT_BACKUP_MULTIPLIER)*prevPQRSGap
                    aspi = [aspi peaksInIntervalIndices(jj)];
                end
            end
        end
        if length(aspi) == 1
            pIndex = unusedPeakXs(aspi(1));
            qIndex = unusedPeakXs(tallestPeakIndex);
            if (pIndex > qIndex)
                holder = pIndex;
                pIndex = qIndex;
                qIndex = holder;
            end
            if tallestPeakIndex > aspi(1)
                unusedPeakXs(tallestPeakIndex) = [];
                unusedPeakYs(tallestPeakIndex) = [];
                unusedPeakXs(aspi(1)) = [];
                unusedPeakYs(aspi(1)) = [];
            else
                unusedPeakXs(aspi(1)) = [];
                unusedPeakYs(aspi(1)) = [];
                unusedPeakXs(tallestPeakIndex) = [];
                unusedPeakYs(tallestPeakIndex) = [];
            end
            pInd = [pInd pIndex];
            pIndYs = [pIndYs TempData(pIndex)];
            qInd = [qInd qIndex];
            qIndYs = [qIndYs TempData(qIndex)];
            plot(pIndex,TempData(pIndex),'r*','MarkerSize',10), hold on
            plot(qIndex,TempData(qIndex),'k*','MarkerSize',10), hold on
            %set(handles.ROIaxes,'xticklabel',[])
            %set(handles.ROIaxes,'yticklabel',[])
            pairings = [pairings(1, :) length(pInd); pairings(2, :) length(qInd)];
            %using pInd because there are cases where qInd lags behind when
            %only one peak was found previously
            prevRRGap = (LIBERAL_ADJUSTMENT_CONSTANT*prevRRGap + pInd(length(pInd)) - pInd(length(pInd) -1))/(LIBERAL_ADJUSTMENT_CONSTANT + 1); %keeping the changes somewhat conservative through an average
            qIndex = qInd(length(qInd)) + prevRRGap;
            pIndex = pInd(length(pInd)) + prevRRGap;
        else
            if length(aspi) == 0 && tallestPeakIndex ~= 0 && arrInARow < ALLOWED_ARR_IN_A_ROW
                pIndex = unusedPeakXs(tallestPeakIndex);
                unusedPeakXs(tallestPeakIndex) = [];
                unusedPeakYs(tallestPeakIndex) = [];
                pInd = [pInd pIndex];
                pIndYs = [pIndYs TempData(pIndex)];
                plot(pIndex,TempData(pIndex),'r*','MarkerSize',10), hold on
                problemInd = [problemInd pIndex];
                problemIndYs = [problemIndYs pIndex];
                plot(pIndex,TempData(pIndex),'y*','MarkerSize',7), hold on
                %set(handles.ROIaxes,'xticklabel',[])
                %set(handles.ROIaxes,'yticklabel',[])
                if pInd(length(pInd)) - pInd(length(pInd) -1) < 2 * prevRRGap && pInd(length(pInd)) - pInd(length(pInd) -1) > 0.5 * prevRRGap
                    %keeping the changes more conservative b/c this peak
                    %is more likely to have been placed incorrectly than a
                    %pairing
                    prevRRGap = (CONSERVATIVE_ADJUSTMENT_CONSTANT*prevRRGap + pInd(length(pInd)) - pInd(length(pInd) -1))/(CONSERVATIVE_ADJUSTMENT_CONSTANT + 1);
                end
                pIndex = pIndex + prevRRGap;
                qIndex = pIndex + prevPQRSGap;
                adjustPQRS = false;
                arrInARow = arrInARow + 1;
            else
                problem = true;
            end
        end
        if problem
            if pIndex + RR_GAP_CONSTANT_RIGHT*prevRRGap > length(TempData)
                problem = false;
            else
                HighPopUpOrDisp('Select the next P Wave.', PopUpFreq);
                h=drawpoint('Visible','off');
                newPoint=h.Position;
                
                %finding the closest peak to the selected point
                [selectedPeak,selectedLoc]=min((unusedPeakXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(TempData(unusedPeakXs) - newPoint(2))).^2);
                plot(unusedPeakXs(selectedLoc),unusedPeakYs(selectedLoc),'r*','MarkerSize',10), hold on
                %set(handles.ROIaxes,'xticklabel',[])
                %set(handles.ROIaxes,'yticklabel',[])
                pInd = [pInd unusedPeakXs(selectedLoc)];
                pIndYs = [pIndYs unusedPeakYs(selectedLoc)];
                unusedPeakXs(selectedLoc) = [];
                unusedPeakYs(selectedLoc) = [];
                pIndex = pInd(length(pInd)) + prevRRGap;
            end
            if qIndex + RR_GAP_CONSTANT_RIGHT*prevRRGap > length(TempData)
                problem = false;
            else
                HighPopUpOrDisp('Select the next R Wave.', PopUpFreq);
                h=drawpoint('Visible','off');
                newPoint=h.Position;
                
                %finding the closest peak to the selected point
                [selectedPeak,selectedLoc]=min((unusedPeakXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(TempData(unusedPeakXs) - newPoint(2))).^2);
                plot(unusedPeakXs(selectedLoc),unusedPeakYs(selectedLoc),'k*','MarkerSize',10), hold on
                %set(handles.ROIaxes,'xticklabel',[])
                %set(handles.ROIaxes,'yticklabel',[])
                qInd = [qInd unusedPeakXs(selectedLoc)];
                qIndYs = [qIndYs unusedPeakYs(selectedLoc)];
                unusedPeakXs(selectedLoc) = [];
                unusedPeakYs(selectedLoc) = [];
                qIndex = qInd(length(qInd)) + prevRRGap;
            end
        end
        while problem
            while qInd(length(qInd)-1) > pInd(length(pInd))
                if pIndex + RR_GAP_CONSTANT_RIGHT*prevRRGap > length(TempData)
                    problem = false;
                    break
                end
                HighPopUpOrDisp('Select the next P Wave.', PopUpFreq);
                h=drawpoint('Visible','off');
                newPoint=h.Position;
                
                %finding the closest peak to the selected point
                [selectedPeak,selectedLoc]=min((unusedPeakXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(TempData(unusedPeakXs) - newPoint(2))).^2);
                plot(unusedPeakXs(selectedLoc),unusedPeakYs(selectedLoc),'r*','MarkerSize',10), hold on
                %set(handles.ROIaxes,'xticklabel',[])
                %set(handles.ROIaxes,'yticklabel',[])
                pInd = [pInd unusedPeakXs(selectedLoc)];
                pIndYs = [pIndYs unusedPeakYs(selectedLoc)];
                unusedPeakXs(selectedLoc) = [];
                unusedPeakYs(selectedLoc) = [];
                problemInd = [problemInd pInd(length(pInd)-1)];
                problemIndYs = [problemIndYs pIndYs(length(pIndYs)-1)];
                plot(pInd(length(pInd)-1),pIndYs(length(pIndYs)-1),'y*','MarkerSize',7), hold on
                %set(handles.ROIaxes,'xticklabel',[])
                %set(handles.ROIaxes,'yticklabel',[])
                pIndex = pInd(length(pInd)) + prevRRGap;
            end
            if problem == false
                break
            end
            while qInd(length(qInd)) < pInd(length(pInd))
                if qIndex + RR_GAP_CONSTANT_RIGHT*prevRRGap > length(TempData)
                    problem = false;
                    break
                end
                HighPopUpOrDisp('Select the next R Wave.', PopUpFreq);
                h=drawpoint('Visible','off');
                newPoint=h.Position;
                
                %finding the closest peak to the selected point
                [selectedPeak,selectedLoc]=min((unusedPeakXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(TempData(unusedPeakXs) - newPoint(2))).^2);
                plot(unusedPeakXs(selectedLoc),unusedPeakYs(selectedLoc),'k*','MarkerSize',10), hold on
                %set(handles.ROIaxes,'xticklabel',[])
                %set(handles.ROIaxes,'yticklabel',[])
                qInd = [qInd unusedPeakXs(selectedLoc)];
                qIndYs = [qIndYs unusedPeakYs(selectedLoc)];
                unusedPeakXs(selectedLoc) = [];
                unusedPeakYs(selectedLoc) = [];
                problemInd = [problemInd qInd(length(qInd)-1)];
                problemIndYs = [problemIndYs qIndYs(length(qIndYs)-1)];
                plot(qInd(length(qInd)-1),qIndYs(length(qIndYs)-1),'y*','MarkerSize',7), hold on
                qIndex = qInd(length(qInd)) + prevRRGap;
            end
            if problem == false
                break;
            end
            p = length(pInd);
            q = length(qInd);
            %if the  following conditional is not met, then the last elements of pInd and qInd do
            %not represent a normal P/QRS pairing
            if (qInd(q) < pInd(p) || qInd(q) - pInd(p) > 0.5 * prevRRGap) && qIndex + RR_GAP_CONSTANT_RIGHT*prevRRGap < length(TempData)
                HighPopUpOrDisp('Select the next P Wave.', PopUpFreq);
                h=drawpoint('Visible','off');
                newPoint=h.Position;
                
                %finding the closest peak to the selected point
                [selectedPeak,selectedLoc]=min((unusedPeakXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(TempData(unusedPeakXs) - newPoint(2))).^2);
                plot(unusedPeakXs(selectedLoc),unusedPeakYs(selectedLoc),'r*','MarkerSize',10), hold on
                %set(handles.ROIaxes,'xticklabel',[])
                %set(handles.ROIaxes,'yticklabel',[])
                pInd = [pInd unusedPeakXs(selectedLoc)];
                pIndYs = [pIndYs unusedPeakYs(selectedLoc)];
                unusedPeakXs(selectedLoc) = [];
                unusedPeakYs(selectedLoc) = [];
                problemInd = [problemInd pInd(length(pInd)-1)];
                problemIndYs = [problemIndYs pIndYs(length(pIndYs)-1)];
                plot(pInd(length(pInd)-1),pIndYs(length(pIndYs)-1),'y*','MarkerSize',7), hold on
                %set(handles.ROIaxes,'xticklabel',[])
                %set(handles.ROIaxes,'yticklabel',[])
                pIndex = pInd(length(pInd)) + prevRRGap;
            else
                if qInd(length(qInd)) - qInd(length(qInd) -1) < 2 * prevRRGap && qInd(length(qInd)) - qInd(length(qInd) -1) > 0.5 * prevRRGap
                    prevRRGap = (MODERATE_ADJUSTMENT_CONSTANT*prevRRGap + qInd(length(qInd)) - qInd(length(qInd) -1))/(MODERATE_ADJUSTMENT_CONSTANT + 1);
                else
                    prevRRGap = (CONSERVATIVE_ADJUSTMENT_CONSTANT*prevRRGap + qInd(length(qInd)) - qInd(length(qInd) -1))/(CONSERVATIVE_ADJUSTMENT_CONSTANT + 1);
                end
                pairings = [pairings(1, :) length(pInd); pairings(2, :) length(qInd)];
                problem = false;
            end
        end
    end
end

%ensuring that pInd and qInd are in order
pOrdered = true;
index = 1;
while index <= length(pInd)-1
    if pInd(index) > pInd(index+1)
        pOrdered = false;
        break
    end
    index=index+1;
end
if pOrdered == false
    sort(pInd);
    pIndYs = [];
    for index = 1:length(pInd)
        pIndYs = [pIndYs TempData(pInd(index))];
    end
end
qOrdered = true;
index = 1;
while index <= length(qInd)-1
    if qInd(index) > qInd(index+1)
        qOrdered = false;
        break
    end
    index=index+1;
end
if qOrdered == false
    sort(qInd);
    qIndYs = [];
    for index = 1:length(qInd)
        qIndYs = [qIndYs TempData(qInd(index))];
    end
end

arrythmias = [];
arrythmiaYs = [];
%does the user want to add any yellow markers? Peaks?
%zooming out first
xlim(size(TempData));
ylim([0,1]);
if PopUpFreq > 0
    str3=questdlg('Would you like to add additional waves or markers? Please note that placements may only be made on preexisting peak markers (cyan, red, or black).', '', 'Yes', 'No - Finish Noise Remover', 'No - Finish Noise Remover');
    switch str3
        case 'Yes'
            str3 = 'N';
        case 'No - Finish Noise Remover'
            str3 = 'D';
    end
else
    prompt = 'Are you finished with editing waves selected by the noise remover? Enter Y or N: ';
    str3 = input(prompt,'s');
end

while str3 == 'N' || str3 == 'n'
    if PopUpFreq > 0
        list = {'P Waves', 'R Waves', 'Yellow Markers', 'Finish Noise Remover'};
        [indx,tf] = listdlg('PromptString',{'Select a feature to add or choose to end the noise remover.',...
        'Only one option can be selected at a time.',''},...
        'SelectionMode','single','ListString',list, 'ListSize', [200, 100]);
        str3 = indx;
    else
        prompt = 'What additional features would you like to add: P waves (P), R waves (Q), yellow markers (Y), or are you finished with the noise remover (D)? Enter P, Q, Y or D: ';
        str3 = input(prompt,'s');
        if str3 == 'P' || str3 == 'p'
            str3 = 1;
        else
            if str3 == 'Q' || str3 == 'q'
                str3 = 2;
            else
                if str3 == 'Y' || str3 == 'y'
                    str3 = 3;
                else 
                    str3 = 4;
                end
            end
        end
    end
    if str3 == 4
        break
    end
    prompt=inputdlg('How many of the selected feature would you like to add (1 to 5 at a time)?');
    if PopUpFreq > 0
        x = str2num(prompt{1});
    else
        x = str2num(prompt{1});
    end
    if x < 1
        x = 1;
    end
    if x > 5
        x = 5;
    end
    StandardPopUpOrDisp('Select points in the trace you would like to add.', PopUpFreq);
    for n = 1:x
        h=drawpoint('Visible','off');
        newPoint=h.Position;
        %finding the closest peak to the selected point
        [selectedPeak,selectedLoc]=min((peakXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(TempData(peakXs) - newPoint(2))).^2);
        xCoord = peakXs(selectedLoc);
        yCoord = peakYs(selectedLoc);
        %if str3 == 'P' || str3 == 'p'
        if str3 == 1
            %adding the peak in order
            for index = 1:length(pInd)
                if pInd(index) > xCoord
                    if index == 1
                        pInd = [xCoord pInd];
                        pIndYs = [yCoord pIndYs];
                    else
                        pInd = [pInd(1:index-1) xCoord pInd(index:end)];
                        pIndYs = [pIndYs(1:index-1) yCoord pIndYs(index:end)];
                    end
                    break;
                end
                if index == length(pInd)
                    pInd = [pInd xCoord];
                    pIndYs = [pIndYs yCoord];
                end
            end
            %ensuring that the peak is not in qInd; if so, it will be
            %removed
            index = 1;
            while index <= length(qInd)
                if qInd(index) == xCoord
                    qInd(index) = [];
                    qIndYs(index) = [];
                else
                    index = index+1;
                end
            end
            plot(xCoord,yCoord,'r*','MarkerSize',10), hold on
        end
        %if str3 == 'Q' || str3 == 'q'
        if str3 == 2
            %adding the peak in order
            for index = 1:length(qInd)
                if qInd(index) > xCoord
                    if index == 1
                        qInd = [xCoord qInd];
                        qIndYs = [yCoord qIndYs];
                    else
                        qInd = [qInd(1:index-1) xCoord qInd(index:end)];
                        qIndYs = [qIndYs(1:index-1) yCoord qIndYs(index:end)];
                    end
                    break;
                end
                if index == length(qInd)
                    qInd = [qInd xCoord];
                    qIndYs = [qIndYs yCoord];
                end
            end
            %ensuring that the peak is not in pInd; if so, it will be
            %removed
            index = 1;
            while index <= length(pInd)
                if pInd(index) == xCoord
                    pInd(index) = [];
                    pIndYs(index) = [];
                else
                    index = index+1;
                end
            end
            plot(xCoord,yCoord,'k*','MarkerSize',10), hold on
            %set(handles.ROIaxes,'xticklabel',[])
            %set(handles.ROIaxes,'yticklabel',[])
        end
        %if str3 == 'Y' || str3 == 'y'
        if str3 == 3
            problemInd = [problemInd xCoord];
            problemIndYs = [problemIndYs yCoord];
            plot(xCoord,yCoord,'y*','MarkerSize',7), hold on
            %set(handles.ROIaxes,'xticklabel',[])
            %set(handles.ROIaxes,'yticklabel',[])
        end
        if str3 == 'A' || str3 == 'a'
            arrythmias = [arrythmias xCoord];
            arrythmiaYs = [arrythmiaYs yCoord];
            plot(xCoord,yCoord,'g*','MarkerSize',5), hold on
            %set(handles.ROIaxes,'xticklabel',[])
            %set(handles.ROIaxes,'yticklabel',[])
        end
        
    end
    %zooming out after edits
    xlim(size(TempData));
    ylim([0,1]);
    if str3 == 1 || str3 == 2 || str3 == 3 || str3 == 'A'
        str3 = 'N';
    end
end

%removing duplicate points from problemInd
index = 1;
while index < length(problemInd)-1
    index2 = index + 1;
    while index2 < length(problemInd)
        if (problemInd(index)==problemInd(index2))
            problemInd(index2) = [];
        else
            index2 = index2 + 1;
        end
    end
    index = index + 1;
end
problemIndYs = [];
for index = 1:length(problemInd)
    problemIndYs = [problemIndYs TempData(index)];
end

allPeaks{currfile,ROIcount(currfile,2),1}=pInd; %P x-coords; order from left to right is maintained by all functions
allPeaks{currfile,ROIcount(currfile,2),2}=qInd; %QRS x-coords; order from left to right is maintained by all functions
allPeaks{currfile,ROIcount(currfile,2),3}=pIndYs; %P y-coords; order cooresponds to x-coords order
allPeaks{currfile,ROIcount(currfile,2),4}=qIndYs; %QRS y-coords; order cooresponds to x-coords order
allPeaks{currfile,ROIcount(currfile,2),5}=problemInd; %problematic x-coords
allPeaks{currfile,ROIcount(currfile,2),6}=problemIndYs; %problematic y-coords; order cooresponds to x-coords order
allPeaks{currfile,ROIcount(currfile,2),7}=arrythmias; %arrythmia x-coords
allPeaks{currfile,ROIcount(currfile,2),8}=arrythmiaYs; %arrythmia y-coords; order cooresponds to x-coords order
allPeaks{currfile,ROIcount(currfile,2),9}=minimaXs;
allPeaks{currfile,ROIcount(currfile,2),10}=minimaYs;

assignin('base','allPeaks',allPeaks)

set(handles.UndoStepButton,'Visible','Off');

axes(handles.ROIaxes),cla
TempData=AllsubData{1,currfile}{1,ROIcount(currfile,2)};
plot(TempData);
set(handles.ROIaxes,'yticklabel',[])
set(handles.ROIaxes,'xticklabel',[])
hold on
PlotAllRelevantPoints(allPeaks, currfile, ROIcount, TempData), hold off
clear TempData

% --- Executes on button press in FindQRSMinimaButton.
function FindQRSMinimaButton_Callback(hObject, eventdata, handles)
% hObject    handle to FindQRSMinimaButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Finds all QRS peak minima occuring after the first P peak

AllsubData=evalin('base','AllsubData');
currfile=get(handles.filelist,'Value');
ROIcount=evalin('base','ROIcount');
allPeaks=evalin('base','allPeaks');
PopUpFreq = evalin('base', 'PopUpFrequencyValue');

tempData=AllsubData{1,currfile}{1,ROIcount(currfile,2)};

problemInd=allPeaks{currfile,ROIcount(currfile,2),5};
problemIndYs=allPeaks{currfile,ROIcount(currfile,2),6};
oldMinimaInd=allPeaks{currfile,ROIcount(currfile,2),9};

%cleaing yellow markers from old minima
counter1 = 1;
toIncrement = 1;
while counter1 < length(problemInd)
    toIncrement = 1;
    for counter2 = 1:length(oldMinimaInd)
        if problemInd(counter1) == oldMinimaInd(counter2)
            problemInd(counter1) = [];
            problemIndYs(counter1) = [];
            toIncrement = 0;
            break
        end
    end
    counter1 = counter1 + toIncrement;
end

minpeakdist_string=get(handles.changepeakdist,'String');
minpeakdist_value=str2num(minpeakdist_string);

minimaInd = [];
minimaIndYs = [];

StandardPopUpOrDisp('Select the height of the highest minima.', PopUpFreq);
h=drawpoint('Visible', 'off');
drawline('Position', [0, h.Position(2); length(tempData), h.Position(2)]);
maxHeight = h.Position(2);

GAP_CONSTANT = 0.2;

for currIndex = 2 : length(tempData) - 1
    if tempData(currIndex) < tempData(currIndex - 1) && tempData(currIndex) < tempData(currIndex + 1) && tempData(currIndex) < maxHeight
        if length(minimaInd) ~= 0 && currIndex - minimaInd(length(minimaInd)) > minpeakdist_value
            minimaInd = [minimaInd currIndex];
            minimaIndYs = [minimaIndYs tempData(currIndex)];
        else
            if length(minimaInd) > 0 && tempData(currIndex) < tempData(minimaInd(length(minimaInd)))
                minimaInd(length(minimaInd)) = currIndex;
                minimaIndYs(length(minimaIndYs)) = tempData(currIndex);
            end
            if length(minimaInd) == 0
                minimaInd = [minimaInd currIndex];
                minimaIndYs = [minimaIndYs tempData(currIndex)];
            end
        end
    end
end

%labelling problematic minima: all minima distances recorded in
%an array, and any pairing with less than half of the median distance is
%recorded
distancesFromNext = [1;minimaInd(2)-minimaInd(1)];
for minIndex = 2:length(minimaInd)-1
    currDist = minimaInd(minIndex+1) - minimaInd(minIndex);
    indToAdd = 1;
    sz = size(distancesFromNext);
    while indToAdd <= sz(2) && currDist > distancesFromNext(2,indToAdd)
        indToAdd = indToAdd + 1;
    end
    if indToAdd == 1
        distancesFromNext = [minIndex distancesFromNext(1, 1:end); currDist distancesFromNext(2, 1:end)];
    else
        if indToAdd > sz(2)
            distancesFromNext = [distancesFromNext(1, 1:end) minIndex; distancesFromNext(2, 1:end) currDist];
        else
            distancesFromNext = [distancesFromNext(1,1:indToAdd-1) minIndex distancesFromNext(1,indToAdd:end); distancesFromNext(2,1:indToAdd-1) currDist distancesFromNext(2,indToAdd:end)];
        end
    end
end

sz = size(distancesFromNext);
medianDist = distancesFromNext(2,round(sz(2)/2));

for currIndex = 1:sz(2)
    if (distancesFromNext(2,currIndex) < medianDist/2)
        problemInd = [problemInd minimaInd(distancesFromNext(1,currIndex)) minimaInd(distancesFromNext(1,currIndex)+1)];
        %problemIndYs will be set after the duplicate point removal
    else
        break
    end
end

%removing duplicate points from problemInd
index = 1;
while index < length(problemInd)-1
    index2 = index + 1;
    while index2 < length(problemInd)
        if (problemInd(index)==problemInd(index2))
            problemInd(index2) = [];
        else
            index2 = index2 + 1;
        end
    end
    index = index + 1;
end
problemIndYs = [];
for index = 1:length(problemInd)
    problemIndYs = [problemIndYs tempData(index)];
end

set(handles.RemoveMinimaNoiseButton,'Visible','On');
set(handles.AddMinimaButton,'Visible','On');
set(handles.DeleteMinimaButton,'Visible','On');
set(handles.MinimaAverageButton,'Visible','On');

allPeaks{currfile,ROIcount(currfile,2),5}=problemInd;
allPeaks{currfile,ROIcount(currfile,2),6}=problemIndYs;
allPeaks{currfile,ROIcount(currfile,2),9}=minimaInd;
allPeaks{currfile,ROIcount(currfile,2),10}=minimaIndYs;

assignin('base','allPeaks',allPeaks)

axes(handles.ROIaxes),cla
tempData=AllsubData{1,currfile}{1,ROIcount(currfile,2)};
plot(tempData);
set(handles.ROIaxes,'yticklabel',[])
set(handles.ROIaxes,'xticklabel',[])
hold on
PlotAllRelevantPoints(allPeaks, currfile, ROIcount, tempData), hold off
clear tempData

% --- Executes on button press in RemoveMinimaNoiseButton.
function RemoveMinimaNoiseButton_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveMinimaNoiseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Removes the minima noise in a similar manner to the general noise remover

currfile=get(handles.filelist,'Value');
AllsubData=evalin('base','AllsubData');
allPeaks=evalin('base','allPeaks');
ROIcount=evalin('base','ROIcount');
PopUpFreq = evalin('base', 'PopUpFrequencyValue');
problemInd = allPeaks{currfile,ROIcount(currfile,2),5};
problemIndYs = allPeaks{currfile, ROIcount(currfile,2),6};
unusedXs = allPeaks{currfile,ROIcount(currfile,2),9}; %note: takes peakXs from the original find peaks; running noise remover won't change this
unusedYs = allPeaks{currfile,ROIcount(currfile,2),10}; %ditto here
tempData=AllsubData{1,currfile}{1,ROIcount(currfile,2)};
minimaInd = [];
minimaIndYs = [];
set(handles.ROIaxes,'xticklabel',[])

str3=[];

%removing all of the old minima problem indices
for i = 1:length(unusedXs)
    for j = 1:length(problemInd)
        if problemInd(j) == unusedXs(i)
            problemInd(j) = [];
            problemIndYs(j) = [];
            break
        end
    end
end

axes(handles.ROIaxes), cla, plot(tempData), hold on
set(handles.ROIaxes,'xticklabel',[])
plot(unusedXs,unusedYs,'c*','MarkerSize',10), hold on
set(handles.ROIaxes,'yticklabel',[])

StandardPopUpOrDisp('Select the first minimum.', PopUpFreq);
h=drawpoint('Visible','off');
newPoint=h.Position;
%finding the closest peak to the selected point
[selectedPeak,selectedLoc]=min((unusedXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(tempData(unusedXs) - newPoint(2))).^2);
plot(unusedXs(selectedLoc),unusedYs(selectedLoc),'m*','MarkerSize',10), hold on
set(handles.ROIaxes,'xticklabel',[])
minimaInd = [minimaInd unusedXs(selectedLoc)];
minimaIndYs = [minimaIndYs unusedYs(selectedLoc)];
xHolder = unusedXs(selectedLoc);
unusedXs(selectedLoc) = [];
unusedYs(selectedLoc) = [];

if PopUpFreq == 1
    StandardPopUpOrDisp('Select the second minimum. Note: further instructions will come through the console until all minima are selected.', PopUpFreq);
else
    StandardPopUpOrDisp('Select the second minimum.', PopUpFreq);
end
h=drawpoint('Visible','off');
newPoint=h.Position;
%finding the closest peak to the selected point
[selectedPeak,selectedLoc]=min((unusedXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(tempData(unusedXs) - newPoint(2))).^2);
plot(unusedXs(selectedLoc),unusedYs(selectedLoc),'m*','MarkerSize',10), hold on
set(handles.ROIaxes,'xticklabel',[])
minimaInd = [minimaInd unusedXs(selectedLoc)];
minimaIndYs = [minimaIndYs unusedYs(selectedLoc)];
prevX = unusedXs(selectedLoc);
prevGap =  prevX - xHolder;
unusedXs(selectedLoc) = [];
unusedYs(selectedLoc) = [];
index = prevX + prevGap;

times = 0; %failsafe for certain cases where the program gets stuck in the loop; assuming there are never more than 10000 peaks
missesInARow = 0;
GAP_CONSTANT = 0.1;
EXPANDED_WINDOW_CONSTANT = 1.5;
tooFewInARow = 0; %keeps track of how many times in a row there were zero minima in the interval
tooManyInARow = 0; %keeps track of how many times in a row there were 2+ minima in the interval
ALLOWED_PROBLEMS_IN_A_ROW = 1; %how many of either of the two above are allowed in a row before adjusting the gap constant
GAP_CONSTANT_ADJUSTER = 1.5; %to be used allowed problems in a row is exceeded; gap constant is multiplied by this value when too few in a row and divided when too many

while index < length(tempData)
    times = times + 1;
    if (times > 10000)
        break
    end
    minimaInIntervalIndices= [];
    for i = 1:length(unusedXs)
        if unusedXs(i) > index - round(GAP_CONSTANT*prevGap) && unusedXs(i) < index + round(GAP_CONSTANT*prevGap)
            minimaInIntervalIndices = [minimaInIntervalIndices i];
        end
    end
    
    expandedWindowUsed = false;
    if length(minimaInIntervalIndices) == 0
        expandedWindowUsed = true;
        tooFewInARow = tooFewInARow + 1;
        if tooFewInARow > ALLOWED_PROBLEMS_IN_A_ROW
            GAP_CONSTANT = GAP_CONSTANT * GAP_CONSTANT_ADJUSTER;
        end
        %trying again with an expanded search window
        for i = 1:length(unusedXs)
            if unusedXs(i) > index - round(GAP_CONSTANT*EXPANDED_WINDOW_CONSTANT*prevGap) && unusedXs(i) < index + round(GAP_CONSTANT*EXPANDED_WINDOW_CONSTANT*prevGap)
                minimaInIntervalIndices = [minimaInIntervalIndices i];
            end
        end
    end
    
    if length(minimaInIntervalIndices) == 1
        relevantIndex = minimaInIntervalIndices(1);
        tooFewInARow = 0;
        tooManyInARow = 0;
        plot(unusedXs(relevantIndex),unusedYs(relevantIndex),'m*','MarkerSize',10), hold on
        set(handles.ROIaxes,'xticklabel',[])
        minimaInd = [minimaInd unusedXs(relevantIndex)];
        minimaIndYs = [minimaIndYs unusedYs(relevantIndex)];
        prevGap = (prevGap + minimaInd(length(minimaInd)) - minimaInd(length(minimaInd)-1))/2; %adjusting somewhat conservatively
        index = minimaInd(length(minimaInd)) + prevGap;
        unusedXs(relevantIndex) = [];
        unusedYs(relevantIndex) = [];
        
        %if there is a nearby unused minima outside of the window but lower, we
        %mark this used minima yellow
        if relevantIndex > 1 && relevantIndex < length(unusedXs)
            if (unusedXs(relevantIndex) - minimaInd(length(minimaInd)) < prevGap/2 && unusedYs(relevantIndex) < minimaIndYs(length(minimaIndYs))) || (minimaInd(length(minimaInd)) - unusedXs(relevantIndex-1) < prevGap/2 && unusedYs(relevantIndex-1) < minimaIndYs(length(minimaIndYs)))
                problemInd = [problemInd minimaInd(length(minimaInd))];
                problemIndYs = [problemIndYs minimaIndYs(length(minimaIndYs))];
                plot(minimaInd(length(minimaInd)),minimaIndYs(length(minimaIndYs)),'y*','MarkerSize',7), hold on
                set(handles.ROIaxes,'xticklabel',[])
            end
        end
    else
        if length(minimaInIntervalIndices) == 0
            tooFewInARow = tooFewInARow + 1;
            if tooFewInARow > ALLOWED_PROBLEMS_IN_A_ROW && expandedWindowUsed == false %if the expanded window was used, the adjustment was made there
                GAP_CONSTANT = GAP_CONSTANT * GAP_CONSTANT_ADJUSTER;
            end
            if index + prevGap * (1+GAP_CONSTANT) > length(tempData)
                break
            end
        else
            tooManyInARow = tooManyInARow + 1;
            if tooManyInARow > ALLOWED_PROBLEMS_IN_A_ROW && expandedWindowUsed == false %if the expanded window was used, then there weren't actually too many in the original window
                GAP_CONSTANT = GAP_CONSTANT / GAP_CONSTANT_ADJUSTER;
            end
        end
        
        HighPopUpOrDisp('Select the next minimum.', PopUpFreq);
        h=drawpoint('Visible','off');
        newPoint=h.Position;
        %finding the closest peak to the selected point
        [selectedPeak,selectedLoc]=min((unusedXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(tempData(unusedXs) - newPoint(2))).^2);
        plot(unusedXs(selectedLoc),unusedYs(selectedLoc),'m*','MarkerSize',10), hold on
        set(handles.ROIaxes,'xticklabel',[])
        minimaInd = [minimaInd unusedXs(selectedLoc)];
        minimaIndYs = [minimaIndYs unusedYs(selectedLoc)];
        %adjusting prevGap conservatively; its possible the old prevGap is
        %based off of outliers, but more likely the new gap is the outlier
        prevGap = (4*prevGap + minimaInd(length(minimaInd)) - minimaInd(length(minimaInd)-1))/5;
        index = unusedXs(selectedLoc) + prevGap;
        unusedXs(selectedLoc) = [];
        unusedYs(selectedLoc) = [];
    end
end

%zooming out before edits
xlim(size(tempData));
ylim([0,1]);

if PopUpFreq > 0
    response=questdlg('Would you like to edit the minima?', '', 'Yes', 'No - Finish Noise Remover', 'No - Finish Noise Remover');
    switch response
        case 'Yes'
            str3 = 'N';
        case 'No'
            str3 = 'D';
    end
else
    prompt = 'Are you finished with editing waves selected by the noise remover? Enter Y or N: ';
    str3 = input(prompt,'s');
end

while str3 == 'N'
    if PopUpFreq > 0
        list = {'Minima', 'Yellow Markers', 'Finish Noise Remover'};
        [indx,tf] = listdlg('PromptString',{'Select a feature to add or choose to end the noise remover.',...
            'Only one option can be selected at a time.',''},...
            'SelectionMode','single','ListString',list, 'ListSize', [200, 100]);
        str3 = indx;
    else
        prompt = 'What additional features would you like to add: Minima (M), yellow markers (Y), or are you finished with the noise remover (D)? Enter M, Y or D: ';
        str3 = input(prompt,'s');
        if str3 == 'M' || str3 == 'm'
            str3 = 1;
        else
            if str3 == 'Y' || str3 == 'y'
                str3 = 2;
            else
                str3 = 3;
            end
        end
    end
    if str3 == 3
        break
    end
    prompt=inputdlg('How many of the selected feature would you like to add (1 to 5 at a time)?');
    if PopUpFreq > 0
        x = str2num(prompt{1});
    else
        x = str2num(prompt{1});
    end
    if x < 1
        x = 1;
    end
    if x > 5
        x = 5;
    end
    StandardPopUpOrDisp('Select the points you would like to add.', PopUpFreq);
    for n = 1:x
        if str3 == 1
            h=drawpoint('Visible','off');
            newPoint=h.Position;
            %finding the closest peak to the selected point
            [selectedPeak,selectedLoc]=min((unusedXs-newPoint(1)).^2 + (YAxisMultiplier(handles)*(tempData(unusedXs) - newPoint(2))).^2);
            xCoord = unusedXs(selectedLoc);
            yCoord = unusedYs(selectedLoc);
            %adding the minimum in order
            for index = 1:length(minimaInd)
                if minimaInd(index) > xCoord
                    if index == 1
                        minimaInd = [xCoord minimaInd];
                        minimaIndYs = [yCoord minimaIndYs];
                    else
                        minimaInd = [minimaInd(1:index-1) xCoord minimaInd(index:end)];
                        minimaIndYs = [minimaIndYs(1:index-1) yCoord minimaIndYs(index:end)];
                    end
                    break;
                end
                if index == length(minimaInd)
                    minimaInd = [minimaInd xCoord];
                    minimaIndYs = [minimaIndYs yCoord];
                end
            end
            plot(xCoord,yCoord,'m*','MarkerSize',10), hold on
        end
        if str3 == 2
            h=drawpoint('Visible','off');
            newPoint=h.Position;
            %finding the closest peak to the selected point
            [selectedPeak,selectedLoc]=min((minimaInd-newPoint(1)).^2 + (YAxisMultiplier(handles)*(tempData(minimaInd) - newPoint(2))).^2);
            xCoord = minimaInd(selectedLoc);
            yCoord = minimaIndYs(selectedLoc);
            %adding the index in order
            for index = 1:length(problemInd)
                if problemInd(index) > xCoord
                    if index == 1
                        problemInd = [xCoord problemInd];
                        problemIndYs = [yCoord problemIndYs];
                    else
                        problemInd = [problemInd(1:index-1) xCoord problemInd(index:end)];
                        problemIndYs = [problemIndYs(1:index-1) yCoord problemIndYs(index:end)];
                    end
                    break;
                end
                if index == length(problemInd)
                    problemInd = [problemInd xCoord];
                    problemIndYs = [problemIndYs yCoord];
                end
            end
            plot(xCoord,yCoord,'y*','MarkerSize',7), hold on
        end
    end
    if str3 == 1 || str3 == 2
        str3 = 'N';
    end
    %zooming out after edits
    xlim(size(tempData));
    ylim([0,1]);
end

allPeaks{currfile,ROIcount(currfile,2),5}=problemInd;
allPeaks{currfile,ROIcount(currfile,2),6}=problemIndYs;
allPeaks{currfile,ROIcount(currfile,2),9}=minimaInd;
allPeaks{currfile,ROIcount(currfile,2),10}=minimaIndYs;

assignin('base','allPeaks',allPeaks)

set(handles.UndoStepButton,'Visible','Off');

axes(handles.ROIaxes),cla
tempData=AllsubData{1,currfile}{1,ROIcount(currfile,2)};
plot(tempData);
set(handles.ROIaxes,'yticklabel',[])
set(handles.ROIaxes,'xticklabel',[])
hold on
PlotAllRelevantPoints(allPeaks, currfile, ROIcount, tempData), hold off
clear TempData

% --- Executes on button press in FullZoomOut.
function FullZoomOut_Callback(hObject, eventdata, handles)
% hObject    handle to FullZoomOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Fully zooms out on the ROIaxes; useful when the home button no longer does
%so (say, after adding or deleting a peak)

AllsubData=evalin('base','AllsubData');
currfile=get(handles.filelist,'Value');
ROIcount=evalin('base','ROIcount');
axes(handles.ROIaxes)
tempData = AllsubData{1,currfile}{1,ROIcount(currfile,2)};
xlim(size(tempData));
ylim([0,1]);

% --- Executes on button press in DeletePeaksButton.
function DeletePeaksButton_Callback(hObject, eventdata, handles)
% hObject    handle to DeletePeaksButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%If peaks boxed: deletes all peaks in the box
%If points selected: deletes the 'nearest' peaks to all points selected
%(note: x-axis and y-axis distances are not weighted equally)

%Note: cannot use both selected peaks and box peaks buttons at once
selectedPoints=[get(handles.SelectPeakButton,'UserData') get(handles.BoxPeaksButton,'UserData')];
AllsubData=evalin('base','AllsubData');
currfile=get(handles.filelist,'Value');
ROIcount=evalin('base','ROIcount');
allPeaks=evalin('base','allPeaks');
pPeakYs = allPeaks{currfile,ROIcount(currfile,2),3};
qPeakYs = allPeaks{currfile,ROIcount(currfile,2),4};

pPeaks=allPeaks{currfile,ROIcount(currfile,2),1};
qPeaks=allPeaks{currfile,ROIcount(currfile,2),2};

% Find which peaks points are closest to

for ii=1:size(selectedPoints)
    [selectedpPeak,selectedpLoc]=min((pPeaks-selectedPoints(ii, 1)).^2 + (YAxisMultiplier(handles)*(pPeakYs - selectedPoints(ii, 2))).^2);
    [selectedqPeak,selectedqLoc]=min((qPeaks-selectedPoints(ii, 1)).^2 + (YAxisMultiplier(handles)*(qPeakYs - selectedPoints(ii, 2))).^2);
    if selectedpPeak<selectedqPeak
        pPeaks(selectedpLoc)=[];
        pPeakYs(selectedpLoc)=[];
    else
        qPeaks(selectedqLoc)=[];
        qPeakYs(selectedqLoc)=[];
    end
end

% update allPeaks
allPeaks{currfile,ROIcount(currfile,2),1} = pPeaks;
allPeaks{currfile,ROIcount(currfile,2),2} = qPeaks;
allPeaks{currfile,ROIcount(currfile,2),3} = pPeakYs;
allPeaks{currfile,ROIcount(currfile,2),4} = qPeakYs;
assignin('base','allPeaks',allPeaks)

%using storage to ensure that window stays zoomed as it was before swap
%colors button was pressed
storageX = handles.ROIaxes.XLim;
storageY = handles.ROIaxes.YLim;
%Plot updated peaks
axes(handles.ROIaxes),cla
tempData=AllsubData{1,currfile}{1,ROIcount(currfile,2)};
plot(tempData);
%maintaining window size
xlim(storageX);
ylim(storageY);
hold on
PlotAllRelevantPoints(allPeaks, currfile, ROIcount, tempData), hold off
set(handles.ROIaxes,'xticklabel',[])
set(handles.ROIaxes,'yticklabel',[])
clear tempData
%reseting user selections
set(handles.SelectPeakButton,'UserData',[]);
set(handles.BoxPeaksButton,'UserData',[]);
assignin('base','selectedYellow',[]);
assignin('base','selectedArrythmias',[]);
assignin('base','selectedMinima',[]);

% --- Executes on button press in SwapColorsButton.
function SwapColorsButton_Callback(hObject, eventdata, handles)
% hObject    handle to SwapColorsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%If peaks boxed: turns red peaks in the box to black, and black peaks
%in the box to red
%If points selected: swaps the colors of the 'nearest' peaks to all points selected
%(note: x-axis and y-axis distances are not weighted equally)

%NOTE: cannot use both selected peaks and box peaks buttons at once
selectedPoints=[get(handles.SelectPeakButton,'UserData') get(handles.BoxPeaksButton,'UserData')];
AllsubData=evalin('base','AllsubData');
currfile=get(handles.filelist,'Value');
ROIcount=evalin('base','ROIcount');
allPeaks=evalin('base','allPeaks');
pPeakYs = allPeaks{currfile,ROIcount(currfile,2),3};
qPeakYs = allPeaks{currfile,ROIcount(currfile,2),4};

pPeaks=allPeaks{currfile,ROIcount(currfile,2),1};
qPeaks=allPeaks{currfile,ROIcount(currfile,2),2};

% Find which peak points are closest to

for ii=1:size(selectedPoints)
    [selectedpPeak,selectedpLoc]=min((pPeaks-selectedPoints(ii, 1)).^2 + (YAxisMultiplier(handles)*(pPeakYs - selectedPoints(ii, 2))).^2);
    [selectedqPeak,selectedqLoc]=min((qPeaks-selectedPoints(ii, 1)).^2 + (YAxisMultiplier(handles)*(qPeakYs - selectedPoints(ii, 2))).^2);
    if selectedpPeak<selectedqPeak
        %the following set of conditionals ensures that the new peak is
        %added in the appropriate order (keeping qPeaks arranged from left
        %to right)
        for index = 1:length(qPeaks)
            if qPeaks(index) > pPeaks(selectedpLoc)
                if index == 1
                    qPeaks = [pPeaks(selectedpLoc) qPeaks];
                    qPeakYs = [pPeakYs(selectedpLoc) qPeakYs];
                else
                    qPeaks = [qPeaks(1:index-1) pPeaks(selectedpLoc) qPeaks(index:end)];
                    qPeakYs = [qPeakYs(1:index-1) pPeakYs(selectedpLoc) qPeakYs(index:end)];
                end
                break;
            end
            if index == length(qPeaks)
                qPeaks = [qPeaks pPeaks(selectedpLoc)];
                qPeakYs = [qPeakYs pPeakYs(selectedpLoc)];
            end
        end
        %removing the old peak
        pPeaks(selectedpLoc)=[];
        pPeakYs(selectedpLoc)=[];
    else
        %the following set of conditionals ensures that the new peak is
        %added in the appropriate order (keeping pPeaks arranged from left
        %to right)
        for index = 1:length(pPeaks)
            if pPeaks(index) > qPeaks(selectedqLoc)
                if index == 1
                    pPeaks = [qPeaks(selectedqLoc) pPeaks];
                    pPeakYs = [qPeakYs(selectedqLoc) pPeakYs];
                else
                    pPeaks = [pPeaks(1:index-1) qPeaks(selectedqLoc) pPeaks(index:end)];
                    pPeakYs = [pPeakYs(1:index-1) qPeakYs(selectedqLoc) pPeakYs(index:end)];
                end
                break;
            end
            if index == length(pPeaks)
                pPeaks = [pPeaks qPeaks(selectedqLoc)];
                pPeakYs = [pPeakYs qPeakYs(selectedqLoc)];
            end
        end
        %removing the old peak
        qPeaks(selectedqLoc)=[];
        qPeakYs(selectedqLoc)=[];
    end
end

% update allPeaks
allPeaks{currfile,ROIcount(currfile,2),1} = pPeaks;
allPeaks{currfile,ROIcount(currfile,2),2} = qPeaks;
allPeaks{currfile,ROIcount(currfile,2),3} = pPeakYs;
allPeaks{currfile,ROIcount(currfile,2),4} = qPeakYs;
assignin('base','allPeaks',allPeaks)

storageX = handles.ROIaxes.XLim;
storageY = handles.ROIaxes.YLim;
%Plot updated peaks
axes(handles.ROIaxes),cla
tempData=AllsubData{1,currfile}{1,ROIcount(currfile,2)};
plot(tempData);
xlim(storageX);
ylim(storageY);
hold on
PlotAllRelevantPoints(allPeaks, currfile, ROIcount, tempData), hold off
set(handles.ROIaxes,'xticklabel',[])
set(handles.ROIaxes,'yticklabel',[])
clear tempData
set(handles.SelectPeakButton,'UserData',[]);
set(handles.BoxPeaksButton,'UserData',[]);
assignin('base','selectedYellow',[]);
assignin('base','selectedArrythmias',[]);
assignin('base','selectedMinima',[]);

% --- Executes on button press in DeleteYellowPeaksButton.
function DeleteYellowPeaksButton_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteYellowPeaksButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%If peaks boxed: deletes all yellow markers in the box
%If points selected: deletes the 'nearest' yellow markers to all points selected
%(note: x-axis and y-axis distances are not weighted equally)

%Note: no peaks are deleted by this button; slight misnomer

selectedYellow = evalin('base', 'selectedYellow');
selectedPoints=[get(handles.SelectPeakButton,'UserData') selectedYellow];
AllsubData=evalin('base','AllsubData');
currfile=get(handles.filelist,'Value');
ROIcount=evalin('base','ROIcount');
allPeaks=evalin('base','allPeaks');

peaks=allPeaks{currfile,ROIcount(currfile,2),5};
peakYs = allPeaks{currfile,ROIcount(currfile,2),6};

% Find which peak points are closest to

for ii=1:size(selectedPoints)
    [selectedPeak,selectedLoc]=min((peaks-selectedPoints(ii, 1)).^2 + (YAxisMultiplier(handles)*(peakYs - selectedPoints(ii, 2))).^2);
    peaks(selectedLoc)=[];
    peakYs(selectedLoc)=[];
end


allPeaks{currfile,ROIcount(currfile,2),5} = peaks;
allPeaks{currfile,ROIcount(currfile,2),6} = peakYs;
assignin('base','allPeaks',allPeaks)
storageX = handles.ROIaxes.XLim;
storageY = handles.ROIaxes.YLim;
%Plot updated peaks
axes(handles.ROIaxes),cla
tempData=AllsubData{1,currfile}{1,ROIcount(currfile,2)};
plot(tempData);
tempData=AllsubData{1,currfile}{1,ROIcount(currfile,2)};
plot(tempData),
xlim(storageX);
ylim(storageY);
hold on
PlotAllRelevantPoints(allPeaks, currfile, ROIcount, tempData), hold off
set(handles.ROIaxes,'xticklabel',[])
set(handles.ROIaxes,'yticklabel',[])
clear tempData
set(handles.SelectPeakButton,'UserData',[]);
set(handles.BoxPeaksButton,'UserData',[]);
assignin('base','selectedYellow',[]);
assignin('base','selectedArrythmias',[]);
assignin('base','selectedMinima',[]);

% --- Executes on button press in ClearYellowPeaksButton.
function ClearYellowPeaksButton_Callback(hObject, eventdata, handles)
% hObject    handle to ClearYellowPeaksButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Removes all yellow markers remaining on the plot

%Note: no actual peaks are removed

selectedPoints=get(handles.SelectPeakButton,'UserData');
AllsubData=evalin('base','AllsubData');
currfile=get(handles.filelist,'Value');
ROIcount=evalin('base','ROIcount');
allPeaks=evalin('base','allPeaks');

allPeaks{currfile,ROIcount(currfile,2),5} = [];
allPeaks{currfile,ROIcount(currfile,2),6} = [];
assignin('base','allPeaks',allPeaks)
storageX = handles.ROIaxes.XLim;
storageY = handles.ROIaxes.YLim;
%Plot updated peaks
axes(handles.ROIaxes), cla
tempData=AllsubData{1,currfile}{1,ROIcount(currfile,2)};
plot(tempData),
xlim(storageX);
ylim(storageY);
hold on
PlotAllRelevantPoints(allPeaks, currfile, ROIcount, tempData), hold off
set(handles.ROIaxes,'xticklabel',[])
set(handles.ROIaxes,'yticklabel',[])
clear tempData
set(handles.SelectPeakButton,'UserData',[]);

% --- Executes on button press in AddPPeaksButton.
function AddPPeaksButton_Callback(hObject, eventdata, handles)
% hObject    handle to AddPPeaksButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%If peaks boxed: does nothing, may cause an error- incompatible
%If points selected: adds a P peak to the highest point within 50 (current setting of X_AXIS_CLICK_RANGE)
%along the x-axis

selectedPoints=get(handles.SelectPeakButton,'UserData');
sz=size(selectedPoints);
AllsubData=evalin('base','AllsubData');
currfile=get(handles.filelist,'Value');
ROIcount=evalin('base','ROIcount');
allPeaks=evalin('base','allPeaks');

tempData=AllsubData{1,currfile}{1,ROIcount(currfile,2)};

pPeaks=allPeaks{currfile,ROIcount(currfile,2),1};
pPeakYs=allPeaks{currfile,ROIcount(currfile,2),3};

X_AXIS_CLICK_RANGE = 50;
Y_AXIS_CLICK_RANGE = 0.05;
% Find which data point selected peak is closest to
for ii=1:sz(1)
    addedPeaks(ii)=round(selectedPoints(ii,1));
    valaddedPeaks(ii)=selectedPoints(ii,2);
    optimalLoc = 0;
    currMax = 0;
    for jj =addedPeaks(ii)-X_AXIS_CLICK_RANGE:1:addedPeaks(ii)+X_AXIS_CLICK_RANGE
        if(tempData(jj) < Y_AXIS_CLICK_RANGE + selectedPoints(ii, 2) && currMax < tempData(jj))
            currMax = tempData(jj);
            optimalLoc = jj;
        end
    end
    addedPeaks(ii)= optimalLoc;
    %adding the peak in order
    for index = 1:length(pPeaks)
        if pPeaks(index) > addedPeaks(ii)
            if index == 1
                pPeaks = [addedPeaks(ii) pPeaks];
                pPeakYs = [tempData(addedPeaks(ii)) pPeakYs];
            else
                pPeaks = [pPeaks(1:index-1) addedPeaks(ii) pPeaks(index:end)];
                pPeakYs = [pPeakYs(1:index-1) tempData(addedPeaks(ii)) pPeakYs(index:end)];
            end
            break;
        end
        if index == length(pPeaks)
            pPeaks = [pPeaks addedPeaks(ii)];
            pPeakYs = [pPeakYs tempData(addedPeaks(ii))];
        end
    end
end

allPeaks{currfile,ROIcount(currfile,2),1} = pPeaks;
allPeaks{currfile,ROIcount(currfile,2),3} = pPeakYs;
assignin('base','allPeaks',allPeaks)

storageX = handles.ROIaxes.XLim;
storageY = handles.ROIaxes.YLim;
%Plot updated peaks
axes(handles.ROIaxes), cla
plot(tempData),
xlim(storageX);
ylim(storageY);
hold on
PlotAllRelevantPoints(allPeaks, currfile, ROIcount, tempData), hold off
set(handles.ROIaxes,'xticklabel',[])
set(handles.ROIaxes,'yticklabel',[])
clear tempData
set(handles.SelectPeakButton,'UserData',[]);

% --- Executes on button press in AddQRSPeaksButton.
function AddQRSPeaksButton_Callback(hObject, eventdata, handles)

%If peaks boxed: does nothing, may cause an error- incompatible
%If points selected: adds a Q peak to the highest point within 50 (current setting of X_AXIS_CLICK_RANGE)
%along the x-axis

% hObject    handle to AddQRSPeaksButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selectedPoints=get(handles.SelectPeakButton,'UserData');
sz=size(selectedPoints);
AllsubData=evalin('base','AllsubData');
currfile=get(handles.filelist,'Value');
ROIcount=evalin('base','ROIcount');
allPeaks=evalin('base','allPeaks');

tempData=AllsubData{1,currfile}{1,ROIcount(currfile,2)};

qPeaks=allPeaks{currfile,ROIcount(currfile,2),2};
qPeakYs=allPeaks{currfile,ROIcount(currfile,2),4};

X_AXIS_CLICK_RANGE = 50;
Y_AXIS_CLICK_RANGE = 0.05;
% Find which data point selected peak is closest to
for ii=1:sz(1)
    addedPeaks(ii)=round(selectedPoints(ii,1));
    valaddedPeaks(ii)=selectedPoints(ii,2);
    optimalLoc = 0;
    currMax = 0;
    for jj =addedPeaks(ii)-X_AXIS_CLICK_RANGE:1:addedPeaks(ii)+X_AXIS_CLICK_RANGE
        if(tempData(jj) < Y_AXIS_CLICK_RANGE + selectedPoints(ii, 2) && currMax < tempData(jj))
            currMax = tempData(jj);
            optimalLoc = jj;
        end
    end
    addedPeaks(ii)= optimalLoc;
    %adding the peak in order
    for index = 1:length(qPeaks)
        if qPeaks(index) > addedPeaks(ii)
            if index == 1
                qPeaks = [addedPeaks(ii) qPeaks];
                qPeakYs = [tempData(addedPeaks(ii)) qPeakYs];
            else
                qPeaks = [qPeaks(1:index-1) addedPeaks(ii) qPeaks(index:end)];
                qPeakYs = [qPeakYs(1:index-1) tempData(addedPeaks(ii)) qPeakYs(index:end)];
            end
            break;
        end
        if index == length(qPeaks)
            qPeaks = [qPeaks addedPeaks(ii)];
            qPeakYs = [qPeakYs tempData(addedPeaks(ii))];
        end
    end
end

allPeaks{currfile,ROIcount(currfile,2),2} = qPeaks;
allPeaks{currfile,ROIcount(currfile,2),4} = qPeakYs;
assignin('base','allPeaks',allPeaks)

storageX = handles.ROIaxes.XLim;
storageY = handles.ROIaxes.YLim;
%Plot updated peaks
axes(handles.ROIaxes), cla
plot(tempData),
xlim(storageX);
ylim(storageY);
hold on
PlotAllRelevantPoints(allPeaks, currfile, ROIcount, tempData), hold off
set(handles.ROIaxes,'xticklabel',[]);
set(handles.ROIaxes,'yticklabel',[]);
clear tempData
set(handles.SelectPeakButton,'UserData',[]);

% --- Executes on button press in AddMinimaButton.
function AddMinimaButton_Callback(hObject, eventdata, handles)
% hObject    handle to AddMinimaButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%If peaks boxed: does nothing, may cause an error- incompatible
%If points selected: adds a minimum marker to the lowest point within 50 (current setting of X_AXIS_CLICK_RANGE)
%along the x-axis

selectedPoints=get(handles.SelectPeakButton,'UserData');
sz=size(selectedPoints);
AllsubData=evalin('base','AllsubData');
currfile=get(handles.filelist,'Value');
ROIcount=evalin('base','ROIcount');
allPeaks=evalin('base','allPeaks');

tempData=AllsubData{1,currfile}{1,ROIcount(currfile,2)};

minima=allPeaks{currfile,ROIcount(currfile,2),9};
minimaYs=allPeaks{currfile,ROIcount(currfile,2),10};

X_AXIS_CLICK_RANGE = 50;
Y_AXIS_CLICK_RANGE = 0.05;

% Find which data point selected peak is closest to
for ii=1:sz(1)
    addedPeaks(ii)=round(selectedPoints(ii,1));
    valaddedPeaks(ii)=selectedPoints(ii,2);
    optimalLoc = 0;
    currMin = 1;
    for jj =addedPeaks(ii)-X_AXIS_CLICK_RANGE:1:addedPeaks(ii)+X_AXIS_CLICK_RANGE
        if(tempData(jj) > selectedPoints(ii, 2) - Y_AXIS_CLICK_RANGE && currMin > tempData(jj))
            currMin = tempData(jj);
            optimalLoc = jj;
        end
    end
    addedPeaks(ii)= optimalLoc;
    %adding the peak in order
    for index = 1:length(minima)
        if minima(index) > addedPeaks(ii)
            if index == 1
                minima = [addedPeaks(ii) minima];
                minimaYs = [tempData(addedPeaks(ii)) minimaYs];
            else
                minima = [minima(1:index-1) addedPeaks(ii) minima(index:end)];
                minimaYs = [minimaYs(1:index-1) tempData(addedPeaks(ii)) minimaYs(index:end)];
            end
            break;
        end
        if index == length(minima)
            minima = [minima addedPeaks(ii)];
            minimaYs = [minimaYs tempData(addedPeaks(ii))];
        end
    end
end

allPeaks{currfile,ROIcount(currfile,2),9} = minima;
allPeaks{currfile,ROIcount(currfile,2),10} = minimaYs;
assignin('base','allPeaks',allPeaks)

storageX = handles.ROIaxes.XLim;
storageY = handles.ROIaxes.YLim;
%Plot updated peaks
axes(handles.ROIaxes), cla
plot(tempData),
xlim(storageX);
ylim(storageY);
hold on
PlotAllRelevantPoints(allPeaks, currfile, ROIcount, tempData), hold off
set(handles.ROIaxes,'xticklabel',[]);
clear tempData
set(handles.SelectPeakButton,'UserData',[]);

% --- Executes on button press in DeleteMinimaButton.
function DeleteMinimaButton_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteMinimaButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure

%If peaks boxed: deletes all minima in the box
%If points selected: deletes the 'nearest' minima to all points selected
%(note: x-axis and y-axis distances are not weighted equally)

selectedMinima = evalin('base', 'selectedMinima');
selectedPoints=[get(handles.SelectPeakButton,'UserData') selectedMinima];
AllsubData=evalin('base','AllsubData');
currfile=get(handles.filelist,'Value');
ROIcount=evalin('base','ROIcount');
allPeaks=evalin('base','allPeaks');

%referred to minima as peaks
peaks=allPeaks{currfile,ROIcount(currfile,2),9};
peakYs = allPeaks{currfile,ROIcount(currfile,2),10};

% Find which peak points are closest to

for ii=1:size(selectedPoints)
    [selectedPeak,selectedLoc]=min((peaks-selectedPoints(ii, 1)).^2 + (YAxisMultiplier(handles)*(peakYs - selectedPoints(ii, 2))).^2);
    peaks(selectedLoc)=[];
    peakYs(selectedLoc)=[];
end

allPeaks{currfile,ROIcount(currfile,2),9} = peaks;
allPeaks{currfile,ROIcount(currfile,2),10} = peakYs;
assignin('base','allPeaks',allPeaks)
storageX = handles.ROIaxes.XLim;
storageY = handles.ROIaxes.YLim;
%Plot updated peaks
axes(handles.ROIaxes), cla
tempData=AllsubData{1,currfile}{1,ROIcount(currfile,2)};
plot(tempData),
xlim(storageX);
ylim(storageY);
hold on
PlotAllRelevantPoints(allPeaks, currfile, ROIcount, tempData), hold off
clear tempData
set(handles.SelectPeakButton,'UserData',[]);
set(handles.BoxPeaksButton,'UserData',[]);
set(handles.ROIaxes,'xticklabel',[]);
assignin('base','selectedYellow',[]);
assignin('base','selectedArrythmias',[]);
assignin('base','selectedMinima',[]);

% --- Executes on button press in SelectPeakButton.
function SelectPeakButton_Callback(hObject, eventdata, handles)
% hObject    handle to SelectPeakButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%allows the user to select a point, which is used in the functions above
%pressing the button again after a point is selected allows the user to
%select more points
%use of any of the functions above clears selections

%Note: use of this button while peaks are boxed is not recommended

currfile=get(handles.filelist,'Value');
ROIcount=evalin('base','ROIcount');
% ROIcount=get(handles.SegmentButton,'UserData',ROIcount)
AllsubData=evalin('base','AllsubData');
allPeaks=evalin('base','allPeaks');
Thresh=evalin('base','Thresh');

axes(handles.ROIaxes)
tempPlot=AllsubData{1,currfile}{1,ROIcount(currfile,2)};
h=impoint;

selectedPoints=get(handles.SelectPeakButton,'UserData');
newPoint=h.getPosition;

if length(selectedPoints)>0
    selectedPoints(end+1,:)=newPoint;
else
    selectedPoints(1,:)=newPoint;
end

set(handles.SelectPeakButton,'UserData',selectedPoints);

% --- Executes on button press in BoxPeaksButton.
function BoxPeaksButton_Callback(hObject, eventdata, handles)
% hObject    handle to BoxPeaksButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%allows the user to select all critical points (points with markers)
%in a box, which are used in the functions above
%use of any of the functions above (with the exception of selecting points) clears selections

%Note: use of this button while peaks are already boxed or selected is not recommended

currfile=get(handles.filelist,'Value');
ROIcount=evalin('base','ROIcount');
AllsubData=evalin('base','AllsubData');
allPeaks=evalin('base','allPeaks');
Thresh=evalin('base','Thresh');

axes(handles.ROIaxes)
tempPlot=AllsubData{1,currfile}{1,ROIcount(currfile,2)};
h=drawpoint;
j=drawpoint;

point1 = h.Position;
point2 = j.Position;

%using the points selected to determine the bottom left corner and dimensions of the
%rectangle
if (point1(1) > point2(1))
    largerXval = point1(1);
    smallerXval = point2(1);
else
    largerXval = point2(1);
    smallerXval = point1(1);
end

if (point1(2) > point2(2))
    largerYval = point1(2);
    smallerYval = point2(2);
else
    largerYval = point2(2);
    smallerYval = point1(2);
end
rectWidth = largerXval - smallerXval;
rectHeight = largerYval - smallerYval;

%using the bottom left corner and the dimensions to construct the rectangle
rectangle('Position', [smallerXval smallerYval rectWidth rectHeight]);

pPeaks=allPeaks{currfile,ROIcount(currfile,2),1};
qPeaks=allPeaks{currfile,ROIcount(currfile,2),2};
pPeakYs=allPeaks{currfile,ROIcount(currfile,2),3};
qPeakYs=allPeaks{currfile,ROIcount(currfile,2),4};
problemInd=allPeaks{currfile,ROIcount(currfile,2),5};
problemYs=allPeaks{currfile,ROIcount(currfile,2),6};
arrythmias=allPeaks{currfile,ROIcount(currfile,2),7};
arrythmiaYs=allPeaks{currfile,ROIcount(currfile,2),8};
minima=allPeaks{currfile,ROIcount(currfile,2),9};
minimaYs=allPeaks{currfile,ROIcount(currfile,2),10};
selectedPeaks = [];
selectedYellow = [];
selectedArrythmias = [];
selectedMinima = [];

%finding all pPeaks inside the box
for ii=1:length(pPeaks)
    if ((pPeaks(ii)<largerXval && pPeaks(ii)> smallerXval && pPeakYs(ii)<largerYval && pPeakYs(ii)> smallerYval))
        if length(selectedPeaks)>0
            selectedPeaks(end+1,:)= [pPeaks(ii) pPeakYs(ii)];
        else
            selectedPeaks(1,:)= [pPeaks(ii) pPeakYs(ii)];
        end
    end
end

%finding all qPeaks inside the box
for ii=1:length(qPeaks)
    if ((qPeaks(ii)<largerXval && qPeaks(ii)> smallerXval && qPeakYs(ii)<largerYval && qPeakYs(ii)> smallerYval))
        if length(selectedPeaks)>0
            selectedPeaks(end+1,:)= [qPeaks(ii) qPeakYs(ii)];
        else
            selectedPeaks(1,:)= [qPeaks(ii) qPeakYs(ii)];
        end
    end
end

%finding all yellow points inside the box
for ii=1:length(problemInd)
    if ((problemInd(ii)<largerXval && problemInd(ii)> smallerXval && problemYs(ii)<largerYval && problemYs(ii)> smallerYval))
        if length(selectedYellow)>0
            selectedYellow(end+1,:)= [problemInd(ii) problemYs(ii)];
        else
            selectedYellow(1,:)= [problemInd(ii) problemYs(ii)];
        end
    end
end

%finding all arrythmias inside the box
for ii=1:length(arrythmias)
    if ((arrythmias(ii)<largerXval && arrythmias(ii)> smallerXval && arrythmiaYs(ii)<largerYval && arrythmiaYs(ii)> smallerYval))
        if length(selectedArrythmias)>0
            selectedArrythmias(end+1,:)= [arrythmias(ii) arrythmiaYs(ii)];
        else
            selectedArrythmias(1,:)= [arrythmias(ii) arrythmiaYs(ii)];
        end
    end
end

%finding all QRS minima inside the box
for ii=1:length(minima)
    if ((minima(ii)<largerXval && minima(ii)> smallerXval && minimaYs(ii)<largerYval && minimaYs(ii)> smallerYval))
        if length(selectedMinima)>0
            selectedMinima(end+1,:)= [minima(ii) minimaYs(ii)];
        else
            selectedMinima(1,:)= [minima(ii) minimaYs(ii)];
        end
    end
end

%storing these for use in the above functions
set(handles.BoxPeaksButton,'UserData',selectedPeaks);
assignin('base','selectedYellow',selectedYellow);
assignin('base','selectedArrythmias',selectedArrythmias);
assignin('base','selectedMinima',selectedMinima);

% --- Executes on button press in DeselectButton.
function DeselectButton_Callback(hObject, eventdata, handles)
% hObject    handle to DeselectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%deselects all boxed peaks (critical points) and selected points

AllsubData=evalin('base','AllsubData');
currfile=get(handles.filelist,'Value');
ROIcount=evalin('base','ROIcount');
allPeaks=evalin('base','allPeaks');

storageX = handles.ROIaxes.XLim;
storageY = handles.ROIaxes.YLim;
%Plot updated peaks
axes(handles.ROIaxes), cla
tempData=AllsubData{1,currfile}{1,ROIcount(currfile,2)};
plot(tempData),
xlim(storageX);
ylim(storageY);
hold on
PlotAllRelevantPoints(allPeaks, currfile, ROIcount, tempData), hold off
set(handles.ROIaxes,'xticklabel',[]);
clear tempData
set(handles.SelectPeakButton,'UserData',[]);
set(handles.BoxPeaksButton,'UserData',[]);
assignin('base','selectedYellow',[]);
assignin('base','selectedArrythmias',[]);
assignin('base','selectedMinima',[]);

%% Functions to plot compiled and average trace

% --- Executes on button press in AvgTraceButton.
function AvgTraceButton_Callback(hObject, eventdata, handles)
% hObject    handle to AvgTraceButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%constructs an average trace from the QRS peaks, and sets an isolectric
%line

axes(handles.AverageAxes),cla
set(handles.AverageAxes,'FontSize',8)

currfile=get(handles.filelist,'Value');
ROIcount=evalin('base','ROIcount');

AllsubData=evalin('base','AllsubData');
allPeaks=evalin('base','allPeaks');
allAvgTraces=evalin('base','allAvgTraces');
allECGpk=evalin('base','allECGpk');
allQRSwidth=evalin('base','allQRSwidth');

%these are used to determine SUBTRACTION_CONSTANT and ADDITION_CONSTANT
PQRS_GAP_MULTIPLIER = evalin('base', 'PQRS_GAP_MULTIPLIER');
RR_MULTIPLIER = evalin('base', 'RR_MULTIPLIER');


Alltraces=AllsubData{1,currfile};
CurrTrace=AllsubData{1,currfile}{1,ROIcount(currfile,2)};
pInd=allPeaks{currfile,ROIcount(currfile,2),1};
qInd=allPeaks{currfile,ROIcount(currfile,2),2};
% currPeaks

%this for loop deals with the case where the trace starts with a QRS peak,
%or even 3 QRS peaks
for i=1:3
    if qInd(1) < pInd(1)
        qInd(1) = [];
    end
end

%this for loop deals with the case where the trace starts with 2-4
%consecutive P peaks
for i=1:3
    if pInd(2) < qInd(1)
        pInd(1) = [];
    end
end


%determines how far the window extends from the QRS peak on the left
SUBTRACTION_CONSTANT = round(PQRS_GAP_MULTIPLIER * (qInd(1) - pInd(1)));

%determines how far the window extends from the QRS peak on the right
ADDITION_CONSTANT = round(RR_MULTIPLIER * (qInd(length(qInd)) - qInd(1))/length(qInd));

% Line up traces
while qInd(1)<SUBTRACTION_CONSTANT+1
    pInd(1)=[];
    qInd(1)=[];
end

% Plot all traces
traces{1,:}=CurrTrace(qInd(1)-SUBTRACTION_CONSTANT:qInd(1)+ADDITION_CONSTANT);

axes(handles.AverageAxes), plot(traces{1,:},'-g', 'LineWidth', 1), hold on
set(handles.AverageAxes,'yticklabel',[])
set(handles.AverageAxes,'xticklabel',[])
grid(handles.AverageAxes,'on')
set(handles.AverageAxes,'FontSize',8)

for i=2:length(qInd)-1
    tempTrace=CurrTrace(qInd(i)-SUBTRACTION_CONSTANT:qInd(i)+ADDITION_CONSTANT);
    traces{i}=tempTrace;
    plot(tempTrace,'-g','LineWidth',1)
end

if qInd(length(qInd)) + ADDITION_CONSTANT + 1 < length(CurrTrace)
    tempTrace=CurrTrace(qInd(length(qInd))-SUBTRACTION_CONSTANT:qInd(length(qInd))+ADDITION_CONSTANT);
    traces{length(qInd)}=tempTrace;
    plot(tempTrace,'-g','LineWidth',1)
end

numtraces=size(traces,2);
for j=1:numtraces
    templn=length(traces{j});
    lentraces(j)=templn;
end

% Plot average trace
minlntraces=min(lentraces);
maxlntraces=max(lentraces);

for i=1:maxlntraces
    for j=1:numtraces
        if i<length(traces{1,j})
            temptr(j)=traces{1,j}(i);
        end
    end
    avgTrace(i)=mean(temptr);
end
plot(avgTrace, '-k', 'LineWidth', 0.6)


%old isoelectric line
%isoelectricLength = length(avgTrace);
%isoelectricY = avgTrace(1);
%plot([1, isoelectricLength], [isoelectricY, isoelectricY], 'cyan', 'LineWidth', 1.0), hold on

hold off

allECGpk{currfile,ROIcount(currfile,2)}=0;
assignin('base','allECGpk',allECGpk)

allQRSwidth{currfile,ROIcount(currfile,2)}=0;
assignin('base','allQRSwidth',allQRSwidth)

allAvgTraces{currfile,ROIcount(currfile,2)}=avgTrace;
assignin('base','allAvgTraces',allAvgTraces)

assignin('base','PQRS_GAP_MULTIPLIER',PQRS_GAP_MULTIPLIER)
assignin('base','RR_MULTIPLIER',RR_MULTIPLIER)
assignin('base','SUBTRACTION_CONSTANT',SUBTRACTION_CONSTANT)
assignin('base','ADDITION_CONSTANT',ADDITION_CONSTANT)
assignin('base','calculateAvgButtonPressed',true); %for use in upcoming functions
assignin('base','minimaAvgButtonPressed',false); %for use in upcoming functions

% --- Executes on button press in MinimaAverageButton.
function MinimaAverageButton_Callback(hObject, eventdata, handles)
% hObject    handle to MinimaAverageButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%constructs an average trace from the QRS minima, and sets an isolectric
%line; the function assumes that the peaks are unrealiable, and therefore
%does not refer to them directly

axes(handles.AverageAxes),cla
set(handles.AverageAxes,'FontSize',8)

currfile=get(handles.filelist,'Value');
ROIcount=evalin('base','ROIcount');

AllsubData=evalin('base','AllsubData');
allPeaks=evalin('base','allPeaks');
allAvgTraces=evalin('base','allAvgTraces');
allECGpk=evalin('base','allECGpk');
allQRSwidth=evalin('base','allQRSwidth');

%these are used to determine SUBTRACTION_CONSTANT and ADDITION_CONSTANT
PQRS_GAP_MULTIPLIER = evalin('base', 'PQRS_GAP_MULTIPLIER');
RR_MULTIPLIER = evalin('base', 'RR_MULTIPLIER');

P_QRS_TO_RR_RATIO = 0.2; %need to arbitrarily assume a value for this, and the pInd and qInd cannot be reliably used by this function; being a bit more liberal with it- would rather graph too much than too little

Alltraces=AllsubData{1,currfile};
CurrTrace=AllsubData{1,currfile}{1,ROIcount(currfile,2)};
minimaInd=allPeaks{currfile,ROIcount(currfile,2),9};

averageRR = round((minimaInd(length(minimaInd))-minimaInd(1))/length(minimaInd));

%determines how far the window extends from the QRS minimum on the right
ADDITION_CONSTANT = round(RR_MULTIPLIER *  averageRR);

%determines how far the window extends from the QRS minimum on the left
SUBTRACTION_CONSTANT = round(PQRS_GAP_MULTIPLIER * P_QRS_TO_RR_RATIO * averageRR);

% Line up traces
while minimaInd(1)<SUBTRACTION_CONSTANT+1
    minimaInd(1) = [];
end

% Plot all traces

traces{1,:}=CurrTrace(minimaInd(1)-SUBTRACTION_CONSTANT:minimaInd(1)+ADDITION_CONSTANT);

axes(handles.AverageAxes), plot(traces{1,:},'-g', 'LineWidth', 1), hold on
set(handles.AverageAxes,'yticklabel',[])
grid(handles.AverageAxes,'on')
set(handles.AverageAxes,'FontSize',8)

for i=2:length(minimaInd)-1
    tempTrace=CurrTrace(minimaInd(i)-SUBTRACTION_CONSTANT:minimaInd(i)+ADDITION_CONSTANT);
    traces{i}=tempTrace;
    plot(tempTrace,'-g','LineWidth',1)
    %plot(norm_data(pl(pInd(i))-50:pl(pInd(i+1))-50))
end

if minimaInd(length(minimaInd)) + ADDITION_CONSTANT + 1 < length(CurrTrace)
    tempTrace=CurrTrace(minimaInd(length(minimaInd))-SUBTRACTION_CONSTANT:minimaInd(length(minimaInd))+ADDITION_CONSTANT);
    traces{length(minimaInd)}=tempTrace;
    plot(tempTrace,'-g','LineWidth',1)
end

numtraces=size(traces,2);
for j=1:numtraces
    templn=length(traces{j});
    lentraces(j)=templn;
end

% Plot average trace
minlntraces=min(lentraces);
maxlntraces=max(lentraces);

for i=1:maxlntraces
    for j=1:numtraces
        if i<length(traces{1,j})
            temptr(j)=traces{1,j}(i);
        end
    end
    %plot(ones(1,numtraces).*i,temptr,'r*')
    avgTrace(i)=mean(temptr);
end
plot(avgTrace, '-k', 'LineWidth', 0.6)

%old isoelectric line
%isoelectricLength = length(avgTrace);
%isoelectricY = avgTrace(1);
%plot([1, isoelectricLength], [isoelectricY, isoelectricY], 'cyan', 'LineWidth', 1.0), hold on

hold off

allECGpk{currfile,ROIcount(currfile,2)}=0;
assignin('base','allECGpk',allECGpk)

allQRSwidth{currfile,ROIcount(currfile,2)}=0;
assignin('base','allQRSwidth',allQRSwidth)

allAvgTraces{currfile,ROIcount(currfile,2)}=avgTrace;
assignin('base','allAvgTraces',allAvgTraces)

assignin('base','PQRS_GAP_MULTIPLIER',PQRS_GAP_MULTIPLIER)
assignin('base','RR_MULTIPLIER',RR_MULTIPLIER)
assignin('base','SUBTRACTION_CONSTANT',SUBTRACTION_CONSTANT)
assignin('base','ADDITION_CONSTANT',ADDITION_CONSTANT)
assignin('base','calculateAvgButtonPressed',false); %for use in later functions
assignin('base','minimaAvgButtonPressed',true); %for use in later functions

% --- Executes on button press in LeftMinusButton.
function LeftMinusButton_Callback(hObject, eventdata, handles)
% hObject    handle to LeftMinusButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%decreases the size of the average trace window on the left

PQRS_GAP_MULTIPLIER = evalin('base', 'PQRS_GAP_MULTIPLIER');
PQRS_GAP_MULTIPLIER = PQRS_GAP_MULTIPLIER - 0.2;
assignin('base','PQRS_GAP_MULTIPLIER',PQRS_GAP_MULTIPLIER)
plotAvg = evalin('base', 'calculateAvgButtonPressed');
plotMinima = evalin('base', 'minimaAvgButtonPressed');

%replotting with the new window; plot drawn is based on which button was
%pressed earlier
if plotAvg == true
    AvgTraceButton_Callback(hObject, eventdata, handles)
end
if plotMinima == true
    MinimaAverageButton_Callback(hObject, eventdata, handles)
end

% --- Executes on button press in LeftPlusButton.
function LeftPlusButton_Callback(hObject, eventdata, handles)
% hObject    handle to LeftPlusButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%increases the size of the average trace window on the left

PQRS_GAP_MULTIPLIER = evalin('base', 'PQRS_GAP_MULTIPLIER');
PQRS_GAP_MULTIPLIER = PQRS_GAP_MULTIPLIER + 0.2;
assignin('base','PQRS_GAP_MULTIPLIER',PQRS_GAP_MULTIPLIER)
plotAvg = evalin('base', 'calculateAvgButtonPressed');
plotMinima = evalin('base', 'minimaAvgButtonPressed');

%replotting with the new window; plot drawn is based on which button was
%pressed earlier
if plotAvg == true
    AvgTraceButton_Callback(hObject, eventdata, handles)
end
if plotMinima == true
    MinimaAverageButton_Callback(hObject, eventdata, handles)
end

% --- Executes on button press in RightMinusButton.
function RightMinusButton_Callback(hObject, eventdata, handles)
% hObject    handle to RightMinusButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%decreases the size of the average trace window on the right

RR_MULTIPLIER = evalin('base', 'RR_MULTIPLIER');
RR_MULTIPLIER = RR_MULTIPLIER - 0.1;
assignin('base','RR_MULTIPLIER',RR_MULTIPLIER)
plotAvg = evalin('base', 'calculateAvgButtonPressed');
plotMinima = evalin('base', 'minimaAvgButtonPressed');

%replotting with the new window; plot drawn is based on which button was
%pressed earlier
if plotAvg == true
    AvgTraceButton_Callback(hObject, eventdata, handles)
end
if plotMinima == true
    MinimaAverageButton_Callback(hObject, eventdata, handles)
end

% --- Executes on button press in RightPlusButton.
function RightPlusButton_Callback(hObject, eventdata, handles)
% hObject    handle to RightPlusButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%increases the size of the average trace window on the right

RR_MULTIPLIER = evalin('base', 'RR_MULTIPLIER');
RR_MULTIPLIER = RR_MULTIPLIER + 0.1;
assignin('base','RR_MULTIPLIER',RR_MULTIPLIER)
plotAvg = evalin('base', 'calculateAvgButtonPressed');
plotMinima = evalin('base', 'minimaAvgButtonPressed');

%replotting with the new window; plot drawn is based on which button was
%pressed earlier
if plotAvg == true
    AvgTraceButton_Callback(hObject, eventdata, handles)
end
if plotMinima == true
    MinimaAverageButton_Callback(hObject, eventdata, handles)
end

% --- Executes on button press in CompressButton.
function CompressButton_Callback(hObject, eventdata, handles)
% hObject    handle to CompressButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%compresses the average trace along the x-axis by a factor of 1.5

axes(handles.AverageAxes)
set(handles.AverageAxes,'FontSize',8)
storageX = handles.AverageAxes.XLim;
xlim(1.5 * storageX);

% --- Executes on button press in DecompressButton.
function DecompressButton_Callback(hObject, eventdata, handles)
% hObject    handle to DecompressButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%decompresses the average trace along the x-axis by a factor of 1.5

axes(handles.AverageAxes)
set(handles.AverageAxes,'FontSize',8)
storageX = handles.AverageAxes.XLim;
xlim(2 * storageX/3);

% --- Executes on button press in FindAvgPeaksbutton.
function FindAvgPeaksbutton_Callback(hObject, eventdata, handles)
% hObject    handle to FindAvgPeaksbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%this function finds and labels the following points on the average trace:
%P wave start, P wave peak, P wave end, QRS wave start, QRS wave peak,
%QRS wave end, T wave start, T wave peak, and T wave end; the labeling is
%done with vertical lines, which can be adjusted by the user in the case of
%mislabeling

currfile=get(handles.filelist,'Value');
ROIcount=evalin('base','ROIcount');
allAvgTraces=evalin('base','allAvgTraces');
allECGpk=evalin('base','allECGpk');
allQRSwidth=evalin('base','allQRSwidth');
SUBTRACTION_CONSTANT = evalin('base','SUBTRACTION_CONSTANT');
ADDITION_CONSTANT = evalin('base','ADDITION_CONSTANT');
plotAvg = evalin('base', 'calculateAvgButtonPressed');
plotMinima = evalin('base', 'minimaAvgButtonPressed');

AllsubData=evalin('base','AllsubData');
allPeaks=evalin('base','allPeaks');

Alltraces=AllsubData{1,currfile};
CurrTrace=AllsubData{1,currfile}{1,ROIcount(currfile,2)};
pInd=allPeaks{currfile,ROIcount(currfile,2),1};
qInd=allPeaks{currfile,ROIcount(currfile,2),2};
minimaInd=allPeaks{currfile,ROIcount(currfile,2),9};

firstPQRSgap = 0;

if plotAvg
    %this for loop deals with the case where the trace starts with a QRS peak,
    %or even 3 QRS peaks
    for i=1:3
        if (qInd(1) < pInd(1))
            qInd(1) = [];
        end
    end
    
    %this for loop deals with the case where the trace starts with 2-4
    %consecutive P peaks
    for i=1:3
        if pInd(2) < qInd(1)
            pInd(1) = [];
        end
    end
    
    firstPQRSgap = qInd(1) - pInd(1);
    
else
    firstPQRSgap = 0.25 * round((minimaInd(length(minimaInd))-minimaInd(1))/length(minimaInd)); %taking a guess
end

currAvgTrace=allAvgTraces{currfile,ROIcount(currfile,2)};

%finding QRS peak
[qrsPk,qrsPklc]=findpeaks(currAvgTrace(round(0.7*SUBTRACTION_CONSTANT):round(1.3*SUBTRACTION_CONSTANT)),'NPeaks',1,'SortStr','descend');
qrsPklc = qrsPklc + round(0.7*SUBTRACTION_CONSTANT) -1;

%finding P peak

pPk = 0;
pPklc = 0;
if qrsPklc-1.5*firstPQRSgap > 0
    %this should typically be the interval checked; the other cases
    %represent highly unlikely, but possible, scenarios
    [pPk,pPklc]=findpeaks(currAvgTrace(round(qrsPklc-1.5*firstPQRSgap):round(qrsPklc-0.5*firstPQRSgap)),'NPeaks',1,'SortStr','descend');
    pPklc = pPklc + round(qrsPklc-1.5*firstPQRSgap) -1;
else
    if qrsPklc-0.5*firstPQRSgap > 0
        [pPk,pPklc]=findpeaks(currAvgTrace(round(1):round(qrsPklc-0.5*firstPQRSgap)),'NPeaks',1,'SortStr','descend');
        pPklc = pPklc + round(qrsPklc-1.5*firstPQRSgap) -1;
    else
        %using the value 50 b/c that is the default min peak dist value
        [pPk,pPklc]=findpeaks(currAvgTrace(round(1):round(qrsPklc-50)),'NPeaks',1,'SortStr','descend');
        pPklc = pPklc + round(qrsPklc-1.5*firstPQRSgap) -1;
    end
end

%finding T peak
[tPk,tPklc]=findpeaks(currAvgTrace(round(qrsPklc+50):round(qrsPklc+350)),'NPeaks',1,'SortStr','descend');
tPklc = tPklc + qrsPklc + 49;

ECGpklcsorted = [pPklc qrsPklc tPklc];
ECGpksorted = [pPk qrsPk tPk];

%respresents the distance of each wave's start from each wave's peak
ECGWLsorted = [0 0 0];

%respresents the distance of each wave's end from each wave's peak
ECGWRsorted = [0 0 0];

%change placement of P start and end to be closer or farther from minima
P_DIST_FROM_PEAK_MULTIPLIER = 0.75;

%P wave start dist
closestMin = 0;
for index = pPklc-1:-1:1
    if currAvgTrace(index) < currAvgTrace(index - 1)
        closestMin = index;
        break
    end
end

ECGWLsorted(1) = round(P_DIST_FROM_PEAK_MULTIPLIER * (pPklc-closestMin));

%P wave end dist
closestMin = 0;
for index = pPklc+1:qrsPklc
    if currAvgTrace(index) < currAvgTrace(index + 1)
        closestMin = index;
        break
    end
end

ECGWRsorted(1) = round(P_DIST_FROM_PEAK_MULTIPLIER * (closestMin - pPklc));

%change placement of QRS start and end to be closer or farther from minima
QRS_DIST_FROM_PEAK_MULTIPLIER = 0.85;

%Q wave start dist
closestMin = 0;
for index = qrsPklc-1:-1:1
    if currAvgTrace(index) < currAvgTrace(index - 1)
        closestMin = index;
        break
    end
end

ECGWLsorted(2) = round(QRS_DIST_FROM_PEAK_MULTIPLIER * (qrsPklc - closestMin));

%Q wave end dist
closestMin = 0;
for index = qrsPklc+1:tPklc
    if currAvgTrace(index) < currAvgTrace(index + 1)
        closestMin = index;
        break
    end
end

ECGWRsorted(2) = round(QRS_DIST_FROM_PEAK_MULTIPLIER * (closestMin - qrsPklc));

%T wave start dist
intervalMin = 0;
currMin = 1;
for index = qrsPklc+25:qrsPklc+100 %values chosen arbitrarily
    if (currMin > currAvgTrace(index))
        currMin = currAvgTrace(index);
        intervalMin = index;
    end
end

ECGWLsorted(3) = tPklc - intervalMin;

%T wave end dist
intervalMin = 0;
currMin = 1;
for index = tPklc+1:length(currAvgTrace)
    if (currMin > currAvgTrace(index))
        currMin = currAvgTrace(index);
        intervalMin = index;
    end
end

ECGWRsorted(3) = intervalMin - tPklc;

ECGSorted=[ECGpklcsorted;ECGpksorted;ECGWLsorted;ECGWRsorted];


axes(handles.AverageAxes)
set(handles.AverageAxes,'FontSize',8)
set(handles.AverageAxes,'yticklabel',[])
% if calculation was centered at QRS peak
if plotAvg == true
    % Line up traces
    if qInd(1)<SUBTRACTION_CONSTANT+1
        pInd(1)=[];
        qInd(1)=[];
    end
    
    traces{1,:}=CurrTrace(qInd(1)-SUBTRACTION_CONSTANT:qInd(1)+ADDITION_CONSTANT);
    
    % Plot average trace
    axes(handles.AverageAxes), plot(traces{1,:},'-g','LineWidth',1), hold on
    set(handles.AverageAxes,'yticklabel',[])
    %set(handles.AverageAxes,'xticklabel',[])
    grid(handles.AverageAxes,'on')
    set(handles.AverageAxes,'FontSize',8)
    
    for i=2:length(qInd)-1
        tempTrace=CurrTrace(qInd(i)-SUBTRACTION_CONSTANT:qInd(i)+ADDITION_CONSTANT);
        traces{i}=tempTrace;
        plot(tempTrace,'-g','LineWidth',1)
        %plot(norm_data(pl(pInd(i))-50:pl(pInd(i+1))-50))
    end
    
    if qInd(length(qInd)) + ADDITION_CONSTANT + 1 < length(CurrTrace)
        tempTrace=CurrTrace(qInd(length(qInd))-SUBTRACTION_CONSTANT:qInd(length(qInd))+ADDITION_CONSTANT);
        traces{length(qInd)}=tempTrace;
        plot(tempTrace,'-g','LineWidth',1)
    end
end

% if calculation was centered at QRS minima
if plotMinima == true
    % Line up traces
    if minimaInd(1)<SUBTRACTION_CONSTANT+1
        minimaInd(1) = [];
    end
    
    traces{1,:}=CurrTrace(minimaInd(1)-SUBTRACTION_CONSTANT:minimaInd(1)+ADDITION_CONSTANT);
    
    % Plot average trace
    axes(handles.AverageAxes), plot(traces{1,:},'-g','LineWidth',1), hold on
    set(handles.AverageAxes,'yticklabel',[])
    %set(handles.AverageAxes,'xticklabel',[])
    grid(handles.AverageAxes,'on')
    set(handles.AverageAxes,'FontSize',8)
    
    for i=2:length(minimaInd)-1
        tempTrace=CurrTrace(minimaInd(i)-SUBTRACTION_CONSTANT:minimaInd(i)+ADDITION_CONSTANT);
        traces{i}=tempTrace;
        plot(tempTrace,'-g','LineWidth',1)
    end
    
    if minimaInd(length(minimaInd)) + ADDITION_CONSTANT + 1 < length(CurrTrace)
        tempTrace=CurrTrace(minimaInd(length(minimaInd))-SUBTRACTION_CONSTANT:minimaInd(length(minimaInd))+ADDITION_CONSTANT);
        traces{length(minimaInd)}=tempTrace;
        plot(tempTrace,'-g','LineWidth',1)
    end
end

plot(currAvgTrace,'-k','LineWidth', 0.6), hold on


%old isoelectric line
%isoelectricLength = length(currAvgTrace);
%isoelectricY = currAvgTrace(1);

%isoelectric line
isoelectricLength = length(currAvgTrace);
%the isoelectric height should be the point of median height between start
%and Q wave
%creating an ordered list of the y-values at all of these points
heights=[currAvgTrace(1)];
for ii=2:ECGSorted(1,2)-ECGSorted(3,2)
    for index = 1:ECGSorted(1,2)-ECGSorted(3,2)
        if currAvgTrace(ii) < heights(index)
            if index == 1
                heights = [currAvgTrace(ii) heights];
            else
                heights = [heights(1:index-1) currAvgTrace(ii) heights(index:end)];
            end
            break;
        end
        if index == length(heights)
            heights = [heights currAvgTrace(ii)];
            break;
        end
    end
end

isoelectricY = heights(round(length(heights)/2));

plot([1, isoelectricLength], [isoelectricY, isoelectricY], 'cyan', 'LineWidth', 1.0), hold on

% Assign wave markers.

%PPeak
set(handles.Ppeak,'UserData',ECGSorted(1,1));
line1=imline(gca,[ECGSorted(1,1),ECGSorted(1,1)],[0,1]);
setColor(line1,[0.75, 0, 0.75]);
addNewPositionCallback(line1,@(l1) set(handles.Ppeak,'UserData',l1));
child_line=get(line1, 'Children');
set(child_line(1),'MarkerSize',0.05);
set(child_line(2),'MarkerSize',0.05);

%Pmin
set(handles.Pmin,'UserData',ECGSorted(1,1)-ECGSorted(3,1));
line2=imline(gca,[ECGSorted(1,1)-ECGSorted(3,1),ECGSorted(1,1)-ECGSorted(3,1)],[0,1]);
setColor(line2,[0.75, 0, 0.75]);
addNewPositionCallback(line2,@(l2) set(handles.Pmin,'UserData',l2));
child_line=get(line2, 'Children');
set(child_line(1),'MarkerSize',0.05);
set(child_line(2),'MarkerSize',0.05);

%Pmax
set(handles.Pmax,'UserData',ECGSorted(1,1)+ECGSorted(4,1));
line3=imline(gca,[ECGSorted(1,1)+ECGSorted(4,1),ECGSorted(1,1)+ECGSorted(4,1)],[0,1]);
setColor(line3,[0.75, 0, 0.75]);
addNewPositionCallback(line3,@(l3) set(handles.Pmax,'UserData',l3));
child_line=get(line3, 'Children');
set(child_line(1),'MarkerSize',0.05);
set(child_line(2),'MarkerSize',0.05);

%QRSpeak
set(handles.QRSpeak,'UserData',ECGSorted(1,2));
line4=imline(gca,[ECGSorted(1,2),ECGSorted(1,2)],[0,1]);
setColor(line4,[0.9290, 0.6940, 0.1250]);
addNewPositionCallback(line4,@(l4) set(handles.QRSpeak,'UserData',l4));
child_line=get(line4, 'Children');
set(child_line(1),'MarkerSize',0.05);
set(child_line(2),'MarkerSize',0.05);

%QRSmin
set(handles.QRSmin,'UserData',ECGSorted(1,2)-ECGSorted(3,2));
line5=imline(gca,[ECGSorted(1,2)-ECGSorted(3,2),ECGSorted(1,2)-ECGSorted(3,2)],[0,1]);
setColor(line5,[0.9290, 0.6940, 0.1250]);
addNewPositionCallback(line5,@(l5) set(handles.QRSmin,'UserData',l5));
child_line=get(line5, 'Children');
set(child_line(1),'MarkerSize',0.05);
set(child_line(2),'MarkerSize',0.05);

%QRSmax
set(handles.QRSmax,'UserData',ECGSorted(1,2)+ECGSorted(4,2));
line6=imline(gca,[ECGSorted(1,2)+ECGSorted(4,2),ECGSorted(1,2)+ECGSorted(4,2)],[0,1]);
setColor(line6,[0.9290, 0.6940, 0.1250]);
addNewPositionCallback(line6,@(l6) set(handles.QRSmax,'UserData',l6));
child_line=get(line6, 'Children');
set(child_line(1),'MarkerSize',0.05);
set(child_line(2),'MarkerSize',0.05);

%Tpeak
set(handles.Tpeak,'UserData',ECGSorted(1,3));
line7=imline(gca,[ECGSorted(1,3),ECGSorted(1,3)],[0,1]);
setColor(line7,[0.3010, 0.7450, 0.9330]);
addNewPositionCallback(line7,@(l7) set(handles.Tpeak,'UserData',l7));
child_line=get(line7, 'Children');
set(child_line(1),'MarkerSize',0.05);
set(child_line(2),'MarkerSize',0.05);

%Tmin
set(handles.Tmin,'UserData',ECGSorted(1,3)-ECGSorted(3,3));
line8=imline(gca,[ECGSorted(1,3)-ECGSorted(3,3),ECGSorted(1,3)-ECGSorted(3,3)],[0,1]);
setColor(line8,[0.3010, 0.7450, 0.9330]);
addNewPositionCallback(line8,@(l8) set(handles.Tmin,'UserData',l8));
child_line=get(line8, 'Children');
set(child_line(1),'MarkerSize',0.05);
set(child_line(2),'MarkerSize',0.05);

%Tmax
set(handles.Tmax,'UserData',ECGSorted(1,3)+ECGSorted(4,3));
line9=imline(gca,[ECGSorted(1,3)+ECGSorted(4,3),ECGSorted(1,3)+ECGSorted(4,3)],[0,1]);
setColor(line9,[0.3010, 0.7450, 0.9330]);
addNewPositionCallback(line9,@(l9) set(handles.Tmax,'UserData',l9));
child_line=get(line9, 'Children');
set(child_line(1),'MarkerSize',0.05);
set(child_line(2),'MarkerSize',0.05);

fcn2 = makeConstrainToRectFcn('imline',get(gca,'XLim'),get(gca,'YLim'));
setPositionConstraintFcn(line1,fcn2);
setPositionConstraintFcn(line2,fcn2);
setPositionConstraintFcn(line3,fcn2);
setPositionConstraintFcn(line4,fcn2);
setPositionConstraintFcn(line5,fcn2);
setPositionConstraintFcn(line6,fcn2);
setPositionConstraintFcn(line7,fcn2);
setPositionConstraintFcn(line8,fcn2);
setPositionConstraintFcn(line9,fcn2);

hold off

allECGSorted{currfile,ROIcount(currfile,2)}=ECGSorted;
assignin('base','allECGSorted',allECGSorted)

% --- Executes on button press in AddAvgPeaksbutton.
function AddAvgPeaksbutton_Callback(hObject, eventdata, handles)
% hObject    handle to AddAvgPeaksbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%this is really the confirm peaks button; locks the peak selections in
%place and calculates average amplitude of all waves, which are used in the ECG

% Read in base data containing info on where line segments are
ConfirmedPeaks=get(handles.AddAvgPeaksbutton,'UserData');
allAvgTraces=evalin('base','allAvgTraces');
currfile=get(handles.filelist,'Value');
ROIcount=evalin('base','ROIcount');
allECGpk=evalin('base','allECGpk');
allQRSwidth=evalin('base','allQRSwidth');
allPeaks=evalin('base', 'allPeaks');
minVal=evalin('base','minVal');
maxVal=evalin('base', 'maxVal');
currAvgTrace=allAvgTraces{currfile,ROIcount(currfile,2)};

temp=get(handles.Pmin,'UserData');
adjustments(1)=temp(1,1);

temp=get(handles.Ppeak,'UserData');
adjustments(2)=temp(1,1);

temp=get(handles.Pmax,'UserData');
adjustments(3)=temp(1,1);

temp=get(handles.QRSmin,'UserData');
adjustments(4)=temp(1,1);

temp=get(handles.QRSpeak,'UserData');
adjustments(5)=temp(1,1);

temp=get(handles.QRSmax,'UserData');
adjustments(6)=temp(1,1);

temp=get(handles.Tmin,'UserData');
adjustments(7)=temp(1,1);

temp=get(handles.Tpeak,'UserData');
adjustments(8)=temp(1,1);

temp=get(handles.Tmax,'UserData');
adjustments(9)=temp(1,1);

adjustments=sort(adjustments);

ConfirmedPeaks{currfile,ROIcount(currfile,2)}=adjustments;

axes(handles.AverageAxes)
grid(handles.AverageAxes,'on')
set(handles.AverageAxes,'FontSize',8)

hold on
for jj=1:9
    plot([adjustments(jj),adjustments(jj)],[0,1],'r-', 'LineWidth', 1.2), hold on
end

%rewritten here since Q loc may have been adjusted by user
%isoelectric line
isoelectricLength = length(currAvgTrace);
%the isoelectric height should be the point of median height between start
%and Q wave
%creating an ordered list of the y-values at all of these points
heights=[currAvgTrace(1)];
for ii=2:adjustments(4)
    for index = 1:adjustments(4)
        if currAvgTrace(ii) < heights(index)
            if index == 1
                heights = [currAvgTrace(ii) heights];
            else
                heights = [heights(1:index-1) currAvgTrace(ii) heights(index:end)];
            end
            break;
        end
        if index == length(heights)
            heights = [heights currAvgTrace(ii)];
            break;
        end
    end
end

isoelectricY = heights(round(length(heights)/2));

plot([1, isoelectricLength], [isoelectricY, isoelectricY], 'cyan', 'LineWidth', 1.0), hold on

set(handles.AddAvgPeaksbutton,'UserData',ConfirmedPeaks)

%setting amplitudes for the analyze ECGs step
untransform_isoelectric=((isoelectricY*(maxVal - minVal))+maxVal);
pAvgTraceAmplitude=(((currAvgTrace(round(adjustments(2)))*(maxVal - minVal))+maxVal) - untransform_isoelectric)*1000;
qAmplitude=(((currAvgTrace(round(adjustments(4)))*(maxVal - minVal))+maxVal) - untransform_isoelectric)*1000;
rAmplitude=(((currAvgTrace(round(adjustments(5)))*(maxVal - minVal))+maxVal) - untransform_isoelectric)*1000;
sAmplitude=(((currAvgTrace(round(adjustments(6)))*(maxVal - minVal))+maxVal) - untransform_isoelectric)*1000;
tAmplitude=(((currAvgTrace(round(adjustments(8)))*(maxVal - minVal))+maxVal) - untransform_isoelectric)*1000;

% Check if all peaks have been analyzed
tstAllAvgPeaks=get(handles.AddAvgPeaksbutton,'UserData');
s=size(tstAllAvgPeaks,1);

if s>=ROIcount(currfile,2)
    %for ii=1:ROIcount(currfile,1)
    %if tstAllAvgPeaks{currfile,ii}
    %check(ii)=1;
    check=1;
else
    %check(ii)=0;
    check=0;
    %end
end

%if sum(check)==ROIcount(currfile,1)
if check==ROIcount(currfile,2)
    set(handles.AnalyzeECGbutton,'Visible','On');
end

assignin('base', 'pAvgTraceAmplitude', pAvgTraceAmplitude) %based off of average trace
assignin('base','qAmplitude',qAmplitude)
assignin('base','rAmplitude',rAmplitude) %based off of average trace
assignin('base','sAmplitude',sAmplitude)
assignin('base','tAmplitude',tAmplitude)
assignin('base','isoelectricLength', isoelectricLength)
assignin('base','isoelectricY', isoelectricY)


%% Function to analyze ECG
% --- Executes on button press in AnalyzeECGbutton.
function AnalyzeECGbutton_Callback(hObject, eventdata, handles)
% hObject    handle to AnalyzeECGbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%outputs a file and table with all relevant data
%the button appears once average peaks are confirmed

allAvgTraces=evalin('base','allAvgTraces');
currfile=get(handles.filelist,'Value');
ROIcount=evalin('base','ROIcount');
allECGpk=evalin('base','allECGpk');
allPeaks=evalin('base','allPeaks');
ConfirmedPeaks=get(handles.AddAvgPeaksbutton,'UserData');
AllsubData=evalin('base','AllsubData');
allQRSwidth=evalin('base','allQRSwidth');
currentfile=evalin('base','currentfile');
numCols=ceil(ROIcount(currfile,1)^(1/2));
ch=evalin('base','ch');
bl=evalin('base','bl');
samplerate=evalin('base','samplerate');
savepathname=evalin('base','savepathname');
SUBTRACTION_CONSTANT = evalin('base','SUBTRACTION_CONSTANT');
ADDITION_CONSTANT = evalin('base','ADDITION_CONSTANT');
plotAvg = evalin('base', 'calculateAvgButtonPressed');
plotMinima = evalin('base', 'minimaAvgButtonPressed');
%qrsAmplitude = evalin('base','qrsAmplitude'); %based off of averaging individual QRS peak amplitudes
%pAmplitude = evalin('base','pAmplitude'); %based off of averaging individual P peak amplitudes
pAvgTraceAmplitude = evalin('base','pAvgTraceAmplitude'); %based off of average trace P peak amplitude
qAmplitude = evalin('base','qAmplitude');
rAmplitude = evalin('base','rAmplitude'); %based off of average trace QRS peak amplitude
sAmplitude = evalin('base','sAmplitude');
tAmplitude = evalin('base','tAmplitude');
isoelectricLength = evalin('base','isoelectricLength');
isoelectricY = evalin('base','isoelectricY');


% Average trace with peak markers - by segments
figure(1)
FigName = ['Average Trace with Markers For ' currentfile ];
set(gcf,'Name',FigName);
for r=1:ROIcount(currfile,2)   
    avgTrace=allAvgTraces{currfile,r};
    %     QRSwidth=allQRSwidth{currfile,r};
    plot(avgTrace,'k-','LineWidth',0.6), hold on
    plot([1, isoelectricLength ], [isoelectricY, isoelectricY], 'cyan', 'LineWidth', 1.0), hold on
    userLines=ConfirmedPeaks{currfile,r};
    for jj=1:9
        plot([userLines(jj),userLines(jj)],[0,1],'r-', 'LineWidth', 0.6), hold on
    end
    
    set(gca,'YTick',[]);
    
    trNum(r)=r;
    nTraces(r)=length(allPeaks{currfile,r,2});
    PRint(r)=(userLines(4)-userLines(1))/2;
    QRSint(r)=(userLines(6)-userLines(4))/2;
    QTint(r)=(userLines(9)-userLines(4))/2;
end
%assignin('base','QTint',QTint);
segmentPeaks_fname = regexprep(currentfile, ".mat", "_Figure1");
saveas(gcf,fullfile(savepathname, segmentPeaks_fname),'tiff')
close

% Compiled average trace of all segments
figure(2)
FigName = ['Combined Trace For ' currentfile ];
set(gcf,'Name',FigName);
Alltraces=AllsubData{1,currfile};

%Create table required for heart rate calculation
rr_hr_table=zeros(2,ROIcount(currfile,1));

for nROI=1:ROIcount(currfile,2)
    
    CurrTrace=AllsubData{1,currfile}{1,nROI};
    pInd=allPeaks{currfile,nROI,1};
    qInd=allPeaks{currfile,nROI,2};
    minimaInd=allPeaks{currfile,nROI,9};
    % currPeaks
    
    if plotAvg == true
        % Line up traces
        if qInd(1)<SUBTRACTION_CONSTANT+1
            pInd(1)=[];
            qInd(1)=[];
        end
        
        traces{nROI,1}=CurrTrace(qInd(1)-SUBTRACTION_CONSTANT:qInd(1)+ADDITION_CONSTANT);
        plot(traces{nROI,1},'-g','LineWidth',1), hold on
        for i=2:length(qInd)-1
            tempTrace=CurrTrace(qInd(i)-SUBTRACTION_CONSTANT:qInd(i)+ADDITION_CONSTANT);
            traces{nROI,i}=tempTrace;
            plot(tempTrace,'-g','LineWidth',1)
            %plot(norm_data(pl(pInd(i))-50:pl(pInd(i+1))-50))
        end
        if qInd(length(qInd)) + ADDITION_CONSTANT + 1 < length(CurrTrace)
            tempTrace=CurrTrace(qInd(length(qInd))-SUBTRACTION_CONSTANT:qInd(length(qInd))+ADDITION_CONSTANT);
            traces{nROI, length(qInd)}=tempTrace;
            plot(tempTrace,'-g','LineWidth',1)
        end
    end
    
    if plotMinima == true
        % Line up traces
        if minimaInd(1)<SUBTRACTION_CONSTANT+1
            minimaInd(1) = [];
        end
        
        traces{nROI,1}=CurrTrace(minimaInd(1)-SUBTRACTION_CONSTANT:minimaInd(1)+ADDITION_CONSTANT);
        plot(traces{nROI,1},'-g','LineWidth',1), hold on
        for i=2:length(minimaInd)-1
            tempTrace=CurrTrace(minimaInd(i)-SUBTRACTION_CONSTANT:minimaInd(i)+ADDITION_CONSTANT);
            traces{nROI,i}=tempTrace;
            plot(tempTrace,'-g','LineWidth',1)
            %plot(norm_data(pl(pInd(i))-50:pl(pInd(i+1))-50))
        end
        
        if minimaInd(length(minimaInd)) + ADDITION_CONSTANT + 1 < length(CurrTrace)
            tempTrace=CurrTrace(minimaInd(length(minimaInd))-SUBTRACTION_CONSTANT:minimaInd(length(minimaInd))+ADDITION_CONSTANT);
            traces{nROI, length(minimaInd)}=tempTrace;
            plot(tempTrace,'-g','LineWidth',1)
        end
    end
    
    set(gca,'YTick',[]);   
    if plotAvg
        % Heart rate calculation
        qInd_new=qInd/(samplerate(ch,bl));
        %pl=AllsubData{1,currfile}{1,ROIcount(currfile,2)};
        %for gg=1:ROIcount(currfile,1)
        %rwave_num = numel(qInd_new);
        rr_table=zeros(length(qInd_new)-1, 1);
        for tt=1:length(qInd_new)-1
            %need to define pl - data
            %single_rr=(pl(qInd(tt+1))-pl(qInd(tt)))*1000;
            single_rr=(qInd_new(tt+1)-qInd_new(tt))*1000;
            rr_table(tt,:)=single_rr;
        end
        avg_RR=(mean(rr_table));
        heartrate_segment=(60/avg_RR)*1000;
        rr_hr_table(1,nROI)=avg_RR;
        rr_hr_table(2,nROI)=heartrate_segment;
        %end
        RRint=rr_hr_table(1,:);
        HR=rr_hr_table(2,:);
        %assignin('base','rr_hr_table',rr_hr_table);
    end
    
    if plotMinima
        % Heart rate calculation
        minimaInd_new=minimaInd/(samplerate(ch,bl));
        %pl=AllsubData{1,currfile}{1,ROIcount(currfile,2)};
        %for gg=1:ROIcount(currfile,1)
        %rwave_num = numel(qInd_new);
        rr_table=zeros(length(minimaInd_new)-1, 1);
        for tt=1:length(minimaInd_new)-1
            %need to define pl - data
            %single_rr=(pl(qInd(tt+1))-pl(qInd(tt)))*1000;
            single_rr=(minimaInd_new(tt+1)-minimaInd_new(tt))*1000;
            rr_table(tt,:)=single_rr;
        end
        avg_RR=(mean(rr_table));
        heartrate_segment=(60/avg_RR)*1000;
        rr_hr_table(1,nROI)=avg_RR;
        rr_hr_table(2,nROI)=heartrate_segment;
        %end
        RRint=rr_hr_table(1,:);
        HR=rr_hr_table(2,:);
        %assignin('base','rr_hr_table',rr_hr_table);
    end
    
end

[a,b]=size(traces);
for i=1:a
    for j=1:b
        sz(i,j)=length(traces{i,j});
    end
end

% Calculate average trace
for k=1:max(sz(sz>0))
    SumTrace(k)=0;
    ct(k)=0;
    for i=1:a
        for j=1:b
            if length(traces{i,j})>k
                SumTrace(k)=SumTrace(k)+traces{i,j}(k);
                ct(k)=ct(k)+1;
            end
        end
    end
end

allAvg=SumTrace./ct;
plot(allAvg,'k-', 'LineWidth', 0.6); hold on
plot([1, isoelectricLength ], [isoelectricY, isoelectricY], 'cyan', 'LineWidth', 1.0); hold on
combinedAvgTrace_fname = regexprep(currentfile, ".mat", "_Figure2");
saveas(gcf,fullfile(savepathname, combinedAvgTrace_fname),'tiff')
close

%Like Figure 2 but with no red lines
figure(4)
FigName = ['Combined Trace For ' currentfile ];
set(gcf,'Name',FigName);
for nROI=1:ROIcount(currfile,2)
    
    CurrTrace=AllsubData{1,currfile}{1,nROI};
    pInd=allPeaks{currfile,nROI,1};
    qInd=allPeaks{currfile,nROI,2};
    minimaInd=allPeaks{currfile,nROI,9};
    % currPeaks
    
    if plotAvg == true
        % Line up traces
        if qInd(1)<SUBTRACTION_CONSTANT+1
            pInd(1)=[];
            qInd(1)=[];
        end
        
        traces{nROI,1}=CurrTrace(qInd(1)-SUBTRACTION_CONSTANT:qInd(1)+ADDITION_CONSTANT);
        plot(traces{nROI,1},'-g','LineWidth',1), hold on
        for i=2:length(qInd)-1
            tempTrace=CurrTrace(qInd(i)-SUBTRACTION_CONSTANT:qInd(i)+ADDITION_CONSTANT);
            traces{nROI,i}=tempTrace;
            plot(tempTrace,'-g','LineWidth',1)
            %plot(norm_data(pl(pInd(i))-50:pl(pInd(i+1))-50))
        end
        if qInd(length(qInd)) + ADDITION_CONSTANT + 1 < length(CurrTrace)
            tempTrace=CurrTrace(qInd(length(qInd))-SUBTRACTION_CONSTANT:qInd(length(qInd))+ADDITION_CONSTANT);
            traces{nROI, length(qInd)}=tempTrace;
            plot(tempTrace,'-g','LineWidth',1)
        end
    end
    
    if plotMinima == true
        % Line up traces
        if minimaInd(1)<SUBTRACTION_CONSTANT+1
            minimaInd(1) = [];
        end
        
        traces{nROI,1}=CurrTrace(minimaInd(1)-SUBTRACTION_CONSTANT:minimaInd(1)+ADDITION_CONSTANT);
        plot(traces{nROI,1},'-g','LineWidth',1), hold on
        for i=2:length(minimaInd)-1
            tempTrace=CurrTrace(minimaInd(i)-SUBTRACTION_CONSTANT:minimaInd(i)+ADDITION_CONSTANT);
            traces{nROI,i}=tempTrace;
            plot(tempTrace,'-g','LineWidth',1)
            %plot(norm_data(pl(pInd(i))-50:pl(pInd(i+1))-50))
        end
        
        if minimaInd(length(minimaInd)) + ADDITION_CONSTANT + 1 < length(CurrTrace)
            tempTrace=CurrTrace(minimaInd(length(minimaInd))-SUBTRACTION_CONSTANT:minimaInd(length(minimaInd))+ADDITION_CONSTANT);
            traces{nROI, length(minimaInd)}=tempTrace;
            plot(tempTrace,'-g','LineWidth',1)
        end
    end
    
    set(gca,'YTick',[]);
end
plot(allAvg,'k-', 'LineWidth', 0.6); hold on
plot([1, isoelectricLength ], [isoelectricY, isoelectricY], 'cyan', 'LineWidth', 1.0); hold on
for jj=1:9
    plot([userLines(jj),userLines(jj)],[0,1],'r-', 'LineWidth', 0.6), hold on
end
combinedAvgTrace_nored_fname = regexprep(currentfile, ".mat", "_Figure4");
saveas(gcf,fullfile(savepathname, combinedAvgTrace_nored_fname),'tiff')
close

%Peak analysis figure
fulltrace_fname = regexprep(currentfile, ".mat", "_Figure3.tiff");
F = getframe(handles.ROIaxes);
Image = frame2im(F);
imwrite(Image, fullfile(savepathname, fulltrace_fname), 'tiff')

% Make data table
datetime_unformatted=now;
datetime_final=datestr(datetime_unformatted, 'mm-dd-YYYY HH:MM');
allData=[nTraces; RRint; HR; PRint; QRSint; QTint; pAvgTraceAmplitude; qAmplitude; rAmplitude; sAmplitude; tAmplitude]';
columnname={'Number of Traces','RR Interval (ms)','Heart Rate (bpm)','PR Interval (ms)','QRS Interval (ms)','QT Interval (ms)', 'P Amplitude (mV)', 'Q Amplitude (mV)', 'R Amplitude (mV)', 'S Amplitude (mV)', 'T Amplitude (mV)'};
assignin('base','allData',allData);

% Write out .txt file
finalRow=[string(currentfile) string(datetime_final) mean(allData(:,1)) mean(allData(:,2)) mean(allData(:,3)) mean(allData(:,4)) mean(allData(:,5)) mean(allData(:,6)) mean(allData(:,7)) mean(allData(:,8)) mean(allData(:,9)) mean(allData(:,10)) mean(allData(:,11))];
writeout_product = array2table(finalRow);
writeout_product.Properties.VariableNames={'File' 'Date' 'nTraces' 'RR(ms)' 'HeartRate(bpm)' 'PR(ms)' 'QRS(ms)' 'QT(ms)' 'PAmplitude(mV)' 'QAmplitude(mV)' 'RAmplitude(mV)' 'SAmplitude(mV)' 'TAmplitude(mV)'};
results_fname = regexprep(currentfile, ".mat", "_Results.txt");
writetable(writeout_product, fullfile(savepathname,results_fname), 'Delimiter',' ');

% GUI table settings
t = uitable('Units','normalized','Position',...
    [0.004036458333333,0.04899894625922,0.765171874999998,0.054889357218125], 'Data', allData,...
    'ColumnName', columnname,...
    'RowName',[],'ColumnWidth',{110,100,110,100,100,100,110,110,110,110,116});

%% Ease of use functions

% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in ChangeSaveDir.
function ChangeSaveDir_Callback(hObject, eventdata, handles)
% hObject    handle to ChangeSaveDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ChangeSaveDir
savepathname=uigetdir();
assignin('base','savepathname',savepathname);

% --- Executes on button press in Restart.
function Restart_Callback(hObject, eventdata, handles)
% hObject    handle to Restart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
OrigDlgH = ancestor(hObject, 'figure');
delete(OrigDlgH);
script_name=evalin('base','script_name');
eval(script_name);

function changepeakdist_Callback(hObject, eventdata, handles)
% hObject    handle to changepeakdist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of changepeakdist as text
%        str2double(get(hObject,'String')) returns contents of changepeakdist as a double

% --- Executes during object creation, after setting all properties.
function changepeakdist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to changepeakdist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes when selected object is changed in PopUpFrequency.
function PopUpFrequency_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in PopUpFrequency 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%assign PopUpFrequency a value based on what the user wants

switch(get(eventdata.NewValue, 'Tag'))
    case 'NoPopUps'
        a=0;
    case 'StandardPopUps'
        a=1;
    case 'HighPopUps'
        a=2;
end
assignin('base', 'PopUpFrequencyValue', a);

function StandardPopUpOrDisp(instruction, PopUpFreq)
%pops up the instruction if PopUpFreq is standard or high, displays from
%console otherwise

if PopUpFreq > 0
    uiwait(msgbox(instruction));
else
    disp(instruction)
end

function HighPopUpOrDisp(instruction, PopUpFreq)

if PopUpFreq > 1
    uiwait(msgbox(instruction));
else
    disp(instruction)
end

return;

%% Deprecated functions
% Functions that are not currently in use

% --- Executes on button press in saveFullTrace.
function saveFullTrace_Callback(hObject, eventdata, handles)
% hObject    handle to saveFullTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currentfile=evalin('base','currentfile');
savepathname=evalin('base','savepathname');
fulltrace_fname = regexprep(currentfile, ".mat", "_Figure3.tiff");
F = getframe(handles.ROIaxes);
Image = frame2im(F);
imwrite(Image, fullfile(savepathname, fulltrace_fname), 'tiff')
g = msgbox('Image saved');

% --- Executes on button press in saveAvgTraceLines.
function saveAvgTraceLines_Callback(hObject, eventdata, handles)
% hObject    handle to saveAvgTraceLines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

currentfile=evalin('base','currentfile');
savepathname=evalin('base','savepathname');
fulltrace_fname = regexprep(currentfile, ".mat", "_Figure4.tiff");
F = getframe(handles.AverageAxes);
Image = frame2im(F);
imwrite(Image, fullfile(savepathname, fulltrace_fname), 'tiff')
g = msgbox('Image saved');

% --- Executes on button press in AddArrhythmia.
function AddArrhythmia_Callback(hObject, eventdata, handles)
% hObject    handle to DeletePeaksButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%If peaks boxed: does nothing, may cause an error- incompatible
%If points selected: adds arrythmia markers (green) to the nearest peaks

selectedPoints=get(handles.SelectPeakButton,'UserData');
AllsubData=evalin('base','AllsubData');
currfile=get(handles.filelist,'Value');
ROIcount=evalin('base','ROIcount');
allPeaks=evalin('base','allPeaks');
pPeakYs = allPeaks{currfile,ROIcount(currfile,2),3};
qPeakYs = allPeaks{currfile,ROIcount(currfile,2),4};
pPeaks=allPeaks{currfile,ROIcount(currfile,2),1};
qPeaks=allPeaks{currfile,ROIcount(currfile,2),2};
arrs = allPeaks{currfile,ROIcount(currfile,2),7};
arrYs = allPeaks{currfile,ROIcount(currfile,2),8};

% Find which peak points are closest to

%Note: not added in order
for ii=1:size(selectedPoints)
    [selectedpPeak,selectedpLoc]=min((pPeaks-selectedPoints(ii, 1)).^2 + (YAxisMultiplier(handles)*(pPeakYs - selectedPoints(ii, 2))).^2);
    [selectedqPeak,selectedqLoc]=min((qPeaks-selectedPoints(ii, 1)).^2 + (YAxisMultiplier(handles)*(qPeakYs - selectedPoints(ii, 2))).^2);
    if selectedpPeak<selectedqPeak
        arrs = [arrs pPeaks(selectedpLoc)];
        arrYs = [arrYs pPeakYs(selectedpLoc)];
    else
        arrs = [arrs qPeaks(selectedqLoc)];
        arrYs = [arrYs qPeakYs(selectedqLoc)];
    end
end

allPeaks{currfile,ROIcount(currfile,2),7} = arrs;
allPeaks{currfile,ROIcount(currfile,2),8} = arrYs;
assignin('base','allPeaks',allPeaks)
storageX = handles.ROIaxes.XLim;
storageY = handles.ROIaxes.YLim;
%Plot updated peaks
axes(handles.ROIaxes), cla
tempData=AllsubData{1,currfile}{1,ROIcount(currfile,2)};
plot(tempData);
xlim(storageX);
ylim(storageY);
hold on
PlotAllRelevantPoints(allPeaks, currfile, ROIcount, tempData), hold off
clear tempData
set(handles.SelectPeakButton,'UserData',[]);

% --- Executes on button press in DeleteArrhythmia.
function DeleteArrhythmia_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteArrhythmia (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%If peaks boxed: deletes arrythmia markers on all peaks in box
%If points selected: deletes arrythmia markers on the nearest peaks

selectedArrythmias = evalin('base', 'selectedArrythmias');
selectedPoints=[get(handles.SelectPeakButton,'UserData') selectedArrythmias];
AllsubData=evalin('base','AllsubData');
currfile=get(handles.filelist,'Value');
ROIcount=evalin('base','ROIcount');
allPeaks=evalin('base','allPeaks');

peaks=allPeaks{currfile,ROIcount(currfile,2),7};
peakYs = allPeaks{currfile,ROIcount(currfile,2),8};

% Find which peaks points are closest to

for ii=1:size(selectedPoints)
    [selectedPeak,selectedLoc]=min((peaks-selectedPoints(ii, 1)).^2 + (YAxisMultiplier(handles)*(peakYs - selectedPoints(ii, 2))).^2);
    peaks(selectedLoc)=[];
    peakYs(selectedLoc)=[];
end

allPeaks{currfile,ROIcount(currfile,2),7} = peaks;
allPeaks{currfile,ROIcount(currfile,2),8} = peakYs;
assignin('base','allPeaks',allPeaks)
storageX = handles.ROIaxes.XLim;
storageY = handles.ROIaxes.YLim;
%Plot updated peaks
axes(handles.ROIaxes), cla
tempData=AllsubData{1,currfile}{1,ROIcount(currfile,2)};
plot(tempData),
xlim(storageX);
ylim(storageY);
hold on
PlotAllRelevantPoints(allPeaks, currfile, ROIcount, tempData), hold off
clear tempData
set(handles.SelectPeakButton,'UserData',[]);
set(handles.BoxPeaksButton,'UserData',[]);
assignin('base','selectedYellow',[]);
assignin('base','selectedArrythmias',[]);
assignin('base','selectedMinima',[]);

% --- Executes on button press in AddPeaksButton.
function AddPeaksButton_Callback(hObject, eventdata, handles)
% hObject    handle to AddPeaksButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%If peaks boxed: does nothing, may cause an error- incompatible
%If points selected: adds a peak to the highest point within 50 (current setting of X_AXIS_CLICK_RANGE)
%along the x-axis, with coloring determined by the same algorithm used in
%find peaks

%Note: use of this button is not recommended; better off using the Add P or
%QRS Peaks buttons

selectedPoints=get(handles.SelectPeakButton,'UserData');
sz=size(selectedPoints);
AllsubData=evalin('base','AllsubData');
currfile=get(handles.filelist,'Value');
ROIcount=evalin('base','ROIcount');
allPeaks=evalin('base','allPeaks');

tempData=AllsubData{1,currfile}{1,ROIcount(currfile,2)};

pPeaks=allPeaks{currfile,ROIcount(currfile,2),1};
qPeaks=allPeaks{currfile,ROIcount(currfile,2),2};
pPeakYs=allPeaks{currfile,ROIcount(currfile,2),3};
qPeakYs=allPeaks{currfile,ROIcount(currfile,2),4};

X_AXIS_CLICK_RANGE = 50;
Y_AXIS_CLICK_RANGE = 0.05; %ensures that peak is not added significantly higher than the
%point selected

% Find which data point selected peak is closest to
for ii=1:sz(1)
    addedPeaks(ii)=round(selectedPoints(ii,1));
    valaddedPeaks(ii)=selectedPoints(ii,2);
    %jj=addedPeaks(ii)-X_AXIS_CLICK_RANGE:1:addedPeaks(ii)+X_AXIS_CLICK_RANGE;
    %[pa,optimalLoc]=max(tempData(jj));
    optimalLoc = 0;
    currMax = 0;
    for jj =addedPeaks(ii)-X_AXIS_CLICK_RANGE:1:addedPeaks(ii)+X_AXIS_CLICK_RANGE
        if(tempData(jj) < Y_AXIS_CLICK_RANGE + selectedPoints(ii, 2) && currMax < tempData(jj))
            currMax = tempData(jj);
            optimalLoc = jj;
        end
    end
    addedPeaks(ii)= optimalLoc;  %took out + addedPeaks(ii) - 11
end

pqPeaks=[pPeaks,qPeaks,addedPeaks];
pqPeaks=sort(pqPeaks);

dist1=pqPeaks(2)-pqPeaks(1);
dist2=pqPeaks(3)-pqPeaks(2);

%nextIsP = false;
pToQGap = 0;
qToPGap = 0;
CONSTANT = 2;
if dist1<dist2
    %pInd=[1];
    %qInd=[2];
    pToQGap = dist1;
    qToPGap = dist2;
    %nextIsP = true;
else
    %pInd=[2];
    %qInd=[1];
    pToQGap = dist2;
    qToPGap = dist1;
end
%Figuring out whether added peaks are red or black
addedIsPpeak = true;
for ii = 1:sz(1)
    for index=1:length(pqPeaks)
        if abs(pqPeaks(index) - addedPeaks(ii)) < pToQGap * CONSTANT && pqPeaks(index) - addedPeaks(ii) < 0
            addedIsPpeak = false;
            break
        end
    end
    if(addedIsPpeak == true)
        %adding the peak in order
        for index = 1:length(pPeaks)
            if pPeaks(index) > addedPeaks(ii)
                if index == 1
                    pPeaks = [addedPeaks(ii) pPeaks];
                    pPeakYs = [tempData(addedPeaks(ii)) pPeakYs];
                else
                    pPeaks = [pPeaks(1:index-1) addedPeaks(ii) pPeaks(index:end)];
                    pPeakYs = [pPeakYs(1:index-1) tempData(addedPeaks(ii)) pPeakYs(index:end)];
                end
                break;
            end
            if index == length(pPeaks)
                pPeaks = [pPeaks addedPeaks(ii)];
                pPeakYs = [pPeakYs tempData(addedPeaks(ii))];
            end
        end
    else
        %adding the peak in order
        for index = 1:length(qPeaks)
            if qPeaks(index) > addedPeaks(ii)
                if index == 1
                    qPeaks = [addedPeaks(ii) qPeaks];
                    qPeakYs = [tempData(addedPeaks(ii)) qPeakYs];
                else
                    qPeaks = [qPeaks(1:index-1) addedPeaks(ii) qPeaks(index:end)];
                    qPeakYs = [qPeakYs(1:index-1) tempData(addedPeaks(ii)) qPeakYs(index:end)];
                end
                break;
            end
        end
    end
end

allPeaks{currfile,ROIcount(currfile,2),1} = pPeaks;
allPeaks{currfile,ROIcount(currfile,2),2} = qPeaks;
allPeaks{currfile,ROIcount(currfile,2),3} = pPeakYs;
allPeaks{currfile,ROIcount(currfile,2),4} = qPeakYs;
assignin('base','allPeaks',allPeaks)

storageX = handles.ROIaxes.XLim;
storageY = handles.ROIaxes.YLim;
%Plot updated peaks
axes(handles.ROIaxes), cla
plot(tempData),
xlim(storageX);
ylim(storageY);
hold on
PlotAllRelevantPoints(allPeaks, currfile, ROIcount, tempData), hold off
clear tempData
set(handles.SelectPeakButton,'UserData',[]);

function EstablishCheckpoint(pInd, pIndYs, qInd, qIndYs, problemInd, problemIndYs, unusedPeakXs, unusedPeakYs, currRRGap, currPQRSGap, prevPInd, prevPIndYs, prevQInd, prevQIndYs, prevProblemInd, prevProblemIndYs, prevUnusedPeakXs, prevUnusedPeakYs, prevRRGap)
%adjusts the prev values at a new checkpoint, definition tbd in a future
%version

% Note: this is designed poorly for value retention; need to be designed
% more like YAxisMultiplier; see https://www.mathworks.com/matlabcentral/answers/272876-how-to-make-return-value-in-for-loop

prevPInd = pInd;
prevPIndYs = pIndYs;
prevQInd = qInd;
prevQIndYs = qIndYs;
prevProblemInd = problemInd;
prevProblemIndYs = problemIndYs;
prevUnusedPeakXs = unusedPeakXs;
prevUnusedPeakYs = unusedPeakYs;
prevRRGap = currRRGap;
prevPQRSGap = currPQRSGap;

function UndoPrevStep(pInd, pIndYs, qInd, qIndYs, problemInd, problemIndYs, unusedPeakXs, unusedPeakYs, currRRGap, currPQRSGap, prevPInd, prevPIndYs, prevQInd, prevQIndYs, prevProblemInd, prevProblemIndYs, prevUnusedPeakXs, prevUnusedPeakYs, prevRRGap, TempData)
%undoes the previous step by reseting these values to what they were before
%the last user selection, and then replotting


% Note: this is designed poorly for value retention; need to be designed
% more like YAxisMultiplier; see https://www.mathworks.com/matlabcentral/answers/272876-how-to-make-return-value-in-for-loop

pInd = prevPInd;
pIndYs = prevPIndYs;
qInd = prevQInd;
qIndYs = prevQIndYs;
problemInd = prevProblemInd;
problemIndYs = prevProblemIndYs;
unusedPeakXs = prevUnusedPeakXs;
unusedPeakYs = prevUnusedPeakYs;
currRRGap = prevRRGap;
currPQRSGap = prevPQRSGap;

axes(handles.ROIaxes), cla, plot(TempData), hold on
plot(unusedPeakXs,unusedPeakYs,'c*','MarkerSize',10), hold on
plot(pInd,pIndYs,'r*','MarkerSize',10)
plot(qInd,qIndYs,'k*','MarkerSize',10)
plot(problemInd,problemIndYs,'y*','MarkerSize',7)

% --- Executes on button press in UndoStepButton.
function UndoStepButton_Callback(hObject, eventdata, handles)
% hObject    handle to UndoStepButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Undoes up to the previous checkpoint in the noise remover


% Note: this is designed poorly for value retention; need to be designed
% more like YAxisMultiplier; see https://www.mathworks.com/matlabcentral/answers/272876-how-to-make-return-value-in-for-loop


assignin('base', 'undoPressed', true);

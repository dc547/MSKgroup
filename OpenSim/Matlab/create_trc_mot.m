function data = create_trc_mot(file)

% This function will create the appropriate files to run an OpenSim
% simulation sequence for rugby scrum data
% Input - file - c3d file to process
% Originally written by Dario Cazzola 

% First, import the classes from the jar file so that these can be called
% directly
import org.opensim.modeling.*

%% Define path 
global subdir_current;
global trialdir_current;


if nargin < 1
    [fname, pname] = uigetfile('*.c3d', 'Select C3D file');
else
    if isempty(fileparts(file))
        pname = cd;
        pname = [pname '\'];
        fname = file;
    else [pname, name, ext] = fileparts(file);
        fname = [name ext];
    end
end

cd(pname);

%% Load the c3dfile

% load the c3d file using BTK
data = btk_loadc3d([pname, fname], 5);

%% Naming in case of Static cal files
if ~isempty(strfind(lower(fname),'cal'))
    data.sub_info.Name = fname(1:end-14);
    data.Name = fname(1:end-14);
else
    data.sub_info.Name = fname(7:end-4);
    data.Name = fname(7:end-4);
end

%% BTK uses First/Last so convert to fit existing routine so Start/End
data.marker_data.Last_Frame = data.marker_data.Last_Frame - data.marker_data.First_Frame;
data.marker_data.First_Frame = 1;

data.Start_Frame = data.marker_data.First_Frame;
data.End_Frame = data.marker_data.Last_Frame;

if ~isempty(strfind(lower(fname),'cal'))
     
    marker_names = {'MM_R';'MM_L';'LM_R';'LM_L';... %Ankle
        '1M_R';'5M_R';'1M_L';'5M_L';'HEE_R';'HEE_L' ;... % Foot
        'MC_R';'MC_L';'LC_R';'LC_L';... % Knee
        'PSIS_R';'PSIS_L';'ASIS_R';'ASIS_L';'GT_R';'GT_L';... % Hip
        'ACR_R';'ACR_L';... % Shoulder
        'S1_L'; 'S2_L';'S3_L'; 'S4_L'; 'T1_L';'T2_L';'T3_L';'T4_L';...% Left Leg
        'S1_R'; 'S2_R';'S3_R'; 'S4_R'; 'T1_R';'T2_R';'T3_R';'T4_R'};
else
    
    marker_names = {'MM_R';'MM_L';'LM_R';'LM_L';... %Ankle
        '1M_R';'5M_R';'1M_L';'5M_L';'HEE_R';'HEE_L' ;... % Foot
        'MC_R';'MC_L';'LC_R';'LC_L';... % Knee
        'PSIS_R';'PSIS_L';'ASIS_R';'ASIS_L';'GT_R';'GT_L';... % Hip
        'ACR_R';'ACR_L';... % Shoulder
        'S1_L'; 'S2_L'; 'S3_L'; 'S4_L'; 'T1_L';'T2_L';'T3_L';'T4_L' ;...% Left Leg
        'S1_R'; 'S2_R'; 'S3_R'; 'S4_R'; 'T1_R';'T2_R';'T3_R';'T4_R'};
end



data.marker_data = btk_sortc3d(data.marker_data,marker_names); % creates .trc file


if isempty(strfind(lower(fname),'cal'))
    %% DEFINE EVENTS E1 E2 E3 E4
% % %     
% % %     E(1) = 5; %the time of "set" call
% % %     
% % %     E(2) = E(1)-0.8; %Start just before set call
% % %     
% % %     E(3) = E(1)+1.2; % Change 2.00 if you want a longer trial
% % %     
% % %     %% Define start and end frames
% % %     % Define start and end frame from the events to write the appropriate TRC
% % %     % and MOT files for the OpenSim simulations
% % %     
% % %     data.Start_Frame = round(E(2)/(1/data.marker_data.Info.frequency));
% % %     data.End_Frame = round(E(3)/(1/data.marker_data.Info.frequency));

    
    %% C3D TO TRC and MOT
    %'v5' of this script is modified from previous ones since person is now
    %walking in the 'forward' direction of the treadmill (towards the wall) and
    %so coordinate system transformations have changed.
    
    data = btk_c3d2trc_v5(data,'off'); 
    
else
    %% Scaling process for the static trial
    
    data = btk_c3d2trc_v5(data, 'off');
    


    
end




clear;clc;

%% Read in files
% Pulls in file names from the folder path and adds them to the working
% directory of the script (read / write access)
format short g ; format compact 
folder_path = "/Users/nbonnie/MATLAB/stereo-calibration-free-firefly";
addpath(genpath(folder_path))
addpath(genpath(strcat(folder_path,"/control")))
fnames = dir(strcat(folder_path,"/control/*.mat"));


%% Loads in corresponding data, extracts information needed
data1 = load(strcat(folder_path, "/control/", fnames(1).name));
data2 = load(strcat(folder_path, "/control/", fnames(2).name));
fns1 = fieldnames(data1);
fns2 = fieldnames(data2);

df1 = data1.(fns1{1}).xyt;
df2 = data2.(fns2{1}).xyt;
c1n = data1.(fns1{1}).n;
c2n = data2.(fns2{1}).n;

frame_width = data1.(fns1{1}).mov.Width;
frame_height = data1.(fns1{1}).mov.Height;

%% Clean out noise and persistent objects:
df1 = removePersistentObjects(df1);
df2 = removePersistentObjects(df2);

%% Calculates the time difference in frames, currently done manually - FOR CONTROL TRIM ONLY
c1_start = 104;
c2_start = 434;
dk = c2_start - c1_start;

%% Find all 1-flash-frames to calibrate on:
calTraj = extractCalibrationTrajectories(df1,df2,dk);


%% Calculate or Read in Fundamental Matrix
addpath(genpath(strcat(folder_path,"/F_Matrices")))
fnames = dir(strcat(pwd,"/F_Matrices/*.mat"));

% Check to see if object already exists
if ~ismember(strcat(fns1{1},"--",fns2{1},".mat"),{fnames.name})
    disp('Estimating fundamental matrix; this may take a while (up to ~1hr)...')
    disp(datetime('now'))

    % renormalize to get third coordinate equal to 1 (see Matlab doc) 
    points1 = calTraj.j1(:,1:2)./calTraj.j1(:,3);
    points2 = calTraj.j2(:,1:2)./calTraj.j2(:,3);

    % calculate fundamental matrix
    % for consistency, points of camera 2 enter as first argument
    estMethod = 'RANSAC';
    stereoParams.F = estimateFundamentalMatrix(points2,points1,'Method',estMethod);
    % methodOptions = {'LMedS', 'LTS', 'RANSAC', 'MSAC', 'Norm8Point'}; 

    disp('calibration complete.')
    disp(datetime('now'))
    save(strcat(pwd,"/F_matrices/",fns1{1},"--",fns2{1}), 'stereoParams');
else
    stereoParams = importdata(strcat(pwd,"/F_matrices/",fns1{1},"--",fns2{1},".mat"));
    disp(strcat('Fundamental matrix already exists for these files, loading:',strcat(fns1{1},"--",fns2{1},".mat")))
end

%% Point matching and Triangulation

fprintf('Beginning point matching and triangulation...\nStart time: %s\n',datetime('now'))
% Finds matching points frame by frame after solving epipolar constraint
[matched_points_1,matched_points_2]=matchStereo(df1, df2, stereoParams, dk, 10000);
% Triangulate

% Load in sony camera intrinsic parameters
load('sony_camera_parameters.mat')
xyz = triangulate(matched_points_1(:,1:2), matched_points_2(:,1:2), sony_camera_parameters);
xyzt = [xyz, matched_points_1(:,3)];

% Note that any missing points were rejected in matchStereo, not the
% triangulation function. rows matched_points_1() == rows xyz
successRate = size(xyzt,1)/min(size(df1,1),size(df2,1));
fprintf('Matching and triangulation completed with success rate: %.3f\nEnd time: %s\n',successRate,datetime('now'))

% Save xyzt object to file
save(strcat("xyzt--",fns1{1},"--",fns2{1}), 'xyzt');
scatter3( xyzt(:,1) , xyzt(:,2) , xyzt(:,3) )

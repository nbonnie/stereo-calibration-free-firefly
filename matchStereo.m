function [matched_df1, matched_df2] = matchStereo(df1, df2, stereoParams, dk, thresh)
% MATCHSTEREO Finds corresponding points between two stereo images.
%
% Description:
%   This function establishes point correspondences between two sets of image 
%   features (df1 and df2) from a calibrated stereo camera setup. It leverages 
%   the epipolar constraint to find potential matches and enforces a similarity
%   threshold to refine the results.
%
% Inputs:
%   df1:          (nx3) matrix of features from camera 1. Columns represent x, y, and time.
%   df2:          (mx3) matrix of features from camera 2. Columns represent x, y, and time.
%   stereoParams: Struct containing stereo calibration parameters, including the fundamental matrix (F).
%   dk:           Time offset (delay/synchronization difference) between cameras.
%   thresh:       Similarity threshold for matching (optional, default is 100). 
%
% Outputs:
%   matched_df1:  (kx3) matrix of matched features from camera 1 (x, y, and time).
%   matched_df2:  (kx3) matrix of matched features from camera 2 (x, y, and time).
%                 Each row in 'matched_df1' corresponds to the same feature as the 
%                 same row in 'matched_df2'.     
%
% Example Usage:
%   [matched_points1, matched_points2] = matchStereo(features1, features2, stereoParams, dk); 
%
% Nolan R Bonnie, 03/2024
% nolan.bonnie@colorado.edu

if nargin == 4
    thresh = 100;
end

% Sync times
df2(:,3) = df2(:,3)-dk;

% Init vars for loop
matched_df1 = [];
matched_df2 = [];

F = stereoParams.F;

for t = intersect( unique(df1(:,3)) , unique(df2(:,3)) )'
    % Time will be trimmed out in point_matching_model()
    df1_t = df1(df1(:,3)==t, :);
    df2_t = df2(df2(:,3)==t, :);

    [matched_df1_t, matched_df2_t, ~] = epipolar_constraint(df1_t, df2_t, F, thresh);
    
    % Append new matched points at time t into complete lists
    % Possible to pre-allocate but likely not neccesary
    matched_df1 = [matched_df1; matched_df1_t]; %#ok<AGROW> 
    matched_df2 = [matched_df2; matched_df2_t]; %#ok<AGROW> 

end

end
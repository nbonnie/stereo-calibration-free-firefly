function [matched_df1, matched_df2, metadata] = matchStereoOld(df1, df2, stereoParams, dk, dThresh)
% OUTPUT:
% matched_df1 - (nx2), x-y-t coordinates
% matched_df2 - (nx2), x-y-t coordinates
% Creates the matched points that matlab requires to triangulate. These are
% points that are "close enough" together after mapping onto eachother.
% Close enough is definied by dThresh, used in matlab function matchpairs

% Sync times
df2(:,3) = df2(:,3)-dk;


% Pull translation and rotation matricies from stereoParams
try
    translation = stereoParams.t(:);
    Rotation = stereoParams.R;
catch
    % If using the real stereoParams object:
    tR = F2tR(stereoParams.FundamentalMatrix);

    translation = tR.t;
    Rotation = tR.R;
    disp("Using real stereoParams object")
end

if nargin == 4
    dThresh = 0.1;
end

% Store metadata on calculation
metadata.t = translation;
metadata.R = Rotation;
metadata.skipped_frames = 0;
metadata.thresh = dThresh;
metadata.possible_frames = intersect( unique(df1(:,3)) , unique(df2(:,3)) )';

% Init vars for loop
matched_df1 = [];
matched_df2 = [];
t_start = datetime('now');

% Find intersection of unique df1 and df2 times to iterate through.
%

% It looks like this section is using df1(i,:), [x, y, t] as points, and
% calculating cost based off this? Closeness should not depend on time if
% all times are restricted to be the same.

for t = intersect( unique(df1(:,3)) , unique(df2(:,3)) )'

    % What we had before:
%     df1_t = df1(df1(:,3)==t, :);
%     df2_t = df2(df2(:,3)==t, :);
    % Create temp dfs at time = t
    df1_t = df1(df1(:,3)==t, 1:2);
    df2_t = df2(df2(:,3)==t, 1:2);

    df1_t = [df1_t, ones(size(df1_t,1),1)];
    df2_t = [df2_t, ones(size(df2_t,1),1)];

    N1 = size(df1_t,1);
    N2 = size(df2_t,1);
    beta2 = (Rotation'*df2_t')';      % Dependent on time as well
    cij = NaN(N1,N2);

    matched_df1_t = NaN(min(N1,N2),3);
    matched_df2_t = NaN(min(N1,N2),3);

    for i = 1:N1
        for j = 1:N2
            % Calculates the optimal distances r1, r2 assuming points i and j are
            % matched, and calculates the distance between the two reconstituted
            % points.
            C = [df1_t(i,:)' -beta2(j,:)'];      % Dependent on whole row, including time??
            r1r2 = lsqnonneg(C,translation);
            cij(i,j) = vecnorm(C*r1r2 - translation);
        end
    end

    m = matchpairs(cij,dThresh);
    if isempty(m)
        metadata.skipped_frames = metadata.skipped_frames + 1;
        continue  % no valid pairs found for time t
    end

    for k = 1:size(m,1)  % For all matches found
        matched_df1_t(k,:) = df1_t(m(k,1),:);
        matched_df2_t(k,:) = df2_t(m(k,2),:);
    end

    % Remove pre-allocated NaN rows
    matched_df1_t(all(isnan(matched_df1_t),2),:) = [];
    matched_df2_t(all(isnan(matched_df2_t),2),:) = [];
    
    % Add new matched xyt rows to our return matrices
    matched_df1 = vertcat(matched_df1, matched_df1_t);      %#ok   Pre-allocation breaks size limit
    matched_df2 = vertcat(matched_df2, matched_df2_t);      %#ok 

end
metadata.time = datetime('now') - t_start;

end
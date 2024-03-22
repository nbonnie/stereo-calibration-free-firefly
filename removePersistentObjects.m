function xytOut = removePersistentObjects(xytIn)
%REMOVEPERSISTENTOBJECTS Removes persistent objects, often light pollution.
% Fireflies cannot flash or glow for a long time, so long light streaks are 
% typically light pollution (flashlight, moon, background spot).  
%
% Raphael Sarfati, 03/2021
% raphael.sarfati@aya.yale.edu
% Peleg Lab, University of Colorado Boulder

%% duration and distance parameters
trajDurationThreshold = 60;
persistentHeightThreshold = 15;
sphereDistThresh = 0.1;

%% initialize
xy = xytIn(:,1:2);
t = xytIn(:,3);
nPoints = length(t);


[vals, xbinedges, ybinedges] = histcounts2(xytIn(:,1), xytIn(:,2), 'BinWidth', [10 10]);
linearIndices = find(vals>persistentHeightThreshold);
[xind, yind] = ind2sub(size(vals), linearIndices);
filteredX = xbinedges(xind);
filteredY = ybinedges(yind);

good_indices = true(nPoints,1);
for i=1:length(filteredX)
    good_indices(xytIn(:,1) >= filteredX(i) & xytIn(:,1) <= filteredX(i)+10 & xytIn(:,2) >= filteredY(i) & xytIn(:,2) <= filteredY(i)+10,1) = false;
end


% %%
% xytRemoved = xytIn(isTooLong,:);
% xytOut = xytIn(isNotTooLong,:);

xytOut = xytIn(good_indices,:);
%scatter(xytOut(:,1),xytOut(:,2), 7, xytOut(:,3));


end


% 
% alpha = xy2alpha(xy,[frameWidth frameWidth/2]);
% nPoints = length(t);
% ti = min(t);
% tf = max(t);
% 
% % adjacency matrix
% adj = sparse(nPoints,nPoints);
% 
% %% match points in successible frames
% for tk = ti:tf-1
%     
%     f1 = find(t == tk);
%     f2 = find(t == tk+1);
%     
%     a1 = alpha(f1,:);
%     a2 = alpha(f2,:);
%     
%     p = pdist2(a1,a2);
%     
%     M = matchpairs(p,sphereDistThresh);
%     
%     % build adjacency matrix
%     for j=1:size(M,1)
%         adj(f1(M(j,1)),f2(M(j,2))) = 1;
%         adj(f2(M(j,2)),f1(M(j,1))) = 1;
%     end
%     
%     % waitbar
%     % w = waitbar((tk-ti)/(tf-ti));
%     
% end
% 
% % close(w)
% 
% %% build trajectories
% % adjacency matrix to graph
% G = graph(adj);
% 
% % graph connected components, i.e. trajectories
% [trajID,trajDuration] = conncomp(G);
% 
% %% filter and exit
% % find trajectories too long
% tooLongTrajID = find(trajDuration > trajDurationThreshold);
% 
% isTooLong = ismember(trajID,tooLongTrajID);
% isNotTooLong = ~isTooLong;

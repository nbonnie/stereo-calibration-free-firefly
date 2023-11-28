function [matchedAlpha1,matchedAlpha2,m,cij] = matchAlphaPoints(df1,df2,stereoParams,dThreshold)
%MATCHALPHAPOINTS Finds optimal overall matching of points given t and R.
%
%   alpha1, alpha2 (Nx3) are the spherical projections in a given frame
%   stereo360Params contains t and R
%   dThreshold is maximum allowed cost for pairing (recommended: 0.1)
%
%   Cost Function
%   Function calculates the optimal distances r1, r2 assuming points i and j are
%   matched, and calculates the distance between the two reconstituted
%   points.
%   Then applies matching algorithm.
%
% Raphael Sarfati 03/2020
% Peleg Lab, University of Colorado Boulder

% default value for dThreshold
if nargin == 3
    dThreshold = 0.1;
end

% initialization
t = stereoParams.t(:);
R = stereoParams.R;
N1 = size(df1,1);
N2 = size(df2,1);
beta2 = (R'*df2')';
cij = NaN(N1,N2);

% calculates cij for each pair ij
for i = 1:N1    
    for j = 1:N2
        % discounts points they are too close to the cameras' connecting
        % line
%         if abs(dot(alpha1(i,:)',t))>0.99 || abs(dot(beta2(j,:)',t))>0.99
%             cij(i,j) = Inf;
            
        % Calculates the optimal distances r1, r2 assuming points i and j are
        % matched, and calculates the distance between the two reconstituted
        % points.
        
        C = [df1(i,:)' -beta2(j,:)'];
        r1r2 = lsqnonneg(C,t);
        cij(i,j) = vecnorm(C*r1r2-t);
            
        
        
    end
end


% apply hungarian/munkres assignment algorithm;
% can be replaced with Matlab FEX's munkres function if old Matlab version
% https://www.mathworks.com/matlabcentral/fileexchange/20328-munkres-assignment-algorithm
m = matchpairs(cij,dThreshold);

matchedAlpha1 = df1(m(:,1),:);
matchedAlpha2 = df2(m(:,2),:);

end
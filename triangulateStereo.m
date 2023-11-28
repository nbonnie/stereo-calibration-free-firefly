function [xyzt, err] = triangulateStereo(c1_points, c2_points, stereoParams)

n = size(c1_points,1);

xyz = NaN(n,3);
err = NaN(n,1);

R = stereoParams.R;
t = stereoParams.t;

w = waitbar(0,"Calculating...");

for i=1:n
    
    alpha1 = c1_points(i,1:3);
    alpha2 = c2_points(i,1:3);
    beta2 = (R'*alpha2')';
    
    % estimates optimal r1, r2 (see Ma 2015 for details)
    C = [alpha1' -beta2'];
    rr = lsqnonneg(C,t);
    
    r1 = rr(1);
    r2 = rr(2);
    
    P1 = r1*alpha1;
    P2 = r2.*(R'*alpha2')' + t';
    
    xyz(i,:) = (P1+P2)/2;
    err(i) = vecnorm(P1-P2);    

    try
        waitbar(i/n, w, "Calculating...");
    catch
        continue
    end

end

close(w)

% Add in time column
xyzt = [xyz, c1_points(:,3)];

end
function groups = trajectoryGroups(xyzti)

for i = unique(xyzti(:,4))
    % Grab xyzti object where time is i
    df_t = xyzti(xyzti(:,4) == i,:);
    % Find all streak ids

end

end
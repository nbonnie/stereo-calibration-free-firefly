function xyzti_new = filterMinGroups(xyzti, min_size)
xyzti_new = [];
for i = 1:size(xyzti, 1)
    if size(xyzti(xyzti(:,5) == xyzti(i,5)), 1) > min_size
        xyzti_new = [xyzti_new; xyzti(i,:)];    %#ok
    end
end
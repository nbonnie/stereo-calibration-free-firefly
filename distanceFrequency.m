function distances = distanceFrequency(xyzt)
    n = size(xyzt, 1);
    distances = nan(n);
    for i = 1:n
        for j = i:n
            if i == j
                continue
            end
            distances(i,j) = norm(xyzt(i,1:3) - xyzt(j,1:3));
        end
    end
end
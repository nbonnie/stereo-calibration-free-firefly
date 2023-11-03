% Made to verify new calibration trajectories with the known quantity
clear; clc;

load("caltraj_N.mat");
load("caltraj_R.mat");

n_xyt_1 = pairs(:,1:3);
n_xyt_2 = pairs(:,4:6);

r_xyt_1 = calTraj.j1;
r_xyt_2 = calTraj.j2;

c1_check = check_match(n_xyt_1, r_xyt_2);
c2_check = check_match(n_xyt_2, r_xyt_1);


function check_array = check_match(test, reference)
    check_array = zeros(1,size(test, 1));
    for i = 1:size(test, 1)
        if any(ismember(reference,test(i,:),'rows')) 
            check_array(i) = 1; 
        else 
            check_array(i) = 0;
        end
    end
end
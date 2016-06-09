%% Static Estimation
clear; clc;
load dynamic_state

%num_samples - number of samples
%N - number of dimensions
%m - number of sensing units

% Centralized estimate
max_k = 200;
xhat = zeros(N,1);
P = eye(N);
x_test = [];
for k=1:max_k
    [xhat,P] = kalman_filter(A,C,R,Q,P,xhat,y(:,k));
    x_test = [x_test, xhat];
end

error_x = x_trajectory - x_test;

figure(1)
hold on;

% Compute local estimates
color={'k.', 'b.' ,'g.', 'm.', 'c.' , 'y.'};
for i=1:m
    C_local = sensor{i}.C;
    R_local = sensor{i}.R;
    y_local = sensor{i}.y;
    
    xhat = zeros(N,1);
    P = eye(N);
    sensor{i}.x_test = [];
    for k=1:max_k
        [sensor{i}.xhat, sensor{i}.P ]= kalman_filter(A,C_local,R_local,Q,P,xhat,y_local(:,k));
        sensor{i}.x_test = [sensor{i}.x_test sensor{i}.xhat];
    end
    
    sensor{i}.error_x = x_trajectory - sensor{i}.x_test;
    
    %plot local errors 
    str_leg{i} = strcat('Estimate of Sensor: ',num2str(i));
    plot(sensor{i}.error_x(1,:),sensor{i}.error_x(2,:) , color{i})
end
str_leg{i+1} = strcat('Centralized Estimate');
 plot(error_x(1,:),error_x(2,:) ,'r.')
 
legend(str_leg, 'Location','NW')
title 'Estimation errors'
hold off
 
 

 
 
 %% Compute fused estimates
  figure(2)
 str_leg = '';
 fusion = '';
 hold on;
 
 x_fused_old=zeros(N,max_k);
 P_fused_old_inv=zeros(N,N);
 for i=1:m
    C_local = sensor{i}.C;
    R_local = sensor{i}.R;
    P_local = sensor{i}.P;
    xhat_local = sensor{i}.x_test;
    
    % apply bayes fusion rule
    [x_fused, P_fused_inv]=fuse_estimates(x_fused_old, xhat_local, P_fused_old_inv, P_local^-1);
    error_x_fused = x_trajectory-x_fused;
    
    x_fused_old = x_fused;
    P_fused_old_inv = P_fused_inv;
        
    if i==1
        fusion = strcat(fusion, num2str(i));
    else
        fusion = strcat(fusion, ', ', num2str(i));
    end
    str_leg{i} = strcat('Fusion of sensors: ',fusion);
    plot(error_x_fused(1,:), error_x_fused(2,:), color{i}, 'MarkerSize', 10)
 end

legend(str_leg, 'Location','NW')
title 'Estimation error per fusion'
hold off
        
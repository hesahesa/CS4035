%% Static Estimation
clear; clc;
load multiple_samples

%num_samples - number of samples
%N - number of dimensions
%m - number of sensing units

% Centralized estimate
[xhat, P] = MLE(C,R,y);
error_x = kron(ones(1,num_samples),x) - xhat;

figure(1)
hold on;

% Compute local estimates
color={'k.', 'b.' ,'g.', 'm.', 'c.' , 'y.'};
for i=1:m
    C_local = sensor{i}.C;
    R_local = sensor{i}.R;
    
    [sensor{i}.xhat, sensor{i}.P ]= MLE(sensor{i}.C,sensor{i}.R,sensor{i}.y);
    sensor{i}.error_x = kron(ones(1,num_samples),x) - sensor{i}.xhat;
    
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
 
 x_fused_old=zeros(N,num_samples);
 P_fused_old_inv=zeros(N,N);
 for i=1:m
    C_local = sensor{i}.C;
    R_local = sensor{i}.R;
    P_local = sensor{i}.P;
    xhat_local = sensor{i}.xhat;
    
    % apply bayes fusion rule
    [x_fused, P_fused_inv]=fuse_estimates(x_fused_old, xhat_local, P_fused_old_inv, P_local^-1);
    error_x_fused = (kron(ones(1,num_samples),x)-x_fused);
    
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
        
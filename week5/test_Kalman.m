close all;
clear; clc;
load dynamic_state

%%%%%% Kalman State Estimation %%%
%num_time - number of time samples
%N - number of dimensions
%m - number of sensing units

%% Centralized Kalman Filter
xhat = zeros(N,num_time);
P{1}=eye(N);
P_pred{1}=eye(N);
error_x = zeros(N,num_time);
for k=2:num_time
    [xhat(:,k), P{k}] = kalman_filter(A, C, R, Q, P{k-1}, xhat(:,k-1), y(:,k));
    error_x(:,k) = x_trajectory(:,k) - xhat(:,k);
end
P_centralized = cov(error_x'); % empirical covariance matrix; should be close to P{num_time}, the theoretical covariance matrix

%% Local Estimates
figure(1)
hold on;
str_leg = '';
color={'k-', 'b-' ,'g-', 'm-', 'c-' , 'y-'};
for i=1:m % Compute local estimates for each sensor
    C_local = sensor{i}.C;
    R_local = sensor{i}.R;
    sensor{i}.xhat = zeros(N,num_time);
    sensor{i}.P{1}=eye(N);
    for k=2:num_time
        [sensor{i}.xhat(:,k), sensor{i}.P{k}] = kalman_filter(A, C_local, R_local, Q, sensor{i}.P{k-1}, sensor{i}.xhat(:,k-1), sensor{i}.y(:,k));
        sensor{i}.error_x(:,k) = x_trajectory(:,k) - sensor{i}.xhat(:,k);
    end
    
    %plot estimation error from each sensor 
    str_leg{i} = strcat('Estimate of Sensor: ',num2str(i));
    plot(1:num_time,sensor{i}.error_x(2,:) , color{i})
end
% compare with centralized estimate
str_leg{i+1} = strcat('Centralized Estimate');
 plot(1:num_time,error_x(2,:) ,'r-')
 
legend(str_leg, 'Location','NW')
title 'Estimation errors'
hold off

 %% Compute fused estimates - Naive Bayesian approach
 figure(2)
 str_leg = '';
 fusion = '';
 hold on;
 
 % variable initialization 
 for k=1:num_time
    P_fused_inv{k} = zeros(N); % inverse of the covariance matrix of the fused estimate (P_fused^(-1))
 end
 error_x_fused = zeros(N,num_time); %estimation error
 x_fused=zeros(N,num_time); %fused estimate
 
 for i=1:m % fuse one sensor at a time, for comparison
    C_local = sensor{i}.C;
    R_local = sensor{i}.R;
    xhat_local = sensor{i}.xhat;
    P_local = sensor{i}.P;
    
    % apply bayes fusion rule (note: the independence assumption does not hold!)
    for k=1:num_time %performs the fusion for all time-steps
        [x_fused(:,k), P_fused_inv{k}]=fuse_estimates(x_fused(:,k), xhat_local(:,k), P_fused_inv{k}, P_local{k}^-1); % updates fused estmates with new local estimates
        error_x_fused(:,k) = x_trajectory(:,k)-x_fused(:,k);  
    end
    P_naive{i} = cov(error_x_fused'); % empirical covariance matrix; If fusion is optimal, P_naive{m} should be close to P{num_time}

    if i==1
        fusion = strcat(fusion, num2str(i));
    else
        fusion = strcat(fusion, ', ', num2str(i));
    end
    str_leg{i} = strcat('Fusion of sensors: ',fusion);
    plot(1:num_time, error_x_fused(2,:), color{i}, 'MarkerSize', 10)
 end
legend(str_leg, 'Location','NW')
title 'Estimation error per fusion'
hold off


 %% Compute fused estimates - Optimal Bayesian approach
 % NOT REQUIRED FOR THE REPORT, only to be used for comparison
 % Based on: http://www.cds.caltech.edu/~murray/courses/eeci-sp08/L9_distributed.pdf
 
 figure(3)
 str_leg = '';
 fusion = '';
 hold on;
 
for j=1:m % fusion for diferent sets of sensors
 P_fused_inv{1} = eye(N);
 x_fused(:,1) = zeros(N,1);
 error_x_fused = zeros(N,num_time);
 
     if j==1
        fusion = strcat(fusion, num2str(j));
    else
        fusion = strcat(fusion, ', ', num2str(j));
    end
 
for k=2:num_time
    x_sum = zeros(N,1);
    P_inv_sum = zeros(N,N);
    
    for i=1:j  % aggregate estimates and covariance matrices from different sensors
    xhat_pred = A*sensor{i}.xhat(:,k-1);
    P_pred_inv = (A*sensor{i}.P{k-1}*A'+Q)^-1;
   
    x_sum = x_sum + (pinv(sensor{i}.P{k})*sensor{i}.xhat(:,k) - P_pred_inv*xhat_pred);
    P_inv_sum =P_inv_sum + (-P_pred_inv + pinv(sensor{i}.P{k})) ;
    end
    
    % fusion at central node
    x_fused_pred = A*x_fused(:,k-1);
    P_fused_pred_inv = (A*pinv(P_fused_inv{k-1})*A'+Q)^-1;
    P_fused_inv{k} = P_fused_pred_inv + P_inv_sum;
    x_fused(:,k) = pinv(P_fused_inv{k})*(P_fused_pred_inv*x_fused_pred + x_sum);

    error_x_fused(:,k) = x_trajectory(:,k)-x_fused(:,k);
end
P_fused{j} = cov(error_x_fused'); % empirical covariance matrix; If naive bayes is optimal, P_fused{m} should be close to P{num_time}

str_leg{j} = strcat('Fusion of sensors: ',fusion);
plot(1:num_time, error_x_fused(2,:), color{j}, 'MarkerSize', 10); 

end

legend(str_leg, 'Location','NW')
title 'Estimation error after fusion'
hold off

% Check independence assumptions by analyzing the covariance between local measurements / estimates
idx1=1;
idx2=6;
Cov_measurements = cov((sensor{idx1}.C*x_trajectory - sensor{idx1}.y)',(sensor{idx2}.C*x_trajectory - sensor{idx2}.y)'); % covariance between measurements of different sensors
Cov_estimates = cov(sensor{idx1}.error_x',sensor{idx2}.error_x'); % covariance between local estimates of different sensors
%
cov_meas = abs(Cov_measurements(1,2)); % measurements of sensor idx1 and idx2 are independent if cov_meas is close to zero
cov_estimates = abs(Cov_estimates(1,2)); % estimates of sensor idx1 and idx2 are independent if cov_estimates is close to zero

% Comparing "accuracy" of each method
acc=[];
for j=1:m %each column k represent the fusion of sensors 1 to k
    tmp = [ log(det(inv(P_naive{j}))); %Naive Bayes
            log(det(inv(P_fused{j}))); %Optimal Bayes
            log(det(inv(P_centralized)))]; % Centralized Kalman Filter
    acc=[acc, tmp];
end

clear; clc;
load 'dynamic_state.mat'
max_k = 200;

xhat = zeros(N,1);
P = eye(N);

x_test = [];

for k=1:max_k
    [xhat,P] = kalman_filter(A,C,R,Q,P,xhat,y(:,k))
    x_test = [x_test, xhat]
end
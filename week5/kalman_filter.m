function [xhat_new,P_new] = kalman_filter(A,C,R,Q,P,xhat,y)
%KALMAN_FILTER Summary of this function goes here
%   Detailed explanation goes here
    x_step = A*xhat;
    P_step = A*P*A'+Q;
    
    Kk = P_step*C'*inv(C*P_step*C' + R);
    xhat_new = x_step + Kk*(y - C*x_step);
    m = size(Kk*C,1);
    P_new = (eye(m) - Kk*C)*P_step;

end


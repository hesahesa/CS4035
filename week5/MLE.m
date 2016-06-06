function [xhat, P]=MLE(C,R,y)
%MLE Summary of this function goes here
%   Detailed explanation goes here
    P = inv(C'*inv(R)*C);
    xhat = P*C'*inv(R)*y;
end


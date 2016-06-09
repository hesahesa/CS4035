function [xhat, P_inv]=fuse_estimates(x1, x2, P1_inv,P2_inv)
%FUSE_ESTIMATES Summary of this function goes here
%   Detailed explanation goes here
    P_inv = P1_inv+P2_inv;
    xhat = inv(P_inv)*(P1_inv*x1 + P2_inv*x2);
end


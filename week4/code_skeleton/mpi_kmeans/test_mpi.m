%clear;
% Load data set
% load fisheriris;
% X=meas(:,3:4);
clear;
load data.mat

X = X(:,[1 2]);

Nrecords = size(X,1);

% Set clustering parameters
K =6;
%centroids = X([1:ceil(Nrecords/K):Nrecords] , :); %initialize set of K centroids
centroids = gendat(X,K/size(X,1)); %initialize set of K centroids randomly

% set memory contraints
Lmax = 1000; %100000; % maximum number of records per slave

%Split data per slave
N_slaves = ceil(Nrecords/Lmax);
for i=1:N_slaves
chunk_i = ((i-1)*Lmax+1):min(i*Lmax,Nrecords); % split data into chunks of up to Lmax records
    data_slaves{i} = X(chunk_i  ,:);
end

flag_parallel = 0; % 0- single core; 1- runs k-means in parallel

%%% Sets and opens the parallel pool
if flag_parallel ==1
    pool = parpool;                      % Invokes workers
end
%%%

iter_max = 5; % run k-means for iter_max iterations
tic;
if flag_parallel == 1
    for iter=1:iter_max
        centroids = kmeans_mpi_par(data_slaves,centroids, N_slaves);
    end
else
    for iter=1:iter_max
        centroids = kmeans_mpi(data_slaves,centroids, N_slaves);
    end
end
toc
if flag_parallel ==1
    delete(pool); % shuts down the parallel pool
end
%%
[Cost_mpi,idx_cluster] = cluster_assignment(X, centroids);
plot_kmeans(X,centroids,idx_cluster)
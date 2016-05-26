clear;
load data.mat

Nrecords = size(X,1);

% Set clustering parameters
K =3;
centroids = X([1:ceil(Nrecords/K):Nrecords] , :); %initialize set of K centroids

% set memory contraints
Lmax = 1000; % maximum number of records per mapper

%Split data per mapper
N_mappers = ceil(Nrecords/Lmax);
for i=1:N_mappers
chunk_i = ((i-1)*Lmax+1):min(i*Lmax,Nrecords); % split data into chunks of up to Lmax records
    data_mappers{i} = X(chunk_i  ,:);
end

flag_parallel = 0; % 0 - single core; 1- uses parallelization

%%% Sets and opens the parallel pool
if flag_parallel ==1
    pool = parpool;                      % Invokes workers
end
%%%

iter_max = 15; % run k-means for iter_max iterations
tic;
if flag_parallel == 1
    for iter=1:iter_max
        centroids = kmeans_mapreduce_par(data_mappers,centroids, N_mappers);
    end
else
    for iter=1:iter_max
        centroids = kmeans_mapreduce(data_mappers,centroids, N_mappers);
    end
end
toc
if flag_parallel ==1
    delete(pool); % shuts down the parallel pool
end
%%
[Cost_mapreduce,idx_cluster] = cluster_assignment(X, centroids);
plot_kmeans(X,centroids,idx_cluster)
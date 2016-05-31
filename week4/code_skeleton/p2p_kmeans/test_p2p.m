clear;
load data.mat % data set

Nrecords = size(X,1); %number of records in the data set

% Set clustering parameters
K =6;

% Set memory contraints per node
Lmax = 1000; % maximum number of records per node

% Split data per node
N_slaves = ceil(Nrecords/Lmax); % required number of nodes, given memory constraints
for i=1:N_slaves
chunk_i = ((i-1)*Lmax+1):min(i*Lmax,Nrecords); % split data into chunks of up to Lmax records
    data_slaves{i} = X(chunk_i  ,:);
end
% Each node initializes a loca copy of the centroids based on local
% data
for i=1:N_slaves
    Nrecords = size(data_slaves{i},1);
    local_centroids{i} = data_slaves{i}([1:ceil(Nrecords/K):Nrecords] , :);
end

% %% Generates a random P2P communication network
rng(1);
Lap = 0;
while rank(Lap) < N_slaves-1 %This loop ensures that the network is connected
    Graph=erdosRenyi(N_slaves,0.8,3);
    Lap = diag(Graph.Adj*ones(N_slaves,1)) - Graph.Adj;
end


flag_parallel = 0; % variable indicating whether Parallelization is used (1) or not (0)

%%% Sets and opens the parallel pool
if flag_parallel ==1
    pool = parpool;                      % Invokes workers
end
%%%

iter_max = 15; % run k-means for iter_max iterations

tic; % Start timer!
if flag_parallel == 1
    for iter=1:iter_max
        local_centroids = kmeans_p2p(data_slaves,N_slaves, Graph,local_centroids);
    end
else
    for iter=1:iter_max
        local_centroids = kmeans_p2p(data_slaves, N_slaves, Graph,local_centroids);
        
        %compute the maximum deviation
        max_dev_1(iter) = -999;
        for i=1:size(local_centroids,2)
          max_dev_1(iter) = max(max_dev_1(iter), norm(local_centroids{1} - local_centroids{i} ,inf) );
       end
    end
end
toc % Time Elapsed

if flag_parallel ==1
    delete(pool); % shuts down the parallel pool
end

% Select the centroids from one node in the network, picked at random 
idx_node = randi([1, N_slaves]);
centroids = local_centroids{idx_node};

%%
[Cost_mpi,idx_cluster] = cluster_assignment(X, centroids);
plot_kmeans(X,centroids,idx_cluster)
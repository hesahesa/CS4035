function centroids = kmeans_mpi(data_slaves,centroids, N_slaves)
K=size(centroids,1);

% Master Broadcasts Centroids to slaves
for i=1:N_slaves
    local_centroids{i} = centroids;
end

% Slaves run k-means on local data
for i=1:N_slaves
    local_clusters{i} = kmeans_mpi_slave(data_slaves{i}, local_centroids{i});
end

% Master aggregates local centroids through weighted averaging
centroids = kmeans_mpi_master(local_clusters, N_slaves);
function centroids = kmeans_mpi_master(local_clusters,N_slaves)
% Mapper function for the K-Means algorithm.

    K=size(local_clusters{1},2);
    n_dim = size(local_clusters{1}{1}.centroids,2);
    centroids = zeros(K,n_dim);
    for j=1:K 
        ...
    end
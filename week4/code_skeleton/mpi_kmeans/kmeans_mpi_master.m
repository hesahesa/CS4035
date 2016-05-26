function centroids = kmeans_mpi_master(local_clusters,N_slaves)
% Mapper function for the K-Means algorithm.

    K=size(local_clusters{1},2);
    n_dim = size(local_clusters{1}{1}.centroids,2);
    centroids = zeros(K,n_dim);
    for j=1:K 
        weighted_sum_centroid = 0;
        sum_weight = 0;
        for slv=1:N_slaves
            local_centroid = local_clusters{slv}{j}.centroids;
            local_size = local_clusters{slv}{j}.sizes;
            if(local_size>0)
                weighted_sum_centroid = local_clusters{slv}{j}.centroids + local_centroid.*(local_size*ones(1,n_dim));
                sum_weight = sum_weight + local_size;
            end
        end
        centroids(j,:) = weighted_sum_centroid./sum_weight;
    end
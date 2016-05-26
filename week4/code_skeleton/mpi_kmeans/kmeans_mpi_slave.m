function local_cluster = kmeans_mpi_slave(data,centroids)
    K=size(centroids,1);
    n_dim = size(data,2);
    new_centroid = zeros(K,n_dim);
    new_size = zeros(K,1);
    for j =1:K % initialize local cluster assignments
        cluster{j} = [];
    end

    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Process Chunk of Data
    [cost,idx_cluster] = cluster_assignment(data,centroids);
    
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%  Compute new centroids and sizes
    for j=1:K
        cluster{j} = data(idx_cluster==j,:);
        local_cluster{j}.sizes = size(cluster{j},1) ;
        local_cluster{j}.centroids = get_centroid(cluster{j}) ;
    end
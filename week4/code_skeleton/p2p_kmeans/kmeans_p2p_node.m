function local_cluster = kmeans_mpi_slave(data,centroids)
% K-means algorithm executed by one single node
    K=size(centroids,1);
    n_dim = size(data,2);
    new_centroid = zeros(K,n_dim);
    new_size = zeros(K,1);
    for j =1:K % initialize local cluster assignments
        cluster{j} = [];
    end
    % %%
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for j=1:size(data,1) % Process Chunk of Data
        ...
    end
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%  Compute new local centroids and sizes
    for j=1:K
        local_cluster{j}.sizes = ...;
        local_cluster{j}.centroids= ...;
    end

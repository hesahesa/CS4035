function KVtable = kmeans_map(data, centroids)
% Mapper function for the K-Means algorithm.
% André Teixeira 2016-05-15
% Hendra H Choiri & Prahesa K Setia
    n_dim = size(data,2);
    Nrecords = size(data,1);
    K=size(centroids,1);
    
    new_centroid = zeros(K,n_dim);
    new_size = zeros(K,1);
    for j =1:K % initialize local cluster assignments
        cluster{j} = [];
        KVtable{j} = [];
    end
    
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %for j=1:Nrecords % Process Chunk of Data
    %    ...
    %end

    [Cost,idx_cluster] = cluster_assignment(data, centroids);
    
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%  Compute new centroids
    for j=1:K
        cluster{j} = data(idx_cluster==j,:);
        new_centroid(j,:) = get_centroid(cluster{j}); % from plot_kmeans folder
        new_size(j) = size(cluster{j},1);
    end
    
    for j =1:K % Create KV pairs (already sorted)
        KVtable{j}.centroids = new_centroid(j,:); % from plot_kmeans folder
        KVtable{j}.sizes = new_size(j);
    end
    % %%
function centroids = kmeans_p2p_average_step(local_clusters,N_nodes, Graph)
% Distributed averaging function for the P2P K-Means algorithm.
%
% local_clusters - set of centroids and sizes for each individual node
% N_nodes - number of nodes in the P2P network
% Graph - structure that characterizes the P2P network
% % Graph.nv - number of nodes
% % Graph.Adj - Adjacency matrix of the network. Adj(i,j) = 1 if nodes i
% and j are neighbors.
%
% André Teixeira 2016-05-15

    K=size(local_clusters{1},2);
    n_dim = size(local_clusters{1}{1}.centroids,2);

A= Graph.Adj + eye(Graph.nv); % adds self-loops, to indicate that each node is its own neighbor

% Averaging step among neighbors
    for i=1:N_nodes
        centroids{i} = zeros(K,n_dim); % initialize new local copy of centroid
        for j=1:K % need to perform the average per cluster
            total_size=0;
            for node = 1:N_nodes % node i now communicates with neighbors
                if A(i,node) == 1; % check if current node is a neighbor of node i
                    total_size = total_size + local_clusters{node}{j}.sizes; % keep track of neighbors' cluster size
                    centroids{i}(j,:) = centroids{i}(j,:) + local_clusters{node}{j}.sizes*local_clusters{node}{j}.centroids ;
                end
            end
            centroids{i}(j,:) = centroids{i}(j,:)/total_size; %normalize with total size of cluster
        end
    end
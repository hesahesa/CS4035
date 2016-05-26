function local_centroids = kmeans_p2p(data_nodes, N_nodes, Graph, local_centroids)
% k-means on local data with local clusters.
% The local clusters are updated based on local data at each node
% In the averaging step, nodes update their local centroids by averaging
% out centroids between neighbors: each node collects centroids and size
% from its neighbors and itself, and then computes the weighted average,
% which becomes the node's new local centroid.
%
% Variables:
% local_clusters - set of centroids and sizes for each individual node
% N_nodes - number of nodes in the P2P network
% Graph - structure that characterizes the P2P network
% % Graph.nv - number of nodes
% % Graph.Adj - Adjacency matrix of the network. Adj(i,j) = 1 if nodes i and j are neighbors.
%
% André Teixeira 2016-05-15

K=size(local_centroids{1},1); % number of clusters

% Each node runs k-means on local data with local clusters
for i=1:N_nodes
    local_clusters{i} = kmeans_p2p_node(data_nodes{i}, local_centroids{i});
end

% Nodes updte their local centroids through distributed averaging between
% their neighbors - requires communication between neighbors!
local_centroids = kmeans_p2p_average_step(local_clusters, N_nodes, Graph);
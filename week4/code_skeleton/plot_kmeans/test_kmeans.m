clear;
load data.mat;
Nrecords = size(X,1);
K = 6;

%centroids = X([1:ceil(Nrecords/K):Nrecords] , :); %initialize set of K centroids

%initialized the centroids with random points from dataset
centroids = gendat(X,K/Nrecords);

max_iter=15;
tic;
for iter=1:max_iter
    % for each iteration, update the centroids until it converges
    % assign the clusters
    [cost,idx_cluster] = cluster_assignment(X,centroids);
    new_centroids = [];
    % get new centroids
    for clust=1:K
        new_centroids(clust,:) = get_centroid(X(idx_cluster==clust,:));
    end
        centroids = new_centroids;
end
toc
plot_kmeans(X,centroids,idx_cluster)
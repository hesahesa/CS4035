n_cluster = 6;

%initialized the centroids with random points from dataset
centroids = gendat(X,n_cluster/size(X,1));

converge = false;
while not(converge)
    % for each iteration, update the means until it converges
    [cost,idx_cluster] = cluster_assignment(X,centroids);
    new_centroids = [];
    for clust=1:n_cluster
        new_centroids(clust,:) = get_centroid(X(idx_cluster==clust,:));
    end
    if( norm(new_centroids-centroids)==0 )
        converge = true;
    else
        centroids = new_centroids;
    end
end
plot_kmeans(X,centroids,idx_cluster)
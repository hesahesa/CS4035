function centroid_i = get_centroid(data_cluster_i)
    % get new centroid, which is the mean of all data in the cluster
    centroid_i = mean(data_cluster_i,1);
end
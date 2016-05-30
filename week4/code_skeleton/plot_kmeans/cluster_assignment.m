function [Cost,idx_cluster] = cluster_assignment(data, centroids)
Nrecords = size(data,1);
K=size(centroids,1);

Cost = 0;
idx_cluster = [];
    
for i=1:Nrecords
    % for each record, find the nearest centroid
    current_data = data(i,:);
    %calculate the distance to each centroid
    diff = ones(K,1)*current_data - centroids;
    dist = (sqrt(sum((diff').^2,1))).^2; %norm^2 for each cluster distance
    
    % accumulate the cost
    Cost = Cost + sum(dist);
    
    % get the nearest centroid
    [Min IMin] = min(dist,[],2);
    idx_cluster(i,1) = IMin;
end
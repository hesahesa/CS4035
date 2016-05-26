function [Cost,idx_cluster] = cluster_assignment(data, centroids)
Nrecords = size(data,1);
K=size(centroids,1);

Cost = [];
idx_cluster = [];
    
for i=1:Nrecords
    current_data = data(i,:);
    diff = ones(K,1)*current_data - centroids;
    dist = (sqrt(sum((diff').^2,1))).^2;
    [Min IMin] = min(dist,[],2);
    
    Cost(i,1) = Min;
    idx_cluster(i,1) = IMin;
end
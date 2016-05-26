function centroids = kmeans_mapreduce_par(data_mappers,centroids, N_mappers)
K=size(centroids,1);

% %%% Call and run Mappers in parallel
parfor i=1:N_mappers
    local_centroids = centroids;
    KVtable_mapper{i} = kmeans_map(data_mappers{i}, centroids);
    % %% Sort per key = centroid_ID   
end

% Sort
parfor j=1:K
    for i=1:N_mappers
        KVtable{j}.centroids(i,:) = KVtable_mapper{i}{j}.centroids; % Places Mapper i's local copy of centroid ID=j 
        KVtable{j}.sizes(i) = KVtable_mapper{i}{j}.sizes;
    end
end

% %%% Call and run the Reducers
parfor j=1:K
    centroids(j,:) = kmeans_reduce(KVtable{j});
end
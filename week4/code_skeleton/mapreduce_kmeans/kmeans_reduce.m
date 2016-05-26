function centroids = kmeans_reduce(KVtable_keyj)
    argCentroids = KVtable_keyj.centroids;
    argSizes = KVtable_keyj.sizes;
    
    numDim = size(argCentroids,2);
    numMappers = size(argSizes);
    total_weighted_centroid = [];
    totalSize = 0;
    
    for i = 1:numMappers
        currentSize = argSizes(i);
        total_weighted_centroid = argCentroids(i,:) .* (currentSize*ones(1,numDim));
        totalSize = totalSize + currentSize;
    end    
    
    centroids = total_weighted_centroid / totalSize;
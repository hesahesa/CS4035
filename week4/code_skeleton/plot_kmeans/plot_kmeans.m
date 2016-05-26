function plot_kmeans(data,centroids,idx_cluster)

% plot
K=size(centroids,1);
color={'r.', 'b.' ,'g.', 'm.', 'c.' , 'y.'};
str_leg = '';
figure;
hold on
for i=1:K
    plot(data(idx_cluster==i,1),data(idx_cluster==i,2),color{i},'MarkerSize',12)
    str_leg{i} = strcat('Cluster ',num2str(i));
end


plot(centroids(:,1),centroids(:,2),'kx','MarkerSize',15,'LineWidth',3)
str_leg{K+1} = 'Centroids';
legend(str_leg, 'Location','NW')
title 'Cluster Assignments and Centroids'
hold off
function SecDet = AddAndSortDetect(SecDetCluster,MaxDist,Epochs)

% Adds the detections to the spike list
%
% INPUTS:
%  SecDetCluster    clusters
%  MaxDist          max distance between det to be considered as one spike
%  Epochs           number of epochs for analysis
%
% OUTPUTS:
%  SecDet           structure with detected spikes for each epoch
%       .Det        detected spikes     

SecDet = struct();
for k=1:Epochs
    AddDet = [];
    for CurrentCluster = 1:length(SecDetCluster)
        if (~isempty(SecDetCluster(CurrentCluster).Det)) && (~isempty(SecDetCluster(CurrentCluster).Det.Epoch(k).Det))
            AddDet = [AddDet' SecDetCluster(CurrentCluster).Det.Epoch(k).Det']';
        end
    end
    
    if isempty(AddDet)
        SecDet(k).Det = [];
    else
        SortDet = sortrows(AddDet,1);
        i = 1;
        while i < length(SortDet(:,1))
            if SortDet(i+1,1)-SortDet(i,1)<MaxDist
                SortDet(i,1) = min([SortDet(i,1) SortDet(i+1,1)]);
                SortDet(i,2) = max([SortDet(i,2) SortDet(i+1,2)]);
                SortDet(i+1,:) = [];
            else
                i=i+1;
            end
        end
        SecDet(k).Det = SortDet;
    end
end
    

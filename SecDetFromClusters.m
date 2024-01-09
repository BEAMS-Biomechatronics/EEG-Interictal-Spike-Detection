function PatientSpecificDetSpikes = SecDetFromClusters(Clusters,Recording,DetectionParameters,Derivation)

% Second detection based on the clusters
%
%  INPUTS:	
%   Clusters            clusters
%   Recording           current recording
%   DetectionParameters detection parameters
%   Derivation          current derivation
%
%  OUTPUTS:
%   PatientSpecificDetSpikes    detected spikes via patient-specific detection

PatientSpecificDetSpikesCluster(Clusters.NumClusters).Det = [];

for CurrentCluster = 1:Clusters.NumClusters
    Clusters.PatientSpecificDetSpikesResult(CurrentCluster).SpikeRawData = [];
    if sum(CurrentCluster == Clusters.RejectedClusters)==0
        PatientSpecificDetectionParameters.Template = Clusters.Centroids(CurrentCluster,:);
        PatientSpecificDetectionParameters.TemplateLength = length(PatientSpecificDetectionParameters.Template);
        PatientSpecificDetectionParameters.TemplateNorm = norm(PatientSpecificDetectionParameters.Template);

        PatientSpecificDetectionParameters.RisingSlopeThreshold = mean(Clusters.FeatureCluster(CurrentCluster).RisingSlope)*DetectionParameters.PatientSpecificFeaturesThresh;
        PatientSpecificDetectionParameters.FallingSlopeThreshold = mean(Clusters.FeatureCluster(CurrentCluster).FallingSlope)*DetectionParameters.PatientSpecificFeaturesThresh;
        PatientSpecificDetectionParameters.CurvatureThreshold = mean(Clusters.FeatureCluster(CurrentCluster).Curvature)*DetectionParameters.PatientSpecificFeaturesThresh;
        PatientSpecificDetectionParameters.CorrelationThreshold = DetectionParameters.PatientSpecificCrossCorrThresh;

        PatientSpecificDetSpikesCluster(CurrentCluster).Det = SpikeDetectection(PatientSpecificDetectionParameters,DetectionParameters,Recording,Derivation);
    end
end

PatientSpecificDetSpikes = AddAndSortDetect(PatientSpecificDetSpikesCluster,round(DetectionParameters.MinimumDistance2Spikes/1000*DetectionParameters.Fs),Recording.Epochs);

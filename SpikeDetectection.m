function DetectedSpikes = SpikeDetectection(ReferenceSpike,DetectionParameters,Recording,Derivation)

% Spike detection algorithm
%
%  INPUTS:	
%   ReferenceSpike      spike template
%   DetectionParameters detection parameters
%   Recording           current recording
%   Derivation          current derivation
%
%  OUTPUTS:
%   DetectedSpikes      structure for detected spikes
%       .ProcessedSpikes    spikes
%       .RisingSlope        rising slope
%       .FallingSlope       falling slope
%       .Curvature          curvature
%       .Det                detected spikes for each epoch

DetectedSpikes = [];
SpikeIndex = 1;

for k=1:Recording.Epochs
    [RawData] = GetData(Recording,k,Derivation,DetectionParameters);
    [ProcessedData] = PreProcessing(RawData,DetectionParameters); 
    VprodScNorm = normxcorr2(ReferenceSpike.Template,ProcessedData);
    VprodScNorm = VprodScNorm(ReferenceSpike.TemplateLength:end);

    [~,locs] = findpeaks(VprodScNorm,'MINPEAKHEIGHT',ReferenceSpike.CorrelationThreshold,'MINPEAKDISTANCE',round(DetectionParameters.MinimumDistance2Spikes/1000*DetectionParameters.Fs));

    EpochSpikeIndex = 1;
    while (EpochSpikeIndex <= length(locs)) && (locs(EpochSpikeIndex)+ReferenceSpike.TemplateLength<length(ProcessedData))
        CurrentSpike = ProcessedData(locs(EpochSpikeIndex):locs(EpochSpikeIndex)+ReferenceSpike.TemplateLength-1);

        [RisingSlope, PositionRisingSlope] = max(CurrentSpike);
        RisingSlope = sqrt(abs(RisingSlope));
        [FallingSlope, PositionFallingSlope] = min(CurrentSpike);
        FallingSlope = -sqrt(abs(FallingSlope));
        Curvature = abs((RisingSlope - FallingSlope)/(PositionRisingSlope - PositionFallingSlope)); 

        if ((FallingSlope<ReferenceSpike.FallingSlopeThreshold) && (RisingSlope>ReferenceSpike.RisingSlopeThreshold) && (Curvature>ReferenceSpike.CurvatureThreshold))
            DetectedSpikes.ProcessedSpikes(SpikeIndex,:) = CurrentSpike;
            DetectedSpikes.RisingSlope(SpikeIndex) = RisingSlope;
            DetectedSpikes.FallingSlope(SpikeIndex) = FallingSlope;
            DetectedSpikes.Curvature(SpikeIndex) = Curvature;
            SpikeIndex = SpikeIndex + 1;
            EpochSpikeIndex = EpochSpikeIndex + 1;
        else
            locs(EpochSpikeIndex) = [];
        end
    end

    if EpochSpikeIndex > 1
        DetectedSpikes.ProcessedSpikes = DetectedSpikes.ProcessedSpikes(1:SpikeIndex-1,:);
        DetectedSpikes.RisingSlope = DetectedSpikes.RisingSlope(1:SpikeIndex-1);
        DetectedSpikes.FallingSlope = DetectedSpikes.FallingSlope(1:SpikeIndex-1);
        DetectedSpikes.Curvature = DetectedSpikes.Curvature(1:SpikeIndex-1);
        DetectedSpikes.Epoch(k).Det = [1000*Recording.StartAnalysis(k)+round(1000/DetectionParameters.Fs)*locs' 1000*Recording.StartAnalysis(k)+round(1000/DetectionParameters.Fs)*(locs+ReferenceSpike.TemplateLength)'];
    else
        DetectedSpikes.ProcessedSpikes = [];
        DetectedSpikes.RisingSlope = [];
        DetectedSpikes.FallingSlope = [];
        DetectedSpikes.Curvature = [];
        DetectedSpikes.Epoch(k).Det = [];
    end
end

% MAIN FILE
% Adapt desired parameters and run the algorithm from here.
clear; clc;

% ***********************
% Recordings parameters *
% ***********************

DBPath          = pwd;      % Path to the EEG recordings database
DispPath        = pwd;      % Path to store the results figures

Purpose         = 'Both';   % 'Display', 'Statistics', or 'Both'
% - 'Statistics' exports statistics in an excel sheet
% - 'Display' exports EEG displays in jpg files
% - 'Both' does the two above

Montage         = 1;        % 1, 2, or 3
% - 1 for longitudinal montage
% - 2 for transversal montage
% - 3 for monopolar (or referential) montage

Recordinglist   = ['1'];    % Names of the files
StartAnalysis   = 0;        % In seconds
Duration        = 4*60;     % In seconds, or Inf for the whole recording
SliceRecording  = 'No';     % 'Yes' to slice the recording for faster performances
SliceDuration   = 5;        % In minutes (minimum 2 minutes)

Recordings = GetRecordings(DBPath,SliceRecording,SliceDuration,Recordinglist,StartAnalysis,Duration,Montage);

% ***********************
%  Detection parameters *
% ***********************

% General parameters
DetectionParameters.Fs                              = 200;  % Resampled EEG (imposed)
DetectionParameters.WindowLength                    = 300;  % ms   
DetectionParameters.MinimumDistance2Spikes          = 80;   % ms
% MinimumDistance2Spikes can be increased (~125 ms) for recordings with few
% spikes and decreased (~50 ms) for recordings with many spikes

% Generic Spike Detection Parameters
DetectionParameters.GenericCrossCorrThresh          = 0.6;  % Cross-correlation threshold
DetectionParameters.GenericFeaturesThresh           = 0.3;  % Features threshold
DetectionParameters.GenericTemplateAmplitude        = 30;   % microV

% Subject Specific spike detection parameters
DetectionParameters.PatientSpecificCrossCorrThresh  = 0.7;  % Cross-correlation threshold
DetectionParameters.PatientSpecificFeaturesThresh   = 0.5;  % Features threshold
DetectionParameters.PatientSpecificMinimumSWI       = 0.1;
DetectionParameters.ClusterSelectionThresh          = 0.05;

% ************
%  Detection *
% ************

for CurrentRecording = 1:length(Recordings)
    fprintf(['Recording: ' Recordings(CurrentRecording).Name '\n']);

    parfor Derivation = 1:Recordings(CurrentRecording).NumDerivation
        % Generic spike detection
        GenDetectedSpikes = GenericDetection(Recordings(CurrentRecording),DetectionParameters,Derivation);
        StatGenDet = SingleDerStats(GenDetectedSpikes,Recordings(CurrentRecording));
        
        % Patient-specific detection
        if StatGenDet.SWI>DetectionParameters.PatientSpecificMinimumSWI
            [Clusters] = ClustersFromDetect(DetectionParameters.ClusterSelectionThresh,GenDetectedSpikes);
            SpecificSpikes(Derivation).Epoch = SecDetFromClusters(Clusters,Recordings(CurrentRecording),DetectionParameters,Derivation);
        else
            SpecificSpikes(Derivation).Epoch = GenDetectedSpikes.Epoch;
        end
    end

    % Adjusting the beginning and the end of spikes
    [SpecificSpikesAdj]= BegEndSpikeAdujstment(SpecificSpikes,Recordings(CurrentRecording),DetectionParameters);
    
    % Patient-specific statistics
    [PatientSpecificStats(CurrentRecording).Stat, TimeLineSWI]= GlobalStats(SpecificSpikesAdj,Recordings(CurrentRecording),DetectionParameters);
    
    % Display and save as jpg
    if strcmp(Purpose,'Display') || strcmp(Purpose,'Both')
        Display(SpecificSpikesAdj,Recordings(CurrentRecording),TimeLineSWI,DetectionParameters,DispPath);
    end
end

% Write in Excel
if strcmp(Purpose,'Statistics') || strcmp(Purpose,'Both')
    WriteExcel(PatientSpecificStats,Recordings);
end

function [Stat, TimeLineSWI] = GlobalStats(DetectedSpikes,Recording,DetectionParameters)

% Computes the global statistics for the patient-specific spike detection
%
% INPUTS:
%   DetectedSpikes      detected spikes
%   Recording           current recording
%   DetectionParameters detection parameters
%
% OUTPUTS:
%   Stat                structure with all statistics 
%       .SWF                SWF
%       .GlobalSWI          SWI on the whole recording
%       .GlobalSWIG         SWIG on the whole recording
%   TimeLineSWI
%       .list               list of spikes
%       .listSpikeIn80El    list of spikes in 80% of elecetrodes or more
%       .locsSpikes         spikes locations
%       .SumSpikeLineEl     time vector with number of spikes at each point

StartAnalysis = Recording.StartAnalysis;
EndAnalysis = Recording.EndAnalysis;
NumElectrodes = length(Recording.ElectrodesDictionary.values);

for CurrentEpoch=1:Recording.Epochs
    EpochDuration = EndAnalysis(CurrentEpoch)-StartAnalysis(CurrentEpoch);
    SpikeLine = zeros(Recording.NumDerivation, EpochDuration*DetectionParameters.Fs);
    SpikeLineEl = zeros(NumElectrodes, EpochDuration*DetectionParameters.Fs);
    % SpikeLine are time vectors with 1 where spike(s) occur
    
    for Derivation = 1:Recording.NumDerivation
        Det = DetectedSpikes(Derivation).Epoch;
        NumElRight = Recording.ElectrodesDictionary(Recording.NegativeElectrodes(Derivation,:));
        NumElLeft = Recording.ElectrodesDictionary(Recording.PositiveElectrodes(Derivation,:));

        if (length(Det) >= CurrentEpoch) && (length(Det(CurrentEpoch).Det) > 2) && (length(Det(CurrentEpoch).Det(:,1)) > 2)
            for IndexDetSpikes = 1:length(Det(CurrentEpoch).Det(:,1))
                BegSk = round((Det(CurrentEpoch).Det(IndexDetSpikes,1)/1000-Recording.StartAnalysis(CurrentEpoch))*DetectionParameters.Fs);
                EndSk = round((Det(CurrentEpoch).Det(IndexDetSpikes,2)/1000-Recording.StartAnalysis(CurrentEpoch))*DetectionParameters.Fs);
                if BegSk >0 && EndSk < length(SpikeLine(Derivation,:))
                    SpikeLine(Derivation,BegSk:EndSk-1) = ones(1,EndSk-BegSk);
                    SpikeLineEl(NumElLeft,BegSk:EndSk-1) = ones(1,EndSk-BegSk); 
                    SpikeLineEl(NumElRight,BegSk:EndSk-1) = ones(1,EndSk-BegSk); 
                end
            end
        end
    end

    SumSpikeLine = sum(SpikeLine);
    SumSpikeLineEl = sum(SpikeLineEl);
    
    % Find spikes and how many spikes there are at the same time
    [~,locsSpikes] = findpeaks(SumSpikeLine,'MINPEAKDISTANCE',round(DetectionParameters.MinimumDistance2Spikes/1000*DetectionParameters.Fs));
    
    % Adjust location of the spike on the middle of flat peak
    for index = 1:length(locsSpikes)
        localpeak = locsSpikes(index);
        MaxVal = SumSpikeLine(localpeak);
        Offset = 1;
        while SumSpikeLine(localpeak+Offset) == MaxVal
            Offset = Offset + 1;
        end
        locsSpikes(index) = localpeak + round(Offset/2);
    end

    % Remove doublets again
    index = 1;
    while index < length(locsSpikes)
        localpeak = locsSpikes(index);
        localpeakNext = locsSpikes(index+1);
        if localpeakNext-localpeak<round(DetectionParameters.MinimumDistance2Spikes/1000*DetectionParameters.Fs)
            locsSpikes(index+1) = [];
        end
        index = index+1;
    end
    
    SpikesInSecLine = zeros(1,EpochDuration);
    SpikesInSecLineEl = zeros(1,EpochDuration);
    AtLeastOneSpikeInSecLine = zeros(1,EpochDuration);
    SpikeIn80PercInSecLineEl = zeros(1,EpochDuration);
    
    TimeLineSWI = struct();
    TimeLineSWI(CurrentEpoch).list = [];
    TimeLineSWI(CurrentEpoch).listSpikeIn80El = [];
    TimeLineSWI(CurrentEpoch).locsSpikes = locsSpikes;
    TimeLineSWI(CurrentEpoch).SumSpikeLineEl = SumSpikeLineEl;

    for NumSec = 1:EpochDuration
        SpikeInThisSec = SumSpikeLine((NumSec-1)*DetectionParameters.Fs+1:NumSec*DetectionParameters.Fs);
        SpikeInThisSecEl = SumSpikeLineEl((NumSec-1)*DetectionParameters.Fs+1:NumSec*DetectionParameters.Fs);
        SpikesInSecLine(NumSec) = max(SpikeInThisSec);
        SpikesInSecLineEl(NumSec) = max(SpikeInThisSecEl);
        if SpikesInSecLine(NumSec)>0
            AtLeastOneSpikeInSecLine(NumSec) = 1;
            TimeLineSWI(CurrentEpoch).list = [TimeLineSWI(CurrentEpoch).list NumSec-1];
        end
        if SpikesInSecLineEl(NumSec)>= 0.8*NumElectrodes
            SpikeIn80PercInSecLineEl(NumSec) = 1;
            TimeLineSWI(CurrentEpoch).listSpikeIn80El = [TimeLineSWI(CurrentEpoch).listSpikeIn80El NumSec-1];
        end
    end
    
    Stat.GlobalSWI = [];
    Stat.GlobalSWIG = []; 
    Stat.GlobalSWI = [Stat.GlobalSWI AtLeastOneSpikeInSecLine];
    Stat.GlobalSWIG = [Stat.GlobalSWIG SpikeIn80PercInSecLineEl];
    Stat.GlobalSWI = mean(Stat.GlobalSWI)*100;
    Stat.GlobalSWIG = mean(Stat.GlobalSWIG)*100;

    Stat.SWF = 0;
    ind = 0;
    if CurrentEpoch == 1 && Recording.AnalysisDuration >= 100
        index100 = 100*DetectionParameters.Fs;
        while ind < length(locsSpikes) && locsSpikes(ind+1) <= index100
            ind = ind + 1;
        end
    end
    Stat.SWF = ind;
end

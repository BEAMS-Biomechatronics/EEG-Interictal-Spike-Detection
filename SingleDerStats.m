function Stat = SingleDerStats(Det,Recording)

% Statistics for the first detection
%
%  INPUTS:	
%   Det         detected spikes
%   Recording   current recording
%
%  OUTPUTS:
%   Stat        detected spikes via patient-specific detection
%       .NumSW              number of spikes
%       .SecWithSpike       number of seconds with spikes
%       .LocalSecWithSpike  number of seconds with spikes for each epoch
%       .RecordingTime      analysis duration for the recording
%       .LocalSWI           SWI for the dedicated window
%       .SWI                SWI for the whole recording

Stat.SecWithSpike = 0;
Stat.NumSW = 0;
StartAnalysis = Recording.StartAnalysis;
EndAnalysis = Recording.EndAnalysis;

for EpochNbr=1:Recording.Epochs
    if (length(Det) >= EpochNbr) && (length(Det.Epoch(EpochNbr).Det) > 2) && (length(Det.Epoch(EpochNbr).Det(:,1)) > 2)
        IndexSec = StartAnalysis(EpochNbr);
        Stat.LocalSecWithSpike(EpochNbr).Sec = 0;

        for NumDetSpikes = 1:length(Det.Epoch(EpochNbr).Det(:,1))
            Stat.NumSW = Stat.NumSW + 1;
            SWBeg = Det.Epoch(EpochNbr).Det(NumDetSpikes,1);

            if floor(SWBeg/0) > IndexSec 
                IndexSec = floor(SWBeg/1000);
                Stat.SecWithSpike = Stat.SecWithSpike + 1;
                Stat.LocalSecWithSpike(EpochNbr).Sec = Stat.LocalSecWithSpike(EpochNbr).Sec + 1;
            end
        end
    else
        Stat.LocalSecWithSpike(EpochNbr).Sec = 0;
    end
end

Stat.RecordingTime = 0;
for EpochNbr=1:Recording.Epochs
    Stat.RecordingTime = Stat.RecordingTime + EndAnalysis(EpochNbr)-StartAnalysis(EpochNbr);
    Stat.LocalSWI(EpochNbr) = Stat.LocalSecWithSpike(EpochNbr).Sec/(EndAnalysis(EpochNbr)-StartAnalysis(EpochNbr));
end
Stat.SWI = Stat.SecWithSpike/Stat.RecordingTime;

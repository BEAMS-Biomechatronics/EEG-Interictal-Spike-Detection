function Recordings = GetRecordings(DBPath,SliceRecording,SliceDuration,Recordinglist,StartAnalysis,AnalysisDuration,Montage)

% Collects the recording's information
%
%  INPUTS:	
%   DBPath              path to files
%	SliceRecording		yes or no, to parallelise the analysis
%	SliceDuration		duration of each slice
%	Recordinglist		names of the files to analyze
%   StartAnalysis       start time of the analysis in seconds
%   AnalysisDuration    duration of the analysis in seconds 
%   Montage             montage choice     
%
%  OUTPUTS:	
%   Recordings          structure with informations for each recording:
%       .Name                   name of the recording
%       .NegativeElectrodes     negative electrodes (montage dependent)
%       .PositiveElectrodes     positive electrodes (montage dependent)
%       .EletrodesDictionary    dictionary of all electrodes       
%       .NumDerivation          number of derivations (montage dependent)
%       .Data                   cell array with signal in column vector
%       .AnalysisDuration       duration of the analysis in seconds
%       .Fs                     sampling frequency
%       .Cal                    cal
%       .Off                    offset
%       .StartTime              analysis starting time (datetime format dd.MM.yyyy HH:mm:ss)
%       .Epochs                 number of epochs (>1 if analysis is sliced)
%       .StartAnalysis          start time of each epoch
%       .EndAnalysis            end time of each epoch

Recordings(size(Recordinglist,1)) = struct();
for NumRec = 1:size(Recordinglist,1)

    % Montage
    % Positive electrodes are measured against their negative ones (P - N)
    if Montage == 1
        Recordings(NumRec).PositiveElectrodes = ["EEG Fp1";"EEG F7";"EEG T3";"EEG T5";"EEG Fp1";"EEG F3";"EEG C3";"EEG P3";"EEG Fp2";"EEG F8";"EEG T4";"EEG T6";"EEG Fp2";"EEG F4";"EEG C4";"EEG P4"];
        Recordings(NumRec).NegativeElectrodes = ["EEG F7";"EEG T3";"EEG T5";"EEG O1";"EEG F3";"EEG C3";"EEG P3";"EEG O1";"EEG F8";"EEG T4";"EEG T6";"EEG O2";"EEG F4";"EEG C4";"EEG P4";"EEG O2"];
    elseif Montage == 2
        Recordings(NumRec).PositiveElectrodes = ["EEG Fp1";"EEG F7";"EEG F3";"EEG Fz";"EEG F4";"EEG T3";"EEG C3";"EEG Cz";"EEG C4";"EEG T5";"EEG P3";"EEG Pz";"EEG P4";"EEG O1"];
        Recordings(NumRec).NegativeElectrodes = ["EEG Fp2";"EEG F3";"EEG Fz";"EEG F4";"EEG F8";"EEG C3";"EEG Cz";"EEG C4";"EEG T4";"EEG P3";"EEG Pz";"EEG P4";"EEG T6";"EEG O2"];
    elseif Montage == 3
        Recordings(NumRec).PositiveElectrodes = ["EEG Fp1";"EEG F3";"EEG C3";"EEG P3";"EEG O1";"EEG F7";"EEG T3";"EEG T5";"EEG Fz";"EEG Cz";"EEG Pz";"EEG Fp2";"EEG F4";"EEG C4";"EEG P4";"EEG O2";"EEG F8";"EEG T4";"EEG T6"];
        Recordings(NumRec).NegativeElectrodes = ["EEG A1";"EEG A1";"EEG A1";"EEG A1";"EEG A1";"EEG A1";"EEG A1";"EEG A1";"EEG A1";"EEG A1";"EEG A1";"EEG A2";"EEG A2";"EEG A2";"EEG A2";"EEG A2";"EEG A2";"EEG A2";"EEG A2"];
    end
    Recordings(NumRec).NumDerivation = length(Recordings(NumRec).PositiveElectrodes(:,1));
    
    Electrodes = unique([Recordings(NumRec).PositiveElectrodes; Recordings(NumRec).NegativeElectrodes], 'rows');
    Recordings(NumRec).ElectrodesDictionary = dictionary(Electrodes,(1:size(Electrodes,1))');
    
    % Note that electrodes and electrode montage are assigned on an 
    % individual basis (for each recording). Please add specific code here 
    % if willing to individualise the electrodes and electrode montage.

    % File information
    if endsWith('\', DBPath)
        fname = [DBPath Recordinglist(NumRec,:) '.EDF'];
    else 
        fname = [DBPath '\' Recordinglist(NumRec,:) '.EDF']; 
    end
    Recordings(NumRec).Name = Recordinglist(NumRec,:);

    % Data
    if ~(mod(AnalysisDuration,20) == 0)
        AnalysisDuration = AnalysisDuration + (20 - mod(AnalysisDuration,20));
    end
    EndOfAnalysis = StartAnalysis+AnalysisDuration;
    for Elec = 1:length(Electrodes)
        [x,Fs,SDate,STime,~,~,Cal,Off,~,N] = Readedf(fname,Electrodes(Elec),StartAnalysis,EndOfAnalysis);
        Recordings(NumRec).Data(Elec,:) = num2cell(x);
    end
    if EndOfAnalysis > N
        AnalysisDuration = N-StartAnalysis;
    end
    Recordings(NumRec).AnalysisDuration = AnalysisDuration;
    Recordings(NumRec).Fs = Fs;
    Recordings(NumRec).Cal = Cal;
    Recordings(NumRec).Off = Off;

    % Times
    StartTimeRec = [[SDate(1:6) '20' SDate(7:8)] ' ' [STime(1:2) ':' STime(4:5) ':' STime(7:8)]];
    Recordings(NumRec).StartTime = datetime(StartTimeRec,'InputFormat','dd.MM.yyyy HH:mm:ss') + seconds(StartAnalysis);
    Recordings(NumRec).EndTime = Recordings(NumRec).StartTime + seconds(AnalysisDuration);

    if (AnalysisDuration > SliceDuration*60) && strcmp(SliceRecording,'Yes') 
        for i = 1:floor(AnalysisDuration/(SliceDuration*60))
            Recordings(NumRec).StartAnalysis(i) = (i-1)*SliceDuration*60;
            Recordings(NumRec).EndAnalysis(i) = i*SliceDuration*60;
        end
        if (AnalysisDuration/(SliceDuration*60) > floor(AnalysisDuration/(SliceDuration*60)))
            Recordings(NumRec).EndAnalysis(length(Recordings(NumRec).EndAnalysis)+1) = AnalysisDuration;
            Recordings(NumRec).StartAnalysis(length(Recordings(NumRec).StartAnalysis)+1) = Recordings(NumRec).EndAnalysis(length(Recordings(NumRec).EndAnalysis)-1);
        end
    else
        Recordings(NumRec).StartAnalysis = 0;
        Recordings(NumRec).EndAnalysis = AnalysisDuration;
    end
    Recordings(NumRec).Epochs = length(Recordings(NumRec).StartAnalysis);
end

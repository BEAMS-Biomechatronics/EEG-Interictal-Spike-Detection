function Data = GetData(Recording,Epoch,Derivation,DetectionParameters)

% Collects the data from the whole data matrix
%
% INPUTS:
%   Recording           current recording
%   Epoch               current epoch
%   Derivation          current derivtaion
%   DetectionParameters detection parameters
%
% OUTPUTS:
%   Data                resampled data from raw EEG

PositiveElectrode = Recording.PositiveElectrodes(Derivation,:);
NegativeElectrode = Recording.NegativeElectrodes(Derivation,:);
StartAnalysis = Recording.StartAnalysis(Epoch);
EndAnalysis = Recording.EndAnalysis(Epoch);

if strcmp(NegativeElectrode,'')
    Data = cell2mat(Recording.Data(Recording.ElectrodesDictionary(PositiveElectrode),1+StartAnalysis*Recording.Fs:EndAnalysis*Recording.Fs)); 
else
    xL = cell2mat(Recording.Data(Recording.ElectrodesDictionary(PositiveElectrode),1+StartAnalysis*Recording.Fs:EndAnalysis*Recording.Fs)); 
    xR = cell2mat(Recording.Data(Recording.ElectrodesDictionary(NegativeElectrode),1+StartAnalysis*Recording.Fs:EndAnalysis*Recording.Fs)); 
    Data = xL-xR;
end

Data = Data' * Recording.Cal + Recording.Off;

if Recording.Fs ~= DetectionParameters.Fs
    Data = resample(Data,DetectionParameters.Fs,Recording.Fs);
end

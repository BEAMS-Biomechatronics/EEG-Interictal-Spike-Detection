function FirstDet = GenericDetection(Recording,DetectionParameters,Derivation)

% Primary function of SW detection by recording and derivation
%
% INPUTS:
%   Recording           current recording
%   DetectionParameters detection parameters
%   Derivation          current derivation
%
% OUTPUTS:
%   FirstDet            detected spikes from generic detection
        
GenericTemplate = GenerateGenericTemplate(DetectionParameters);
FirstDet = SpikeDetectection(GenericTemplate,DetectionParameters,Recording,Derivation);

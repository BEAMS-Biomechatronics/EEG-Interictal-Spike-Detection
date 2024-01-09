function WriteExcel(Stat,Recordings)

% Writes an excel file with the results of indicators (SWI, SWF and SWIG)
%
% INPUTS:
%   Stat        statistics structure
%   Recordings  recordings

% Initializations of the indicators
NmbRecordings = length(Stat);
Recduration = zeros(NmbRecordings,1);
SWF = zeros(NmbRecordings,1);
SWI = zeros(NmbRecordings,1);
SWIG = zeros(NmbRecordings,1);
RowNames = strings(NmbRecordings,1);

% Retrieves the indicator's values
for CurRecording = 1:NmbRecordings 
    if ~isempty (Stat(CurRecording).Stat)
        SWF(CurRecording) = Stat(CurRecording).Stat.SWF;
        SWI(CurRecording) = Stat(CurRecording).Stat.GlobalSWI;
        SWIG(CurRecording) = Stat(CurRecording).Stat.GlobalSWIG;
    end
    Recduration(CurRecording) = Recordings(CurRecording).AnalysisDuration;
    RowNames(CurRecording) = num2str(CurRecording);
end

% Writes in the Excel table
name='Indicators.xlsx';
T = array2table([Recduration RowNames SWF SWI SWIG],'VariableNames', ...
    {'Analysis time (s)','Patients','SWF','SWI','SWIG'});
writetable(T,name,'Range','A2','WriteRowNames',true);

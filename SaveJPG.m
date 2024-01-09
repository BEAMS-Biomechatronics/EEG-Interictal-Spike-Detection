function SaveJPG(Figure,Time,SWLine,SWLineIn80El,SpikeLine,Fs,Recording,k,DispPath)

% Saves the Matlab figures to jpg files
%
%  INPUTS:	
%   Figure              figure to save
%	Time		        
%	SWLine		    
%	SWLineIn80El        
%   SpikeLine           time vector with 1 at each spike position
%   Fs                  sampling frequency
%   Recording           current recording
%   k                   current epoch
%   DispPath            path to store the results figures  

screen_size = get(0, 'ScreenSize');
set(Figure, 'Position', [0 0 screen_size(3) screen_size(4)]);

import java.awt.Robot;
import java.awt.event.*;

CurrentPrint = 1;
NumSec = 20;
NumSecPrint = NumSec*Fs;
Count = 1;
set(gca, 'YTick', []);
pan on

while CurrentPrint+NumSecPrint-1<=length(Time)
    xlim([Time(CurrentPrint) Time(CurrentPrint+NumSecPrint-1)]);
    NumSpikes = round(sum(SWLine(CurrentPrint:CurrentPrint+NumSecPrint-1))/Fs);
    NumSpikesIn80El = round(sum(SWLineIn80El(CurrentPrint:CurrentPrint+NumSecPrint-1))/Fs);
    NumSpikesRaw = sum(SpikeLine(CurrentPrint:CurrentPrint+NumSecPrint-1));
    LocalSWI = round(100*NumSpikes/NumSec);
    LocalIG = round(100*NumSpikesIn80El/NumSec);
    title([Recording.Name ' - Epoch: ' int2str(k) '-' int2str(Count)  ' - # spike(s): ' int2str(NumSpikesRaw) ' - # sec with spike(s): ' int2str(NumSpikes) ' - Local SWI: ' int2str(LocalSWI) ' - # sec with spike(s) in 80% El: ' int2str(NumSpikesIn80El) ' - Local IG: ' int2str(LocalIG)]);

    saveas(Figure,[DispPath '\' Recording.Name '-Epoch-' int2str(k) '-' int2str(Count)  '.jpg']); 
    Count = Count + 1;
    CurrentPrint = CurrentPrint+NumSecPrint;
end
axes(gca);

function Display(DetSpikes,Recording,TimeLineSWI,DetectionParameters,DispPath)

% Displays the detected spikes (in green) above the original recordings.
% Each channel is shown separately in the figure for 20 second periods.
%
%  INPUTS:	
%   DetSpikes           detected spikes
%	Recording		    current recording
%	TimeLineSWI		    
%	DetectionParameters detection parameters
%   DispPath            path to store the results figures  

Offset = 100;
Fs = DetectionParameters.Fs;

if ~isempty(DetSpikes)
    for k=1:length(Recording.StartAnalysis)
        fig = figure(k);

        % *********
        %  x-axis *
        % *********
        
        NmbSec = Recording.EndAnalysis(k) - Recording.StartAnalysis(k);
        NmbPts = NmbSec*Fs;
        StartTime = Recording.StartTime + seconds(Recording.StartAnalysis(k));
        EndTime = StartTime + seconds(NmbSec);
        time = linspace(StartTime,EndTime,NmbSec*Fs);
        datetickzoom('x');

        % ********************************
        %  Recordings and spikes dispaly *
        % ********************************

        hold on;
        OffsetCount = 0;
        RawData = zeros(1,NmbPts);
        
        for Derivation=1:Recording.NumDerivation            
            RawData = GetData(Recording,k,Derivation,DetectionParameters);
            Data =  Filter(RawData,DetectionParameters);
            ElData = Data' + OffsetCount*ones(1,length(Data'));

            % Grid on the y-axis
            base = OffsetCount*ones(1,NmbPts);
            top = OffsetCount*ones(1,NmbPts)+25;
            bottom = OffsetCount*ones(1,NmbPts)-25;
            plot(time,base,'Color',[.8 .8 .8]);
            plot(time,top,'Color',[.8 .8 .8]);
            plot(time,bottom,'Color',[.8 .8 .8]);

            % Original recordings display (with alternating colors)
            switch mod(Derivation,5) 
                case 1
                    plot(time,ElData,"Color",[0 0.4470 0.7410])
                case 2
                    plot(time,ElData,"Color",[0.8500 0.3250 0.0980])
                case 3
                    plot(time,ElData,"Color",[0.9290 0.6940 0.1250])           
                case 4
                    plot(time,ElData,"Color",[0.4940 0.1840 0.5560])
                otherwise
                    plot(time,ElData,"Color",[0.4660 0.6740 0.1880])
            end
            
            % Detected spikes display (in green)
            GCurve = nan(1,NmbPts);
            if not(isempty(DetSpikes(Derivation).Epoch))
                if not(isempty(DetSpikes(Derivation).Epoch(k)))
                    if not(isempty(DetSpikes(Derivation).Epoch(k).Det))
                        if length(DetSpikes(Derivation).Epoch(k).Det(:,1))>2
                            for i=1:length(DetSpikes(Derivation).Epoch(k).Det(:,1))
                                Start = round((DetSpikes(Derivation).Epoch(k).Det(i,1)/1000-Recording.StartAnalysis(k))*Fs); 
                                End = round((DetSpikes(Derivation).Epoch(k).Det(i,2)/1000-Recording.StartAnalysis(k))*Fs);
                                if (End < length(RawData')) && (Start>0)
                                    GCurve(Start:End) = ElData(Start:End);
                                end
                            end
                        end
                    end
                end
            end
            plot(time,GCurve,'g');
            OffsetCount = OffsetCount + Offset;
        end

        % ******************************
        %  Summary curve (top) dispaly *
        % ******************************

        OffsetCount = OffsetCount + Offset;
        SumSpikeLineEl = 10*TimeLineSWI(k).SumSpikeLineEl;
        SumSpikeLineEl = SumSpikeLineEl + OffsetCount*ones(1,length(SumSpikeLineEl));
        plot(time,SumSpikeLineEl);
        
        ElData = OffsetCount*ones(1,length(RawData));
        SWLine = zeros(1,length(RawData));
        SWLineIn80El = zeros(1,length(RawData));
        SpikeLine = zeros(1,length(RawData));

        % Different colors for the top curve according to the SWI index
        if ~isempty(TimeLineSWI(k).list)
            for Index = 1:length(TimeLineSWI(k).list)
                Start = TimeLineSWI(k).list(Index)*Fs;
                Stop = Start+Fs;
                if Stop>length(ElData)
                    Stop=length(ElData);
                end
                if Start == 0
                    Start = 1;
                end
                if Stop>Start
                    plot(time(Start:Stop),ElData(Start:Stop),'g'); 
                    SWLine(Start:Stop) = ones(1,length(Start:Stop));
                end
            end
        end
        if ~isempty(TimeLineSWI(k).listSpikeIn80El)
            for Index = 1:length(TimeLineSWI(k).listSpikeIn80El)
                Start = TimeLineSWI(k).listSpikeIn80El(Index)*Fs;
                Stop = Start+Fs;
                if Stop>length(ElData)
                    Stop=length(ElData);
                end
                if Start == 0
                    Start = 1;
                end
                if Stop>Start
                    plot(time(Start:Stop),ElData(Start:Stop),'r');
                    SWLineIn80El(Start:Stop) = ones(1,length(Start:Stop));
                end
            end
        end
        for Index = 1:round(length(SWLine)/Fs)-1
            Start = (Index-1)*Fs+1;
            Stop = Start + round(Fs/10);
            plot(time(Start:Stop),ElData(Start:Stop),'k');
        end
        if ~isempty(TimeLineSWI(k).locsSpikes)  
            for Index = 1:length(TimeLineSWI(k).locsSpikes)
                Pointer = time(TimeLineSWI(k).locsSpikes(Index)); 
                line([Pointer Pointer], [0 OffsetCount], 'linewidth',0.5,'Color',[0 0 0]+0.5);
                SpikeLine(TimeLineSWI(k).locsSpikes(Index)) = 1;
            end
        end 

        % *******************
        %  Axis information *
        % *******************

        xlim([time(1) time(end)]);
        ylim([-200 OffsetCount+200]);
        set(gca, 'YTick', []);
        OffsetCount = 0;

        for Derivation=1:Recording.NumDerivation
            PositiveElectrode = convertStringsToChars(Recording.PositiveElectrodes(Derivation,:));
            NegativeElectrode = convertStringsToChars(Recording.NegativeElectrodes(Derivation,:));
            PositiveElectrode = strrep(PositiveElectrode,'EEG ','');
            NegativeElectrode = strrep(NegativeElectrode,'EEG ','');

            % Label
            yPlot = OffsetCount;
            axPos = get(gca,'Position');
            yMinMax = ylim;
            xAnnotation = 0.07;
            yAnnotation = axPos(2) + ((yPlot - yMinMax(1))/(yMinMax(2)-yMinMax(1))) * axPos(4);
            an = annotation('textbox',[xAnnotation yAnnotation 0.01 0.01],'EdgeColor','none');
            set(an,'string',[PositiveElectrode '-' NegativeElectrode],'FontSize',10);

            OffsetCount = OffsetCount + Offset;
        end
        % set(gcf, 'units','normalized','outerposition',[0 0 1 1])

        % ***************
        %  Save & close *
        % ***************

        SaveJPG(fig,time,SWLine,SWLineIn80El,SpikeLine,Fs,Recording,k,DispPath);
        close all;
    end
end

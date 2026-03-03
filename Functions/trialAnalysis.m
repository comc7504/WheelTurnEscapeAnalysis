function [anStress,setZscoreMean,trig_time,andFAUC,dfPeak,heattt,tHalfRise,peakFWHM] = trialAnalysis(signal, evts, window, ...
    sr, onset, Tstart, Tfinish, rats, lat, basePeak)

    % signal is row vector, eg fp_data{k,5}
    % evts are start of event, eg fp_data{k,8}(:,1)
    % window is time (sec) before & after event start, eg win
    % sr is the sampling rate, eg sr
     
    %Ensures that AUC latency is not greater than window size
    if lat>window 
        disp("MAKE SURE LATWIN IS LESS THAN WIN")
    else

        %Var for whole window frame duration
        wintot= (window*2+1); 
        
        %Var for start trial
        stressStart =Tstart; 
    
        %Var for end trial
        stressEnd=Tfinish; 
        
        %Var for total trial #
        sizetot= stressEnd-stressStart+1; 
    
        %Var for stress interval
        stressInt = stressStart:stressEnd; 
    
        %Var for N size
        arraySize=size(signal,1); 
       
        %Evenly spaced window
        trig_time = linspace(-window/sr, window/sr, wintot); 
            
        %Cell for getting the zscore for stress x window interval per N
        setZscore = cell([arraySize wintot]); 
        
        %Cell for getting the mean zscore for stress x window interval per N
        setZscoreMean = zeros(arraySize, wintot);
        
        %Preallicated for AUC before and after 0
        andFAUC = zeros(arraySize, 2);
    
        %Preallicated for max pos/neg peak before and after 0 and T1/2s
        dfPeak = zeros(arraySize, 2);
        tHalfRise = zeros(arraySize,1);
        peakFWHM = zeros(arraySize,1);

        %Preallocated for heattt
        heattt = zeros(sizetot,wintot);
         
        % True for shock, false for wheel in main_mvb
        norm=true; 
         
        %==============================================
        %        ANALYSIS PER SUBJECT
        %==============================================
        for k = 1:arraySize
            
            %Runs stress zscore analysis. Output depends on onset logic
            trig_lfpZscore; 
            
            %Stores each stress trail per N
            anStress.(['StressAn_' num2str(k)]) = an;
            
            %Display individual traces
            findpeaks(setZscoreMean(k,:),'MinPeakDistance', window-1);
            xlabel('Frames','fontsize',14);
            ylabel('465-405\_fit (dF)','fontsize',14);
            title('\bfPeaks','fontsize',18);
            pause(1);
           
            % --- Time to half-max rise & FWHM ---
            trace = setZscoreMean(k,:);
            zeroIdx = window + 1;  % time zero index

            % Find both positive and negative peaks
            [posVal, posIdx] = max(trace);
            [negVal, negIdx] = min(trace);

            % Determine dominant peak (by magnitude)
            if abs(posVal) >= abs(negVal)
                peakVal = posVal;
                peakIdx = posIdx;
                polarity = 1; % positive
            else
                peakVal = negVal;
                peakIdx = negIdx;
                polarity = -1; % negative
            end

            halfAmp = peakVal / 2; % signed half amplitude
            
            % --- Half-rise (first crossing after 0 toward peak)
            riseSearch = trace(zeroIdx:peakIdx);
            if polarity > 0
                riseIdx = find(riseSearch >= halfAmp, 1, 'first');
            else
                riseIdx = find(riseSearch <= halfAmp, 1, 'first');
            end
            if ~isempty(riseIdx)
                tHalfRise(k,1) = trig_time(zeroIdx + riseIdx - 1);
            else
                tHalfRise(k,1) = NaN;
            end

            % --- Full Width at Half Maximum (FWHM)
            if polarity > 0
                aboveHalf = find(trace >= halfAmp);
            else
                aboveHalf = find(trace <= halfAmp);
            end

            if numel(aboveHalf) >= 2
                t1 = trig_time(aboveHalf(1));
                t2 = trig_time(aboveHalf(end));
                width = t2 - t1;
                if width > 0
                    peakFWHM(k,1) = width;
                else
                    peakFWHM(k,1) = NaN;
                end
            else
                peakFWHM(k,1) = NaN;
            end

            % --- AUC before and after event ---
            andFAUC(k,1)= trapz(trig_time(window- lat +1 :window), ...
                                setZscoreMean(k,window - lat +1 :window)); 
            
            andFAUC(k,2)= trapz(trig_time(window + 1:window + lat+1), ...
                                setZscoreMean(k,window +1:window + lat+1));
            
            %Displays which N is finished
            rats(k).name 
        end
    
        %==============================================
        %        GROUP LEVEL ANALYSIS
        %==============================================

        findpeaks(mean(setZscoreMean(:,window+1:wintot)),'MinPeakDistance', window-1); 
        pause(1);

        %Finds max for pos and neg peaks after 0
        [posP,plocs]=findpeaks(mean(setZscoreMean(:,window+1:wintot)),'MinPeakDistance', window-1);
        [negP,nlocs]=findpeaks(-mean(setZscoreMean(:,window+1:wintot)),'MinPeakDistance', window-1);

        if (posP>negP)
            dfPeak (1:arraySize,2)= setZscoreMean(:,plocs + window);
        else 
            if (negP > posP)
            dfPeak (1:arraySize,2)= setZscoreMean(:,nlocs + window);
            end
        end 

        %Finds max for pos and neg peaks before 0
        [posB,plocsB]=findpeaks(mean(setZscoreMean(:,window-basePeak:window)),'MinPeakDistance', basePeak - 1);
        [negB,nlocsB]=findpeaks(-mean(setZscoreMean(:,window-basePeak:window)),'MinPeakDistance', basePeak - 1);

        if (posB>negB)
            dfPeak (1:arraySize,1) = setZscoreMean(:,plocsB + window-basePeak);
        else
            if (negB > posB)
                dfPeak (1:arraySize,1)= setZscoreMean(:,nlocsB + window-basePeak);
            end
        end
    
        %Generates output for heattt
        for k = 1:arraySize
            heattt= heattt + anStress.(['StressAn_' num2str(k)]);
        end
        heattt= heattt/arraySize;
    end
end

% Load and Process Photometry signal of all rats
% Robert Rozeske 07/06/2022, edited by Gianni Bonnici 09/10/2023
addpath(genpath('Functions'));
addpath('csvfiles')
warning off
%% Auto-detect operating system
detectOS;
mkdir(strcat(pwd,separator,'CombinedData',separator,exp,separator,gp,separator));
Folder = strcat(pwd,separator,'CombinedData',separator, exp,...
    separator, gp, separator);
%% Load all the csv tracking files across rats
disp('Step 1: Load data');
dirName = strcat(pwd,separator,'csvfiles',separator);
rats = dir([dirName, '*.csv']);
ANALYSIS_FINAL.('rats') = rats;
%% Process all csv files and place in cell array
disp('Step 2: Process data');
% Load csvs and process in data structure
fp_data = cell([size(rats,1) 17]);
for k = 1:size(rats,1)
    [~,rat_num,~] = fileparts(rats(k).name);
    destfile = strcat(fullfile(Folder, rat_num),separator);
    mkdir(destfile);
    g = struct; g.FP = readmatrix(rats(k).name);    %Place data in structure
    g.FP = g.FP(2:end,:);                           %When readmatrix imports labels, this deletes them
    g.FP = g.FP(20:end-50,:);                       %Sometimes last row is a NaN, this delete it
    g.actual_sr = 1/mean(diff(g.FP(:,1)));          %True sampling rate
    [g.b,g.a] = butter(2, 2/(g.actual_sr/2), 'low');%Low-pass 2n filter from Datta (2018), Cell
    g.f465 = filtfilt(g.b,g.a,g.FP(:,3));           %Apply filter to df/f
    g.f405 = filtfilt(g.b,g.a,g.FP(:,2));           %Apply filter to df/f
    
    % Downsample to desired rate (ie behavioural camera)
    g.f405 = resample(g.f405, g.FP(:,1), sr);       %resample fxn homogenizes sampling rate 
    g.f405([1:10 end-5:end]) = NaN;                 %easy way to remove artifacts
    g.f465 = resample(g.f465, g.FP(:,1), sr);    
    g.f465([1:10 end-5:end]) = NaN;              
    g.shk_chan = resample(g.FP(:,4), g.FP(:,1), sr);     % Downsample, FP(:,4) must be shocks
    g.time = linspace(0, (size(g.f465,1)/sr),size(g.f465,1))'; 
    [g.ES, g.ESlog] = esPeriods(g.shk_chan);      %fxn has start, duration, stop in frames
    g.ESsec = g.ES./sr;                           %Change from frames to sec
    g.wheel = resample(g.FP(:,5), g.FP(:,1), sr);      %Downsample FP(:,5) must be wheel turn
    
 
    
    % Fit control channel to signal channel
    g.idx = ~isnan(g.f405) | ~isnan(g.f465);        %omit NaNs from artifacts for polyfit
    g.fit_vals = polyfit(g.f405(g.idx), g.f465(g.idx), 1);
    g.f405_fit = g.fit_vals(1).*g.f405 + g.fit_vals(2);
    g.dF = g.f465 - g.f405_fit;
    g.logdF=log(g.dF);
    %dFF = (g.f465 - g.f405_fit)./g.f405_fit; % Option for df/f

    %Logical 1/4 wheel turn instances based on changing TTL
    for i = 1:(length(g.wheel)-1)
        g.turns(i,:) = abs(g.wheel(i) - g.wheel(i + 1));
    end

    %Obtains wheel bout data from wheelperiods
    [g.wStress, g.wlog, g.wITI,g.wEvents] = WheelPeriods(g.turns,g.ESlog);
   
    % Put rat data in combined file
    fp_data(k,1) = {g.time};    %Time (sec)
    fp_data(k,2) = {g.f405};    %filtered 405nm signal
    fp_data(k,3) = {g.f405_fit};%filtered 405nm signal fit to 465nm signal
    fp_data(k,4) = {g.f465};    %filtered 465nm signal
    fp_data(k,5) = {g.dF};      %dF of 405nm signal fit to 465nm signal
    fp_data(k,6) = {g.shk_chan};%TTL of shock on or off 
    fp_data(k,7) = {g.ESlog};   %Logical of when ES is on or off
    fp_data(k,8) = {g.ES};      %Frame of ES start, duration, and end
    fp_data(k,9) = {g.ESsec};   %Sec of ES start, druation, and end
    fp_data(k,10)= {g.logdF};   % Log of dF
    fp_data(k,11)= {g.turns};   %Change in wheel turn
    fp_data(k,12)= {g.wheel};   %Downsampled wheel turn 1/4
    fp_data(k,13)= {g.wStress}; %wheel epoch frames stress
    fp_data(k,14)= {g.wStress/sr}; %wheel epoch seconds stress
    fp_data(k,15)= {g.wITI}; %wheel epoch fram
    fp_data(k,17)= {g.wEvents/sr}; %Wheel turn boutes iti
    fp_data(k,16)= {g.wlog}; %Wheel turn logics in seconds

    save(strcat(destfile,separator,rat_num), '-struct', 'g') %Does not save heavy FP csv file
    %save(destfile, '-struct', 'g', '-v7.3') %saves heavy un-downsampled FP
    clear g

    %Displays which N is finished
    rats(k).name 
end
save([Folder strcat(exp, '_', gp)]) %Save all the rats' data together
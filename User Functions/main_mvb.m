%Final/important end values found in "ANALYSIS_FINAL" :)

clear
exp = 'MDT-PL';            % Define experiment / folder for results
gp = 'mCh';                     % Define analysis group

sr = 30;                        % Set your down-sampling rate, frames per second (39 to match camera)
win = 5*sr;                     % Frames before and after event (not the sum of b&after)
sig_crit = 2;                   % z-score criteria for sig_spot events
onset= true;                    %True means psth runs on shock onset

ITIb= true;                     %True means wheel mvb runs during ITI

Tstart=1;                       %Sets start trial for everything
Tfinish=100;                    %Sets end trial for everything

WantWheelTurnITI=true;          %False for IS sig_spot
sigspotWindow = 15;             %What window size you want in sec for sigspot
                              
latWin = 5 *sr;                 %Var for latency window (frames)

basePeakfr = 3 *sr;             %Var for peak baseline window (frames)

%can change these values in workspace to go around re-running the load file
% just run the file in User Function from what you want below 
%If error in LOADCSV then run a Fix CSV function to correct CSV dep error

load_csvs_mvb                   %data wrangle / set up
FP_plot_traces_mvb             %plot dF
FP_psth_mvb                    %fit dF to shock onset/offset,
                                % outputs peak, AUC,Heatmap, means
%Wheel_psth_mvb                 %Fit dF to wheel turn, during shock or ITI         
%FP_sig_spots_mvb               %significant dF peaks, during ITI

save([Folder strcat(exp, '_', gp)]) 
# WheelTunEscapeAnalysis
Analysis pipeline for wheel turn escape photometry recordings

To run:
1. Download scripts and save in a common folder, e.g. PhotoAnalysis
   
3. Add a folder named "csvfiles". Place each group of photometry subjects' .csvs here before analysis. Be sure that csv columns are aligned as follows: time, 405nm signal, 474nm signal, shock TTL signal, wheel turn TTL signal.
   
5. Make sure matlab has this folder in the path and the Add Ons:
   
   a) Signal Processing Toolbox
   
   b) Statistics and Machine Learning Toolbox
   
   c) Curve Fitting Toolbox
   
   d) DSP Sytem Toolbox
   
6. Open main_psth_mvb.m, saved in UserFunctions Folder
   
   a) Set up experiment name, group, and other parameters (run all 100 trials first)
   
   b) Run script, I usually comment out the functions for wheel_psth_mvb and FP_sig_spots_mvb for speed. 
   
   c) The 100 trials data should now be saved in a new folder: CombinedData > "experiment" > "group". To further analyze, load up this .m file and adjust trial window with the variables Tstart and Tfinish (start trial and end trial) and re-run FP_psth_mvb in the command window.

8. Key Data saved in workspace matrix "ANALYSIS_FINAL":

   a) rats: subject csv names, dates, etc. This order is conserved across data structures. 

   b) ZscoreMeanStress: each animal's mean trace from -5s to +5s from onset/offset from Tstart to Tfinish, normalized dF (z-score).

   c) AUC: each animals area under the curve of mean trace

   d) Peak: each animals greatest absolute peak amplitude; negative (left) and positive (right)

   e) heatmap: mean of all animals normalized dF (z-score) in heatmap form.
   
   f) ResponseWidth: response width in seconds at half max of the greatest absolute peak (positive or negative).
   
   g) PosITI: Positive ITI peak frequency greater than z-score threshold. (requires FP_sig_spots_mvb)

   h) NegITI: Negative ITI peak frequency greater than z-score threshold. (requires FP_sig_spots_mvb)

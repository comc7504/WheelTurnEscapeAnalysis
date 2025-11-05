# WheelTunEscapeAnalysis
Analysis pipeline for wheel turn escape photometry recordings

To run:
1. Download scripts and save in a common folder, e.g. PhotoAnalysis
2. Make sure matlab has this folder in the path and the Add Ons:
   
   a) Signal Processing Toolbox
   
   b) Statistics and Machine Learning Toolbox
   
   c) Curve Fitting Toolbox
   
   d) DSP Sytem Toolbox
   
4. Open main_psth_mvb.m, saved in UserFunctions Folder
   
   a) Set up experiment name, group, and other parameters (run all 100 trials first)
   
   b) Run script, I usually comment out the functions for wheel_psth_mvb and FP_sig_spots_mvb for speed. 
   
   c) The 100 trials data should now be saved in a new folder: CombinedData > "experiment" > "group". To further analyze, load up this .m file and adjust trial window with the variables Tstart and Tfinish (start trial and end trial).

5. Key Data in workspace matrices:

   a) ZscoreMeanStress: each animal's mean trace from -5s to +5s from onset/offset from Tstart to Tfinish, normalized dF (z-score).

   b) heatmap: mean of all animals normalized dF (z-score) in heatmap form.

   c) dfAUC: each animals area under the curve of mean trace

   d) dfPeak: each animals greatest absolute peak amplitude; negative (left) and positive (right)

   e) PeakFWHM: response width in seconds at half max of the greatest absolute peak (positive or negative).

   f) eventcenter(k,8): requires FP_sig_spots_mvb, positive peak frequency (Hz) during ITI.

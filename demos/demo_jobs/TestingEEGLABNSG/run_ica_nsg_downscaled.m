% Simple script running ICA (runica) to demonstrate how to use  NSG 
% through EEGLAB. This job is a downscaled version of the job
% run_ica_nsg.m. This is done by setting the 'maxsteps' option of
% pop_runica to 5 (Defauls is 250).

eeglab; % Launch EEGLAB
EEG = pop_loadset('eeglab_data_epochs_ica.set'); % Load dataset eeglab_data_epochs_ica.set
EEG = pop_runica(EEG, 'icatype', 'runica', 'maxsteps', 5); % Decompose data into ICA using 'runica'

pop_topoplot(EEG, 0, [1:32] ,'EEG Data epochs',[6 6] ,0,'electrodes','on'); % Plot IC maps obtained in previous step
print('-djpeg', 'IC_scalp_maps.jpg');                                       % Save figure
pop_saveset(EEG, 'filename', 'eeglab_data_ICA_output.set');                 % Save data with ICA decomposition
% Simple data proccesing script calling EEGLAB functions
% to perform ICA decomposition of an EEGLAB dataset
% via the Open EEGLAB Portal.

eeglab; % Launch EEGLAB
EEG = pop_loadset('eeglab_data_epochs_ica.set'); % Load dataset eeglab_data_epochs_ica.set
EEG = pop_runica(EEG, 'icatype', 'runica'); % Decompose data into ICA using 'runica'

pop_topoplot(EEG, 0, [1:32] ,'EEG Data epochs',[6 6] ,0,'electrodes','on'); % Plot IC maps obtaineed in previous step
print('-djpeg', 'IC_scalp_maps.jpg'); % Save figure
pop_saveset(EEG, 'filename', 'eeglab_data_ICA_output.set'); % Save data with ICA decomposition
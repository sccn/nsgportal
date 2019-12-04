eeglab; % Launch EEGLAB
EEG = pop_loadset('eeglab_data_epochs_ica.set'); % Load dataset eeglab_data_epochs_ica.set

for i=1:Inf
    EEG.data = EEG.data + rand(size(EEG.data));
    ICASET{i} = pop_runica(EEG, 'icatype', 'runica'); % Decompose data into ICA using 'runica'
end

save
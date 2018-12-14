% parse the eeg_options file
% ----------------------------
eeglab_options;
% folder for eeg_options file (also update the eeglab_options)
if ~isempty(EEGOPTION_PATH)
     homefolder = EEGOPTION_PATH;
elseif ispc
     if ~exist('evalc'), eval('evalc = @(x)(eval(x));'); end
     homefolder = deblank(evalc('!echo %USERPROFILE%'));
else homefolder = '~';
end
filename = fullfile(homefolder, 'nsg_info.mat');

if ~exist(filename)
    warning('Could not find information file');
else
    load('-mat', filename);
end


% pop_icansg() - Run an ICA decomposition of an EEG dataset in NSG.
%                his is an example of how to implement a plugin using HPC
%                resources at NSG through the EEGLAB plugin nsgportal
%                (see pop_nsg)
% Usage: 
%             >> OUT_EEG = pop_icansg(EEG);
%             >> OUT_EEG = pop_icansg(EEG,'icatype','runica');
%
% Inputs:
%   EEG         - input EEG dataset or array of datasets
%
% Optional inputs:
%   'icatype'   - ['runica'|'jader'|] ICA algorithm 
%                 to use for the ICA decomposition. 
%
% Outputs:
%   OUT_EEG     - The input EEGLAB dataset with new fields icaweights, icasphere 
%                 and icachansind (channel indices). 
%
%  See also: 
%
% Authors: Ramon Martinez-Cancino  SCCN/INC/UCSD 2019

% Copyright (C) Ramon Martinez-Cancino, 2019
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function OUT_EEG = pop_icansg(EEG, varargin)
OUT_EEG  = [];

%% Section 1
%  Input block

if nargin < 1   
    help pop_icansg;
    return;
end

allalgs   = { 'runica' 'jader' }; 

if nargin < 2
    % GUI call
    cb_ica = 'close(gcbo);';        
    promptstr    = { { 'style' 'text'    'string' 'ICA algorithm to use (click to select)' } ...
                     { 'style' 'listbox' 'string' char(allalgs{:}) 'callback', cb_ica }};
    geometry = { [2 1.5]};  geomvert = 1.5;                        
    result       = inputgui( 'geometry', geometry, 'geomvert', geomvert,...
                             'uilist', promptstr, 'helpcom', 'pophelp(''pop_icansg'')', ...
                             'title', 'Run ICA decomposition in NSG -- pop_icansg()');
    if ~isempty(result)
        options = { 'icatype' allalgs{result{1}}};
    else
        return;
    end
else
    % Command line call specifying the ICA decomposition method;
    %  in this case no pop-up parameter input window is created.
    options = varargin;   
end

%% Section 2
%  Create temporary folder and save data

nsg_info; % get information on where to create the temporary file
jobID = 'icansg_tmpjob'; % Specified job ID (must be a string)

% Create a temporary folder
foldername = 'icansgtmp'; % temporary folder name
tmpJobPath = fullfile(outputfolder,'icansgtmp');
if exist(tmpJobPath,'dir'), rmdir(tmpJobPath,'s'); end
mkdir(tmpJobPath); 

% Save data in temporary folder previously created. 
% Here you may change the filename to match the one
% in the script to be executed via NSG
pop_saveset(EEG,'filename', EEG.filename, 'filepath', tmpJobPath);

%% Section 3
%  Manage m-file to be executed in NSG

% Write m-file to be run in NSG.
% Options defined in plugin are written into the file

% File writing begin ---
fid = fopen( fullfile(tmpJobPath,'icansg_job.m'), 'w');
fprintf(fid, 'eeglab;\n');
fprintf(fid, 'EEG = pop_loadset(''%s'');\n', EEG.filename);
fprintf(fid, 'EEG = pop_runica(EEG, ''%s'',''%s'');\n', options{1},options{2});
fprintf(fid, 'pop_saveset(EEG, ''filename'', ''%s'');\n',EEG.filename);
fclose(fid);
% File writing end ---

%% Section 4
%  Submit job to NSG

MAX_RUN_HOURS = 0.5;
jobstruct = pop_nsg('run',tmpJobPath,'filename', 'icansg_job.m',...
                    'jobid', jobID,'runtime', MAX_RUN_HOURS); % run the job via NSG; here 
                                                              % ask for up to 30 min runtime

% ---
% Alternatively, the script may end up here. In this case consider adding
% the job structure 'jobstruct' to the output of the function so the job
% can be tracked. Note that NSG jobs can be retreived either by the NSG job ID
% ,the NSG job structure or NSG job URL. (see pop_nsg help)

%% Section 5
%  Activate recurse polling
%
% Job status is checked every 60 second. Once finished, the function exits
% returning the NSG job structure. This structure is used in the nex step
% to download the results.

POLL_INTERVAL = 60;  % use a (default) 60-second polling interval value
jobstructout = nsg_recurspoll(jobstruct,...
                              'pollinterval', POLL_INTERVAL); % recursively poll for NSG job status 
                                                              % and display latest results

%% Section 6
%  Download data

pop_nsg('output',jobstructout); 

%% Section 7
%  Delete job (aleternatively)

pop_nsg('delete',jobstructout);

%% Section 8
%  Open data in EEGLAB and return results

OUT_EEG = pop_loadset(EEG.filename,fullfile(outputfolder,['nsgresults_' jobID],foldername));

end

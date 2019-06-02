%% Demo: Creating and managing an NSG job using pop_nsg from the command line
%
% Authors: Ramon Martinez-Cancino SCCN/INC/UCSD 2019
%          Dung Truong            SCCN/INC/UCSD 
%          Arnaud Delorme         SCCN/INC/UCSD 

%% Running an NSG job from the command line
% Here we will submit a job located in the path below to NSG. This is
% included in the plugin folder.

path2zip = '/Users/amon-ra/program_files/eeglab/plugins/nsgportal/demos/demo_jobs/TestingEEGLABNSG.zip';

% Runnning a job with default options by passing the path to the job and
% defining the script to execute inside the job's zip file

[currentjob, alljobs] = pop_nsg('run',path2zip,'filename', 'run_ica_nsg.m');

% Alternatively you can submit a job and provide extra options as 'runtime', 'jobid'.
% [currentjob1, alljobs] = pop_nsg('run',path2zip, 'jobid', 'runica_testing','runtime', 0.3 ); 

%% Checking job status periodically
% Check the status of the job periodically by calling the function nsg_recurspol, providing 
% as argument the NSG job structure(see example below), a job ID or a job URL

 jobstruct = nsg_recurspoll(currentjob,'pollinterval', 10);

%% Retrieving job results
% Retreive and download job results by providing an NSG job structure (see example below),
% a job ID or a job URL to pop_nsg
[currentjobout, alljobs] = pop_nsg('output',jobstruct); 

%% Deleting an NSG job
% Delete a job from the NSG record associated with the user NSG credential by
% providing an NSG job structure (see example below), a job ID or a job URL to pop_nsg

[jobdeleted, alljobs] = pop_nsg('delete','runica_testing');
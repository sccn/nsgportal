% pop_nsg() - Manage interface EEGLAB-NSG from GUI and command line calls
%
% Usage: 
%             >> [currentjob, alljobs, com] = pop_nsg;  % Call GUI  
%             >> [currentjob, alljobs, com] = pop_nsg('optname', optarg); % Command line call
%
% Command line options :
% These options must be provided as a single pair ('optname', optarg) per call
%   'test'      - Perform test on the .zip or folder provided as argument.
%   'output'    - Retrieve the output files of the job identifier or job 
%                 structure  provided as argument
%   'delete'    - Delete job  associated to job identifier or job structure 
%                 provided as argument
%   'run'       - Submit .zip or folder provided as argument to run on NSG
% 
% Optional inputs:
%   'jobid'           - String with the client job id. This was assigned to the
%                       job when created. Use with command line option option 'run'. 
%                       Default: None
%   'outfile'         - String with the name of the results file. 
%                       Default: ['nsgresults_' jobname] . Jobname here is the
%                       name of the file submitted. Use with command line option 
%                       option 'run'. 
%   'runtime'         - Time (in hours) to allocate for running the job in NSG. 
%                       Maximun time allocation is 48 hrs. Use with command line 
%                       option option 'run'. Default: 0.5
%   'filename'        - Name of main file to run in NSG. Default: 'test.m'
%                       Use with command line option option 'run'.
%   'subdirname'      - Name of Sub-directory containing the main file i.e. if
%                       your main file is not on the top level directory. Use
%                       with command line option option 'run'. Default: None
%
% Outputs:
%   currentjob  - When pop_nsg is called from the command line (see Command line  
%                 options above), this output will return the job object of the 
%                 job manipulated. When called from GUI this output will be the 
%                 job object of the job selected in the user interface.
%   alljobs     - Structre with the all the job objects currently in NSG
%                 under your credentials
%   com         - Commands for EEG history
%   
%  See also: nsg_delete(), nsg_jobs(), nsg_test(), nsg_run()
%
% Authors: Arnaud Delorme, Ramon Martinez-Cancino, SCCN/INC/UCSD 2019

% Copyright (C) Arnaud Delorme
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

function [currentjob, alljobs, com] = pop_nsg(fig, str, varargin)
currentjob = []; alljobs = []; com = '';

try
    options = varargin;
    if ~isempty( varargin )
        for i = 1:2:numel(options)
            g.(options{i}) = options{i+1};
        end
    else g= []; end
catch
    disp('pop_nsg() error: calling convention {''key'', value, ... } error'); return;
end;

try g.listvalue;        catch, g.listvalue       = 1 ;          end
try g.jobid;            catch, g.jobid           = '';          end
try g.outfile;          catch, g.outfile         = '';          end % Default defined in nsg_run
try g.runtime;          catch, g.runtime         = 0.5;         end
try g.filename;         catch, g.filename        = 'test.m';    end
try g.subdirname;       catch, g.subdirname      = '';          end

if nargin < 1
    res = nsg_jobs;
    if isfield(res, 'error')
        errordlg2(res.error.message);
        error(res.error.message);
    end
    jobnames = getjobnames(res);
        
    cblist   = 'pop_nsg(gcbf,''update'');';
    cbstdout = 'pop_nsg(gcbf,''stdout'');';
    cbstderr = 'pop_nsg(gcbf,''stderr'');';
    cdrescan = 'pop_nsg(gcbf,''rescan'');';
    cbtest   = 'pop_nsg(gcbf,''testgui'');';
    cboutput = 'pop_nsg(gcbf,''outputgui'');';
    cdelete  = 'pop_nsg(gcbf,''deletegui'');';
    cbrun    = 'pop_nsg(gcbf,''rungui'');';
    cbzip    = '[filename pathname] = uigetfile({''*.zip'' ''*.ZIP''}); if ~isequal(pathname, 0), set(findobj(gcbf, ''tag'', ''fileorfolder''), ''string'', fullfile(pathname, filename)); end; clear pathname filename;';
    cbdir    = 'pathname = uigetdir(); if ~isequal(pathname, 0), set(findobj(gcbf, ''tag'', ''fileorfolder''), ''string'', pathname); end; clear pathname;';
    joblog   = char(ones(7,70)*' ');
    uilist = { { 'style' 'text'       'string' 'Select job' 'fontweight' 'bold' } {} ...
        { 'style' 'pushbutton' 'string' 'Rescan jobs' 'fontweight' 'bold' 'callback' cdrescan } ...
        { 'style' 'listbox'    'string' jobnames 'tag' 'joblist' 'callback' cblist} ...
        { 'style' 'text' 'string' 'XXXXXXXXXXXX' 'tag' 'jobstatus' } ...
        { 'style' 'pushbutton' 'string' 'Delete this job on NSG' 'callback' cdelete } ...
        { 'style' 'text' 'string' joblog 'tag' 'joblog' } ...
        { 'style' 'pushbutton' 'string' 'See text output' 'callback' cbstdout } ...
        { 'style' 'pushbutton' 'string' 'See errors' 'callback' cbstderr } ...
        { 'style' 'pushbutton' 'string' 'Download results' 'callback' cboutput } ...
        { } ...
        { 'style' 'text'       'string' 'Submit new job' 'fontweight' 'bold' } ...
        { 'style' 'text'       'string' 'Job folder or .zip file' } ...
        { 'style' 'edit'       'string' '' 'tag' 'fileorfolder' } ...
        { 'style' 'pushbutton' 'string' 'Browse zip'    'callback' cbzip } ...
        { 'style' 'pushbutton' 'string' 'Browse folder' 'callback' cbdir } ...
        {} ...
        {} { 'style' 'pushbutton' 'string' 'Test job (unix/Mac only)' 'callback' cbtest } {} ...
        {} { 'style' 'pushbutton' 'string' 'Run job' 'callback' cbrun } {} };
    
    geom     = { [0.5 1 0.7] [1] [1 1] [1] [1 1 1.3] [1]   [1] [0.7 1 0.5 0.5] 1     [1 1 1] [1 1 1] };
    geomvert = [ [1]         [5] [1]   [5] [1]       [0.6] [1] [1]             [0.5] [1]     [1]     ];
   
    userdat.com = ''; 
    [result, userdata] = inputgui( 'geometry', geom, ...
                                   'uilist'  , uilist, ...
                                   'geomvert', geomvert, ...
                                   'helpcom' , 'pophelp(''pop_nsg'')', ...
                                   'title'   , 'NSG-R Matlab/EEGLAB interface -- pop_nsg()', ...
                                   'userdata', userdat,...
                                   'eval'    , 'pop_nsg(gcf,''update'')' );
    
     % GUI call command line output
     tmpalljobs = nsg_jobs;
     if ~isempty(tmpalljobs.joblist.jobs) && ~isempty(result)
         alljobs = tmpalljobs.joblist.jobs.jobstatus;
         if length(tmpalljobs.joblist.jobs.jobstatus)== 1
             currentjob = tmpalljobs.joblist.jobs.jobstatus(1);
         else
             currentjob = tmpalljobs.joblist.jobs.jobstatus{result{1}};
         end
     end
     
else
    if ishandle(fig)
        newjob  = get(findobj(fig, 'tag', 'fileorfolder'), 'string');
        joblist = get(findobj(fig, 'tag', 'joblist'), 'string');
        jobval  = get(findobj(fig, 'tag', 'joblist'), 'value');
        
        if ~isempty(joblist)
            jobstr = joblist{jobval};
        else
            jobstr = '';
        end
        
        % For com output
        userdat = get(fig,'userdata');      
    else
        if isstruct(str) 
            if isfield(str,'selfUri')
                valargin = str.selfUri.url;
            else
                error('pop_nsg: Invalid job structure provided as input');
            end
        else
            valargin = str;
        end
        str = fig;
    end
    
    switch str
        case 'rescan'
            res = nsg_jobs;
            jobnames = getjobnames(res);
            set(findobj(fig, 'tag', 'joblist'), 'value', g.listvalue, 'string', jobnames);
            pop_nsg(fig, 'update');
            
        case 'deletegui'   
            if ~isempty(jobstr)
                pop_nsg('delete', jobstr);
            end
            pop_nsg(fig, 'rescan','listvalue',1);
            
        case 'delete'
            if ~isempty(valargin)
                % Command line output
                tmpcurrentjob = nsg_jobs(valargin);
                currentjob = tmpcurrentjob.jobstatus;
                currentjob.jobStage = 'DELETED';
                % Deleting job
                nsg_delete(valargin);         
            end
    
        case 'update'
            joblog   = char(ones(7,70)*' ');
            set(findobj(fig, 'tag', 'jobstatus'), 'string', ' ');
            set(findobj(fig, 'tag', 'joblog'), 'string', joblog);
            drawnow;
            
            if ~isempty(jobstr)
                resjob = nsg_jobs(jobstr);
                set(findobj(fig, 'tag', 'jobstatus'), 'string', resjob.jobstatus.jobStage);
                if iscell(resjob.jobstatus.messages.message)
                   jobtxt = cellfun(@(x)x.text, resjob.jobstatus.messages.message, 'uniformoutput', false);
                else
                   jobtxt = { resjob.jobstatus.messages.message.text };
                end
                for iLine = 1:length(jobtxt)
                    if length(jobtxt{iLine}) > 70
                        jobtxt{iLine} = [ jobtxt{iLine}(1:67) '...' ];
                    end
                end
                jobtxt = strvcat(jobtxt{:});
                set(findobj(fig, 'tag', 'joblog'), 'string', jobtxt);
            end

        case 'stdout'
            if isempty(jobstr),disp('pop_nsg: No jobs were found.');return;end
            resjob  = nsg_jobs([ jobstr '/output' ]);
            if ~isempty(resjob.results.jobfiles)
                url = geturl(resjob.results.jobfiles.jobfile, 'STDOUT');
            else
                url = '';
            end
            if ~isempty(url)
                resfile = nsg_jobs(url, 'txt');
            else
                resfile = pwd; % any folder
            end
            tmp = dir(resfile);
            if tmp(1).bytes == 0 || isempty(url)
                warndlg2('File is empty, check error');
            else
                pophelp(resfile, 1);
            end
            
        case 'stderr'
            if isempty(jobstr),disp('pop_nsg: No jobs were found.');return;end
            resjob  = nsg_jobs([ jobstr '/output' ]);
            if ~isempty(resjob.results.jobfiles)
                url = geturl(resjob.results.jobfiles.jobfile, 'STDERR');
            else
                url = '';
            end
            if ~isempty(url)
                resfile = nsg_jobs(url, 'txt');
            else
                resfile = pwd; % any folder
            end
            tmp = dir(resfile);
            if tmp(1).bytes == 0 || isempty(url)
                warndlg2('File is empty, check text output');
            else
                pophelp(resfile, 1);
            end
            
        case 'outputgui' 
            if isempty(jobstr),disp('pop_nsg: No jobs were found.');return;end
            pop_nsg('output', jobstr);

        case 'output'
            if isempty(valargin),disp('pop_nsg: No jobs were found.');return;end
            resjob  = nsg_jobs([ valargin '/output' ]);
            if ~isempty(resjob.results.jobfiles)
                restmp  = nsg_jobs(geturl(resjob.results.jobfiles.jobfile, 'output.tar.gz'), 'zip');
            else
                restmp = 0;
            end
            if restmp == 0
                warndlg2('File is empty, check error');
            else
                warndlg2([ 'File downloaded and decompressed in the' 10 'output folder specified in the settings']);
            end          
            % Command line output
            tmpcurrentjob = nsg_jobs(valargin);
            currentjob = tmpcurrentjob.jobstatus;
            
        case 'testgui'
            if isempty(newjob)
                warndlg2('Empty input');
            else
                pop_nsg('test',newjob);
            end
            
        case 'test'
            if isempty(valargin)
                warndlg2('Empty input');
            else
                nsg_test(valargin);
            end
            
        case 'rungui' 
             if isempty(newjob)
                warndlg2('Empty input');
             else
                pop_nsg('run', newjob);
                pop_nsg(fig, 'rescan','listvalue',length(get(findobj(gcf,'tag','joblist'),'string'))+1);
             end    
             
        case 'run'
            if isempty(valargin)
                warndlg2('Empty input');
            else              
                currentjoburl = nsg_run(valargin,'jobid', g.jobid,'outfile',g.outfile,'runtime',g.runtime,'filename', g.filename, 'subdirname', g.subdirname);                
                % Command line output
                tmpcurrentjob = nsg_jobs(currentjoburl);
                currentjob = tmpcurrentjob.jobstatus;               
            end
    end 
    
    % Command line output
    if ~ishandle(fig)
        tmpalljobs    = nsg_jobs;
        if ~isempty(tmpalljobs.joblist.jobs)
            alljobs = tmpalljobs.joblist.jobs.jobstatus; %tmpalljobs.jobstatus;
        end
    end
end

% get result type
function url = geturl(results, resultType)
url = '';
if ~iscell(results)
    results = {};
end

for iRes = 1:length(results)
    if strcmpi(results{iRes}.downloadUri.title, resultType)
        url = results{iRes}.downloadUri.url;
    end
end

function jobnames = getjobnames(res)
    jobStatus = {};
    jobnames = {};
    try
        jobStatus = res.joblist.jobs.jobstatus;
        if ~iscell(jobStatus), jobStatus = { jobStatus }; end
        for iJob = 1:length(jobStatus)
            jobnames{iJob} = jobStatus{iJob}.selfUri.url;
        end
    catch, end
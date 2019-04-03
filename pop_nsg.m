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
        if ~ischar(options{1}), options = options{1}; end
        for i = 1:2:numel(options)
            g.(options{i}) = options{i+1};
        end
    else, g= []; end
catch
    disp('pop_nsg() error: calling convention {''key'', value, ... } error'); return;
end

try g.listvalue;        catch, g.listvalue       = 1 ;          end
try g.jobid;            catch, g.jobid           = '';          end
try g.outfile;          catch, g.outfile         = '';          end % Default defined in nsg_run
try g.runtime;          catch, g.runtime         = 0.5;         end
try g.filename;         catch, g.filename        = '';          end
try g.subdirname;       catch, g.subdirname      = '';          end

if nargin < 1
    res = nsg_jobs;
    if isfield(res, 'error')
        errordlg2(res.error.message);
        error(res.error.message);
    end
    clientjoburl = getjobnames(res); 
    jobnames     = nsg_getjobid(clientjoburl,1);
    cbautoscan  = '';
    cbloadplot  = 'pop_nsg(gcbf,''loadplot'');';
    cbcancel     = 'set(findobj(gcbf, ''tag'', ''runnsg''), ''userdata'', ''dummy'');'; % Setting a dummy change of userdata
    cblist       = 'pop_nsg(gcbf,''update'');';
    cbstdout     = 'pop_nsg(gcbf,''stdout'');';
    cbstderr     = 'pop_nsg(gcbf,''stderr'');';
    cdrescan     = 'pop_nsg(gcbf,''rescan'');';
    cbtest       = 'pop_nsg(gcbf,''testgui'');';
    cboutput     = 'pop_nsg(gcbf,''outputgui'');';
    cdelete      = 'pop_nsg(gcbf,''deletegui'');';
    cbrun        = 'pop_nsg(gcbf,''rungui'',eval( [ ''{'' get(findobj(gcf,''tag'',''edit_runopt''),''string'') ''}'' ] ));';
    cbsetmfile   = 'jobfile = get(findobj(gcbf,''tag'',''fileorfolder''),''String''); mfilelist = '' '';if ~isempty(jobfile),if isdir(jobfile),mfilestmp = dir(fullfile(jobfile, ''*.m''));if ~isempty(mfilestmp), mfilelist = {mfilestmp.name}; end;else,mfilelist = listzipcontents(jobfile, ''.m'');if isempty(mfilelist), mfilelist = '' ''; end; end;set(findobj(gcbf,''tag'',''listbox_mfile''),''string'',mfilelist,''Value'', 1);end;clear pathname filename;';
    cbload       =  ['ButtonName = questdlg2(''Do you want to load a ZIP file or a folder?'',''pop_nsg'',''Folder'', ''ZIP File'', ''ZIP File'');if strcmpi(ButtonName, ''zip file''),[filename pathname] = uigetfile({''*.zip'' ''*.ZIP''});if ~isequal(pathname, 0),set(findobj(gcbf, ''tag'', ''fileorfolder''), ''string'', fullfile(pathname, filename));end;else,pathname = uigetdir();if ~isequal(pathname, 0),set(findobj(gcbf, ''tag'', ''fileorfolder''), ''string'', pathname);end;end;' cbsetmfile];
    joblog       = char(ones(7,70)*' ');
    
    uilist = { { 'style' 'text'       'string' 'Select job' 'fontweight' 'bold' }...                         % Label Select job
               { 'style' 'pushbutton' 'string' 'Rescan NSG jobs' 'callback' cdrescan }...                    % Button rescan
               { 'style' 'pushbutton' 'string' 'Auto scan' 'callback' cbautoscan }...                        % Button autoscan
               { 'style' 'pushbutton' 'string' 'Delete this NSG job' 'callback' cdelete } ...                % Button delete
               { 'style' 'listbox'    'string' jobnames 'tag' 'joblist' 'callback' cblist}...                % List jobs
               { 'style' 'pushbutton' 'string' 'View job output log' 'callback' cbstdout } ...               % Button output log
               { 'style' 'pushbutton' 'string' 'View job error log' 'callback' cbstderr } ...                % Button error log
               { 'style' 'pushbutton' 'string' 'Download job results' 'callback' cboutput }...               % Button download log
               { 'style' 'pushbutton' 'string' 'Load/plot results' 'callback' cbloadplot }...                % Button plot
               { 'style' 'text'       'string' 'NSG job status' 'fontweight' 'bold' }...                     % Label Status
               { 'style' 'text'       'string' joblog 'tag' 'joblog' }...                                    % List Joblog
               { 'style' 'text'       'string' 'Submit new NSG job' 'fontweight' 'bold' } ...                % Label submit
               { 'style' 'text'       'string' 'Job folder or .zip file' } ...                               % Label select file 
               { 'style' 'edit'       'string' '' 'tag' 'fileorfolder' } ...                                 % Edit Filepath
               { 'style' 'pushbutton' 'string' '...'    'callback' cbload }...                               % Button load file
               { 'style' 'text'       'string' 'Matlab script to execute'}...                                % Label File to execute
               {'style'  'popupmenu'  'string' {'test.m'} 'tag' 'listbox_mfile'}...                          % Popup menu file to execute
               {'style'  'pushbutton' 'string' 'Test job locally' 'callback' cbtest}...                      % Button test
               {'style'  'text'       'string' 'NSG run options (see Help)'}...                              % Label Run options
               {'style'  'edit'       'string' ' ' 'tag' 'edit_runopt'}...                                   % Edit run options                        
               {'style'  'pushbutton' 'string' 'Help', 'tag' 'help' 'callback', 'pophelp(''pop_nsg'')' }...  % Button Help
               {'style'  'pushbutton' 'string' 'Cancel', 'tag' 'cc' 'callback' cbcancel} ...                 % Button Cancel
               {'style'  'pushbutton' 'string' 'Run job on NSG' 'tag' 'runnsg' 'callback' cbrun } };         % Button Run job                 
    
    ht = 17; wt = 7.5;
    horzspan  = 1.8; vertspam = 1.1; c1 = 0.9; c2 = 2.55; c3 = 5.2; c4 = 6.8;    
    geom = { {wt ht [c2 0]      [1 vertspam]   } ...      % Label Select job
             {wt ht [c1 1]      [horzspan vertspam] } ...  % Button rescan
             {wt ht [c1 2.33]   [horzspan vertspam] }...   % Button autoscan
             {wt ht [c1 5]      [horzspan vertspam] }...   % Button delete
             {wt ht [c2 1]      [4.4 5]   } ...           % List jobs
             {wt ht [c4 1]      [horzspan vertspam] } ...  % Button output log
             {wt ht [c4 2.33]   [horzspan vertspam] }...   % Button error log
             {wt ht [c4 3.66]   [horzspan vertspam] }...   % Button download log
             {wt ht [c4 5]      [horzspan vertspam] }...   % Button download log
             {wt ht [c1 6.3]    [horzspan vertspam] }...   % Label Status
             {wt ht [c2 6]      [5 5]   }...              % List Joblog
             {wt ht [c1 11]     [horzspan vertspam] } ...  % Label submit
             {wt ht [c1 12]     [horzspan vertspam] } ...  % Label select file 
             {wt ht [c2 12]     [4.4 vertspam] } ...      % Edit Filepath
             {wt ht [c4 12]     [horzspan vertspam] }...   % Button load file
             {wt ht [c1 13.3]   [horzspan vertspam] } ...  % Label File to execute
             {wt ht [c2 13.3]   [3 vertspam] } ...        % Popup menu file to execute
             {wt ht [c4 13.3]   [horzspan vertspam] }...   % Button test
             {wt ht [c1 15]     [horzspan vertspam] } ...  % Label Run options
             {wt ht [c2 15]     [4.4 vertspam] } ...      % Edit run options
             {wt ht [c1 17]     [horzspan vertspam] } ...  % Button Help
             {wt ht [c3 17]     [horzspan vertspam] } ...  % Button Cancel
             {wt ht [c4 17]     [horzspan vertspam] }};    % Button Run job
         
    for i = 1:length(geom), geom{i}{3} = geom{i}{3}-1; end 
    
    % GUI setup
    fig = figure('visible', 'off','Units', 'Normalized'); 
    supergui('fig', fig, 'geom', geom, 'uilist', uilist, 'userdata', '', 'title' , 'NSG-R Matlab/EEGLAB interface -- pop_nsg()');
    set(fig, 'Units', 'Normalized', 'Position',[0.2750 0.3204 0.3990 0.5389],'visible', 'on');      
    pop_nsg(fig, 'update');
    
    % Wait for cancel, grab list position and close the GUI
    waitfor( findobj('parent', fig, 'tag', 'runnsg'), 'userdata');
    if ~(ishandle(fig)), return; end % Check if figure still exist
    result = get(findobj(fig, 'tag', 'joblist'), 'value');
    close(fig); 
    
     % GUI call command line output
     tmpalljobs = nsg_jobs;
     if ~isempty(tmpalljobs.joblist.jobs) && ~isempty(result)
         alljobs = tmpalljobs.joblist.jobs.jobstatus;
         if length(tmpalljobs.joblist.jobs.jobstatus)== 1
             currentjob = tmpalljobs.joblist.jobs.jobstatus(1);
         else
             currentjob = tmpalljobs.joblist.jobs.jobstatus{result};
         end
     end
     
else
    if ishandle(fig)
        newjob  = get(findobj(fig, 'tag', 'fileorfolder'), 'string');
        joblist = get(findobj(fig, 'tag', 'joblist'), 'string');
        jobval  = get(findobj(fig, 'tag', 'joblist'), 'value');
        tmplist = get(findobj(fig, 'tag', 'listbox_mfile'), 'string');
        
        % Def .m file to run
        if any(strcmp(str,{'rungui', 'test'}))
            % mfiles
            if ~isempty(deblank(tmplist))
                g.filename  = tmplist{get(findobj(fig, 'tag', 'listbox_mfile'), 'value')}; % Updating mfile
            else
                warndlg2('Select MATLAB script to execute'); return;
            end            
        end
        
        if ~isempty(joblist)
            if ischar(joblist), joblist = {joblist}; end
            for ijobs =1:length(joblist)
                if ~isnsgurl(joblist{ijobs})
                    joblist{ijobs} = nsg_findclientjoburl(joblist{ijobs});
                end
            end
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
        case 'loadplot'
               nsg_info;
               resjob  = nsg_jobs([ jobstr '/output' ]);
               if ~isempty(resjob.results.jobfiles)
                   zipfilepos = find(cell2mat(cellfun(@(x) strcmp(x.parameterName,'outputfile'),resjob.results.jobfiles.jobfile,'UniformOutput',0)));
                   [tmp, tmpval] = fileparts(resjob.results.jobfiles.jobfile{zipfilepos}.filename);
                   [tmp, foldname] = fileparts(tmpval);
                   tmpFolder = fullfile(outputfolder, foldname);
                   if exist(tmpFolder,'dir')
                       nsg_uilistfiles(tmpFolder,'oklabel', 'Load/plot' );
                   else
                       disp('pop_nsg: Unable to load/plot results. Results must be downloaded first');
                       return;
                   end
               else
                   disp('pop_nsg: Unable to load/plot results. Computation has not finished');
                   return;
               end           
        case 'autoscan'
            
        case 'rescan'
            res = nsg_jobs;
            clientjoburl = getjobnames(res);
            jobnames = nsg_getjobid(clientjoburl,1);
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
                % Find zip file of results (name is not fixed anymore)
                zipfilepos = find(cell2mat(cellfun(@(x) strcmp(x.parameterName,'outputfile'),resjob.results.jobfiles.jobfile,'UniformOutput',0)));
                % Getting name of results file
                [tmp, tmpval] = fileparts(resjob.results.jobfiles.jobfile{zipfilepos}.filename);
                [tmp, foldname] = fileparts(tmpval);
                % Pulling results
                restmp  = nsg_jobs(resjob.results.jobfiles.jobfile{zipfilepos}.downloadUri.url, 'zip',foldname);
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
                tmpparams = eval( [ '{' get(findobj(gcf,'tag','edit_runopt'),'string') '}' ] );
                pop_nsg('run', newjob, tmpparams{:});
                if iscell(get(findobj(gcf,'tag','joblist'),'string'))
                    listpos = length(get(findobj(gcf,'tag','joblist'),'string'))+1;
                elseif ~isempty(get(findobj(gcf,'tag','joblist'),'string'))
                    listpos = 2;
                end               
                pop_nsg(fig, 'rescan','listvalue',listpos);
             end    
             
        case 'run'
            if isempty(valargin)
                warndlg2('Empty input');
            else              
                currentjoburl = nsg_run(valargin,'jobid', g.jobid,'outfile',g.outfile,'runtime',g.runtime,'filename', g.filename, 'subdirname', g.subdirname);                
                % Command line output
                if ~isempty(currentjoburl)
                    tmpcurrentjob = nsg_jobs(currentjoburl);
                    currentjob = tmpcurrentjob.jobstatus;
                end
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
end
% ---
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
end
% ---
function jobnames = getjobnames(res)
    jobnames = {};
    try
        jobStatus = res.joblist.jobs.jobstatus;
        if ~iscell(jobStatus), jobStatus = { jobStatus }; end
        for iJob = 1:length(jobStatus)
            jobnames{iJob} = jobStatus{iJob}.selfUri.url;
        end
    catch
    end
end
% ---   
function urlflag = isnsgurl(urlcheck)
if length(urlcheck)>= 20
    urlflag =fastif(strcmp('https://nsgr.sdsc.edu',urlcheck(1:21)),1,0);  
else
    urlflag = 0;
end
end
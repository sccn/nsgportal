function com = pop_nsg(str, fig)

com = '';
if nargin < 1
    res = nsg_jobs;
    if isfield(res, 'error')
        errordlg2(res.error.message);
        error(res.error.message);
    end
    jobnames = getjobnames(res);
        
    cblist   = 'pop_nsg(''update'', gcbf);';
    cbstdout = 'pop_nsg(''stdout'', gcbf);';
    cbstderr = 'pop_nsg(''stderr'', gcbf);';
    cboutput = 'pop_nsg(''output'', gcbf);';
    cdelete  = 'pop_nsg(''delete'', gcbf);';
    cdrescan = 'pop_nsg(''rescan'', gcbf);';
    cbtest   = 'pop_nsg(''test'', gcbf);';
    cbrun    = 'pop_nsg(''run'', gcbf);';
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
    
    [result, userdat2, strhalt, outstruct, instruct] = inputgui( 'geometry', geom, ...
        'uilist'  , uilist, ...
        'geomvert'  , geomvert, ...
        'helpcom' , 'pophelp(''pop_nsg'')', ...
        'title'   , 'NSG-R Matlab/EEGLAB interface -- pop_nsg()', ...
        'eval'    , 'pop_nsg(''update'', gcf)' );
else
    newjob  = get(findobj(fig, 'tag', 'fileorfolder'), 'string');
    joblist = get(findobj(fig, 'tag', 'joblist'), 'string');
    jobval  = get(findobj(fig, 'tag', 'joblist'), 'value');
    if ~isempty(joblist)
        jobstr = joblist{jobval};
    else 
        jobstr = '';
    end
    
    switch str
        case 'rescan'
            res = nsg_jobs;
            jobnames = getjobnames(res);
            set(findobj(fig, 'tag', 'joblist'), 'string', jobnames);
            pop_nsg('update', fig);
            
        case 'delete'
            if ~isempty(jobstr)
                nsg_delete(jobstr);
            end
            pop_nsg('rescan', fig);
    
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
        case 'output'
            resjob  = nsg_jobs([ jobstr '/output' ]);
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
        case 'test'
            if isempty(newjob)
                warndlg2('Empty input');
            else
                nsg_test(newjob);
            end
        case 'run'
            if isempty(newjob)
                warndlg2('Empty input');
            else
                nsg_run(newjob);
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


% nsg_run     - Submit job to NSG and return job URL.
%                          
% Usage: 
%             >> jobURL = nsg_run(joblocation)
%             >> jobURL = nsg_run(joblocation, 'jobid', 'job02')
%
% Inputs:
%  joblocation    - Path to the zip file containing the job to submit to NSG
%
% Outputs:
%  jobURL         - [string] Job URL
%
% Optional inputs:
%  'jobid'          - String with the client job id. This was assigned to the
%                     job when created. Default: None
%  'outfile'        - String with the name of the results file. 
%                     Default: ['nsgresults_'jobname] . Jobname here is the
%                     name of the file submitted.
%  'runtime'        - Time (in hours) to allocate for running the job in NSG. 
%                     Maximun time allocation is 48 hrs. Default: 0.5
%  'filename'       - Name of main file to run in NSG. Default: 'test.m'
%  'subdirname'     - Name of Sub-directory containing the main file i.e. if
%                     your main file is not on the top level directory.
%                     Default: None
%   
%  See also: nsg_delete(), nsg_jobs(), nsg_test(), nsg_run(), nsg_findclientjoburl()
%
% Authors: Ramon Martinez-Cancino and Arnaud Delorme, SCCN/INC/UCSD 2019

% Copyright (C) Ramon Martinez-Cancino and Arnaud Delorme
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

function jobURL = nsg_run(joblocation, varargin)
jobURL = [];

try
    options = varargin;
    if ~isempty( varargin )
        for i = 1:2:numel(options)
            g.(options{i}) = options{i+1};
        end
    else g= []; end
catch
    disp('nsg_run() error: calling convention {''key'', value, ... } error'); return;
end
try g.jobid; assert(~isempty(g.jobid));       catch, g.jobid           = randi(10000);             end  
try g.outfile; assert(~isempty(g.outfile));   catch, g.outfile         = ['nsgresults_' g.jobid];  end
try g.runtime;                                catch, g.runtime         = 0.5;                      end
try g.filename;                               catch, g.filename        = '';                       end
try g.subdirname;                             catch, g.subdirname      = '';                       end

if isempty(g.filename)
    disp('nsg_run: Property filename must be provided'); 
    return; 
end

nsg_info;

[~, filename, ext] = fileparts(joblocation);
if isempty(ext)
    zipFile = fullfile(outputfolder, [ filename '.zip' ]);
    zip(zipFile, joblocation);
else
    zipFile = joblocation;
end

% Create command to run job
curlcom = ['curl -u %s:%s -H cipres-appkey:%s %s/job/%s -F tool=EEGLAB_TG'...
                                                      ' -F input.infile_=@%s'...
                                                      ' -F metadata.statusEmail=true'...
                                                      ' -F metadata.clientJobId=%s'...
                                                     [' -F vparam.outputfilename_=' char(39) char(39) '%s' char(39) char(39)]...
                                                      ' -F vparam.runtime_=''%s'''...
                                                      ' -F vparam.filename_=%s'];                                                                                                                                                                                                    
% Submit job
if isempty(g.subdirname)
   command = sprintf([curlcom ' > tmptxt.xml'], nsgusername, nsgpassword, nsgkey, nsgurl, nsgusername,...
                                                zipFile, num2str(g.jobid), g.outfile, num2str(g.runtime), g.filename);                                                                                    
else
   command = sprintf([curlcom ' -F vparam.subdirname_=%s > tmptxt.xml'], nsgusername, nsgpassword, nsgkey, nsgurl, nsgusername,...
                                                                      zipFile, num2str(g.jobid), g.outfile, num2str(g.runtime), g.filename, g.subdirname);
end
system(command);
disp('Job has been submitted!');

% Find job URL
jobURL = nsg_findclientjoburl(num2str(g.jobid));
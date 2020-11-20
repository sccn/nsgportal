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
%  'filename'       - Name of main file to run in NSG. Default: None
%  'subdirname'     - Name of Sub-directory containing the main file i.e. if
%                     your main file is not on the top level directory.
%                     Default: None
%  'nnodes'         - Number of nodes to use if running AMICA. Default: 1 
%  'statusemail'    - 'true'| 'false'. If "true", an email will be sentafter
%                     job completion. Default: 'true'
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
try g.nnodes;                                 catch, g.nnodes          = 1;                        end
try g.statusemail;                            catch, g.statusemail     = 'true';                   end
% try g.emailaddress;                           catch, g.emailaddress    = '';                       end % Not implemented in NSGR yet

if isempty(g.filename)
    disp('nsg_run: Property filename must be provided'); 
    return; 
end

nsg_info;

if ~exist(joblocation)
    error('Cannot find file or folder');
end
[~, filename, ext] = fileparts(joblocation);
if isempty(ext)
    zipFile = fullfile(outputfolder, [ filename '.zip' ]);
    zip(zipFile, joblocation);
else
    zipFile = joblocation;
end

% Create command to run job
curlcom = ['curl -k -s -u %s:%s -H cipres-appkey:%s %s/job/%s -F tool=EEGLAB_TG'...
                                                      ' -F input.infile_=@"%s"'...
                                                      ' -F metadata.statusEmail=%s'...
                                                      ' -F metadata.clientJobId=%s'...
                                                      ' -F vparam.outputfilename_="%s"'...
                                                      ' -F vparam.runtime_=%f'...
                                                      ' -F vparam.number_nodes_=%u'...
                                                      ' -F vparam.filename_=%s'];                                                                                                                                                                                                    
% Adding other options
comstring1 = 'command = sprintf([curlcom ';
comstring2 = 'nsgusername, nsgpassword, nsgkey, nsgurl, nsgusername, zipFile, g.statusemail,num2str(g.jobid), g.outfile, g.runtime, g.nnodes, g.filename';
if ~isempty(g.subdirname)
    comstring1 = [comstring1 ''' -F vparam.subdirname_=''''%s'''''''];
    comstring2 = [comstring2 ', g.subdirname'];
end
% if ~isempty(g.emailaddress)
%     comstring1 = [comstring1 ''' -F vparam.emailAddress=''''%s'''''''];
%     comstring2 = [comstring2 ', g.emailaddress'];
% end
commandstring = [comstring1 ' '' > tmptxt.xml''], ' comstring2 ');'];
eval(commandstring);

% Submit job
system(command);
disp('Job has been submitted!');

% Find job URL
jobURL = nsg_findclientjoburl(num2str(g.jobid));

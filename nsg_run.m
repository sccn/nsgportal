% nsg_run     - Submit job to NSG and return job URL.
%                          
% Usage: 
%             >> jobURL = nsg_run(joblocation)
%             >> jobURL = nsg_run(joblocation, 'clientjobid', 'job02')
%
% Inputs:
%  joblocation    - Path to the zip file containing the job to submit to NSG
%
% Outputs:
%  jobURL         - [string] Job URL
%
% Optional inputs:
%  'clientjobid'  - String with the client job id. This was assigned to the
%                   job when created.
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
try g.clientjobid;   catch, g.clientjobid   = randi(10000);  end

nsg_info;

[~, filename, ext] = fileparts(joblocation);
if isempty(ext)
    zipFile = fullfile(outputfolder, [ filename '.zip' ]);
    zip(zipFile, joblocation);
else
    zipFile = joblocation;
end

% submit job
if isempty(g.clientjobid)
    command = sprintf('curl -u %s:%s -H cipres-appkey:%s %s/job/%s -F tool=EEGLAB_TG -F input.infile_=@%s -F metadata.statusEmail=true > tmptxt.xml', nsgusername, nsgpassword, nsgkey, nsgurl, nsgusername, zipFile);
else
    command = sprintf('curl -u %s:%s -H cipres-appkey:%s %s/job/%s -F tool=EEGLAB_TG -F input.infile_=@%s -F metadata.statusEmail=true  -F metadata.clientJobId=%s > tmptxt.xml', nsgusername, nsgpassword, nsgkey, nsgurl, nsgusername, zipFile, num2str(g.clientjobid));
end
system(command);
disp('Job has been submitted!');

% Find job URL
jobURL = nsg_findclientjoburl(num2str(g.clientjobid)); 
% nsg_jobs     - Returns job object. When called without arguments 
%                returns all jobs.
%                          
% Usage: 
%             >> joblist = nsg_jobs
%             >> joblist = nsg_jobs(jobname)
%             >> joblist = nsg_jobs(jobname,'xml')
%
% Inputs:
%
% Outputs:
%  res2    - Structure of job objects
%
% Optional inputs:
%  'jobname'    - URL of job
%  'filetype'   - File extension to use to store files with job
%                 information E.g. 'xml','txt', '.zip'. Default:'xml'
% 
%  See also: nsg_delete(), nsg_test(), nsg_run(), nsg_findclientjoburl()
%
% Authors: Arnaud Delorme and Ramon Martinez-Cancino, SCCN/INC/UCSD 2019

% Copyright (C) Arnaud Delorme and Ramon Martinez-Cancino 2019
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

function res2 = nsg_jobs(jobname, filetype)

nsg_info;
if nargin < 2
    filetype = 'xml';
end
if nargin < 1
    command = sprintf('curl -u %s:%s -H cipres-appkey:%s "%s/job/%s?expand=true" > tmptxt.xml', nsgusername,  nsgpassword, nsgkey, nsgurl, nsgusername); % request full job status objects
    system(command);
    res2 = xml2struct('tmptxt.xml');
    res2 = removeTextTag(res2);    
else
    
    if strcmpi(filetype, 'xml')
        command = sprintf(['curl -u %s:%s -H cipres-appkey:%s "%s?expand=true" > tmptxt.' filetype], nsgusername, nsgpassword, nsgkey, jobname);
        system(command);
        
        res2 = xml2struct('tmptxt.xml');
        res2 = removeTextTag(res2);
        
    elseif strcmpi(filetype, 'txt')
        command = sprintf(['curl -u %s:%s -H cipres-appkey:%s "%s?expand=true" > tmptxt.' filetype], nsgusername, nsgpassword, nsgkey, jobname);
        system(command);
        res2 = [ 'tmptxt.' filetype ];
    else
        tmpval = fileparts(jobname);
        tmpval = fileparts(tmpval);
        [tmp, foldname] = fileparts(tmpval);
        
        tmpFolder = fullfile(outputfolder, foldname);
        currentFolder = pwd;
        mkdir(tmpFolder)
        cd(tmpFolder);
        command = sprintf(['curl -u %s:%s -H cipres-appkey:%s "%s?expand=true" > tmptxt.' filetype], nsgusername, nsgpassword, nsgkey, jobname);
        system(command);
        tmp = dir([ 'tmptxt.' filetype ]);
        if tmp.bytes == 0
            res2 = 0;
        else
            system( [ 'tar zxvf tmptxt.' filetype] );
            res2 = 1;
        end
        cd(currentFolder);
    end
end    
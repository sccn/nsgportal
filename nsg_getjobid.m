% nsg_getjobid() - Given a Job URL, finds and returns the job ID 
%                  
%                                                
% Usage: 
%             >> clientjobid = nsg_getjobid('myjobURL', 1)  
%
% Inputs:
%  clientjoburl  - String or cell arrray of strings with job URLs
%  ignoreidnum   - [0,1] Flag to ignore [1] or not[0] numerical job IDs.
%                  For example, if 'ignoreidnum' is set to [1] and the
%                  job have a numerical IDs, then the ouptut will be the
%                  job URL. 
%
% Outputs:
%  clientjobid   - [string] Job ID
%   
%  See also: nsg_run(),pop_nsg()
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

function clientjobid = nsg_getjobid(clientjoburl,ignoreidnum)

if iscell(clientjoburl), ninputs = length(clientjoburl); else, ninputs =1; end
clientjobid = cell(1,ninputs);
for i =1:ninputs
    if iscell(clientjoburl), clientjobtmp = clientjoburl{i}; else, clientjobtmp = clientjoburl; end
    jobstr = nsg_jobs(clientjobtmp);
    
    tmphit = find(cellfun(@(x) strcmp(x.key,'clientJobId'),jobstr.jobstatus.metadata.entry));
    if ~isempty(tmphit)
        jobidtmp = jobstr.jobstatus.metadata.entry{tmphit}.value;
    end
    
    % Note: The rationale here is by assuming that numeric IDs are not assigned
    % by users but by nsg_run() in order to retreive the jobs later. Thus we
    % should enforce job IDs to be strings. In case the numeric
    
    if ~isnan(str2double(jobidtmp)) && ignoreidnum == 1
        clientjobid{i} = clientjobtmp;      
    elseif ~isnan(str2double(jobidtmp)) && ignoreidnum == 0
        clientjobid{i} = jobidtmp;
    else
        clientjobid{i} = jobidtmp;
    end
end

if ninputs==1, clientjobid=clientjobid{1}; end
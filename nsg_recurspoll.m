% nsg_recurspoll     - Given a jobid the function keep polling recursively
%                      for the job status until job is completed.
%                                            
% Usage: 
%             >> jobstruct = nsg_recurspoll(jobid)
%
% Inputs:
%  jobid             - Job ID 
%
% Outputs:
%  jobstruct         - Structure of job provided as input
%
% Optional inputs:
%  'pollinterval'    - Time in seconds of intervals for polling.This parameter 
%                       should be higher that 450 seconds. Please keep polling frequency
%                       as low as possible to avoid overloading NSG !!!
%  'verbose'         - [0|1] Display job status on each polling. Default:[1]
%   
%  See also: nsg_jobs()
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

function jobstruct = nsg_recurspoll(jobid,varargin)
jobstruct = []; 

try
    options = varargin;
    if ~isempty( varargin )
        if ~ischar(options{1}), options = options{1}; end
        for i = 1:2:numel(options)
            g.(options{i}) = options{i+1};
        end
    else, g= []; end
catch
    disp('nsg_recurspoll() error: calling convention {''key'', value, ... } error'); return;
end

try g.pollinterval;     catch, g.pollinterval= 450 ;       end
try g.verbose;          catch, g.verbose = 1 ;              end

if g.pollinterval<1800
    disp(['nsg_recurspoll: Invalid polling interval. This parameter should be higher that 450 (sec).' char(10)...
          '                Please, keep polling frequency as low as possible to avoid overloading NSG']);
end

joburl = nsg_findclientjoburl(jobid);
if ~isempty(joburl)
    t = timer;
    t.TimerFcn = @(~,~)nsgpoll(joburl,g.verbose);
    t.Period =  g.pollinterval;
    t.ExecutionMode = 'fixedRate';
    t.TasksToExecute = 1000;
    t.BusyMode = 'queue';
    start(t);
    waitfor(t);
    
    jobstruct = nsg_jobs(joburl);
end

%---
function nsgpoll(joburl,verbose)
res = nsg_jobs(joburl);
if iscell(res.jobstatus.messages.message)
    stage =res.jobstatus.messages.message{end}.stage;
else
    stage = res.jobstatus.messages.message.stage;
end
 if verbose
     disp(['Job status: ' stage]);
 end

if strcmpi(stage, 'completed')
    delete(t);
end
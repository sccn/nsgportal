% nsg_recurspoll     - Given a jobid the function keep polling recursively
%                      the job status until job is completed.
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

try g.pollinterval;     catch, g.pollinterval= 60;       end
try g.verbose;          catch, g.verbose = 1 ;           end

if g.pollinterval<60
    warning(['Attention to the polling interval value used. This may impact negatively ' char(10)...
          '         the server performance. Try keeping this parameter as low as possible']);
end

% Decoding input
if ~isempty(jobid)
    joburl = '';
    if isstruct(jobid) % NSG struct
        if isfield(jobid,'selfUri')
            joburl = jobid.selfUri.url;
        else
            error('nsg_recurspoll: Invalid job structure provided as input');
        end
    elseif isnsgurl(jobid) % NSG URL
        joburl = jobid;
    elseif ischar(jobid) % NSG JobID
        joburl = nsg_findclientjoburl(jobid);
    end
    if isempty(joburl), error('nsg_recurspoll: Invalid  argument to locate job'); end
else
    disp('nsg_recurspoll: Invalid argument to locate job');
    return;
end

t = timer;
t.Period =  g.pollinterval;
t.ExecutionMode = 'fixedRate';
t.TasksToExecute = 1000;
t.BusyMode = 'queue';
t.Tag = ['timer_nsg_recursepoll_' num2str(floor(100*rand(1)))]; % Neccesary in case more than one timer is running in paralell
t.TimerFcn = @(~,~)nsg_poll(joburl,g.verbose,t.Tag);
start(t);
wait(t);
delete(t);
jobstructmp = nsg_jobs(joburl);
jobstruct = jobstructmp.jobstatus;

%---
function nsg_poll(joburl,verbose,tagval)
res = nsg_jobs(joburl);
if iscell(res.jobstatus.messages.message)
    stage =res.jobstatus.messages.message{end}.stage;
else
    stage = res.jobstatus.messages.message.stage;
end
 if verbose
     format shortg;
     timeval = clock;
     disp(['Job status on ' num2str(timeval(2)) '-' num2str(timeval(3)) '-' num2str(timeval(1)) ' ' num2str(timeval(4)) ':'  num2str(timeval(5)) ':'  num2str(floor(timeval(6)))  ' : ' stage]);
 end

if strcmpi(stage, 'completed')
    alltimersobj = timerfindall('Tag', tagval);
    stop(alltimersobj);
end
% nsg_download - Download results of NSG job
%                          
% Usage: 
%  >> jobinfo = nsg_download(jobURL)
%
% Inputs:
%  jobURL    - Job URL
%
% Outputs:
%  jobinfo   - Information about the job. 0 if no results were found.
%
% Authors: Arnaud Delorme, SCCN/INC/UCSD 2020

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

function restmp = nsg_download(urlval)

resjob  = nsg_jobs([ urlval '/output' ]);
restmp = 0;
if ~isempty(resjob.results.jobfiles)
    % Find zip file of results (name is not fixed anymore)
    zipfilepos = find(cell2mat(cellfun(@(x) strcmpi(x.parameterName,'outputfile'),resjob.results.jobfiles.jobfile,'UniformOutput',0)));
    if ~isempty(zipfilepos(1))
        % Getting name of results file
        [tmp, tmpval] = fileparts(resjob.results.jobfiles.jobfile{zipfilepos(1)}.filename);
        [tmp, foldname] = fileparts(tmpval);
        % Pulling results
        restmp  = nsg_jobs(resjob.results.jobfiles.jobfile{zipfilepos(1)}.downloadUri.url, 'zip',foldname);
    end
end

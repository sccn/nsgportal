% nsg_test() - Run an NSG job test in the local computing resource.
%
% Usage: 
%             >> nsg_test('eeglab/plugins/nsgportal/demos/demo_jobs/TestingEEGLABNSG.zip', 'run_ica_nsg.m')
%
% Inputs:
%   joblocation         - Path to job NSG zip file or folder
%   joblocation         - Matlab file (.m) to execute during the test
%
% Outputs:
%
%  See also: 
%
% Authors: Arnaud Delorme          SCCN/INC/UCSD 2019
%          Ramon Martinez-Cancino  SCCN/INC/UCSD 2019

% Copyright (C)  Arnaud Delorme, 2019
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

function nsg_test(joblocation, mfilename, subdirname)

nsg_info;

[~, filename, ext] = fileparts(joblocation);
if isempty(ext)
    if isempty(outputfolder)
        outputfolder = pwd;
    end
    zipFile = fullfile(outputfolder, [ filename '.zip' ]);
    zip(zipFile, joblocation);
    nsg_test(zipFile, mfilename, subdirname);
else
    if ~strcmpi(ext, '.zip')
        error('Not a zip file');
    else
        tmpFolder = fullfile(outputfolder, [ filename num2str(rand(1)*1000000) ]);
        currentFolder = pwd;
        mkdir(tmpFolder);
        cd(tmpFolder);
        unzip(joblocation);
        
        folderContent = dir(pwd);
        folderContent(strmatch('.',  { folderContent.name }, 'exact')) = [];
        folderContent(strmatch('..', { folderContent.name }, 'exact')) = [];
        cd(fullfile(folderContent(1).folder, folderContent(1).name));
        testIfTestPresent = dir(mfilename);
        if isempty(testIfTestPresent)
            zipContent = dir(pwd);
            for iZip = 1:length(zipContent)
                if isdir(zipContent(iZip).name) && zipContent(iZip).name(1) ~= '.' && zipContent(iZip).name(1) ~= '_'
                    cd(zipContent(iZip).name);
                    if ~isempty(subdirname), cd(subdirname); end
                    break;
                end
            end
        end
        disp('****************');
        disp('NOW RUNNING TEST');
        disp('****************');
        try
            run(mfilename);
        catch
            cd(currentFolder);
            error(lasterror);
        end
        disp('***************');
        disp('TEST SUCCESSFUL');
        disp('***************');
        cd('..');
        cd('..');
        rmdir(tmpFolder, 's');
        cd(currentFolder);
        
    end
end

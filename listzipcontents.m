% listzipcontents() - Lists the contents of zip file with given extension
%
% Usage: 
%             >> filelist = listzipcontents('zipfile.zip','.m'); 
%             >> filelist = listzipcontents('zipfile.zip'); 
%
%Inputs :
%   zipFilename  - String specifying the fullpath and filename of the zip file 
%                  The function not support password-protected or encrypted zip 
%                  archives.
%   extension    - Extension of the files to include in the output list. If
%                  this argument is ignored. The function will list all the
%                  content of the zip file
% Outputs:
%   filelist     - Cell array with the names of the files with extension
%                  'extension' (if provided) in the zip file.
%   
%  See also: 
%
% Authors: Ramon Martinez-Cancino, SCCN/INC/UCSD 2019

%   Disclaimer
%   Based on the function listzipcontents.m by 
%   B.C. Hamans, UMC St Radboud, 2011 (B.C.Hamans@rad.umcn.nl)
%   The function was modified to accept an additional argument
%   for filtering file extensions.

function filelist = listzipcontents(zipFilename,extension)
zipJavaFile  = java.io.File(zipFilename);                 % Create a Java file of the ZIP filename.
zipFile      = org.apache.tools.zip.ZipFile(zipJavaFile); % Create a Java ZipFile and validate it.
entries      = zipFile.getEntries;                        % Extract the entries from the ZipFile.

% Loop through the entries and add to the file list.
filelistmp={};
while entries.hasMoreElements
    filelistmp = cat(1,filelistmp,char(entries.nextElement));
end

% Filter results by extension
filelist = {};
if exist('extension', 'var') && ~isempty(extension)
[trash, filenamenames, exts] =cellfun(@(x) fileparts(x),filelistmp,'UniformOutput',0); % ~ may not work in old MATLAB versions
     filespos = find(cell2mat(cellfun(@(x) strcmp(x, extension),exts,'UniformOutput',0)));
     if ~isempty(filespos)
         filelist =cellfun(@(x) cat(2,x,extension), filenamenames(filespos),'UniformOutput',0);
     end
else
    filelist = filelistmp;
end
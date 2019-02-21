% pop_nsginfo() - interactively modify NSG credentials and options
%
% Usage:
%   >> pop_nsginfo( 'key', val );
%
% Graphic interface:
%   'NSG user name' : NSG User name
%   'NSG user password': NSG password
%   'NSG key': Application ID assigned to the application. See if UMBRELLA
%              or DIRECT and update comment here.
%   'NSG url': NSG URL Default: 'https://nsgr.sdsc.edu:8443/cipresrest/v1'
%   'Output folder': Path to folder to store tenporray files.
%
% Outputs:
%   com    - Command line call
%
% See also: nsg_delete(), nsg_test(), nsg_run(), nsg_findclientjoburl()
%
% Authors:  Arnaud Delorme and Ramon Martinez-Cancino SCCN/INC/UCSD 2019

% Copyright (C)  Arnaud Delorme SCCN/INC/UCSD 2019
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

function com = pop_nsginfo( varargin )

com = '';
nsg_info;
if ~exist('nsgusername' , 'var'), nsgusername  = ''; end
if ~exist('nsgkey'      , 'var'), nsgkey       = 'TestingEEGLAB-BCE8EC90088F4475AE48190A1B87EF8D'; end
if ~exist('nsgpassword' , 'var'), nsgpassword  = ''; end
if ~exist('nsgurl'      , 'var'), nsgurl       = 'https://nsgr.sdsc.edu:8443/cipresrest/v1'; end
if ~exist('outputfolder', 'var'), outputfolder = ''; end

if nargin < 2
    commandload = [ '[filepathtmp] = uigetdir(''Select a folder'');' ...
                    'if filepathtmp(1) ~=0,' ...
                    '   set(findobj(''parent'', gcbf, ''tag'', ''outputfolder''), ''string'', filepathtmp);' ...
                    'end;' ...
                    'clear filepathtmp;' ];
                
    % which set to save
    % -----------------
    uilist = { ...
        { 'style' 'text' 'string' 'NSG user name' } ...
        { 'style' 'edit' 'string' nsgusername 'tag' 'nsgusername' } ...
        { } ...
        { 'style' 'text' 'string' 'NSG user password' } ...
        { 'style' 'edit' 'string' nsgpassword 'tag' 'nsgpassword' } ...
        { } ...
        { 'style' 'text' 'string' 'NSG key (see help message)' } ...
        { 'style' 'edit' 'string' nsgkey 'tag' 'nsgkey' } ...
        { } ...
        { 'style' 'text' 'string' 'NSG url' } ...
        { 'style' 'edit' 'string' nsgurl 'tag' 'nsgurl' } ...
        { } ...
        { 'style' 'text' 'string' 'Output folder' } ...
        { 'style' 'edit' 'string' outputfolder 'tag' 'outputfolder' } ...
        { 'Style', 'pushbutton', 'string', '...', 'callback', commandload } };
    geometry = { [3 3 1]  [3 3 1] [3 3 1] [3 3 1] [3 3 1] };
    
    [res,~,~,options] = inputgui( 'geometry', geometry, 'uilist', uilist, 'title', 'NSG settings - pop_nsginfo()', 'helpcom', 'pophelp(''pop_nsginfo'')');
    if isempty(res), return; end
else
    options = varargin;
end

% decode inputs
% -------------
fieldlist = { 'nsgusername'     'string'       []         ''; 
              'nsgkey'          'string'       []         'TestingEEGLAB-BCE8EC90088F4475AE48190A1B87EF8D'; 
              'nsgpassword'     'string'       []         '';
              'nsgurl'          'string'       []         'https://nsgr.sdsc.edu:8443/cipresrest/v1';
              'outputfolder'    'string'       []         '' };
g = finputcheck( options, fieldlist, 'pop_nsginfo');

save('-mat', filename, '-struct', 'g');

com = sprintf('pop_nsginfo(%s);', vararg2str(options));
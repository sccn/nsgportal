% pop_nsginfo() - interactively modify NSG credentials and options
%
% Usage:
%   >> pop_nsginfo( 'key', val );
%
% Inputs:
%   EEG       - input dataset
%   locutoff  - lower edge of the frequency pass band (Hz)  {0 -> lowpass}
%   hicutoff  - higher edge of the frequency pass band (Hz) {0 -> highpass}
%   filtorder - length of the filter in points {default 3*fix(srate/locutoff)}
%   revfilt   - [0|1] Reverse filter polarity (from bandpass to notch filter). 
%                     Default is 0 (bandpass).
%   usefft    - [0|1] 1 uses FFT filtering instead of FIR. Default is 0.
%   plotfreqz - [0|1] plot frequency response of filter. Default is 0.
%   firtype   - ['firls'|'fir1'] filter design method, default is 'firls'
%               from the command line
%   causal    - [0|1] 1 uses causal filtering. Default is 0.
%
% Outputs:
%   EEGOUT   - output dataset
%
% Author: Arnaud Delorme, CNL / Salk Institute, 2001
%
% See also: eegfilt(), eegfiltfft(), eeglab()

% Copyright (C) 2001 Arnaud Delorme, Salk Institute, arno@salk.edu
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

% 01-25-02 reformated help & license -ad 

function com = pop_nsginfo( varargin )

com = '';
nsg_info;
if ~exist('nsgkey'      , 'var'), nsgkey       = ''; end
if ~exist('nsgpassword' , 'var'), nsgpassword  = ''; end
if ~exist('nsgurl'      , 'var'), nsgurl       = ''; end
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
    geometry = { [3 3 1] [3 3 1] [3 3 1] [3 3 1] };
    
    [res,~,~,options] = inputgui( 'geometry', geometry, 'uilist', uilist, 'title', 'NSG settings - pop_nsginfo()', 'helpcom', 'pophelp(''pop_nsginfo'')');
    if isempty(res), return; end
else
    options = varargin;
end

% decode inputs
% -------------
fieldlist = { 'nsgkey'          'string'       []         ''; 
              'nsgpassword'     'string'       []         '';
              'nsgurl'          'string'       []         'https://nsgr.sdsc.edu:8443/cipresrest/v1';
              'outputfolder'    'string'       []         '' };
g = finputcheck( options, fieldlist, 'pop_nsginfo');

save('-mat', filename, '-struct', 'g');

com = sprintf('pop_nsginfo(%s);', vararg2str(options));


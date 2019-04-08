% eegplugin_nsgportal() - EEGLAB plugin for interfacing the NSG portal
%
% Usage:
%   >> eegplugin_nsgportal(fig);
%   >> eegplugin_nsgportal(fig, trystrs, catchstrs);
%
% Inputs:
%   fig        - [integer] EEGLAB figure
%   trystrs    - [struct]  "try" strings for menu callbacks. See notes. 
%   catchstrs  - [struct]  "catch" strings for menu callbacks. See notes. 
%
% Author: Arnaud Delorme, Ramon Martinez-Cancino SCCN, INC, UCSD, 2018
%
% See also: eeglab()

% Copyright (C) 2018 Arnaud Delorme
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

function vers = eegplugin_nsgportal(fig, trystrs, catchstrs)
    
    vers = 'nsgportal1.0';
    if nargin < 3
        error('eegplugin_nsgportal requires 3 arguments');
    end;
    
    % add loreta folder to path
    % -----------------------
    if ~exist('pop_nsg')
        p = which('eegplugin_nsgportal');
        p = p(1:findstr(p,'eegplugin_nsgportal.m')-1);
        addpath([ p vers ] );
    end
    
    % find tools menu
    % ---------------
    menu = findobj(fig, 'tag', 'tools'); 
    % tag can be 
    % 'import data'  -> File > import data menu
    % 'import epoch' -> File > import epoch menu
    % 'import event' -> File > import event menu
    % 'export'       -> File > export
    % 'tools'        -> tools menu
    % 'plot'         -> plot menu
    
    % menu callback commands
    % ----------------------
    catchstrs.store_and_hist = [ ...
                        '[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET); ' ...
                        'catch, errordlg2(lasterr, ''EEGLAB error''); LASTCOM= ''''; clear EEGTMP; end;' ...
                        'h(LASTCOM); disp(''Done.''); eeglab(''redraw'');' ];
    cominfo = [ trystrs.check_data 'com = pop_nsginfo;' catchstrs.add_to_hist ]; 
    comnsg  = [ trystrs.check_data 'com = pop_nsg;' catchstrs.add_to_hist ]; 
    %comimport = [ trystrs.check_ica 'EEG = loretaimport(EEG);' catchstrs.store_and_hist ];
    %complot1  = [ check_loreta 'pop_dipplot(EEG);' catchstrs.add_to_hist ];
    
    % create menus
    % ------------
    submenu = uimenu( menu, 'Label', 'NSG portal');
    set(menu, 'enable', 'on', 'userdata', 'startup:on;study:on');
    uimenu( submenu, 'Label', 'Change NSG portal settings and credentials', 'CallBack', cominfo);
    uimenu( submenu, 'Label', 'Execute EEGLAB scripts on NSG portal', 'CallBack', comnsg);
    
 
% nsg_uilistfiles() - Display files in the folder specified with the further
%                     option specified in the callback. Default calback
%                     opens image files and EEG sets.
%
% Usage: nsg_uilistfiles()
%
% Author: Ramon Martinez-Cancino and Arnaud Delorme, SCCN/INC/UCSD 2019
%
% See also: pop_nsg()

% Copyright (C) Ramon Martinez-Cancino SCCN/INC/UCSD 2019
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

function com = nsg_uilistfiles(pathname,varargin)
com = '';

tmp = dir(pathname);
liststring = {tmp.name};

if nargin < 1
   help listdlg2;
   return;
end

for index = 1:length(varargin)
	if iscell(varargin{index}), varargin{index} = { varargin{index} }; end
	if ischar(varargin{index}), varargin{index} = lower(varargin{index}); end
end
g = struct(varargin{:});

try  g.promptstring;  catch, g.promptstring  = 'Select a file';                end
try  g.selectionmode; catch, g.selectionmode = 'multiple';         end
try  g.listsize;      catch, g.listsize      = [];                 end
try  g.initialvalue;  catch, g.initialvalue  = [];                 end
try  g.name;          catch, g.name          = '';                 end
try  g.oklabel;       catch, g.oklabel       = 'OK';               end
try  g.okcallback;    catch, g.okcallback    = @defaultokcallback; end

%%
fig = figure('visible', 'off','name', g.name, 'units', 'normalized', 'tag', 'filebrowserapp');

allstr = '';
for index = 1:length(liststring)
    allstr = [ allstr '|' liststring{index} ];
end
allstr = allstr(2:end);

% Building GUI
geometry = {[1] [1] [1] [1 1]};
geomvert = [min(length(liststring), 10) 1 0.8 1];
if ~strcmpi(g.selectionmode, 'multiple') || ...
        (iscell(liststring) && length(liststring) == 1) || ...
        (isstr (liststring) && size(liststring,1) == 1 && isempty(find(liststring == '|')))
	if isempty(g.initialvalue), g.initialvalue = 1; end
    minval = 1;
	maxval = 1;
else
    minval = 0;
    maxval = 2;
end
usrdat = pathname;
listui = {{ 'Style', 'listbox', 'tag', 'listboxvals', 'string', allstr, 'max', maxval, 'min', minval } ...
          { 'Style', 'text', 'tag', 'textpath','string', shortenpath(pathname)}  ...
          {}...
		  { 'Style', 'pushbutton', 'string', 'Cancel', 'callback', ['set(gcbf, ''userdata'', ''cancel''); close(gcbf);'] }  ...
		  { 'Style', 'pushbutton', 'tag', 'buttonok', 'string', g.oklabel    , 'callback', ['set(gcbf, ''userdata'', ''ok'');'] } };

if ~isempty(g.promptstring)
	geometry = {[1] geometry{:}};
	geomvert = [[1] geomvert];
	listui = { { 'Style', 'text', 'string', g.promptstring } listui{:}};
end
[tmp, tmp2, allobj] = supergui( 'fig', fig, 'geomhoriz', geometry, 'geomvert', geomvert, 'uilist', listui, 'userdata',usrdat);

set(findobj('tag','filebrowserapp'),'Position',[0.2516 0.5194 0.1443 0.3222]);

%% Asigning callback to list
listobj  = findobj('tag', 'listboxvals');
set(listobj,'callback', @clickcallback);
okobj  = findobj('tag', 'buttonok');
set(okobj,'callback', g.okcallback);
end

% AUX functions
%---        
function clickcallback(obj,evt)
persistent chk
if isempty(chk)
      chk = 1;
      pause(0.5); %Add a delay to distinguish single click from a double click
      if chk == 1
          %fprintf(1,'\nI am doing a single-click.\n\n');
          chk = [];
      end
else
      chk = [];
      %fprintf(1,'\nI am doing a double-click.\n\n');
      val = get(obj, 'value');
      listmp = get(obj,'string');
      if ischar(listmp)
          filename = deblank(listmp(val,:));
      elseif iscell(listmp)
          filename = deblank(listmp{val});
      end
      filepath = get(get(obj,'Parent'), 'userdata');
      
      switch filename
          case '..'
                listmp = dir(fileparts(filepath));
                liststring = {listmp.name};
                set(obj,'string',liststring, 'value', 1);  
                set(get(obj,'Parent'), 'userdata',fileparts(filepath));
                set(findobj('tag','textpath'),'string',shortenpath(fileparts(filepath)));
          otherwise
              if isdir(fullfile(filepath,filename))
                listmp = dir(fullfile(filepath,filename));
                liststring = {listmp.name};
                if ~isempty(liststring)
                    set(obj,'string',liststring, 'value', 1);
                end
                set(get(obj,'Parent'), 'userdata',fullfile(filepath,filename));
                set(findobj('tag','textpath'),'string',fullfile(filepath,filename));
              end
      end
end
end

%--- 
function defaultokcallback(obj,evt)
val = get(findobj('tag', 'listboxvals'),'value');
listmp = get(findobj('tag', 'listboxvals'),'string');

if ischar(listmp)
    filename = deblank(listmp(val,:));
elseif iscell(listmp)
    filename = deblank(listmp{val});
end
filepath = get(get(obj,'Parent'), 'userdata');
filefull = fullfile(filepath,filename);
[tmp,tmp,ext] = fileparts(filefull);

tmpformats = imformats;
imfileext = cellfun(@(x) x{:},{tmpformats.ext},'UniformOutput',0);

switch ext(2:end)
    case 'fig'
        openfig(filefull);
    case imfileext
        img = imread(filefull);
        figure; imshow(img);
    case 'set'
        evalin('base', sprintf(['EEG = pop_loadset(''filename'', ''%s'',''filepath'',''%s'');[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, length(ALLEEG)+1); CURRENTSET = length(ALLEEG);'],filename,filepath ));
    case 'mat'
        evalin('base','load(filefull)');
    otherwise
        disp('pop_nsg: Not a valid file extension');
end
end

%---
function pathstring = shortenpath(pathname)
if length(pathname)>30
    pathstring = ['...' pathname(end-30:end)];
else
    pathstring = pathname;
end
end
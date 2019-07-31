% isnsgurl() - Check if strings is an NSG url
%
% Usage: 
%             >> urlflag = isnsgurl('https://nsgr.sdsc.edu/myjob')  
%
% Command line options :
%   'urlcheck'      - URL string
%                 
% Outputs:
%   urlflag  - [0|1] 0 indicates that is not a valid NSG URL, 1 indicates the
%              opposite
%   
%  See also:
%
% Authors:  Ramon Martinez-Cancino, SCCN/INC/UCSD 2019

% Copyright (C) Ramon Martinez-Cancino
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

function urlflag = isnsgurl(urlcheck)
if length(urlcheck)>= 21
    urlflag =fastif(strcmp('https://nsgr.sdsc.edu',urlcheck(1:21)),1,0);  
else
    urlflag = 0;
end
end
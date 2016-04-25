%
% (c) Steffen Mauch, 2015
% steffen.mauch@gmail.com
% Ingenieurbuero Mauch - Unorthodox Solutions
% www.unorthodox-solutions.de
%
% $Id: hasoFastSettings.m 1880 2015-09-14 16:31:24Z smauch $
%
% You can redistribute it and/or modify it under the terms of the GNU 
% General Public License as published by the 
% Free Software Foundation, version 2.
%
% This program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
% FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
% details.
%
% You should have received a copy of the GNU General Public License along with
% this program; if not, write to the Free Software Foundation, Inc., 51
% Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

nLenses = 14;             % nb lenses in x/y-direction
nLensesSqr = nLenses*nLenses;
f = 4796;           % in units [mu]
pixelSize = 7.4;    % in units [um]
nbPixelsPerLens = 16;
nbPixels = 224;
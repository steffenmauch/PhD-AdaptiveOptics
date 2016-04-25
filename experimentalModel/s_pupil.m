% s-function to mask spots to fit round pupil
%
% (c) Steffen Mauch, 2011-2015
% steffen.mauch@gmail.com
% Ingenieurbuero Mauch - Unorthodox Solutions
% www.unorthodox-solutions.de
%
% $Id: s_pupil.m 1880 2015-09-14 16:31:24Z smauch $
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

function [sys,x0,str,ts] = s_pupil(~,~,u,flag,dimMatrix)
switch flag
    case 0
        
        sizes                   = simsizes;
        sizes.NumContStates     = 0;
        sizes.NumDiscStates     = 0;
        sizes.NumOutputs        = dimMatrix.^2;
        sizes.NumInputs         = dimMatrix.^2;
        sizes.DirFeedthrough    = 1;
        sizes.NumSampleTimes    = 1;
        sys                     = simsizes(sizes);
        
        x0                      = [];
        str                     = [];
        ts                      = [0 0];
        
    case 3
        
        temp_values = reshape(u,dimMatrix,dimMatrix);
        
        x       = -1:2/(dimMatrix-1):1;
        [X, Y]  = meshgrid(x,x);
        [~, r]  = cart2pol(X,Y);
        idx     = r > 1;
        idx2    = ( r <= 1 );
        r(idx)  = 0;
        r(idx2) = 1;
        
        temp    = r.*temp_values;
        sys     = temp(:);
end
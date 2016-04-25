%
% (c) Steffen Mauch, 2011-2015
% steffen.mauch@gmail.com
% Ingenieurbuero Mauch - Unorthodox Solutions
% www.unorthodox-solutions.de
%
% $Id: s_zernike.m 1880 2015-09-14 16:31:24Z smauch $
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

function [sys,x0,str,ts] = s_zernike(t,x,~,flag,dimMatrix,zernik1,zernik2,rotate)

switch flag
    case 0
        
        sizes = simsizes;
        sizes.NumContStates     = 0;
        sizes.NumDiscStates     = dimMatrix.^2;
        sizes.NumOutputs        = dimMatrix.^2;
        sizes.NumInputs         = 0;
        sizes.DirFeedthrough    = 0;
        sizes.NumSampleTimes    = 0;
        sys                     = simsizes(sizes);
        
        str                     = [];
        ts                      = [];
        
        x = -1:2/(dimMatrix-1):1;
        [X,Y] = meshgrid(x,x);
        [theta,r] = cart2pol(X,Y);
        idx = r<=1;
        z = zeros(size(X));
        z(idx) = zernfun(zernik1,zernik2,r(idx),theta(idx));
        
        x0 = imrotate( z , rotate, 'bilinear', 'crop')*5*10^-7;
        x0 = x0(:);
        
    case 3
        sys = x;
end
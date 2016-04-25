% s-function to show quiver plot
%
% (c) Steffen Mauch, 2011-2015
% steffen.mauch@gmail.com
% Ingenieurbuero Mauch - Unorthodox Solutions
% www.unorthodox-solutions.de
%
% $Id: s_quiver.m 1880 2015-09-14 16:31:24Z smauch $
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

function [sys,x0,str,ts] = s_quiver(t,x,u,flag,sampleTime,dimMatrix,enable,label_title)
switch flag
    case 0
        
        sizes = simsizes;
        sizes.NumContStates  = 0;
        sizes.NumDiscStates  = 1;
        sizes.NumOutputs     = 0;
        sizes.NumInputs      = dimMatrix.^2*2;
        sizes.DirFeedthrough = 1;
        sizes.NumSampleTimes = 1;
        sys = simsizes(sizes);
        
        x0=0;
        str=[];
        ts=[sampleTime 0];
        
        if( enable  == 1 )
            x0 = figure;
        end
        
    case 3
        if( enable )
            u_length = length(u);
            
            dx = reshape(u(1:u_length/2),dimMatrix,dimMatrix);
            dy = reshape(u(u_length/2+1:u_length),dimMatrix,dimMatrix);
            figure(x);
            quiver(1:dimMatrix, 1:dimMatrix,dx,dy, 'AutoScale','off');
            title(label_title);
        end
end
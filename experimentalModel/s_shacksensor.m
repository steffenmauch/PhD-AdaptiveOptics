% s-function to model behavior of ideal Shack-Hartmann Wavefront Sensor
% meaning no problems regarding ordering/segmentation
%
% (c) Steffen Mauch, 2011-2015
% steffen.mauch@gmail.com
% Ingenieurbuero Mauch - Unorthodox Solutions
% www.unorthodox-solutions.de
%
% $Id: s_shacksensor.m 1880 2015-09-14 16:31:24Z smauch $
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

function [sys,x0,str,ts] = s_shacksensor(t,x,u,flag,sampleTime,dimMatrix_i,dimMatrix_o, noiseSHWFS, scaleSHWFS, aperture)
switch flag
    case 0
        
        sizes                   = simsizes;
        sizes.NumContStates     = 0;
        sizes.NumDiscStates     = 0;
        sizes.NumOutputs        = dimMatrix_o.^2*2;
        sizes.NumInputs         = dimMatrix_i.^2;
        sizes.DirFeedthrough    = 1;
        sizes.NumSampleTimes    = 1;
        sys                     = simsizes(sizes);
        
        x0                      = [];
        str                     = [];
        ts                      = [sampleTime 0];
        
        scale = floor(dimMatrix_i/dimMatrix_o);
        if( scale*dimMatrix_o+2 ~= dimMatrix_i )
            error('quotient of dimMatrix_i and dimMatrix_o must be an integer');
        end
        
    case 3
        
        temp_values = reshape(u, dimMatrix_i, dimMatrix_i);
        if( aperture == 1 )
        
            x       = -1:2/(dimMatrix_i-1):1;
            [X, Y]  = meshgrid(x,x);
            idx     = (sqrt(X.^2+Y.^2) > 1.05);

            temp_values(idx)    = 0;
        end
        
        [dx, dy] = gradient( temp_values );
        dx = dx(2:end-1,2:end-1);
        dy = dy(2:end-1,2:end-1);
        
        scale = round(dimMatrix_i/dimMatrix_o);
        
        tempX = mat2cell(dx, scale*ones(dimMatrix_o,1), scale*ones(dimMatrix_o,1) );
        sysX = cellfun( @(x) mean(x(:)), tempX );
        sysX = sysX * scaleSHWFS + noiseSHWFS * rand(dimMatrix_o,dimMatrix_o);
        
        tempY = mat2cell(dy, scale*ones(dimMatrix_o,1), scale*ones(dimMatrix_o,1) );
        sysY = cellfun( @(x) mean(x(:)), tempY );
        sysY = sysY * scaleSHWFS + noiseSHWFS * rand(dimMatrix_o,dimMatrix_o);
        
        sys = [sysX(:); sysY(:)];

end
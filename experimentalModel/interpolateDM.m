% 
% (c) Steffen Mauch, 2015
%  steffen.mauch@gmail.com
% Ingenieurbuero Mauch - Unorthodox Solutions
% www.unorthodox-solutions.de
%
% $Id: interpolateDM.m 1880 2015-09-14 16:31:24Z smauch $
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

dimY = 56;
dimU = 24;

actuatorPlace = zeros(dimU,3);
actuatorPlace(:,1) = 1:dimU;

inCount = 8;
outCount = 16;
radIn = 16;
radOut = 48;

actuatorPlace(1:inCount,2) = ceil( ( radIn*sin( (0:1/inCount:1-1/inCount)*2*pi ) + radIn ) / 2 + (dimY-radIn)/2 );
actuatorPlace(1:inCount,3) = ceil( ( radIn*cos( (0:1/inCount:1-1/inCount)*2*pi ) + radIn ) / 2 + (dimY-radIn)/2 );

actuatorPlace(inCount+1:end,2) = ceil( ( radOut*sin( (0:1/outCount:1-1/outCount)*2*pi ) + radOut ) / 2 + (dimY-radOut)/2 );
actuatorPlace(inCount+1:end,3) = ceil( ( radOut*cos( (0:1/outCount:1-1/outCount)*2*pi ) + radOut ) / 2 + (dimY-radOut)/2 );

load('DMModel-experimental.mat','rsys')
DMmodel = rsys*260;
DMmodel_static = DMmodel.C*(-DMmodel.A\DMmodel.B)+DMmodel.D;
u = zeros(dimU,1);
u(8) = 1;

z = DMmodel_static*u;

x = actuatorPlace(:,2);
y = actuatorPlace(:,3);
v = z;

[xq,yq] = meshgrid( 1:dimY, 1:dimY);

F1 = scatteredInterpolant(x,y,v ,'natural','linear');
vq = griddata(x,y,v,xq,yq, 'linear');

figure();
%surf(xq,yq,vq);
surf(xq,yq, F1(xq,yq) );
hold on;
plot3(x,y,v,'yo','LineWidth',5)

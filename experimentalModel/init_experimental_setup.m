%
% (c) Steffen Mauch, 2015
% steffen.mauch@gmail.com
% Ingenieurbuero Mauch - Unorthodox Solutions
% www.unorthodox-solutions.de
%
% $Id: init_experimental_setup.m 1969 2015-12-11 10:10:15Z smauch $
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

addpath( '../zonalReconstruction' )

%load('simulink-aif-20150902.mat')
load('../controllerSynthesisDM/workspace-hinfstruct-peak3dot32.mat')

try
    load('DMModel-experimental-AIF.mat','rsys', 'poke', 'transferMatrix')
    aif_cal = transferMatrix;
catch

end

DMmodel = rsys*260;

DMmodel_static = DMmodel.C*(-DMmodel.A\DMmodel.B)+DMmodel.D;
staticDMInput = zeros(24,1);
staticDMInput(3) = 1;

%% dimSquareMatrix must be a multiple of dimSlopeMatrix
%  otherwise the simulation won't work

% dimension of wavefront data during simulation
dimSquareMatrix = 58;

% dimension of the slope data from the wavefront
% sensor for calculating the signals for the DM
dimSlopeMatrix = 14;

% number of actuators of the DM
dimActuator = 24;

load('../controllerSynthesisDM/mirror-DM-STE-20150826.mat','ident_normalized_static')
uval.deltaDM = ss( ones(dimActuator,dimActuator) );


Ts = 1/800;

% these values have as unit [s]
sampleTimeWavefrontSensor = Ts;

% evaluation delay due to image processing
% this value has as unit [ms]
delayWavefront = 1.15;

K1d = c2d( K1, Ts/2);
CL1d_not_reduced = lft(plant([1:sizeDM (sizeDM*2+1):(sizeDM*3) (sizeDM+1):(sizeDM*2)], ...
        [1:sizeDM (sizeDM+1):(sizeDM*2)]),d2c(K1d) );

%%

dimY = dimSquareMatrix;
dimU = dimActuator;

actuatorPlace = zeros(dimU,3);
actuatorPlace(:,1) = 1:dimU;

inCount = 8;
outCount = 16;
radIn = 16;
radOut = 46;

actuatorPlace(1:inCount,2) = ceil( ( radIn*sin( (0:1/inCount:1-1/inCount)*2*pi ) + radIn ) / 2 + (dimY-radIn)/2 );
actuatorPlace(1:inCount,3) = ceil( ( radIn*cos( (0:1/inCount:1-1/inCount)*2*pi ) + radIn ) / 2 + (dimY-radIn)/2 );

actuatorPlace(inCount+1:end,2) = ceil( ( radOut*sin( (0:1/outCount:1-1/outCount)*2*pi ) + radOut ) / 2 + (dimY-radOut)/2 );
actuatorPlace(inCount+1:end,3) = ceil( ( radOut*cos( (0:1/outCount:1-1/outCount)*2*pi ) + radOut ) / 2 + (dimY-radOut)/2 );

layoutActuator = actuatorPlace;
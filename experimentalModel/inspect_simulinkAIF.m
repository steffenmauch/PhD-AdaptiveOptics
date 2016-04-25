% script to evaluate simulink AIF
% (c) Steffen Mauch, 2015
%  steffen.mauch@gmail.com
% Ingenieurbuero Mauch - Unorthodox Solutions
% www.unorthodox-solutions.de
%
% $Id: inspect_simulinkAIF.m 1880 2015-09-14 16:31:24Z smauch $
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

load('simulink-aif-20150902.mat')

cm = controlMatrix.Data(:,:,end);
%aif_cal = inv(cm.'*cm)*cm.';
aif_cal = (cm.'*cm)\cm.';

nbActuators = size(aif_cal,2);
for k=1:nbActuators
    x = reshape(cm(k,1:196),14,14);
    y = reshape(cm(k,197:end),14,14);
    surf( zonalReconstruction(x,y,1) )
    %pause
end

hasoFastSettings();
poke = cm';
[transferMatrix, ~, modes] = svdinverse( poke );
%transferMatrix = v*d^-1*u.';
figure();
for ii=1:size(modes,2)
    temp = poke * modes(:,ii);
    tempX = reshape( temp(1:length(poke)/2), nLenses, nLenses);
    tempY = reshape( temp(length(poke)/2+1:end), nLenses, nLenses);
    Sx = tempX;%*(pixelSize/f)*nbPixelsPerLens*pixelSize;
    Sy = tempY;%*(pixelSize/f)*nbPixelsPerLens*pixelSize;

    W = zonalReconstruction(Sx, Sy, 1);
    subplot(ceil(nbActuators/4),4,ii);
    %surf(W);
    imagesc(W, axs);
    colorbar
    title( sprintf('mode: %d',ii) );
end
suptitle('SVD modes in deformable mirror (DM) space');
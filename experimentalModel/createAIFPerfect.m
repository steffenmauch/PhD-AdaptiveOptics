%
% (c) Steffen Mauch, 2015
% steffen.mauch@gmail.com
% Ingenieurbuero Mauch - Unorthodox Solutions
% www.unorthodox-solutions.de
%
% $Id: createAIFPerfect.m 1882 2015-09-14 19:27:48Z smauch $
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

init_experimental_setup();

aperture = 1;
noiseSHWFS = 0;
scaleSHWFS = 1/100;

load('../controllerSynthesisDM/mirror-DM-STE-20150826.mat','rsys')
DMmodel = rsys*260;
DMmodel_static = DMmodel.C*(-DMmodel.A\DMmodel.B)+DMmodel.D;

dimAct = size(DMmodel_static,1);
dimXSlopesIdx = 1:196;
dimYSlopesIdx = 197:196*2;

poke = zeros( dimAct, dimYSlopesIdx(end));

for k = 1:dimAct
    
    u = zeros(dimAct,1);
    u(k) = 1;
    
    x = actuatorPlace(:,2);
    y = actuatorPlace(:,3);
    v = DMmodel_static*u;
    
    [xq,yq] = meshgrid( 1:dimY, 1:dimY);
    
    F1 = scatteredInterpolant(x,y,v ,'natural','linear');
    DM_surface = F1(xq,yq);

    if( aperture == 1 )

        x       = -1:2/(dimSquareMatrix-1):1;
        [X, Y]  = meshgrid(x,x);
        idx     = (sqrt(X.^2+Y.^2) > 1.05);

        DM_surface(idx)    = 0;
    end

    [dx, dy] = gradient( DM_surface );
    dx = dx(2:end-1,2:end-1);
    dy = dy(2:end-1,2:end-1);

    scale = round(dimSquareMatrix/dimSlopeMatrix);

    tempX = mat2cell(dx, scale*ones(dimSlopeMatrix,1), scale*ones(dimSlopeMatrix,1) );
    sysX = cellfun( @(x) mean(x(:)), tempX );
    sysX = sysX * scaleSHWFS + noiseSHWFS * rand(dimSlopeMatrix,dimSlopeMatrix);

    tempY = mat2cell(dy, scale*ones(dimSlopeMatrix,1), scale*ones(dimSlopeMatrix,1) );
    sysY = cellfun( @(x) mean(x(:)), tempY );
    sysY = sysY * scaleSHWFS + noiseSHWFS * rand(dimSlopeMatrix,dimSlopeMatrix);

    poke(k,:) = [sysX(:); sysY(:)];
end

nbActuators = dimAct;
for k=1:nbActuators
    x = reshape(poke(k,1:196),14,14);
    y = reshape(poke(k,197:end),14,14);
    surf( zonalReconstruction(x,y,1) )
    %pause
end

poke = poke';

hasoFastSettings();
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
    imagesc(W);
    colorbar
    title( sprintf('mode: %d',ii) );
end
suptitle('SVD modes in deformable mirror (DM) space');

choice = questdlg('Do you want to save reduced workspace?');
switch choice
    case 'No'
        
    case 'Yes'
        save( 'DMModel-experimental-AIF.mat','rsys', 'poke', 'transferMatrix' )
end
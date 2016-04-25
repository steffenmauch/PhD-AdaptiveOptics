function [Minv,gains,modes] = svdinverse(M,varargin)
%function [Minv,gains,modes] = svdinverse(M,modesRemoved)
% does the SVD inverse of a matrix with mode removal
% Example:
% [D,gain,modes] = svdinverse(M,1);
% for ii=1:size(modes,2)
%     modePhs{ii} = reshape(M * modes(:,ii),ny,nx);
%     figure();
%     plot(modePhs{ii});
%     title( sprintf('mode: %d',ii) );
%     pause(0.01);
% end;

if( nargin == 2 )
    modesRemoved = varargin{1};
else
    modesRemoved = 0;
end;

[u,ss,v] = svd(M);
sv = diag(ss);
gains = sv;
svi = 1.0./sv;
si = zeros(size(ss,2),size(ss,1)); 
%nf; semilogy(sv,'*b-'); title('svd gains-AOA recon');
for ii=1:size(svi,1)-modesRemoved
    si(ii,ii) = svi(ii); 
end

Minv = v*si*u';

if( nargout >= 3 )
    %calculate the mode shapes
    modes = v;
end

return;
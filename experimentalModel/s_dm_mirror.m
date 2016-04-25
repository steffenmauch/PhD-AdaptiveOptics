%% M-file s_dm_mirror
%
% (c) Steffen Mauch, 2011-2015
% steffen.mauch@gmail.com
% Ingenieurbuero Mauch - Unorthodox Solutions
% www.unorthodox-solutions.de
%
% $Id: s_dm_mirror.m 1880 2015-09-14 16:31:24Z smauch $
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

   function [sys,x0,str,ts] = s_dm_mirror(t,x,u,flag,sampleTime,dimActuator,dimMatrix)
   persistent dm_mirror;
   persistent voltages;
   
   switch flag
   case 0
      
      sizes = simsizes;
      sizes.NumContStates  = 0;
      sizes.NumDiscStates  = 0;
      %sizes.NumOutputs     = 2;
      sizes.NumOutputs     = dimMatrix.^2;
      sizes.NumInputs      = dimActuator;
      sizes.DirFeedthrough = 1;
      sizes.NumSampleTimes = 1; 
      sys = simsizes(sizes);
      
      x0=[];
      str=[];
      ts=[sampleTime 0];
      
      voltages = [0, 50, 100, 150, 200];
%       dm_mirror = createLookupTable_dm(dimActuator, voltages, dimMatrix);
%       save('dm_mirror_model.mat','dm_mirror');
      load dm_mirror_model.mat
      
   case 3
      sys = zeros(dimMatrix.^2,1);
      
      if ~isempty(dm_mirror) && ~isempty(voltages)
          for k=1:length(u)
              %[k u(k)]
              
            temp = find( voltages == u(k) );
            if( temp )
                sys = sys + eval( sprintf('dm_mirror.act%i(:,%i)',k,temp ) );
            else
                temp = find( sort( [voltages u(k)] ) == u(k) );
                temp1 = eval( sprintf('dm_mirror.act%i(:,%i)',k,temp ) );
                temp2 = eval( sprintf('dm_mirror.act%i(:,%i)',k,(temp-1) ) );
                sys = sys + (temp1-temp2)./(voltages(temp)-voltages(temp-1)).*u(k);
            end
            
          end
      end
      
   end
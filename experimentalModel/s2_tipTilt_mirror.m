%% M-file s2_tipTilt_mirror
%
% (c) Steffen Mauch, 2011-2015
% steffen.mauch@gmail.com
% Ingenieurbuero Mauch - Unorthodox Solutions
% www.unorthodox-solutions.de
%
% $Id: s2_tipTilt_mirror.m 1880 2015-09-14 16:31:24Z smauch $
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

function s2_tipTilt_mirror(block)

% Musterbeispiel level-2 Matlab M-file s-function
%
% -------------------------------------------------------------------------
%
% Beschreibung: Beispiel einer level-2 Matlab M-file s-function zur
%               Simulation des dynamischen Verhaltens eines einfachen
%               Systems; 
% -------------------------------------------------------------------------
%
% Eingaenge:    u1(1) ... u1
%
%               u2(1) ... u2
%
% Zustaende:    x(1)  ... x1
%               x(2)  ... x2
%
% Ausgaenge:    y1(1) ... x(1)
%               y1(2) ... x(2)
%
%               y2(1) ... exp(x1)*cosh(x2)
%
% Parameter:    p(1)  ... a
%               p(2)  ... b
%               p(3)  ... Vektor der Anfangswerte x0 ([x(1),x(2)] fuer t=0)
%
% -------------------------------------------------------------------------
% Abtastzeit (sample time): zeitkontinuierlich (continuous)
% -------------------------------------------------------------------------


% Die Funktion setup (s.u.) dient der Initialiserung des Matlab Objektes
% (block). Im Objekt block sind alle fuer die Simulation in Simulink
% notwendigen Eigenschaften (Eingaenge, Zustaende, Ausgaenge, Parameter,
% usw.) des dynamischen Systems (math. Modell) zusammengefasst.
setup(block);

% -------------------------------------------------------------------------
% Initialisierung des Simulationsobjektes block
% -------------------------------------------------------------------------

function setup(block)
  
  % Anzahl der Eingangs- und Ausgangsports
  block.NumInputPorts  = 1;
  block.NumOutputPorts = 2;
  
  % Setup port properties to be inherited or dynamic
% block.SetPreCompInpPortInfoToDynamic;
% block.SetPreCompOutPortInfoToDynamic;

  % Anzahl der zeitkontinuierlichen Zustaende
  block.NumContStates = 8;

  % Anzahl der Parameter
  block.NumDialogPrms = 5;
  
  % Dimensionen der Eingangsports
  % Flag DirectFeedthrough kennzeichnet, ob ein Eingang direkt an einem
  % Ausgang auftritt, d.h. y=f(u)
  block.InputPort(1).Dimensions        = 2;
  block.InputPort(1).SamplingMode = 'Sample';
  block.InputPort(1).DirectFeedthrough = true;

  % Dimensionen der Ausgangsports  
  block.OutputPort(1).Dimensions       = block.DialogPrm(2).Data.^2;
  block.OutputPort(1).SamplingMode = 'Sample';
  
  % Dimensionen der Ausgangsports  
  block.OutputPort(2).Dimensions       = 1;
  block.OutputPort(2).SamplingMode = 'Sample';
  
  % Einstellen der Abtastzeit: [0 0] wird verwendet fuer die
  % zeitkontinuierliche Simulation.
  % block.SampleTimes = [block.DialogPrm(1).Data 0];
  block.SampleTimes = [0 0];
  
  
  % ------------------------------------------------
  % NICHT VERAENDERN
  % ------------------------------------------------
  % 
  % Registrieren der einzelnen Methoden
  % Hier: InitializeConditions ... Initialisierung
  %       Outputs ...       Berechnung der Ausgaenge
  %       Derivatives ...   Berechnung der Zustaende
  %       Terminate ...     Konsistentes Beenden der Simulation

  block.RegBlockMethod('InitializeConditions',    @InitConditions); 
  block.RegBlockMethod('Outputs',                 @Output);  
  block.RegBlockMethod('Derivatives',             @Derivatives);  
  block.RegBlockMethod('Terminate',               @Terminate);
  block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
  block.RegBlockMethod('Start',                   @Start);
  block.RegBlockMethod('Update',                  @Update);



%%
%% PostPropagationSetup:
%%   Functionality    : Setup work areas and state variables. Can
%%                      also register run-time methods here
%%   Required         : No
%%   C-Mex counterpart: mdlSetWorkWidths
%%
function DoPostPropSetup(block)
block.NumDworks = 1;
  
  block.Dwork(1).Name            = 'x1';
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 0;      % double
  block.Dwork(1).Complexity      = 'Real'; % real
  block.Dwork(1).UsedAsDiscState = true;
  

%%
%% Start:
%%   Functionality    : Called once at start of model execution. If you
%%                      have states that should be initialized once, this 
%%                      is the place to do it.
%%   Required         : No
%%   C-MEX counterpart: mdlStart
%%
function Start(block)

block.Dwork(1).Data = 0;


% -------------------------------------------------------------------------
% Setzen der Anfangsbedingungen der Zustaende
% -------------------------------------------------------------------------

 function InitConditions(block)
    dimMatrix = block.DialogPrm(2).Data;
    block.OutputPort(1).Data = zeros(dimMatrix.^2,1);
    
    block.OutputPort(2).Data = 0;
    % Schreiben auf Objekt block (NICHT VERAENDERN)
    block.ContStates.Data = [0 0 0 0 0 0 0 0];
%   
%   % Einlesen der Parameter des Systems
% %  a   = block.DialogPrm(1).Data; % bei Bedarf
% %  b   = block.DialogPrm(2).Data;
%   x0 = block.DialogPrm(3).Data;
%   
%   % Eingabe der Anfangsbedingungen
%   x=x0;
%   


%%
%% Update:
%%   Functionality    : Called to update discrete states
%%                      during simulation step
%%   Required         : No
%%   C-MEX counterpart: mdlUpdate
%%
function Update(block)

block.Dwork(1).Data = block.InputPort(1).Data(1);


% -------------------------------------------------------------------------
% Berechnen der Ausgaenge
% -------------------------------------------------------------------------
% 
 function Output(block)
 % 
 % Shortcut fuer den Zustand
   x = block.ContStates.Data;
   
    dimMatrix = block.DialogPrm(2).Data;
    strokeTipTilt = block.DialogPrm(3).Data;
    enableDyn = block.DialogPrm(4).Data;
    %u =  block.InputPort(1).Data;


        temp1 = zeros(dimMatrix, dimMatrix);
        temp2 = zeros(dimMatrix, dimMatrix);
        
        for k=1:dimMatrix
            temp1(k,:) = (-0.5:1/(dimMatrix-1):0.5);
            temp2(:,k) = (-0.5:1/(dimMatrix-1):0.5).';
        end
        
        if( enableDyn )
            temp3 = temp1.*x(1) + temp2.*x(5);
        else
            temp3 = temp1 + temp2;
        end
        block.OutputPort(1).Data = temp3(:).*strokeTipTilt;
        
  
   block.OutputPort(2).Data = x(1);
 

% -------------------------------------------------------------------------
% Berechnen der Zustaende
% -------------------------------------------------------------------------

 function Derivatives(block)
% 
%   % Einlesen der Parameter des Systems
%   a   = block.DialogPrm(1).Data;
%   b   = block.DialogPrm(2).Data;
%   
    enableLimit = block.DialogPrm(5).Data;

   % Shortcut fuer den Eingang
   u = block.InputPort(1).Data;
     
   % Shortcut fuer die Zustaende
   x = block.ContStates.Data;
   
   % Berechnen der Zustaende

   %%  PT4-Glied
   
   a0 = 3.636e14;
   a1 = 2.961e11;
   a2 = 9.782e07;
   a3 = 1.615e04;
   
   b0 = 3.636e14;
   
   if( enableLimit )
      if( u(1) > 1 )
          u(1) = 1;
      elseif( u(1) < -1 )
          u(1) = -1;
      end
      if( u(2) > 1 )
          u(2) = 1;
      elseif( u(2) < -1 )
          u(2) = -1;
      end
   end
   
   dx(1) = x(2);
   dx(2) = x(3);
   dx(3) = x(4);
   dx(4) = -a3*x(4) -a2*x(3) -a1*x(2) - a0*x(1) + b0*u(1);
  
   dx(5) = x(6);
   dx(6) = x(7);
   dx(7) = x(8);
   dx(8) = -a3*x(8) -a2*x(7) -a1*x(6) - a0*x(5) + b0*u(2);
   
%   % Schreiben auf Objekt block
   block.Derivatives.Data = dx;


% -------------------------------------------------------------------------
% Operationen am Ende der Simulation
% -------------------------------------------------------------------------

% Die function Terminate wird hier nicht verwendet,
% muss aber vorhanden sein!
function Terminate(block)

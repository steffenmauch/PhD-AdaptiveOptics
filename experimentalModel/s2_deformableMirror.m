%% M-file s2_tipTilt_mirror
%
% (c) Steffen Mauch, 2011-2015
% steffen.mauch@gmail.com
% Ingenieurbuero Mauch - Unorthodox Solutions
% www.unorthodox-solutions.de
%
% $Id: s2_deformableMirror.m 1880 2015-09-14 16:31:24Z smauch $
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

function s2_deformableMirror(block)

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
  block.NumOutputPorts = 1;
  
  % Setup port properties to be inherited or dynamic
% block.SetPreCompInpPortInfoToDynamic;
% block.SetPreCompOutPortInfoToDynamic;

  % Anzahl der zeitkontinuierlichen Zustaende
  block.NumContStates = 0;

  % Anzahl der Parameter
  block.NumDialogPrms = 3;
  
  % Dimensionen der Eingangsports
  % Flag DirectFeedthrough kennzeichnet, ob ein Eingang direkt an einem
  % Ausgang auftritt, d.h. y=f(u)
  block.InputPort(1).Dimensions        = block.DialogPrm(1).Data;
  block.InputPort(1).SamplingMode = 'Sample';
  block.InputPort(1).DirectFeedthrough = true;

  % Dimensionen der Ausgangsports  
  block.OutputPort(1).Dimensions       = block.DialogPrm(2).Data.^2;
  block.OutputPort(1).SamplingMode = 'Sample';
  
  
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


%%
%% Update:
%%   Functionality    : Called to update discrete states
%%                      during simulation step
%%   Required         : No
%%   C-MEX counterpart: mdlUpdate
%%
function Update(block)


% -------------------------------------------------------------------------
% Berechnen der Ausgaenge
% -------------------------------------------------------------------------
% 
 function Output(block)
     %
     % Shortcut fuer den Eingang
     u = block.InputPort(1).Data;
     
     %dimActuator = block.DialogPrm(1).Data;
     dimSquareMatrix = block.DialogPrm(2).Data;
     actuatorPlace = block.DialogPrm(3).Data;
     
     x = actuatorPlace(:,2);
     y = actuatorPlace(:,3);
     v = u;
     
     [xq,yq] = meshgrid( 1:dimSquareMatrix, 1:dimSquareMatrix);
     
     F1 = scatteredInterpolant(x,y,v ,'natural','linear');
     
     output = F1(xq,yq);

     block.OutputPort(1).Data = output(:);


% -------------------------------------------------------------------------
% Berechnen der Zustaende
% -------------------------------------------------------------------------
%s
 function Derivatives(block)
% 



% -------------------------------------------------------------------------
% Operationen am Ende der Simulation
% -------------------------------------------------------------------------

% Die function Terminate wird hier nicht verwendet,
% muss aber vorhanden sein!
function Terminate(block)

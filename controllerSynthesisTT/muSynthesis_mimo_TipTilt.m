close all;

Ts = 1/(850*2);
delay = 2*Ts;


A = [0 1 0; 0 0 1; -1.584e10 -2.378e7 -6432];
B = [0 0 1].';
C = [1.584e10 0 0];
D = 0;

A_act = [A, zeros(3,3); zeros(3,3) A];
B_act = [B zeros(3,1); zeros(3,1) B];
C_act = [C zeros(1,3); zeros(1,3) C];
D_act = [zeros(2,2)];

%     10% uncertanty to the input added!
actuator_channel1 = ss(A,B,C,D) + ultidyn('delta1',[1 1],'Bound',1)/10 ;
actuator_channel2 = ss(A,B,C,D) + ultidyn('delta2',[1 1],'Bound',1)/10 ;

actuator = [actuator_channel1 0; 0 actuator_channel2];

[den,num] = pade(delay,3);
delay = tf(den,num)*([1 0; 0 1]);

% create the plant
Wout1 = ss([1 0;0 1]);

systemnames = 'delay actuator Wout1';
inputvar = '[ disturb(2); u(2) ]';
outputvar = '[ Wout1; delay; u ]';
input_to_Wout1 = '[ disturb(1)-actuator(1); disturb(2)-actuator(2) ]';
input_to_delay = '[ disturb(1)-actuator(1); disturb(2)-actuator(2) ]';
input_to_actuator = '[ u ]';
plant = sysic;

% create the complete model
Wplant = 1;
Wplant = Wplant*[1 0;0 1];

Woutput = 1000*tf( conv([10 1],[1/1200 1]), conv([100 1],[1/6 1]) );
Woutput = Woutput*[1 0; 0 1];

WactingValue = 0.3*tf( [1/80 1], [1/10000 1] );
WactingValue = WactingValue*[1 0; 0 1];

systemnames = 'Wplant Woutput plant WactingValue';
inputvar = '[ w(2); u(2) ]';
outputvar = '[ Woutput; WactingValue; plant(3); plant(4) ]';
input_to_Wplant = '[ w(1); w(2) ]';
input_to_plant = '[ Wplant; u ]';
input_to_Woutput = '[ plant(1); plant(2) ]';
input_to_WactingValue = '[ plant(5); plant(6) ]';
overallPlant = sysic;


% Reglerentwurf 1
C1 = ltiblock.ss('C',8,2,2);

C1.y = 'u'; 
C1.u = '[+delay]' ;

[M,Delta,Blkstruct]=lftdata(overallPlant);
for k = 1:(2)
    eval( ['M.u{' sprintf('%i',k) '}=''u1(' sprintf('%i',k) ')'';'] );
    eval( ['M.y{' sprintf('%i',k) '}=''y1(' sprintf('%i',k) ')'';'] );
end

% Connect the blocks together
%overallPlant = overallPlant.NominalValue;
T0 = connect(M,C1,{'u1','w'},{'y1','[+Woutput]','[+WactingValue]'});


nxD = 5; % D-scale order for both uncertainty channels
D1 = ltiblock.tf('D1', nxD, nxD );
D2 = ltiblock.tf('D2', nxD, nxD );

test = blkdiag(eye(1)-D1,eye(1)-D2,1,1,1,1);
test1 = blkdiag(eye(1)-D1,eye(1)-D2,1,1);

T0 = (test)\T0*(test1) ;

options = hinfstructOptions;
options.Display = 'iter';
options.MaxIter = 10000;
options.RandomStart = 3;
tic
[T,gam1,info] = hinfstruct(T0,options);
toc
K1 = ss(T.Blocks.C);


% 
% %K1 = 0;
% % enable model reduction (simple)
 K1_not_reduced = K1;
K1 = balred(K1,8);
% %K1 = balancmr(K1, 8);
% %K1 = hankelmr(K1, 6);
%K1 = reduce(K1, 8);
% 

K1d = c2d(K1,Ts);


CL1 = lft(plant([1 2 5 6 3 4],[1 2 3 4]),K1 ); 
CL1_not_reduced = lft(plant([1 2 5 6 3 4],[1 2 3 4]),K1_not_reduced );
%CL1 = lft(plant([1 3 2],[1 2]),d2c(K1d) ); 
sprintf('H-infinity controller K1 achieved a norm of %2.5g',gam1) 


hfig = figure();
%bode(Wplant(1,1),'r--');
hold on;
bode(Woutput(1,1),'k-');
bode(WactingValue(1,1),'m.-');
legend('W_{plant}', 'W_{output}','W_{acting}');
title('weighting function')
%matlab2tikz( 'figurehandle', hfig, 'minimumPointsDistance', 0.0, 'weightingFunction.tikz', 'height', '\figureheight', 'width', '\figurewidth' , 'showInfo', false);

hfig = figure
opt = bodeoptions;
opt.PhaseMatching = 'on';
bode(actuator(1,1),'r--',ss(A,B,C,D),'k-', opt);
title('actuator bode plot')
legend('uncertain model','nominal model');
%matlab2tikz( 'figurehandle', hfig, 'minimumPointsDistance', 0.0, 'actuatorBode.tikz', 'height', '\figureheight', 'width', '\figurewidth' , 'showInfo', false);

hfig = figure
bode(CL1(1,1),'k-', CL1_not_reduced(1,1),'r--');
title('closed loop bode plot')
legend('C(s) reduced','C(s) not reduced');
%matlab2tikz( 'figurehandle', hfig, 'minimumPointsDistance', 0.0, 'closedLoopBode.tikz', 'height', '\figureheight', 'width', '\figurewidth' , 'showInfo', false);
 
hfig = figure();
time = 0:0.00005:0.04;
step(CL1_not_reduced(1,1),'r', time)
hold on;
step(CL1(1,1),'b', time)
title('step response')
legend('C(s) not reduced','C(s) reduced');
%matlab2tikz( 'figurehandle', hfig, 'minimumPointsDistance', 0.0, 'stepResponse.tikz', 'height', '\figureheight', 'width', '\figurewidth' , 'showInfo', false);


 figure();
 pzplot(K1,'r');
 hold on;
 pzplot(K1_not_reduced,'b');
 legend('reduced model','original model');

clear all
load('../controllerSynthesisDM/workspace-hinfstruct-peak3dot32.mat')

Ts = 1/1700;
Ts_SHWFS = Ts*2;
delay = Ts*2;


act = ss( rsys );
% controller
sizeDM = 24;

K1_disk = c2d(K1, Ts);

simModel = 'mimoSimulation_noInit_uncertain';
uval.deltaDM = ss( ones(sizeDM,sizeDM) );

[uvars,pathinfo] = ufind( simModel );
%uvars          % uncertain variables

hfig = figure();
hold on
for i=1:50
   uval = usample(uvars);   % generate random instance of uncertain variables
   sim( simModel, 0.2);   % simulate response
   
   time = clock.signals.values*10^3;
       
   ax(1)=subplot(2,1,1);
   hold on;
   plot(time, actingValue.signals.values(:,1),'-.b','LineWidth',2)
   plot(time, actingValue.signals.values(:,2),':r','LineWidth',2)
   %plot(time, actingValue.signals.values(:,3:end),'-k','LineWidth',1)
   %set(gca, 'XTick', 0:0.05:2)
   
   ax(2)=subplot(2,1,2);
   hold on;
   plot(time, wavefront1.signals.values(:,1),'-.b','LineWidth',2)
   plot(time, wavefront1.signals.values(:,2),':r','LineWidth',2)
   %plot(time, wavefront1.signals.values(:,3:end),'-k','LineWidth',1)
   %set(gca, 'XTick', 0:0.05:2)
end

linkaxes(ax,'x');

   first = [ 100 150; 100 150 ];
   stepValue = [1 1;-1 -1];
   
ax(1)=subplot(2,1,1);
hold on;
xlabel('time in [ms]')
ylabel('actingValue')
plot(first, stepValue,'-k','LineWidth',2);

axis([90 155 -0.6 0.4])

ax(2)=subplot(2,1,2);
hold on;
xlabel('time in [ms]')
ylabel('wavefront ')
plot(first, stepValue,'-k','LineWidth',2);

axis([95 165 -0.6 0.4])

cleanfigure
% matlab2tikz( 'stepDiagramDMSimulink-simulated.tikz', 'height', '\figureheight', 'width', '\figurewidth' );

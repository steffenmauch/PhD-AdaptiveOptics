% close all;
% clear all;
% 
load('workspace-hinfstruct-peak3dot32.mat','K1');
% 
load( 'mirror-DM-STE-20150826.mat' )
sizeDM = 24;

deltaDM = ultidyn( 'deltaDM',[sizeDM sizeDM],'Bound',1)/5;
deltaDM2 = ultidyn( 'deltaDM2',[sizeDM sizeDM],'Bound',1)/5;

actuatorDM = rsys * (eye(sizeDM)+deltaDM);

Ts = 1/800;
tau = Ts;


[a,b] = pade(tau,2);
delay_tf_u = tf(a,b);
delay = delay_tf_u * diag(ones(sizeDM,1));

% create the plant
Wout1 = ss( diag(ones(sizeDM,1)) );

systemnames = 'delay actuatorDM Wout1';
inputvar = sprintf( '[ disturb(%i); u(%i) ]', sizeDM, sizeDM );
outputvar = '[ Wout1; delay; u ]';
input_to_Wout1 = sprintf('[ disturb(1:%i)-actuatorDM(1:%i) ]', sizeDM, sizeDM );
input_to_delay = sprintf('[ disturb(1:%i)-actuatorDM(1:%i) ]', sizeDM, sizeDM );
input_to_actuatorDM = sprintf( '[ u(1:%i) ]', sizeDM );
plant = sysic;


% create the complete model
Wplant1 = 1;
Wplant = Wplant1 * diag(ones(sizeDM,1));

Woutput1 = 2000*tf( ([1/1200 1]), ([1/10 1]) );
Woutput = Woutput1 * diag(ones(sizeDM,1));

WactingValue1 = 0.4*tf( [1/200 1], [1/10000 1] );
WactingValue = WactingValue1 * diag(ones(sizeDM,1));


systemnames = 'Wplant Woutput plant WactingValue';
inputvar = sprintf('[ w(%i); u(%i) ]', sizeDM , sizeDM);
outputvar = sprintf('[ Woutput; WactingValue; plant(%i:%i) ]', sizeDM+1, sizeDM*2 );
input_to_Wplant = sprintf('[ w(1:%i) ]', sizeDM );
input_to_plant = sprintf('[ Wplant(1:%i); u(1:%i) ]', sizeDM, sizeDM );
input_to_Woutput = sprintf('[ plant(1:%i) ]', sizeDM );
input_to_WactingValue = sprintf('[ plant(%i:%i) ]', sizeDM*2+1, sizeDM*3);
overallPlant = sysic;


% Reglerentwurf 1
ordController = 2*sizeDM;
C1 = ltiblock.ss('C1',ordController,sizeDM,sizeDM,'full');
C_test = reduce( K1, ordController );
% C_test = K1;
C1.a.Value = C_test.a;
C1.b.Value = C_test.b;
C1.c.Value = C_test.c;
C1.d.Value = C_test.d;

C1.y = 'u'; 
C1.u = '[+delay]' ;

[M,Delta,Blkstruct]=lftdata(overallPlant);
%for k = 1:(sizeDM+26)
for k = 1:(sizeDM)
    eval( ['M.u{' sprintf('%i',k) '}=''u1(' sprintf('%i',k) ')'';'] );
    eval( ['M.y{' sprintf('%i',k) '}=''y1(' sprintf('%i',k) ')'';'] );
end

% Connect the blocks together
%overallPlant = overallPlant.NominalValue;
T0 = connect(M,C1,{'u1','w'},{'y1','[+Woutput]','[+WactingValue]'});


nxD = 8; % D-scale order for both uncertainty channels
nb1 = sizeDM;
D1 = ltiblock.ss('D1', nxD, nb1, nb1,'full');
%  D1_test = ss(T.Blocks.D1);
%  D1.a.Value = D1_test.a;
%  D1.b.Value = D1_test.b;
%  D1.c.Value = D1_test.c;
%  D1.d.Value = D1_test.d;

nxD = 12; % D-scale order for both uncertainty channels
nb2 = sizeDM;
D2 = ltiblock.ss('D2', nxD, nb2, nb2,'full');

%test = blkdiag(eye(nb1)-D1,eye(nb2)-D2,eye(sizeDM),eye(sizeDM));
test = blkdiag(eye(nb1)-D1,eye(sizeDM),eye(sizeDM));
%test1 = blkdiag(eye(nb1)-D1,eye(nb2)-D2,eye(sizeDM));
test1 = blkdiag(eye(nb1)-D1,eye(sizeDM));
T0 = (test)\T0*(test1) ;


options = hinfstructOptions;
options.Display = 'iter';
options.MaxIter = 500;
options.TolGain = 1e-4;
options.RandomStart = 0;
options.UseParallel = true;
%options.SpecRadius = 1/1333;
tic
[T,gam1,info] = hinfstruct(T0,options);
toc
K1 = ss(T.Blocks.C1);

CL1_not_reduced = lft(plant([1:sizeDM (sizeDM*2+1):(sizeDM*3) (sizeDM+1):(sizeDM*2)], ...
        [1:sizeDM (sizeDM+1):(sizeDM*2)]),K1 );
%CL1 = lft(plant([1 3 2],[1 2]),d2c(K1d) ); 
sprintf('H-infinity controller K1 achieved a norm of %2.5g',gam1) 

step(CL1_not_reduced(1,1))

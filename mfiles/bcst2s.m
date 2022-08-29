function [ret,x0,str]=bcst2s(t,x,u,flag);
%BCST2S	is the M-file description of the SIMULINK system named BCST2S.
%	The block-diagram can be displayed by typing: BCST2S.
%
%	SYS=BCST2S(T,X,U,FLAG) returns depending on FLAG certain
%	system values given time point, T, current state vector, X,
%	and input vector, U.
%	FLAG is used to indicate the type of output to be returned in SYS.
%
%	Setting FLAG=1 causes BCST2S to return state derivitives, FLAG=2
%	discrete states, FLAG=3 system outputs and FLAG=4 next sample
%	time. For more information and other options see SFUNC.
%
%	Calling BCST2S with a FLAG of zero:
%	[SIZES]=BCST2S([],[],[],0),  returns a vector, SIZES, which
%	contains the sizes of the state vector and other parameters.
%		SIZES(1) number of states
%		SIZES(2) number of discrete states
%		SIZES(3) number of outputs
%		SIZES(4) number of inputs.
%	For the definition of other parameters in SIZES, see SFUNC.
%	See also, TRIM, LINMOD, LINSIM, EULER, RK23, RK45, ADAMS, GEAR.

% Note: This M-file is only used for saving graphical information;
%       after the model is loaded into memory an internal model
%       representation is used.

% the system will take on the name of this mfile:
sys = mfilename;
new_system(sys)
simver(1.2)
if(0 == (nargin + nargout))
     set_param(sys,'Location',[103,596,603,896])
     open_system(sys)
end;
set_param(sys,'algorithm',		'RK-45')
set_param(sys,'Start time',	'0.0')
set_param(sys,'Stop time',		'200')
set_param(sys,'Min step size',	'0.001')
set_param(sys,'Max step size',	'10')
set_param(sys,'Relative error','1e-3')
set_param(sys,'Return vars',	'')

add_block('built-in/Clock',[sys,'/','Clock'])
set_param([sys,'/','Clock'],...
		'position',[140,25,160,45])

add_block('built-in/To Workspace',[sys,'/','To Workspace1'])
set_param([sys,'/','To Workspace1'],...
		'mat-name','t',...
		'position',[215,27,265,43])

add_block('built-in/Step Fcn',[sys,'/','Step Fcn'])
set_param([sys,'/','Step Fcn'],...
		'Time','100',...
		'After','fv',...
		'position',[45,70,65,90])

add_block('built-in/Step Fcn',[sys,'/','Step Fcn1'])
set_param([sys,'/','Step Fcn1'],...
		'Time','102',...
		'After','fv',...
		'position',[45,125,65,145])

add_block('built-in/Sum',[sys,'/','Sum'])
set_param([sys,'/','Sum'],...
		'inputs','+--',...
		'position',[120,82,140,138])

add_block('built-in/To Workspace',[sys,'/','To Workspace'])
set_param([sys,'/','To Workspace'],...
		'mat-name','yout',...
		'position',[390,102,440,118])

add_block('built-in/Transfer Fcn',[sys,'/','Transfer Fcn'])
set_param([sys,'/','Transfer Fcn'],...
		'Numerator','[k1*k]',...
		'Denominator','[1 1/k]',...
		'position',[185,83,325,137])

add_block('built-in/Transport Delay',[sys,'/','Transport Delay'])
set_param([sys,'/','Transport Delay'],...
		'orientation',2,...
		'Delay Time','1',...
		'position',[275,185,320,215])


%     Subsystem  'PID Controller'.

new_system([sys,'/','PID Controller'])
set_param([sys,'/','PID Controller'],'Location',[0,0,362,244])

add_block('built-in/Inport',[sys,'/','PID Controller/In_1'])
set_param([sys,'/','PID Controller/In_1'],...
		'position',[25,65,45,85])

add_block('built-in/Outport',[sys,'/','PID Controller/Out_1'])
set_param([sys,'/','PID Controller/Out_1'],...
		'position',[290,65,310,85])

add_block('built-in/Derivative',[sys,'/','PID Controller/Derivative'])
set_param([sys,'/','PID Controller/Derivative'],...
		'position',[150,128,190,152])

add_block('built-in/Transfer Fcn',[sys,'/','PID Controller/Integral'])
set_param([sys,'/','PID Controller/Integral'],...
		'Numerator','[I]',...
		'Denominator','[1 0]',...
		'position',[110,57,145,93])

add_block('built-in/Gain',[sys,'/','PID Controller/Proportional'])
set_param([sys,'/','PID Controller/Proportional'],...
		'Gain','P',...
		'position',[120,13,140,37])

add_block('built-in/Gain',[sys,'/','PID Controller/D'])
set_param([sys,'/','PID Controller/D'],...
		'Gain','D',...
		'position',[95,129,115,151])

add_block('built-in/Sum',[sys,'/','PID Controller/Sum'])
set_param([sys,'/','PID Controller/Sum'],...
		'inputs','+++',...
		'position',[245,57,265,93])
add_line([sys,'/','PID Controller'],[145,25;210,25;210,65;235,65])
add_line([sys,'/','PID Controller'],[150,75;235,75])
add_line([sys,'/','PID Controller'],[195,140;215,140;215,85;235,85])
add_line([sys,'/','PID Controller'],[50,75;100,75])
add_line([sys,'/','PID Controller'],[80,75;80,25;110,25])
add_line([sys,'/','PID Controller'],[65,75;65,140;85,140])
add_line([sys,'/','PID Controller'],[270,75;280,75])
add_line([sys,'/','PID Controller'],[120,140;140,140])
set_param([sys,'/','PID Controller'],...
		'Mask Display','PID',...
		'Mask Type','PID Controller',...
		'Mask Dialogue','Enter expressions for proportional, integral, and derivitive terms.|Proportional:|Integral|Derivitive:')
set_param([sys,'/','PID Controller'],...
		'Mask Translate','P=@1; I=@2; D=@3;')
set_param([sys,'/','PID Controller'],...
		'Mask Help','This block implements a PID controller where paramaters are entered for the Proportional, Integral and Derivitive terms. Unmask this block to see how it works. The derivative term is implemented using a true derivative block.')
set_param([sys,'/','PID Controller'],...
		'Mask Entries','0.057\/0\/0\/')


%     Finished composite block 'PID Controller'.

set_param([sys,'/','PID Controller'],...
		'orientation',2,...
		'position',[185,184,225,216])
add_line(sys,[165,35;205,35])
add_line(sys,[70,80;110,90])
add_line(sys,[70,135;110,110])
add_line(sys,[145,110;175,110])
add_line(sys,[330,110;380,110])
add_line(sys,[270,200;235,200])
add_line(sys,[350,110;350,195;330,200])
add_line(sys,[180,200;90,200;90,170;110,130])

% Return any arguments.
if (nargin | nargout)
	% Must use feval here to access system in memory
	if (nargin > 3)
		if (flag == 0)
			eval(['[ret,x0,str]=',sys,'(t,x,u,flag);'])
		else
			eval(['ret =', sys,'(t,x,u,flag);'])
		end
	else
		[ret,x0,str] = feval(sys);
	end
end

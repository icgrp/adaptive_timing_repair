
>
Refreshing IP repositories
234*coregenZ19-234h px� 
G
"No user IP repositories specified
1154*coregenZ19-1704h px� 
z
"Loaded Vivado IP repository '%s'.
1332*coregen21
//home/eiffel/tools/XIlinx/Vivado/2024.2/data/ipZ19-2313h px� 
�
Command: %s
1870*	planAhead2�
�read_checkpoint -auto_incremental -incremental /home/eiffel/adaptive_timing_repair/project_1/project_1.srcs/utils_1/imports/synth_1/top.dcpZ12-2866h px� 
�
;Read reference checkpoint from %s for incremental synthesis3154*	planAhead2^
\/home/eiffel/adaptive_timing_repair/project_1/project_1.srcs/utils_1/imports/synth_1/top.dcpZ12-5825h px� 
T
-Please ensure there are no constraint changes3725*	planAheadZ12-7989h px� 
_
Command: %s
53*	vivadotcl2.
,synth_design -top top -part xc7a200tsbg484-1Z4-113h px� 
:
Starting synth_design
149*	vivadotclZ4-321h px� 
{
@Attempting to get a license for feature '%s' and/or device '%s'
308*common2
	Synthesis2

xc7a200tZ17-347h px� 
k
0Got license for feature '%s' and/or device '%s'
310*common2
	Synthesis2

xc7a200tZ17-349h px� 
E
Loading part %s157*device2
xc7a200tsbg484-1Z21-403h px� 

VNo compile time benefit to using incremental synthesis; A full resynthesis will be run2353*designutilsZ20-5440h px� 
�
�Flow is switching to default flow due to incremental criteria not met. If you would like to alter this behaviour and have the flow terminate instead, please set the following parameter config_implementation {autoIncr.Synth.RejectBehavior Terminate}2229*designutilsZ20-4379h px� 
o
HMultithreading enabled for synth_design using a maximum of %s processes.4828*oasys2
7Z8-7079h px� 
a
?Launching helper process for spawning children vivado processes4827*oasysZ8-7078h px� 
P
#Helper process launched with PID %s4824*oasys2	
2469659Z8-7075h px� 
�
%s*synth2�
�Starting RTL Elaboration : Time (s): cpu = 00:00:02 ; elapsed = 00:00:03 . Memory (MB): peak = 2161.375 ; gain = 418.797 ; free physical = 48407 ; free virtual = 96297
h px� 
�
5undeclared symbol '%s', assumed default net type '%s'7502*oasys2
state2
wire22
./home/eiffel/adaptive_timing_repair/src/ddfl.v2
1478@Z8-11241h px� 
�
.'%s' is already implicitly declared on line %s5153*oasys2
state2
14722
./home/eiffel/adaptive_timing_repair/src/ddfl.v2
1698@Z8-8895h px� 
�
synthesizing module '%s'%s4497*oasys2
top2
 22
./home/eiffel/adaptive_timing_repair/src/ddfl.v2
428@Z8-6157h px� 
�
unable to resolve '%s'660*oasys2
str_to_flat22
./home/eiffel/adaptive_timing_repair/src/ddfl.v2
1228@Z8-660h px� 
�
unable to resolve '%s'660*oasys2
str_to_flat22
./home/eiffel/adaptive_timing_repair/src/ddfl.v2
1238@Z8-660h px� 
�
!failed synthesizing module '%s'%s4496*oasys2
top2
 22
./home/eiffel/adaptive_timing_repair/src/ddfl.v2
428@Z8-6156h px� 
�
%s*synth2�
�Finished RTL Elaboration : Time (s): cpu = 00:00:03 ; elapsed = 00:00:03 . Memory (MB): peak = 2239.344 ; gain = 496.766 ; free physical = 48283 ; free virtual = 96173
h px� 
C
Releasing license: %s
83*common2
	SynthesisZ17-83h px� 
~
G%s Infos, %s Warnings, %s Critical Warnings and %s Errors encountered.
28*	vivadotcl2
152
12
02
4Z4-41h px� 
<

%s failed
30*	vivadotcl2
synth_designZ4-43h px� 
|
Command failed: %s
69*common2G
ESynthesis failed - please see the console or run log file for detailsZ17-69h px� 
\
Exiting %s at %s...
206*common2
Vivado2
Thu Apr 17 01:57:08 2025Z17-206h px� 


End Record
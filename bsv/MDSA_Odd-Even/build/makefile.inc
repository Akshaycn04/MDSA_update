SIM:= iverilog
EG_NAME:=MDSA_Odd-Even

TB_BSV:= mdsa_oddeven_testbench
#TB_BSV:= tb_oddeven_sorter_testbench
#TB_BSV:= cae_testbench

TB_BSV_TOP:= mk_${TB_BSV}

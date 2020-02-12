prefix            = ""
n_initiators      = 3
n_targets         = 5
addrwidth         = 24 # System address width
datawidth         = 32 # System data width
sidewidth         = 0  # System sideband width 
connection_matrix = [[0, 1, 1, 1, 0],
                     [0, 0, 0, 1, 0],
										 [1, 0, 0, 1, 1]]

# Number of outstanding requests at initiators and targets
outstanding_num   = {'I0' : 4,
										 'I1' : 4,
										 'I2' : 4,
										 'T0' : 2,
										 'T1' : 2,
										 'T2' : 2,
										 'T3' : 2,
										 'T4' : 2}

# Name of agents, must be unique
agents            = {'I0' : 'CPUm',
										 'I1' : 'SCRm',
										 'I2' : 'BRUm',
										 'T0' : 'CPUs',
										 'T1' : 'SCRs',
										 'T2' : 'KBDs',
										 'T3' : 'RAMs',
										 'T4' : 'ROMs'}

# [Mask, Value] - Address & Mask == Value => access to this target
# Please take care of address bit width of iniitiators
address_map       = {'T0' : ["24'hE0_0000", "24'h20_0000"],
										 'T1' : ["24'hE0_0000", "24'h40_0000"],
										 'T2' : ["24'hE0_0000", "24'h60_0000"],
										 'T3' : ["24'hE0_0000", "24'h00_0000"],
										 'T4' : ["24'hE0_0000", "24'h80_0000"]}

agents_addrwidth = {'I0' : 24,
										'I1' : 24,
										'I2' : 24,
										'T0' : 16,
							      'T1' : 16,
							 		  'T2' : 16,
					    			'T3' : 21,
										'T4' : 15}

agents_datawidth = {'I0' : 32,
							      'I1' : 32,
							 		  'I2' : 16,
					    			'T0' : 16,
					    			'T1' : 16,
					    			'T2' : 8,
					    			'T3' : 32,
										'T4' : 16}

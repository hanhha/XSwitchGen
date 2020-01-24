prefix            = "N2T"
n_initiators      = 3
n_targets         = 5
addrwidth         = 32 # System address width
datawidth         = 16 # System data width
sidewidth         = 0  # System sideband width 
connection_matrix = [[0, 1, 1, 1, 0],
                     [0, 0, 0, 1, 0],
										 [1, 0, 0, 1, 1]]

# Number of outstanding requests at initiators and targets
outstanding_num   = {'I0' : 3,
										 'I1' : 3,
										 'I2' : 3,
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
address_map       = {'T0' : ["32'hFFFF_0000", "32'h0001_0000"],
										 'T1' : ["32'hFFFF_0000", "32'h0002_0000"],
										 'T2' : ["32'hFFFF_0000", "32'h0003_0000"],
										 'T3' : ["32'hFFFF_0000", "32'h0004_0000"],
										 'T4' : ["32'hFFFF_0000", "32'h0005_0000"]}

agents_addrwidth = {'I0' : 16,
										'I1' : 16,
										'I2' : 16,
										'T0' : 16,
							      'T1' : 16,
							 		  'T2' : 16,
					    			'T3' : 21,
										'T4' : 16}

agents_datawidth = {'I0' : 16,
							      'I1' : 16,
							 		  'I2' : 16,
					    			'T0' : 16,
					    			'T1' : 16,
					    			'T2' : 16,
					    			'T3' : 21,
										'T4' : 16}

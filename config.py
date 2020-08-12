prefix            = ""
n_initiators      = 3
n_targets         = 5
user_width        = 0  # System sideband width 
connection_matrix = [[0, 1, 1, 1, 0],
                     [0, 0, 0, 1, 0],
										 [1, 0, 0, 1, 1]]

#                     Name      Outstanding # Address width   Data width
agents = {'I0' : {"name": 'CPUm', "otd": 4,    "adrw":24,     "dataw":32},
				  'I1' : {"name": 'SCRm', "otd": 4,    "adrw":24,     "dataw":32},
				  'I2' : {"name": 'BRUm', "otd": 4,    "adrw":24,     "dataw":16},
				  'T0' : {"name": 'CPUs', "otd": 2,    "adrw":16,     "dataw":16},
				  'T1' : {"name": 'SCRs', "otd": 2,    "adrw":16,     "dataw":16},
				  'T2' : {"name": 'KBDs', "otd": 2,    "adrw":16,     "dataw":8},
				  'T3' : {"name": 'RAMs', "otd": 2,    "adrw":21,     "dataw":32},
				  'T4' : {"name": 'ROMs', "otd": 2,    "adrw":15,     "dataw":16}}

# [Mask, Value] - Address & Mask == Value => access to this target
# Please take care of address bit width of iniitiators
address_map       = {'T0' : [{"mask":"24'hE0_0000", "value":"24'h20_0000"}],
										 'T1' : [{"mask":"24'hE0_0000", "value":"24'h40_0000"}],
										 'T2' : [{"mask":"24'hE0_0000", "value":"24'h60_0000"}],
										 'T3' : [{"mask":"24'hE0_0000", "value":"24'h00_0000"}],
										 'T4' : [{"mask":"24'hE0_0000", "value":"24'h80_0000"}]}

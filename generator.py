#!/usr/bin/env python3

import os
import glob
import shutil
import importlib.util as ip

import epy

seed = "Seed"

def copy_files (source, dest):
	for filename in glob.glob(source + '/*.sv'):
		shutil.copy (filename, dest)
	for filename in glob.glob(source + '/*.svh'):
		shutil.copy (filename, dest)

def gen_files (source, dest, env):
	for filename in glob.glob(source + '/*.epy'):
		with open (filename,"r") as sf:
			epython = epy.ePython (sf.read())
		basename = env['prefix'] + os.path.basename (filename)
		with open (dest + "/" + os.path.splitext(basename)[0], "w") as f:
			f.write (epython.render (env))

gen_cfg = ip.spec_from_file_location ('gen_cfg', "./config.py")
cfg     = ip.module_from_spec (gen_cfg)
gen_cfg.loader.exec_module (cfg)

env = dict (gendir = cfg.prefix if cfg.prefix != "" else "generated",
						prefix = cfg.prefix + "_" if cfg.prefix != "" else "",
						n_initiators   = cfg.n_initiators,
						n_targets      = cfg.n_targets,
						datawidth      = cfg.datawidth,
						targetid_width = cfg.targetid_width,
						vdw            = cfg.datawidth + cfg.targetid_width,
						conn_matrix    = cfg.connection_matrix)

print (env['prefix'])
print (env['n_initiators'])
print (env['n_targets'])
print (env['targetid_width'])
print (env['datawidth'])
print (env['conn_matrix'])

print ("RTL will be generated in \"%s\" folder." %(env['gendir']))
shutil.rmtree (env['gendir'], ignore_errors = True)
os.makedirs   (env['gendir'], exist_ok = True)

copy_files (seed, env['gendir'])
gen_files  (seed, env['gendir'], env)

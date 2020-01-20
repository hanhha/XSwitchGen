#!/usr/bin/env python3

import os
import glob
import shutil
import math
import importlib.util as ip

import epy

class XRouterGen (object):
	def __init__ (self, env):
		self.env  = env
		self.seed = "Seed"

	def gen_files (self):
		for filename in glob.glob(self.seed + '/*.epy'):
			with open (filename,"r") as sf:
				epython = epy.ePython (sf.read())
			basename = self.env['prefix'] + os.path.basename (filename)
			with open (self.env['gendir'] + "/" + os.path.splitext(basename)[0], "w") as f:
				f.write (epython.render (self.env))

	def gen_cmm_files (self):
		for filename in glob.glob(self.seed + '/*.epy_cmm'):
			with open (filename,"r") as sf:
				epython = epy.ePython (sf.read())
			basename = self.env['cmm_prefix'] + os.path.basename (filename)
			with open (self.env['gendir'] + "/" + os.path.splitext(basename)[0], "w") as f:
				f.write (epython.render (self.env))

if __name__ == "__main__":
	gen_cfg = ip.spec_from_file_location ('gen_cfg', "./config.py")
	cfg     = ip.module_from_spec (gen_cfg)
	gen_cfg.loader.exec_module (cfg)

	gendir = cfg.prefix if cfg.prefix != "" else "generated"

	req_env = dict (gendir           = cfg.prefix if cfg.prefix != "" else "generated",
	                prefix           = cfg.prefix + "_req_" if cfg.prefix != "" else "req_",
									cmm_prefix       = cfg.prefix + "_" if cfg.prefix != "" else "",
	                n_initiators     = cfg.n_initiators,
	                n_targets        = cfg.n_targets,
									addrwidth        = cfg.addrwidth,
									agents           = cfg.agents,
									address_map      = cfg.address_map,
									target_addrwidth = cfg.target_addrwidth,
	                conn_matrix      = cfg.connection_matrix)

	req_env ['datawidth']      = max(list(cfg.initiator_datawidth.values()))
	req_env ['pktwidth']       = req_env['datawidth'] + max(list(cfg.target_addrwidth.values()))
	req_env ['initid_width']   = math.ceil(math.log2(req_env['n_initiators']))
	req_env ['targetid_width'] = math.ceil(math.log2(req_env['n_targets']))
	req_env ['vdw']            = req_env ['pktwidth'] + req_env ['initid_width'] + req_env ['targetid_width']

	rsp_env = dict (gendir = cfg.prefix if cfg.prefix != "" else "generated",
	                prefix = cfg.prefix + "_rsp_" if cfg.prefix != "" else "rsp_",
									cmm_prefix = cfg.prefix + "_" if cfg.prefix != "" else "",
	                n_initiators   = cfg.n_targets,
	                n_targets      = cfg.n_initiators,
									agents         = cfg.agents,
	                conn_matrix    = [*zip(*cfg.connection_matrix)])

	rsp_env ['datawidth']      = max(list(cfg.target_datawidth.values()))
	rsp_env ['pktwidth']       = rsp_env['datawidth']
	rsp_env ['initid_width']   = math.ceil(math.log2(rsp_env['n_initiators']))
	rsp_env ['targetid_width'] = math.ceil(math.log2(rsp_env['n_targets']))
	rsp_env ['vdw']            = rsp_env ['pktwidth'] + rsp_env ['initid_width'] + rsp_env ['targetid_width']

	req_gen = XRouterGen (req_env)
	rsp_gen = XRouterGen (rsp_env)

	print ("RTL will be generated in \"%s\" folder." %(gendir))
	shutil.rmtree (gendir, ignore_errors = True)
	os.makedirs   (gendir, exist_ok = True)

	req_gen.gen_files ()
	req_gen.gen_cmm_files ()
	rsp_gen.gen_files ()

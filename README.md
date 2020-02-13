# XSwitchGen
Generator for crossbar matrix implementation in System Verilog
## Usage
1 - Modify config.py
2 - Run generator.py
3 - Generated system verilog source are placed in newly created folder, and template for testbench as well (refer to sample_generated/verif for an example of modification of testbench to verify write/read transaction).
4 - Run formal and simulation verification in scripts folder inside above folder. Run "make help" for more detail.

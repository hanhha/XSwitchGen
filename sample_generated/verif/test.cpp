#include <VXFabricCover.h>
#include "testbench.h"
#include <iostream>

using namespace std;

void init (TESTBENCH<VXFabricCover> *tb) {
  tb->m_core->SCRm_req_vld  = 0;
  tb->m_core->SCRm_req_wr   = 0;
  tb->m_core->SCRm_req_adr  = 0;
  tb->m_core->SCRm_req_strb = 0;
  tb->m_core->SCRm_req_dat  = 0;
  tb->m_core->SCRm_rsp_gnt  = 1;
	tb->tick ();
}

void write (TESTBENCH<VXFabricCover> *tb, int data, int strb, int addr) {
	tb->m_core->SCRm_req_adr = addr;
	tb->m_core->SCRm_req_wr  = 1;
  tb->m_core->SCRm_req_strb = strb;
  tb->m_core->SCRm_req_dat  = data;
	tb->m_core->SCRm_req_vld = 1;
	tb->m_core->SCRm_rsp_gnt = 1;
	tb->tick ();
	while (tb->m_core->SCRm_req_gnt == 0) {
		tb->m_core->SCRm_req_vld = 1;
		tb->tick ();
	}
	tb->m_core->SCRm_req_vld = 0;
	while (tb->m_core->SCRm_rsp_vld == 0) {
		tb->tick ();
	}
}

int read (TESTBENCH<VXFabricCover> *tb, int addr) {
	tb->m_core->SCRm_req_adr = addr;
	tb->m_core->SCRm_req_wr  = 0;
	tb->m_core->SCRm_req_vld = 1;
	tb->m_core->SCRm_rsp_gnt = 1;
	tb->tick ();
	while (tb->m_core->SCRm_req_gnt == 0) {
		tb->m_core->SCRm_req_vld = 1;
		tb->tick ();
	}
	tb->m_core->SCRm_req_vld = 0;
	while (tb->m_core->SCRm_rsp_vld == 0) {
		tb->tick ();
	}
	return tb->m_core->SCRm_rsp_dat;
}

int main (int argc, char **argv) {
  Verilated::commandArgs(argc, argv);
  TESTBENCH<VXFabricCover> *tb = new TESTBENCH<VXFabricCover>();

  tb->opentrace("trace.vcd");

	// Initial values
	init (tb);

	tb->reset ();
	tb->tick ();
	write (tb, 0x12345678, 0x1, 0x0);
	cout << "0x" << hex << read (tb, 0x0) << endl;
	write (tb, 0x12345678, 0x2, 0x1);
	cout << "0x" << hex << read (tb, 0x0) << endl;
	write (tb, 0x12345678, 0x4, 0x2);
	cout << "0x" << hex << read (tb, 0x0) << endl;
	write (tb, 0x12345678, 0x8, 0x3);
	cout << "0x" << hex << read (tb, 0x0) << endl;
	tb->close ();
	exit (EXIT_SUCCESS);
}

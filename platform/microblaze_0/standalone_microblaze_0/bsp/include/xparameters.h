#ifndef XPARAMETERS_H   /* prevent circular inclusions */
#define XPARAMETERS_H   /* by using protection macros */

/* Definitions for peripheral ECHO_IP_0 */
#define XPAR_ECHO_IP_0_BASEADDR 0x44a00000
#define XPAR_ECHO_IP_0_HIGHADDR 0x44a0ffff

/* Canonical definitions for peripheral ECHO_IP_0 */
#define XPAR_ECHO_IP_0_BASEADDR 0x44a00000
#define XPAR_ECHO_IP_0_HIGHADDR 0x44a0ffff

#define XPAR_LMB_BRAM_0_BASEADDRESS 0x0
#define XPAR_LMB_BRAM_0_HIGHADDRESS 0x3fff
#define XPAR_CPU_CORE_CLOCK_FREQ_HZ 100000000

#define XPAR_MICROBLAZE_ADDR_SIZE 32

#define XPAR_MICROBLAZE_USE_STACK_PROTECTION 0

/* Number of SLRs */
#define NUMBER_OF_SLRS 0x1

/* Device ID */
#define XPAR_DEVICE_ID "7z010i"

#endif  /* end of protection macro */
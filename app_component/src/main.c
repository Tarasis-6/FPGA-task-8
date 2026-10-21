#include "xparameters.h"
#include "xil_io.h"
#include <stdint.h>
#include "sleep.h"

#define REG_SHIFT   0x00    // slv_reg0[1:0]                        
#define REG_DELAY   0x04    // slv_reg1[3:0], 1..8                  
#define REG_CLEAR   0x08    // write 1 -> one-clock clear pulse     
#define REG_SPARE   0x0C    // plain R/W, used as a result mailbox  

#define RESULT_PASS 0x600D0000
#define RESULT_FAIL 0xBAD00000

int main()
{
    int ok = 1;

    Xil_Out32(XPAR_ECHO_IP_0_BASEADDR + REG_SPARE, 0xA5A55A5A);
    if (Xil_In32(XPAR_ECHO_IP_0_BASEADDR + REG_SPARE) != 0xA5A55A5A) ok = 0;
    
    uint32_t delay_val = 1;
    uint32_t shift_val = 1;


    for  (int i = 0; i < 2; i++){
        
        delay_val = delay_val + 1;
        shift_val = shift_val + 1;

        if (delay_val > 8 || delay_val < 1)
            delay_val = 2 ;        
        
        
        if (shift_val > 3)
            shift_val = 1;        

        
        Xil_Out32(XPAR_ECHO_IP_0_BASEADDR + REG_DELAY, delay_val);
        Xil_Out32(XPAR_ECHO_IP_0_BASEADDR + REG_SHIFT, shift_val);
        Xil_Out32(XPAR_ECHO_IP_0_BASEADDR + REG_CLEAR, 1);

        if (Xil_In32(XPAR_ECHO_IP_0_BASEADDR + REG_DELAY) != delay_val) ok = 0;
        if (Xil_In32(XPAR_ECHO_IP_0_BASEADDR + REG_SHIFT) != shift_val) ok = 0;

        /* 3. report */
        Xil_Out32(XPAR_ECHO_IP_0_BASEADDR + REG_SPARE, ok ? RESULT_PASS : RESULT_FAIL);
    
        usleep(5);
    }
    
    while (1);
       
    return 0;
}
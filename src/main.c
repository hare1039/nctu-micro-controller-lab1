#include "inc/stm32l476xx.h"
extern void delay();
extern void GPIO_init();
extern void MAX7219_init();
extern void display_array(char * array, int up_limit);

enum clock_type{C_ONE, C_SIX, C_TEN, C_SIXTEEN, C_FOTFY, C_ALL_TYPE};


#define UNTIL(x) while(!(x))
#define FALSE_ 0
#define TRUE_ (!(FALSE_))
//reference to manual p225/1830
/*
f(PLLR) = f(PLL CLK INPUT)*(PLLN/(PLLM*PLLR))
SYS_CLK    PLLN    PLLM   PLLR   OUTPUT RESULT
1            8       8     4       4*8/32 = 1MHz
6            12      4     2       4*12/8 = 6MHz
10           20      4     2       4*20/8 = 10MHz
16           32      4     2       4*32/8 = 16MHz
40           80      4     2       4*80/8 = 40MHz
*/

    /*  PLLR:   26
		PLLREN: 24
		        23-16
		        15
		PLLN:   14-8
		        7
		PLLM:   6-4
		        3
		        2
		PLLSRC: 1-0
	 */
    //MSI set as clock entry
    //654321098765432109876543210

const unsigned int pattern[C_ALL_TYPE] = {
    0b011000000000000100001110001,
    0b001000000000000110000110001,
    0b001000000000001010000110001,
    0b001000000000010000000110001,
    0b001000000000101000000110001
};

void systemclk_setting(enum clock_type state)
{
    // use hsi clock
    RCC->CR |= RCC_CR_HSION;
    UNTIL (RCC->CR & RCC_CR_HSIRDY)  /* wait */;

    RCC->CFGR = 0x00000000;          // reset
    RCC->CR  &= 0xFEFFFFFF;          // PLL off
    UNTIL ((RCC->CR & 0x02000000) == 0)/* wait */;

    // PLLCFGR: set clock speed
    RCC->PLLCFGR &= 0x00000001;      // only the MSI clock source
    RCC->PLLCFGR |= pattern[state];

    RCC->CR |= RCC_CR_PLLON;         // PLL on
    UNTIL ((RCC->CR & RCC_CR_PLLRDY))/* wait */;

	RCC->CFGR |= RCC_CFGR_SW_PLL;    // set clock source to PLL
	UNTIL ((RCC->CFGR & RCC_CFGR_SWS_PLL) == RCC_CFGR_SWS_PLL) /* wait */;
}
int read_from(uint32_t src, int port)
{
	return src & (1<<port);
}

int pressed()
{
	static int debounce = 0;
	if( read_from(GPIOC->IDR, 13) == 0)
	{
	    debounce = debounce >= 1 ? 1 : debounce+1 ;
	    return FALSE_;
	}
	else if( debounce >= 1 )
	{
	    debounce = 0;
	    return TRUE_;
	}
	return FALSE_;
}

void display(int src, int lim)
{
	char c[8] = {0};
	int i = 8, t = 10000000;
	for(; i ; i--)
	{
		c[8 - i] = (src / t) % 10;
		t /= 10;
	}
	display_array(c, lim - 1);
}

int main()
{
    GPIO_init();
    MAX7219_init();
    enum clock_type state = C_ONE;
    systemclk_setting(state);
    for(;;)
    {
        if(pressed())
        {
        		state = (state == C_FOTFY)? C_ONE: state + 1;
        	    systemclk_setting(state);
        }
        display(123, 5);
		GPIOA->ODR = 0b0000000000000000;
		delay();
		GPIOA->ODR = 0b0000000000100000;
		delay();
    }
    return 0;
}

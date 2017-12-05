#include "inc/stm32l476xx.h"
extern void delay();
extern void GPIO_init();
extern void MAX7219_init();
extern void display_array(char * array, int up_limit);

enum clock_type{C_ONE, C_SIX, C_TEN, C_SIXTEEN, C_FOTFY, C_ALL_TYPE};


#define UNTIL(x) while(!(x))
#define FALSE_ 0
#define TRUE_ (!(FALSE_))

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

int append_dot(int who)
{
	return -16 + who;
}

void display_int(int src, int lim)
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

void display_float(int centi)
{
	char c[8] = {0};
	int i = 8, t = 10000000, lim = 7;
	for(; i ; i--)
	{
		c[8 - i] = (centi / t) % 10;
		t /= 10;
		if(lim == 7 && c[8 - i] != 0)
			lim = i - 1;
	}
	c[5] = append_dot(c[5]);

	display_array(c, lim);
}

void timer_init()
{
    RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN; //turn on the timer2
    TIM2->CR1 &= 0x0000; // count up mode
    TIM2->PSC = 39999U;  // prescaler
    TIM2->ARR = 99U;     // counters
    TIM2->EGR = 0x0001;  //re-initailzie timer to startup
}

void Timer_start(TIM_TypeDef *timer)
{
    TIM2->CR1 |= TIM_CR1_CEN; // counter mode, change in the control register
    TIM2->SR &= ~(TIM_SR_UIF); // close the user interrupt mode
}

int main()
{
    GPIO_init();
    MAX7219_init();
    for(;;)
    {
        display_float(11245);
     	// display_int(10, 5);
    }
    return 0;
}

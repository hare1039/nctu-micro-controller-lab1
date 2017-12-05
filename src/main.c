#include "inc/stm32l476xx.h"
extern void delay();
extern void GPIO_init();
extern void MAX7219_init();
extern void display_array(char * array, int up_limit);

const int max_count_centi = 1000;

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

void display_clock(int centi)
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
	display_array(c, lim < 2? 2: lim);
}

void timer_init()
{
    RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN; //turn on the timer2
    TIM2->CR1 &= 0x0000; // count up mode
    TIM2->PSC = 39999U;  // prescaler
    TIM2->ARR = 99U;     // counters
    TIM2->EGR = 0x0001;  //re-initailzie timer to startup
}

void timer_start()
{
    TIM2->CR1 |= TIM_CR1_CEN; // counter mode, change in the control register
    TIM2->SR &= ~(TIM_SR_UIF); // close the user interrupt mode
}

int main()
{
    GPIO_init();
    MAX7219_init();
    timer_init();
    timer_start();
    display_int(0, 1);

    int current_time = 0;
    for(;;)
    {
        	if(TIM2->SR & 1) // event :: 1 second
    	    	{
    	    	    current_time += 100;
    	    	    TIM2->SR &= ~(TIM_SR_UIF); //reset
    	    }
    	    int now = current_time + TIM2->CNT;
    	    if(now <= max_count_centi)
    	    {
    	    	    display_clock(now);
    	    }
    }
    return 0;
}

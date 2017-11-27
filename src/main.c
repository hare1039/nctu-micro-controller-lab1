#include "inc/stm32l476xx.h"
#include "inc/utils.h"

void GPIO_init();
void delay();
void SystemClock_Config()
{
	//TODO: Change the SYSCLK source and set the corresponding Prescaler value.
}

int main()
{
 	SystemClock_Config();
	GPIO_init();
	for(;;)
	{
		if (user_press_button())
		{
			
		}
		GPIOA->BSRR = (1<<5);
		delay ();
		GPIOA->BRR  = (1<<5);
		delay ();
	}
}

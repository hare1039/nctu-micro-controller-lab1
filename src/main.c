void GPIO_init();
void 4MHz_delay_1s();
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
		4MHz_delay_1s ();
		GPIOA->BRR  = (1<<5);
		4MHz_delay_1s ();
	}
}

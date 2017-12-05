#include "inc/stm32l476xx.h"
#include "gpio.h"
extern void gpio_init();
extern void fpu_enable();

#define DO 261.6
#define RE 293.7
#define MI 329.6
#define FA 349.2
#define SO 392.0
#define LA 440.0
#define SI 493.9
#define HI_DO 523.3

float freq = -1;
int curr = -2, prev = -3, check = -4;
int duty_cycle = 50;

void timer_init()
{
	RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;
	GPIOB->AFR[0] |= GPIO_AFRL_AFSEL3_0;
	TIM2->CR1 |= TIM_CR1_DIR;
	TIM2->CR1 |= TIM_CR1_ARPE;
	TIM2->ARR = (uint32_t) 100;
	TIM2->CCMR1 &= 0xFFFFFCFF;
	TIM2->CCMR1 |= (TIM_CCMR1_OC2M_2 | TIM_CCMR1_OC2M_1);
	TIM2->CCMR1 |= TIM_CCMR1_OC2PE;
	TIM2->CCER |= TIM_CCER_CC2E;
	TIM2->EGR = TIM_EGR_UG;
}

void timer_config()
{
	TIM2->PSC = (uint32_t) (4000000 / freq / 100);
	TIM2->CCR2 = duty_cycle;
}


int main()
{
	fpu_enable();
	gpio_init();
	keypad_init();
	timer_init();
	for(;;)
		{
			prev = curr;
			curr = keypad_scan();
			if (curr == prev)
				check = 86400;
			else
				check = curr;
			switch (check)
			{
			case 1:
				freq = DO;
				timer_config();
				TIM2->CR1 |= TIM_CR1_CEN;
				break;
			case 2:
				freq = RE;
				timer_config();
				TIM2->CR1 |= TIM_CR1_CEN;
				break;
			case 3:
				freq = MI;
				timer_config();
				TIM2->CR1 |= TIM_CR1_CEN;
				break;
			case 4:
				freq = FA;
				timer_config();
				TIM2->CR1 |= TIM_CR1_CEN;
				break;
			case 5:
				freq = SO;
				timer_config();
				TIM2->CR1 |= TIM_CR1_CEN;
				break;
			case 6:
				freq = LA;
				timer_config();
				TIM2->CR1 |= TIM_CR1_CEN;
				break;
			case 7:
				freq = SI;
				timer_config();
				TIM2->CR1 |= TIM_CR1_CEN;
				break;
			case 8:
				freq = HI_DO;
				timer_config();
				TIM2->CR1 |= TIM_CR1_CEN;
				break;
			case 10:
				duty_cycle = duty_cycle == 90 ? duty_cycle : duty_cycle + 5;
				break;
			case 11:
				duty_cycle = duty_cycle == 10 ? duty_cycle : duty_cycle - 5;
				break;
			case 86400:
				break;
			default:
				TIM2->CR1 &= ~TIM_CR1_CEN;
				freq = -1;
				break;
			}
		}
}

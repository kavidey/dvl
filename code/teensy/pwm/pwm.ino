/****************************************************************************************************************************
  PWM_Multi.ino

  For Teensy boards (Teensy 2.x, Teensy LC, Teensy 3.x, Teensy 4.x, etc.)
  Written by Khoi Hoang

  Built by Khoi Hoang https://github.com/khoih-prog/Teensy_PWM
  Licensed under MIT license
*****************************************************************************************************************************/

#define _PWM_LOGLEVEL_       4

#include "Teensy_PWM.h"

uint32_t PWM_Pins[] = { 6, 9 };

#define NUM_OF_PINS   ( sizeof(PWM_Pins) / sizeof(uint32_t) )

Teensy_PWM* PWM_Instance[NUM_OF_PINS];

void setup()
{
  Serial.begin(115200);

  while (!Serial && millis() < 5000);

  delay(500);


  for (uint8_t index = 0; index < NUM_OF_PINS; index++)
  {
    PWM_Instance[index] = new Teensy_PWM(PWM_Pins[index], 750000, 50.0f);

    if (PWM_Instance[index])
    {
      PWM_Instance[index]->setPWM();
    }
  }


  ARM_DEMCR |= ARM_DEMCR_TRCENA;
  ARM_DWT_CTRL |= ARM_DWT_CTRL_CYCCNTENA;

  flexPwmInvertPolarity(PWM_Pins[0], true);
  // flexPwmInvertPolarity(PWM_Pins[1], false);
  // flexPwmInvertPolarity(PWM_Pins[2], false);
  // flexPwmInvertPolarity(PWM_Pins[2], false);
}

void loop()
{
  //Long delay has no effect on the operation of hardware-based PWM channels
  delay(1000000);
}

void flexPwmInvertPolarity(uint8_t pin, bool inversePolarity)
{
	const struct pwm_pin_info_struct *info;

	if (pin >= CORE_NUM_DIGITAL) return;
	info = pwm_pin_info + pin;

	//return if not a FlexPWM pin
	if (info->type != 1) return;

	// FlexPWM pin
	IMXRT_FLEXPWM_t *flexpwm;
	switch ((info->module >> 4) & 3) {
		case 0: flexpwm = &IMXRT_FLEXPWM1; break;
		case 1: flexpwm = &IMXRT_FLEXPWM2; break;
		case 2: flexpwm = &IMXRT_FLEXPWM3; break;
		default: flexpwm = &IMXRT_FLEXPWM4;
	}

	unsigned int submodule = info->module & 0x03;
	uint8_t channel = info->channel;
	uint8_t polarityShift = 0;

	//find out offset for the channel
	//TODO: move magic numbers to declarations 
	switch (channel) {
	  case 0: // X
	  	polarityShift              = 8U;  //PWM_OCTRL_POLX_SHIFT
		break;
	  case 1: // A
		polarityShift              = 10U; //PWM_OCTRL_POLA_SHIFT
		break;
	  case 2: // B
	    polarityShift              = 9U;  //PWM_OCTRL_POLB_SHIFT
	}

	//if polarityShift was not initialized skip
	if(!polarityShift) return;

	//update polarity
	if(inversePolarity) {
		flexpwm->SM[submodule].OCTRL |= ((uint16_t)1U << (uint16_t)polarityShift);
	} else {
		flexpwm->SM[submodule].OCTRL &= ~((uint16_t)1U << (uint16_t)polarityShift);
	}
}
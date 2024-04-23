#define _PWM_LOGLEVEL_ 0

#include "Teensy_PWM.h"
#include <vector>

#define DUTY_CYCLE(x) ((uint32_t)x * MAX_16BIT) / 100

#define PWM_L_PIN 6
#define PWM_R_PIN 9
#define PWM_DEMOD_PIN 1
Teensy_PWM *PWM_L, *PWM_R, *PWM_DEMOD;

#define TRIGGER_PIN 4
#define MODE_PIN 5

int duty_cycle_50 = DUTY_CYCLE(50);
int center_frequency = 750000;
// int bandwidth = 10000;
// int current_frequency = 0;

void setup() {
  // Setup Serial
  Serial.begin(115200);
  while (!Serial && millis() < 5000)
    ;

  delay(500);

  // Initialize PWM
  PWM_L = new Teensy_PWM(PWM_L_PIN, center_frequency, 0);
  PWM_R = new Teensy_PWM(PWM_R_PIN, center_frequency, 0);
  PWM_DEMOD = new Teensy_PWM(PWM_DEMOD_PIN, center_frequency-100, duty_cycle_50);

  PWM_L->setPWM();
  PWM_R->setPWM();
  PWM_DEMOD->setPWM();

  ARM_DEMCR |= ARM_DEMCR_TRCENA;
  ARM_DWT_CTRL |= ARM_DWT_CTRL_CYCCNTENA;

  flexPwmInvertPolarity(6, true);
  // flexPwmInvertPolarity(PWM_Pins[1], false);
  // flexPwmInvertPolarity(PWM_Pins[2], false);
  // flexPwmInvertPolarity(PWM_Pins[2], false);

  // Setup communication pins
  pinMode(TRIGGER_PIN, INPUT_PULLUP);
  pinMode(MODE_PIN, INPUT_PULLUP);
}

void loop() {
  Serial.print(!digitalReadFast(TRIGGER_PIN));
  Serial.println(!digitalReadFast(MODE_PIN));
  if (!digitalReadFast(TRIGGER_PIN)) {
    if (!digitalReadFast(MODE_PIN)) {
      // Burst
      PWM_L->setPWM_manual(PWM_L_PIN, duty_cycle_50);
      PWM_R->setPWM_manual(PWM_R_PIN, duty_cycle_50);
      PWM_DEMOD->setPWM_manual(PWM_DEMOD_PIN, duty_cycle_50);

      delayMicroseconds(300);

      // current_frequency = center_frequency - bandwidth;

      // for (int i = -bandwidth; i < bandwidth; i = i+(bandwidth/1000)) {
      //   current_frequency = center_frequency - i;
      //   PWM_L->setPWM(PWM_L_PIN, current_frequency, duty_cycle_50);
      //   PWM_R->setPWM(PWM_R_PIN, current_frequency, duty_cycle_50);
      //   PWM_DEMOD->setPWM(PWM_DEMOD_PIN, current_frequency, duty_cycle_50);
      //   delayMicroseconds(1);
      // }

      PWM_L->setPWM_manual(PWM_L_PIN, 0);
      PWM_R->setPWM_manual(PWM_R_PIN, 0);
      PWM_DEMOD->setPWM_manual(PWM_DEMOD_PIN, 0);
      delay(50);
    } else {
      PWM_L->setPWM_manual(PWM_L_PIN, duty_cycle_50);
      PWM_R->setPWM_manual(PWM_R_PIN, duty_cycle_50);
      PWM_DEMOD->setPWM_manual(PWM_DEMOD_PIN, duty_cycle_50);
      // PWM_DEMOD->setPWM(PWM_DEMOD_PIN, 730000, duty_cycle_50);
    }
  } else {
    PWM_L->setPWM_manual(PWM_L_PIN, 0);
    PWM_R->setPWM_manual(PWM_R_PIN, 0);
    PWM_DEMOD->setPWM_manual(PWM_DEMOD_PIN, 0);
    delay(10);
  }
}

void flexPwmInvertPolarity(uint8_t pin, bool inversePolarity) {
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
    case 0:                // X
      polarityShift = 8U;  //PWM_OCTRL_POLX_SHIFT
      break;
    case 1:                 // A
      polarityShift = 10U;  //PWM_OCTRL_POLA_SHIFT
      break;
    case 2:                // B
      polarityShift = 9U;  //PWM_OCTRL_POLB_SHIFT
  }

  //if polarityShift was not initialized skip
  if (!polarityShift) return;

  //update polarity
  if (inversePolarity) {
    flexpwm->SM[submodule].OCTRL |= ((uint16_t)1U << (uint16_t)polarityShift);
  } else {
    flexpwm->SM[submodule].OCTRL &= ~((uint16_t)1U << (uint16_t)polarityShift);
  }
}
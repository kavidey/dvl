/*
File: Lab_6_JHB.c
Author: Kavi Dey
Email: kdey@hmc.edu
Date: 10/9/23

Main file for lab 6
*/

#include "lib/STM32L432KC.h"
#include "lib/STM32L432KC_GPIO.h"
#include "lib/STM32L432KC_TIM.h"
#include "lib/STM32L432KC_USART.h"
#include "stm32l432xx.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(void) {
  configureFlash();
  configureClock();

  gpioEnable(GPIO_PORT_A);
  gpioEnable(GPIO_PORT_B);
  gpioEnable(GPIO_PORT_C);

  // Initialize USART
  //USART_TypeDef *USART_DEBUG = initUSART(USART2_ID, 115200);

  initI2C();
  //sendString(USART_DEBUG, "I2C Initialized\n");

  //char responseStr[20];
  //char * response;
  char write[1] = {0x63};
  while (1) {
    // response = readI2C(0x42, 0x00, 1);
    writeI2C(0x42, 0x63, write, 1);
    //sprintf(responseStr, "Received: %02x\n", response[0]);
    //sendString(USART_DEBUG, responseStr);
  }
}

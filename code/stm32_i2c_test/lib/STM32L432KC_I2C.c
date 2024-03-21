/*
File: STM32L432KC_I2C.c
Current Author: Kavi Dey (kdey@g.hmc.edu)
Previous Contributors: Lawrence Nelson (llnelson@g.hmc.edu) and Cecilia Li
(celi@g.hmc.edu). Contributed in 2023

This code defines the functions to initialize I2C communication
*/

#include "STM32L432KC.h"
#include "STM32L432KC_I2C.h"
#include "stm32l432xx.h"

// This function initializes the I2C libaray
void initI2C(void) {
  // Configure and enable I2C Peripheral Clock in RCC
  RCC->CFGR |= _VAL2FLD(RCC_CFGR_PPRE1, 0b101); // 8MHz
  RCC->CFGR |= _VAL2FLD(RCC_CFGR_HPRE, 0b0000);
  RCC->APB1ENR1 |= RCC_APB1ENR1_I2C1EN;
  RCC->CCIPR |= _VAL2FLD(RCC_CCIPR_I2C1SEL, 0b00);

  // Disable I2C
  I2C1->CR1 &= ~I2C_CR1_PE;

  // Set pins to standard Speed
  SYSCFG->CFGR1 &= ~SYSCFG_CFGR1_I2C1_FMP;
  // SYSCFG->CFGR1 &= ~SYSCFG_CFGR1_I2C_PB6_FMP;
  // SYSCFG->CFGR1 &= ~SYSCFG_CFGR1_I2C_PB7_FMP;

  // ANFOFF
  I2C1->CR1 |= I2C_CR1_ANFOFF;

  // DNF
  I2C1->CR1 &= ~(I2C_CR1_DNF);

  // Configure Timing for 100kHz communication in standard mode
  I2C1->TIMINGR |= _VAL2FLD(I2C_TIMINGR_PRESC, 0xB);
  I2C1->TIMINGR |= _VAL2FLD(I2C_TIMINGR_SCLDEL, 0x4);
  I2C1->TIMINGR |= _VAL2FLD(I2C_TIMINGR_SDADEL, 0x2);
  I2C1->TIMINGR |= _VAL2FLD(I2C_TIMINGR_SCLH, 0xF);
  I2C1->TIMINGR |= _VAL2FLD(I2C_TIMINGR_SCLL, 0x13);

  // Enable interrupt flags
  I2C1->CR1 |= I2C_CR1_RXIE;
  I2C1->CR1 |= I2C_CR1_TXIE;
  I2C1->CR1 |= I2C_CR1_NACKIE;
  I2C1->CR1 |= I2C_CR1_STOPIE;

  // NOSTRETCH
  I2C1->CR1 &= ~(I2C_CR1_NOSTRETCH);

  // Set end commands; hardware controlled
  I2C1->CR2 |= I2C_CR2_AUTOEND;
  I2C1->CR2 &= ~I2C_CR2_RELOAD;

  // Enable I2C
  I2C1->CR1 |= I2C_CR1_PE;

  // Send clock to GPIOA/B
  RCC->AHB2ENR |=
      (RCC_AHB2ENR_GPIOAEN | RCC_AHB2ENR_GPIOBEN | RCC_AHB2ENR_GPIOCEN);

  // Initially assigning I2C pins
  pinMode(I2C_SCL, GPIO_ALT); // I2C1_SCL
  pinMode(I2C_SDA, GPIO_ALT); // I2C1_SDA

  // Set to AF04 for I2C alternate functions
  GPIOA->AFR[1] |= _VAL2FLD(GPIO_AFRH_AFSEL9, 4);
  GPIOB->AFR[1] |= _VAL2FLD(GPIO_AFRH_AFSEL10, 4);

  // Set output type to open-drain
  GPIOA->OTYPER |= GPIO_OTYPER_OT9;
  GPIOA->OTYPER |= GPIO_OTYPER_OT10;
}

void writeI2C(char dev_addr, char memory_addr, char *data, int nbytes) {
  while (I2C1->CR2 & I2C_CR2_START_Msk)
    ; // delay for nbytes setting

  // Set number of bytes for transfer
  I2C1->CR2 &= ~(I2C_CR2_NBYTES);
  I2C1->CR2 |= _VAL2FLD(I2C_CR2_NBYTES, 0x02); // sending 2 bytes

  // Set address mode, 7-BIT MODE
  I2C1->CR2 &= ~I2C_CR2_ADD10;

  // clear nackf
  I2C1->ICR |= I2C_ICR_NACKCF;

  // Set address  0x52 -> 0b0101_0010 -> 0b010_1001
  I2C1->CR2 &= ~I2C_CR2_SADD;
  I2C1->CR2 |=
      _VAL2FLD(I2C_CR2_SADD, (dev_addr)); // I2C adress of the Wii Nunchuk x52

  // Set transfer direction for a write
  I2C1->CR2 &= ~I2C_CR2_RD_WRN;

  // wait for tx buffer to clear
  while (!(I2C1->ISR & I2C_ISR_TXE_Msk))
    ;

  // Set START bit
  I2C1->CR2 |= I2C_CR2_START;

  // put data in tx buffer
  *(volatile char *)(&I2C1->TXDR) = memory_addr;

  // wait for the data to be transmitted
  while (!(I2C1->ISR & I2C_ISR_TXE_Msk))
    ;

  for (int i = 0; i < nbytes; i++) {
    // wait for tx buffer to clear
    while (!(I2C1->ISR & I2C_ISR_TXE_Msk))
      ;
    // put data in tx buffer
    *(volatile char *)(&I2C1->TXDR) = data[i];
  }
}

char *readI2C(char dev_addr, char memory_addr, int nbytes) {
  while (I2C1->CR2 & I2C_CR2_START_Msk)
    ; // delay for nbytes setting

  static char data[256];

  // Set address mode, 7-BIT MODE
  I2C1->CR2 &= ~I2C_CR2_ADD10;

  // clear nackf and stop flag
  I2C1->ICR |= I2C_ICR_NACKCF;
  I2C1->ICR |= I2C_ICR_STOPCF;

  I2C1->CR2 &= ~I2C_CR2_SADD;
  I2C1->CR2 |= _VAL2FLD(I2C_CR2_SADD, dev_addr); // I2C adress of t

  // Set transfer direction for a read
  I2C1->CR2 |= I2C_CR2_RD_WRN;

  // wait for the read bit to be written
  while (!(I2C_CR2_RD_WRN))
    ;

  // wait for the buffer
  while (!(I2C1->ISR & I2C_ISR_TXE_Msk))
    ;

  // Set number of bytes for transfer
  I2C1->CR2 &= ~(I2C_CR2_NBYTES);
  I2C1->CR2 |= _VAL2FLD(I2C_CR2_NBYTES, nbytes);

  // Set START bit
  I2C1->CR2 |= I2C_CR2_START;

  // waiting for something to fill into the RXNE block
  for (int i = 0; i < nbytes; i++) {
    while (!(I2C1->ISR & I2C_ISR_RXNE))
      ;
    data[i] = (volatile char)I2C1->RXDR;
  }

  I2C1->ICR |= I2C_ICR_STOPCF;
  return data;
}
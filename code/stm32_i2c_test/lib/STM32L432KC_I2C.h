/*
File: STM32L432KC_I2C.h
Current Author: Kavi Dey (kdey@g.hmc.edu)
Previous Contributors: Lawrence Nelson (llnelson@g.hmc.edu) and Cecilia Li (celi@g.hmc.edu). Contributed in 2023

Header file for STM32L432KC_I2C.c
*/

#include <stdint.h>
#include <stm32l432xx.h>

#define I2C_SCL PB6
#define I2C_SDA PB7

///////////////////////////////////////////////////////////////////////////////
// Function prototypes
///////////////////////////////////////////////////////////////////////////////
void initI2C(void);

void writeI2C(char dev_addr, char memory_addr, char* data, int nbytes);

char *readI2C(char dev_addr, char memory_addr, int nbytes);

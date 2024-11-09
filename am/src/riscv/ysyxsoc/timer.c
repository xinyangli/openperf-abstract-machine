#include "amdev.h"
#include "riscv/riscv.h"
#include <am.h>
#include <stdint.h>

#define RTC_ADDR 0xa0000048
static uint64_t up = 0;

void __am_timer_uptime(AM_TIMER_UPTIME_T *uptime) {
  uint32_t h = inl(RTC_ADDR + 4);
  uint32_t l = inl(RTC_ADDR);
  uint64_t time = (uint64_t)h << 32 | l;
  uptime->us = time - up;
}
void __am_timer_init() {
  uint32_t h = inl(RTC_ADDR + 4);
  uint32_t l = inl(RTC_ADDR);
  up = (uint64_t)h << 32 | l;
}

void __am_timer_rtc(AM_TIMER_RTC_T *rtc) {
  rtc->second = 0;
  rtc->minute = 0;
  rtc->hour   = 0;
  rtc->day    = 0;
  rtc->month  = 0;
  rtc->year   = 1900;
}

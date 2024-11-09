#include <am.h>
#include <amdev.h>
#include <stdint.h>
#include <nutshell.h>
#include <riscv/riscv.h>
#include <klib.h>

static uint64_t boot_time = 0;
static inline uint64_t read_time(void) {
  //Just host time
  return ind(RTC_ADDR) * 20000;  // unit: us
  //return ind(RTC_ADDR);  // unit: us
}

void __am_timer_uptime(AM_TIMER_UPTIME_T *uptime) {
  uptime->us =  read_time() - boot_time;
}

void __am_timer_rtc(AM_TIMER_RTC_T *rtc) {
  rtc->second = 0;
  rtc->minute = 0;
  rtc->hour   = 0;
  rtc->day    = 0;
  rtc->month  = 0;
  rtc->year   = 2018;
}

void __am_timer_init() {
  boot_time = read_time();
}

#include "amdev.h"
#include "riscv/riscv.h"
#include <am.h>
#include <nemu.h>
#include <stdbool.h>
#include <stdint.h>

#define AUDIO_FREQ_ADDR      (AUDIO_ADDR + 0x00)
#define AUDIO_CHANNELS_ADDR  (AUDIO_ADDR + 0x04)
#define AUDIO_SAMPLES_ADDR   (AUDIO_ADDR + 0x08)
#define AUDIO_SBUF_SIZE_ADDR (AUDIO_ADDR + 0x0c)
#define AUDIO_INIT_ADDR      (AUDIO_ADDR + 0x10)
#define AUDIO_COUNT_ADDR     (AUDIO_ADDR + 0x14)

//We assume that this configure will never change during the execution
AM_AUDIO_CONFIG_T cfg_now; 
int last_write = 0;

void __am_audio_config(AM_AUDIO_CONFIG_T *cfg) {
  cfg->present = true;
  cfg->bufsize = inl(AUDIO_SBUF_SIZE_ADDR);
}
void __am_audio_init() {
  outl(AUDIO_INIT_ADDR, 0);
  __am_audio_config(&cfg_now);
}


void __am_audio_ctrl(AM_AUDIO_CTRL_T *ctrl) {
  outl(AUDIO_FREQ_ADDR, ctrl->freq);
  outl(AUDIO_CHANNELS_ADDR, ctrl->channels);
  outl(AUDIO_SAMPLES_ADDR, ctrl->samples);
  outl(AUDIO_INIT_ADDR, 1);
}

void __am_audio_status(AM_AUDIO_STATUS_T *stat) {
  stat->count = inl(AUDIO_COUNT_ADDR);
}

void __am_audio_play(AM_AUDIO_PLAY_T *ctl) {
  int len = ctl->buf.end - ctl->buf.start;
  int count = inl(AUDIO_COUNT_ADDR);
  int size = cfg_now.bufsize;
  for(; count + len > size; count = inl(AUDIO_COUNT_ADDR)); 
  for(int i = 0; i < len; i += 4) {
    outl(last_write + AUDIO_SBUF_ADDR, *(uint32_t*)(ctl->buf.start + i));
    last_write = (last_write + 4) % size;
  }
  //Should lock here, NEMU and AM may write to this addr at the same time
  outl(AUDIO_COUNT_ADDR, inl(AUDIO_COUNT_ADDR) + len);
}

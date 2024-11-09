//#include "amdev.h"
#include "riscv/riscv.h"
#include <am.h>
#include <nemu.h>
#include <klib.h>
#include <stdint.h>
#define SYNC_ADDR (VGACTL_ADDR + 4)

static AM_GPU_CONFIG_T cfg_now;


void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
    uint32_t vga_ctrl_data = inl(VGACTL_ADDR);
    uint16_t w = vga_ctrl_data >> 16;
    uint16_t h = vga_ctrl_data & 0x0000ffff;
  *cfg = (AM_GPU_CONFIG_T) {
    .present = true, .has_accel = false,
    .width = w, .height = h,
    .vmemsz = w * h
  };
}

void __am_gpu_init() {
    __am_gpu_config(&cfg_now);
}

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {

    //size of block
    int w = ctl->w, h = ctl->h;
    //coordinates of the bottom-left pixel of the block
    int x = ctl->x, y = ctl->y;
    uint32_t pixel_idx = 0;
    uint32_t pixel = 0;
    uint32_t buffer_idx = y * cfg_now.width + x;

    for(int i = 0; i < h; i++) {
        for(int j = 0; j < w; j++) {
            pixel = *((uint32_t*)ctl->pixels + pixel_idx);
            outl(FB_ADDR + 4U * buffer_idx, pixel);
            pixel_idx++;
            buffer_idx++;
        }
        buffer_idx += cfg_now.width - w;
    }
    if (ctl->sync) {
        outl(SYNC_ADDR, 1);
    }
}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
  status->ready = true;
}

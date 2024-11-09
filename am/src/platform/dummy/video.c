#include <am.h>
#include <amdev.h>

#define W 320
#define H 240

size_t __am_video_read(uintptr_t reg, void *buf, size_t size) {
  return 0;
}

size_t __am_video_write(uintptr_t reg, void *buf, size_t size) {
  return 0;
}

void __am_vga_init() {
}

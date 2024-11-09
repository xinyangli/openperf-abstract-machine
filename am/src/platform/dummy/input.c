#include "amdev.h"
#include <am.h>

void __am_input_read(AM_INPUT_KEYBRD_T *kbd) {
  kbd->keydown = 0;
  kbd->keycode = AM_KEY_NONE;
}

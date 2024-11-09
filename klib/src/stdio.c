#include <am.h>

#include <klib-macros.h>
#include <klib.h>
#include <limits.h>
#include <stdarg.h>
#include <stdbool.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)


static int int2str(char *p, int v, size_t n) {
  if (n == 0 || p == NULL)
    return 0;
  if (v == 0) {
    *p = '0';
    return 1;
  }
  if (v == INT_MIN) {
    return stpncpy(p, "-2147483648", n) - p;
  }
  const char *const s = p;
  int idx = 0;
  char buf[16] = {0};

  int tmp = abs(v);

  while (tmp != 0) {
    buf[idx] = tmp % 10 + '0';
    tmp /= 10;
    idx++;
  }
  if(v < 0 && n > 0) {
      *p = '-';
      n--;
      p++;
  }
 idx--;
  while (idx >= 0 && n > 0) {
    *p = buf[idx];
    p++;
    idx--;
    n--;
  }
  return p - s;
}
int printf(const char *fmt, ...) {

  char buf[1024] = {0};
  va_list ap;
  va_start(ap, fmt);
  int n = vsnprintf(buf, 1024, fmt, ap);
  va_end(ap);
  for (size_t i = 0; i < n; i++) {
    putch(buf[i]);
  }
  return n;
}

int vsprintf(char *out, const char *fmt, va_list ap) {

  return vsnprintf(out, -1, fmt, ap);
}

int sprintf(char *out, const char *fmt, ...) {

  va_list ap;
  va_start(ap, fmt);
  int res = vsprintf(out, fmt, ap);
  va_end(ap);
  return res;
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);
  int res = vsnprintf(out, n, fmt, ap);
  va_end(ap);
  return res;
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap1) {

  size_t count = 0;
  va_list ap;
  va_copy(ap, ap1);

  while (count < n - 1 && *fmt != '\0') {
    switch (*fmt) {
    case '%': {
      fmt++;
      if (*fmt == '%') {
        *out = *fmt;
        out++;
        fmt++;
        count++;
      } else if (*fmt == 's') {
        char *p = va_arg(ap, char *);

        while (count < n - 1 && *p) {
          *out = *p;
          out++;
          count++;
          p++;
        }
        fmt++;

      } else if (*fmt == 'd') {
        int v = va_arg(ap, int);
        int int_num = int2str(out, v, n - 1 - count);
        count += int_num;
        out += int_num;
        fmt++;
      } else if(*fmt == 'c'){
          char c = (char)va_arg(ap, int);
          *out = c;
          out++;
          count++;
          fmt++;
      }
      else {
        //panic("not implemented");
        fmt++;
      }
      break;
    }
    default:
      *out = *fmt;
      out++;
      fmt++;
      count++;
    }
  }
  *out = '\0';
  return count;
}

#endif

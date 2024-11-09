#include <klib-macros.h>
#include <klib.h>
#include <stddef.h>
#include <stdint.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

size_t strlen(const char *s) {
  if (s == NULL)
    return 0;
  size_t count = 0;
  while (*s != '\0') {
    count++;
    s++;
  }

  return count;
}

char *strcpy(char *dst, const char *src) {

  size_t i = 0;
  while (src[i] != '\0') {
    dst[i] = src[i];
    i++;
  }

  dst[i] = '\0';
  return dst;
}
char *stpncpy(char *dst, const char *src, size_t n) {

  for (; n != 0 && (*dst = *src); src++, dst++, n--);
  return dst;
}
// copied from musl
char *stpcpy(char *dst, const char *src) {

  for (; (*dst = *src); src++, dst++)
    ;
  return dst;
}
char *strncpy(char *dst, const char *src, size_t n) {
  // If the specified size is less than or equal to the source string's length,
  // strncpy doesn't not append a null terminator to the destination buffer.
  for (size_t i = 0; i < n; i++) {
    if (src[i] != '\0')
      dst[i] = src[i];
    else {
      while (i < n) {
        dst[i] = 0;
        i++;
      }
      break;
    }
  }
  return dst;
}

char *strcat(char *dst, const char *src) {

  strcpy(dst + (strlen(dst)), src);
  return dst;
}

int strcmp(const char *s1, const char *s2) { return strncmp(s1, s2, -1); }

// refer to musl, more elegant than mine
int strncmp(const char *s1, const char *s2, size_t n) {

  unsigned char *l = (void *)s1, *r = (void *)s2;
  if (!n--)
    return 0;

  while (n && *l && *r && *l == *r) {
    l++;
    r++;
    n--;
  }
  return *l - *r;
}

void *memset(void *s, int c, size_t n) {
  if (n == 0)
    return s;
  for (size_t i = 0; i < n; i++)
    *((unsigned char *)s + i) = (unsigned char)c;

  return s;
}

void *memmove(void *dst, const void *src, size_t n) {

  if (dst == src)
    return dst;
  // A simple way to deal with overlap areas, improve in the future.
  // Can I use malloc here ? Will buf area and other areas overlap?  try to find
  // a better way.
  size_t s = (size_t)src;
  size_t d = (size_t)dst;

  if (s > d && (d + n - 1 >= s)) {
    size_t overlap_n = d + n - s;
    memcpy(dst, src, overlap_n);
    memcpy((void *)(s + overlap_n), (void *)(d + overlap_n), n - overlap_n);
  } else if (d > s && (s + n - 1 >= d)) {
    size_t overlap_n = s + n - d;
    memcpy((void *)(d + n - overlap_n), dst, overlap_n);
    memcpy(dst, src, n - overlap_n);
  } else {
    memcpy(dst, src, n);
  }

  return dst;
}

void *memcpy(void *out, const void *in, size_t n) {
  // Note that memcpy function require the memory areas do not overlap.
  // Panic directly when the input is invalid to debug. It seems to violate the
  // manual specifications.
  if (out == in)
    return out;
  size_t dest = (size_t)out;
  size_t src = (size_t)in;

  if ((dest > src && src + n - 1 < dest) ||
      (src > dest && dest + n - 1 < src)) {
    while (n != 0) {
      *(char *)(dest + n - 1) = *(char *)(src + n - 1);
      n--;
    }

  }
    return out;
  
}
  int memcmp(const void *s1, const void *s2, size_t n) {
    if (n == 0)
    return 0;
    const unsigned char *a = s1;
    const unsigned char *b = s2;
    while (n != 0) {
      if (*a == *b) {
        a++;
        b++;
        n--;
        continue;
      } else {
        return *a - *b;
      }
    }
    return 0;
  }

#endif

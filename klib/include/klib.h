#ifndef KLIB_H__
#define KLIB_H__

#include <am.h>
#include <stdarg.h>
#include <stddef.h>
#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

#ifdef __cplusplus
extern "C" {
#endif

// string.h
char *stpcpy(char *dst, const char *src);
char *stpncpy(char *dst, const char *src, size_t n);
void *memset(void *s, int c, size_t n);
void *memcpy(void *dst, const void *src, size_t n);
void *memmove(void *dst, const void *src, size_t n);
int memcmp(const void *s1, const void *s2, size_t n);
size_t strlen(const char *s);
char *strcat(char *dst, const char *src);
char *strcpy(char *dst, const char *src);
char *strncpy(char *dst, const char *src, size_t n);
int strcmp(const char *s1, const char *s2);
int strncmp(const char *s1, const char *s2, size_t n);
void *memchr(const void *src, int c, size_t n);

// stdlib.h
void srand(unsigned int seed);
int rand(void);
void *malloc(size_t size);
void free(void *ptr);
int abs(int x);
int atoi(const char *nptr);
// stdio.h
int printf(const char *format, ...);
int sprintf(char *str, const char *format, ...);
int snprintf(char *str, size_t size, const char *format, ...);
int vsprintf(char *str, const char *format, va_list ap);
int vsnprintf(char *str, size_t size, const char *format, va_list ap);

// assert.h
#ifdef NDEBUG
#define assert(ignore) ((void)0)
#else
#define assert(cond)                                                           \
  do {                                                                         \
    if (!(cond)) {                                                             \
      printf("Assertion fail at %s:%d\n", __FILE__, __LINE__);                 \
      halt(1);                                                                 \
    }                                                                          \
  } while (0)
#endif

#ifndef __cplusplus
// static_assert is keyword in c++
#define static_assert(const_cond)                                              \
  static char CONCAT(_static_assert_, __LINE__)[(const_cond) ? 1 : -1]         \
      __attribute__((unused))
#endif

#ifdef __cplusplus
}
#endif
#else
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#endif // !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)
#endif // KLIB_H_

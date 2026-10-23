#if !defined(_WIN32) && !defined(_POSIX_C_SOURCE)
#define _POSIX_C_SOURCE 199309L
#endif
#include "moonbit.h"
#ifdef _WIN32
#include <windows.h>
#else
#include <errno.h>
#include <time.h>
#endif

MOONBIT_FFI_EXPORT void moonspec_cli_generation_pause(void) {
#ifdef _WIN32
  Sleep(10);
#else
  struct timespec remaining = {0, 10000000L};
  while (nanosleep(&remaining, &remaining) == -1 && errno == EINTR) {
  }
#endif
}

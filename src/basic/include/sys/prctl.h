#pragma once

#include <features.h>

#ifdef __GLIBC__
#       include_next <sys/prctl.h>
#else

#include <stdint.h>

// TODO: assert struct size from linux and from musl are same
#include <linux/prctl.h>

int prctl (int, ...);

#endif /* __GLIBC__ */

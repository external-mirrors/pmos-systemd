#pragma once
// Mostly copied from musl sys/stat.h

#include <features.h>

#ifdef __GLIBC__
#       include_next <sys/stat.h>
#else

#define __NEED_dev_t
#define __NEED_ino_t
#define __NEED_mode_t
#define __NEED_nlink_t
#define __NEED_uid_t
#define __NEED_gid_t
#define __NEED_off_t
#define __NEED_time_t
#define __NEED_blksize_t
#define __NEED_blkcnt_t
#define __NEED_struct_timespec
#define __NEED_int64_t
#define __NEED_uint64_t
#define __NEED_uint32_t
#define __NEED_uint16_t

#include <bits/alltypes.h>
#include <bits/stat.h>
#include <linux/stat.h>

int stat(const char *__restrict, struct stat *__restrict);
int fstat(int, struct stat *);
int lstat(const char *__restrict, struct stat *__restrict);
int fstatat(int, const char *__restrict, struct stat *__restrict, int);
int chmod(const char *, mode_t);
int fchmod(int, mode_t);
int fchmodat(int, const char *, mode_t, int);
mode_t umask(mode_t);
int mkdir(const char *, mode_t);
int mkfifo(const char *, mode_t);
int mkdirat(int, const char *, mode_t);
int mkfifoat(int, const char *, mode_t);

int mknod(const char *, mode_t, dev_t);
int mknodat(int, const char *, mode_t, dev_t);

int futimens(int, const struct timespec [2]);
int utimensat(int, const char *, const struct timespec [2], int);

int lchmod(const char *, mode_t);

int statx(int, const char *__restrict, int, unsigned, struct statx *__restrict);

#define UTIME_NOW  0x3fffffff
#define UTIME_OMIT 0x3ffffffe

#endif

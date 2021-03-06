libt_openbsd_src_files_exclude_arm += \
    upstream-openbsd/lib/libc/string/memmove.c \
    upstream-openbsd/lib/libc/string/stpcpy.c \
    upstream-openbsd/lib/libc/string/strcat.c \

libt_bionic_src_files_exclude_arm += \
    arch-arm/generic/bionic/memcpy.S \
    arch-arm/generic/bionic/memset.S \
    arch-arm/generic/bionic/strcmp.S \
    arch-arm/generic/bionic/strcpy.S \
    arch-arm/generic/bionic/strlen.c \
    bionic/__strcat_chk.cpp \
    bionic/__strcpy_chk.cpp \

# Use cortext-a7 version of memset
libt_bionic_src_files_arm += \
    arch-arm/cortex-a7/bionic/memset.S \

# Use cortex-a15 versions of strcat/strcpy/strlen.
libt_bionic_src_files_arm += \
    arch-arm/cortex-a15/bionic/stpcpy.S \
    arch-arm/cortex-a15/bionic/strcat.S \
    arch-arm/cortex-a15/bionic/strcpy.S \
    arch-arm/cortex-a15/bionic/strlen.S \

# Use krait versions of strcmp
libt_bionic_src_files_arm += \
    arch-arm/krait/bionic/strcmp.S \
    arch-arm/krait/bionic/__strcat_chk.S \
    arch-arm/krait/bionic/__strcpy_chk.S \

# Use kryo versions of memcpy
libt_bionic_src_files_arm += \
    arch-arm/kryo/bionic/memcpy.S \

# Use Denver version of memmove
libt_bionic_src_files_arm += \
    arch-arm/denver/bionic/memmove.S

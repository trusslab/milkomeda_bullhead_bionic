LOCAL_PATH := $(call my-dir)


include $(CLEAR_VARS)

LOCAL_CLANG := true

LOCAL_SRC_FILES := \
    debugger.cpp \
    dlfcn.cpp \
    linker.cpp \
    linker_allocator.cpp \
    linker_block_allocator.cpp \
    linker_dlwarning.cpp \
    linker_gdb_support.cpp \
    linker_libc_support.c \
    linker_mapped_file_fragment.cpp \
    linker_memory.cpp \
    linker_phdr.cpp \
    linker_sdk_versions.cpp \
    linker_utils.cpp \
    rt.cpp \

LOCAL_SRC_FILES_arm     := arch/arm/begin.S
LOCAL_SRC_FILES_arm64   := arch/arm64/begin.S
LOCAL_SRC_FILES_x86     := arch/x86/begin.c
LOCAL_SRC_FILES_x86_64  := arch/x86_64/begin.S
LOCAL_SRC_FILES_mips    := arch/mips/begin.S linker_mips.cpp
LOCAL_SRC_FILES_mips64  := arch/mips64/begin.S linker_mips.cpp

# -shared is used to overwrite the -Bstatic and -static
# flags triggered by LOCAL_FORCE_STATIC_EXECUTABLE.
# This dynamic linker is actually a shared object linked with static libraries.
LOCAL_LDFLAGS := \
    -shared \
    -Wl,-Bsymbolic \
    -Wl,--exclude-libs,ALL \

LOCAL_CFLAGS += \
    -fno-stack-protector \
    -Wstrict-overflow=5 \
    -fvisibility=hidden \
    -Wall -Wextra -Wunused -Werror \

LOCAL_CFLAGS_arm += -D__work_around_b_24465209__
LOCAL_CFLAGS_x86 += -D__work_around_b_24465209__

LOCAL_CONLYFLAGS += \
    -std=gnu99 \

LOCAL_CPPFLAGS += \
    -Wold-style-cast \

ifeq ($(TARGET_IS_64_BIT),true)
LOCAL_CPPFLAGS += -DTARGET_IS_64_BIT
endif

ifeq ($(TARGET_NEEDS_PLATFORM_TEXT_RELOCATIONS),true)
LOCAL_CPPFLAGS += -DTARGET_NEEDS_PLATFORM_TEXT_RELOCATIONS
endif

# We need to access Bionic private headers in the linker.
LOCAL_CFLAGS += -I$(LOCAL_PATH)/../libc/

ifneq ($(LINKER_NON_PIE_EXECUTABLES_HEADER_DIR),)
    LOCAL_CFLAGS += -DENABLE_NON_PIE_SUPPORT
    LOCAL_C_INCLUDES += $(LINKER_NON_PIE_EXECUTABLES_HEADER_DIR)
    LOCAL_SRC_FILES += linker_non_pie.cpp
endif

ifneq ($(LINKER_FORCED_SHIM_LIBS),)
    LOCAL_CFLAGS += -DFORCED_SHIM_LIBS="\"$(LINKER_FORCED_SHIM_LIBS)\""
endif

# we don't want crtbegin.o (because we have begin.o), so unset it
# just for this module
LOCAL_NO_CRT := true
# TODO: split out the asflags.
LOCAL_ASFLAGS := $(LOCAL_CFLAGS)

LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk

LOCAL_STATIC_LIBRARIES := libc_nomalloc libziparchive libutils libbase libz liblog

LOCAL_FORCE_STATIC_EXECUTABLE := true

LOCAL_MODULE := linker
LOCAL_MODULE_STEM_32 := linker
LOCAL_MODULE_STEM_64 := linker65
LOCAL_MULTILIB := both

# Leave the symbols in the shared library so that stack unwinders can produce
# meaningful name resolution.
LOCAL_STRIP_MODULE := keep_symbols

# Insert an extra objcopy step to add prefix to symbols. This is needed to prevent gdb
# looking up symbols in the linker by mistake.
#
# Note we are using "=" instead of ":=" to defer the evaluation,
# because LOCAL_2ND_ARCH_VAR_PREFIX or linked_module isn't set properly yet at this point.
LOCAL_POST_LINK_CMD = $(hide) $($(LOCAL_2ND_ARCH_VAR_PREFIX)TARGET_OBJCOPY) \
  --prefix-symbols=__dl_ $(linked_module)

include $(BUILD_EXECUTABLE)


define add-linker-symlink
$(eval _from := $(TARGET_OUT)/bin/$(1))
$(eval _to:=$(2))
$(_from): $(LOCAL_MODULE_MAKEFILE)
	@echo "Symlink: $$@ -> $(_to)"
	@mkdir -p $$(dir $$@)
	@rm -rf $$@
	$(hide) ln -sf $(_to) $$@
endef

$(eval $(call add-linker-symlink,linker_asan,linker))
ifeq ($(TARGET_IS_64_BIT),true)
$(eval $(call add-linker-symlink,linker_asan64,linker65))
endif

include $(call first-makefiles-under,$(LOCAL_PATH))

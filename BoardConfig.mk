#
# Copyright (C) 2016 The CyanogenMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Retrofit dynamic partitions: the bootloader only takes Motorola signed
# partition tables, so super spans the stock system and cache partitions
# instead (see BoardConfigCommon.mk)
TARGET_MSM8226_DYNAMIC_PARTITIONS := true
TARGET_RECOVERY_FSTAB := device/motorola/peregrine/rootdir/etc/fstab.qcom

# inherit from common msm8226-common
-include device/motorola/msm8226-common/BoardConfigCommon.mk

DEVICE_PATH := device/motorola/peregrine

# Vendor Unification Init
TARGET_INIT_VENDOR_LIB := libinit_peregrine
TARGET_RECOVERY_DEVICE_MODULES := libinit_peregrine

# Board
TARGET_BOARD_INFO_FILE := $(DEVICE_PATH)/board-info.txt

# Camera
BOARD_GLOBAL_CFLAGS += -DCAMERA_VENDOR_L_COMPAT

# Kernel
TARGET_KERNEL_CONFIG := peregrine_defconfig

# Partitions
BOARD_BOOTIMAGE_PARTITION_SIZE := 10485760
ifeq ($(MSM8226_BUILD_RECOVERY),true)
# Only fastboot booted, never flashed: no partition size limit
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 67108864
else
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 10485760
endif
BOARD_USERDATAIMAGE_PARTITION_SIZE := 5930598400
# No cache image is built; the non-A/B OTA tools only need its size
BOARD_CACHEIMAGE_PARTITION_SIZE := 560070656

# Super: system (1157627904) + cache (560070656), metadata in system.
# /metadata is a logical partition too, created empty by the OTA.
BOARD_SUPER_PARTITION_SIZE := 1717698560
BOARD_SUPER_PARTITION_METADATA_DEVICE := system
BOARD_SUPER_PARTITION_BLOCK_DEVICES := system cache
BOARD_SUPER_PARTITION_SYSTEM_DEVICE_SIZE := 1157627904
BOARD_SUPER_PARTITION_CACHE_DEVICE_SIZE := 560070656
BOARD_SUPER_PARTITION_GROUPS := peregrine_dynamic_partitions
BOARD_PEREGRINE_DYNAMIC_PARTITIONS_PARTITION_LIST := system vendor
# super minus 4 MiB for the logical partition metadata
BOARD_PEREGRINE_DYNAMIC_PARTITIONS_SIZE := 1713504256
BOARD_SUPER_EMPTY_PARTITIONS := metadata:peregrine_dynamic_partitions:16777216
# All of super is handed out: group 1713504256 - metadata 16777216 =
# 1696727040, minus 8 MiB of slack for liblp's extent alignment across the
# two block devices. vendor 120 MiB, system the rest. Same total as falcon:
# a bigger system partition and a smaller cache add up to the same super.
BOARD_VENDORIMAGE_PARTITION_SIZE := 125829120
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 1562509312
# super is looked up as /dev/block/by-name/system, which ueventd only
# creates for the boot devices
BOARD_KERNEL_CMDLINE += androidboot.super_partition=system androidboot.boot_devices=msm_sdcc.1
BOARD_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy

# Properties
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop

# inherit from the proprietary version
-include vendor/motorola/peregrine/BoardConfigVendor.mk

#!/usr/bin/env python3
"""
patch_avb.py
Utility to disable AVB verification and hashtree checks on MediaTek vbmeta images.
Sets header flags at byte offset 120 (0x78) to 0x00000003.
"""

import sys
import os
import struct

def patch_file(image_path, output_path=None):
    if not os.path.isfile(image_path):
        print(f"Error: {image_path} not found.")
        return False

    with open(image_path, "rb") as f:
        data = bytearray(f.read())

    if len(data) < 124 or data[:4] != b"AVB0":
        print(f"Error: {image_path} is not a valid AVB image.")
        return False

    # Read existing flags
    flags = struct.unpack(">I", data[120:124])[0]
    print(f"Original flags for {os.path.basename(image_path)}: {hex(flags)}")

    # Set flags to 3 (AVB_VBMETA_IMAGE_FLAGS_HASHTREE_DISABLED | AVB_VBMETA_IMAGE_FLAGS_VERIFICATION_DISABLED)
    struct.pack_into(">I", data, 120, 3)

    out = output_path or image_path
    with open(out, "wb") as f:
        f.write(data)

    print(f"Patched flags -> 0x3 successfully saved to: {out}")
    return True

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python patch_avb.py <vbmeta_image.img> [output_image.img]")
        sys.exit(1)

    in_file = sys.argv[1]
    out_file = sys.argv[2] if len(sys.argv) > 2 else None
    success = patch_file(in_file, out_file)
    sys.exit(0 if success else 1)

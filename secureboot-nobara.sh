#!/usr/bin/env bash
set -euo pipefail
echo "Based on sbctl on https://github.com/Foxboron/sbctl"
echo "\nAlso huge thanks to u/Asphalt_Expert on reddit for his tutorial\n"

if [[ "$EUID" -ne 0 ]]; then
    echo "run this script as superuser dumbass (use: sudo $0)"
    exit 1
fi

echo "=== Enabling sbctl copr and installing sbctl ==="
dnf -y copr enable chenxiaolong/sbctl
dnf -y install sbctl

echo -e "\n=== Checking sbctl status ==="
sbctl status

read -rp "Do you play valorant or battlefield 6 (The stupid windows games)? (y/n): " dualboot

enroll_keys() {
    if [[ "$dualboot" =~ ^[Yy]$ ]]; then
        echo -e "\n fuck vanguard and EA's shit anti cheat for making me do this"
        sbctl enroll-keys --microsoft
    else
        sbctl enroll-keys
    fi
}

# Check Setup Mode
setup_mode=$(sbctl status | grep -i "Setup Mode" | awk '{print $3}')

if [[ "$setup_mode" == "✓" ]]; then
    echo -e "\n=== Setup Mode is Disabled ==="
    enroll_keys
    echo -e "\nContinuing without reboot..."
else
    echo -e "\n=== Setup Mode is Enabled ==="
    echo "Creating and enrolling keys..."
    sbctl create-keys
    enroll_keys
    echo -e "\nContinuing without reboot..."
fi

# --- Post key enrollment ---
echo -e "\n=== Post enrollment status ==="
sbctl status

echo -e "\n=== Signing and verifying EFI binaries ==="

while true; do
    # Run verify and strip bogus "invalid pe header" lines
    verify_output=$(sbctl verify 2>&1 | grep -v "failed to verify file")

    echo "$verify_output"

    # Extract unsigned .efi / .EFI files
    unsigned_efi=$(echo "$verify_output" | grep "✗" | awk '{print $2}' | grep -E "\.efi$|\.EFI$" || true)

    if [[ -z "$unsigned_efi" ]]; then
        echo -e "\n✅ All EFI binaries are signed!"
        break
    fi

    echo -e "\n=== Found unsigned EFI binaries ==="
    echo "$unsigned_efi"

    while read -r file; do
        [[ -z "$file" ]] && continue
        echo "Signing: $file"
        sbctl sign -s "$file" || echo "⚠️ Failed to sign $file"
    done <<< "$unsigned_efi"
done

# Sign kernel images
echo -e "\n=== Checking kernel images ==="
kernels=$(ls -1 /boot/vmlinuz-* 2>/dev/null || true)

if [[ -n "$kernels" ]]; then
    for kernel in $kernels; do
        echo "Signing kernel: $kernel"
        sbctl sign -s "$kernel" || echo "⚠️ Failed to sign $kernel"
    done
else
    echo "No kernel images found in /boot/"
fi

# Replace 91-sbctl.install supplied by sbctl package with our own, as the logic used in their script is incompatible with the boot structure of nobara. Required to ensure newly installed versions of the kernel get signed with the keys we setup in this script.
echo -e "\n=== Updating sbctl post-install scriptlet"
cp 91-sbctl.install /usr/lib/kernel/install.d/
echo -e "WARNING! As sbctl updates, our update to the post-install scriptlet will be"
echo -e "replaced with the one supplied by the package. This will cause new versions"
echo -e "of the kernel to go unsigned. To fix this, boot into a kernel that's already signed,"
echo -e "and manually copy the file over yourself."
echo -e "Open a terminal to the directory you placed nobara-secure-boot into,"
echo -e "(default is /home/nobara-secure-boot) and execute the following command:"
echo -e "sudo cp 91-sbctl.install /usr/lib/kernel/install.d/"
echo -e "Then just run the script to make it sign the kernel(s)"

# Final verify
echo -e "\n=== Final sbctl verify ==="
sbctl verify | grep -v "failed to verify file"

echo -e "\n✅ All unsigned EFI binaries and kernels have been signed!"
echo -e "\n🔒 Now reboot the system and enable Secure Boot in BIOS"
echo -e "\nAlso fuck riot games and EA for making me make this script"

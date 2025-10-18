# Nobara-secure-boot

 shell script to enable secure boot in nobara. 
## Pre-use steps
 1. Enter your bios, and reset secure boot to setup mode
 2. **DO NOT** enter any other operating system after this. From grub, boot into nobara. On most hardware, setup mode only works for the first boot after enabling it.
## Usage
Clone and cd into this repository with 
```bash
git clone https://github.com/GammaLyrae/nobara-secure-boot.git/ && cd nobara-secure-boot
```
then run the script as root with 

```bash 
sudo sh secureboot-nobara.sh
```

## Basic Troubleshooting:
"My kernels aren't getting signed anymore! I can only boot into an older version of the kernel that was signed as part of this script!"

The package "sbctl" has probably been updated. Because we replaced a script supplied by the package with one of our own directly into a system directory, updating the package overwrote our custom script. Assuming you did not delete your git clone of this repo, you can fix this by opening a terminal to your nobara-secure-boot folder and running the following commands:
```bash
sudo cp 91-sbctl.install /usr/lib/kernel/install.d/
sudo sh 91-sbctl.install
```
This will re-copy our modified script over the one supplied by the sbctl package, and then run the script to attempt to sign your kernel images again. This should let you boot into the latest kernel(s) and fix the automation for signing them as they're installed, at least until sbctl updates again.

## Issues
Please open an issue in the original repo from the original uploader here [#issues](https://github.com/degenerate-kun-69/nobara-secure-boot/issues) so they can find the fixes. I will not be maintaining this fork or offering troubleshooting assistance beyond modifications I've made for personal use that are "cutting edge" enough to a point that I've only verified they work as expected on my own machine.

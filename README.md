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
## Issues
Please open an issue in the original repo from the original uploader here [#issues](https://github.com/degenerate-kun-69/nobara-secure-boot/issues) so they can find the fixes. I will not be maintaining this fork or offering troubleshooting assistance beyond modifications I've made for personal use that are "cutting edge" enough to a point that I've only verified they work as expected on my own machine.

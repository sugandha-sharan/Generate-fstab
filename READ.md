# generate-fstab.sh
The shell script to convert yaml file containing fstab entry to fstab format.

Structure:

```bash
.

├── README.md
├── sample-fstab.yml
├── generate-fstab.sh

## Requirement
To run the script, one must fulfill some requirements.
- Script is ran in: Python 3.9.9 but should work above **Python 3.6+**
- Pip(use pip3 if needed according to your system) should be installed and necessarily for python3.
- yq tool needs to be installed 

## Prepare environment

### Install required libraries to work with this tool.

```bash
$  pip install yq 
```
## How to run this script

$ ./generate-fstab.sh

## Variables used in the script
YAML_FILE: YAML File with entries of different fs, refer sample-fstab.yml 
OFILE: Output fstab file

## Sample run  with sample-fstab.yml
$ ./generate-fstab.sh
creating fstab file in current directory
Adding entry to fstab: "/dev/sda1: /boot xfs defaults 0 2"
Adding entry to fstab: "/dev/sda2: / ext4 defaults 0 1"
Adding entry to fstab: "/dev/sdb1: /var/lib/postgresql ext4 defaults,createopts="-m 10" 0 2"
Adding entry to fstab: "192.168.4.5:/var/nfs/home /home nfs noexec,nosuid 0 2"
$ 


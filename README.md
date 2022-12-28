## Home Assistant bash scripts for OpenWrt devices
This script allows to remotely enable or disable a firewall rule on an OpenWrt router. I personaly use this to block internet from certain device(s) in my network on demand. Be aware that to create rule names without spaces.

### Features:
* Switches:
  * Enable/disable firewall rules

### Installing
* OpenWrt device(s):
  * No packages need to be installed

### Home Assistant configuration
* Connect to Home Assistant shell
  * Create a folder `/config/bash_scripts` 
  * Generate a new certificate using `ssh-keygen` and save it at `/config/bash_scripts/openwrt`:
  * Copy the newly created certificate to openwrt with `ssh-copy-id -i /config/bash_scripts/openwrt root@openwrt.lan`
  * Copy the file `openwrt_firewall.sh` to `/config/bash_scripts`
  * Edit `openwrt_firewall.sh` and add the IP address of your router

### Switch
Switch configuration could look like below:
```yaml
{
# Example configuration.yaml entry
switch:
  - platform: command_line
    switches:
        allow_john_devices:
        friendly_name: Allow John Devices
        command_on: >
            /bin/bash /config/bash_scripts/openwrt_firewall.sh set_rule_state Allow-John 1
        command_off: >
            /bin/bash /config/bash_scripts/openwrt_firewall.sh set_rule_state Allow-John 0
        command_state: >
            /bin/bash /config/bash_scripts/openwrt_firewall.sh get_rule_state Allow-John
        value_template: '{{ value == "1" }}'
```


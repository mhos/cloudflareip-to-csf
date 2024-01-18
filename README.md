## CloudFlare IP Update Script for CSF (ConfigServer Firewall)

This Bash script, automates the daily update of CloudFlare IP lists on a server. 
It performs the following tasks:

1. Retrieves current CloudFlare IPv4 and IPv6 addresses.
2. Updates the csf/cloudflare.allow file with the new IPs.
3. Modifies csf.allow and csf.ignore files accordingly.
4. Restarts CSF/LFD (ConfigServer Firewall and Login Failure Daemon).
5. Creates a daily cron job for continuous automation.

### How to Run

To execute the script, run the following command:

```bash
bash <(curl -s https://raw.githubusercontent.com/mhos/cloudflareip-to-csf/main/cloudflare_ip_csf.sh)

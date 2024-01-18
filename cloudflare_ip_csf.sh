#!/bin/bash

# Created By Casey O'Connor
# Date: 1/18/2024
# Adds cron to daily update CloudFlare IP lists.

# File paths
csf_allow_file="/etc/csf/csf.allow"
csf_ignore_file="/etc/csf/csf.ignore"
cloudflare_ips_script="/etc/cron.daily/cloudflareips"

# Line to find in csf.allow
line_to_find_allow="# add it to csf.ignore"

# Line to add under it in csf.allow
line_to_add_allow="Include /etc/csf/cloudflare.allow"

# Line to add under 127.0.0.1 in csf.ignore
line_to_add_ignore="Include /etc/csf/cloudflare.allow"

# CloudFlare IPs List URLs
cloudflare_ips=`curl -s https://www.cloudflare.com/ips-v4`
cloudflare_ips+=`echo -e "\n" && curl -s https://www.cloudflare.com/ips-v6`

# Update CloudFlare IPs in csf/cloudflare.allow
rm -rf /etc/csf/cloudflare.allow
touch /etc/csf/cloudflare.allow

for ip in ${cloudflare_ips}; do
    echo $ip >> /etc/csf/cloudflare.allow
done

# Check if the line to add already exists in csf.allow
if grep -q "$line_to_add_allow" "$csf_allow_file"; then
    echo "Line already exists in $csf_allow_file. No changes made for csf.allow."
else
    # Find the line in csf.allow
    if grep -q "$line_to_find_allow" "$csf_allow_file"; then
        # Add the line under it in csf.allow
        sed -i "/$line_to_find_allow/a $line_to_add_allow" "$csf_allow_file"
        echo "Line added successfully in csf.allow."
    else
        echo "Line not found in $csf_allow_file for csf.allow."
    fi
fi

# Check if the line to add already exists in csf.ignore
if grep -q "$line_to_add_ignore" "$csf_ignore_file"; then
    echo "Line already exists in $csf_ignore_file. No changes made for csf.ignore."
else
    # Add the line under 127.0.0.1 in csf.ignore
    sed -i "/127.0.0.1/a $line_to_add_ignore" "$csf_ignore_file"
    echo "Line added successfully in csf.ignore."
fi

# Restart CSF/LFD
csf -ra

# Create /etc/cron.daily/cloudflareips script
echo "#!/bin/bash

# CloudFlare IPs List URLs
IPS=\`curl -s https://www.cloudflare.com/ips-v4\`
IPS+=\`echo -e \"\\n\" && curl -s https://www.cloudflare.com/ips-v6\`

# Remove stale CloudFlare include file
rm -rf /etc/csf/cloudflare.allow
touch /etc/csf/cloudflare.allow

# Loop IPs into include file
for ip in \${IPS}; do
    echo \$ip >> /etc/csf/cloudflare.allow
done

# Restart CSF/LFD
csf -ra
" | sudo tee /etc/cron.daily/cloudflareips > /dev/null

# Make /etc/cron.daily/cloudflareips executable
chmod +x "$cloudflare_ips_script"

echo "CloudFlare IPs update script and cron job added successfully."

#/bin/sh
# Install and Configure Fusion Forge and its dependencies

# declare some variables
SHARED_FOLDER=/vagrant

# Add the FF repository
cat <<EOF > /etc/apt/sources.list.d/fusionforge.list 
deb http://fusionforge.fusionforge.org/deb/5.2 wheezy main
deb-src http://fusionforge.fusionforge.org/deb/5.2 wheezy main
EOF

# Add the archive key by running
wget -q http://fusionforge.fusionforge.org/deb/5.2/key -O- | apt-key add -

# Preinject apt-get responses
cat <<EOF > /etc/apt/apt.conf.d/90forceyes
APT::Get::Assume-Yes "true";
APT::Get::force-yes "true";
EOF

# Run update our package databases
apt-get update

# Use some major overkill to avoid the postgres encoding problem
apt-get install locales-all
locale-gen
export LC_ALL=en_US.utf8
export LANGUAGE=en_US.utf8
export LANG=en_US.UTF-8
update-locale LC_CTYPE=en_US.UTF-8
apt-get install postgresql
sed -e "s/en_US/en_US.utf8/;" -i /etc/postgresql/9.1/main/postgresql.conf

# Pre-load debconf with answers to configuration questions
apt-get install debconf-utils
debconf-set-selections $SHARED_FOLDER/debconf-responses

# Make sure debconf does NOT ask questions if it knows the answers
cat <<EOF >/etc/sudoers.d/env_keep
Defaults	env_keep += "DEBIAN_FRONTEND"
EOF
chmod 0440 /etc/sudoers.d/env_keep
export DEBIAN_FRONTEND=noninteractive

# Install gforge-db-postgresql and fix its character encoding problem
apt-get install gforge-db-postgresql
# this line might be the only needed to fix the postgres encoding problem
sed -e "s/UNICODE/UTF8/" -i /usr/share/gforge/bin/install-db.sh

# Install FusionForge Standard as the Full Edition has dependency issues with bazaar
apt-get install fusionforge-standard

# Install FusionForge plugin we will need
apt-get install fusionforge-plugin-contribtracker fusionforge-plugin-headermenu \
  fusionforge-plugin-globalsearch fusionforge-plugin-mediawiki \
  fusionforge-plugin-moinmoin fusionforge-plugin-projectlabels \
  fusionforge-plugin-scmgit fusionforge-plugin-blocks fusionforge-plugin-hudson

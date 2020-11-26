#! /bin/sh

mk_squid_pam() {
cat >/etc/pam.d/squid <<EOF
auth required pam_unix.so
account required pam_unix.so
EOF
}

fix_helper_perm() {
   chmod a+s /usr/local/libexec/squid/basic_pam_auth
}

mk_users() {
  if [ ! -f /root/chpasswd ]; then
      echo /root/chpasswd found
      exit 1
  fi

  chmod a+x /root/chpasswd

  for _user in `echo $proxy_users`; do
      pw user add $_user -m
      _z1=`echo $_user passwd | sed 's/ /_/g'`
      _z2="echo \$$_z1"
      _passwd=`eval $_z2`
      /root/chpasswd $_user $_passwd
  done
}

if [ -f /root/proxy.conf ]; then
   . /root/proxy.conf
fi

mk_squid_pam
fix_helper_perm
mk_users

sysrc squid_enable="YES"
service squid start

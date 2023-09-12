#cloud-config
ssh_pwauth: true

runcmd:
%{ if length(custom_repos) > 0 }
%{ if custom_repos_type == "yum" }
- find /etc/yum.repos.d -type f ! -name 'tpl*' -delete
%{ endif }
%{ endif }
- yum install -y fio

users:
- name: ansible
  gecos: Ansible User
  groups: users,admin,wheel
  sudo: ALL=(ALL) NOPASSWD:ALL
  shell: /bin/bash
  lock_passwd: false
  plain_text_passwd: ${root_pass}

%{ if length(custom_repos) > 0 }
%{ if custom_repos_type == "yum" }
yum_repos:
  %{ for repo in custom_repos }
  tpl-${repo.name}:
    baseurl: ${repo.url}
    name: "tpl-${repo.name}"
    enabled: ${repo.enabled}
    gpgcheck: ${repo.gpgcheck}
    %{ endfor }
%{ endif }
%{ endif }
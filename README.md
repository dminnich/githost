# Project Git UserDir PaaS

The files in this repo will help you stand up a server where users can create free static content webhosting accounts.  Their content will be seen at http://example.com/~user and will be managed and backed by git.  Meaning, a 'git push' is all they will need to upload their changes.  This is how a lot of the new fancy PaaS vendors work and it should be relatively easy to extend this to support languages other than just html.

It accomplishes these things by using
  - Git post-receive hooks
  - ansible
  - apache
  - ruby, passenger, and a sinatra webapp

Setting it up
  - Create a CentOS 7 VM
  - Set its hostname to be your top level domain
  - Create a CNAME DNS record for signup.example.com that points at your example.com that points at your server
  - Disable selinux on it and reboot
  - ssh-keygen
  - ssh-copyid root@localhost
  - yum -y install epel-release
  - yum -y install ansible git
  - cd /opt
  - git clone https://github.com/dminnich/githost
  - cd githost
  - ansible-playbook -i inventory install-server.yaml  -v

Testing it

- go to http://example.com
- create an account
- git clone ssh://username@example.com/~/geekhost_home_folder.git
- cd geekhost_home_folder
- edit your public_html/index.html page
- git add .
- git commit -m "first edit"
- git push origin master
- go to http://example.com/~username

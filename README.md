# Project 1 – Linux Web Server (AlmaLinux 9.6 + Nginx)

This is the starter repository for Project 1 adjusted for AlmaLinux (RHEL-based).
Follow the PDF guide or the chat instructions to deploy this on an AlmaLinux server (local VM or EC2).

Structure:
- scripts/: helper scripts for setup and SSH hardening (AlmaLinux-specific)
- site/: sample static site to deploy
- .gitignore: common ignores

NOTE: Review and run scripts carefully. You may need to install 'policycoreutils-python-utils' for SELinux tools,
and enable EPEL if you want to install certbot later (for HTTPS).

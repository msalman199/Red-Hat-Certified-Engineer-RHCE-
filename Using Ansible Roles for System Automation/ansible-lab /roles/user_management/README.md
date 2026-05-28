# User Management Role

This Ansible role provides comprehensive user management capabilities for Linux systems.

## Features

- Create and remove users
- Manage user groups
- Configure SSH keys
- Set password policies
- Handle user home directories

## Requirements

- Ansible 2.9 or higher
- Target systems: RHEL/CentOS 7+, Ubuntu 18.04+

## Role Variables

### Default Variables

```yaml
users_to_create: []
users_to_remove: []
default_shell: /bin/bash
default_groups: []
create_home: true

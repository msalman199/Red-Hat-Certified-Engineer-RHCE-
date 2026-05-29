#!/usr/bin/env python3

import json
import sys
import subprocess

def get_inventory():
    inventory = {
        '_meta': {
            'hostvars': {}
        },
        'webservers': {
            'hosts': [],
            'vars': {
                'ansible_user': 'ansible',
                'http_port': 80,
                'max_clients': 200
            }
        },
        'us_east': {
            'hosts': [],
            'vars': {
                'region': 'us-east-1',
                'datacenter': 'virginia'
            }
        },
        'us_west': {
            'hosts': [],
            'vars': {
                'region': 'us-west-2',
                'datacenter': 'oregon'
            }
        },
        'europe': {
            'hosts': [],
            'vars': {
                'region': 'eu-west-1',
                'datacenter': 'ireland'
            }
        }
    }
    
    # Simulate discovering hosts (in production, this would query cloud APIs)
    hosts = [
        {'name': 'web-us-east-01', 'ip': '10.0.1.10', 'region': 'us_east'},
        {'name': 'web-us-east-02', 'ip': '10.0.1.11', 'region': 'us_east'},
        {'name': 'web-us-west-01', 'ip': '10.0.2.10', 'region': 'us_west'},
        {'name': 'web-us-west-02', 'ip': '10.0.2.11', 'region': 'us_west'},
        {'name': 'web-eu-west-01', 'ip': '10.0.3.10', 'region': 'europe'},
        {'name': 'web-eu-west-02', 'ip': '10.0.3.11', 'region': 'europe'}
    ]
    
    for host in hosts:
        # Add to webservers group
        inventory['webservers']['hosts'].append(host['name'])
        
        # Add to regional group
        inventory[host['region']]['hosts'].append(host['name'])
        
        # Add host variables
        inventory['_meta']['hostvars'][host['name']] = {
            'ansible_host': host['ip'],
            'region_name': host['region'],
            'server_id': host['name']
        }
    
    return inventory

if __name__ == '__main__':
    if len(sys.argv) == 2 and sys.argv[1] == '--list':
        print(json.dumps(get_inventory(), indent=2))
    elif len(sys.argv) == 3 and sys.argv[1] == '--host':
        print(json.dumps({}))
    else:
        print("Usage: %s --list or %s --host <hostname>" % (sys.argv[0], sys.argv[0]))
        sys.exit(1)

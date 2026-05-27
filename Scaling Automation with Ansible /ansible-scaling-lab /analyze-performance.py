#!/usr/bin/env python3
import json
import os
import statistics
from datetime import datetime

def analyze_performance_results():
    results_dir = "/tmp/ansible-performance"
    results = []
    
    # Read all performance result files
    for filename in os.listdir(results_dir):
        if filename.endswith('-performance.json'):
            with open(os.path.join(results_dir, filename), 'r') as f:
                results.append(json.load(f))
    
    if not results:
        print("No performance results found!")
        return
    
    print("=== Ansible Performance Analysis ===")
    print(f"Total hosts tested: {len(results)}")
    print(f"Test timestamp: {results[0]['test_timestamp']}")
    print()
    
    # Analyze test durations
    durations = [r['test_duration_seconds'] for r in results]
    print("=== Test Duration Analysis ===")
    print(f"Average duration: {statistics.mean(durations):.2f} seconds")
    print(f"Minimum duration: {min(durations)} seconds")
    print(f"Maximum duration: {max(durations)} seconds")
    print(f"Standard deviation: {statistics.stdev(durations):.2f} seconds")
    print()
    
    # Analyze system resources
    print("=== System Resources Summary ===")
    total_cpu_cores = sum(r['system_info']['cpu_cores'] for r in results)
    total_memory_gb = sum(r['system_info']['memory_mb'] for r in results) / 1024
    total_disk_gb = sum(r['system_info']['disk_space_gb'] for r in results)
    
    print(f"Total CPU cores: {total_cpu_cores}")
    print(f"Total memory: {total_memory_gb:.2f} GB")
    print(f"Total disk space: {total_disk_gb:.2f} GB")
    print()
    
    # Test results summary
    print("=== Test Results Summary ===")
    for result in results:
        hostname = result['hostname']
        tests = result['performance_tests']
        
        print(f"Host: {hostname}")
        for test_name, test_data in tests.items():
            status = test_data.get('status', 'unknown')
            print(f"  {test_name}: {status}")
        print()
    
    # Performance recommendations
    print("=== Performance Recommendations ===")
    if max(durations) > 60:
        print("- Consider increasing Ansible forks for better parallelization")
    if statistics.stdev(durations) > 10:
        print("- High variance in execution times detected - check network connectivity")
    if len(results) > 10:
        print("- For large inventories, consider using Ansible Tower/AWX for better scaling")
    
    print("\nAnalysis complete!")

if __name__ == "__main__":
    analyze_performance_results()
EOF

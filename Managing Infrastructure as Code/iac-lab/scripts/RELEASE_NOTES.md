# Release Notes - Version $VERSION

## Changes in this release:
$(cat CHANGELOG.tmp)

## Infrastructure Components:
- Web Servers: $(grep -A 10 "webservers:" infrastructure.yml | grep "count:" | awk '{print $2}') instances
- Database Servers: $(grep -A 10 "databases:" infrastructure.yml | grep "count:" | awk '{print $2}') instances  
- Load Balancers: $(grep -A 10 "loadbalancers:" infrastructure.yml | grep "count:" | awk '{print $2}') instances

## Deployment Instructions:
1. Review the changes in this release
2. Test in development environment first
3. Deploy to staging for validation
4. Deploy to production during maintenance window

## Rollback Plan:
If issues occur, rollback using:
\`\`\`bash
git checkout <previous-tag>
ansible-playbook playbooks/deploy-infrastructure.yml
\`\`\`

Generated: $(date)
EOL

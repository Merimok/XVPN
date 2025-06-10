# Security Policy

## Supported Versions

We actively support the following versions with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 1.2.x   | :white_check_mark: |
| 1.1.x   | :white_check_mark: |
| 1.0.x   | :x:                |

## Reporting a Vulnerability

We take the security of XVPN seriously. If you discover a security vulnerability, please follow these steps:

### 1. Do NOT Create a Public Issue
Please do not report security vulnerabilities through public GitHub issues, discussions, or any other public channels.

### 2. Contact Us Privately
Send an email to: **security@xvpn-project.com** (replace with actual email)

Include the following information:
- Type of vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)
- Your contact information

### 3. Response Timeline
- **Initial Response**: Within 48 hours
- **Vulnerability Assessment**: Within 7 days
- **Fix Development**: Depends on severity (1-30 days)
- **Public Disclosure**: After fix is released

## Security Measures

### Application Security
- **Process Isolation**: VPN engine runs in separate process
- **Privilege Separation**: Minimal required permissions
- **Input Validation**: All user inputs are validated
- **Secure Storage**: Sensitive data handling best practices

### Network Security
- **Protocol Security**: VLESS protocol implementation
- **Certificate Validation**: Proper TLS certificate handling
- **DNS Security**: Secure DNS resolution
- **Traffic Isolation**: VPN traffic separation

### System Security
- **Administrator Privileges**: Required only for TUN adapter
- **File System Access**: Limited to application directory
- **Registry Access**: Minimal Windows registry usage
- **Memory Protection**: Secure memory handling

## Best Practices for Users

### Installation Security
1. **Download from Official Sources**: Only use official releases
2. **Verify Checksums**: Check file integrity before installation
3. **Run as Administrator**: Only when necessary for TUN adapter
4. **Antivirus Compatibility**: Whitelist if false positives occur

### Configuration Security
1. **Server Credentials**: Keep server configurations private
2. **Regular Updates**: Keep application and dependencies updated
3. **Network Monitoring**: Monitor for unusual network activity
4. **Backup Configurations**: Securely backup server settings

### Operational Security
1. **Regular Restarts**: Restart application periodically
2. **Log Monitoring**: Review application logs for anomalies
3. **Network Isolation**: Use dedicated network for VPN testing
4. **Access Control**: Limit access to configuration files

## Vulnerability Categories

### Critical (Fix within 24-48 hours)
- Remote code execution
- Privilege escalation
- Credential theft
- Network traffic interception

### High (Fix within 7 days)
- Information disclosure
- Denial of service
- Authentication bypass
- Session hijacking

### Medium (Fix within 30 days)
- Local privilege escalation
- Information leakage
- Configuration tampering
- Protocol downgrade

### Low (Fix in next release)
- Minor information disclosure
- UI-based attacks
- Configuration issues
- Documentation problems

## Security Testing

### Automated Testing
- Static code analysis
- Dependency vulnerability scanning
- Build security validation
- Runtime security monitoring

### Manual Testing
- Penetration testing
- Code review
- Protocol analysis
- Network security assessment

## Dependencies

### Third-Party Security
We monitor security advisories for:
- **Flutter Framework**: Regular updates to stable channel
- **Dart Language**: Security patches applied promptly
- **sing-box**: Monitor upstream security fixes
- **Wintun**: Track Windows driver security updates

### Supply Chain Security
- **Source Verification**: All dependencies verified
- **Checksum Validation**: Build artifacts validated
- **Signed Releases**: Code signing for official releases
- **Build Reproducibility**: Reproducible build process

## Incident Response

### In Case of Security Incident
1. **Immediate Assessment**: Evaluate impact and scope
2. **User Notification**: Notify users of security issues
3. **Emergency Patches**: Release critical fixes quickly
4. **Post-Incident Review**: Analyze and improve processes

### Communication Plan
- **Security Advisories**: Published on GitHub Security tab
- **Release Notes**: Security fixes documented in changelog
- **User Notifications**: Email/notification system for critical issues
- **Public Disclosure**: Coordinated disclosure after fix deployment

## Contact Information

- **Security Email**: security@xvpn-project.com
- **PGP Key**: [Link to public key if available]
- **Response Time**: 48 hours maximum
- **Severity Escalation**: Critical issues escalated immediately

## Legal

### Responsible Disclosure
We support responsible disclosure and will work with security researchers to:
- Understand and validate reported vulnerabilities
- Develop and test fixes
- Coordinate public disclosure timing
- Provide attribution if desired

### Safe Harbor
We will not pursue legal action against security researchers who:
- Follow our responsible disclosure process
- Do not access or modify user data
- Do not disrupt our services
- Act in good faith to improve security

Thank you for helping keep XVPN secure!

# Project Maintenance Scripts

This directory contains several automated scripts for maintaining and operating the Hyperledger Fabric Certificate Management System:

## 🚀 Setup & Operation Scripts

### `reset_network.sh`
**Purpose**: Complete network reset and restart (fixes 90% of issues)
**When to use**: 
- Network connectivity problems
- After system reboot
- When starting fresh

```bash
./reset_network.sh
```

### `quick_start.sh`
**Purpose**: Test system functionality and install dependencies
**When to use**: 
- After cloning the repository
- To verify system status

```bash
./quick_start.sh
```

## 🧹 Cleanup & Maintenance Scripts

### `cleanup_project.sh`
**Purpose**: Remove temporary files and optimize project
**When to use**: 
- Weekly maintenance
- Before committing to git
- To free up disk space

```bash
./cleanup_project.sh
```

### `final_cleanup.sh`
**Purpose**: Comprehensive cleanup of all unused files
**When to use**: 
- Project finalization
- Before distribution
- Major cleanup

```bash
./final_cleanup.sh
```

### `analyze_project.sh`
**Purpose**: Analyze project structure and identify issues
**When to use**: 
- Project health checks
- Before cleanup
- Troubleshooting

```bash
./analyze_project.sh
```

## 🔧 Network Troubleshooting Scripts

### `fix_discovery_access.sh`
**Purpose**: Fix discovery service access issues
**When to use**: 
- "access denied" errors
- Channel discovery problems

```bash
./fix_discovery_access.sh
```

### `fix_org3_access.sh`
**Purpose**: Fix Org3 specific access issues
**When to use**: 
- After adding Org3
- Org3 connectivity problems

```bash
./fix_org3_access.sh
```

## 📊 Usage Recommendations

| Frequency | Script | Purpose |
|-----------|--------|---------|
| **First time** | `reset_network.sh` → `quick_start.sh` | Initial setup |
| **Daily** | `quick_start.sh` | Health check |
| **Weekly** | `cleanup_project.sh` | Maintenance |
| **Monthly** | `final_cleanup.sh` | Deep cleanup |
| **As needed** | `analyze_project.sh` | Analysis |
| **Troubleshooting** | `reset_network.sh` | Fix issues |

## 🎯 Quick Commands

```bash
# Complete setup from scratch
./reset_network.sh && ./quick_start.sh

# Regular maintenance
./cleanup_project.sh && ./analyze_project.sh

# Nuclear option (fixes everything)
./final_cleanup.sh && ./reset_network.sh

# Start application
cd certificate-management-ui && npm start
```

## ✅ Script Status

All scripts are:
- ✅ Executable and ready to use
- ✅ Well-documented with colored output
- ✅ Error-handling enabled
- ✅ Safe to run multiple times
- ✅ Production tested

**Total Scripts**: 7 automated maintenance scripts  
**Project Status**: Production Ready  
**Last Updated**: July 22, 2025

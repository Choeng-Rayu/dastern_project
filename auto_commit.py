#!/usr/bin/env python3
"""
Auto commit script - commits files one by one with push after each commit
Handles unstaged changes properly
"""
import subprocess
import sys
import os

def run_command(cmd):
    """Run a shell command and return output"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, cwd="/home/rayu/dastern_project")
        return result.returncode, result.stdout.strip(), result.stderr.strip()
    except Exception as e:
        print(f"Error running command: {e}")
        return 1, "", str(e)

def get_unstaged_changes():
    """Get all unstaged changes"""
    code, out, err = run_command("git diff --name-status")
    if code == 0:
        return out.split('\n') if out else []
    return []

def commit_by_directory():
    """Group files by top-level directory and commit"""
    # First add all changes
    print("Adding all changes...")
    code, out, err = run_command("git add -A")
    if code != 0:
        print(f"Error adding changes: {err}")
        return False
    
    changes = get_unstaged_changes()
    if not changes:
        # Try getting from staged instead
        code, out, err = run_command("git diff --cached --name-status")
        changes = out.split('\n') if out else []
    
    if not changes:
        print("No changes to commit")
        return False
    
    # Group by top-level directory
    directories = {}
    for line in changes:
        if not line.strip():
            continue
        parts = line.split('\t')
        if len(parts) >= 2:
            filepath = parts[1]
            # Get the top-level directory
            topdir = filepath.split('/')[0]
            if topdir not in directories:
                directories[topdir] = []
            directories[topdir].append(filepath)
    
    print(f"Found {len(directories)} directories to commit")
    print(f"Directories: {list(directories.keys())}")
    print()
    
    # Commit each directory
    for dirname, files in sorted(directories.items()):
        print(f"Processing: {dirname} ({len(files)} files)")
        
        # Reset staging
        code, out, err = run_command("git reset")
        if code != 0:
            print(f"  Error resetting: {err}")
        
        # Add all files in this directory
        for filepath in files:
            code, out, err = run_command(f"git add '{filepath}'")
            if code != 0:
                print(f"  Warning adding {filepath}: {err}")
        
        # Check if there's anything staged
        code, staged_out, err = run_command("git diff --cached --name-only")
        staged_files = [f for f in staged_out.split('\n') if f.strip()]
        
        if not staged_files:
            print(f"  Skipping {dirname} - no files staged")
            continue
        
        # Commit
        print(f"  Committing {dirname}...")
        code, out, err = run_command(f'git commit -m "{dirname}"')
        if code != 0:
            print(f"  Error committing: {err}")
            continue
        
        print(f"  ✓ Committed: {dirname}")
        
        # Push
        print(f"  Pushing {dirname}...")
        code, out, err = run_command("git push origin main -f")
        if code != 0:
            print(f"  Error pushing: {err}")
            return False
        
        print(f"  ✓ Pushed: {dirname}")
        print()
    
    return True

def main():
    print("=" * 60)
    print("Auto Commit Script")
    print("=" * 60)
    print()
    
    # Check if we're in a git repo
    code, out, err = run_command("git status")
    if code != 0:
        print("Not in a git repository!")
        sys.exit(1)
    
    # Get current status
    code, status_out, err = run_command("git status --short")
    print(f"Current status ({len([l for l in status_out.split(chr(10)) if l.strip()])} changes):")
    if status_out:
        lines = status_out.split('\n')
        for line in lines[:10]:
            if line.strip():
                print(f"  {line}")
        if len(lines) > 10:
            print(f"  ... and {len(lines) - 10} more")
    print()
    
    # Commit all changes
    if commit_by_directory():
        print("=" * 60)
        print("✓ All commits completed successfully!")
        print("=" * 60)
        
        # Final status
        code, status_out, err = run_command("git status")
        print(f"\nFinal status:\n{status_out}")
    else:
        print("=" * 60)
        print("✗ Commit process interrupted")
        print("=" * 60)
        sys.exit(1)

if __name__ == "__main__":
    main()

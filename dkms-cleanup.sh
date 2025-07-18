#!/bin/bash

# ╔═══════════════════════════════════════════╗
# ║         🔧 DKMS Cleanup Utility           ║
# ║      Remove broken or stale builds        ║
# ╚═══════════════════════════════════════════╝

DKMS_DIR="/var/lib/dkms"
REMOVED=0
REMOVED_LIST=()
DRY_RUN=false
INTERACTIVE=false
LOGFILE=""

print_help() {
    cat <<EOF
Usage: $0 [options]

Options:
  --dry-run           Show what would be removed without deleting
  --interactive       Ask before deleting each entry
  --log <file>        Write output to the specified logfile
  --help              Show this help message and exit

Description:
  Scans for broken DKMS modules (missing source directories)
  and stale kernel-specific builds for uninstalled kernels.
EOF
}

log() {
    echo -e "$1"
    [ -n "$LOGFILE" ] && echo -e "$1" >> "$LOGFILE"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --interactive)
            INTERACTIVE=true
            shift
            ;;
        --log)
            LOGFILE="$2"
            shift 2
            ;;
        --help)
            print_help
            exit 0
            ;;
        *)
            log "❌ Unknown option: $1"
            print_help
            exit 1
            ;;
    esac
done

log "🔍 Scanning for broken DKMS modules and old kernel-specific builds..."
installed_kernels=$(ls /lib/modules/)

for module in "$DKMS_DIR"/*; do
    [ -d "$module" ] || continue
    mod_name=$(basename "$module")

    for version in "$module"/*; do
        [ -d "$version" ] || continue
        ver_name=$(basename "$version")
        src_dir="$version/source"
        kernel_version="$ver_name"

        if [ ! -d "$src_dir" ]; then
            log "⚠️  Broken DKMS module: $mod_name/$ver_name (missing source)"
            if $DRY_RUN; then
                log "💡 [Dry Run] Would remove: $version"
            else
                if $INTERACTIVE; then
                    read -p "❗ Remove $version? (y/n): " confirm
                    [[ "$confirm" != "y" ]] && continue
                fi
                sudo rm -rf "$version"
                log "🧹 Removed: $version"
                ((REMOVED++))
                REMOVED_LIST+=("$mod_name/$ver_name")
            fi
        elif ! echo "$installed_kernels" | grep -Fxq "$kernel_version"; then
            log "⚠️  Stale build: $mod_name/$ver_name (kernel $kernel_version not installed)"
            if $DRY_RUN; then
                log "💡 [Dry Run] Would remove: $version"
            else
                if $INTERACTIVE; then
                    read -p "❗ Remove $version? (y/n): " confirm
                    [[ "$confirm" != "y" ]] && continue
                fi
                sudo rm -rf "$version"
                log "🧹 Removed: $version"
                ((REMOVED++))
                REMOVED_LIST+=("$mod_name/$ver_name")
            fi
        fi
    done
done

if [ "$REMOVED" -eq 0 ] && ! $DRY_RUN; then
    log "✅ No broken or old DKMS modules found."
elif $DRY_RUN; then
    log "📝 Dry run complete. No changes made."
else
    log "✅ Cleanup complete. Removed $REMOVED broken or old DKMS module(s)."
    printf "%-40s\n" "🗑️ Removed modules:"
    printf "%s\n" "${REMOVED_LIST[@]}" | column
fi

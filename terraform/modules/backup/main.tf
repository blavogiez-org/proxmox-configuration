resource "proxmox_backup_job" "daily_backup" {
  id       = "daily-backup"
  schedule = "02:00"
  storage  = backup_storage
  all      = true
  mode     = "snapshot"
  compress = "zstd"

  prune_backups = {
    keep-last = "2"
  }
}

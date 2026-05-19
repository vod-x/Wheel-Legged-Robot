# setup-git.ps1 — 初始化本地 Git 提交规范配置
# 克隆仓库后执行一次：.\setup-git.ps1

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$template = "$root/.gitmessage" -replace '\\', '/'
$hooksDir = ".githooks"

# 1. 设置 commit 模板
git config commit.template $template
Write-Host "[OK] commit.template -> $template"

# 2. 通过 sh 复制 hook（保留可执行权限，Windows NTFS 下 PowerShell 复制会丢失权限）
$sh = Get-ChildItem "E:\Software\Git\bin\sh.exe","C:\Program Files\Git\bin\sh.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
if (-not $sh) { $sh = (Get-Command git | Split-Path | Split-Path) + "\bin\sh.exe" }
$rootUnix = $root -replace '\\','/' -replace '^([A-Z]):', { '/'+$args[0][0].ToString().ToLower() }
& $sh -c "cp '$rootUnix/.githooks/prepare-commit-msg' /tmp/_hook && chmod +x /tmp/_hook && cp /tmp/_hook '$rootUnix/.git/hooks/prepare-commit-msg'"
Write-Host "[OK] hook deployed with executable permission"

# 3. 确保 core.hooksPath 使用默认值（.git/hooks）
git config --unset core.hooksPath 2>$null
Write-Host "[OK] core.hooksPath -> .git/hooks (default)"

Write-Host "`n配置完成，现在可以使用 git commit 了。"

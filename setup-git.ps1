# setup-git.ps1 — 初始化本地 Git 提交规范配置
# 克隆仓库后执行一次：.\setup-git.ps1

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$template = "$root/.gitmessage" -replace '\\', '/'
$hooksDir = ".githooks"

# 1. 设置 commit 模板
git config commit.template $template
Write-Host "[OK] commit.template -> $template"

# 2. 将 .githooks/ 中的 hook 复制到 .git/hooks/（Git 原生目录，无需可执行权限）
$srcHooks = Join-Path $root ".githooks"
$dstHooks = Join-Path $root ".git\hooks"
Get-ChildItem $srcHooks | ForEach-Object {
    Copy-Item $_.FullName (Join-Path $dstHooks $_.Name) -Force
    Write-Host "[OK] hook copied: $($_.Name)"
}

# 3. 确保 core.hooksPath 使用默认值（.git/hooks）
git config --unset core.hooksPath 2>$null
Write-Host "[OK] core.hooksPath -> .git/hooks (default)"

Write-Host "`n配置完成，现在可以使用 git commit 了。"

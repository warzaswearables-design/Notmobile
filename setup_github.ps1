# Get credentials
$username = Read-Host "Enter your GitHub username"
$repoName = Read-Host "Enter a name for the new repository [default: warzatools-armada]"
if ([string]::IsNullOrEmpty($repoName)) { $repoName = "warzatools-armada" }

Write-Host "`nTo create and push to GitHub automatically, you need a Personal Access Token (Classic)." -ForegroundColor Yellow
Write-Host "You can generate one at: https://github.com/settings/tokens/new" -ForegroundColor Yellow
Write-Host "Make sure to check the 'repo' scope checkbox.`n" -ForegroundColor Yellow

$token = Read-Host "Paste your GitHub Personal Access Token (PAT)"
if ([string]::IsNullOrEmpty($token)) {
    Write-Error "Token cannot be empty."
    exit 1
}

# Create repository on GitHub via API
$body = @{
    name = $repoName
    private = $false
} | ConvertTo-Json

$headers = @{
    "Authorization" = "token $token"
    "Accept" = "application/vnd.github.v3+json"
}

Write-Host "`nCreating repository '$repoName' on GitHub..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "https://api.github.com/user/repos" -Method Post -Headers $headers -Body $body -ContentType "application/json"
    Write-Host "Repository created successfully! URL: $($response.html_url)" -ForegroundColor Green
} catch {
    Write-Host "Failed to create repository: $_" -ForegroundColor Red
    Write-Host "If the repository already exists, we will try to push to it anyway.`n" -ForegroundColor Yellow
}

# Set remote and push
$remoteUrl = "https://$username:$token@github.com/$username/$repoName.git"
Write-Host "Setting git remote and pushing to GitHub..." -ForegroundColor Cyan
git remote remove origin 2>$null
git remote add origin $remoteUrl

# Push and hide token output from stderr/stdout
git push -u origin main 2>&1 | ForEach-Object {
    $_ -replace $token, "********"
}

# Clean up remote to remove plain token from Git config
git remote remove origin
git remote add origin "https://github.com/$username/$repoName.git"

Write-Host "`nDone! Everything is set up and pushed to GitHub." -ForegroundColor Green
Write-Host "Go to: https://github.com/$username/$repoName/actions" -ForegroundColor Green
Write-Host "to watch your build run! Once it's finished, download the image under the latest run." -ForegroundColor Green

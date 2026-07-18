#!/usr/bin/env bash
set -e

echo -n "Enter your GitHub username: "
read -r username

echo -n "Enter a name for the new repository [default: warzatools-armada]: "
read -r repoName
if [ -z "$repoName" ]; then
    repoName="warzatools-armada"
fi

echo ""
echo "To create and push to GitHub automatically, you need a Personal Access Token (Classic)."
echo "You can generate one at: https://github.com/settings/tokens/new"
echo "Make sure to check the 'repo' scope checkbox."
echo ""
echo -n "Paste your GitHub Personal Access Token (PAT): "
read -r token

if [ -z "$token" ]; then
    echo "Error: Token cannot be empty." >&2
    exit 1
fi

echo ""
echo "Creating repository '$repoName' on GitHub..."

# Create repository via GitHub API using curl
response=$(curl -s -H "Authorization: token $token" \
                 -H "Accept: application/vnd.github.v3+json" \
                 -d "{\"name\":\"$repoName\",\"private\":false}" \
                 https://api.github.com/user/repos)

# Check if creation was successful
if echo "$response" | grep -q '"html_url"'; then
    html_url=$(echo "$response" | grep -o '"html_url": "[^"]*' | cut -d'"' -f4)
    echo "Repository created successfully! URL: $html_url"
else
    echo "Failed to create repository or repository already exists."
    echo "We will try to push to it anyway."
fi

echo ""
echo "Setting git remote and pushing to GitHub..."
git remote remove origin 2>/dev/null || true
git remote add origin "https://$username:$token@github.com/$username/$repoName.git"

# Push and filter out token from output
git push -u origin main 2>&1 | sed "s/$token/********/g"

# Clean up remote to remove plain token from Git config
git remote remove origin
git remote add origin "https://github.com/$username/$repoName.git"

echo ""
echo "Done! Everything is set up and pushed to GitHub."
echo "Go to: https://github.com/$username/$repoName/actions"
echo "to watch your build run! Once it's finished, download the image under the latest run."

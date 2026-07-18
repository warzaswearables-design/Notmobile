@echo off
set /p username="Enter your GitHub username: "
set /p reponame="Enter your GitHub repository name (e.g. warzatools-armada): "

echo.
echo Setting git remote to https://github.com/%username%/%reponame%.git...
git remote remove origin >nul 2>&1
git remote add origin https://github.com/%username%/%reponame%.git

echo.
echo Pushing to GitHub... A secure window will pop up. 
echo Please click "Sign in with your browser" to authenticate.
echo.

git push -u origin main

echo.
echo Done! If the push succeeded, go to your repository's "Actions" tab to watch the build.
pause

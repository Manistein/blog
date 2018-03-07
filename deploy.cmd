echo -e "\033[0;32mDeploying updates to Github...\033[0m"

%Build the project.%
hugo

%Add changes to git.%
git add -A

%Commit changes.%
git commit -m "publish"

%Push source and build repos.%
git push origin master
git subtree push --prefix=public git@github.com:Manistein/blog.git gh-pages
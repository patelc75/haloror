#!/bin/bash 
# adding a comment
# adding another comment

cd /home/web/devredmine/git_repos/haloror && git pull >> /dev/null 
cd /home/web/devredmine/git_repos/haloflex && git pull >> /dev/null

cd /home/web/devredmine && ruby script/runner "Repository.fetch_changesets" -e production >> /dev/null


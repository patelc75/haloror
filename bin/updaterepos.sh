#!/bin/bash
# testing log

# pull for each git repo for devredmine and redmine
cd /home/web/devredmine/git_repos/haloror && git pull >> /dev/null 
cd /home/web/devredmine/git_repos/haloflex && git pull >> /dev/null

# add changesets to each ticket
cd /home/web/devredmine && ruby script/runner "Repository.fetch_changesets" -e production >> /dev/null


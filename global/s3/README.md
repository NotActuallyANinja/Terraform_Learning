This is important if multiple people are working on a set of files.

This helps to prevent issues from happening due to:
- Manual error, if someone forgets to pull down the latest version before running terraform 
- Locking, git wouldnt prevent 2 team members from running terraform apply at the same time
- Secrets, this stops secrets from being stored in plain text. E.g. a db instance username and password would be stored in the state file in plain text

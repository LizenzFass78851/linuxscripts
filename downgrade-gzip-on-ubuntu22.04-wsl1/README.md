# Downgrade gzip on ubuntu 22.04 in WSL 1
this script ensures that gzip remains usable again under ubuntu 22.04 in wsl 1.

Without this script or without appropriate measures, the following error would currently (at the time of the first publication of this script) be displayed
````
bash: /usr/bin/gzip: cannot execute binary file: Exec format error
````

another solution would be to wait until ubuntu gzip is updated in the apt reposetories

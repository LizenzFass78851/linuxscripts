## Setup Ubuntu Active Directory
- Scripts based on the instructions from https://wiki.ubuntuusers.de/HowTo/Samba-AD-Server_unter_Ubuntu_20.04_installieren/

- copy the `env.example` to `.env` 
- Fill out the `.env` file and leave it in the same directory as the scripts.

- Run the `1-install_samba_ad.sh` on the desired DC1 and you're done.
  - If a second DC is desired, run the `2-join_additional_dc.sh` on the desired DC2 
  - then run the `3-post-setup_after_join_additional_dc.sh` on DC1 to complete the changes.

> [!NOTE]
> the `PTR_ADDRESS` env are the 3 of 4 parts of the ipv4 address backwards
> e.g. `192.168.178.0/24` = `178.168.192.in-addr.arpa`
# Fossil Fighters: Champions battle sim

A battle simulator for the game Fossil Fighters: Champions released on the Nintendo DS
in 2011.

## Useful scripts/commands

### deploy_and_run_server.sh
```sh
#!/bin/zsh
cd ~/ffc-battle-sim
scp server.x86_64 ffc-battle-sim-server:~
scp server.pck ffc-battle-sim-server:~
ssh ffc-battle-sim-server -t '~/run_server.sh'
```

### SSH into server
`ssh ffc-battle-sim-server`

### Run server remotely
1. Export project and export pck
2. run `deploy_and_run_server.sh` (make sure directory is in $PATH)

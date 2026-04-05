# Fossil Fighters battle sim

A battle simulator for the game Fossil Fighters released on the Nintendo DS
in 2008.

## Useful scripts/commands

### deploy_and_run_server.sh
```sh
#!/bin/zsh
cd ~/ffc-battle-sim
scp server.x86_64 ffc-battle-sim-server:~
ssh ffc-battle-sim-server -t '~/run_server.sh'
```

### Run server remotely
1. Export project
2. run `deploy_and_run_server.sh` (make sure parent directory is in $PATH)

### Copy game to pc
`scp ~/ffc-battle-sim/FF\ Battle\ Sim\ (Linux).x86_64 cachyos-pc:~/Desktop`

### Todo
- Add "fossil liscence" style card in player lobby scene
- Make icon select a modal popup
- Make buttons silve with screws in corner
- Add announcer 

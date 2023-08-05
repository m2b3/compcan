# Compute Canada / AllianceCan scripts

Usage:

```bash
 ./hook.sh rrg-mypi narval 16 8000M 2:00:00 1
```

Will spawn a job on `narval` under the account `rrg-mypi` with 16 CPUs, 8GB RAM, 1 GPU, for a maximum duration of 2 hours.

Omit the last argument if you don't need a GPU.


## Features

- jupyter job will not die on connection loss


## TODO

- [ ] Easy resume: connect to gateaway, find running jobs spawned through this script, and attach to one of them with SSH forwarding
- [ ] Per-project config:
    - [ ] `requirements.txt`
    - [ ] SLURM modules
- [ ] Rewrite this in OCaml or Rust, add job monitoring, GUI and/or TUI...

# Compute Canada / AllianceCan scripts

Usage:

```bash
 ./hook.sh narval 16 8000M 2:00:00 1
```

Will spawn a job on `narval` with 16 CPUs, 8GB RAM, 1 GPU, for a maximum duration of 2 hours.

Omit the last argument if you don't need a GPU.


## TODO

- [ ] Per-project config:
    - [ ] `requirements.txt`
    - [ ] SLURM modules
- [ ] Rewrite this in OCaml or Rust, add job monitoring, GUI and/or TUI...

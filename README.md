# HPC on FPGA

Hamming Product Code on FPGA.

> Designed for 16 bit width.

> Use 7,4 or 8,4 Hamming Code



## Requirement

use docker image at [.devcontainer/Dockerfile](.devcontainer/Dockerfile)

---

## Build or Run

```bash
./build --help
```

# Design and Feature

### Decoders

- [ ] First
- [ ] Second
- [ ] Third

### Designs

- [ ] IO components
- [ ] Encoding utilities
- [ ] Decoding utilities
- [ ] Test suit

### Features

- [ ] [Partial transmite](#partial-transmite)
- [ ] [Auto transmite additional check bits](#auto-transmite-additional-check-bits)
- [ ] [Parallel encoding/decoding]()
- [ ] [Transmite while encoding/decoding]()

## Partial Transmite

The partial transmite is done by implementing a special component which tells if the whole message is beign encoded no matter if extra check bits still in pending state.

## Auto transmite additional check bits

In this design, the extra check bits will not try to transmite before anything wrong has been detected by the receiver.

## Parallel codec

This is done by implementating mulitple same encoder running at same time.

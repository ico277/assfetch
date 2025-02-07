# assfetch
Yet another pfetch/neofetch clone written in x86_64 linux assembly.

# Build Instructions
## Build Dependencies
- nasm
- gcc
- make
- git (for cloning)

## Runtime Dependencies
- none

## Cloning
```bash
git clone --recursive https://github.com/ico277/assfetch
```
or
```bash
git clone https://github.com/ico277/assfetch
git submodule update --init --recursive
```

## Building
```bash
cd ./assfetch
make
```

## Installing
```bash
sudo make install
```

## Running
```bash
./assfetch.out
```
or after install
```bash
assfetch
```

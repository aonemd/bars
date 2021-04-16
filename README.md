<div align="center">
  <h1>
    bars
  </h1>

  A configurable bar written in Rust

  ![bars screenshot](https://user-images.githubusercontent.com/16504838/115078698-45839600-9f00-11eb-8bf4-8f3c93aa6f48.png)
</div>

## Features

- Configurable through a TOML config file
- Schedule each bar (block) in a separate thread with a time interval

## Building

- You need to have `Rust` installed with `Cargo`
- `make build` to build the project
- `sudo make install` to copy the binary to `/usr/local/bin`

## Usage

- Add your bar config in [bars.toml](https://github.com/aonemd/bars/blob/master/bars.toml)
- Run `bars -C /path/to/bars.toml &` to start

## Customization

- The icons in bars are from [FontAwesome](https://fontawesome.com).
    There's a package `ttf-font-awesome` in the AUR
- The colored bars are working in [dwm](https://dwm.suckless.org/) using the
    patch [status2d](https://dwm.suckless.org/patches/status2d/). There are
    always non-colored version of each bar

## TODOs

- [] Add a log for runtime errors
- [] Add support for Wayland

## License

See [LICENSE](https://github.com/aonemd/bars/blob/master/LICENSE).

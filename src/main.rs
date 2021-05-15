use std::collections::HashMap;

use structopt::StructOpt;

mod bar;
use bar::Runner;

#[derive(Debug, StructOpt)]
struct Cli {
    #[structopt(
        short = "C",
        long = "config",
        help = "Config file to load",
        parse(from_os_str),
        default_value = "bars.toml"
    )]
    config_file: std::path::PathBuf,
}

fn main() -> Result<(), std::io::Error> {
    let cli = Cli::from_args();
    let config = std::fs::read_to_string(cli.config_file)?;

    let bar_runner = Runner::from(config);

    let mut status: HashMap<usize, String> = HashMap::new();

    bar_runner.run(&mut status);

    Ok(())
}

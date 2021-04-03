use std::collections::HashMap;

use toml;

mod bar;
use bar::Runner;

fn main() -> Result<(), std::io::Error> {
    let bars_as_toml = std::fs::read_to_string("bars.toml")?;
    let  mut bar_runner: Runner = toml::from_str(&bars_as_toml).unwrap();

    let mut status: HashMap<usize, String> = HashMap::new();

    bar_runner.assign_default_attributes();
    bar_runner.run(&mut status);

    Ok(())
}

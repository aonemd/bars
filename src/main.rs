use std::collections::HashMap;

use toml;

mod bar;
use bar::Bars;

fn main() -> Result<(), std::io::Error> {
    let bars_as_toml = std::fs::read_to_string("bars.toml")?;
    let  mut bars: Bars = toml::from_str(&bars_as_toml).unwrap();

    let mut status: HashMap<usize, String> = HashMap::new();

    bars.assign_default_attributes();
    bars.run(&mut status);

    Ok(())
}

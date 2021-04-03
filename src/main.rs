use std::collections::HashMap;

mod bar;
use bar::Runner;

fn main() -> Result<(), std::io::Error> {
    let config = std::fs::read_to_string("bars.toml")?;

    let bar_runner = Runner::from(config);

    let mut status: HashMap<usize, String> = HashMap::new();

    bar_runner.run(&mut status);

    Ok(())
}

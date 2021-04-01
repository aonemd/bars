use std::process::Command;

use serde::Deserialize;
use toml;

#[derive(Debug, Deserialize)]
struct Bars {
    bar: Vec<Bar>,
}

#[derive(Debug, Deserialize)]
struct Bar {
    name: String,
    command: String,
    args: Option<Vec<String>>,
    interval: i32,
}

fn main() -> Result<(), std::io::Error> {
    let bars_as_toml = std::fs::read_to_string("bars.toml")?;
    let bars: Bars = toml::from_str(&bars_as_toml).unwrap();

    let out = Command::new("./bars/date_time_component.sh")
        .output()
        .expect("Error occurred");
    let time = String::from_utf8_lossy(&out.stdout);
    let status = format!("Time: {}", time);
    let _ = Command::new("xsetroot").arg("-name").arg(status).output();

    Ok(())
}

use std::process::Command;

use serde::Deserialize;
use toml;

#[derive(Debug, Deserialize)]
struct Bars {
    bar: Vec<Bar>,
}

impl Bars {
    fn assign_orders(&mut self) {
        for (index, bar) in self.bar.iter_mut().enumerate() {
            bar.order = (index + 1) as u32;
        }
    }
}

#[derive(Debug, Deserialize)]
struct Bar {
    name: String,
    command: String,
    args: Option<Vec<String>>,
    interval: i32,
    #[serde(skip)]
    order: u32,
}

impl Bar {
    fn run(&self) -> String {
        let out = Command::new(&self.command)
            .args(self.args.as_ref().unwrap_or(&vec![]))
            .output()
            .expect("Error occurred");
        let res = String::from_utf8_lossy(&out.stdout);
        return format!("{}: {}", self.name, res.trim());
    }
}

fn main() -> Result<(), std::io::Error> {
    let bars_as_toml = std::fs::read_to_string("bars.toml")?;
    let mut bars: Bars = toml::from_str(&bars_as_toml).unwrap();

    bars.assign_orders();

    let status: Vec<String> = bars.bar.into_iter().map(|b| b.run()).rev().collect();

    let status = status.join(" | ");
    let _ = Command::new("xsetroot").arg("-name").arg(status).output();

    Ok(())
}

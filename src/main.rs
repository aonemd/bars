use std::process::Command;
use std::sync::mpsc::{self, Sender, Receiver};

use serde::Deserialize;
use toml;

#[derive(Debug)]
struct BarChannel<T>(Sender<T>, Receiver<T>);
impl<T> Default for BarChannel<T> {
    fn default() -> Self {
        let (sender, receiver) = mpsc::channel();
        Self(sender, receiver)
    }
}

#[derive(Debug, Deserialize)]
struct Bars<T> {
    bar: Vec<Bar<T>>,

    #[serde(skip)]
    channel: BarChannel<T>,
}

impl<T> Bars<T> {
    pub fn assign_default_attributes(&mut self) {
        for (index, bar) in self.bar.iter_mut().enumerate() {
            bar.order = (index + 1) as u32;
            bar.sender = self.channel.0.clone();
        }
    }
}

#[derive(Debug, Deserialize)]
struct Bar<T> {
    name: String,
    command: String,
    args: Option<Vec<String>>,
    interval: i32,
    #[serde(skip, default = "default_channel_sender")]
    sender: Sender<T>,
    #[serde(skip)]
    order: u32,
}

fn default_channel_sender<T>() -> Sender<T> {
    let (_sender, _) = mpsc::channel();
    _sender
}

impl<T> Bar<T> {
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
    let mut bars: Bars<String> = toml::from_str(&bars_as_toml).unwrap();

    bars.assign_default_attributes();

    let status: Vec<String> = bars.bar.into_iter().map(|b| b.run()).rev().collect();

    let status = status.join(" | ");
    let _ = Command::new("xsetroot").arg("-name").arg(status).output();

    Ok(())
}

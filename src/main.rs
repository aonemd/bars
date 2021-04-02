use std::process::Command;
use std::time::Duration;
use std::thread;
use std::sync::mpsc::{sync_channel, SyncSender, Receiver};

use serde::Deserialize;
use toml;

#[derive(Debug)]
struct Message(u32, String);

#[derive(Debug)]
struct BarChannel<Message>(SyncSender<Message>, Receiver<Message>);
impl Default for BarChannel<Message> {
    fn default() -> Self {
        let (sender, receiver) = sync_channel::<Message>(0);
        Self(sender, receiver)
    }
}

#[derive(Debug, Deserialize)]
struct Bars {
    bar: Vec<Bar>,

    #[serde(skip)]
    channel: BarChannel<Message>,
}

impl Bars {
    pub fn assign_default_attributes(&mut self) {
        for (index, bar) in self.bar.iter_mut().enumerate() {
            bar.order = (index + 1) as u32;
            bar.sender = self.channel.0.clone();
        }
    }

    pub fn run(self) {
        for bar in self.bar.into_iter() {
            thread::spawn(move || {
                loop {
                    let res = bar.run();
                    bar.sender.send(res).unwrap();
                    thread::sleep(Duration::from_secs(bar.interval));
                }
            });
        }

        for received in &self.channel.1 {
            println!("Got: {}", received.1);
        }

    }
}

#[derive(Debug, Deserialize)]
struct Bar {
    name: String,
    command: String,
    args: Option<Vec<String>>,
    interval: u64,
    #[serde(skip, default = "default_channel_sender")]
    sender: SyncSender<Message>,
    #[serde(skip)]
    order: u32,
}

fn default_channel_sender() -> SyncSender<Message> {
    let (_sender, _) = sync_channel::<Message>(0);
    _sender
}

impl Bar {
    fn run(&self) -> Message {
        let out = Command::new(&self.command)
            .args(self.args.as_ref().unwrap_or(&vec![]))
            .output()
            .expect("Error occurred");
        let res = String::from_utf8_lossy(&out.stdout);
        let status_message = format!("{}: {}", self.name, res.trim());
        Message(self.order, status_message)
    }
}

fn main() -> Result<(), std::io::Error> {
    let bars_as_toml = std::fs::read_to_string("bars.toml")?;
    let  mut bars: Bars = toml::from_str(&bars_as_toml).unwrap();

    bars.assign_default_attributes();
    bars.run();

    // println!("{:#?}", bars);

    // let status: Vec<String> = bars.bar.into_iter().map(|b| b.run()).rev().collect();

    // let status = status.join(" | ");
    // let _ = Command::new("xsetroot").arg("-name").arg(status).output();

    Ok(())
}

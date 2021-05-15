use std::collections::HashMap;
use std::process::Command;
use std::sync::mpsc::{sync_channel, Receiver, SyncSender};
use std::thread;
use std::time::Duration;

use serde::Deserialize;
use toml;

#[derive(Debug)]
struct Message(usize, String);

impl PartialEq for Message {
    fn eq(&self, other: &Self) -> bool {
        self.0 == other.0
    }
}

#[derive(Debug)]
struct BarChannel<Message>(SyncSender<Message>, Receiver<Message>);
impl Default for BarChannel<Message> {
    fn default() -> Self {
        let (sender, receiver) = sync_channel::<Message>(0);
        Self(sender, receiver)
    }
}

#[derive(Debug, Deserialize)]
struct Bar {
    label: Option<String>,
    command: String,
    args: Option<Vec<String>>,
    interval: u64,
    #[serde(skip, default = "default_channel_sender")]
    sender: SyncSender<Message>,
    #[serde(skip)]
    order: usize,
}

#[derive(Debug, Deserialize)]
pub struct Runner {
    bar: Vec<Bar>,
    delim: Option<String>,

    #[serde(skip)]
    channel: BarChannel<Message>,
}

impl From<String> for Runner {
    fn from(config: String) -> Self {
        let mut new_runner: Runner = toml::from_str(&config).unwrap();

        new_runner.assign_default_attributes();

        new_runner
    }
}

impl Runner {
    pub fn run(self, status: &mut HashMap<usize, String>) {
        let delimeter = self.delim.unwrap_or(String::from(" "));

        for bar in self.bar.into_iter() {
            thread::spawn(move || loop {
                let res = bar.run();
                bar.sender.send(res).unwrap();
                thread::sleep(Duration::from_secs(bar.interval));
            });
        }

        for received in &self.channel.1 {
            status.insert(received.0, received.1);

            let mut col: Vec<_> = status.iter().collect();
            col.sort_by(|a, b| b.0.cmp(&a.0));
            let mut sorted_status: Vec<String> = col.iter().map(|e| (e.1).to_string()).collect();
            sorted_status.retain(|s| !s.is_empty());
            let status = sorted_status.join(&delimeter.to_string());

            let _ = Command::new("xsetroot").arg("-name").arg(status).output();
        }
    }

    fn assign_default_attributes(&mut self) {
        for (index, bar) in self.bar.iter_mut().enumerate() {
            bar.order = index;
            bar.sender = self.channel.0.clone();
        }
    }
}

impl Bar {
    fn run(&self) -> Message {
        let out = Command::new(&self.command)
            .args(self.args.as_ref().unwrap_or(&vec![]))
            .output()
            .expect("Error occurred");
        let res = String::from_utf8_lossy(&out.stdout);
        let status_message = format!(
            "{}{}",
            self.label.as_ref().unwrap_or(&String::from("")),
            res.trim()
        );
        Message(self.order, status_message)
    }
}

fn default_channel_sender() -> SyncSender<Message> {
    let (_sender, _) = sync_channel::<Message>(0);
    _sender
}

use std::process::Command;

fn main() {
    let out = Command::new("./bars/date_time_component.sh").output().expect("Error occurred");
    let time = String::from_utf8_lossy(&out.stdout);
    let status = format!("Time: {}", time);
    let _ = Command::new("xsetroot").arg("-name").arg(status).output();
}

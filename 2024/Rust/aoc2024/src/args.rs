use clap::{Parser, Subcommand};

#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
pub struct Cli {
    #[arg(short, long)]
    pub input_file: std::path::PathBuf,

    #[arg(short, long, default_value_t = 1)]
    pub part_number: u8,

    #[command(subcommand)]
    pub command: Commands,
}

#[derive(Subcommand, Debug)]
pub enum Commands {
    Day1,
    Day2,
    Day3,
    Day4,
}

mod args;
mod commands;

use args::Cli;
use clap::Parser;
use std::io;

fn main() -> Result<(), io::Error> {
    let args = Cli::parse();

    match args.command {
        args::Commands::Day1 => commands::day1::handle(args.input_file, args.part_number),
    }
}

mod args;
mod commands;

use args::Cli;
use clap::Parser;
use std::io;

fn main() -> Result<(), io::Error> {
    let args = Cli::parse();

    match args.command {
        args::Commands::Day1 => commands::day1::handle(args.input_file, args.part_number),
        args::Commands::Day2 => commands::day2::handle(args.input_file, args.part_number),
        args::Commands::Day3 => commands::day3::handle(args.input_file, args.part_number),
        args::Commands::Day4 => commands::day4::handle(args.input_file, args.part_number),
    }
}

use std::io;
use std::fs::read_to_string;
use regex::Regex;

pub fn handle(input_file: std::path::PathBuf, part_number: u8) -> Result<(), io::Error> {
    let contents = read_to_string(input_file)?;
    match part_number {
        1 => part1(&contents),
        _ => Err(io::Error::new(io::ErrorKind::InvalidInput, "Invalid part number")),
    }
}

fn part1(input: &str) -> Result<(), io::Error> {
    let regex = Regex::new(r"(?m)mul\((?<f>-?[0-9]{1,3}),(?<s>-?[0-9]{1,3})\)").unwrap();

    // result will be an iterator over tuples containing the start and end indices for each match in the string
    let result = regex.captures_iter(input);

    let mut sum: i32 = 0;
    for (_, [first, second]) in result.map(|c| c.extract()) {
        sum += first.parse::<i32>().unwrap() * second.parse::<i32>().unwrap();
    }

    println!("{}", sum);

    Ok(())
}

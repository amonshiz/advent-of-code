use regex::Regex;
use std::fs::read_to_string;
use std::io;

pub fn handle(input_file: std::path::PathBuf, part_number: u8) -> Result<(), io::Error> {
    let contents = read_to_string(input_file)?;
    match part_number {
        1 => part1(&contents),
        2 => part2(&contents),
        _ => Err(io::Error::new(
            io::ErrorKind::InvalidInput,
            "Invalid part number",
        )),
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

fn part2(input: &str) -> Result<(), io::Error> {
    let regex = Regex::new(r"(?m)mul\((?<mul>(?<f>-?[0-9]{1,3}),(?<s>-?[0-9]{1,3}))\)|(?<do>do\(\))|(?<dont>don't\(\))").unwrap();

    // result will be an iterator over tuples containing the start and end indices for each match in the string
    let result = regex.captures_iter(input);

    let mut sum: i32 = 0;
    let mut is_enabled: bool = true;
    for mat in result {
        if let Some(_mul) = mat.name("mul") {
            if !is_enabled {
                continue;
            }

            sum += mat.name("f").unwrap().as_str().parse::<i32>().unwrap()
                * mat.name("s").unwrap().as_str().parse::<i32>().unwrap();
        }
        if let Some(do_match) = mat.name("do") {
            if do_match.as_str() == "do()" {
                is_enabled = true;
            }
        }
        if let Some(dont_match) = mat.name("dont") {
            if dont_match.as_str() == "don't()" {
                is_enabled = false;
            }
        }
    }

    println!("{}", sum);

    Ok(())
}

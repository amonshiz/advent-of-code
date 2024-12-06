use nom::{
    character::complete::{digit1, newline, space1},
    multi::separated_list1,
    combinator::map_res,
    IResult,
};
use std::{fs::read_to_string, iter::zip};
use std::io;

#[derive(Debug, PartialEq)]
pub struct Report {
    pub levels: Vec<i32>,
}

fn str_to_u32(input: &str) -> IResult<&str, i32> {
    map_res(digit1, str::parse)(input)
}

fn parse_report(input: &str) -> IResult<&str, Report> {
    let (input, levels) = separated_list1(space1, str_to_u32)(input)?;
    Ok((input, Report { levels }))
}

fn parse_reports(input: &str) -> IResult<&str, Vec<Report>> {
    let (input, reports) = separated_list1(newline, parse_report)(input)?;
    Ok((input, reports))
}

pub fn handle(input_file: std::path::PathBuf, part_number: u8) -> Result<(), io::Error> {
    let contents = read_to_string(input_file)?;
    match part_number {
        1 => part_1(&contents),
        _ => Err(io::Error::new(io::ErrorKind::InvalidInput, "Invalid part number")),
    }
}

trait LevelsValidation {
    fn levels_are_valid(&self) -> bool;
}

impl LevelsValidation for Report {
    fn levels_are_valid(&self) -> bool {
        if self.levels.len() < 2 {
            return true;
        }

        let first = self.levels[0];
        let second = self.levels[1];

        let to_check: &[i32] = if first < second {
            &self.levels[..]
        } else {
            let mut reversed = self.levels.clone();
            reversed.reverse();
            Box::leak(reversed.into_boxed_slice())
        };

        for (current, next) in zip(to_check, &to_check[1..]) {
            let diff = next - current;
            if diff < 1 || diff > 3 {
                return false;
            }
        }

        true
    }
}

pub fn part_1(input: &str) -> Result<(), io::Error> {
    let (_, reports) = parse_reports(input).unwrap();
    let valid_count = reports.iter().filter(|r| r.levels_are_valid()).count();
    println!("{}", valid_count);
    Ok(())
}

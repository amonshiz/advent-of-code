use nom::{
    character::complete::{digit1, space1, newline},
    multi::separated_list1,
    sequence::separated_pair,
    IResult,
};
use std::fs::read_to_string;
use std::io;

#[derive(Debug, PartialEq)]
pub struct IDPair {
    pub first: u32,
    pub second: u32,
}

fn parse_id_pair(input: &str) -> IResult<&str, IDPair> {
    let (input, (first, second)) = separated_pair(digit1, space1, digit1)(input)?;
    Ok((input, IDPair { first: first.parse().unwrap(), second: second.parse().unwrap() }))
}

fn parse_id_pairs(input: &str) -> IResult<&str, Vec<IDPair>> {
    separated_list1(newline, parse_id_pair)(input)
}

pub fn handle(input_file: std::path::PathBuf, part_number: u8) -> Result<(), io::Error> {
    match part_number {
        1 => part_1(input_file),
        _ => Err(io::Error::new(io::ErrorKind::InvalidInput, "Invalid part number")),
    }
}

pub fn part_1(input_file: std::path::PathBuf) -> Result<(), io::Error> {
    let contents = read_to_string(input_file)?;

    let id_pairs = parse_id_pairs(&contents);
    let mut left_ids: Vec<u32> = Vec::new();
    let mut right_ids: Vec<u32> = Vec::new();
    for id_pair in id_pairs.unwrap().1 {
        left_ids.push(id_pair.first);
        right_ids.push(id_pair.second);
    }
    left_ids.sort();
    right_ids.sort();
    let mut diff: u32 = 0;
    for i in 0..left_ids.len() {
        diff += (left_ids[i] as i32 - right_ids[i] as i32).abs() as u32;
    }
    println!("{}", diff);
    Ok(())
}

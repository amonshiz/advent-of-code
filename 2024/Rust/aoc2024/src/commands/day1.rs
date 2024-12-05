use nom::{
    character::complete::{digit1, newline, space1},
    multi::separated_list1,
    sequence::separated_pair,
    IResult,
};
use std::collections::HashMap;
use std::fs::read_to_string;
use std::io;

#[derive(Debug, PartialEq)]
pub struct IDPair {
    pub first: u32,
    pub second: u32,
}

fn parse_id_pair(input: &str) -> IResult<&str, IDPair> {
    let (input, (first, second)) = separated_pair(digit1, space1, digit1)(input)?;
    Ok((
        input,
        IDPair {
            first: first.parse().unwrap(),
            second: second.parse().unwrap(),
        },
    ))
}

fn parse_id_pairs(input: &str) -> IResult<&str, Vec<IDPair>> {
    separated_list1(newline, parse_id_pair)(input)
}

pub fn handle(input_file: std::path::PathBuf, part_number: u8) -> Result<(), io::Error> {
    let contents = read_to_string(input_file)?;

    let id_pairs = parse_id_pairs(&contents);
    let mut left_ids: Vec<u32> = Vec::new();
    let mut right_ids: Vec<u32> = Vec::new();
    for id_pair in id_pairs.unwrap().1 {
        left_ids.push(id_pair.first);
        right_ids.push(id_pair.second);
    }

    match part_number {
        1 => part_1(&mut left_ids, &mut right_ids),
        2 => part_2(left_ids, right_ids),
        _ => Err(io::Error::new(
            io::ErrorKind::InvalidInput,
            "Invalid part number",
        )),
    }
}

pub fn part_1(left_ids: &mut Vec<u32>, right_ids: &mut Vec<u32>) -> Result<(), io::Error> {
    left_ids.sort();
    right_ids.sort();
    let mut diff: u32 = 0;
    for i in 0..left_ids.len() {
        diff += (left_ids[i] as i32 - right_ids[i] as i32).unsigned_abs();
    }
    println!("{}", diff);
    Ok(())
}

pub fn part_2(left_ids: Vec<u32>, right_ids: Vec<u32>) -> Result<(), io::Error> {
    let mut right_counts: HashMap<u32, u32> = HashMap::new();
    for right_id in right_ids {
        *right_counts.entry(right_id).or_insert(0) += 1;
    }

    let mut count_result: u32 = 0;
    for left_id in left_ids {
        if right_counts.contains_key(&left_id) {
            count_result += left_id * right_counts[&left_id];
        }
    }
    println!("{}", count_result);
    Ok(())
}

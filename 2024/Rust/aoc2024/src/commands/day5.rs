// use std::collections:HashMap;
use nom::{
    character::complete::{digit1, newline},
    bytes::complete::tag,
    combinator::map_res,
    multi::separated_list1,
    sequence::separated_pair,
    IResult,
};
use std::io;
use std::fs::read_to_string;
use std::collections::{HashMap, HashSet};

#[derive(Debug, PartialEq)]
pub struct Rule {
    pub first: u32,
    pub second: u32,
}

#[derive(Debug, PartialEq, Clone)]
pub struct Update {
    pub pages: Vec<u32>,
}

fn str_to_u32(input: &str) -> IResult<&str, u32> {
    map_res(digit1, str::parse)(input)
}

fn parse_rule(input: &str) -> IResult<&str, Rule> {
    let (input, (first, second)) = separated_pair(str_to_u32, tag("|"), str_to_u32)(input)?;
    Ok((input, Rule { first, second }))
}

fn parse_rules(input: &str) -> IResult<&str, Vec<Rule>> {
    let (input, rules) = separated_list1(newline, parse_rule)(input)?;
    Ok((input, rules))
}

fn parse_update(input: &str) -> IResult<&str, Update> {
    let (input, pages) = separated_list1(tag(","), str_to_u32)(input)?;
    Ok((input, Update { pages }))
}

fn parse_updates(input: &str) -> IResult<&str, Vec<Update>> {
    let (input, updates) = separated_list1(newline, parse_update)(input)?;
    Ok((input, updates))
}

fn parse_input(input: &str) -> IResult<&str, (Vec<Rule>, Vec<Update>)> {
    let (input, (rules, updates)) = separated_pair(parse_rules, tag("\n\n"), parse_updates)(input)?;
    Ok((input, (rules, updates)))
}

pub fn handle(input_file: std::path::PathBuf, part_number: u8) -> Result<(), io::Error> {
    println!("Day 5");
    match part_number {
        1 => part1(input_file),
        _ => Err(io::Error::new(io::ErrorKind::InvalidInput, "Invalid part number")),
    }
}

fn part1(input_file: std::path::PathBuf) -> Result<(), io::Error> {
    let contents = read_to_string(input_file)?;
    let (_, (rules, updates)) = parse_input(&contents).unwrap();
    // println!("{:?}", rules);
    // println!("{:?}", updates);

    let mut rule_map: HashMap<u32, HashSet<u32>> = HashMap::new();
    for rule in rules {
        rule_map.entry(rule.first).or_insert(HashSet::new()).insert(rule.second);
    }

    let mut middle_value_sum = 0;
    'update_loop: for update in updates {
        let mut seen_pages: HashSet<u32> = HashSet::new();
        let update_copy = update.clone();
        for page in update_copy.pages {
            if let Some(required_pages_after) = rule_map.get(&page) {
                if !required_pages_after.is_disjoint(&seen_pages) {
                    println!("Invalid update: {:?}", update);
                    continue 'update_loop;
                }
            }
            seen_pages.insert(page);
        }
        middle_value_sum += update.pages[update.pages.len() / 2];
    }
    println!("Middle value sum: {}", middle_value_sum);
    Ok(())
}

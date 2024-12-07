// use std::collections:HashMap;
use nom::{
    bytes::complete::tag,
    character::complete::{digit1, newline},
    combinator::map_res,
    multi::separated_list1,
    sequence::separated_pair,
    IResult,
};
use std::cmp::Ordering;
use std::collections::{HashMap, HashSet};
use std::fs::read_to_string;
use std::io;

#[derive(Debug, PartialEq)]
pub struct Rule {
    pub first: u32,
    pub second: u32,
}

#[derive(Debug, PartialEq, Clone)]
pub struct Update {
    pub pages: Vec<u32>,
}

impl Update {
    fn is_valid(&self, rules: &HashMap<u32, HashSet<u32>>) -> bool {
        let mut seen_pages: HashSet<u32> = HashSet::new();
        for page in self.pages.clone() {
            if let Some(required_pages_after) = rules.get(&page) {
                if !required_pages_after.is_disjoint(&seen_pages) {
                    return false;
                }
            }
            seen_pages.insert(page);
        }
        true
    }
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
        2 => part2(input_file),
        _ => Err(io::Error::new(
            io::ErrorKind::InvalidInput,
            "Invalid part number",
        )),
    }
}

fn part1(input_file: std::path::PathBuf) -> Result<(), io::Error> {
    let contents = read_to_string(input_file)?;
    let (_, (rules, updates)) = parse_input(&contents).unwrap();
    // println!("{:?}", rules);
    // println!("{:?}", updates);

    let mut rule_map: HashMap<u32, HashSet<u32>> = HashMap::new();
    for rule in rules {
        rule_map.entry(rule.first).or_default().insert(rule.second);
    }

    let mut middle_value_sum = 0;
    'update_loop: for update in updates {
        if !update.is_valid(&rule_map) {
            println!("Invalid update: {:?}", update);
            continue 'update_loop;
        }

        middle_value_sum += update.pages[update.pages.len() / 2];
    }
    println!("Middle value sum: {}", middle_value_sum);
    Ok(())
}

fn part2(input_file: std::path::PathBuf) -> Result<(), io::Error> {
    let contents = read_to_string(input_file)?;
    let (_, (rules, updates)) = parse_input(&contents).unwrap();

    let mut rule_map: HashMap<u32, HashSet<u32>> = HashMap::new();
    for rule in rules {
        rule_map.entry(rule.first).or_default().insert(rule.second);
    }

    let invalid_updates = updates.iter().filter(|update| !update.is_valid(&rule_map));
    let mut corrected_updates: Vec<Update> = Vec::new();
    for invalid_update in invalid_updates {
        let mut other_pages = invalid_update.pages.clone();
        other_pages.sort_by(|a, b| {
            if let Some(first_requirements) = rule_map.get(a) {
                // If the second number is required to come after the first, then we need to indicate that the first is "less" that the second.
                if first_requirements.contains(b) {
                    return Ordering::Less;
                }
            }
            if let Some(second_requirements) = rule_map.get(b) {
                // If the first number is required to come after the second, then we need to indicate that the first is "greater" than the second.
                if second_requirements.contains(a) {
                    return Ordering::Greater;
                }
            }
            // If neither number requires the other to come first, then we can sort them naturally.
            a.cmp(b)
        });
        let potential_update = Update { pages: other_pages };
        if potential_update.is_valid(&rule_map) {
            corrected_updates.push(potential_update);
        }
    }

    let middle_value_sum: u32 = corrected_updates
        .iter()
        .map(|update| update.pages[update.pages.len() / 2])
        .sum();
    println!("Middle value sum: {}", middle_value_sum);
    Ok(())
}

use std::io;
use std::fs::read_to_string;
use nom::{
    bytes::complete::tag,
    character::complete::{digit1, space1, newline},
    multi::separated_list1,
    sequence::separated_pair,
    combinator::map_res,
    IResult,
};

pub fn handle(input_file: std::path::PathBuf, part_number: u8) -> Result<(), io::Error> {
    let contents = read_to_string(input_file)?;
    match part_number {
        1 => part_1(&contents),
        2 => part_2(&contents),
        _ => Err(io::Error::new(io::ErrorKind::InvalidInput, "Invalid part number")),
    }
}

enum Operation {
    Addition,
    Multiplication,
    Concatenation,
}

impl Operation {
    fn apply(&self, lhs: i64, rhs: i64) -> i64 {
        match self {
            Operation::Addition => lhs + rhs,
            Operation::Multiplication => lhs * rhs,
            Operation::Concatenation => (lhs.to_string() + &rhs.to_string()).parse::<i64>().unwrap(),
        }
    }
}

#[derive(Debug, PartialEq)]
struct Equation {
    test_value: i64,
    factors: Vec<i64>,
}

impl Equation {
    fn is_valid(&self, operations: &[Operation]) -> bool {
        fn check_factors(factors: &Vec<i64>, test_value: i64, operations: &[Operation]) -> bool {
            if factors.len() == 0 {
                return false;
            }

            if factors.len() < 2 {
                return factors[0] == test_value;
            }

            // check combining the first two factors via addition
            // check combining the first two factors via multiplication
            let mut tail = factors.clone();
            let head = tail.drain(0..2).collect::<Vec<i64>>();
            for operation in operations {
                let mut updated_factors = [operation.apply(head[0], head[1])].to_vec();
                updated_factors.extend(&mut tail.iter().cloned());
                if check_factors(&updated_factors, test_value, operations) {
                    return true;
                }
            }
            false
        }
        check_factors(&self.factors, self.test_value, operations)
    }
}

fn str_to_i64(input: &str) -> IResult<&str, i64> {
    map_res(digit1, str::parse::<i64>)(input)
}

fn parse_factors(input: &str) -> IResult<&str, Vec<i64>> {
    separated_list1(space1, str_to_i64)(input)
}

fn parse_equation(input: &str) -> IResult<&str, Equation> {
    let (input, (test_value, factors)) = separated_pair(str_to_i64, tag(": "), parse_factors)(input)?;
    Ok((input, Equation { test_value, factors }))
}

fn parse_equations(input: &str) -> Vec<Equation> {
    separated_list1(newline, parse_equation)(input).unwrap().1
}

fn part_1(contents: &str) -> Result<(), io::Error> {
    let equations = parse_equations(contents);
    let valid_equations = equations.iter().filter(|e| e.is_valid(&[Operation::Addition, Operation::Multiplication])).collect::<Vec<&Equation>>();
    println!("{}", valid_equations.len());
    let sum_of_valid_equations = valid_equations.iter().fold(0, |acc, e| acc + e.test_value);
    println!("{:?}", sum_of_valid_equations);
    Ok(())
}

fn part_2(contents: &str) -> Result<(), io::Error> {
    let equations = parse_equations(contents);
    let valid_equations = equations.iter().filter(|e| e.is_valid(&[Operation::Addition, Operation::Multiplication, Operation::Concatenation])).collect::<Vec<&Equation>>();
    println!("{}", valid_equations.len());
    let sum_of_valid_equations = valid_equations.iter().fold(0, |acc, e| acc + e.test_value);
    println!("{:?}", sum_of_valid_equations);
    Ok(())
}

use std::fs;
use std::io;
use enum_iterator::{all, Sequence};

pub fn handle(input_file: std::path::PathBuf, part_number: u8) -> Result<(), io::Error> {
    let contents = fs::read_to_string(input_file)?;

    match part_number {
        1 => part1(&contents),
        2 => part2(&contents),
        _ => Err(io::Error::new(io::ErrorKind::InvalidInput, "Invalid part number")),
    }
}

#[derive(Debug, Sequence, Copy, Clone)]
enum Direction {
    Up,
    Down,
    Left,
    Right,
    LeftUp,
    LeftDown,
    RightUp,
    RightDown,
}

impl Direction {
    fn indices_from_line_and_character(&self, line: usize, character: usize, length: usize, max_line_count: usize, max_character_count: usize) -> Vec<(usize, usize)> {
        let range = 0..length;
        match self {
            Direction::Up => {
                if line < length - 1 {
                    return vec![];
                }
                range.map(|i| (line - i, character)).collect()
            },
            Direction::Down => {
                if line + length - 1 >= max_line_count {
                    return vec![];
                }
                range.map(|i| (line + i, character)).collect()
            },
            Direction::Left => {
                if character < length - 1 {
                    return vec![];
                }
                range.map(|i| (line, character - i)).collect()
            },
            Direction::Right => {
                if character + length - 1 >= max_character_count {
                    return vec![];
                }
                range.map(|i| (line, character + i)).collect()
            },
            Direction::LeftUp => {
                if line < length - 1 || character < length - 1 {
                    return vec![];
                }
                range.map(|i| (line - i, character - i)).collect()
            },
            Direction::LeftDown => {
                if line + length - 1 >= max_line_count || character < length - 1 {
                    return vec![];
                }
                range.map(|i| (line + i, character - i)).collect()
            },
            Direction::RightUp => {
                if line < length - 1 || character + length - 1 >= max_character_count {
                    return vec![];
                }
                range.map(|i| (line - i, character + i)).collect()
            },
            Direction::RightDown => {
                if line + length - 1 >= max_line_count || character + length - 1 >= max_character_count {
                    return vec![];
                }
                range.map(|i| (line + i, character + i)).collect()
            },
        }
    }
}

fn collect_characters_beginning_at_line_and_character(lines: &Vec<Vec<char>>, line: usize, character: usize, length: usize, direction: &Direction) -> Vec<char> {
    let mut characters = vec![];
    let indices = direction.indices_from_line_and_character(line, character, length, lines.len(), lines[line].len());
    for (next_line_index, next_character_index) in indices {
        characters.push(lines[next_line_index][next_character_index]);
    }
    characters
}

fn count_of_string_beginning_at_line_and_character(input: &str, lines: &Vec<Vec<char>>, line: usize, character: usize, length: usize) -> usize {
    let mut count = 0;
    for direction in all::<Direction>() {
        let characters = collect_characters_beginning_at_line_and_character(lines, line, character, length, &direction);
        if input.eq(&characters.iter().collect::<String>()) {
            count += 1;
        }
    }
    return count;
}

fn part1(contents: &str) -> Result<(), io::Error> {
    // split the contents into lines
    // split each line into characters
    let lines: Vec<Vec<char>> = contents
        .lines()
        .map(|line| line.chars().collect())
        .collect();

    let mut count = 0;
    for line in 0..lines.len() {
        for character in 0..lines[line].len() {
            count += count_of_string_beginning_at_line_and_character("XMAS", &lines, line, character, 4);
        }
    }

    println!("{}", count);
    Ok(())
}

fn x_mases_beginning_at_line_and_character(lines: &Vec<Vec<char>>, line: usize, character: usize) -> usize {
    if line < 1 || line == lines.len() - 1 || character < 1 || character == lines[line].len() - 1 {
        return 0;
    }

    let left_up = collect_characters_beginning_at_line_and_character(lines, line - 1, character - 1, 3, &Direction::RightDown);
    let left_down = collect_characters_beginning_at_line_and_character(lines, line + 1, character - 1, 3, &Direction::RightUp);
    let right_up = collect_characters_beginning_at_line_and_character(lines, line - 1, character + 1, 3, &Direction::LeftDown);
    let right_down = collect_characters_beginning_at_line_and_character(lines, line + 1, character + 1, 3, &Direction::LeftUp);
    let mut count = 0;
    let forward_mas = vec!['M', 'A', 'S'];
    let reverse_mas = forward_mas.iter().rev().cloned().collect::<Vec<char>>();
    if [left_up, left_down, right_up, right_down].iter().all(|direction| direction.eq(&forward_mas) || direction.eq(&reverse_mas)) {
        count += 1;
    }
    return count;
}

fn part2(contents: &str) -> Result<(), io::Error> {
    let lines: Vec<Vec<char>> = contents
        .lines()
        .map(|line| line.chars().collect())
        .collect();

    let mut count = 0;
    for line in 0..lines.len() {
        for character in 0..lines[line].len() {
            count += x_mases_beginning_at_line_and_character(&lines, line, character);
        }
    }
    println!("{}", count);
    Ok(())
}

use std::collections::HashMap;
use std::collections::HashSet;
use std::fs::read_to_string;
use std::io;
use std::iter::Extend;

pub fn handle(input_file: std::path::PathBuf, part_number: u8) -> Result<(), io::Error> {
    let contents = read_to_string(input_file)?;
    match part_number {
        1 => part_1(&contents),
        2 => part_2(&contents),
        _ => Err(io::Error::new(
            io::ErrorKind::InvalidInput,
            "Invalid part number",
        )),
    }
}

#[derive(Clone, Hash, Copy, Debug, Eq, PartialEq)]
struct Position {
    x: i32,
    y: i32,
}

impl Position {
    fn next(&self, direction: &GuardDirection) -> Position {
        match direction {
            GuardDirection::Up => Position {
                x: self.x,
                y: self.y - 1,
            },
            GuardDirection::Down => Position {
                x: self.x,
                y: self.y + 1,
            },
            GuardDirection::Left => Position {
                x: self.x - 1,
                y: self.y,
            },
            GuardDirection::Right => Position {
                x: self.x + 1,
                y: self.y,
            },
        }
    }
}

#[derive(PartialEq, Eq, Hash, Clone)]
enum GuardDirection {
    Up,
    Down,
    Left,
    Right,
}

impl GuardDirection {
    fn next(&self) -> GuardDirection {
        match self {
            GuardDirection::Up => GuardDirection::Right,
            GuardDirection::Right => GuardDirection::Down,
            GuardDirection::Down => GuardDirection::Left,
            GuardDirection::Left => GuardDirection::Up,
        }
    }
}

enum MovementEnd {
    OnBoard(Vec<Position>),
    OffBoard(Vec<Position>),
}

struct Map {
    locations: Vec<Vec<char>>,
    guard_start_position: Position,
    guard_position: Option<Position>,
    direction: GuardDirection,
}

impl Map {
    fn new(contents: &str) -> Map {
        let locations = contents
            .split("\n")
            .map(|line| line.chars().collect())
            .collect();
        Map::new_from_locations(locations)
    }

    fn new_from_locations(locations: Vec<Vec<char>>) -> Map {
        // println!("{:?}", locations);
        let filtered_locations: Vec<Vec<char>> = locations
            .into_iter()
            .filter(|line| !line.is_empty())
            .collect();
        for (y, line) in filtered_locations.iter().enumerate() {
            if let Some(x) = line.iter().position(|&c| c == '^') {
                let guard_start_position = Position {
                    x: x as i32,
                    y: y as i32,
                };
                return Map {
                    locations: filtered_locations,
                    guard_start_position,
                    guard_position: Some(guard_start_position),
                    direction: GuardDirection::Up,
                };
            }
        }
        panic!("No guard start position found");
    }

    fn updated_with_obstruction(original: &Map, position: Position) -> Option<Map> {
        if original.guard_start_position == position {
            return None;
        }

        let mut new_locations = original.locations.clone();
        new_locations[position.y as usize][position.x as usize] = '#';
        Some(Map::new_from_locations(new_locations))
    }
}

impl Map {
    fn character_at(&self, position: &Position) -> char {
        // println!("{:?}", position);
        self.locations[position.y as usize][position.x as usize]
    }

    fn is_on_board(&self, position: &Position) -> bool {
        // println!("pos {:?} bounds {:?} {:?}", position, self.locations[0].len(), self.locations.len());
        position.x >= 0
            && position.x < self.locations[0].len() as i32
            && position.y >= 0
            && position.y < self.locations.len() as i32
    }

    fn guard_positions(&self, direction: &GuardDirection) -> MovementEnd {
        let mut positions: Vec<Position> = Vec::new();

        match &self.guard_position {
            Some(guard_position) => {
                let mut next_position = *guard_position;
                while self.is_on_board(&next_position) && self.character_at(&next_position) != '#' {
                    positions.push(next_position);
                    next_position = next_position.next(direction);
                }
                if self.is_on_board(&next_position) {
                    MovementEnd::OnBoard(positions)
                } else {
                    MovementEnd::OffBoard(positions)
                }
            }
            None => panic!("Guard position not found"),
        }
    }

    fn move_guard(&mut self) -> MovementEnd {
        let movement = self.guard_positions(&self.direction);
        match &movement {
            MovementEnd::OnBoard(positions) => {
                self.guard_position = Some(*positions.last().unwrap());
                self.direction = self.direction.next();
            }
            MovementEnd::OffBoard(_) => {
                self.guard_position = None;
            }
        }
        movement
    }

    fn path_contains_loop(&mut self) -> bool {
        let mut directions_at_obstructions: HashMap<Position, HashSet<GuardDirection>> =
            HashMap::new();
        'check_loop: loop {
            let movement = self.move_guard();
            match movement {
                MovementEnd::OnBoard(positions) => {
                    if let Some(last_position) = positions.last() {
                        let next_position = last_position.next(&self.direction);
                        let directions = directions_at_obstructions
                            .entry(next_position)
                            .or_default();
                        if directions.contains(&self.direction) {
                            return true;
                        }
                        directions.insert(self.direction.clone());
                    }
                }
                MovementEnd::OffBoard(_) => {
                    break 'check_loop;
                }
            }
        }
        false
    }
}

fn part_1(contents: &str) -> Result<(), io::Error> {
    let mut map = Map::new(contents);
    let mut visited_positions: HashSet<Position> = HashSet::new();
    loop {
        let movement = map.move_guard();
        match movement {
            MovementEnd::OnBoard(positions) => {
                visited_positions.extend(positions.clone());
                // println!("on board {:?}", positions);
            }
            MovementEnd::OffBoard(positions) => {
                visited_positions.extend(positions.clone());
                // println!("off board {:?}", positions);
                break;
            }
        }
    }
    println!("{:?}", visited_positions.len());
    Ok(())
}

fn part_2(contents: &str) -> Result<(), io::Error> {
    let mut map = Map::new(contents);
    let mut visited_positions: HashSet<Position> = HashSet::new();
    loop {
        let movement = map.move_guard();
        match movement {
            MovementEnd::OnBoard(positions) => {
                visited_positions.extend(positions.clone());
                // println!("on board {:?}", positions);
            }
            MovementEnd::OffBoard(positions) => {
                visited_positions.extend(positions.clone());
                // println!("off board {:?}", positions);
                break;
            }
        }
    }

    let mut count_of_obstructions = 0;
    for position in visited_positions {
        if let Some(mut updated_map) = Map::updated_with_obstruction(&map, position) {
            if updated_map.path_contains_loop() {
                count_of_obstructions += 1;
            }
        }
    }
    println!("{:?}", count_of_obstructions);
    Ok(())
}

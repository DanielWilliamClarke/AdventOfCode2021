use crate::common::Solution;

pub struct Day07;

impl Solution<String, i32> for Day07 {
    fn pt_1(&self, input: &[String]) -> i32 {
        self.optimize(
            &self.parse(input),
        |index, position| index.abs_diff(*position) as i32)
    }

    fn pt_2(&self, input: &[String]) -> i32 {
        self.optimize(
            &self.parse(input),
        |index, position| {
                let n = index.abs_diff(*position) as i32;
                n * (n + 1) / 2 // Triangular number yo
            })
    }
}

impl Day07 {
    pub fn new() -> Day07 {
        Day07 {}
    }

    fn parse(&self, input: &[String]) -> Vec<i32> {
        input
            .first()
            .unwrap()
            .split(',')
            .map(|number| number.parse().unwrap())
            .collect()
    }

    fn optimize (&self, input: &[i32], cost_predicate: fn(&i32, &i32) -> i32) -> i32 {
        let max = input.iter().max().unwrap();
        let min = input.iter().min().unwrap();

        (*min..*max)
            .map(|index| {
                input
                    .iter()
                    .map(|position| cost_predicate(&index, position))
                    .sum::<i32>()
            })
            .min()
            .unwrap()
    }
}

#[cfg(test)]
mod tests {
    use crate::{common::Solution, day_07::solution::Day07};

    #[test]
    fn solution_is_correct() {
        let day = Day07::new();
        let input = day.read_input("src/day_07/input.txt");
        vec![
            (day.pt_1(&input), 347449),
            (day.pt_2(&input), 98039527),
        ]
        .iter()
        .for_each(|test| assert_eq!(test.0, test.1))
    }
}

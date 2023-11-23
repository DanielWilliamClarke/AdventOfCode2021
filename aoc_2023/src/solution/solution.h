#ifndef SOLUTION_H
#define SOLUTION_H
#pragma once

#include <string>
#include <vector>
#include <iostream>
#include <iomanip>
#include <cxxabi.h>

#include "printer.h"

template <typename Input, typename Output1, typename Output2 = Output1>
class Solution : public Printer {
public: 
    virtual std::vector<Input> readInput () const = 0;
    virtual Output1 part1 (std::vector<Input> input) const = 0;
    virtual Output2 part2 (std::vector<Input> input) const = 0;
    void print() const override;
};

template <typename Input, typename Output1, typename Output2>
void Solution<Input, Output1, Output2>::print() const {
    // Magic typename method.. 
    int status;
    auto solutionName = abi::__cxa_demangle(typeid(*this).name(), 0, 0, &status);
    auto line = "🎄🎄🎄🎄🎄🎄🎄🎄🎄🎄🎄🎄🎄🎄🎄🎄🎄🎄🎄🎄🎄🎄🎄";
    auto input = this->readInput();

    std::cout << line << '\n';
    std::cout << "🎅 Running Advent Of Code 2022: { " << solutionName <<  " } 🎅" << '\n';
    std::cout << "Part 1:" << std::setw(2) << this->part1(input) << '\n';
    std::cout << "Part 2:" << std::setw(2) << this->part2(input) << '\n';
    std::cout << line << '\n';
}

#endif // SOLUTION_H
#include "day_15.h"

#include <ranges>
#include <numeric>
#include <algorithm>
#include <optional>

#include "main/solution/string_utils.h"

Box::Box()
{
    this->lenses.reserve(10);
}

void Box::removeLens(const std::string& label)
{
    auto [start, end] = std::ranges::remove_if(
        this->lenses,
        [&label](auto s) { return s.label == label; }
    );

    this->lenses.erase(start, end);
}

void Box::addLens(const Sequence& sequence)
{
    auto lenseIter = std::ranges::find_if(
        this->lenses,
        [&sequence](auto s) { return s.label == sequence.label; }
    );

    if (lenseIter != this->lenses.end())
    {
        // replace lens if label is present
        lenseIter->focalLength = sequence.focalLength;
    }
    else
    {
        // add lens to the back
        this->lenses.emplace_back(sequence);
    }
}

int computeHash(const std::string& label)
{
    auto hash = 0;

    for(const auto& c : label)
    {
        hash += c;
        hash *= 17;
        hash %= 256;
    }

    return hash;
}

std::vector<std::shared_ptr<Box>> generateBoxes(int total)
{
    std::vector<std::shared_ptr<Box>> boxes(total);

    std::generate_n(boxes.begin(), total, []() {
        return std::make_shared<Box>();
    });

    return boxes;
}

void parseAndProcessBoxes(const std::vector<std::shared_ptr<Box>>& boxes, const std::string& input)
{
    std::ranges::for_each(
        splitString(input,  ','),
        [&boxes](const std::string& sequence) {
            auto parts = splitString(sequence,  '=');

            if (parts.size() == 1) {
                std::string label{ parts.front().begin(), parts.front().end() - 1 };
                boxes[computeHash(label)]->removeLens(label);
            } else {
                boxes[computeHash(parts.front())]->addLens({
                    parts.front(),
                    std::stoi(parts.back())
                });
            }
        });
}

int focusLenses(const std::vector<std::shared_ptr<Box>>& boxes)
{
    int focus = 0;

    for (auto boxId = 0; boxId < boxes.size(); boxId++)
    {
        const auto& box = boxes[boxId];

        for (auto slotId  = 0; slotId < box->lenses.size(); slotId++)
        {
            // calculate focusing power
            focus += (boxId + 1) * (slotId + 1) * box->lenses[slotId].focalLength;
        }
    }

    return focus;
}

constexpr std::string Day15::filename () const 
{
    return "main/days/15/input.txt";
}

int Day15::part1(const std::vector<std::string>& input) const
{
    int total = 0;

    for (const auto& s : splitString(input.front(),  ','))
    {
        total += computeHash(s);
    }

    return total;
}

int Day15::part2(const std::vector<std::string>& input) const 
{
    auto boxes = generateBoxes(256);
    parseAndProcessBoxes(boxes, input.front());
    return focusLenses(boxes);
}
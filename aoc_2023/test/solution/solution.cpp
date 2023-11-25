#include "gtest/gtest.h"

#include "src/solution/solution.h"

class TestReader : public Solution<int> 
{
public:
    const std::string filename() const override { return "test/solution/input.txt"; }
    int part1(const std::vector<std::string>&) const override { return 0; }
    int part2(const std::vector<std::string>&) const override { return 0; }
};

TEST(Solution, CanReadAFileToVector) 
{
    TestReader reader;

    auto input = reader.readInput();

    EXPECT_EQ(input.size(), 0);
}
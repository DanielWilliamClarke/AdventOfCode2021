package.path = package.path .. ";../utils/?.lua"

local test = require "simple_test"
local read_file = require "read_file"
local timing = require "timing"

local function print_grid(grid)
    for y = 1, #grid do
        local row = {}
        for x = 1, #grid[1] do
            table.insert(row, grid[y][x])
        end
        print(table.concat(row, ""))
    end
end

local function print_moves(moves)
    for _,m in ipairs(moves) do
        print(m[1] .. ", " .. m[2])
    end 
end

local function within_bounds(grid, position)
    return position[1] >= 1 and position[1] <= #grid and position[2] >= 1 and position[2] <= #grid[1]
end

local moves_to_dirs = {
    ["<"] = function() return { 0, -1 } end,
    ["^"] = function() return { -1, 0 } end,
    ["v"] = function() return { 1, 0 } end,
    [">"] = function() return { 0 , 1 } end
}

local single_to_double = {
    ["#"] = function() return { "#", "#" } end,
    ["O"] = function() return { "[", "]" } end,
    ["."] = function() return { ".", "." } end,
    ["@"] = function() return { "@", "." } end
}

local function parse_warehouse(lines, wide)
    local grid = {}

    for y,l in ipairs(lines) do
        if l == "" then
            goto finished
        end

        local row = {}
        local x = 1
        for char in string.gmatch(l, ".") do
            if not wide then 
                table.insert(row, char)
            else 
                local chars = single_to_double[char]()
                table.move(chars, 1, #chars, #row + 1, row)
            end
        
            x = x + 1
        end
        table.insert(grid, row)
    end

    ::finished::
    local new_lines = {}
    for i = #grid + 2, #lines do
        table.insert(new_lines, lines[i])
    end

    -- find robot
    local robot = {}
    for y = 1, #grid do
        for x = 1, #grid[1] do
            if grid[y][x] == "@" then
                robot = {y, x}
                break
            end
        end
    end
    -- print("Robot at:" .. robot[1] .. ", " .. robot[2])

    return grid, robot, new_lines
end

local function parse_moves(lines)
    local moves = {}

    for _,l in ipairs(lines) do
        for char in string.gmatch(l, ".") do
            table.insert(moves, moves_to_dirs[char]())
        end
    end

    return moves
end

local single_move -- forward declare
local function attempt_move_box (warehouse, current, next, dir, entity)
    local box_next, hits_wall = single_move(warehouse, next, dir)
    if hits_wall then
        return current, hits_wall -- wall, cant move
    else 
        -- if not hitting a wall move this entity
        warehouse[next[1]][next[2]] = "."
        warehouse[box_next[1]][box_next[2]] = entity
        return next, hits_wall
    end
end

function single_move(warehouse, current, dir)
    local next = {
        current[1] + dir[1],
        current[2] + dir[2]
    }

    if not within_bounds(warehouse, next) then
        return current
    end

    local entity = warehouse[next[1]][next[2]]
    if entity == "." then
        return next, false -- empty space, can move
    elseif entity == "#" then
       return current, true -- wall, cant move
    elseif entity == "O" then
        -- need to determine if this entity can move
        -- look in direction until you hit a . or a # 
        return attempt_move_box(warehouse, current, next, dir, entity)
    elseif entity == "[" or entity == "]" then
        -- when hitting from left or right should be no change 

        -- if hitting from up or down we need to account for moving the item left or right from it 
        -- based on either `[` look right and ']` look left 
        if dir[1] == 0 then  -- moving sideways
            return attempt_move_box(warehouse, current, next, dir, entity) -- ✅
        elseif dir[2] == 0 then -- moving updown
            -- do some foo here
            return current, true
        end
    end
end

local function process_robot_moves(warehouse, robot, moves, display)
    local robot_entity = "@"

    for _,m in ipairs(moves) do
        -- print(m[1] .. ", " .. m[2])
        local next = single_move(warehouse, robot, m)

        -- move robot
        warehouse[robot[1]][robot[2]] = "."
        warehouse[next[1]][next[2]] = robot_entity
        robot = next;
        if display then 
            print_grid(warehouse)
        end
    end
end

local function sum_gps_coordinates (warehouse)
    local total = 0
    for y = 1, #warehouse do
        for x = 1, #warehouse[1] do
            if warehouse[y][x] == 'O' then
                total = total + (100 * (y - 1) + (x - 1))
            end
        end
    end
    return total
end

local function part1()
    local lines =
        read_file.parse(
            "input.txt",
            function(line)
                return line
            end
        )

    local warehouse, robot, new_lines = parse_warehouse(lines)
    -- print_grid(warehouse)
    local moves = parse_moves(new_lines)
    -- print_moves(moves)
    process_robot_moves(warehouse, robot, moves)

    return sum_gps_coordinates(warehouse)
end

local function part2()
    local lines =
        read_file.parse(
            "example_mini.txt",
            function(line)
                return line
            end
        )

    local warehouse, robot, new_lines = parse_warehouse(lines, true)
    print_grid(warehouse)
    -- print_grid(warehouse)
    local moves = parse_moves(new_lines)
    process_robot_moves(warehouse, robot, moves, true)
    return 0
end

test(
    "🎅 Part 1",
    function(a)
        a.ok(timing.measure(part1) == 1406628, "Part 1 solution incorrect!")
    end
)

test(
    "🎄 Part 2",
    function(a)
        a.ok(timing.measure(part2) == 0, "Part 2 solution incorrect!")
    end
)
const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");

// ============================================================================
// GAME CONFIGURATION (Tweakable Global Variables)
// ============================================================================
// Modify any of the values below to tweak game balance, mechanics, or visuals.
// ============================================================================

// --- Population & City Settings ---
/// Total population starting in the city
pub var STARTING_POPULATION: i32 = 80;

// --- Heat Generator Settings ---
/// Radius around the heat generator where heat keeps citizens warm (in world units)
pub var GENERATOR_HEAT_RADIUS: f32 = 12.0;
/// Whether the heat generator starts in the active/turned-on state
pub var GENERATOR_STARTS_ACTIVE: bool = false;
/// Coal consumed per second while the heat generator is active
pub var GENERATOR_COAL_DRAIN_PER_SEC: f32 = 0.5;
/// Heat generator requires coal fuel to operate. When fuel reaches 0, it shuts down.
pub var GENERATOR_REQUIRES_COAL: bool = true;

// --- Initial Resource Stockpiles ---
pub var INITIAL_COAL_STOCKPILE: f32 = 80.0; // Starting reserve for initial generator operation
pub var INITIAL_WOOD_STOCKPILE: f32 = 80.0;
pub var INITIAL_STEEL_STOCKPILE: f32 = 40.0;
pub var INITIAL_FOOD_STOCKPILE: f32 = 80.0;

// --- Gathering Rates & Pile Limits ---
pub var COAL_GATHER_RATE_PER_WORKER_PER_SEC: f32 = 0.40;
pub var WOOD_GATHER_RATE_PER_WORKER_PER_SEC: f32 = 0.50;
pub var STEEL_GATHER_RATE_PER_WORKER_PER_SEC: f32 = 0.25;
pub var FOOD_GATHER_RATE_PER_WORKER_PER_SEC: f32 = 0.35;
/// Maximum workers that can be assigned to a single resource pile
pub var PILE_WORKER_CAP: i32 = 15;
/// Initial resource amount available in each resource pile (default: 200)
pub var PILE_INITIAL_RESOURCE: f32 = 200.0;
/// Initial resource limit for the Coal Pile
pub var INITIAL_COAL_PILE_RESOURCE: f32 = 200.0;
/// Initial resource limit for the Wood Pile
pub var INITIAL_WOOD_PILE_RESOURCE: f32 = 200.0;
/// Initial resource limit for the Steel Pile
pub var INITIAL_STEEL_PILE_RESOURCE: f32 = 200.0;
/// Initial resource limit for the Food Cache
pub var INITIAL_FOOD_PILE_RESOURCE: f32 = 200.0;

// --- Resource Pile Positions (Generator is located at (0, 0, 0)) ---
pub var COAL_PILE_POSITION: rl.Vector3 = .{ .x = -2.0, .y = 0.0, .z = -14.0 };
pub var WOOD_PILE_POSITION: rl.Vector3 = .{ .x = 12.0, .y = 0.0, .z = -6.0 };
pub var STEEL_PILE_POSITION: rl.Vector3 = .{ .x = -12.0, .y = 0.0, .z = 6.0 };
pub var FOOD_PILE_POSITION: rl.Vector3 = .{ .x = 6.0, .y = 0.0, .z = 12.0 };

// --- Citizen Movement & Behavior Settings ---
/// Walking speed of citizens in world units per second
pub var CITIZEN_WALK_SPEED: f32 = 3.0;
/// Inner radius boundary for idle citizens gathering around the generator
pub var CITIZEN_IDLE_MIN_RADIUS: f32 = 4.4;
/// Outer radius boundary for idle citizens gathering around the generator
pub var CITIZEN_IDLE_MAX_RADIUS: f32 = 9.5;
/// Wander radius around a resource pile for working citizens
pub var CITIZEN_WORK_RADIUS: f32 = 3.2;

// --- Camera Navigation Settings ---
pub var CAMERA_PAN_SPEED: f32 = 28.0;
pub var CAMERA_ZOOM_SPEED: f32 = 3.5;
pub var CAMERA_MIN_DISTANCE: f32 = 12.0;
pub var CAMERA_MAX_DISTANCE: f32 = 80.0;
pub var CAMERA_DEFAULT_POSITION: rl.Vector3 = .{ .x = 0.0, .y = 35.0, .z = 29.0 };
pub var CAMERA_DEFAULT_TARGET: rl.Vector3 = .{ .x = 0.0, .y = 0.0, .z = -1.0 };

// --- Performance & Frame Rate Settings ---
/// Whether to dynamically limit the frame rate to match the current monitor's refresh rate (e.g. 60Hz, 160Hz)
pub var LIMIT_FPS_TO_REFRESH_RATE: bool = true;
/// Fallback target frame rate when LIMIT_FPS_TO_REFRESH_RATE is false (0 = uncapped / unlimited frame rate)
pub var TARGET_FPS: i32 = 0;
/// Currently active frame rate limit applied to raylib
pub var ACTIVE_FPS_LIMIT: i32 = 60;
/// Whether to enable VSync (false when using setTargetFPS)
pub var ENABLE_VSYNC: bool = false;

// --- In-World Interaction & Screen Hit Settings ---
/// Screen-space pixel hit radius around pile base to register clicks and hovers
pub var PILE_SCREEN_HIT_RADIUS_PX: f32 = 65.0;
/// In-world vertical height offset where the floating badge/card is anchored above the pile
pub var PILE_LABEL_HEIGHT_OFFSET: f32 = 3.8;

// --- Grid & Structure Dimensions ---
/// World units per grid cell square (2.0 world units per square)
pub var GRID_CELL_SIZE: f32 = 2.0;

/// Width in grid squares for a House (2 squares = 4.0 world units)
pub var HOUSE_GRID_WIDTH: i32 = 2;
/// Length in grid squares for a House (2 squares = 4.0 world units)
pub var HOUSE_GRID_LENGTH: i32 = 2;

/// Width in grid squares for a Science Lab (3 squares = 6.0 world units)
pub var LAB_GRID_WIDTH: i32 = 3;
/// Length in grid squares for a Science Lab (3 squares = 6.0 world units)
pub var LAB_GRID_LENGTH: i32 = 3;

/// Width in grid squares for a Greenhouse (2 squares = 4.0 world units)
pub var GREENHOUSE_GRID_WIDTH: i32 = 2;
/// Length in grid squares for a Greenhouse (4 squares = 8.0 world units)
pub var GREENHOUSE_GRID_LENGTH: i32 = 4;

/// Width in grid squares for a Coal Mine (4 squares = 8.0 world units)
pub var COAL_MINE_GRID_WIDTH: i32 = 4;
/// Length in grid squares for a Coal Mine (4 squares = 8.0 world units)
pub var COAL_MINE_GRID_LENGTH: i32 = 4;

/// Width in grid squares for the Heat Generator (4 squares = 8.0 world units)
pub var GENERATOR_GRID_WIDTH: i32 = 4;
/// Length in grid squares for the Heat Generator (4 squares = 8.0 world units)
pub var GENERATOR_GRID_LENGTH: i32 = 4;
/// Origin grid X coordinate for the Heat Generator (centered at world 0, 0)
pub var GENERATOR_GRID_X: i32 = -2;
/// Origin grid Z coordinate for the Heat Generator (centered at world 0, 0)
pub var GENERATOR_GRID_Z: i32 = -2;

/// Width in grid squares for all Resource Piles (2 squares = 4.0 world units)
pub var PILE_GRID_WIDTH: i32 = 2;
/// Length in grid squares for all Resource Piles (2 squares = 4.0 world units)
pub var PILE_GRID_LENGTH: i32 = 2;

/// Grid coordinates for Coal Pile (2x2 squares)
pub var COAL_PILE_GRID_X: i32 = -2;
pub var COAL_PILE_GRID_Z: i32 = -8;

/// Grid coordinates for Wood Pile (2x2 squares)
pub var WOOD_PILE_GRID_X: i32 = 5;
pub var WOOD_PILE_GRID_Z: i32 = -4;

/// Grid coordinates for Steel Pile (2x2 squares)
pub var STEEL_PILE_GRID_X: i32 = -7;
pub var STEEL_PILE_GRID_Z: i32 = 2;

/// Grid coordinates for Food Pile (2x2 squares)
pub var FOOD_PILE_GRID_X: i32 = 2;
pub var FOOD_PILE_GRID_Z: i32 = 5;

/// Wood cost required to construct one House
pub var HOUSE_WOOD_COST: f32 = 20.0;
/// Total citizens sheltered by a completed House
pub var HOUSE_CAPACITY: i32 = 10;
/// Base construction duration in seconds when built by maximum workers
pub var HOUSE_BASE_BUILD_TIME: f32 = 20.0;
/// Maximum number of idle workers that can simultaneously construct a single House
pub var HOUSE_MAX_BUILDERS: i32 = 10;
/// Clearance collision radius around a House in world units
pub var HOUSE_COLLISION_RADIUS: f32 = 3.6;

/// Wood cost required to construct one Lab
pub var LAB_WOOD_COST: f32 = 30.0;
/// Worker capacity for a completed Lab
pub var LAB_CAPACITY: i32 = 10;
/// Base construction duration in seconds when built by maximum workers
pub var LAB_BASE_BUILD_TIME: f32 = 25.0;
/// Maximum number of idle workers that can simultaneously construct a single Lab
pub var LAB_MAX_BUILDERS: i32 = 10;
/// Clearance collision radius around a Lab in world units
pub var LAB_COLLISION_RADIUS: f32 = 5.2;

/// Wood cost required to construct one Greenhouse
pub var GREENHOUSE_WOOD_COST: f32 = 20.0;
/// Worker capacity for a completed Greenhouse
pub var GREENHOUSE_CAPACITY: i32 = 10;
/// Base construction duration in seconds when built by maximum workers
pub var GREENHOUSE_BASE_BUILD_TIME: f32 = 25.0;
/// Maximum number of idle workers that can simultaneously construct a single Greenhouse
pub var GREENHOUSE_MAX_BUILDERS: i32 = 10;
/// Clearance collision radius around a Greenhouse in world units
pub var GREENHOUSE_COLLISION_RADIUS: f32 = 4.8;

/// Wood cost required to research Greenhouses in the Lab
pub var GREENHOUSES_RESEARCH_WOOD_COST: f32 = 20.0;
/// Research duration in seconds for Greenhouses (2 minutes = 120 seconds)
pub var GREENHOUSES_RESEARCH_DURATION: f32 = 120.0;

/// Wood cost required to construct one Coal Mine
pub var COAL_MINE_WOOD_COST: f32 = 40.0;
/// Worker capacity for a completed Coal Mine
pub var COAL_MINE_CAPACITY: i32 = 10;
/// Base construction duration in seconds when built by maximum workers
pub var COAL_MINE_BASE_BUILD_TIME: f32 = 25.0;
/// Maximum number of idle workers that can simultaneously construct a single Coal Mine
pub var COAL_MINE_MAX_BUILDERS: i32 = 10;
/// Clearance collision radius around a Coal Mine in world units
pub var COAL_MINE_COLLISION_RADIUS: f32 = 5.8;

/// Wood cost required to research Coal Mine in the Lab
pub var COAL_MINE_RESEARCH_WOOD_COST: f32 = 100.0;
/// Steel cost required to research Coal Mine in the Lab
pub var COAL_MINE_RESEARCH_STEEL_COST: f32 = 100.0;
/// Research duration in seconds for Coal Mine (2 minutes = 120 seconds)
pub var COAL_MINE_RESEARCH_DURATION: f32 = 120.0;

/// Coal generation multiplier relative to a standard coal pile worker
pub var COAL_MINE_GATHER_RATE_MULTIPLIER: f32 = 2.0;
/// Coal generated per worker per second in a Coal Mine (double the coal of a coal pile: 0.40 * 2.0 = 0.80 coal/sec)
pub var COAL_MINE_COAL_RATE_PER_WORKER_PER_SEC: f32 = 0.80;

/// Width in grid squares for a Wood Shack (4 squares = 8.0 world units)
pub var WOOD_SHACK_GRID_WIDTH: i32 = 4;
/// Length in grid squares for a Wood Shack (4 squares = 8.0 world units)
pub var WOOD_SHACK_GRID_LENGTH: i32 = 4;

/// Wood cost required to construct one Wood Shack
pub var WOOD_SHACK_WOOD_COST: f32 = 100.0;
/// Steel cost required to construct one Wood Shack
pub var WOOD_SHACK_STEEL_COST: f32 = 50.0;
/// Worker capacity for a completed Wood Shack
pub var WOOD_SHACK_CAPACITY: i32 = 10;
/// Base construction duration in seconds when built by maximum workers
pub var WOOD_SHACK_BASE_BUILD_TIME: f32 = 25.0;
/// Maximum number of idle workers that can simultaneously construct a single Wood Shack
pub var WOOD_SHACK_MAX_BUILDERS: i32 = 10;
/// Clearance collision radius around a Wood Shack in world units
pub var WOOD_SHACK_COLLISION_RADIUS: f32 = 5.8;

/// Wood cost required to research Wood Shack in the Lab
pub var WOOD_SHACK_RESEARCH_WOOD_COST: f32 = 25.0;
/// Steel cost required to research Wood Shack in the Lab
pub var WOOD_SHACK_RESEARCH_STEEL_COST: f32 = 25.0;
/// Research duration in seconds for Wood Shack (2 minutes = 120 seconds)
pub var WOOD_SHACK_RESEARCH_DURATION: f32 = 120.0;

/// Wood generated per worker per second in a Wood Shack (10 workers = 10 wood/sec)
pub var WOOD_SHACK_WOOD_RATE_PER_WORKER_PER_SEC: f32 = 1.0;

/// Width in grid squares for a Steel Forge (4 squares = 8.0 world units)
pub var STEEL_FORGE_GRID_WIDTH: i32 = 4;
/// Length in grid squares for a Steel Forge (4 squares = 8.0 world units)
pub var STEEL_FORGE_GRID_LENGTH: i32 = 4;

/// Wood cost required to construct one Steel Forge
pub var STEEL_FORGE_WOOD_COST: f32 = 100.0;
/// Steel cost required to construct one Steel Forge
pub var STEEL_FORGE_STEEL_COST: f32 = 50.0;
/// Worker capacity for a completed Steel Forge
pub var STEEL_FORGE_CAPACITY: i32 = 10;
/// Base construction duration in seconds when built by maximum workers
pub var STEEL_FORGE_BASE_BUILD_TIME: f32 = 25.0;
/// Maximum number of idle workers that can simultaneously construct a single Steel Forge
pub var STEEL_FORGE_MAX_BUILDERS: i32 = 10;
/// Clearance collision radius around a Steel Forge in world units
pub var STEEL_FORGE_COLLISION_RADIUS: f32 = 5.8;

/// Wood cost required to research Steel Forge in the Lab
pub var STEEL_FORGE_RESEARCH_WOOD_COST: f32 = 25.0;
/// Steel cost required to research Steel Forge in the Lab
pub var STEEL_FORGE_RESEARCH_STEEL_COST: f32 = 25.0;
/// Research duration in seconds for Steel Forge (2 minutes = 120 seconds)
pub var STEEL_FORGE_RESEARCH_DURATION: f32 = 120.0;

/// Steel generated per worker per second in a Steel Forge (10 workers = 10 steel/sec)
pub var STEEL_FORGE_STEEL_RATE_PER_WORKER_PER_SEC: f32 = 1.0;

/// Maximum number of placed buildings in the settlement
pub const MAX_BUILDINGS: usize = 128;

// --- Visual Color Palette ---
pub var COLOR_SNOW_GROUND: rl.Color = rl.Color.init(236, 241, 246, 255); // Snowy white landscape
pub var COLOR_SNOW_RINGS: rl.Color = rl.Color.init(205, 218, 230, 255); // City district ring lines
pub var COLOR_HEAT_ZONE: rl.Color = rl.Color.init(255, 125, 30, 48); // Warm glowing amber heat disc
pub var COLOR_HEAT_ZONE_RING: rl.Color = rl.Color.init(255, 140, 35, 190); // Glowing heat boundary ring
pub var COLOR_GENERATOR_BASE: rl.Color = rl.Color.init(36, 38, 44, 255); // Dark industrial steel core
pub var COLOR_GENERATOR_LIT: rl.Color = rl.Color.init(255, 120, 20, 255); // Molten orange furnace vents
pub var COLOR_GENERATOR_UNLIT: rl.Color = rl.Color.init(65, 70, 80, 255); // Cold unlit furnace vents
pub var COLOR_COAL_PILE: rl.Color = rl.Color.init(28, 28, 34, 255); // Dark black coal
pub var COLOR_WOOD_PILE: rl.Color = rl.Color.init(142, 88, 48, 255); // Timber brown wood
pub var COLOR_STEEL_PILE: rl.Color = rl.Color.init(145, 168, 190, 255); // Metallic silver/blue steel
pub var COLOR_FOOD_PILE: rl.Color = rl.Color.init(195, 60, 48, 255); // Red supply crates
pub var COLOR_CITIZEN_WARM: rl.Color = rl.Color.init(230, 140, 35, 255); // Warm citizen coat
pub var COLOR_CITIZEN_COLD: rl.Color = rl.Color.init(65, 115, 180, 255); // Frostbitten citizen coat
pub var COLOR_HOUSE_WALLS: rl.Color = rl.Color.init(104, 76, 52, 255); // Timber brown wood walls
pub var COLOR_HOUSE_ROOF: rl.Color = rl.Color.init(54, 64, 75, 255); // Dark slate roof
pub var COLOR_HOUSE_CHIMNEY: rl.Color = rl.Color.init(45, 38, 34, 255); // Brick chimney
pub var COLOR_LAB_WALLS: rl.Color = rl.Color.init(68, 76, 88, 255); // Industrial stone gray
pub var COLOR_LAB_ROOF: rl.Color = rl.Color.init(42, 58, 72, 255); // Deep slate blue roof
pub var COLOR_LAB_DOME: rl.Color = rl.Color.init(50, 175, 205, 255); // Cyan glass observatory dome
pub var COLOR_GREENHOUSE_WALLS: rl.Color = rl.Color.init(45, 95, 80, 255); // Dark timber/bronze frame
pub var COLOR_GREENHOUSE_GLASS: rl.Color = rl.Color.init(65, 185, 145, 190); // Translucent seafoam glass panels
pub var COLOR_GREENHOUSE_ROOF: rl.Color = rl.Color.init(80, 205, 160, 220); // Pitched glass roof canopy
pub var COLOR_GREENHOUSE_CROPS: rl.Color = rl.Color.init(75, 185, 90, 255); // Vibrant agricultural crops
pub var COLOR_COAL_MINE_WALLS: rl.Color = rl.Color.init(48, 44, 42, 255); // Dark weathered timber & corrugated iron
pub var COLOR_COAL_MINE_ROOF: rl.Color = rl.Color.init(36, 40, 48, 255); // Heavy industrial slate/iron roof
pub var COLOR_COAL_MINE_FOUNDATION: rl.Color = rl.Color.init(32, 35, 40, 255); // Heavy reinforced stone base
pub var COLOR_COAL_MINE_HEADFRAME: rl.Color = rl.Color.init(72, 58, 48, 255); // Heavy structural timber tower
pub var COLOR_COAL_MINE_CHIMNEY: rl.Color = rl.Color.init(60, 38, 32, 255); // Industrial soot-stained smokestack
pub var COLOR_COAL_MINE_CHUTE: rl.Color = rl.Color.init(55, 60, 70, 255); // Heavy iron ore chute
pub var COLOR_COAL_MINE_WHEEL: rl.Color = rl.Color.init(115, 125, 140, 255); // Pithead winding gear wheel
pub var COLOR_WOOD_SHACK_WALLS: rl.Color = rl.Color.init(125, 82, 48, 255); // Rich rustic log walls
pub var COLOR_WOOD_SHACK_ROOF: rl.Color = rl.Color.init(78, 52, 34, 255); // Dark weathered timber shingle roof
pub var COLOR_WOOD_SHACK_FOUNDATION: rl.Color = rl.Color.init(52, 48, 44, 255); // Heavy stone foundation
pub var COLOR_WOOD_SHACK_LOGS: rl.Color = rl.Color.init(155, 105, 62, 255); // Freshly harvested timber logs
pub var COLOR_WOOD_SHACK_CHIMNEY: rl.Color = rl.Color.init(65, 62, 58, 255); // Cast iron stovepipe
pub var COLOR_WOOD_SHACK_PLANKS: rl.Color = rl.Color.init(175, 125, 78, 255); // Sawn timber planks
pub var COLOR_STEEL_FORGE_WALLS: rl.Color = rl.Color.init(55, 60, 68, 255); // Heavy dark iron & reinforced soot stone
pub var COLOR_STEEL_FORGE_ROOF: rl.Color = rl.Color.init(40, 44, 52, 255); // Dark industrial corrugated iron roof
pub var COLOR_STEEL_FORGE_FOUNDATION: rl.Color = rl.Color.init(35, 38, 44, 255); // Reinforced granite foundation
pub var COLOR_STEEL_FORGE_FIRE: rl.Color = rl.Color.init(255, 130, 30, 255); // Molten forge smelting hearth glow
pub var COLOR_STEEL_FORGE_CHIMNEY: rl.Color = rl.Color.init(48, 50, 56, 255); // Heavy iron blast stack
pub var COLOR_STEEL_FORGE_STEEL: rl.Color = rl.Color.init(160, 180, 205, 255); // Cast steel billets & anvil
pub var COLOR_SCAFFOLDING: rl.Color = rl.Color.init(184, 138, 72, 255); // Construction scaffolding frame
pub var COLOR_DISMANTLE_SCAFFOLD: rl.Color = rl.Color.init(205, 80, 60, 255); // Demolition/dismantling scaffolding frame
pub var COLOR_GHOST_VALID: rl.Color = rl.Color.init(60, 215, 120, 150); // Translucent green preview
pub var COLOR_GHOST_INVALID: rl.Color = rl.Color.init(235, 60, 60, 150); // Translucent red preview

// ============================================================================
// DATA STRUCTURES
// ============================================================================

pub const Resource = enum(usize) {
    coal = 0,
    wood = 1,
    steel = 2,
    food = 3,

    pub fn name(self: Resource) [:0]const u8 {
        return switch (self) {
            .coal => "Coal",
            .wood => "Wood",
            .steel => "Steel",
            .food => "Food",
        };
    }

    pub fn color(self: Resource) rl.Color {
        return switch (self) {
            .coal => COLOR_COAL_PILE,
            .wood => COLOR_WOOD_PILE,
            .steel => COLOR_STEEL_PILE,
            .food => COLOR_FOOD_PILE,
        };
    }

    pub fn gridX(self: Resource) i32 {
        return switch (self) {
            .coal => COAL_PILE_GRID_X,
            .wood => WOOD_PILE_GRID_X,
            .steel => STEEL_PILE_GRID_X,
            .food => FOOD_PILE_GRID_X,
        };
    }

    pub fn gridZ(self: Resource) i32 {
        return switch (self) {
            .coal => COAL_PILE_GRID_Z,
            .wood => WOOD_PILE_GRID_Z,
            .steel => STEEL_PILE_GRID_Z,
            .food => FOOD_PILE_GRID_Z,
        };
    }

    pub fn gridWidth(self: Resource) i32 {
        _ = self;
        return PILE_GRID_WIDTH;
    }

    pub fn gridLength(self: Resource) i32 {
        _ = self;
        return PILE_GRID_LENGTH;
    }

    pub fn position(self: Resource) rl.Vector3 {
        return switch (self) {
            .coal => COAL_PILE_POSITION,
            .wood => WOOD_PILE_POSITION,
            .steel => STEEL_PILE_POSITION,
            .food => FOOD_PILE_POSITION,
        };
    }

    pub fn gatherRate(self: Resource) f32 {
        return switch (self) {
            .coal => COAL_GATHER_RATE_PER_WORKER_PER_SEC,
            .wood => WOOD_GATHER_RATE_PER_WORKER_PER_SEC,
            .steel => STEEL_GATHER_RATE_PER_WORKER_PER_SEC,
            .food => FOOD_GATHER_RATE_PER_WORKER_PER_SEC,
        };
    }
};

pub const CitizenRole = enum {
    idle,
    gathering_coal,
    gathering_wood,
    gathering_steel,
    gathering_food,
    working_greenhouse,
    working_lab,
    working_coal_mine,
    working_wood_shack,
    working_steel_forge,

    pub fn toResource(self: CitizenRole) ?Resource {
        return switch (self) {
            .idle, .working_greenhouse, .working_lab, .working_coal_mine, .working_wood_shack, .working_steel_forge => null,
            .gathering_coal => .coal,
            .gathering_wood => .wood,
            .gathering_steel => .steel,
            .gathering_food => .food,
        };
    }

    pub fn fromResource(res: Resource) CitizenRole {
        return switch (res) {
            .coal => .gathering_coal,
            .wood => .gathering_wood,
            .steel => .gathering_steel,
            .food => .gathering_food,
        };
    }
};

pub const BuildingType = enum(usize) {
    house = 0,
    lab = 1,
    greenhouse = 2,
    coal_mine = 3,
    wood_shack = 4,
    steel_forge = 5,

    pub fn name(self: BuildingType) [:0]const u8 {
        return switch (self) {
            .house => "House",
            .lab => "Lab",
            .greenhouse => "Greenhouse",
            .coal_mine => "Coal Mine",
            .wood_shack => "Wood Shack",
            .steel_forge => "Steel Forge",
        };
    }

    pub fn woodCost(self: BuildingType) f32 {
        return switch (self) {
            .house => HOUSE_WOOD_COST,
            .lab => LAB_WOOD_COST,
            .greenhouse => GREENHOUSE_WOOD_COST,
            .coal_mine => COAL_MINE_WOOD_COST,
            .wood_shack => WOOD_SHACK_WOOD_COST,
            .steel_forge => STEEL_FORGE_WOOD_COST,
        };
    }

    pub fn steelCost(self: BuildingType) f32 {
        return switch (self) {
            .house, .lab, .greenhouse, .coal_mine => 0.0,
            .wood_shack => WOOD_SHACK_STEEL_COST,
            .steel_forge => STEEL_FORGE_STEEL_COST,
        };
    }

    pub fn capacity(self: BuildingType) i32 {
        return switch (self) {
            .house => HOUSE_CAPACITY,
            .lab => LAB_CAPACITY,
            .greenhouse => GREENHOUSE_CAPACITY,
            .coal_mine => COAL_MINE_CAPACITY,
            .wood_shack => WOOD_SHACK_CAPACITY,
            .steel_forge => STEEL_FORGE_CAPACITY,
        };
    }

    pub fn maxBuilders(self: BuildingType) i32 {
        return switch (self) {
            .house => HOUSE_MAX_BUILDERS,
            .lab => LAB_MAX_BUILDERS,
            .greenhouse => GREENHOUSE_MAX_BUILDERS,
            .coal_mine => COAL_MINE_MAX_BUILDERS,
            .wood_shack => WOOD_SHACK_MAX_BUILDERS,
            .steel_forge => STEEL_FORGE_MAX_BUILDERS,
        };
    }

    pub fn baseBuildTime(self: BuildingType) f32 {
        return switch (self) {
            .house => HOUSE_BASE_BUILD_TIME,
            .lab => LAB_BASE_BUILD_TIME,
            .greenhouse => GREENHOUSE_BASE_BUILD_TIME,
            .coal_mine => COAL_MINE_BASE_BUILD_TIME,
            .wood_shack => WOOD_SHACK_BASE_BUILD_TIME,
            .steel_forge => STEEL_FORGE_BASE_BUILD_TIME,
        };
    }

    pub fn gridWidth(self: BuildingType) i32 {
        return switch (self) {
            .house => HOUSE_GRID_WIDTH,
            .lab => LAB_GRID_WIDTH,
            .greenhouse => GREENHOUSE_GRID_WIDTH,
            .coal_mine => COAL_MINE_GRID_WIDTH,
            .wood_shack => WOOD_SHACK_GRID_WIDTH,
            .steel_forge => STEEL_FORGE_GRID_WIDTH,
        };
    }

    pub fn gridLength(self: BuildingType) i32 {
        return switch (self) {
            .house => HOUSE_GRID_LENGTH,
            .lab => LAB_GRID_LENGTH,
            .greenhouse => GREENHOUSE_GRID_LENGTH,
            .coal_mine => COAL_MINE_GRID_LENGTH,
            .wood_shack => WOOD_SHACK_GRID_LENGTH,
            .steel_forge => STEEL_FORGE_GRID_LENGTH,
        };
    }

    pub fn collisionRadius(self: BuildingType) f32 {
        return switch (self) {
            .house => HOUSE_COLLISION_RADIUS,
            .lab => LAB_COLLISION_RADIUS,
            .greenhouse => GREENHOUSE_COLLISION_RADIUS,
            .coal_mine => COAL_MINE_COLLISION_RADIUS,
            .wood_shack => WOOD_SHACK_COLLISION_RADIUS,
            .steel_forge => STEEL_FORGE_COLLISION_RADIUS,
        };
    }
};

pub const BuildingState = enum {
    constructing,
    completed,
    dismantling,
};

pub const Building = struct {
    id: usize,
    btype: BuildingType,
    grid_x: i32,
    grid_z: i32,
    pos: rl.Vector3,
    state: BuildingState,
    progress: f32, // 0.0 to 1.0
    active_builders: i32,
    is_warm: bool,
    assigned_workers: i32 = 0,
};

pub const GridCoord = struct {
    gx: i32,
    gz: i32,
};

pub const BuildTab = enum {
    people,
    food,
    science,
    resources,
};

pub const ResearchTab = enum {
    technology,
    food,
    resources,
    efficiency,
    exploration,
};

pub const ResearchState = enum {
    available,
    researching,
    completed,
};

pub const PlacementCheck = struct {
    valid: bool,
    reason: [:0]const u8,
};

pub const MAX_CITIZENS: usize = 1024;
pub const SIMD_WIDTH: usize = 4;
pub const Vec4f = @Vector(SIMD_WIDTH, f32);
pub const Vec4b = @Vector(SIMD_WIDTH, bool);
pub const Vec4i = @Vector(SIMD_WIDTH, i32);

pub const MAX_SMOKE_PARTICLES: usize = 32;

/// High-performance Struct-of-Arrays (SoA) for citizens.
/// Coordinates are aligned to 16 bytes for SIMD operations.
pub const CitizenManager = struct {
    pos_x: [MAX_CITIZENS]f32 align(16) = undefined,
    pos_z: [MAX_CITIZENS]f32 align(16) = undefined,
    target_x: [MAX_CITIZENS]f32 align(16) = undefined,
    target_z: [MAX_CITIZENS]f32 align(16) = undefined,
    speed: [MAX_CITIZENS]f32 align(16) = undefined,
    wander_timer: [MAX_CITIZENS]f32 align(16) = undefined,
    role: [MAX_CITIZENS]CitizenRole = undefined,
    is_warm: [MAX_CITIZENS]bool = undefined,
    count: usize = 0,

    // O(1) worker allocation index stacks
    idle_ids: [MAX_CITIZENS]u16 = undefined,
    idle_count: usize = 0,
    assigned_ids: [4][MAX_CITIZENS]u16 = undefined,
    assigned_counts: [4]usize = .{ 0, 0, 0, 0 },

    pub fn init(self: *CitizenManager, pop: usize) void {
        const capped_pop = @min(pop, MAX_CITIZENS);
        self.count = capped_pop;
        self.idle_count = 0;
        self.assigned_counts = .{ 0, 0, 0, 0 };

        for (0..capped_pop) |i| {
            const angle = randomFloat(0.0, std.math.pi * 2.0);
            const dist = randomFloat(CITIZEN_IDLE_MIN_RADIUS, CITIZEN_IDLE_MAX_RADIUS);
            const px = @cos(angle) * dist;
            const pz = @sin(angle) * dist;

            self.pos_x[i] = px;
            self.pos_z[i] = pz;
            self.target_x[i] = px;
            self.target_z[i] = pz;
            self.speed[i] = CITIZEN_WALK_SPEED * randomFloat(0.85, 1.15);
            self.wander_timer[i] = randomFloat(1.0, 4.0);
            self.role[i] = .idle;
            self.is_warm[i] = generator_active;

            self.idle_ids[self.idle_count] = @intCast(i);
            self.idle_count += 1;
        }

        var i = capped_pop;
        while (i < MAX_CITIZENS) : (i += 1) {
            self.pos_x[i] = 0.0;
            self.pos_z[i] = 0.0;
            self.target_x[i] = 0.0;
            self.target_z[i] = 0.0;
            self.speed[i] = 0.0;
            self.wander_timer[i] = 999.0;
            self.role[i] = .idle;
            self.is_warm[i] = false;
        }
    }

    pub fn getIdleCount(self: *const CitizenManager) usize {
        return self.idle_count;
    }

    pub fn getAssignedCount(self: *const CitizenManager, res: Resource) usize {
        return self.assigned_counts[@intFromEnum(res)];
    }

    pub fn assign(self: *CitizenManager, res: Resource, delta: i32) void {
        const res_idx = @intFromEnum(res);
        if (delta > 0) {
            if (isPileDepleted(res)) return;
            const cur_assigned = self.assigned_counts[res_idx];
            const cap: usize = @intCast(@max(0, PILE_WORKER_CAP));
            if (cur_assigned >= cap) return;
            const space_left: usize = cap - cur_assigned;
            const available: usize = @min(self.idle_count, space_left);
            const to_add: usize = @intCast(@min(@as(i32, @intCast(available)), delta));
            for (0..to_add) |_| {
                if (self.idle_count == 0) break;
                self.idle_count -= 1;
                const id = self.idle_ids[self.idle_count];

                self.assigned_ids[res_idx][self.assigned_counts[res_idx]] = id;
                self.assigned_counts[res_idx] += 1;

                const role = CitizenRole.fromResource(res);
                self.role[id] = role;
                const target = pickTargetForRole(role);
                self.target_x[id] = target.x;
                self.target_z[id] = target.z;
                self.wander_timer[id] = randomFloat(2.0, 5.5);
            }
        } else if (delta < 0) {
            const cur_assigned = self.assigned_counts[res_idx];
            const to_remove: usize = @intCast(@min(@as(i32, @intCast(cur_assigned)), -delta));
            for (0..to_remove) |_| {
                if (self.assigned_counts[res_idx] == 0) break;
                self.assigned_counts[res_idx] -= 1;
                const id = self.assigned_ids[res_idx][self.assigned_counts[res_idx]];

                self.idle_ids[self.idle_count] = id;
                self.idle_count += 1;

                self.role[id] = .idle;
                const target = pickTargetForRole(.idle);
                self.target_x[id] = target.x;
                self.target_z[id] = target.z;
                self.wander_timer[id] = randomFloat(2.0, 5.5);
            }
        }
    }

    pub fn update(self: *CitizenManager, dt: f32, is_gen_active: bool) struct { warm: i32, cold: i32 } {
        var warm_sum: i32 = 0;
        var cold_sum: i32 = 0;
        const heat_radius_sq = GENERATOR_HEAT_RADIUS * GENERATOR_HEAT_RADIUS;
        const heat_rad_sq_vec: Vec4f = @splat(heat_radius_sq);
        const ones: Vec4i = @splat(1);
        const zeros: Vec4i = @splat(0);

        var i: usize = 0;
        while (i + SIMD_WIDTH <= self.count) : (i += SIMD_WIDTH) {
            const px_ptr: *align(16) [SIMD_WIDTH]f32 = @alignCast(self.pos_x[i..][0..SIMD_WIDTH]);
            const pz_ptr: *align(16) [SIMD_WIDTH]f32 = @alignCast(self.pos_z[i..][0..SIMD_WIDTH]);
            const tx_ptr: *align(16) [SIMD_WIDTH]f32 = @alignCast(self.target_x[i..][0..SIMD_WIDTH]);
            const tz_ptr: *align(16) [SIMD_WIDTH]f32 = @alignCast(self.target_z[i..][0..SIMD_WIDTH]);
            const sp_ptr: *align(16) [SIMD_WIDTH]f32 = @alignCast(self.speed[i..][0..SIMD_WIDTH]);

            var px: Vec4f = px_ptr.*;
            var pz: Vec4f = pz_ptr.*;
            const tx: Vec4f = tx_ptr.*;
            const tz: Vec4f = tz_ptr.*;
            const sp: Vec4f = sp_ptr.*;

            // SIMD Warmth calculation (distance squared to (0,0))
            if (is_gen_active) {
                const dist_sq_gen = px * px + pz * pz;
                const warm_mask: Vec4b = dist_sq_gen <= heat_rad_sq_vec;
                self.is_warm[i..][0..SIMD_WIDTH].* = warm_mask;
                const warm_ints = @select(i32, warm_mask, ones, zeros);
                warm_sum += @reduce(.Add, warm_ints);
            } else {
                const false_mask: Vec4b = @splat(false);
                self.is_warm[i..][0..SIMD_WIDTH].* = false_mask;
            }

            // SIMD Movement calculation
            const dx = tx - px;
            const dz = tz - pz;
            const dist_sq = dx * dx + dz * dz;

            inline for (0..SIMD_WIDTH) |lane| {
                const d_sq = dist_sq[lane];
                if (d_sq > 0.0625) {
                    const dist = @sqrt(d_sq);
                    const step = @min(dist, sp[lane] * dt);
                    const inv_dist = 1.0 / dist;
                    px[lane] += dx[lane] * inv_dist * step;
                    pz[lane] += dz[lane] * inv_dist * step;
                } else {
                    self.wander_timer[i + lane] -= dt;
                    if (self.wander_timer[i + lane] <= 0.0) {
                        self.wander_timer[i + lane] = randomFloat(2.0, 5.5);
                        const new_tgt = pickTargetForRole(self.role[i + lane]);
                        self.target_x[i + lane] = new_tgt.x;
                        self.target_z[i + lane] = new_tgt.z;
                    }
                }
            }

            px_ptr.* = px;
            pz_ptr.* = pz;
        }

        // Remainder
        while (i < self.count) : (i += 1) {
            const px = self.pos_x[i];
            const pz = self.pos_z[i];

            if (is_gen_active) {
                const dist_sq = px * px + pz * pz;
                const w = dist_sq <= heat_radius_sq;
                self.is_warm[i] = w;
                if (w) warm_sum += 1;
            } else {
                self.is_warm[i] = false;
            }

            const dx = self.target_x[i] - px;
            const dz = self.target_z[i] - pz;
            const dist_sq = dx * dx + dz * dz;

            if (dist_sq > 0.0625) {
                const dist = @sqrt(dist_sq);
                const step = @min(dist, self.speed[i] * dt);
                const inv_dist = 1.0 / dist;
                self.pos_x[i] += dx * inv_dist * step;
                self.pos_z[i] += dz * inv_dist * step;
            } else {
                self.wander_timer[i] -= dt;
                if (self.wander_timer[i] <= 0.0) {
                    self.wander_timer[i] = randomFloat(2.0, 5.5);
                    const new_tgt = pickTargetForRole(self.role[i]);
                    self.target_x[i] = new_tgt.x;
                    self.target_z[i] = new_tgt.z;
                }
            }
        }

        cold_sum = @as(i32, @intCast(self.count)) - warm_sum;
        return .{ .warm = warm_sum, .cold = cold_sum };
    }
};

/// High-performance Struct-of-Arrays (SoA) for smoke particles.
pub const SmokeParticlesSoA = struct {
    pos_x: [MAX_SMOKE_PARTICLES]f32 align(16) = undefined,
    pos_y: [MAX_SMOKE_PARTICLES]f32 align(16) = undefined,
    pos_z: [MAX_SMOKE_PARTICLES]f32 align(16) = undefined,
    vel_x: [MAX_SMOKE_PARTICLES]f32 align(16) = undefined,
    vel_y: [MAX_SMOKE_PARTICLES]f32 align(16) = undefined,
    vel_z: [MAX_SMOKE_PARTICLES]f32 align(16) = undefined,
    alpha: [MAX_SMOKE_PARTICLES]f32 align(16) = undefined,
    size: [MAX_SMOKE_PARTICLES]f32 align(16) = undefined,
    active: [MAX_SMOKE_PARTICLES]bool = [_]bool{false} ** MAX_SMOKE_PARTICLES,
    spawn_timer: f32 = 0.0,

    pub fn init(self: *SmokeParticlesSoA) void {
        for (0..MAX_SMOKE_PARTICLES) |i| {
            self.active[i] = false;
            self.alpha[i] = 0.0;
        }
        self.spawn_timer = 0.0;
    }

    pub fn update(self: *SmokeParticlesSoA, dt: f32, is_gen_active: bool) void {
        if (is_gen_active) {
            self.spawn_timer += dt;
            if (self.spawn_timer >= 0.12) {
                self.spawn_timer = 0.0;
                for (0..MAX_SMOKE_PARTICLES) |i| {
                    if (!self.active[i]) {
                        self.active[i] = true;
                        self.pos_x[i] = randomFloat(-0.2, 0.2);
                        self.pos_y[i] = 11.2;
                        self.pos_z[i] = randomFloat(-0.2, 0.2);
                        self.vel_x[i] = randomFloat(-0.4, 0.4);
                        self.vel_y[i] = randomFloat(2.5, 4.0);
                        self.vel_z[i] = randomFloat(-0.4, 0.4);
                        self.alpha[i] = 0.85;
                        self.size[i] = randomFloat(0.4, 0.7);
                        break;
                    }
                }
            }
        }

        var i: usize = 0;
        const dt_v: Vec4f = @splat(dt);
        const alpha_decay_v: Vec4f = @splat(dt * 0.45);
        const size_growth_v: Vec4f = @splat(dt * 0.5);

        while (i + 4 <= MAX_SMOKE_PARTICLES) : (i += 4) {
            const px_ptr: *align(16) [4]f32 = @alignCast(self.pos_x[i..][0..4]);
            const py_ptr: *align(16) [4]f32 = @alignCast(self.pos_y[i..][0..4]);
            const pz_ptr: *align(16) [4]f32 = @alignCast(self.pos_z[i..][0..4]);
            const vx_ptr: *align(16) [4]f32 = @alignCast(self.vel_x[i..][0..4]);
            const vy_ptr: *align(16) [4]f32 = @alignCast(self.vel_y[i..][0..4]);
            const vz_ptr: *align(16) [4]f32 = @alignCast(self.vel_z[i..][0..4]);
            const a_ptr: *align(16) [4]f32 = @alignCast(self.alpha[i..][0..4]);
            const s_ptr: *align(16) [4]f32 = @alignCast(self.size[i..][0..4]);

            px_ptr.* = px_ptr.* + vx_ptr.* * dt_v;
            py_ptr.* = py_ptr.* + vy_ptr.* * dt_v;
            pz_ptr.* = pz_ptr.* + vz_ptr.* * dt_v;
            a_ptr.* = a_ptr.* - alpha_decay_v;
            s_ptr.* = s_ptr.* + size_growth_v;

            inline for (0..4) |lane| {
                if (self.active[i + lane] and self.alpha[i + lane] <= 0.0) {
                    self.active[i + lane] = false;
                }
            }
        }
    }

    pub fn draw(self: *const SmokeParticlesSoA) void {
        for (0..MAX_SMOKE_PARTICLES) |i| {
            if (self.active[i]) {
                const alpha_u8 = @as(u8, @intFromFloat(std.math.clamp(self.alpha[i] * 255.0, 0.0, 255.0)));
                const smoke_col = rl.Color.init(220, 225, 235, alpha_u8);
                rl.drawSphereEx(.{ .x = self.pos_x[i], .y = self.pos_y[i], .z = self.pos_z[i] }, self.size[i], 4, 6, smoke_col);
            }
        }
    }
};

// ============================================================================
// GAME STATE
// ============================================================================

var generator_active: bool = false;
var stockpiles: [4]f32 = .{ 0.0, 0.0, 0.0, 0.0 };
var pile_reserves: [4]f32 = .{ 200.0, 200.0, 200.0, 200.0 };
var workers_assigned: [4]i32 = .{ 0, 0, 0, 0 }; // workers per Resource enum

pub fn isPileActive(r: Resource) bool {
    return pile_reserves[@intFromEnum(r)] > 0.001;
}

pub fn isPileDepleted(r: Resource) bool {
    return pile_reserves[@intFromEnum(r)] <= 0.001;
}

fn depletePile(res: Resource) void {
    const res_idx = @intFromEnum(res);
    pile_reserves[res_idx] = 0.0;
    if (workers_assigned[res_idx] > 0) {
        assignWorkers(res, -workers_assigned[res_idx]);
    }
    if (selected_resource == res) {
        selected_resource = null;
    }
    if (hovered_resource == res) {
        hovered_resource = null;
    }
}
var citizen_mgr: CitizenManager = .{};
var smoke_soa: SmokeParticlesSoA = .{};
var total_citizens: usize = 0;

var selected_resource: ?Resource = null;
var hovered_resource: ?Resource = null;
var selected_generator: bool = false;
var hovered_generator: bool = false;

var buildings: [MAX_BUILDINGS]Building = undefined;
var buildings_count: usize = 0;
var build_menu_open: bool = false;
var active_build_tab: BuildTab = .people;
var placing_building: ?BuildingType = null;
var selected_building: ?usize = null;
var hovered_building: ?usize = null;

var is_paused: bool = false;
var show_controls_dialog: bool = false;
var pause_menu_selected_idx: usize = 0;
var should_quit: bool = false;
var fuel_warning_timer: f32 = 0.0;

var research_menu_open: bool = false;
var active_research_tab: ResearchTab = .food;
var greenhouses_research_state: ResearchState = .available;
var greenhouses_research_progress: f32 = 0.0;
var coal_mine_research_state: ResearchState = .available;
var coal_mine_research_progress: f32 = 0.0;
var wood_shack_research_state: ResearchState = .available;
var wood_shack_research_progress: f32 = 0.0;
var steel_forge_research_state: ResearchState = .available;
var steel_forge_research_progress: f32 = 0.0;
var research_spinner_angle: f32 = 0.0;

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

pub const MAX_EFFECTIVE_RESEARCH_LABS: usize = 4;
pub fn getMaxEffectiveResearchWorkers() i32 {
    return @as(i32, @intCast(MAX_EFFECTIVE_RESEARCH_LABS)) * LAB_CAPACITY;
}

fn hasCompletedLab() bool {
    for (buildings[0..buildings_count]) |b| {
        if (b.btype == .lab and b.state == .completed) {
            return true;
        }
    }
    return false;
}

fn isResearchActive() bool {
    return (greenhouses_research_state == .researching or coal_mine_research_state == .researching or wood_shack_research_state == .researching or steel_forge_research_state == .researching);
}

fn getActiveResearchProgress() f32 {
    if (greenhouses_research_state == .researching) {
        return std.math.clamp(greenhouses_research_progress / GREENHOUSES_RESEARCH_DURATION, 0.0, 1.0);
    } else if (coal_mine_research_state == .researching) {
        return std.math.clamp(coal_mine_research_progress / COAL_MINE_RESEARCH_DURATION, 0.0, 1.0);
    } else if (wood_shack_research_state == .researching) {
        return std.math.clamp(wood_shack_research_progress / WOOD_SHACK_RESEARCH_DURATION, 0.0, 1.0);
    } else if (steel_forge_research_state == .researching) {
        return std.math.clamp(steel_forge_research_progress / STEEL_FORGE_RESEARCH_DURATION, 0.0, 1.0);
    }
    return 0.0;
}

fn getTotalLabWorkers() i32 {
    var total: i32 = 0;
    for (buildings[0..buildings_count]) |b| {
        if (b.btype == .lab and b.state == .completed) {
            total += b.assigned_workers;
        }
    }
    return total;
}

fn getEffectiveResearchWorkers() i32 {
    var lab_workers: [MAX_BUILDINGS]i32 = undefined;
    var count: usize = 0;
    for (buildings[0..buildings_count]) |b| {
        if (b.btype == .lab and b.state == .completed) {
            lab_workers[count] = b.assigned_workers;
            count += 1;
        }
    }
    if (count == 0) return 0;

    // Sort descending to prioritize the highest staffed labs up to the 4-lab cap
    if (count > 1) {
        var i: usize = 0;
        while (i < count - 1) : (i += 1) {
            var j: usize = i + 1;
            while (j < count) : (j += 1) {
                if (lab_workers[j] > lab_workers[i]) {
                    const temp = lab_workers[i];
                    lab_workers[i] = lab_workers[j];
                    lab_workers[j] = temp;
                }
            }
        }
    }

    var total: i32 = 0;
    const limit = @min(count, MAX_EFFECTIVE_RESEARCH_LABS);
    for (lab_workers[0..limit]) |w| {
        total += w;
    }
    return total;
}

fn getResearchSpeedMultiplier() f32 {
    const eff = getEffectiveResearchWorkers();
    return @as(f32, @floatFromInt(eff)) / @as(f32, @floatFromInt(LAB_CAPACITY));
}

fn getGreenhousesCardRect(strip_y: f32) rl.Rectangle {
    return rl.Rectangle.init(16.0, strip_y + 44.0, 310.0, 92.0);
}

fn getGreenhousesCancelBtnRect(strip_y: f32) rl.Rectangle {
    const card = getGreenhousesCardRect(strip_y);
    const btn_w: f32 = 64.0;
    const btn_h: f32 = 20.0;
    return rl.Rectangle.init(card.x + card.width - btn_w - 12.0, card.y + 63.0, btn_w, btn_h);
}

fn getCoalMineCardRect(strip_y: f32) rl.Rectangle {
    return rl.Rectangle.init(16.0, strip_y + 44.0, 310.0, 92.0);
}

fn getCoalMineCancelBtnRect(strip_y: f32) rl.Rectangle {
    const card = getCoalMineCardRect(strip_y);
    const btn_w: f32 = 64.0;
    const btn_h: f32 = 20.0;
    return rl.Rectangle.init(card.x + card.width - btn_w - 12.0, card.y + 63.0, btn_w, btn_h);
}

fn getWoodShackCardRect(strip_y: f32) rl.Rectangle {
    return rl.Rectangle.init(338.0, strip_y + 44.0, 310.0, 92.0);
}

fn getWoodShackCancelBtnRect(strip_y: f32) rl.Rectangle {
    const card = getWoodShackCardRect(strip_y);
    const btn_w: f32 = 64.0;
    const btn_h: f32 = 20.0;
    return rl.Rectangle.init(card.x + card.width - btn_w - 12.0, card.y + 63.0, btn_w, btn_h);
}

fn getSteelForgeCardRect(strip_y: f32) rl.Rectangle {
    return rl.Rectangle.init(660.0, strip_y + 44.0, 310.0, 92.0);
}

fn getSteelForgeCancelBtnRect(strip_y: f32) rl.Rectangle {
    const card = getSteelForgeCardRect(strip_y);
    const btn_w: f32 = 64.0;
    const btn_h: f32 = 20.0;
    return rl.Rectangle.init(card.x + card.width - btn_w - 12.0, card.y + 63.0, btn_w, btn_h);
}

fn cancelOngoingResearch() void {
    if (greenhouses_research_state == .researching) {
        stockpiles[@intFromEnum(Resource.wood)] += GREENHOUSES_RESEARCH_WOOD_COST;
        greenhouses_research_state = .available;
        greenhouses_research_progress = 0.0;
    } else if (coal_mine_research_state == .researching) {
        stockpiles[@intFromEnum(Resource.wood)] += COAL_MINE_RESEARCH_WOOD_COST;
        stockpiles[@intFromEnum(Resource.steel)] += COAL_MINE_RESEARCH_STEEL_COST;
        coal_mine_research_state = .available;
        coal_mine_research_progress = 0.0;
    } else if (wood_shack_research_state == .researching) {
        stockpiles[@intFromEnum(Resource.wood)] += WOOD_SHACK_RESEARCH_WOOD_COST;
        stockpiles[@intFromEnum(Resource.steel)] += WOOD_SHACK_RESEARCH_STEEL_COST;
        wood_shack_research_state = .available;
        wood_shack_research_progress = 0.0;
    } else if (steel_forge_research_state == .researching) {
        stockpiles[@intFromEnum(Resource.wood)] += STEEL_FORGE_RESEARCH_WOOD_COST;
        stockpiles[@intFromEnum(Resource.steel)] += STEEL_FORGE_RESEARCH_STEEL_COST;
        steel_forge_research_state = .available;
        steel_forge_research_progress = 0.0;
    }
}


fn assignGreenhouseWorkers(idx: usize, delta: i32) void {
    if (idx >= buildings_count) return;
    var b = &buildings[idx];
    if (b.btype != .greenhouse or b.state != .completed) return;

    if (delta > 0) {
        const can_add = @min(delta, @as(i32, @intCast(citizen_mgr.getIdleCount())));
        const space = GREENHOUSE_CAPACITY - b.assigned_workers;
        const to_add = @min(can_add, space);
        var added: i32 = 0;
        while (added < to_add) : (added += 1) {
            if (citizen_mgr.idle_count == 0) break;
            citizen_mgr.idle_count -= 1;
            const id = citizen_mgr.idle_ids[citizen_mgr.idle_count];
            citizen_mgr.role[id] = .working_greenhouse;
            const angle = randomFloat(0.0, std.math.pi * 2.0);
            const dist = randomFloat(1.5, 3.5);
            citizen_mgr.target_x[id] = b.pos.x + @cos(angle) * dist;
            citizen_mgr.target_z[id] = b.pos.z + @sin(angle) * dist;
            citizen_mgr.wander_timer[id] = randomFloat(2.0, 5.0);
            b.assigned_workers += 1;
        }
    } else if (delta < 0) {
        const to_remove = @min(-delta, b.assigned_workers);
        var removed: i32 = 0;
        while (removed < to_remove) : (removed += 1) {
            var closest_id: ?usize = null;
            var min_dist_sq: f32 = std.math.floatMax(f32);
            for (0..citizen_mgr.count) |i| {
                if (citizen_mgr.role[i] == .working_greenhouse) {
                    const dx = citizen_mgr.pos_x[i] - b.pos.x;
                    const dz = citizen_mgr.pos_z[i] - b.pos.z;
                    const d_sq = dx * dx + dz * dz;
                    if (d_sq < min_dist_sq) {
                        min_dist_sq = d_sq;
                        closest_id = i;
                    }
                }
            }
            if (closest_id) |cid| {
                citizen_mgr.role[cid] = .idle;
                citizen_mgr.idle_ids[citizen_mgr.idle_count] = @intCast(cid);
                citizen_mgr.idle_count += 1;
                const tgt = pickTargetForRole(.idle);
                citizen_mgr.target_x[cid] = tgt.x;
                citizen_mgr.target_z[cid] = tgt.z;
                b.assigned_workers -= 1;
            } else {
                break;
            }
        }
    }
}

fn assignLabWorkers(idx: usize, delta: i32) void {
    if (idx >= buildings_count) return;
    var b = &buildings[idx];
    if (b.btype != .lab or b.state != .completed) return;

    if (delta > 0) {
        const can_add = @min(delta, @as(i32, @intCast(citizen_mgr.getIdleCount())));
        const space = LAB_CAPACITY - b.assigned_workers;
        const to_add = @min(can_add, space);
        var added: i32 = 0;
        while (added < to_add) : (added += 1) {
            if (citizen_mgr.idle_count == 0) break;
            citizen_mgr.idle_count -= 1;
            const id = citizen_mgr.idle_ids[citizen_mgr.idle_count];
            citizen_mgr.role[id] = .working_lab;
            const angle = randomFloat(0.0, std.math.pi * 2.0);
            const dist = randomFloat(1.5, 3.2);
            citizen_mgr.target_x[id] = b.pos.x + @cos(angle) * dist;
            citizen_mgr.target_z[id] = b.pos.z + @sin(angle) * dist;
            citizen_mgr.wander_timer[id] = randomFloat(2.0, 5.0);
            b.assigned_workers += 1;
        }
    } else if (delta < 0) {
        const to_remove = @min(-delta, b.assigned_workers);
        var removed: i32 = 0;
        while (removed < to_remove) : (removed += 1) {
            var closest_id: ?usize = null;
            var min_dist_sq: f32 = std.math.floatMax(f32);
            for (0..citizen_mgr.count) |i| {
                if (citizen_mgr.role[i] == .working_lab) {
                    const dx = citizen_mgr.pos_x[i] - b.pos.x;
                    const dz = citizen_mgr.pos_z[i] - b.pos.z;
                    const d_sq = dx * dx + dz * dz;
                    if (d_sq < min_dist_sq) {
                        min_dist_sq = d_sq;
                        closest_id = i;
                    }
                }
            }
            if (closest_id) |cid| {
                citizen_mgr.role[cid] = .idle;
                citizen_mgr.idle_ids[citizen_mgr.idle_count] = @intCast(cid);
                citizen_mgr.idle_count += 1;
                const tgt = pickTargetForRole(.idle);
                citizen_mgr.target_x[cid] = tgt.x;
                citizen_mgr.target_z[cid] = tgt.z;
                b.assigned_workers -= 1;
            } else {
                break;
            }
        }
    }
}

fn assignCoalMineWorkers(idx: usize, delta: i32) void {
    if (idx >= buildings_count) return;
    var b = &buildings[idx];
    if (b.btype != .coal_mine or b.state != .completed) return;

    if (delta > 0) {
        const can_add = @min(delta, @as(i32, @intCast(citizen_mgr.getIdleCount())));
        const space = COAL_MINE_CAPACITY - b.assigned_workers;
        const to_add = @min(can_add, space);
        var added: i32 = 0;
        while (added < to_add) : (added += 1) {
            if (citizen_mgr.idle_count == 0) break;
            citizen_mgr.idle_count -= 1;
            const id = citizen_mgr.idle_ids[citizen_mgr.idle_count];
            citizen_mgr.role[id] = .working_coal_mine;
            const angle = randomFloat(0.0, std.math.pi * 2.0);
            const dist = randomFloat(2.0, 4.5);
            citizen_mgr.target_x[id] = b.pos.x + @cos(angle) * dist;
            citizen_mgr.target_z[id] = b.pos.z + @sin(angle) * dist;
            citizen_mgr.wander_timer[id] = randomFloat(2.0, 5.0);
            b.assigned_workers += 1;
        }
    } else if (delta < 0) {
        const to_remove = @min(-delta, b.assigned_workers);
        var removed: i32 = 0;
        while (removed < to_remove) : (removed += 1) {
            var closest_id: ?usize = null;
            var min_dist_sq: f32 = std.math.floatMax(f32);
            for (0..citizen_mgr.count) |i| {
                if (citizen_mgr.role[i] == .working_coal_mine) {
                    const dx = citizen_mgr.pos_x[i] - b.pos.x;
                    const dz = citizen_mgr.pos_z[i] - b.pos.z;
                    const d_sq = dx * dx + dz * dz;
                    if (d_sq < min_dist_sq) {
                        min_dist_sq = d_sq;
                        closest_id = i;
                    }
                }
            }
            if (closest_id) |cid| {
                citizen_mgr.role[cid] = .idle;
                citizen_mgr.idle_ids[citizen_mgr.idle_count] = @intCast(cid);
                citizen_mgr.idle_count += 1;
                const tgt = pickTargetForRole(.idle);
                citizen_mgr.target_x[cid] = tgt.x;
                citizen_mgr.target_z[cid] = tgt.z;
                b.assigned_workers -= 1;
            } else {
                break;
            }
        }
    }
}

fn assignWoodShackWorkers(idx: usize, delta: i32) void {
    if (idx >= buildings_count) return;
    var b = &buildings[idx];
    if (b.btype != .wood_shack or b.state != .completed) return;

    if (delta > 0) {
        const can_add = @min(delta, @as(i32, @intCast(citizen_mgr.getIdleCount())));
        const space = WOOD_SHACK_CAPACITY - b.assigned_workers;
        const to_add = @min(can_add, space);
        var added: i32 = 0;
        while (added < to_add) : (added += 1) {
            if (citizen_mgr.idle_count == 0) break;
            citizen_mgr.idle_count -= 1;
            const id = citizen_mgr.idle_ids[citizen_mgr.idle_count];
            citizen_mgr.role[id] = .working_wood_shack;
            const angle = randomFloat(0.0, std.math.pi * 2.0);
            const dist = randomFloat(2.0, 4.5);
            citizen_mgr.target_x[id] = b.pos.x + @cos(angle) * dist;
            citizen_mgr.target_z[id] = b.pos.z + @sin(angle) * dist;
            citizen_mgr.wander_timer[id] = randomFloat(2.0, 5.0);
            b.assigned_workers += 1;
        }
    } else if (delta < 0) {
        const to_remove = @min(-delta, b.assigned_workers);
        var removed: i32 = 0;
        while (removed < to_remove) : (removed += 1) {
            var closest_id: ?usize = null;
            var min_dist_sq: f32 = std.math.floatMax(f32);
            for (0..citizen_mgr.count) |i| {
                if (citizen_mgr.role[i] == .working_wood_shack) {
                    const dx = citizen_mgr.pos_x[i] - b.pos.x;
                    const dz = citizen_mgr.pos_z[i] - b.pos.z;
                    const d_sq = dx * dx + dz * dz;
                    if (d_sq < min_dist_sq) {
                        min_dist_sq = d_sq;
                        closest_id = i;
                    }
                }
            }
            if (closest_id) |cid| {
                citizen_mgr.role[cid] = .idle;
                citizen_mgr.idle_ids[citizen_mgr.idle_count] = @intCast(cid);
                citizen_mgr.idle_count += 1;
                const tgt = pickTargetForRole(.idle);
                citizen_mgr.target_x[cid] = tgt.x;
                citizen_mgr.target_z[cid] = tgt.z;
                b.assigned_workers -= 1;
            } else {
                break;
            }
        }
    }
}

fn assignSteelForgeWorkers(idx: usize, delta: i32) void {
    if (idx >= buildings_count) return;
    var b = &buildings[idx];
    if (b.btype != .steel_forge or b.state != .completed) return;

    if (delta > 0) {
        const can_add = @min(delta, @as(i32, @intCast(citizen_mgr.getIdleCount())));
        const space = STEEL_FORGE_CAPACITY - b.assigned_workers;
        const to_add = @min(can_add, space);
        var added: i32 = 0;
        while (added < to_add) : (added += 1) {
            if (citizen_mgr.idle_count == 0) break;
            citizen_mgr.idle_count -= 1;
            const id = citizen_mgr.idle_ids[citizen_mgr.idle_count];
            citizen_mgr.role[id] = .working_steel_forge;
            const angle = randomFloat(0.0, std.math.pi * 2.0);
            const dist = randomFloat(2.0, 4.5);
            citizen_mgr.target_x[id] = b.pos.x + @cos(angle) * dist;
            citizen_mgr.target_z[id] = b.pos.z + @sin(angle) * dist;
            citizen_mgr.wander_timer[id] = randomFloat(2.0, 5.0);
            b.assigned_workers += 1;
        }
    } else if (delta < 0) {
        const to_remove = @min(-delta, b.assigned_workers);
        var removed: i32 = 0;
        while (removed < to_remove) : (removed += 1) {
            var closest_id: ?usize = null;
            var min_dist_sq: f32 = std.math.floatMax(f32);
            for (0..citizen_mgr.count) |i| {
                if (citizen_mgr.role[i] == .working_steel_forge) {
                    const dx = citizen_mgr.pos_x[i] - b.pos.x;
                    const dz = citizen_mgr.pos_z[i] - b.pos.z;
                    const d_sq = dx * dx + dz * dz;
                    if (d_sq < min_dist_sq) {
                        min_dist_sq = d_sq;
                        closest_id = i;
                    }
                }
            }
            if (closest_id) |cid| {
                citizen_mgr.role[cid] = .idle;
                citizen_mgr.idle_ids[citizen_mgr.idle_count] = @intCast(cid);
                citizen_mgr.idle_count += 1;
                const tgt = pickTargetForRole(.idle);
                citizen_mgr.target_x[cid] = tgt.x;
                citizen_mgr.target_z[cid] = tgt.z;
                b.assigned_workers -= 1;
            } else {
                break;
            }
        }
    }
}

fn removeBuilding(idx: usize) void {
    if (idx >= buildings_count) return;
    if (buildings[idx].btype == .greenhouse and buildings[idx].assigned_workers > 0) {
        assignGreenhouseWorkers(idx, -buildings[idx].assigned_workers);
    }
    if (buildings[idx].btype == .lab and buildings[idx].assigned_workers > 0) {
        assignLabWorkers(idx, -buildings[idx].assigned_workers);
    }
    if (buildings[idx].btype == .coal_mine and buildings[idx].assigned_workers > 0) {
        assignCoalMineWorkers(idx, -buildings[idx].assigned_workers);
    }
    if (buildings[idx].btype == .wood_shack and buildings[idx].assigned_workers > 0) {
        assignWoodShackWorkers(idx, -buildings[idx].assigned_workers);
    }
    if (buildings[idx].btype == .steel_forge and buildings[idx].assigned_workers > 0) {
        assignSteelForgeWorkers(idx, -buildings[idx].assigned_workers);
    }
    var i = idx;
    while (i + 1 < buildings_count) : (i += 1) {
        buildings[i] = buildings[i + 1];
        buildings[i].id = i;
    }
    buildings_count -= 1;

    if (selected_building) |sel| {
        if (sel == idx) {
            selected_building = null;
        } else if (sel > idx) {
            selected_building = sel - 1;
        }
    }
    if (hovered_building) |hov| {
        if (hov == idx) {
            hovered_building = null;
        } else if (hov > idx) {
            hovered_building = hov - 1;
        }
    }
}

fn getBuildBtnRect(sh: f32) rl.Rectangle {
    const btn_w: f32 = 126.0;
    const btn_h: f32 = 36.0;
    const btn_x: f32 = 16.0;
    const btn_y: f32 = if (build_menu_open or research_menu_open) sh - 148.0 - btn_h - 8.0 else sh - btn_h - 16.0;
    return rl.Rectangle.init(btn_x, btn_y, btn_w, btn_h);
}

fn getResearchBtnRect(sh: f32) rl.Rectangle {
    const btn_w: f32 = 140.0;
    const btn_h: f32 = 36.0;
    const btn_x: f32 = 16.0 + 126.0 + 8.0;
    const btn_y: f32 = if (build_menu_open or research_menu_open) sh - 148.0 - btn_h - 8.0 else sh - btn_h - 16.0;
    return rl.Rectangle.init(btn_x, btn_y, btn_w, btn_h);
}

fn getControlsBtnRect(sw: f32, sh: f32) rl.Rectangle {
    const btn_w: f32 = 110.0;
    const btn_h: f32 = 36.0;
    const btn_x: f32 = sw - btn_w - 16.0;
    const btn_y: f32 = if (build_menu_open or research_menu_open) sh - 148.0 - btn_h - 8.0 else sh - btn_h - 16.0;
    return rl.Rectangle.init(btn_x, btn_y, btn_w, btn_h);
}

fn getPopPillRect(screen_w: i32) rl.Rectangle {
    const fps_badge_w: i32 = if (LIMIT_FPS_TO_REFRESH_RATE) 124 else 76;
    const fps_box_x: i32 = screen_w - fps_badge_w - 12;
    const pop_box_w: i32 = 360;
    const pop_box_x: i32 = fps_box_x - pop_box_w - 14;
    return rl.Rectangle.init(
        @as(f32, @floatFromInt(pop_box_x + 2)),
        6.0,
        72.0,
        32.0,
    );
}

fn fmt(comptime format: []const u8, args: anytype) [:0]const u8 {
    const RingSize = 16;
    const BufSize = 128;
    const S = struct {
        var buffers: [RingSize][BufSize:0]u8 = undefined;
        var ring_idx: usize = 0;
    };
    const idx = S.ring_idx;
    S.ring_idx = (S.ring_idx + 1) % RingSize;
    return std.fmt.bufPrintZ(&S.buffers[idx], format, args) catch "err";
}

fn randomFloat(min: f32, max: f32) f32 {
    const r = @as(f32, @floatFromInt(rl.getRandomValue(0, 10000))) / 10000.0;
    return min + r * (max - min);
}

fn getIdleCitizensCount() i32 {
    return @intCast(citizen_mgr.getIdleCount());
}

fn getMouseGroundIntersection(ray: rl.Ray) ?rl.Vector3 {
    if (@abs(ray.direction.y) < 0.0001) return null;
    const t = -ray.position.y / ray.direction.y;
    if (t < 0.0) return null;
    return rl.Vector3{
        .x = ray.position.x + t * ray.direction.x,
        .y = 0.0,
        .z = ray.position.z + t * ray.direction.z,
    };
}

pub fn worldToGrid(hx: f32, hz: f32, gw: i32, gl: i32) GridCoord {
    const s = GRID_CELL_SIZE;
    const half_w = @as(f32, @floatFromInt(gw)) * 0.5;
    const half_l = @as(f32, @floatFromInt(gl)) * 0.5;
    const gx = @as(i32, @intFromFloat(@round((hx / s) - half_w)));
    const gz = @as(i32, @intFromFloat(@round((hz / s) - half_l)));
    return .{ .gx = gx, .gz = gz };
}

pub fn gridToWorldCenter(gx: i32, gz: i32, gw: i32, gl: i32) rl.Vector3 {
    const s = GRID_CELL_SIZE;
    const cx = (@as(f32, @floatFromInt(gx)) + @as(f32, @floatFromInt(gw)) * 0.5) * s;
    const cz = (@as(f32, @floatFromInt(gz)) + @as(f32, @floatFromInt(gl)) * 0.5) * s;
    return .{ .x = cx, .y = 0.0, .z = cz };
}

fn distSqPointToBox2D(px: f32, pz: f32, min_x: f32, max_x: f32, min_z: f32, max_z: f32) f32 {
    const closest_x = std.math.clamp(px, min_x, max_x);
    const closest_z = std.math.clamp(pz, min_z, max_z);
    const dx = px - closest_x;
    const dz = pz - closest_z;
    return dx * dx + dz * dz;
}

fn canPlaceBuildingAtGrid(gx: i32, gz: i32, btype: BuildingType) PlacementCheck {
    const gw = btype.gridWidth();
    const gl = btype.gridLength();

    // 1. Grid overlap check with Heat Generator (4x4 squares: [GENERATOR_GRID_X, GENERATOR_GRID_X + GENERATOR_GRID_WIDTH))
    const gen_overlap_x = (gx < GENERATOR_GRID_X + GENERATOR_GRID_WIDTH) and (gx + gw > GENERATOR_GRID_X);
    const gen_overlap_z = (gz < GENERATOR_GRID_Z + GENERATOR_GRID_LENGTH) and (gz + gl > GENERATOR_GRID_Z);
    if (gen_overlap_x and gen_overlap_z) {
        return .{ .valid = false, .reason = "Overlaps Heat Generator" };
    }

    // 2. Grid overlap check with Resource Piles (2x2 squares each)
    inline for (std.meta.tags(Resource)) |r| {
        if (isPileActive(r)) {
            const rgx = r.gridX();
            const rgz = r.gridZ();
            const rgw = r.gridWidth();
            const rgl = r.gridLength();

            const pile_overlap_x = (gx < rgx + rgw) and (gx + gw > rgx);
            const pile_overlap_z = (gz < rgz + rgl) and (gz + gl > rgz);
            if (pile_overlap_x and pile_overlap_z) {
                return .{ .valid = false, .reason = "Overlaps resource pile" };
            }
        }
    }

    // 3. Grid overlap check with existing buildings (exact integer interval overlap)
    for (buildings[0..buildings_count]) |b| {
        const bgw = b.btype.gridWidth();
        const bgl = b.btype.gridLength();

        const overlap_x = (gx < b.grid_x + bgw) and (gx + gw > b.grid_x);
        const overlap_z = (gz < b.grid_z + bgl) and (gz + gl > b.grid_z);

        if (overlap_x and overlap_z) {
            return .{ .valid = false, .reason = "Grid squares occupied" };
        }
    }

    // 4. City boundary check
    const center_pos = gridToWorldCenter(gx, gz, gw, gl);
    const dist_center_sq = center_pos.x * center_pos.x + center_pos.z * center_pos.z;
    if (dist_center_sq > 85.0 * 85.0) {
        return .{ .valid = false, .reason = "Beyond city boundary" };
    }

    // 5. Wood and Steel cost check
    if (stockpiles[@intFromEnum(Resource.wood)] < btype.woodCost()) {
        return .{ .valid = false, .reason = "Insufficient Wood" };
    }
    if (stockpiles[@intFromEnum(Resource.steel)] < btype.steelCost()) {
        return .{ .valid = false, .reason = "Insufficient Steel" };
    }

    return .{ .valid = true, .reason = "Click to Place" };
}

fn pickTargetForRole(role: CitizenRole) rl.Vector3 {
    if (role == .working_greenhouse) {
        for (buildings[0..buildings_count]) |b| {
            if (b.btype == .greenhouse and b.state == .completed and b.assigned_workers > 0) {
                const angle = randomFloat(0.0, std.math.pi * 2.0);
                const dist = randomFloat(1.5, 3.5);
                return .{
                    .x = b.pos.x + @cos(angle) * dist,
                    .y = 0.0,
                    .z = b.pos.z + @sin(angle) * dist,
                };
            }
        }
        // Fallback to generator
        const angle = randomFloat(0.0, std.math.pi * 2.0);
        const dist = randomFloat(CITIZEN_IDLE_MIN_RADIUS, CITIZEN_IDLE_MAX_RADIUS);
        return .{
            .x = @cos(angle) * dist,
            .y = 0.0,
            .z = @sin(angle) * dist,
        };
    } else if (role == .working_lab) {
        for (buildings[0..buildings_count]) |b| {
            if (b.btype == .lab and b.state == .completed and b.assigned_workers > 0) {
                const angle = randomFloat(0.0, std.math.pi * 2.0);
                const dist = randomFloat(1.5, 3.2);
                return .{
                    .x = b.pos.x + @cos(angle) * dist,
                    .y = 0.0,
                    .z = b.pos.z + @sin(angle) * dist,
                };
            }
        }
        const angle = randomFloat(0.0, std.math.pi * 2.0);
        const dist = randomFloat(CITIZEN_IDLE_MIN_RADIUS, CITIZEN_IDLE_MAX_RADIUS);
        return .{
            .x = @cos(angle) * dist,
            .y = 0.0,
            .z = @sin(angle) * dist,
        };
    } else if (role == .working_coal_mine) {
        for (buildings[0..buildings_count]) |b| {
            if (b.btype == .coal_mine and b.state == .completed and b.assigned_workers > 0) {
                const angle = randomFloat(0.0, std.math.pi * 2.0);
                const dist = randomFloat(2.0, 4.5);
                return .{
                    .x = b.pos.x + @cos(angle) * dist,
                    .y = 0.0,
                    .z = b.pos.z + @sin(angle) * dist,
                };
            }
        }
        const angle = randomFloat(0.0, std.math.pi * 2.0);
        const dist = randomFloat(CITIZEN_IDLE_MIN_RADIUS, CITIZEN_IDLE_MAX_RADIUS);
        return .{
            .x = @cos(angle) * dist,
            .y = 0.0,
            .z = @sin(angle) * dist,
        };
    } else if (role == .working_wood_shack) {
        for (buildings[0..buildings_count]) |b| {
            if (b.btype == .wood_shack and b.state == .completed and b.assigned_workers > 0) {
                const angle = randomFloat(0.0, std.math.pi * 2.0);
                const dist = randomFloat(2.0, 4.5);
                return .{
                    .x = b.pos.x + @cos(angle) * dist,
                    .y = 0.0,
                    .z = b.pos.z + @sin(angle) * dist,
                };
            }
        }
        const angle = randomFloat(0.0, std.math.pi * 2.0);
        const dist = randomFloat(CITIZEN_IDLE_MIN_RADIUS, CITIZEN_IDLE_MAX_RADIUS);
        return .{
            .x = @cos(angle) * dist,
            .y = 0.0,
            .z = @sin(angle) * dist,
        };
    } else if (role == .working_steel_forge) {
        for (buildings[0..buildings_count]) |b| {
            if (b.btype == .steel_forge and b.state == .completed and b.assigned_workers > 0) {
                const angle = randomFloat(0.0, std.math.pi * 2.0);
                const dist = randomFloat(2.0, 4.5);
                return .{
                    .x = b.pos.x + @cos(angle) * dist,
                    .y = 0.0,
                    .z = b.pos.z + @sin(angle) * dist,
                };
            }
        }
        const angle = randomFloat(0.0, std.math.pi * 2.0);
        const dist = randomFloat(CITIZEN_IDLE_MIN_RADIUS, CITIZEN_IDLE_MAX_RADIUS);
        return .{
            .x = @cos(angle) * dist,
            .y = 0.0,
            .z = @sin(angle) * dist,
        };
    } else if (role.toResource()) |res| {
        if (isPileDepleted(res)) {
            const angle = randomFloat(0.0, std.math.pi * 2.0);
            const dist = randomFloat(CITIZEN_IDLE_MIN_RADIUS, CITIZEN_IDLE_MAX_RADIUS);
            return .{
                .x = @cos(angle) * dist,
                .y = 0.0,
                .z = @sin(angle) * dist,
            };
        }
        const center = res.position();
        const angle = randomFloat(0.0, std.math.pi * 2.0);
        const dist = randomFloat(1.2, CITIZEN_WORK_RADIUS);
        return .{
            .x = center.x + @cos(angle) * dist,
            .y = 0.0,
            .z = center.z + @sin(angle) * dist,
        };
    } else {
        // Idle citizens: If there is an active construction site with active builders,
        // wander around that construction site to visually assist!
        for (buildings[0..buildings_count]) |b| {
            if ((b.state == .constructing or b.state == .dismantling) and b.active_builders > 0) {
                if (randomFloat(0.0, 1.0) < 0.65) {
                    const angle = randomFloat(0.0, std.math.pi * 2.0);
                    const dist = randomFloat(1.6, 3.2);
                    return .{
                        .x = b.pos.x + @cos(angle) * dist,
                        .y = 0.0,
                        .z = b.pos.z + @sin(angle) * dist,
                    };
                }
            }
        }

        // Otherwise wander around the central generator
        const angle = randomFloat(0.0, std.math.pi * 2.0);
        const dist = randomFloat(CITIZEN_IDLE_MIN_RADIUS, CITIZEN_IDLE_MAX_RADIUS);
        return .{
            .x = @cos(angle) * dist,
            .y = 0.0,
            .z = @sin(angle) * dist,
        };
    }
}

fn initGame() void {
    generator_active = GENERATOR_STARTS_ACTIVE;
    stockpiles[@intFromEnum(Resource.coal)] = INITIAL_COAL_STOCKPILE;
    stockpiles[@intFromEnum(Resource.wood)] = INITIAL_WOOD_STOCKPILE;
    stockpiles[@intFromEnum(Resource.steel)] = INITIAL_STEEL_STOCKPILE;
    stockpiles[@intFromEnum(Resource.food)] = INITIAL_FOOD_STOCKPILE;

    pile_reserves[@intFromEnum(Resource.coal)] = INITIAL_COAL_PILE_RESOURCE;
    pile_reserves[@intFromEnum(Resource.wood)] = INITIAL_WOOD_PILE_RESOURCE;
    pile_reserves[@intFromEnum(Resource.steel)] = INITIAL_STEEL_PILE_RESOURCE;
    pile_reserves[@intFromEnum(Resource.food)] = INITIAL_FOOD_PILE_RESOURCE;

    workers_assigned = .{ 0, 0, 0, 0 };
    selected_resource = null;
    hovered_resource = null;
    selected_generator = false;
    hovered_generator = false;

    buildings_count = 0;
    build_menu_open = false;
    research_menu_open = false;
    active_build_tab = .people;
    active_research_tab = .food;
    greenhouses_research_state = .available;
    greenhouses_research_progress = 0.0;
    coal_mine_research_state = .available;
    coal_mine_research_progress = 0.0;
    wood_shack_research_state = .available;
    wood_shack_research_progress = 0.0;
    steel_forge_research_state = .available;
    steel_forge_research_progress = 0.0;
    research_spinner_angle = 0.0;
    placing_building = null;
    selected_building = null;
    hovered_building = null;
    show_controls_dialog = false;
    is_paused = false;
    pause_menu_selected_idx = 0;

    citizen_mgr.init(@intCast(@min(STARTING_POPULATION, MAX_CITIZENS)));
    total_citizens = citizen_mgr.count;
    smoke_soa.init();
}

fn assignWorkers(res: Resource, delta: i32) void {
    if (delta > 0 and isPileDepleted(res)) return;
    citizen_mgr.assign(res, delta);
    workers_assigned[@intFromEnum(res)] = @intCast(citizen_mgr.getAssignedCount(res));
}

fn tryToggleGenerator() void {
    if (!generator_active) {
        // Need coal fuel to ignite
        const coal_idx = @intFromEnum(Resource.coal);
        if (stockpiles[coal_idx] <= 0.0) {
            fuel_warning_timer = 3.5;
            return;
        }
        generator_active = true;
    } else {
        generator_active = false;
    }
}

// ============================================================================
// IN-WORLD PILE SELECTION & UI HIT DETECTION
// ============================================================================

pub const PileUIBounds = struct {
    center_screen: rl.Vector2,
    badge_rect: rl.Rectangle,
    card_rect: ?rl.Rectangle,
    is_on_screen: bool,
};

pub const CachedSceneUI = struct {
    piles: [4]PileUIBounds,
    gen_base_screen: rl.Vector2,
    gen_base_on_screen: bool,
    gen_label_screen: rl.Vector2,
    gen_label_rect: rl.Rectangle,
    gen_label_on_screen: bool,
};

fn isPointInFrontOfCamera(pos: rl.Vector3, camera: rl.Camera3D) bool {
    const cam_dir = camera.target.subtract(camera.position);
    const to_pos = pos.subtract(camera.position);
    return (cam_dir.x * to_pos.x + cam_dir.y * to_pos.y + cam_dir.z * to_pos.z) > 0.1;
}

fn getBuildingDialogRect(b: Building, camera: rl.Camera3D, sw: f32, sh: f32) ?rl.Rectangle {
    const bldg_anchor = rl.Vector3{ .x = b.pos.x, .y = 3.8, .z = b.pos.z };
    if (!isPointInFrontOfCamera(bldg_anchor, camera)) return null;

    const anchor_screen = rl.getWorldToScreen(bldg_anchor, camera);
    if (anchor_screen.x < -120.0 or anchor_screen.x > sw + 120.0 or
        anchor_screen.y < -120.0 or anchor_screen.y > sh + 120.0)
    {
        return null;
    }

    const is_worker_facility = (b.btype == .greenhouse or b.btype == .lab or b.btype == .coal_mine or b.btype == .wood_shack or b.btype == .steel_forge);
    const card_w: f32 = 250.0;
    const card_h: f32 = if (is_worker_facility and b.state == .completed) 226.0 else 188.0;

    var cx = anchor_screen.x - card_w / 2.0;
    var cy = anchor_screen.y - card_h - 14.0;

    if (cy < 52.0) {
        cy = anchor_screen.y + 22.0;
    }

    cx = std.math.clamp(cx, 16.0, sw - card_w - 16.0);
    cy = std.math.clamp(cy, 52.0, sh - card_h - 36.0);

    return rl.Rectangle.init(cx, cy, card_w, card_h);
}

fn getGeneratorDialogRect(camera: rl.Camera3D, sw: f32, sh: f32) ?rl.Rectangle {
    const gen_anchor = rl.Vector3{ .x = 0.0, .y = 11.0, .z = 0.0 };
    if (!isPointInFrontOfCamera(gen_anchor, camera)) return null;

    const anchor_screen = rl.getWorldToScreen(gen_anchor, camera);
    if (anchor_screen.x < -120.0 or anchor_screen.x > sw + 120.0 or
        anchor_screen.y < -120.0 or anchor_screen.y > sh + 120.0)
    {
        return null;
    }

    const gen_panel_w: f32 = 270.0;
    const gen_panel_h: f32 = 215.0;

    var cx = anchor_screen.x - gen_panel_w / 2.0;
    var cy = anchor_screen.y - gen_panel_h - 14.0;

    if (cy < 52.0) {
        cy = anchor_screen.y + 22.0;
    }

    cx = std.math.clamp(cx, 16.0, sw - gen_panel_w - 16.0);
    cy = std.math.clamp(cy, 52.0, sh - gen_panel_h - 36.0);

    return rl.Rectangle.init(cx, cy, gen_panel_w, gen_panel_h);
}

fn computePileUIBounds(r: Resource, camera: rl.Camera3D, selected: ?Resource, sw: f32, sh: f32) PileUIBounds {
    if (isPileDepleted(r)) {
        return .{
            .center_screen = .{ .x = -9999.0, .y = -9999.0 },
            .badge_rect = rl.Rectangle.init(-9999.0, -9999.0, 0.0, 0.0),
            .card_rect = null,
            .is_on_screen = false,
        };
    }

    const p = r.position();
    const anchor = rl.Vector3{ .x = p.x, .y = PILE_LABEL_HEIGHT_OFFSET, .z = p.z };
    const in_front = isPointInFrontOfCamera(anchor, camera);
    const base_screen = rl.getWorldToScreen(.{ .x = p.x, .y = 0.5, .z = p.z }, camera);
    const badge_screen = rl.getWorldToScreen(anchor, camera);

    const on_screen = in_front and badge_screen.x >= -120 and badge_screen.x <= sw + 120 and
        badge_screen.y >= -120 and badge_screen.y <= sh + 120;

    const badge_w: f32 = 185.0;
    const badge_h: f32 = 28.0;
    const badge_rect = rl.Rectangle.init(
        badge_screen.x - badge_w / 2.0,
        badge_screen.y - badge_h / 2.0,
        badge_w,
        badge_h,
    );

    var card_rect: ?rl.Rectangle = null;
    if (selected == r) {
        const card_w: f32 = 260.0;
        const card_h: f32 = 130.0;
        var cx = badge_screen.x - card_w / 2.0;
        var cy = badge_screen.y - card_h - 14.0;

        if (cy < 52.0) {
            cy = badge_screen.y + 22.0;
        }

        cx = std.math.clamp(cx, 16.0, sw - card_w - 16.0);
        cy = std.math.clamp(cy, 52.0, sh - card_h - 36.0);

        card_rect = rl.Rectangle.init(cx, cy, card_w, card_h);
    }

    return .{
        .center_screen = base_screen,
        .badge_rect = badge_rect,
        .card_rect = card_rect,
        .is_on_screen = on_screen,
    };
}

fn computeCachedUI(camera: rl.Camera3D, selected: ?Resource) CachedSceneUI {
    const sw = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const sh = @as(f32, @floatFromInt(rl.getScreenHeight()));
    var res: CachedSceneUI = undefined;

    inline for (std.meta.tags(Resource)) |r| {
        res.piles[@intFromEnum(r)] = computePileUIBounds(r, camera, selected, sw, sh);
    }

    const gen_anchor = rl.Vector3{ .x = 0.0, .y = 12.0, .z = 0.0 };
    const gen_in_front = isPointInFrontOfCamera(gen_anchor, camera);
    const gen_base_screen = rl.getWorldToScreen(.{ .x = 0.0, .y = 2.0, .z = 0.0 }, camera);
    res.gen_base_screen = gen_base_screen;
    res.gen_base_on_screen = gen_in_front and gen_base_screen.x >= -100 and gen_base_screen.x <= sw + 100 and
        gen_base_screen.y >= -100 and gen_base_screen.y <= sh + 100;

    const gen_label_screen = rl.getWorldToScreen(gen_anchor, camera);
    res.gen_label_screen = gen_label_screen;
    const label_w: f32 = 190.0;
    const label_h: f32 = 28.0;
    res.gen_label_rect = rl.Rectangle.init(
        gen_label_screen.x - label_w / 2.0,
        gen_label_screen.y - label_h / 2.0,
        label_w,
        label_h,
    );
    res.gen_label_on_screen = gen_in_front and gen_label_screen.x > 30 and gen_label_screen.x < sw - 30 and
        gen_label_screen.y > 45 and gen_label_screen.y < sh - 35;

    return res;
}

fn isMouseOverPileTarget(r: Resource, mouse_pos: rl.Vector2, ui: PileUIBounds, ray: rl.Ray) bool {
    if (isPileDepleted(r)) return false;
    if (!ui.is_on_screen) return false;

    // 1. Hovering the floating badge
    if (rl.checkCollisionPointRec(mouse_pos, ui.badge_rect)) {
        return true;
    }

    // 2. 3D Ray Collision with exact 2x2 grid bounding box
    const pos = r.position();
    const pile_box = rl.BoundingBox{
        .min = .{ .x = pos.x - 2.0, .y = 0.0, .z = pos.z - 2.0 },
        .max = .{ .x = pos.x + 2.0, .y = 3.2, .z = pos.z + 2.0 },
    };
    const hit = rl.getRayCollisionBox(ray, pile_box);
    if (hit.hit) {
        return true;
    }

    // 3. Fallback: hovering near center screen projection
    const dist_to_base = rl.Vector2.distance(mouse_pos, ui.center_screen);
    if (dist_to_base < 35.0) {
        return true;
    }

    return false;
}

fn isMouseOverGeneratorTarget(mouse_pos: rl.Vector2, cached: CachedSceneUI, ray: rl.Ray) bool {
    // 1. Hovering the floating badge of the Heat Generator (height ~12.0)
    if (!selected_generator and cached.gen_label_on_screen and rl.checkCollisionPointRec(mouse_pos, cached.gen_label_rect)) {
        return true;
    }

    // 2. 3D Ray Collision with exact 4x4 grid bounding box (8x8 world units)
    const gen_box = rl.BoundingBox{
        .min = .{ .x = -4.0, .y = 0.0, .z = -4.0 },
        .max = .{ .x = 4.0, .y = 11.5, .z = 4.0 },
    };
    const gen_hit = rl.getRayCollisionBox(ray, gen_box);
    if (gen_hit.hit) {
        return true;
    }

    // 3. Fallback: hovering near center base projection
    if (cached.gen_base_on_screen) {
        if (rl.Vector2.distance(mouse_pos, cached.gen_base_screen) < 45.0) {
            return true;
        }
    }

    return false;
}

/// Query the current monitor refresh rate and apply it to raylib's frame limiter.
/// Automatically adapts when the game is moved between different displays (e.g. 60Hz laptop vs 160Hz gaming monitor).
pub fn updateMonitorRefreshRate(force: bool) void {
    if (LIMIT_FPS_TO_REFRESH_RATE) {
        const mon = rl.getCurrentMonitor();
        const raw_hz = rl.getMonitorRefreshRate(mon);
        const target_hz: i32 = if (raw_hz > 0) raw_hz else 60;
        if (force or target_hz != ACTIVE_FPS_LIMIT) {
            ACTIVE_FPS_LIMIT = target_hz;
            rl.setTargetFPS(target_hz);
            std.debug.print("[Display] Screen refresh rate detected: {d} Hz on monitor {d}\n", .{ target_hz, mon });
        }
    } else {
        if (force or TARGET_FPS != ACTIVE_FPS_LIMIT) {
            ACTIVE_FPS_LIMIT = TARGET_FPS;
            rl.setTargetFPS(TARGET_FPS);
        }
    }
}

// ============================================================================
// MAIN APPLICATION
// ============================================================================

pub fn main() !void {
    rl.setConfigFlags(.{
        .vsync_hint = ENABLE_VSYNC,
        .window_highdpi = true,
        .window_resizable = true,
    });

    rl.initWindow(1280, 720, "Frostpunk - First Settlement");
    defer rl.closeWindow();

    // Disable default ESC behavior so we can use it for our Pause Menu
    rl.setExitKey(.null);

    // Detect display refresh rate and limit FPS accordingly
    updateMonitorRefreshRate(true);

    initGame();

    // 3D Camera Setup (Isometric / Top-Down angle)
    var camera = rl.Camera3D{
        .position = CAMERA_DEFAULT_POSITION,
        .target = CAMERA_DEFAULT_TARGET,
        .up = .{ .x = 0.0, .y = 1.0, .z = 0.0 },
        .fovy = 45.0,
        .projection = .perspective,
    };

    var warm_count: i32 = 0;
    var cold_count: i32 = 0;
    var monitor_check_timer: f32 = 0.0;

    while (!rl.windowShouldClose() and !should_quit) {
        const dt = rl.getFrameTime();

        // Periodically verify monitor refresh rate (e.g. window dragged across 60Hz/160Hz monitors)
        monitor_check_timer += dt;
        if (monitor_check_timer >= 0.5) {
            monitor_check_timer = 0.0;
            updateMonitorRefreshRate(false);
        }

        // --------------------------------------------------------------------
        // PAUSE MENU / ESC Key handling
        // --------------------------------------------------------------------
        if (rl.isKeyPressed(.escape)) {
            if (show_controls_dialog) {
                show_controls_dialog = false;
                is_paused = false;
                pause_menu_selected_idx = 0;
            } else if (placing_building != null) {
                placing_building = null;
            } else if (build_menu_open) {
                build_menu_open = false;
            } else if (research_menu_open) {
                research_menu_open = false;
            } else if (selected_resource != null or selected_generator or selected_building != null) {
                selected_resource = null;
                selected_generator = false;
                selected_building = null;
            } else {
                is_paused = !is_paused;
                pause_menu_selected_idx = 0;
            }
        }

        // --------------------------------------------------------------------
        // GAMEPLAY INPUT & SIMULATION (Only when NOT paused)
        // --------------------------------------------------------------------
        var ground_hit: ?rl.Vector3 = null;
        var snapped_grid: ?GridCoord = null;
        var placement_pos: ?rl.Vector3 = null;
        var placement_check = PlacementCheck{ .valid = false, .reason = "" };
        const mouse_pos = rl.getMousePosition();

        if (!is_paused) {
            // Build Menu hotkey 'B'
            if (rl.isKeyPressed(.b)) {
                if (placing_building != null) {
                    placing_building = null;
                } else {
                    build_menu_open = !build_menu_open;
                    if (build_menu_open) {
                        research_menu_open = false;
                        selected_resource = null;
                        selected_generator = false;
                        selected_building = null;
                    }
                }
            }

            // Right-click cancels building placement
            if (placing_building != null and rl.isMouseButtonPressed(.right)) {
                placing_building = null;
            }

            // Toggle generator with Space or P
            if (rl.isKeyPressed(.space) or rl.isKeyPressed(.p)) {
                tryToggleGenerator();
            }

            // Reset camera view with R
            if (rl.isKeyPressed(.r)) {
                camera.position = CAMERA_DEFAULT_POSITION;
                camera.target = CAMERA_DEFAULT_TARGET;
            }

            // Camera Pan Controls (WASD / Arrow Keys)
            var pan_move = rl.Vector3.zero();
            if (rl.isKeyDown(.w) or rl.isKeyDown(.up)) pan_move.z -= 1.0;
            if (rl.isKeyDown(.s) or rl.isKeyDown(.down)) pan_move.z += 1.0;
            if (rl.isKeyDown(.a) or rl.isKeyDown(.left)) pan_move.x -= 1.0;
            if (rl.isKeyDown(.d) or rl.isKeyDown(.right)) pan_move.x += 1.0;

            if (pan_move.lengthSqr() > 0.0) {
                const norm = pan_move.scale(1.0 / pan_move.length());
                const move_step = norm.scale(CAMERA_PAN_SPEED * dt);
                camera.position = camera.position.add(move_step);
                camera.target = camera.target.add(move_step);
            }

            // Camera Drag with Right or Middle Mouse Button (only when not placing building)
            if (placing_building == null and (rl.isMouseButtonDown(.right) or rl.isMouseButtonDown(.middle))) {
                const mouse_delta = rl.getMouseDelta();
                const factor = 0.06;
                const drag_step = rl.Vector3{
                    .x = -mouse_delta.x * factor,
                    .y = 0.0,
                    .z = -mouse_delta.y * factor,
                };
                camera.position = camera.position.add(drag_step);
                camera.target = camera.target.add(drag_step);
            }

            // Camera Zoom (Mouse Wheel)
            const wheel = rl.getMouseWheelMove();
            if (wheel != 0.0) {
                const offset = camera.position.subtract(camera.target);
                var distance = offset.length();
                distance -= wheel * CAMERA_ZOOM_SPEED;
                distance = std.math.clamp(distance, CAMERA_MIN_DISTANCE, CAMERA_MAX_DISTANCE);
                const dir = offset.scale(1.0 / offset.length());
                camera.position = camera.target.add(dir.scale(distance));
            }

            // Keyboard shortcuts to assign/recall workers when a pile is selected:
            if (selected_resource) |sel| {
                if (isPileDepleted(sel)) {
                    selected_resource = null;
                } else if (rl.isKeyPressed(.equal) or rl.isKeyPressed(.kp_add) or rl.isKeyPressed(.up)) {
                    assignWorkers(sel, 1);
                } else if (rl.isKeyPressed(.minus) or rl.isKeyPressed(.kp_subtract) or rl.isKeyPressed(.down)) {
                    assignWorkers(sel, -1);
                } else if (rl.isKeyPressed(.c) or rl.isKeyPressed(.n)) {
                    assignWorkers(sel, -workers_assigned[@intFromEnum(sel)]);
                } else if (rl.isKeyPressed(.a) or rl.isKeyPressed(.m)) {
                    const assigned = workers_assigned[@intFromEnum(sel)];
                    assignWorkers(sel, @max(0, PILE_WORKER_CAP - assigned));
                } else if (rl.isKeyPressed(.delete) or rl.isKeyPressed(.backspace)) {
                    selected_resource = null;
                }
            }

            // Keyboard shortcuts to assign/recall workers when a Greenhouse or Lab is selected:
            if (selected_building) |s_bid| {
                if (s_bid < buildings_count and buildings[s_bid].state == .completed) {
                    if (buildings[s_bid].btype == .greenhouse) {
                        if (rl.isKeyPressed(.equal) or rl.isKeyPressed(.kp_add) or rl.isKeyPressed(.up)) {
                            assignGreenhouseWorkers(s_bid, 1);
                        } else if (rl.isKeyPressed(.minus) or rl.isKeyPressed(.kp_subtract) or rl.isKeyPressed(.down)) {
                            assignGreenhouseWorkers(s_bid, -1);
                        } else if (rl.isKeyPressed(.c) or rl.isKeyPressed(.n)) {
                            assignGreenhouseWorkers(s_bid, -buildings[s_bid].assigned_workers);
                        } else if (rl.isKeyPressed(.a) or rl.isKeyPressed(.m)) {
                            assignGreenhouseWorkers(s_bid, GREENHOUSE_CAPACITY);
                        }
                    } else if (buildings[s_bid].btype == .lab) {
                        if (rl.isKeyPressed(.equal) or rl.isKeyPressed(.kp_add) or rl.isKeyPressed(.up)) {
                            assignLabWorkers(s_bid, 1);
                        } else if (rl.isKeyPressed(.minus) or rl.isKeyPressed(.kp_subtract) or rl.isKeyPressed(.down)) {
                            assignLabWorkers(s_bid, -1);
                        } else if (rl.isKeyPressed(.c) or rl.isKeyPressed(.n)) {
                            assignLabWorkers(s_bid, -buildings[s_bid].assigned_workers);
                        } else if (rl.isKeyPressed(.a) or rl.isKeyPressed(.m)) {
                            assignLabWorkers(s_bid, LAB_CAPACITY);
                        }
                    } else if (buildings[s_bid].btype == .coal_mine) {
                        if (rl.isKeyPressed(.equal) or rl.isKeyPressed(.kp_add) or rl.isKeyPressed(.up)) {
                            assignCoalMineWorkers(s_bid, 1);
                        } else if (rl.isKeyPressed(.minus) or rl.isKeyPressed(.kp_subtract) or rl.isKeyPressed(.down)) {
                            assignCoalMineWorkers(s_bid, -1);
                        } else if (rl.isKeyPressed(.c) or rl.isKeyPressed(.n)) {
                            assignCoalMineWorkers(s_bid, -buildings[s_bid].assigned_workers);
                        } else if (rl.isKeyPressed(.a) or rl.isKeyPressed(.m)) {
                            assignCoalMineWorkers(s_bid, COAL_MINE_CAPACITY);
                        }
                    } else if (buildings[s_bid].btype == .wood_shack) {
                        if (rl.isKeyPressed(.equal) or rl.isKeyPressed(.kp_add) or rl.isKeyPressed(.up)) {
                            assignWoodShackWorkers(s_bid, 1);
                        } else if (rl.isKeyPressed(.minus) or rl.isKeyPressed(.kp_subtract) or rl.isKeyPressed(.down)) {
                            assignWoodShackWorkers(s_bid, -1);
                        } else if (rl.isKeyPressed(.c) or rl.isKeyPressed(.n)) {
                            assignWoodShackWorkers(s_bid, -buildings[s_bid].assigned_workers);
                        } else if (rl.isKeyPressed(.a) or rl.isKeyPressed(.m)) {
                            assignWoodShackWorkers(s_bid, WOOD_SHACK_CAPACITY);
                        }
                    } else if (buildings[s_bid].btype == .steel_forge) {
                        if (rl.isKeyPressed(.equal) or rl.isKeyPressed(.kp_add) or rl.isKeyPressed(.up)) {
                            assignSteelForgeWorkers(s_bid, 1);
                        } else if (rl.isKeyPressed(.minus) or rl.isKeyPressed(.kp_subtract) or rl.isKeyPressed(.down)) {
                            assignSteelForgeWorkers(s_bid, -1);
                        } else if (rl.isKeyPressed(.c) or rl.isKeyPressed(.n)) {
                            assignSteelForgeWorkers(s_bid, -buildings[s_bid].assigned_workers);
                        } else if (rl.isKeyPressed(.a) or rl.isKeyPressed(.m)) {
                            assignSteelForgeWorkers(s_bid, STEEL_FORGE_CAPACITY);
                        }
                    }
                }
            }

            // Screen & UI interaction coordinates
            const sw_f = @as(f32, @floatFromInt(rl.getScreenWidth()));
            const sh_f = @as(f32, @floatFromInt(rl.getScreenHeight()));

            const in_top_bar = mouse_pos.y < 48.0;

            const build_btn_rect = getBuildBtnRect(sh_f);
            const in_build_btn = rl.checkCollisionPointRec(mouse_pos, build_btn_rect);

            const research_btn_rect = getResearchBtnRect(sh_f);
            const in_research_btn = rl.checkCollisionPointRec(mouse_pos, research_btn_rect);

            const ctrl_btn_rect = getControlsBtnRect(sw_f, sh_f);
            const in_ctrl_btn = rl.checkCollisionPointRec(mouse_pos, ctrl_btn_rect);

            const strip_h: f32 = 148.0;
            const strip_y: f32 = sh_f - strip_h;
            const in_build_strip = build_menu_open and mouse_pos.y >= strip_y and mouse_pos.y <= sh_f;
            const in_research_strip = research_menu_open and mouse_pos.y >= strip_y and mouse_pos.y <= sh_f;

            var in_generator_dialog = false;
            if (selected_generator) {
                if (getGeneratorDialogRect(camera, sw_f, sh_f)) |g_rect| {
                    in_generator_dialog = rl.checkCollisionPointRec(mouse_pos, g_rect);
                }
            }

            var in_building_dialog = false;
            if (selected_building) |sbid| {
                if (sbid < buildings_count) {
                    if (getBuildingDialogRect(buildings[sbid], camera, sw_f, sh_f)) |b_rect| {
                        in_building_dialog = rl.checkCollisionPointRec(mouse_pos, b_rect);
                    }
                }
            }

            // Precompute scene 2D projections ONCE per frame
            const cached_ui = computeCachedUI(camera, selected_resource);

            // Check if mouse is inside the on-pile management card of the active pile
            var in_active_card: bool = false;
            if (selected_resource) |sel| {
                if (cached_ui.piles[@intFromEnum(sel)].card_rect) |cr| {
                    if (rl.checkCollisionPointRec(mouse_pos, cr)) {
                        in_active_card = true;
                    }
                }
            }

            const pop_pill_rect = getPopPillRect(rl.getScreenWidth());
            const pop_hovered = rl.checkCollisionPointRec(mouse_pos, pop_pill_rect);

            const in_ui = in_top_bar or in_generator_dialog or in_active_card or in_build_btn or in_research_btn or in_ctrl_btn or in_build_strip or in_research_strip or in_building_dialog;

            const ray = rl.getScreenToWorldRay(mouse_pos, camera);
            ground_hit = getMouseGroundIntersection(ray);
            if (placing_building) |btype| {
                if (ground_hit) |hit| {
                    const gw = btype.gridWidth();
                    const gl = btype.gridLength();
                    const snapped = worldToGrid(hit.x, hit.z, gw, gl);
                    snapped_grid = snapped;
                    placement_pos = gridToWorldCenter(snapped.gx, snapped.gz, gw, gl);
                    placement_check = canPlaceBuildingAtGrid(snapped.gx, snapped.gz, btype);
                } else {
                    snapped_grid = null;
                    placement_pos = null;
                    placement_check = .{ .valid = false, .reason = "Cursor off map" };
                }
            } else {
                snapped_grid = null;
                placement_pos = null;
            }

            // Detect hover over resource piles, Heat Generator & buildings
            hovered_resource = null;
            hovered_generator = false;
            hovered_building = null;

            if (placing_building == null and !in_ui) {
                inline for (std.meta.tags(Resource)) |r| {
                    if (isMouseOverPileTarget(r, mouse_pos, cached_ui.piles[@intFromEnum(r)], ray)) {
                        hovered_resource = r;
                    }
                }
                if (isMouseOverGeneratorTarget(mouse_pos, cached_ui, ray)) {
                    hovered_generator = true;
                }
                for (buildings[0..buildings_count]) |b| {
                    const gw_f = @as(f32, @floatFromInt(b.btype.gridWidth())) * GRID_CELL_SIZE;
                    const gl_f = @as(f32, @floatFromInt(b.btype.gridLength())) * GRID_CELL_SIZE;
                    const box = rl.BoundingBox{
                        .min = .{ .x = b.pos.x - gw_f * 0.5, .y = 0.0, .z = b.pos.z - gl_f * 0.5 },
                        .max = .{ .x = b.pos.x + gw_f * 0.5, .y = 3.6, .z = b.pos.z + gl_f * 0.5 },
                    };
                    const hit = rl.getRayCollisionBox(ray, box);
                    if (hit.hit) {
                        hovered_building = b.id;
                    }
                    // Also check collision against floating badge for completed Greenhouse, Lab, Coal Mine, Wood Shack & Steel Forge (when not selected)
                    if (selected_building != b.id and b.state == .completed and (b.btype == .greenhouse or b.btype == .lab or b.btype == .coal_mine or b.btype == .wood_shack or b.btype == .steel_forge)) {
                        const screen_pos = rl.getWorldToScreen(.{ .x = b.pos.x, .y = 3.8, .z = b.pos.z }, camera);
                        const badge_rect = rl.Rectangle.init(screen_pos.x - 175.0 / 2.0, screen_pos.y - 28.0 / 2.0, 175.0, 28.0);
                        if (rl.checkCollisionPointRec(mouse_pos, badge_rect)) {
                            hovered_building = b.id;
                        }
                        if (b.btype == .lab and isResearchActive()) {
                            const spinner_rect = rl.Rectangle.init(screen_pos.x - 22.0, badge_rect.y - 58.0, 44.0, 58.0);
                            if (rl.checkCollisionPointRec(mouse_pos, spinner_rect)) {
                                hovered_building = b.id;
                            }
                        }
                    }
                }
            }

            const in_res_cancel = research_menu_open and (
                (active_research_tab == .food and greenhouses_research_state == .researching and rl.checkCollisionPointRec(mouse_pos, getGreenhousesCancelBtnRect(strip_y))) or
                (active_research_tab == .resources and coal_mine_research_state == .researching and rl.checkCollisionPointRec(mouse_pos, getCoalMineCancelBtnRect(strip_y))) or
                (active_research_tab == .resources and wood_shack_research_state == .researching and rl.checkCollisionPointRec(mouse_pos, getWoodShackCancelBtnRect(strip_y))) or
                (active_research_tab == .resources and steel_forge_research_state == .researching and rl.checkCollisionPointRec(mouse_pos, getSteelForgeCancelBtnRect(strip_y)))
            );

            // Set cursor style
            if (placing_building != null) {
                rl.setMouseCursor(if (placement_check.valid) .crosshair else .not_allowed);
            } else if (hovered_resource != null or hovered_generator or hovered_building != null or in_build_btn or in_research_btn or in_ctrl_btn or pop_hovered or in_res_cancel) {
                rl.setMouseCursor(.pointing_hand);
            } else {
                rl.setMouseCursor(.default);
            }

            // Handle Left Mouse Click
            if (rl.isMouseButtonPressed(.left)) {
                if (placing_building) |btype| {
                    if (!in_top_bar and !in_build_btn and !in_research_btn and !in_ctrl_btn) {
                        if (snapped_grid) |snapped| {
                            if (placement_check.valid) {
                                stockpiles[@intFromEnum(Resource.wood)] -= btype.woodCost();
                                stockpiles[@intFromEnum(Resource.steel)] -= btype.steelCost();
                                if (buildings_count < MAX_BUILDINGS) {
                                    const center_pos = gridToWorldCenter(snapped.gx, snapped.gz, btype.gridWidth(), btype.gridLength());
                                    buildings[buildings_count] = .{
                                        .id = buildings_count,
                                        .btype = btype,
                                        .grid_x = snapped.gx,
                                        .grid_z = snapped.gz,
                                        .pos = center_pos,
                                        .state = .constructing,
                                        .progress = 0.0,
                                        .active_builders = 0,
                                        .is_warm = false,
                                        .assigned_workers = 0,
                                    };
                                    buildings_count += 1;
                                }
                                const keep_building = rl.isKeyDown(.left_shift) or rl.isKeyDown(.right_shift);
                                if (!keep_building or stockpiles[@intFromEnum(Resource.wood)] < btype.woodCost() or stockpiles[@intFromEnum(Resource.steel)] < btype.steelCost() or buildings_count >= MAX_BUILDINGS) {
                                    placing_building = null;
                                }
                            }
                        }
                    }
                } else {
                    if (in_ctrl_btn) {
                        is_paused = true;
                        show_controls_dialog = true;
                        build_menu_open = false;
                        research_menu_open = false;
                        placing_building = null;
                    } else if (in_build_btn) {
                        build_menu_open = !build_menu_open;
                        if (build_menu_open) {
                            research_menu_open = false;
                            selected_resource = null;
                            selected_generator = false;
                            selected_building = null;
                        }
                    } else if (in_research_btn) {
                        if (hasCompletedLab()) {
                            research_menu_open = !research_menu_open;
                            if (research_menu_open) {
                                build_menu_open = false;
                                selected_resource = null;
                                selected_generator = false;
                                selected_building = null;
                            }
                        }
                    } else if (in_build_strip) {
                        // Check close button [x]
                        const close_rect = rl.Rectangle.init(sw_f - 36.0, strip_y + 8.0, 24.0, 24.0);
                        if (rl.checkCollisionPointRec(mouse_pos, close_rect)) {
                            build_menu_open = false;
                        }
                        // Check Tabs
                        const tab_y = strip_y + 8.0;
                        const tab_w: f32 = 110.0;
                        const tab_h: f32 = 28.0;
                        const tab_people_rect = rl.Rectangle.init(16.0, tab_y, tab_w, tab_h);
                        const tab_food_rect = rl.Rectangle.init(134.0, tab_y, tab_w, tab_h);
                        const tab_science_rect = rl.Rectangle.init(252.0, tab_y, tab_w, tab_h);
                        const tab_res_rect = rl.Rectangle.init(370.0, tab_y, tab_w + 10, tab_h);
                        if (rl.checkCollisionPointRec(mouse_pos, tab_people_rect)) {
                            active_build_tab = .people;
                        } else if (rl.checkCollisionPointRec(mouse_pos, tab_food_rect)) {
                            active_build_tab = .food;
                        } else if (rl.checkCollisionPointRec(mouse_pos, tab_science_rect)) {
                            active_build_tab = .science;
                        } else if (rl.checkCollisionPointRec(mouse_pos, tab_res_rect)) {
                            active_build_tab = .resources;
                        }

                        // Check cards based on active tab
                        if (active_build_tab == .people) {
                            const house_card_rect = rl.Rectangle.init(16.0, strip_y + 44.0, 230.0, 92.0);
                            if (rl.checkCollisionPointRec(mouse_pos, house_card_rect)) {
                                if (stockpiles[@intFromEnum(Resource.wood)] >= BuildingType.house.woodCost()) {
                                    placing_building = .house;
                                    build_menu_open = false;
                                }
                            }
                        } else if (active_build_tab == .food) {
                            if (greenhouses_research_state == .completed) {
                                const gh_card_rect = rl.Rectangle.init(16.0, strip_y + 44.0, 250.0, 92.0);
                                if (rl.checkCollisionPointRec(mouse_pos, gh_card_rect)) {
                                    if (stockpiles[@intFromEnum(Resource.wood)] >= BuildingType.greenhouse.woodCost()) {
                                        placing_building = .greenhouse;
                                        build_menu_open = false;
                                    }
                                }
                            }
                        } else if (active_build_tab == .science) {
                            const lab_card_rect = rl.Rectangle.init(16.0, strip_y + 44.0, 240.0, 92.0);
                            if (rl.checkCollisionPointRec(mouse_pos, lab_card_rect)) {
                                if (stockpiles[@intFromEnum(Resource.wood)] >= BuildingType.lab.woodCost()) {
                                    placing_building = .lab;
                                    build_menu_open = false;
                                }
                            }
                        } else if (active_build_tab == .resources) {
                            if (coal_mine_research_state == .completed) {
                                const cm_card_rect = rl.Rectangle.init(16.0, strip_y + 44.0, 250.0, 92.0);
                                if (rl.checkCollisionPointRec(mouse_pos, cm_card_rect)) {
                                    if (stockpiles[@intFromEnum(Resource.wood)] >= BuildingType.coal_mine.woodCost()) {
                                        placing_building = .coal_mine;
                                        build_menu_open = false;
                                    }
                                }
                            }
                            if (wood_shack_research_state == .completed) {
                                const ws_card_rect = rl.Rectangle.init(286.0, strip_y + 44.0, 260.0, 92.0);
                                if (rl.checkCollisionPointRec(mouse_pos, ws_card_rect)) {
                                    if (stockpiles[@intFromEnum(Resource.wood)] >= BuildingType.wood_shack.woodCost() and
                                        stockpiles[@intFromEnum(Resource.steel)] >= BuildingType.wood_shack.steelCost()) {
                                        placing_building = .wood_shack;
                                        build_menu_open = false;
                                    }
                                }
                            }
                            if (steel_forge_research_state == .completed) {
                                const sf_card_rect = rl.Rectangle.init(556.0, strip_y + 44.0, 260.0, 92.0);
                                if (rl.checkCollisionPointRec(mouse_pos, sf_card_rect)) {
                                    if (stockpiles[@intFromEnum(Resource.wood)] >= BuildingType.steel_forge.woodCost() and
                                        stockpiles[@intFromEnum(Resource.steel)] >= BuildingType.steel_forge.steelCost()) {
                                        placing_building = .steel_forge;
                                        build_menu_open = false;
                                    }
                                }
                            }
                        }
                    } else if (in_research_strip) {
                        // Check close button [x]
                        const close_rect = rl.Rectangle.init(sw_f - 36.0, strip_y + 8.0, 24.0, 24.0);
                        if (rl.checkCollisionPointRec(mouse_pos, close_rect)) {
                            research_menu_open = false;
                        }
                        const tab_y = strip_y + 8.0;
                        const tab_w: f32 = 110.0;
                        const tab_h: f32 = 28.0;
                        const tab_tech_rect = rl.Rectangle.init(16.0, tab_y, tab_w, tab_h);
                        const tab_food_rect = rl.Rectangle.init(134.0, tab_y, tab_w, tab_h);
                        const tab_res_rect = rl.Rectangle.init(252.0, tab_y, tab_w, tab_h);
                        if (rl.checkCollisionPointRec(mouse_pos, tab_tech_rect)) {
                            active_research_tab = .technology;
                        } else if (rl.checkCollisionPointRec(mouse_pos, tab_food_rect)) {
                            active_research_tab = .food;
                        } else if (rl.checkCollisionPointRec(mouse_pos, tab_res_rect)) {
                            active_research_tab = .resources;
                        }

                        if (active_research_tab == .food) {
                            if (greenhouses_research_state == .available and !isResearchActive()) {
                                const gh_card_rect = getGreenhousesCardRect(strip_y);
                                if (rl.checkCollisionPointRec(mouse_pos, gh_card_rect)) {
                                    if (stockpiles[@intFromEnum(Resource.wood)] >= GREENHOUSES_RESEARCH_WOOD_COST and hasCompletedLab()) {
                                        stockpiles[@intFromEnum(Resource.wood)] -= GREENHOUSES_RESEARCH_WOOD_COST;
                                        greenhouses_research_state = .researching;
                                        greenhouses_research_progress = 0.0;
                                    }
                                }
                            } else if (greenhouses_research_state == .researching) {
                                const cancel_btn_rect = getGreenhousesCancelBtnRect(strip_y);
                                if (rl.checkCollisionPointRec(mouse_pos, cancel_btn_rect)) {
                                    cancelOngoingResearch();
                                }
                            }
                        } else if (active_research_tab == .resources) {
                            if (coal_mine_research_state == .available and !isResearchActive()) {
                                const cm_card_rect = getCoalMineCardRect(strip_y);
                                if (rl.checkCollisionPointRec(mouse_pos, cm_card_rect)) {
                                    if (stockpiles[@intFromEnum(Resource.wood)] >= COAL_MINE_RESEARCH_WOOD_COST and
                                        stockpiles[@intFromEnum(Resource.steel)] >= COAL_MINE_RESEARCH_STEEL_COST and
                                        hasCompletedLab()) {
                                        stockpiles[@intFromEnum(Resource.wood)] -= COAL_MINE_RESEARCH_WOOD_COST;
                                        stockpiles[@intFromEnum(Resource.steel)] -= COAL_MINE_RESEARCH_STEEL_COST;
                                        coal_mine_research_state = .researching;
                                        coal_mine_research_progress = 0.0;
                                    }
                                }
                            } else if (coal_mine_research_state == .researching) {
                                const cancel_btn_rect = getCoalMineCancelBtnRect(strip_y);
                                if (rl.checkCollisionPointRec(mouse_pos, cancel_btn_rect)) {
                                    cancelOngoingResearch();
                                }
                            }

                            if (wood_shack_research_state == .available and !isResearchActive()) {
                                const ws_card_rect = getWoodShackCardRect(strip_y);
                                if (rl.checkCollisionPointRec(mouse_pos, ws_card_rect)) {
                                    if (stockpiles[@intFromEnum(Resource.wood)] >= WOOD_SHACK_RESEARCH_WOOD_COST and
                                        stockpiles[@intFromEnum(Resource.steel)] >= WOOD_SHACK_RESEARCH_STEEL_COST and
                                        hasCompletedLab()) {
                                        stockpiles[@intFromEnum(Resource.wood)] -= WOOD_SHACK_RESEARCH_WOOD_COST;
                                        stockpiles[@intFromEnum(Resource.steel)] -= WOOD_SHACK_RESEARCH_STEEL_COST;
                                        wood_shack_research_state = .researching;
                                        wood_shack_research_progress = 0.0;
                                    }
                                }
                            } else if (wood_shack_research_state == .researching) {
                                const cancel_btn_rect = getWoodShackCancelBtnRect(strip_y);
                                if (rl.checkCollisionPointRec(mouse_pos, cancel_btn_rect)) {
                                    cancelOngoingResearch();
                                }
                            }

                            if (steel_forge_research_state == .available and !isResearchActive()) {
                                const sf_card_rect = getSteelForgeCardRect(strip_y);
                                if (rl.checkCollisionPointRec(mouse_pos, sf_card_rect)) {
                                    if (stockpiles[@intFromEnum(Resource.wood)] >= STEEL_FORGE_RESEARCH_WOOD_COST and
                                        stockpiles[@intFromEnum(Resource.steel)] >= STEEL_FORGE_RESEARCH_STEEL_COST and
                                        hasCompletedLab()) {
                                        stockpiles[@intFromEnum(Resource.wood)] -= STEEL_FORGE_RESEARCH_WOOD_COST;
                                        stockpiles[@intFromEnum(Resource.steel)] -= STEEL_FORGE_RESEARCH_STEEL_COST;
                                        steel_forge_research_state = .researching;
                                        steel_forge_research_progress = 0.0;
                                    }
                                }
                            } else if (steel_forge_research_state == .researching) {
                                const cancel_btn_rect = getSteelForgeCancelBtnRect(strip_y);
                                if (rl.checkCollisionPointRec(mouse_pos, cancel_btn_rect)) {
                                    cancelOngoingResearch();
                                }
                            }
                        }
                    } else if (!in_ui) {
                        var clicked_pile: ?Resource = null;
                        inline for (std.meta.tags(Resource)) |r| {
                            if (isMouseOverPileTarget(r, mouse_pos, cached_ui.piles[@intFromEnum(r)], ray)) {
                                clicked_pile = r;
                            }
                        }

                        if (clicked_pile) |p| {
                            selected_resource = p;
                            selected_generator = false;
                            selected_building = null;
                        } else if (isMouseOverGeneratorTarget(mouse_pos, cached_ui, ray)) {
                            selected_generator = true;
                            selected_resource = null;
                            selected_building = null;
                        } else if (hovered_building) |bid| {
                            selected_building = bid;
                            selected_resource = null;
                            selected_generator = false;
                        } else {
                            // Clicked empty ground: deselect all
                            selected_resource = null;
                            selected_generator = false;
                            selected_building = null;
                        }
                    }
                }
            }

            // ----------------------------------------------------------------
            // SIMULATION UPDATE
            // ----------------------------------------------------------------

            // Update warning timer
            if (fuel_warning_timer > 0.0) {
                fuel_warning_timer -= dt;
            }

            // Research progression (scales with total assigned lab workers across up to 4 labs)
            if (greenhouses_research_state == .researching) {
                const speed = getResearchSpeedMultiplier();
                if (speed > 0.0) {
                    greenhouses_research_progress += speed * dt;
                    if (greenhouses_research_progress >= GREENHOUSES_RESEARCH_DURATION) {
                        greenhouses_research_progress = GREENHOUSES_RESEARCH_DURATION;
                        greenhouses_research_state = .completed;
                    }
                }
            } else if (coal_mine_research_state == .researching) {
                const speed = getResearchSpeedMultiplier();
                if (speed > 0.0) {
                    coal_mine_research_progress += speed * dt;
                    if (coal_mine_research_progress >= COAL_MINE_RESEARCH_DURATION) {
                        coal_mine_research_progress = COAL_MINE_RESEARCH_DURATION;
                        coal_mine_research_state = .completed;
                    }
                }
            } else if (wood_shack_research_state == .researching) {
                const speed = getResearchSpeedMultiplier();
                if (speed > 0.0) {
                    wood_shack_research_progress += speed * dt;
                    if (wood_shack_research_progress >= WOOD_SHACK_RESEARCH_DURATION) {
                        wood_shack_research_progress = WOOD_SHACK_RESEARCH_DURATION;
                        wood_shack_research_state = .completed;
                    }
                }
            } else if (steel_forge_research_state == .researching) {
                const speed = getResearchSpeedMultiplier();
                if (speed > 0.0) {
                    steel_forge_research_progress += speed * dt;
                    if (steel_forge_research_progress >= STEEL_FORGE_RESEARCH_DURATION) {
                        steel_forge_research_progress = STEEL_FORGE_RESEARCH_DURATION;
                        steel_forge_research_state = .completed;
                    }
                }
            }

            // 1. Generator coal fuel consumption
            if (generator_active) {
                const coal_idx = @intFromEnum(Resource.coal);
                if (stockpiles[coal_idx] > 0.0) {
                    stockpiles[coal_idx] -= GENERATOR_COAL_DRAIN_PER_SEC * dt;
                    if (stockpiles[coal_idx] <= 0.0) {
                        stockpiles[coal_idx] = 0.0;
                        generator_active = false; // Out of fuel!
                        fuel_warning_timer = 4.0;
                    }
                } else {
                    stockpiles[coal_idx] = 0.0;
                    generator_active = false;
                    fuel_warning_timer = 4.0;
                }
            }

            // 2. Resource gathering from limited piles
            inline for (std.meta.tags(Resource)) |r| {
                const idx = @intFromEnum(r);
                const count = workers_assigned[idx];
                if (count > 0 and pile_reserves[idx] > 0.0) {
                    const gather_amount = @as(f32, @floatFromInt(count)) * r.gatherRate() * dt;
                    const actual_gathered = @min(gather_amount, pile_reserves[idx]);
                    pile_reserves[idx] -= actual_gathered;
                    stockpiles[idx] += actual_gathered;
                    if (pile_reserves[idx] <= 0.001) {
                        depletePile(r);
                    }
                }
            }

            // 2b. Greenhouse Food, Coal Mine Coal, Wood Shack Wood, and Steel Forge Steel Production
            for (buildings[0..buildings_count]) |*b| {
                if (b.state == .completed and b.btype == .greenhouse) {
                    if (b.assigned_workers > 0) {
                        const food_rate = @as(f32, @floatFromInt(b.assigned_workers)) * 1.0;
                        stockpiles[@intFromEnum(Resource.food)] += food_rate * dt;
                    }
                } else if (b.state == .completed and b.btype == .coal_mine) {
                    if (b.assigned_workers > 0) {
                        const coal_rate = @as(f32, @floatFromInt(b.assigned_workers)) * COAL_MINE_COAL_RATE_PER_WORKER_PER_SEC;
                        stockpiles[@intFromEnum(Resource.coal)] += coal_rate * dt;
                    }
                } else if (b.state == .completed and b.btype == .wood_shack) {
                    if (b.assigned_workers > 0) {
                        const wood_rate = @as(f32, @floatFromInt(b.assigned_workers)) * WOOD_SHACK_WOOD_RATE_PER_WORKER_PER_SEC;
                        stockpiles[@intFromEnum(Resource.wood)] += wood_rate * dt;
                    }
                } else if (b.state == .completed and b.btype == .steel_forge) {
                    if (b.assigned_workers > 0) {
                        const steel_rate = @as(f32, @floatFromInt(b.assigned_workers)) * STEEL_FORGE_STEEL_RATE_PER_WORKER_PER_SEC;
                        stockpiles[@intFromEnum(Resource.steel)] += steel_rate * dt;
                    }
                }
            }

            // 3. Citizens SIMD movement, wandering, and warmth calculation (Single pass SoA)
            const citizen_stats = citizen_mgr.update(dt, generator_active);
            warm_count = citizen_stats.warm;
            cold_count = citizen_stats.cold;

            // 4. Generator smoke/steam particles (SIMD SoA)
            smoke_soa.update(dt, generator_active);

            // 5. Building construction & dismantling simulation (idle workers)
            var idle_available: usize = citizen_mgr.getIdleCount();
            var b_idx: usize = 0;
            while (b_idx < buildings_count) {
                var b = &buildings[b_idx];
                const dist_to_gen_sq = b.pos.x * b.pos.x + b.pos.z * b.pos.z;
                b.is_warm = generator_active and (dist_to_gen_sq <= GENERATOR_HEAT_RADIUS * GENERATOR_HEAT_RADIUS);

                if (b.state == .constructing) {
                    const needed: usize = @intCast(b.btype.maxBuilders());
                    const assigned = @min(idle_available, needed);
                    b.active_builders = @intCast(assigned);
                    idle_available -= assigned;

                    if (b.active_builders > 0) {
                        // Progress speed: 10 workers -> 1.0 (20s), 5 workers -> 0.5 (40s), 0 workers -> 0.0
                        const speed_mult = @as(f32, @floatFromInt(b.active_builders)) / @as(f32, @floatFromInt(b.btype.maxBuilders()));
                        const progress_delta = (speed_mult / b.btype.baseBuildTime()) * dt;
                        b.progress += progress_delta;
                        if (b.progress >= 1.0) {
                            b.progress = 1.0;
                            b.state = .completed;
                            b.active_builders = 0;
                        }
                    }
                    b_idx += 1;
                } else if (b.state == .dismantling) {
                    const needed: usize = @intCast(b.btype.maxBuilders());
                    const assigned = @min(idle_available, needed);
                    b.active_builders = @intCast(assigned);
                    idle_available -= assigned;

                    if (b.active_builders > 0) {
                        const speed_mult = @as(f32, @floatFromInt(b.active_builders)) / @as(f32, @floatFromInt(b.btype.maxBuilders()));
                        const progress_delta = (speed_mult / b.btype.baseBuildTime()) * dt;
                        b.progress -= progress_delta;
                        if (b.progress <= 0.0) {
                            // Dismantling complete: return all resources used to build it
                            stockpiles[@intFromEnum(Resource.wood)] += b.btype.woodCost();
                            stockpiles[@intFromEnum(Resource.steel)] += b.btype.steelCost();
                            removeBuilding(b_idx);
                            if (!hasCompletedLab() and research_menu_open) {
                                research_menu_open = false;
                            }
                            continue;
                        }
                    }
                    b_idx += 1;
                } else {
                    b.active_builders = 0;
                    b_idx += 1;
                }
            }
        }

        // Cache UI for rendering HUD
        const current_cached_ui = computeCachedUI(camera, selected_resource);

        // --------------------------------------------------------------------
        // DRAWING / RENDERING
        // --------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        // 1. Clear background to snowy white
        rl.clearBackground(COLOR_SNOW_GROUND);

        // 2. 3D Scene Mode
        camera.begin();

        // Ground Plane (Snow landscape)
        rl.drawPlane(.{ .x = 0.0, .y = -0.01, .z = 0.0 }, .{ .x = 220.0, .y = 220.0 }, COLOR_SNOW_GROUND);

        // Heat Zone on Ground (Visible when Generator is ON)
        if (generator_active) {
            rl.drawCircle3D(.{ .x = 0, .y = 0.03, .z = 0 }, GENERATOR_HEAT_RADIUS, .{ .x = 1, .y = 0, .z = 0 }, 90.0, COLOR_HEAT_ZONE);
        }

        // --- Pass 1: Solid Geometries (Triangles Batch) ---
        // Heat Generator solids
        drawHeatGenerator(generator_active, selected_generator, hovered_generator);

        // Smoke / Steam Particles
        smoke_soa.draw();

        // Resource Piles solids
        drawResourcePiles(selected_resource, hovered_resource);

        // Buildings solids & Placement Ghost solid
        drawBuildingsSolids(placement_pos, placing_building, placement_check.valid, snapped_grid);

        // Citizen bodies (RL_TRIANGLES)
        for (0..citizen_mgr.count) |i| {
            const body_color = if (citizen_mgr.is_warm[i]) COLOR_CITIZEN_WARM else COLOR_CITIZEN_COLD;
            rl.drawCube(
                .{ .x = citizen_mgr.pos_x[i], .y = 0.45, .z = citizen_mgr.pos_z[i] },
                0.48,
                0.9,
                0.48,
                body_color,
            );
        }

        // Citizen heads (RL_TRIANGLES - low-poly sphere with 4 rings and 6 slices)
        for (0..citizen_mgr.count) |i| {
            const head_color = if (citizen_mgr.is_warm[i]) rl.Color.init(252, 220, 195, 255) else rl.Color.init(180, 208, 230, 255);
            rl.drawSphereEx(
                .{ .x = citizen_mgr.pos_x[i], .y = 1.05, .z = citizen_mgr.pos_z[i] },
                0.24,
                4,
                6,
                head_color,
            );
        }

        // --- Pass 2: Lines & Outlines (Lines Batch) ---
        // Concentric District Rings
        rl.drawCylinderWires(.{ .x = 0, .y = 0.01, .z = 0 }, 12.0, 12.0, 0.01, 64, COLOR_SNOW_RINGS);
        rl.drawCylinderWires(.{ .x = 0, .y = 0.01, .z = 0 }, 20.0, 20.0, 0.01, 64, COLOR_SNOW_RINGS);
        rl.drawCylinderWires(.{ .x = 0, .y = 0.01, .z = 0 }, 30.0, 30.0, 0.01, 64, COLOR_SNOW_RINGS);
        rl.drawCylinderWires(.{ .x = 0, .y = 0.01, .z = 0 }, 42.0, 42.0, 0.01, 64, COLOR_SNOW_RINGS);

        if (generator_active) {
            rl.drawCylinderWires(.{ .x = 0, .y = 0.05, .z = 0 }, GENERATOR_HEAT_RADIUS, GENERATOR_HEAT_RADIUS, 0.05, 64, COLOR_HEAT_ZONE_RING);
            rl.drawCylinderWires(.{ .x = 0, .y = 0.05, .z = 0 }, GENERATOR_HEAT_RADIUS * 0.5, GENERATOR_HEAT_RADIUS * 0.5, 0.04, 48, rl.Color.init(255, 175, 60, 110));
        }

        // Buildings wires & Placement Ghost wires
        drawBuildingsWires(selected_building, hovered_building, placement_pos, placing_building, placement_check.valid, snapped_grid);

        // Citizen wireframe accents
        for (0..citizen_mgr.count) |i| {
            rl.drawCubeWires(
                .{ .x = citizen_mgr.pos_x[i], .y = 0.45, .z = citizen_mgr.pos_z[i] },
                0.48,
                0.9,
                0.48,
                rl.Color.init(20, 25, 30, 60),
            );
        }

        camera.end();

        // 3. 2D HUD & Interactive Management UI
        drawHUD(warm_count, cold_count, current_cached_ui, camera, mouse_pos, placement_check);

        // 4. Modal Dialogs (Controls Dialog or Pause Menu)
        if (show_controls_dialog) {
            drawControlsDialog();
        } else if (is_paused) {
            drawPauseMenu();
        }
    }
}

// ============================================================================
// 3D DRAWING FUNCTIONS
// ============================================================================

fn drawHeatGenerator(active: bool, selected: bool, hovered: bool) void {
    const vent_color = if (active) COLOR_GENERATOR_LIT else COLOR_GENERATOR_UNLIT;

    // Selection & hover visual ground indicators (Solids)
    if (selected) {
        rl.drawCube(.{ .x = 0, .y = 0.03, .z = 0 }, 8.08, 0.05, 8.08, rl.Color.init(255, 180, 50, 45));
    } else if (hovered) {
        rl.drawCube(.{ .x = 0, .y = 0.03, .z = 0 }, 8.08, 0.05, 8.08, rl.Color.init(180, 220, 255, 35));
    }

    // --- Pass 1: Solid Geometries (Triangles Batch) ---
    // Base Tier 1: Wide base block (fits inside 4x4 grid footprint of 8.0 x 8.0)
    rl.drawCube(.{ .x = 0, .y = 0.5, .z = 0 }, 7.8, 1.0, 7.8, COLOR_GENERATOR_BASE);

    // Base Tier 2: Stepped platform
    rl.drawCube(.{ .x = 0, .y = 1.4, .z = 0 }, 5.8, 0.8, 5.8, rl.Color.init(50, 54, 62, 255));

    // Furnace Core Block (Cubic furnace chamber)
    rl.drawCube(.{ .x = 0, .y = 3.4, .z = 0 }, 4.4, 3.2, 4.4, COLOR_GENERATOR_BASE);

    // 4 Radiant Heat Vents (Glow orange when active)
    rl.drawCube(.{ .x = 0, .y = 3.4, .z = 2.22 }, 2.4, 1.6, 0.15, vent_color);
    rl.drawCube(.{ .x = 0, .y = 3.4, .z = -2.22 }, 2.4, 1.6, 0.15, vent_color);
    rl.drawCube(.{ .x = 2.22, .y = 3.4, .z = 0 }, 0.15, 1.6, 2.4, vent_color);
    rl.drawCube(.{ .x = -2.22, .y = 3.4, .z = 0 }, 0.15, 1.6, 2.4, vent_color);

    // Boiler Drum (Sphere atop furnace block)
    rl.drawSphereEx(.{ .x = 0, .y = 5.8, .z = 0 }, 2.3, 8, 8, rl.Color.init(65, 70, 80, 255));

    // Chimney Stack (Cylinder)
    rl.drawCylinder(.{ .x = 0, .y = 7.0, .z = 0 }, 1.15, 1.35, 4.2, 16, rl.Color.init(42, 45, 52, 255));

    // Chimney Rim / Brass Crown
    const crown_color = if (active) rl.Color.init(245, 165, 35, 255) else rl.Color.init(95, 100, 110, 255);
    rl.drawCylinder(.{ .x = 0, .y = 11.1, .z = 0 }, 1.38, 1.38, 0.35, 16, crown_color);

    // --- Pass 2: Wire Outlines & Rings (Lines Batch) ---
    if (selected) {
        rl.drawCubeWires(.{ .x = 0, .y = 0.06, .z = 0 }, 8.08, 0.12, 8.08, rl.Color.gold);
    } else if (hovered) {
        rl.drawCubeWires(.{ .x = 0, .y = 0.05, .z = 0 }, 8.08, 0.08, 8.08, rl.Color.init(180, 220, 255, 180));
    }

    rl.drawCubeWires(.{ .x = 0, .y = 0.5, .z = 0 }, 7.8, 1.0, 7.8, rl.Color.init(20, 22, 26, 255));
    rl.drawCubeWires(.{ .x = 0, .y = 1.4, .z = 0 }, 5.8, 0.8, 5.8, rl.Color.init(25, 28, 32, 255));
    rl.drawCubeWires(.{ .x = 0, .y = 3.4, .z = 0 }, 4.4, 3.2, 4.4, rl.Color.init(18, 20, 24, 255));
    rl.drawSphereWires(.{ .x = 0, .y = 5.8, .z = 0 }, 2.32, 8, 8, rl.Color.init(28, 30, 36, 180));
    rl.drawCylinderWires(.{ .x = 0, .y = 7.0, .z = 0 }, 1.15, 1.35, 4.2, 8, rl.Color.init(22, 24, 28, 255));
}

fn drawResourcePiles(selected: ?Resource, hovered: ?Resource) void {
    // --- Pass 1: Solid Geometries (Triangles Batch) ---
    // Selection & hover visual ground indicators (2x2 grid footprint = 4.0 x 4.0)
    inline for (std.meta.tags(Resource)) |r| {
        if (isPileActive(r)) {
            const pos = r.position();
            if (selected == r) {
                rl.drawCube(.{ .x = pos.x, .y = 0.03, .z = pos.z }, 4.08, 0.05, 4.08, rl.Color.init(255, 205, 50, 50));
            } else if (hovered == r) {
                rl.drawCube(.{ .x = pos.x, .y = 0.03, .z = pos.z }, 4.08, 0.05, 4.08, rl.Color.init(180, 220, 255, 40));
            }
        }
    }

    // 1. COAL PILE (Solids)
    if (isPileActive(.coal)) {
        const pos = COAL_PILE_POSITION;
        rl.drawCube(.{ .x = pos.x, .y = 1.1, .z = pos.z }, 3.0, 2.2, 3.0, COLOR_COAL_PILE);
        rl.drawCube(.{ .x = pos.x + 1.1, .y = 0.8, .z = pos.z + 0.8 }, 1.9, 1.6, 1.9, rl.Color.init(38, 38, 44, 255));
        rl.drawCube(.{ .x = pos.x - 1.0, .y = 0.7, .z = pos.z - 0.8 }, 1.8, 1.4, 1.8, rl.Color.init(44, 44, 52, 255));
        rl.drawCube(.{ .x = pos.x + 0.8, .y = 0.6, .z = pos.z - 1.0 }, 1.5, 1.2, 1.5, rl.Color.init(32, 32, 38, 255));
        rl.drawCube(.{ .x = pos.x - 0.8, .y = 0.5, .z = pos.z + 1.0 }, 1.4, 1.0, 1.4, rl.Color.init(48, 48, 56, 255));
        rl.drawCube(.{ .x = pos.x + 0.1, .y = 2.4, .z = pos.z }, 1.4, 0.9, 1.4, rl.Color.init(22, 22, 26, 255));
    }

    // 2. WOOD PILE (Solids - fits inside 2x2 grid footprint)
    if (isPileActive(.wood)) {
        const pos = WOOD_PILE_POSITION;
        rl.drawCube(.{ .x = pos.x - 1.1, .y = 0.45, .z = pos.z }, 0.9, 0.9, 3.8, COLOR_WOOD_PILE);
        rl.drawCube(.{ .x = pos.x, .y = 0.45, .z = pos.z }, 0.9, 0.9, 3.8, COLOR_WOOD_PILE);
        rl.drawCube(.{ .x = pos.x + 1.1, .y = 0.45, .z = pos.z }, 0.9, 0.9, 3.8, COLOR_WOOD_PILE);
        rl.drawCube(.{ .x = pos.x - 0.55, .y = 1.3, .z = pos.z }, 0.9, 0.85, 3.6, rl.Color.init(162, 102, 58, 255));
        rl.drawCube(.{ .x = pos.x + 0.55, .y = 1.3, .z = pos.z }, 0.9, 0.85, 3.6, rl.Color.init(162, 102, 58, 255));
        rl.drawCube(.{ .x = pos.x, .y = 2.1, .z = pos.z }, 0.9, 0.8, 3.4, rl.Color.init(178, 115, 68, 255));
    }

    // 3. STEEL PILE (Solids - fits inside 2x2 grid footprint)
    if (isPileActive(.steel)) {
        const pos = STEEL_PILE_POSITION;
        rl.drawCube(.{ .x = pos.x, .y = 0.45, .z = pos.z - 0.9 }, 3.8, 0.85, 1.1, COLOR_STEEL_PILE);
        rl.drawCube(.{ .x = pos.x, .y = 0.45, .z = pos.z + 0.9 }, 3.8, 0.85, 1.1, COLOR_STEEL_PILE);
        rl.drawCube(.{ .x = pos.x - 1.1, .y = 1.25, .z = pos.z }, 1.1, 0.75, 3.4, rl.Color.init(168, 185, 205, 255));
        rl.drawCube(.{ .x = pos.x + 1.1, .y = 1.25, .z = pos.z }, 1.1, 0.75, 3.4, rl.Color.init(168, 185, 205, 255));
        rl.drawCube(.{ .x = pos.x, .y = 1.85, .z = pos.z }, 2.8, 0.5, 2.4, rl.Color.init(190, 208, 226, 255));
        rl.drawCube(.{ .x = pos.x + 1.2, .y = 0.65, .z = pos.z + 1.2 }, 1.1, 1.1, 1.1, rl.Color.init(130, 145, 165, 255));
    }

    // 4. FOOD CACHE (Solids - fits inside 2x2 grid footprint)
    if (isPileActive(.food)) {
        const pos = FOOD_PILE_POSITION;
        rl.drawCube(.{ .x = pos.x - 0.9, .y = 0.95, .z = pos.z - 0.7 }, 1.8, 1.9, 1.8, COLOR_FOOD_PILE);
        rl.drawCube(.{ .x = pos.x + 0.9, .y = 0.85, .z = pos.z + 0.7 }, 1.6, 1.7, 1.6, rl.Color.init(180, 50, 40, 255));
        rl.drawCylinder(.{ .x = pos.x + 1.1, .y = 0.0, .z = pos.z - 1.0 }, 0.6, 0.6, 1.6, 12, rl.Color.init(115, 82, 58, 255));
        rl.drawCylinder(.{ .x = pos.x - 1.0, .y = 0.0, .z = pos.z + 1.1 }, 0.6, 0.6, 1.6, 12, rl.Color.init(115, 82, 58, 255));
        rl.drawSphereEx(.{ .x = pos.x - 0.9, .y = 2.2, .z = pos.z - 0.7 }, 0.55, 6, 6, rl.Color.init(215, 185, 145, 255));
    }

    // --- Pass 2: Wire Outlines & Indicators (Lines Batch) ---
    inline for (std.meta.tags(Resource)) |r| {
        if (isPileActive(r)) {
            const pos = r.position();
            if (selected == r) {
                rl.drawCubeWires(.{ .x = pos.x, .y = 0.06, .z = pos.z }, 4.08, 0.12, 4.08, rl.Color.gold);
            } else if (hovered == r) {
                rl.drawCubeWires(.{ .x = pos.x, .y = 0.05, .z = pos.z }, 4.08, 0.08, 4.08, rl.Color.init(200, 220, 255, 180));
            }
        }
    }

    // Coal wires
    if (isPileActive(.coal)) {
        const pos = COAL_PILE_POSITION;
        rl.drawCubeWires(.{ .x = pos.x, .y = 1.1, .z = pos.z }, 3.0, 2.2, 3.0, rl.Color.init(10, 10, 14, 255));
    }

    // Wood wires
    if (isPileActive(.wood)) {
        const pos = WOOD_PILE_POSITION;
        rl.drawCubeWires(.{ .x = pos.x - 1.1, .y = 0.45, .z = pos.z }, 0.9, 0.9, 3.8, rl.Color.init(80, 45, 20, 255));
        rl.drawCubeWires(.{ .x = pos.x, .y = 0.45, .z = pos.z }, 0.9, 0.9, 3.8, rl.Color.init(80, 45, 20, 255));
        rl.drawCubeWires(.{ .x = pos.x + 1.1, .y = 0.45, .z = pos.z }, 0.9, 0.9, 3.8, rl.Color.init(80, 45, 20, 255));
        rl.drawCubeWires(.{ .x = pos.x, .y = 2.1, .z = pos.z }, 0.9, 0.8, 3.4, rl.Color.init(90, 55, 25, 255));
    }

    // Steel wires
    if (isPileActive(.steel)) {
        const pos = STEEL_PILE_POSITION;
        rl.drawCubeWires(.{ .x = pos.x, .y = 0.45, .z = pos.z - 0.9 }, 3.8, 0.85, 1.1, rl.Color.init(80, 95, 110, 255));
        rl.drawCubeWires(.{ .x = pos.x, .y = 0.45, .z = pos.z + 0.9 }, 3.8, 0.85, 1.1, rl.Color.init(80, 95, 110, 255));
        rl.drawCubeWires(.{ .x = pos.x, .y = 1.85, .z = pos.z }, 2.8, 0.5, 2.4, rl.Color.init(100, 115, 130, 255));
    }

    // Food wires
    if (isPileActive(.food)) {
        const pos = FOOD_PILE_POSITION;
        rl.drawCubeWires(.{ .x = pos.x - 0.9, .y = 0.95, .z = pos.z - 0.7 }, 1.9, 1.9, 1.9, rl.Color.init(100, 25, 20, 255));
        rl.drawCubeWires(.{ .x = pos.x + 0.9, .y = 0.85, .z = pos.z + 0.7 }, 1.7, 1.7, 1.7, rl.Color.init(90, 20, 18, 255));
    }
}

fn drawBlueprintGrid(gx: i32, gz: i32, gw: i32, gl: i32) void {
    const s = GRID_CELL_SIZE;
    const margin: i32 = 8;
    const min_gx = gx - margin;
    const max_gx = gx + gw + margin;
    const min_gz = gz - margin;
    const max_gz = gz + gl + margin;

    const min_x = @as(f32, @floatFromInt(min_gx)) * s;
    const max_x = @as(f32, @floatFromInt(max_gx)) * s;
    const min_z = @as(f32, @floatFromInt(min_gz)) * s;
    const max_z = @as(f32, @floatFromInt(max_gz)) * s;

    const grid_color = rl.Color.init(125, 155, 185, 75);

    var ix = min_gx;
    while (ix <= max_gx) : (ix += 1) {
        const x = @as(f32, @floatFromInt(ix)) * s;
        rl.drawLine3D(.{ .x = x, .y = 0.02, .z = min_z }, .{ .x = x, .y = 0.02, .z = max_z }, grid_color);
    }

    var iz = min_gz;
    while (iz <= max_gz) : (iz += 1) {
        const z = @as(f32, @floatFromInt(iz)) * s;
        rl.drawLine3D(.{ .x = min_x, .y = 0.02, .z = z }, .{ .x = max_x, .y = 0.02, .z = z }, grid_color);
    }
}

fn drawBuildingsSolids(cand_pos: ?rl.Vector3, placing: ?BuildingType, can_place: bool, snapped_grid: ?GridCoord) void {
    for (buildings[0..buildings_count]) |b| {
        if (b.btype == .lab) {
            if (b.state == .constructing or b.state == .dismantling) {
                const scaf_col = if (b.state == .dismantling) COLOR_DISMANTLE_SCAFFOLD else COLOR_SCAFFOLDING;
                // Foundation slab (5.8 x 0.38 x 5.8)
                rl.drawCube(.{ .x = b.pos.x, .y = 0.19, .z = b.pos.z }, 5.8, 0.38, 5.8, scaf_col);

                // 4 corner timber scaffolding posts (height rises with progress)
                const post_h = @max(0.6, 3.4 * b.progress);
                rl.drawCube(.{ .x = b.pos.x - 2.6, .y = post_h / 2.0, .z = b.pos.z - 2.6 }, 0.4, post_h, 0.4, COLOR_WOOD_PILE);
                rl.drawCube(.{ .x = b.pos.x + 2.6, .y = post_h / 2.0, .z = b.pos.z - 2.6 }, 0.4, post_h, 0.4, COLOR_WOOD_PILE);
                rl.drawCube(.{ .x = b.pos.x - 2.6, .y = post_h / 2.0, .z = b.pos.z + 2.6 }, 0.4, post_h, 0.4, COLOR_WOOD_PILE);
                rl.drawCube(.{ .x = b.pos.x + 2.6, .y = post_h / 2.0, .z = b.pos.z + 2.6 }, 0.4, post_h, 0.4, COLOR_WOOD_PILE);

                // Partial walls rising with progress
                const wall_h = 2.2 * b.progress;
                if (wall_h > 0.15) {
                    rl.drawCube(.{ .x = b.pos.x, .y = 0.38 + wall_h / 2.0, .z = b.pos.z }, 5.4, wall_h, 5.4, COLOR_LAB_WALLS);
                }
            } else {
                // Completed Lab (3x3 footprint)
                // Base foundation (5.8 x 0.38 x 5.8)
                rl.drawCube(.{ .x = b.pos.x, .y = 0.19, .z = b.pos.z }, 5.8, 0.38, 5.8, rl.Color.init(38, 44, 52, 255));
                // Main masonry walls (5.4 x 2.2 x 5.4)
                rl.drawCube(.{ .x = b.pos.x, .y = 1.48, .z = b.pos.z }, 5.4, 2.2, 5.4, COLOR_LAB_WALLS);
                // Flat roof trim (5.7 x 0.35 x 5.7)
                rl.drawCube(.{ .x = b.pos.x, .y = 2.75, .z = b.pos.z }, 5.7, 0.35, 5.7, COLOR_LAB_ROOF);
                // Central glass observatory dome / skylight (2.8 x 1.1 x 2.8)
                rl.drawCube(.{ .x = b.pos.x, .y = 3.48, .z = b.pos.z }, 2.8, 1.1, 2.8, COLOR_LAB_DOME);
                // Chemical exhaust chimney pipe
                rl.drawCube(.{ .x = b.pos.x + 1.8, .y = 3.6, .z = b.pos.z - 1.8 }, 0.5, 2.0, 0.5, rl.Color.init(45, 52, 60, 255));
                // Double entry door
                rl.drawCube(.{ .x = b.pos.x, .y = 0.9, .z = b.pos.z + 2.72 }, 1.2, 1.45, 0.12, rl.Color.init(28, 36, 44, 255));
                // Glowing observation windows
                const win_glow = if (b.is_warm) rl.Color.init(120, 230, 255, 255) else rl.Color.init(70, 140, 180, 255);
                rl.drawCube(.{ .x = b.pos.x - 2.72, .y = 1.5, .z = b.pos.z }, 0.12, 0.9, 2.2, win_glow);
                rl.drawCube(.{ .x = b.pos.x + 2.72, .y = 1.5, .z = b.pos.z }, 0.12, 0.9, 2.2, win_glow);
            }
        } else if (b.btype == .greenhouse) {
            const scaf_col = if (b.state == .dismantling) COLOR_DISMANTLE_SCAFFOLD else COLOR_SCAFFOLDING;
            if (b.state == .constructing or b.state == .dismantling) {
                // Foundation slab (3.84 x 0.36 x 7.84)
                rl.drawCube(.{ .x = b.pos.x, .y = 0.18, .z = b.pos.z }, 3.84, 0.36, 7.84, scaf_col);

                // 6 scaffolding timber posts
                const post_h = @max(0.6, 3.2 * b.progress);
                rl.drawCube(.{ .x = b.pos.x - 1.65, .y = post_h / 2.0, .z = b.pos.z - 3.65 }, 0.35, post_h, 0.35, COLOR_WOOD_PILE);
                rl.drawCube(.{ .x = b.pos.x + 1.65, .y = post_h / 2.0, .z = b.pos.z - 3.65 }, 0.35, post_h, 0.35, COLOR_WOOD_PILE);
                rl.drawCube(.{ .x = b.pos.x - 1.65, .y = post_h / 2.0, .z = b.pos.z }, 0.35, post_h, 0.35, COLOR_WOOD_PILE);
                rl.drawCube(.{ .x = b.pos.x + 1.65, .y = post_h / 2.0, .z = b.pos.z }, 0.35, post_h, 0.35, COLOR_WOOD_PILE);
                rl.drawCube(.{ .x = b.pos.x - 1.65, .y = post_h / 2.0, .z = b.pos.z + 3.65 }, 0.35, post_h, 0.35, COLOR_WOOD_PILE);
                rl.drawCube(.{ .x = b.pos.x + 1.65, .y = post_h / 2.0, .z = b.pos.z + 3.65 }, 0.35, post_h, 0.35, COLOR_WOOD_PILE);

                // Partial rising walls
                const wall_h = 2.0 * b.progress;
                if (wall_h > 0.15) {
                    rl.drawCube(.{ .x = b.pos.x, .y = 0.36 + wall_h / 2.0, .z = b.pos.z }, 3.6, wall_h, 7.6, COLOR_GREENHOUSE_WALLS);
                }
            } else {
                // Completed Greenhouse (2x4 footprint)
                // Base foundation (3.84 x 0.36 x 7.84)
                rl.drawCube(.{ .x = b.pos.x, .y = 0.18, .z = b.pos.z }, 3.84, 0.36, 7.84, rl.Color.init(40, 46, 42, 255));
                // Lower timber skirting (3.68 x 0.5 x 7.68)
                rl.drawCube(.{ .x = b.pos.x, .y = 0.61, .z = b.pos.z }, 3.68, 0.5, 7.68, COLOR_GREENHOUSE_WALLS);
                // Glass walls (3.5 x 1.4 x 7.5)
                rl.drawCube(.{ .x = b.pos.x, .y = 1.56, .z = b.pos.z }, 3.5, 1.4, 7.5, COLOR_GREENHOUSE_GLASS);
                // Interior glowing crop planter beds (2.6 x 0.35 x 6.6)
                rl.drawCube(.{ .x = b.pos.x, .y = 0.95, .z = b.pos.z }, 2.6, 0.35, 6.6, COLOR_GREENHOUSE_CROPS);
                // Pitched glass canopy roof (3.68 x 0.65 x 7.68)
                rl.drawCube(.{ .x = b.pos.x, .y = 2.58, .z = b.pos.z }, 3.68, 0.65, 7.68, COLOR_GREENHOUSE_ROOF);
                // Top ridge beam (1.2 x 0.22 x 7.68)
                rl.drawCube(.{ .x = b.pos.x, .y = 2.95, .z = b.pos.z }, 1.2, 0.22, 7.68, COLOR_GREENHOUSE_WALLS);
                // Structural frame ribs
                rl.drawCube(.{ .x = b.pos.x, .y = 1.6, .z = b.pos.z - 2.5 }, 3.68, 1.6, 0.2, COLOR_GREENHOUSE_WALLS);
                rl.drawCube(.{ .x = b.pos.x, .y = 1.6, .z = b.pos.z }, 3.68, 1.6, 0.2, COLOR_GREENHOUSE_WALLS);
                rl.drawCube(.{ .x = b.pos.x, .y = 1.6, .z = b.pos.z + 2.5 }, 3.68, 1.6, 0.2, COLOR_GREENHOUSE_WALLS);
                // Front and back entrance doors
                rl.drawCube(.{ .x = b.pos.x, .y = 0.88, .z = b.pos.z + 3.82 }, 0.95, 1.35, 0.12, rl.Color.init(32, 55, 45, 255));
                rl.drawCube(.{ .x = b.pos.x, .y = 0.88, .z = b.pos.z - 3.82 }, 0.95, 1.35, 0.12, rl.Color.init(32, 55, 45, 255));
            }
        } else if (b.btype == .coal_mine) {
            const scaf_col = if (b.state == .dismantling) COLOR_DISMANTLE_SCAFFOLD else COLOR_SCAFFOLDING;
            if (b.state == .constructing or b.state == .dismantling) {
                // Foundation slab (7.84 x 0.40 x 7.84)
                rl.drawCube(.{ .x = b.pos.x, .y = 0.20, .z = b.pos.z }, 7.84, 0.40, 7.84, scaf_col);

                // 8 scaffolding timber posts around 4x4 perimeter
                const post_h = @max(0.6, 4.5 * b.progress);
                rl.drawCube(.{ .x = b.pos.x - 3.5, .y = post_h / 2.0, .z = b.pos.z - 3.5 }, 0.4, post_h, 0.4, COLOR_WOOD_PILE);
                rl.drawCube(.{ .x = b.pos.x + 3.5, .y = post_h / 2.0, .z = b.pos.z - 3.5 }, 0.4, post_h, 0.4, COLOR_WOOD_PILE);
                rl.drawCube(.{ .x = b.pos.x - 3.5, .y = post_h / 2.0, .z = b.pos.z + 3.5 }, 0.4, post_h, 0.4, COLOR_WOOD_PILE);
                rl.drawCube(.{ .x = b.pos.x + 3.5, .y = post_h / 2.0, .z = b.pos.z + 3.5 }, 0.4, post_h, 0.4, COLOR_WOOD_PILE);
                rl.drawCube(.{ .x = b.pos.x, .y = post_h / 2.0, .z = b.pos.z - 3.5 }, 0.4, post_h, 0.4, COLOR_WOOD_PILE);
                rl.drawCube(.{ .x = b.pos.x, .y = post_h / 2.0, .z = b.pos.z + 3.5 }, 0.4, post_h, 0.4, COLOR_WOOD_PILE);
                rl.drawCube(.{ .x = b.pos.x - 3.5, .y = post_h / 2.0, .z = b.pos.z }, 0.4, post_h, 0.4, COLOR_WOOD_PILE);
                rl.drawCube(.{ .x = b.pos.x + 3.5, .y = post_h / 2.0, .z = b.pos.z }, 0.4, post_h, 0.4, COLOR_WOOD_PILE);

                // Partial rising engine house walls
                const wall_h = 2.4 * b.progress;
                if (wall_h > 0.15) {
                    rl.drawCube(.{ .x = b.pos.x + 1.8, .y = 0.40 + wall_h / 2.0, .z = b.pos.z }, 3.4, wall_h, 5.8, COLOR_COAL_MINE_WALLS);
                }
            } else {
                // Completed Coal Mine (4x4 footprint)
                // Heavy reinforced stone foundation (7.84 x 0.40 x 7.84)
                rl.drawCube(.{ .x = b.pos.x, .y = 0.20, .z = b.pos.z }, 7.84, 0.40, 7.84, COLOR_COAL_MINE_FOUNDATION);

                // Mine Shaft Entrance Pit on left side
                rl.drawCube(.{ .x = b.pos.x - 1.6, .y = 0.41, .z = b.pos.z - 0.2 }, 3.4, 0.05, 3.4, rl.Color.init(15, 15, 18, 255));
                rl.drawCube(.{ .x = b.pos.x - 1.6, .y = 0.43, .z = b.pos.z - 0.2 }, 3.1, 0.04, 3.1, rl.Color.init(8, 8, 10, 255));

                // Headframe / Pithead Winding Tower (4 heavy timber/steel columns over the shaft)
                const tower_h: f32 = 4.6;
                rl.drawCube(.{ .x = b.pos.x - 3.1, .y = tower_h / 2.0, .z = b.pos.z - 1.7 }, 0.42, tower_h, 0.42, COLOR_COAL_MINE_HEADFRAME);
                rl.drawCube(.{ .x = b.pos.x - 0.1, .y = tower_h / 2.0, .z = b.pos.z - 1.7 }, 0.42, tower_h, 0.42, COLOR_COAL_MINE_HEADFRAME);
                rl.drawCube(.{ .x = b.pos.x - 3.1, .y = tower_h / 2.0, .z = b.pos.z + 1.3 }, 0.42, tower_h, 0.42, COLOR_COAL_MINE_HEADFRAME);
                rl.drawCube(.{ .x = b.pos.x - 0.1, .y = tower_h / 2.0, .z = b.pos.z + 1.3 }, 0.42, tower_h, 0.42, COLOR_COAL_MINE_HEADFRAME);

                // Diagonal bracing struts
                rl.drawCube(.{ .x = b.pos.x - 1.6, .y = 2.4, .z = b.pos.z - 1.7 }, 3.0, 0.28, 0.28, COLOR_COAL_MINE_HEADFRAME);
                rl.drawCube(.{ .x = b.pos.x - 1.6, .y = 2.4, .z = b.pos.z + 1.3 }, 3.0, 0.28, 0.28, COLOR_COAL_MINE_HEADFRAME);
                rl.drawCube(.{ .x = b.pos.x - 3.1, .y = 2.4, .z = b.pos.z - 0.2 }, 0.28, 0.28, 3.0, COLOR_COAL_MINE_HEADFRAME);

                // Top headframe platform & crossbeam
                rl.drawCube(.{ .x = b.pos.x - 1.6, .y = tower_h + 0.15, .z = b.pos.z - 0.2 }, 3.4, 0.3, 3.4, COLOR_COAL_MINE_HEADFRAME);

                // Twin Winding Sheave Wheels atop the headframe
                rl.drawCube(.{ .x = b.pos.x - 1.9, .y = tower_h + 0.7, .z = b.pos.z - 0.2 }, 0.25, 0.9, 0.9, COLOR_COAL_MINE_WHEEL);
                rl.drawCube(.{ .x = b.pos.x - 1.3, .y = tower_h + 0.7, .z = b.pos.z - 0.2 }, 0.25, 0.9, 0.9, COLOR_COAL_MINE_WHEEL);

                // Winding Engine & Sorting House / Workshop on right side
                rl.drawCube(.{ .x = b.pos.x + 1.8, .y = 1.6, .z = b.pos.z }, 3.4, 2.4, 5.8, COLOR_COAL_MINE_WALLS);
                // Sloped industrial corrugated roof
                rl.drawCube(.{ .x = b.pos.x + 1.8, .y = 3.0, .z = b.pos.z }, 3.6, 0.5, 6.0, COLOR_COAL_MINE_ROOF);

                // Industrial brick smokestack
                rl.drawCube(.{ .x = b.pos.x + 2.8, .y = 3.8, .z = b.pos.z - 2.0 }, 0.65, 3.2, 0.65, COLOR_COAL_MINE_CHIMNEY);
                rl.drawCube(.{ .x = b.pos.x + 2.8, .y = 5.45, .z = b.pos.z - 2.0 }, 0.85, 0.2, 0.85, rl.Color.init(42, 28, 24, 255));

                // Coal discharge chute from shaft to sorting house
                rl.drawCube(.{ .x = b.pos.x + 0.3, .y = 1.3, .z = b.pos.z + 1.8 }, 1.2, 0.9, 2.2, COLOR_COAL_MINE_CHUTE);

                // Freshly mined coal mounds & ore carts at loading platform
                rl.drawCube(.{ .x = b.pos.x - 1.8, .y = 0.65, .z = b.pos.z + 2.4 }, 2.2, 0.5, 1.8, COLOR_COAL_PILE);
                rl.drawCube(.{ .x = b.pos.x - 1.8, .y = 1.0, .z = b.pos.z + 2.4 }, 1.4, 0.35, 1.2, rl.Color.init(38, 38, 44, 255));

                // Glowing lanterns / engine house windows
                const glow_col = if (b.is_warm) rl.Color.init(255, 185, 75, 255) else rl.Color.init(180, 120, 50, 255);
                rl.drawCube(.{ .x = b.pos.x + 0.05, .y = 1.4, .z = b.pos.z - 1.2 }, 0.12, 0.7, 0.9, glow_col);
                rl.drawCube(.{ .x = b.pos.x + 3.55, .y = 1.5, .z = b.pos.z }, 0.12, 0.7, 1.4, glow_col);
            }
        } else if (b.btype == .wood_shack) {
            const scaf_col = if (b.state == .dismantling) COLOR_DISMANTLE_SCAFFOLD else COLOR_SCAFFOLDING;
            if (b.state == .constructing or b.state == .dismantling) {
                // Foundation slab (7.84 x 0.36 x 7.84)
                rl.drawCube(.{ .x = b.pos.x, .y = 0.18, .z = b.pos.z }, 7.84, 0.36, 7.84, scaf_col);

                // 8 scaffolding timber posts around 4x4 perimeter
                const post_h = @max(0.6, 3.8 * b.progress);
                rl.drawCube(.{ .x = b.pos.x - 3.5, .y = post_h / 2.0, .z = b.pos.z - 3.5 }, 0.4, post_h, 0.4, COLOR_WOOD_PILE);
                rl.drawCube(.{ .x = b.pos.x + 3.5, .y = post_h / 2.0, .z = b.pos.z - 3.5 }, 0.4, post_h, 0.4, COLOR_WOOD_PILE);
                rl.drawCube(.{ .x = b.pos.x - 3.5, .y = post_h / 2.0, .z = b.pos.z + 3.5 }, 0.4, post_h, 0.4, COLOR_WOOD_PILE);
                rl.drawCube(.{ .x = b.pos.x + 3.5, .y = post_h / 2.0, .z = b.pos.z + 3.5 }, 0.4, post_h, 0.4, COLOR_WOOD_PILE);
                rl.drawCube(.{ .x = b.pos.x, .y = post_h / 2.0, .z = b.pos.z - 3.5 }, 0.4, post_h, 0.4, COLOR_WOOD_PILE);
                rl.drawCube(.{ .x = b.pos.x, .y = post_h / 2.0, .z = b.pos.z + 3.5 }, 0.4, post_h, 0.4, COLOR_WOOD_PILE);
                rl.drawCube(.{ .x = b.pos.x - 3.5, .y = post_h / 2.0, .z = b.pos.z }, 0.4, post_h, 0.4, COLOR_WOOD_PILE);
                rl.drawCube(.{ .x = b.pos.x + 3.5, .y = post_h / 2.0, .z = b.pos.z }, 0.4, post_h, 0.4, COLOR_WOOD_PILE);

                // Partial rising cabin walls
                const wall_h = 2.2 * b.progress;
                if (wall_h > 0.15) {
                    rl.drawCube(.{ .x = b.pos.x - 1.4, .y = 0.36 + wall_h / 2.0, .z = b.pos.z - 0.9 }, 4.4, wall_h, 5.2, COLOR_WOOD_SHACK_WALLS);
                }
            } else {
                // Completed Wood Shack (4x4 footprint)
                // Heavy rustic timber foundation slab
                rl.drawCube(.{ .x = b.pos.x, .y = 0.18, .z = b.pos.z }, 7.84, 0.36, 7.84, COLOR_WOOD_SHACK_FOUNDATION);

                // Main Carpenter / Sawmill Workshop Cabin (left/rear)
                rl.drawCube(.{ .x = b.pos.x - 1.4, .y = 1.46, .z = b.pos.z - 0.9 }, 4.4, 2.2, 5.2, COLOR_WOOD_SHACK_WALLS);
                // Sloped timber plank roof
                rl.drawCube(.{ .x = b.pos.x - 1.4, .y = 2.93, .z = b.pos.z - 0.9 }, 4.8, 0.75, 5.6, COLOR_WOOD_SHACK_ROOF);
                // Heavy ridge log
                rl.drawCube(.{ .x = b.pos.x - 1.4, .y = 3.35, .z = b.pos.z - 0.9 }, 1.2, 0.25, 5.6, COLOR_WOOD_SHACK_LOGS);

                // Workshop stovepipe chimney & cowl
                rl.drawCube(.{ .x = b.pos.x - 3.0, .y = 3.3, .z = b.pos.z - 2.8 }, 0.45, 2.2, 0.45, COLOR_WOOD_SHACK_CHIMNEY);
                rl.drawCube(.{ .x = b.pos.x - 3.0, .y = 4.45, .z = b.pos.z - 2.8 }, 0.7, 0.12, 0.7, rl.Color.init(45, 45, 50, 255));

                // Workshop door
                rl.drawCube(.{ .x = b.pos.x - 1.4, .y = 0.9, .z = b.pos.z + 1.72 }, 1.0, 1.4, 0.12, COLOR_WOOD_SHACK_LOGS);

                // Workshop glowing windows
                const win_col = if (b.is_warm) rl.Color.init(255, 205, 80, 255) else rl.Color.init(120, 180, 230, 255);
                rl.drawCube(.{ .x = b.pos.x - 3.62, .y = 1.5, .z = b.pos.z - 0.9 }, 0.12, 0.8, 1.4, win_col);
                rl.drawCube(.{ .x = b.pos.x - 1.4, .y = 1.5, .z = b.pos.z - 3.52 }, 1.4, 0.8, 0.12, win_col);

                // Timber Sawing Shelter / Covered Work Area (right side)
                // 4 heavy corner log posts
                const post_h: f32 = 2.8;
                rl.drawCube(.{ .x = b.pos.x + 1.2, .y = post_h / 2.0, .z = b.pos.z - 3.0 }, 0.35, post_h, 0.35, COLOR_WOOD_SHACK_LOGS);
                rl.drawCube(.{ .x = b.pos.x + 3.4, .y = post_h / 2.0, .z = b.pos.z - 3.0 }, 0.35, post_h, 0.35, COLOR_WOOD_SHACK_LOGS);
                rl.drawCube(.{ .x = b.pos.x + 1.2, .y = post_h / 2.0, .z = b.pos.z + 1.2 }, 0.35, post_h, 0.35, COLOR_WOOD_SHACK_LOGS);
                rl.drawCube(.{ .x = b.pos.x + 3.4, .y = post_h / 2.0, .z = b.pos.z + 1.2 }, 0.35, post_h, 0.35, COLOR_WOOD_SHACK_LOGS);

                // Sloped shelter canopy awning
                rl.drawCube(.{ .x = b.pos.x + 2.3, .y = 2.9, .z = b.pos.z - 0.9 }, 2.8, 0.25, 4.8, COLOR_WOOD_SHACK_ROOF);

                // Sawhorse trestle & log being sawed inside shelter
                rl.drawCube(.{ .x = b.pos.x + 2.3, .y = 0.76, .z = b.pos.z - 0.9 }, 1.4, 0.8, 0.8, COLOR_WOOD_SHACK_PLANKS);
                rl.drawCube(.{ .x = b.pos.x + 2.3, .y = 1.25, .z = b.pos.z - 0.9 }, 0.6, 0.6, 2.6, COLOR_WOOD_SHACK_LOGS);

                // Stack of freshly cut timber logs (pyramid stack in yard)
                rl.drawCube(.{ .x = b.pos.x + 1.8, .y = 0.55, .z = b.pos.z + 2.6 }, 2.8, 0.55, 1.4, COLOR_WOOD_SHACK_LOGS);
                rl.drawCube(.{ .x = b.pos.x + 1.8, .y = 1.05, .z = b.pos.z + 2.6 }, 2.2, 0.50, 1.0, COLOR_WOOD_SHACK_LOGS);

                // Chopping stump block & firewood
                rl.drawCube(.{ .x = b.pos.x - 2.4, .y = 0.65, .z = b.pos.z + 2.7 }, 0.9, 0.75, 0.9, COLOR_WOOD_SHACK_FOUNDATION);
                rl.drawCube(.{ .x = b.pos.x - 1.5, .y = 0.45, .z = b.pos.z + 2.8 }, 0.4, 0.4, 0.7, COLOR_WOOD_SHACK_PLANKS);

                // Hanging lantern on sawing shelter post
                rl.drawCube(.{ .x = b.pos.x + 1.2, .y = 2.3, .z = b.pos.z + 0.9 }, 0.18, 0.26, 0.18, win_col);
            }
        } else if (b.btype == .steel_forge) {
            const scaf_col = if (b.state == .dismantling) COLOR_DISMANTLE_SCAFFOLD else COLOR_SCAFFOLDING;
            if (b.state == .constructing or b.state == .dismantling) {
                // Foundation slab (7.84 x 0.36 x 7.84)
                rl.drawCube(.{ .x = b.pos.x, .y = 0.18, .z = b.pos.z }, 7.84, 0.36, 7.84, scaf_col);

                // 8 scaffolding iron posts around 4x4 perimeter
                const post_h = @max(0.6, 4.4 * b.progress);
                rl.drawCube(.{ .x = b.pos.x - 3.5, .y = post_h / 2.0, .z = b.pos.z - 3.5 }, 0.4, post_h, 0.4, COLOR_STEEL_PILE);
                rl.drawCube(.{ .x = b.pos.x + 3.5, .y = post_h / 2.0, .z = b.pos.z - 3.5 }, 0.4, post_h, 0.4, COLOR_STEEL_PILE);
                rl.drawCube(.{ .x = b.pos.x - 3.5, .y = post_h / 2.0, .z = b.pos.z + 3.5 }, 0.4, post_h, 0.4, COLOR_STEEL_PILE);
                rl.drawCube(.{ .x = b.pos.x + 3.5, .y = post_h / 2.0, .z = b.pos.z + 3.5 }, 0.4, post_h, 0.4, COLOR_STEEL_PILE);
                rl.drawCube(.{ .x = b.pos.x, .y = post_h / 2.0, .z = b.pos.z - 3.5 }, 0.4, post_h, 0.4, COLOR_STEEL_PILE);
                rl.drawCube(.{ .x = b.pos.x, .y = post_h / 2.0, .z = b.pos.z + 3.5 }, 0.4, post_h, 0.4, COLOR_STEEL_PILE);
                rl.drawCube(.{ .x = b.pos.x - 3.5, .y = post_h / 2.0, .z = b.pos.z }, 0.4, post_h, 0.4, COLOR_STEEL_PILE);
                rl.drawCube(.{ .x = b.pos.x + 3.5, .y = post_h / 2.0, .z = b.pos.z }, 0.4, post_h, 0.4, COLOR_STEEL_PILE);

                // Partial rising foundry walls
                const wall_h = 2.4 * b.progress;
                if (wall_h > 0.15) {
                    rl.drawCube(.{ .x = b.pos.x - 1.4, .y = 0.36 + wall_h / 2.0, .z = b.pos.z - 0.9 }, 4.4, wall_h, 5.2, COLOR_STEEL_FORGE_WALLS);
                }
            } else {
                // Completed Steel Forge (4x4 footprint)
                // Reinforced granite foundation slab
                rl.drawCube(.{ .x = b.pos.x, .y = 0.18, .z = b.pos.z }, 7.84, 0.36, 7.84, COLOR_STEEL_FORGE_FOUNDATION);

                // Main Smelting Hall & Cupola Furnace Building (left/rear)
                rl.drawCube(.{ .x = b.pos.x - 1.4, .y = 1.56, .z = b.pos.z - 0.9 }, 4.4, 2.4, 5.2, COLOR_STEEL_FORGE_WALLS);
                // Sloped industrial corrugated iron roof
                rl.drawCube(.{ .x = b.pos.x - 1.4, .y = 3.03, .z = b.pos.z - 0.9 }, 4.8, 0.65, 5.6, COLOR_STEEL_FORGE_ROOF);

                // Heavy blast furnace smokestack with iron bands
                rl.drawCube(.{ .x = b.pos.x - 2.8, .y = 3.8, .z = b.pos.z - 2.6 }, 0.85, 3.4, 0.85, COLOR_STEEL_FORGE_CHIMNEY);
                rl.drawCube(.{ .x = b.pos.x - 2.8, .y = 5.55, .z = b.pos.z - 2.6 }, 1.1, 0.25, 1.1, rl.Color.init(30, 32, 38, 255));
                // Blast stack crown flame glow
                rl.drawCube(.{ .x = b.pos.x - 2.8, .y = 5.75, .z = b.pos.z - 2.6 }, 0.6, 0.2, 0.6, COLOR_STEEL_FORGE_FIRE);

                // Furnace smelting hearth arch opening (front) with intense orange glow
                rl.drawCube(.{ .x = b.pos.x - 1.4, .y = 1.0, .z = b.pos.z + 1.72 }, 1.6, 1.4, 0.14, COLOR_STEEL_FORGE_FOUNDATION);
                rl.drawCube(.{ .x = b.pos.x - 1.4, .y = 0.9, .z = b.pos.z + 1.74 }, 1.1, 1.0, 0.12, COLOR_STEEL_FORGE_FIRE);

                // Glowing foundry windows / heat vents
                const win_col = if (b.is_warm) rl.Color.init(255, 170, 60, 255) else rl.Color.init(220, 120, 40, 255);
                rl.drawCube(.{ .x = b.pos.x - 3.62, .y = 1.6, .z = b.pos.z - 0.9 }, 0.12, 0.7, 1.4, win_col);
                rl.drawCube(.{ .x = b.pos.x - 1.4, .y = 1.6, .z = b.pos.z - 3.52 }, 1.4, 0.7, 0.12, win_col);

                // Open Smithing & Forging Bay (right side)
                // 4 heavy structural iron pillars
                const post_h: f32 = 2.8;
                rl.drawCube(.{ .x = b.pos.x + 1.2, .y = post_h / 2.0, .z = b.pos.z - 3.0 }, 0.35, post_h, 0.35, COLOR_STEEL_FORGE_CHIMNEY);
                rl.drawCube(.{ .x = b.pos.x + 3.4, .y = post_h / 2.0, .z = b.pos.z - 3.0 }, 0.35, post_h, 0.35, COLOR_STEEL_FORGE_CHIMNEY);
                rl.drawCube(.{ .x = b.pos.x + 1.2, .y = post_h / 2.0, .z = b.pos.z + 1.2 }, 0.35, post_h, 0.35, COLOR_STEEL_FORGE_CHIMNEY);
                rl.drawCube(.{ .x = b.pos.x + 3.4, .y = post_h / 2.0, .z = b.pos.z + 1.2 }, 0.35, post_h, 0.35, COLOR_STEEL_FORGE_CHIMNEY);

                // Sloped forge canopy awning
                rl.drawCube(.{ .x = b.pos.x + 2.3, .y = 2.9, .z = b.pos.z - 0.9 }, 2.8, 0.25, 4.8, COLOR_STEEL_FORGE_ROOF);

                // Hot coal smithing forge hearth with glowing bed of coals
                rl.drawCube(.{ .x = b.pos.x + 2.3, .y = 0.75, .z = b.pos.z - 2.0 }, 1.2, 0.75, 1.2, COLOR_STEEL_FORGE_FOUNDATION);
                rl.drawCube(.{ .x = b.pos.x + 2.3, .y = 1.15, .z = b.pos.z - 2.0 }, 0.8, 0.15, 0.8, COLOR_STEEL_FORGE_FIRE);

                // Heavy steel blacksmith anvil on iron block
                rl.drawCube(.{ .x = b.pos.x + 2.3, .y = 0.65, .z = b.pos.z - 0.5 }, 0.8, 0.60, 0.8, COLOR_STEEL_FORGE_FOUNDATION);
                rl.drawCube(.{ .x = b.pos.x + 2.3, .y = 1.1, .z = b.pos.z - 0.5 }, 0.5, 0.35, 1.1, COLOR_STEEL_FORGE_STEEL);

                // Water quenching trough
                rl.drawCube(.{ .x = b.pos.x + 1.3, .y = 0.55, .z = b.pos.z + 2.6 }, 1.2, 0.55, 1.6, rl.Color.init(45, 52, 62, 255));
                rl.drawCube(.{ .x = b.pos.x + 1.3, .y = 0.75, .z = b.pos.z + 2.6 }, 0.9, 0.15, 1.3, rl.Color.init(60, 95, 130, 255));

                // Stack of manufactured steel ingots / billets in the yard
                rl.drawCube(.{ .x = b.pos.x + 2.8, .y = 0.55, .z = b.pos.z + 2.6 }, 1.4, 0.50, 1.6, COLOR_STEEL_PILE);
                rl.drawCube(.{ .x = b.pos.x + 2.8, .y = 0.95, .z = b.pos.z + 2.6 }, 1.0, 0.35, 1.2, COLOR_STEEL_FORGE_STEEL);

                // Iron slag scrap heap
                rl.drawCube(.{ .x = b.pos.x - 2.5, .y = 0.5, .z = b.pos.z + 2.7 }, 1.2, 0.45, 1.1, rl.Color.init(50, 46, 44, 255));
            }
        } else {
            // House
            if (b.state == .constructing or b.state == .dismantling) {
                const scaf_col = if (b.state == .dismantling) COLOR_DISMANTLE_SCAFFOLD else COLOR_SCAFFOLDING;
                // Foundation slab (3.92 x 0.36 x 3.92)
                rl.drawCube(.{ .x = b.pos.x, .y = 0.18, .z = b.pos.z }, 3.92, 0.36, 3.92, scaf_col);

                // 4 corner timber scaffolding posts (height rises with progress)
                const post_h = @max(0.6, 3.2 * b.progress);
                rl.drawCube(.{ .x = b.pos.x - 1.65, .y = post_h / 2.0, .z = b.pos.z - 1.65 }, 0.35, post_h, 0.35, COLOR_WOOD_PILE);
                rl.drawCube(.{ .x = b.pos.x + 1.65, .y = post_h / 2.0, .z = b.pos.z - 1.65 }, 0.35, post_h, 0.35, COLOR_WOOD_PILE);
                rl.drawCube(.{ .x = b.pos.x - 1.65, .y = post_h / 2.0, .z = b.pos.z + 1.65 }, 0.35, post_h, 0.35, COLOR_WOOD_PILE);
                rl.drawCube(.{ .x = b.pos.x + 1.65, .y = post_h / 2.0, .z = b.pos.z + 1.65 }, 0.35, post_h, 0.35, COLOR_WOOD_PILE);

                // Partial walls rising with progress
                const wall_h = 2.2 * b.progress;
                if (wall_h > 0.15) {
                    rl.drawCube(.{ .x = b.pos.x, .y = 0.36 + wall_h / 2.0, .z = b.pos.z }, 3.5, wall_h, 3.5, COLOR_HOUSE_WALLS);
                }
            } else {
                // Completed House
                // Base foundation (3.92 x 0.36 x 3.92)
                rl.drawCube(.{ .x = b.pos.x, .y = 0.18, .z = b.pos.z }, 3.92, 0.36, 3.92, rl.Color.init(55, 42, 32, 255));
                // Main timber walls (3.6 x 2.2 x 3.6)
                rl.drawCube(.{ .x = b.pos.x, .y = 1.4, .z = b.pos.z }, 3.6, 2.2, 3.6, COLOR_HOUSE_WALLS);
                // Peaked slate roof (3.92 x 0.75 x 3.92)
                rl.drawCube(.{ .x = b.pos.x, .y = 2.85, .z = b.pos.z }, 3.92, 0.75, 3.92, COLOR_HOUSE_ROOF);
                rl.drawCube(.{ .x = b.pos.x, .y = 3.32, .z = b.pos.z }, 3.96, 0.32, 1.8, rl.Color.init(45, 52, 60, 255));
                // Chimney
                rl.drawCube(.{ .x = b.pos.x + 1.15, .y = 3.2, .z = b.pos.z + 1.05 }, 0.65, 1.6, 0.65, COLOR_HOUSE_CHIMNEY);
                // Front door
                rl.drawCube(.{ .x = b.pos.x, .y = 0.8, .z = b.pos.z + 1.82 }, 0.9, 1.25, 0.12, rl.Color.init(42, 30, 22, 255));
                // Windows
                const win_color = if (b.is_warm) rl.Color.init(255, 210, 85, 255) else rl.Color.init(130, 175, 220, 255);
                rl.drawCube(.{ .x = b.pos.x - 1.82, .y = 1.5, .z = b.pos.z }, 0.12, 0.8, 0.8, win_color);
                rl.drawCube(.{ .x = b.pos.x + 1.82, .y = 1.5, .z = b.pos.z }, 0.12, 0.8, 0.8, win_color);
            }
        }
    }

    // Ghost preview (solids)
    if (placing) |btype| {
        if (snapped_grid) |snapped| {
            const s = GRID_CELL_SIZE;
            const gw = btype.gridWidth();
            const gl = btype.gridLength();
            const cell_col = if (can_place) rl.Color.init(50, 205, 110, 110) else rl.Color.init(230, 50, 50, 110);

            var ix: i32 = 0;
            while (ix < gw) : (ix += 1) {
                var iz: i32 = 0;
                while (iz < gl) : (iz += 1) {
                    const cell_x = (@as(f32, @floatFromInt(snapped.gx + ix)) + 0.5) * s;
                    const cell_z = (@as(f32, @floatFromInt(snapped.gz + iz)) + 0.5) * s;
                    rl.drawCube(.{ .x = cell_x, .y = 0.025, .z = cell_z }, s - 0.08, 0.03, s - 0.08, cell_col);
                }
            }

            if (cand_pos) |pos| {
                const col = if (can_place) COLOR_GHOST_VALID else COLOR_GHOST_INVALID;
                if (btype == .lab) {
                    rl.drawCube(.{ .x = pos.x, .y = 0.19, .z = pos.z }, 5.8, 0.38, 5.8, col);
                    rl.drawCube(.{ .x = pos.x, .y = 1.48, .z = pos.z }, 5.4, 2.2, 5.4, col);
                    rl.drawCube(.{ .x = pos.x, .y = 2.75, .z = pos.z }, 5.7, 0.35, 5.7, col);
                    rl.drawCube(.{ .x = pos.x, .y = 3.48, .z = pos.z }, 2.8, 1.1, 2.8, col);
                } else if (btype == .greenhouse) {
                    rl.drawCube(.{ .x = pos.x, .y = 0.18, .z = pos.z }, 3.84, 0.36, 7.84, col);
                    rl.drawCube(.{ .x = pos.x, .y = 1.56, .z = pos.z }, 3.5, 1.4, 7.5, col);
                    rl.drawCube(.{ .x = pos.x, .y = 2.58, .z = pos.z }, 3.68, 0.65, 7.68, col);
                } else if (btype == .coal_mine) {
                    rl.drawCube(.{ .x = pos.x, .y = 0.20, .z = pos.z }, 7.84, 0.40, 7.84, col);
                    rl.drawCube(.{ .x = pos.x + 1.8, .y = 1.6, .z = pos.z }, 3.4, 2.4, 5.8, col);
                    rl.drawCube(.{ .x = pos.x + 1.8, .y = 3.0, .z = pos.z }, 3.6, 0.5, 6.0, col);
                    rl.drawCube(.{ .x = pos.x - 1.6, .y = 2.4, .z = pos.z }, 3.2, 4.6, 3.2, col);
                    rl.drawCube(.{ .x = pos.x + 2.8, .y = 3.8, .z = pos.z - 2.0 }, 0.65, 3.2, 0.65, col);
                } else if (btype == .wood_shack) {
                    rl.drawCube(.{ .x = pos.x, .y = 0.18, .z = pos.z }, 7.84, 0.36, 7.84, col);
                    rl.drawCube(.{ .x = pos.x - 1.4, .y = 1.46, .z = pos.z - 0.9 }, 4.4, 2.2, 5.2, col);
                    rl.drawCube(.{ .x = pos.x - 1.4, .y = 2.93, .z = pos.z - 0.9 }, 4.8, 0.75, 5.6, col);
                    rl.drawCube(.{ .x = pos.x + 2.3, .y = 2.9, .z = pos.z - 0.9 }, 2.8, 0.25, 4.8, col);
                    rl.drawCube(.{ .x = pos.x - 3.0, .y = 3.3, .z = pos.z - 2.8 }, 0.45, 2.2, 0.45, col);
                } else if (btype == .steel_forge) {
                    rl.drawCube(.{ .x = pos.x, .y = 0.18, .z = pos.z }, 7.84, 0.36, 7.84, col);
                    rl.drawCube(.{ .x = pos.x - 1.4, .y = 1.56, .z = pos.z - 0.9 }, 4.4, 2.4, 5.2, col);
                    rl.drawCube(.{ .x = pos.x - 1.4, .y = 3.03, .z = pos.z - 0.9 }, 4.8, 0.65, 5.6, col);
                    rl.drawCube(.{ .x = pos.x + 2.3, .y = 2.9, .z = pos.z - 0.9 }, 2.8, 0.25, 4.8, col);
                    rl.drawCube(.{ .x = pos.x - 2.8, .y = 3.8, .z = pos.z - 2.6 }, 0.85, 3.4, 0.85, col);
                } else {
                    rl.drawCube(.{ .x = pos.x, .y = 0.18, .z = pos.z }, 3.92, 0.36, 3.92, col);
                    rl.drawCube(.{ .x = pos.x, .y = 1.4, .z = pos.z }, 3.6, 2.2, 3.6, col);
                    rl.drawCube(.{ .x = pos.x, .y = 2.85, .z = pos.z }, 3.92, 0.75, 3.92, col);
                    rl.drawCube(.{ .x = pos.x + 1.15, .y = 3.2, .z = pos.z + 1.05 }, 0.65, 1.6, 0.65, col);
                }
            }
        }
    }
}

fn drawBuildingsWires(selected: ?usize, hovered: ?usize, cand_pos: ?rl.Vector3, placing: ?BuildingType, can_place: bool, snapped_grid: ?GridCoord) void {
    for (buildings[0..buildings_count]) |b| {
        const is_lab = (b.btype == .lab);
        const is_gh = (b.btype == .greenhouse);
        const is_cm = (b.btype == .coal_mine);
        const is_ws = (b.btype == .wood_shack);
        const is_sf = (b.btype == .steel_forge);
        const w_sz: f32 = if (is_cm or is_ws or is_sf) 7.84 else if (is_lab) 5.8 else 3.84;
        const l_sz: f32 = if (is_cm or is_ws or is_sf) 7.84 else if (is_lab) 5.8 else if (is_gh) 7.84 else 3.92;
        const h_sz: f32 = if (is_cm) 4.6 else if (is_sf) 4.2 else if (is_ws) 3.6 else if (is_lab) 3.6 else if (is_gh) 3.0 else 3.2;

        if (b.state == .constructing or b.state == .dismantling) {
            const scaf_col = if (b.state == .dismantling) COLOR_DISMANTLE_SCAFFOLD else COLOR_SCAFFOLDING;
            rl.drawCubeWires(.{ .x = b.pos.x, .y = h_sz / 2.0, .z = b.pos.z }, w_sz, h_sz, l_sz, scaf_col);
        } else {
            if (is_lab) {
                rl.drawCubeWires(.{ .x = b.pos.x, .y = 1.48, .z = b.pos.z }, 5.4, 2.2, 5.4, rl.Color.init(45, 55, 68, 255));
                rl.drawCubeWires(.{ .x = b.pos.x, .y = 2.75, .z = b.pos.z }, 5.7, 0.35, 5.7, rl.Color.init(65, 80, 100, 255));
                rl.drawCubeWires(.{ .x = b.pos.x, .y = 3.48, .z = b.pos.z }, 2.8, 1.1, 2.8, rl.Color.init(80, 180, 220, 255));
            } else if (is_gh) {
                rl.drawCubeWires(.{ .x = b.pos.x, .y = 0.61, .z = b.pos.z }, 3.68, 0.5, 7.68, rl.Color.init(30, 60, 50, 255));
                rl.drawCubeWires(.{ .x = b.pos.x, .y = 1.56, .z = b.pos.z }, 3.5, 1.4, 7.5, rl.Color.init(45, 120, 95, 255));
                rl.drawCubeWires(.{ .x = b.pos.x, .y = 2.58, .z = b.pos.z }, 3.68, 0.65, 7.68, rl.Color.init(55, 140, 110, 255));
            } else if (is_cm) {
                rl.drawCubeWires(.{ .x = b.pos.x, .y = 0.20, .z = b.pos.z }, 7.84, 0.40, 7.84, rl.Color.init(45, 48, 55, 255));
                rl.drawCubeWires(.{ .x = b.pos.x + 1.8, .y = 1.6, .z = b.pos.z }, 3.4, 2.4, 5.8, rl.Color.init(55, 58, 68, 255));
                rl.drawCubeWires(.{ .x = b.pos.x - 1.6, .y = 2.4, .z = b.pos.z - 0.2 }, 3.4, 4.6, 3.4, rl.Color.init(65, 70, 82, 255));
                rl.drawCubeWires(.{ .x = b.pos.x + 2.8, .y = 3.8, .z = b.pos.z - 2.0 }, 0.65, 3.2, 0.65, rl.Color.init(50, 52, 60, 255));
            } else if (is_ws) {
                rl.drawCubeWires(.{ .x = b.pos.x, .y = 0.18, .z = b.pos.z }, 7.84, 0.36, 7.84, rl.Color.init(55, 45, 35, 255));
                rl.drawCubeWires(.{ .x = b.pos.x - 1.4, .y = 1.46, .z = b.pos.z - 0.9 }, 4.4, 2.2, 5.2, rl.Color.init(65, 45, 25, 255));
                rl.drawCubeWires(.{ .x = b.pos.x - 1.4, .y = 2.93, .z = b.pos.z - 0.9 }, 4.8, 0.75, 5.6, rl.Color.init(45, 55, 65, 255));
                rl.drawCubeWires(.{ .x = b.pos.x + 2.3, .y = 2.9, .z = b.pos.z - 0.9 }, 2.8, 0.25, 4.8, rl.Color.init(55, 60, 65, 255));
                rl.drawCubeWires(.{ .x = b.pos.x - 3.0, .y = 3.3, .z = b.pos.z - 2.8 }, 0.45, 2.2, 0.45, rl.Color.init(40, 42, 45, 255));
            } else if (is_sf) {
                rl.drawCubeWires(.{ .x = b.pos.x, .y = 0.18, .z = b.pos.z }, 7.84, 0.36, 7.84, rl.Color.init(45, 50, 58, 255));
                rl.drawCubeWires(.{ .x = b.pos.x - 1.4, .y = 1.56, .z = b.pos.z - 0.9 }, 4.4, 2.4, 5.2, rl.Color.init(55, 62, 72, 255));
                rl.drawCubeWires(.{ .x = b.pos.x - 1.4, .y = 3.03, .z = b.pos.z - 0.9 }, 4.8, 0.65, 5.6, rl.Color.init(50, 56, 66, 255));
                rl.drawCubeWires(.{ .x = b.pos.x + 2.3, .y = 2.9, .z = b.pos.z - 0.9 }, 2.8, 0.25, 4.8, rl.Color.init(55, 62, 70, 255));
                rl.drawCubeWires(.{ .x = b.pos.x - 2.8, .y = 3.8, .z = b.pos.z - 2.6 }, 0.85, 3.4, 0.85, rl.Color.init(60, 65, 75, 255));
            } else {
                rl.drawCubeWires(.{ .x = b.pos.x, .y = 1.4, .z = b.pos.z }, 3.6, 2.2, 3.6, rl.Color.init(35, 25, 20, 255));
                rl.drawCubeWires(.{ .x = b.pos.x, .y = 2.85, .z = b.pos.z }, 3.92, 0.75, 3.92, rl.Color.init(30, 36, 42, 255));
                rl.drawCubeWires(.{ .x = b.pos.x + 1.15, .y = 3.2, .z = b.pos.z + 1.05 }, 0.65, 1.6, 0.65, rl.Color.init(25, 20, 18, 255));
            }
        }

        if (selected == b.id) {
            rl.drawCubeWires(.{ .x = b.pos.x, .y = h_sz / 2.0, .z = b.pos.z }, w_sz + 0.12, h_sz + 0.1, l_sz + 0.12, rl.Color.gold);
            rl.drawCubeWires(.{ .x = b.pos.x, .y = 0.05, .z = b.pos.z }, w_sz + 0.18, 0.1, l_sz + 0.18, rl.Color.gold);
        } else if (hovered == b.id) {
            rl.drawCubeWires(.{ .x = b.pos.x, .y = h_sz / 2.0, .z = b.pos.z }, w_sz + 0.12, h_sz + 0.1, l_sz + 0.12, rl.Color.init(180, 220, 255, 180));
        }
    }

    // Ghost preview (wires)
    if (placing) |btype| {
        if (snapped_grid) |snapped| {
            const s = GRID_CELL_SIZE;
            const gw = btype.gridWidth();
            const gl = btype.gridLength();

            drawBlueprintGrid(snapped.gx, snapped.gz, gw, gl);

            const wire_col = if (can_place) rl.Color.init(80, 255, 140, 220) else rl.Color.init(255, 75, 75, 220);

            var ix: i32 = 0;
            while (ix < gw) : (ix += 1) {
                var iz: i32 = 0;
                while (iz < gl) : (iz += 1) {
                    const cell_x = (@as(f32, @floatFromInt(snapped.gx + ix)) + 0.5) * s;
                    const cell_z = (@as(f32, @floatFromInt(snapped.gz + iz)) + 0.5) * s;
                    rl.drawCubeWires(.{ .x = cell_x, .y = 0.035, .z = cell_z }, s - 0.06, 0.04, s - 0.06, wire_col);
                }
            }

            if (cand_pos) |pos| {
                if (btype == .lab) {
                    rl.drawCubeWires(.{ .x = pos.x, .y = 0.19, .z = pos.z }, 5.8, 0.38, 5.8, wire_col);
                    rl.drawCubeWires(.{ .x = pos.x, .y = 1.48, .z = pos.z }, 5.4, 2.2, 5.4, wire_col);
                    rl.drawCubeWires(.{ .x = pos.x, .y = 2.75, .z = pos.z }, 5.7, 0.35, 5.7, wire_col);
                    rl.drawCubeWires(.{ .x = pos.x, .y = 3.48, .z = pos.z }, 2.8, 1.1, 2.8, wire_col);
                } else if (btype == .greenhouse) {
                    rl.drawCubeWires(.{ .x = pos.x, .y = 0.18, .z = pos.z }, 3.84, 0.36, 7.84, wire_col);
                    rl.drawCubeWires(.{ .x = pos.x, .y = 1.56, .z = pos.z }, 3.5, 1.4, 7.5, wire_col);
                    rl.drawCubeWires(.{ .x = pos.x, .y = 2.58, .z = pos.z }, 3.68, 0.65, 7.68, wire_col);
                } else if (btype == .coal_mine) {
                    rl.drawCubeWires(.{ .x = pos.x, .y = 0.20, .z = pos.z }, 7.84, 0.40, 7.84, wire_col);
                    rl.drawCubeWires(.{ .x = pos.x + 1.8, .y = 1.6, .z = pos.z }, 3.4, 2.4, 5.8, wire_col);
                    rl.drawCubeWires(.{ .x = pos.x - 1.6, .y = 2.4, .z = pos.z }, 3.2, 4.6, 3.2, wire_col);
                    rl.drawCubeWires(.{ .x = pos.x + 2.8, .y = 3.8, .z = pos.z - 2.0 }, 0.65, 3.2, 0.65, wire_col);
                } else if (btype == .wood_shack) {
                    rl.drawCubeWires(.{ .x = pos.x, .y = 0.18, .z = pos.z }, 7.84, 0.36, 7.84, wire_col);
                    rl.drawCubeWires(.{ .x = pos.x - 1.4, .y = 1.46, .z = pos.z - 0.9 }, 4.4, 2.2, 5.2, wire_col);
                    rl.drawCubeWires(.{ .x = pos.x - 1.4, .y = 2.93, .z = pos.z - 0.9 }, 4.8, 0.75, 5.6, wire_col);
                    rl.drawCubeWires(.{ .x = pos.x + 2.3, .y = 2.9, .z = pos.z - 0.9 }, 2.8, 0.25, 4.8, wire_col);
                    rl.drawCubeWires(.{ .x = pos.x - 3.0, .y = 3.3, .z = pos.z - 2.8 }, 0.45, 2.2, 0.45, wire_col);
                } else if (btype == .steel_forge) {
                    rl.drawCubeWires(.{ .x = pos.x, .y = 0.18, .z = pos.z }, 7.84, 0.36, 7.84, wire_col);
                    rl.drawCubeWires(.{ .x = pos.x - 1.4, .y = 1.56, .z = pos.z - 0.9 }, 4.4, 2.4, 5.2, wire_col);
                    rl.drawCubeWires(.{ .x = pos.x - 1.4, .y = 3.03, .z = pos.z - 0.9 }, 4.8, 0.65, 5.6, wire_col);
                    rl.drawCubeWires(.{ .x = pos.x + 2.3, .y = 2.9, .z = pos.z - 0.9 }, 2.8, 0.25, 4.8, wire_col);
                    rl.drawCubeWires(.{ .x = pos.x - 2.8, .y = 3.8, .z = pos.z - 2.6 }, 0.85, 3.4, 0.85, wire_col);
                } else {
                    rl.drawCubeWires(.{ .x = pos.x, .y = 0.18, .z = pos.z }, 3.92, 0.36, 3.92, wire_col);
                    rl.drawCubeWires(.{ .x = pos.x, .y = 1.4, .z = pos.z }, 3.6, 2.2, 3.6, wire_col);
                    rl.drawCubeWires(.{ .x = pos.x, .y = 2.85, .z = pos.z }, 3.92, 0.75, 3.92, wire_col);
                }
            }
        }
    }
}

// ============================================================================
// 2D HUD & UI
// ============================================================================

fn drawWorldLabels(cached: CachedSceneUI) void {
    // 1. Heat Generator floating label
    if (cached.gen_label_on_screen and !selected_generator) {
        const text = if (generator_active) "HEAT GENERATOR [ONLINE]" else "HEAT GENERATOR [OFFLINE]";
        const tw = rl.measureText(text, 11);
        const bx = @as(i32, @intFromFloat(cached.gen_label_screen.x)) - @divTrunc(tw, 2);
        const by = @as(i32, @intFromFloat(cached.gen_label_screen.y));

        const border_color = if (selected_generator)
            rl.Color.gold
        else if (hovered_generator)
            rl.Color.init(255, 215, 80, 255)
        else if (generator_active)
            COLOR_GENERATOR_LIT
        else
            rl.Color.init(70, 75, 85, 255);

        const bg_color = if (selected_generator or hovered_generator)
            rl.Color.init(32, 40, 52, 245)
        else
            rl.Color.init(18, 22, 28, 220);

        rl.drawRectangle(bx - 8, by - 4, tw + 16, 20, bg_color);
        rl.drawRectangleLines(bx - 8, by - 4, tw + 16, 20, border_color);
        rl.drawText(
            text,
            bx,
            by,
            11,
            if (selected_generator) rl.Color.gold else if (generator_active) rl.Color.init(255, 205, 60, 255) else rl.Color.init(180, 185, 195, 255),
        );
    }

    // 2. Resource Piles floating badges & On-Pile Worker Assignment Stations
    inline for (std.meta.tags(Resource)) |r| {
        const ui = cached.piles[@intFromEnum(r)];
        if (isPileActive(r) and ui.is_on_screen) {
            const assigned = workers_assigned[@intFromEnum(r)];
            const is_selected = (selected_resource == r);
            const is_hovered = (hovered_resource == r);

            if (!is_selected) {
                // --- Unselected State: Floating Badge ---
                const br = ui.badge_rect;
                const bg_color = if (is_hovered) rl.Color.init(32, 40, 52, 245) else rl.Color.init(18, 22, 28, 230);
                const border_color = if (is_hovered) rl.Color.init(255, 215, 80, 255) else r.color();

                rl.drawRectangleRounded(br, 0.25, 6, bg_color);
                rl.drawRectangleRoundedLinesEx(br, 0.25, 6, if (is_hovered) 2.0 else 1.2, border_color);

                // Resource color pill
                rl.drawRectangle(@intFromFloat(br.x + 8), @intFromFloat(br.y + 7), 12, 14, r.color());

                // Label text: Name & worker count
                _ = rl.drawText(
                    fmt("{s} Pile ({d:.0})", .{ r.name(), pile_reserves[@intFromEnum(r)] }),
                    @intFromFloat(br.x + 25),
                    @intFromFloat(br.y + 4),
                    11,
                    if (is_hovered) rl.Color.init(255, 225, 120, 255) else rl.Color.white,
                );

                const count_text = fmt("{d}/{d} workers", .{ assigned, PILE_WORKER_CAP });
                _ = rl.drawText(
                    count_text,
                    @intFromFloat(br.x + 25),
                    @intFromFloat(br.y + 15),
                    10,
                    if (assigned >= PILE_WORKER_CAP)
                        rl.Color.init(245, 205, 70, 255)
                    else if (assigned > 0)
                        rl.Color.init(120, 230, 140, 255)
                    else
                        rl.Color.init(150, 165, 180, 255),
                );

                // Right manage prompt
                _ = rl.drawText(
                    if (is_hovered) "CLICK" else "MANAGE",
                    @intFromFloat(br.x + br.width - 48),
                    @intFromFloat(br.y + 9),
                    9,
                    if (is_hovered) rl.Color.init(255, 215, 80, 255) else rl.Color.init(130, 150, 175, 255),
                );
            } else {
                // --- Selected State: On-Pile Worker Management Station ---
                if (ui.card_rect) |cr| {
                    const rate = @as(f32, @floatFromInt(assigned)) * r.gatherRate();

                    // Connecting line from card to pile base/badge point
                    const anchor_x = ui.badge_rect.x + ui.badge_rect.width / 2.0;
                    const anchor_y = ui.badge_rect.y + ui.badge_rect.height / 2.0;
                    const card_bottom_y = if (cr.y < anchor_y) cr.y + cr.height else cr.y;
                    rl.drawLineEx(
                        .{ .x = cr.x + cr.width / 2.0, .y = card_bottom_y },
                        .{ .x = anchor_x, .y = anchor_y },
                        2.0,
                        rl.Color.init(245, 195, 65, 180),
                    );

                    // Main card background
                    rl.drawRectangleRounded(cr, 0.06, 8, rl.Color.init(18, 22, 30, 250));
                    rl.drawRectangleRoundedLinesEx(cr, 0.06, 8, 2.0, rl.Color.init(245, 195, 65, 255));

                    // Header: Resource color icon + Title
                    rl.drawRectangle(@intFromFloat(cr.x + 12), @intFromFloat(cr.y + 11), 12, 14, r.color());
                    _ = rl.drawText(
                        fmt("{s} PILE", .{r.name()}),
                        @intFromFloat(cr.x + 30),
                        @intFromFloat(cr.y + 10),
                        15,
                        rl.Color.init(245, 205, 70, 255),
                    );

                    // Close button [x]
                    if (!is_paused) {
                        if (rg.button(rl.Rectangle.init(cr.x + cr.width - 28, cr.y + 8, 20, 20), "x")) {
                            selected_resource = null;
                        }
                    }

                    // Subtitle
                    rl.drawText(
                        fmt("Remaining: {d:.0} | Max {d} Workers", .{ pile_reserves[@intFromEnum(r)], PILE_WORKER_CAP }),
                        @intFromFloat(cr.x + 12),
                        @intFromFloat(cr.y + 28),
                        10,
                        rl.Color.init(140, 175, 210, 255),
                    );

                    // Divider line 1
                    rl.drawLine(
                        @intFromFloat(cr.x + 12),
                        @intFromFloat(cr.y + 42),
                        @intFromFloat(cr.x + cr.width - 12),
                        @intFromFloat(cr.y + 42),
                        rl.Color.init(55, 65, 80, 255),
                    );

                    // Status info
                    _ = rl.drawText(
                        fmt("Assigned: {d} / {d} workers", .{ assigned, PILE_WORKER_CAP }),
                        @intFromFloat(cr.x + 12),
                        @intFromFloat(cr.y + 48),
                        13,
                        if (assigned >= PILE_WORKER_CAP) rl.Color.init(245, 205, 70, 255) else rl.Color.white,
                    );

                    _ = rl.drawText(
                        fmt("Yield: +{d:.1} {s}/sec", .{ rate, r.name() }),
                        @intFromFloat(cr.x + 12),
                        @intFromFloat(cr.y + 66),
                        12,
                        rl.Color.init(120, 230, 140, 255),
                    );

                    // Divider line 2
                    rl.drawLine(
                        @intFromFloat(cr.x + 12),
                        @intFromFloat(cr.y + 84),
                        @intFromFloat(cr.x + cr.width - 12),
                        @intFromFloat(cr.y + 84),
                        rl.Color.init(50, 60, 75, 255),
                    );

                    // Worker Allocation Buttons (Only clickable when not paused)
                    if (!is_paused) {
                        // Button Row: [None] [-5] [-1] [+1] [+5] [Max]
                        const btn_y1 = cr.y + 92.0;
                        const btn_h1: f32 = 26.0;

                        if (rg.button(rl.Rectangle.init(cr.x + 12, btn_y1, 42, btn_h1), "None")) {
                            assignWorkers(r, -assigned);
                        }
                        if (rg.button(rl.Rectangle.init(cr.x + 58, btn_y1, 34, btn_h1), "-5")) {
                            assignWorkers(r, -5);
                        }
                        if (rg.button(rl.Rectangle.init(cr.x + 96, btn_y1, 32, btn_h1), "-1")) {
                            assignWorkers(r, -1);
                        }
                        if (rg.button(rl.Rectangle.init(cr.x + 132, btn_y1, 32, btn_h1), "+1")) {
                            assignWorkers(r, 1);
                        }
                        if (rg.button(rl.Rectangle.init(cr.x + 168, btn_y1, 34, btn_h1), "+5")) {
                            assignWorkers(r, 5);
                        }
                        if (rg.button(rl.Rectangle.init(cr.x + 206, btn_y1, 42, btn_h1), "Max")) {
                            const to_fill = @max(0, PILE_WORKER_CAP - assigned);
                            assignWorkers(r, to_fill);
                        }
                    }
                }
            }
        }
    }
}

fn drawLabResearchSpinner(center: rl.Vector2, radius: f32, progress: f32, speed_mult: f32, is_paused_state: bool) void {
    _ = is_paused_state;
    const outer_r: f32 = radius;
    const ring_w: f32 = 4.5;
    const inner_r: f32 = outer_r - ring_w;

    // 1. Dark circular disc background
    rl.drawCircleV(center, outer_r + 2.0, rl.Color.init(14, 20, 30, 245));
    rl.drawCircleLinesV(center, outer_r + 2.0, rl.Color.init(40, 65, 95, 200));

    // 2. Base track (empty progress ring)
    rl.drawRing(center, inner_r, outer_r, 0.0, 360.0, 48, rl.Color.init(24, 38, 55, 255));

    // 3. Progress fill arc (clockwise from top / 12 o'clock, which is -90.0 degrees)
    const fill_progress = std.math.clamp(progress, 0.0, 1.0);
    if (fill_progress > 0.002) {
        const start_deg: f32 = -90.0;
        const end_deg: f32 = -90.0 + fill_progress * 360.0;
        const fill_color = if (speed_mult > 0.0) rl.Color.init(55, 210, 255, 255) else rl.Color.init(245, 175, 60, 255);
        rl.drawRing(center, inner_r, outer_r, start_deg, end_deg, 48, fill_color);
    }

    // 4. Center text: Percentage
    const pct_val = @as(i32, @intFromFloat(fill_progress * 100.0));
    const pct_text = fmt("{d}%", .{pct_val});
    const font_size: i32 = if (pct_val >= 100) 9 else 10;
    const tw = rl.measureText(pct_text, font_size);
    const tx = @as(i32, @intFromFloat(center.x)) - @divTrunc(tw, 2);
    const ty = @as(i32, @intFromFloat(center.y)) - @divTrunc(font_size, 2);
    rl.drawText(pct_text, tx, ty, font_size, rl.Color.white);
}

fn drawBuildingLabels(camera: rl.Camera3D) void {
    const sw = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const sh = @as(f32, @floatFromInt(rl.getScreenHeight()));

    for (buildings[0..buildings_count]) |b| {
        // If this building is currently selected, its full management station dialog
        // is drawn directly on top of it, so skip the small floating badge or progress card.
        if (selected_building == b.id) continue;

        if (b.state == .constructing or b.state == .dismantling) {
            const screen_pos = rl.getWorldToScreen(.{ .x = b.pos.x, .y = 3.6, .z = b.pos.z }, camera);
            if (screen_pos.x > -50 and screen_pos.x < sw + 50 and screen_pos.y > -50 and screen_pos.y < sh + 50) {
                const bar_w: f32 = 110.0;
                const bar_h: f32 = 10.0;
                const bar_x = screen_pos.x - bar_w / 2.0;
                const card_h: f32 = 42.0;
                const card_y = screen_pos.y - card_h / 2.0;
                const bar_y = card_y + 18.0;

                const is_dismantling = (b.state == .dismantling);
                const border_col = if (is_dismantling) COLOR_DISMANTLE_SCAFFOLD else COLOR_SCAFFOLDING;

                // Card background
                rl.drawRectangleRounded(
                    rl.Rectangle.init(bar_x - 8, card_y, bar_w + 16, card_h),
                    0.25,
                    6,
                    rl.Color.init(18, 22, 28, 230),
                );
                rl.drawRectangleRoundedLinesEx(
                    rl.Rectangle.init(bar_x - 8, card_y, bar_w + 16, card_h),
                    0.25,
                    6,
                    1.2,
                    border_col,
                );

                // Title & percentage
                const pct = if (is_dismantling)
                    @as(i32, @intFromFloat((1.0 - b.progress) * 100.0))
                else
                    @as(i32, @intFromFloat(b.progress * 100.0));

                const title_text = if (is_dismantling)
                    fmt("{s}: Demolish {d}%", .{ b.btype.name(), pct })
                else
                    fmt("{s}: {d}%", .{ b.btype.name(), pct });

                rl.drawText(
                    title_text,
                    @intFromFloat(bar_x),
                    @intFromFloat(card_y + 4),
                    11,
                    if (is_dismantling) rl.Color.init(255, 130, 110, 255) else rl.Color.init(245, 205, 70, 255),
                );

                // Progress Bar Background
                rl.drawRectangle(
                    @intFromFloat(bar_x),
                    @intFromFloat(bar_y),
                    @intFromFloat(bar_w),
                    @intFromFloat(bar_h),
                    rl.Color.init(35, 40, 50, 255),
                );
                // Progress Bar Fill
                const progress_ratio = if (is_dismantling)
                    std.math.clamp(1.0 - b.progress, 0.0, 1.0)
                else
                    std.math.clamp(b.progress, 0.0, 1.0);

                const fill_w = bar_w * progress_ratio;
                rl.drawRectangle(
                    @intFromFloat(bar_x),
                    @intFromFloat(bar_y),
                    @intFromFloat(fill_w),
                    @intFromFloat(bar_h),
                    border_col,
                );
                rl.drawRectangleLines(
                    @intFromFloat(bar_x),
                    @intFromFloat(bar_y),
                    @intFromFloat(bar_w),
                    @intFromFloat(bar_h),
                    rl.Color.init(80, 95, 115, 255),
                );

                // Builder / worker status
                if (b.active_builders > 0) {
                    const worker_label = if (is_dismantling) "Workers" else "Builders";
                    rl.drawText(
                        fmt("{d}/{d} {s}", .{ b.active_builders, b.btype.maxBuilders(), worker_label }),
                        @intFromFloat(bar_x),
                        @intFromFloat(card_y + 30),
                        10,
                        if (is_dismantling) rl.Color.init(255, 170, 150, 255) else rl.Color.init(130, 225, 160, 255),
                    );
                } else {
                    rl.drawText(
                        "Paused (0 Idle)",
                        @intFromFloat(bar_x),
                        @intFromFloat(card_y + 30),
                        10,
                        rl.Color.init(255, 120, 100, 255),
                    );
                }
            }
        } else if (b.state == .completed and (b.btype == .greenhouse or b.btype == .lab or b.btype == .coal_mine or b.btype == .wood_shack or b.btype == .steel_forge)) {
            const screen_pos = rl.getWorldToScreen(.{ .x = b.pos.x, .y = 3.8, .z = b.pos.z }, camera);
            if (screen_pos.x > -100 and screen_pos.x < sw + 100 and screen_pos.y > -100 and screen_pos.y < sh + 100) {
                const badge_w: f32 = 175.0;
                const badge_h: f32 = 28.0;
                const br = rl.Rectangle.init(
                    screen_pos.x - badge_w / 2.0,
                    screen_pos.y - badge_h / 2.0,
                    badge_w,
                    badge_h,
                );

                const is_selected = (selected_building == b.id);
                const is_hovered = (hovered_building == b.id);

                const is_gh = (b.btype == .greenhouse);
                const is_lab_b = (b.btype == .lab);
                const is_cm = (b.btype == .coal_mine);
                const is_ws = (b.btype == .wood_shack);
                const max_cap = if (is_gh) GREENHOUSE_CAPACITY else if (is_lab_b) LAB_CAPACITY else if (is_cm) COAL_MINE_CAPACITY else if (is_ws) WOOD_SHACK_CAPACITY else STEEL_FORGE_CAPACITY;
                const assigned = b.assigned_workers;

                const primary_color = if (is_gh)
                    rl.Color.init(60, 195, 125, 255)
                else if (is_lab_b)
                    rl.Color.init(100, 215, 255, 255)
                else if (is_cm)
                    rl.Color.init(245, 175, 65, 255)
                else if (is_ws)
                    rl.Color.init(195, 130, 80, 255)
                else
                    rl.Color.init(140, 175, 215, 255);

                const bg_color = if (is_selected)
                    rl.Color.init(35, 48, 65, 250)
                else if (is_hovered)
                    rl.Color.init(32, 40, 52, 245)
                else
                    rl.Color.init(18, 22, 28, 230);

                const border_color = if (is_selected or is_hovered)
                    rl.Color.init(255, 215, 80, 255)
                else
                    primary_color;

                rl.drawRectangleRounded(br, 0.25, 6, bg_color);
                rl.drawRectangleRoundedLinesEx(br, 0.25, 6, if (is_selected or is_hovered) 2.0 else 1.2, border_color);

                // Building color icon pill
                rl.drawRectangle(@intFromFloat(br.x + 8), @intFromFloat(br.y + 7), 12, 14, primary_color);

                // Building Name
                const name_text = if (is_gh) "Greenhouse" else if (is_lab_b) "Lab" else if (is_cm) "Coal Mine" else if (is_ws) "Wood Shack" else "Steel Forge";
                rl.drawText(
                    name_text,
                    @intFromFloat(br.x + 25),
                    @intFromFloat(br.y + 4),
                    11,
                    if (is_hovered or is_selected) rl.Color.init(255, 225, 120, 255) else rl.Color.white,
                );

                // Worker count: "X/10 workers"
                const count_text = fmt("{d}/{d} workers", .{ assigned, max_cap });
                rl.drawText(
                    count_text,
                    @intFromFloat(br.x + 25),
                    @intFromFloat(br.y + 15),
                    10,
                    if (assigned >= max_cap)
                        rl.Color.init(245, 205, 70, 255)
                    else if (assigned > 0)
                        rl.Color.init(120, 230, 140, 255)
                    else
                        rl.Color.init(150, 165, 180, 255),
                );

                // Right manage prompt
                rl.drawText(
                    if (is_selected) "OPEN" else if (is_hovered) "CLICK" else "MANAGE",
                    @intFromFloat(br.x + br.width - 48),
                    @intFromFloat(br.y + 9),
                    9,
                    if (is_selected) rl.Color.init(245, 205, 70, 255) else if (is_hovered) rl.Color.init(255, 215, 80, 255) else rl.Color.init(130, 150, 175, 255),
                );

                // For completed Labs when research is active: draw the circular progress bar & spinner above the badge
                if (b.btype == .lab and isResearchActive()) {
                    const spinner_center = rl.Vector2{ .x = screen_pos.x, .y = br.y - 25.0 };
                    const progress = getActiveResearchProgress();
                    const speed_mult = getResearchSpeedMultiplier();

                    // Connecting vertical line to badge
                    rl.drawLineEx(
                        .{ .x = screen_pos.x, .y = br.y - 7.0 },
                        .{ .x = screen_pos.x, .y = br.y },
                        2.0,
                        if (is_hovered or is_selected) rl.Color.init(255, 215, 80, 255) else rl.Color.init(65, 150, 195, 220),
                    );

                    // Top status pill
                    const res_label = if (speed_mult > 0.0) "RESEARCHING" else "PAUSED";
                    const rlw = rl.measureText(res_label, 9);
                    const pill_w: f32 = @as(f32, @floatFromInt(rlw)) + 12.0;
                    const pill_x = screen_pos.x - pill_w / 2.0;
                    const pill_y = br.y - 56.0;
                    rl.drawRectangle(@intFromFloat(pill_x), @intFromFloat(pill_y), @intFromFloat(pill_w), 13, rl.Color.init(15, 22, 32, 230));
                    rl.drawRectangleLines(@intFromFloat(pill_x), @intFromFloat(pill_y), @intFromFloat(pill_w), 13, if (speed_mult > 0.0) rl.Color.init(60, 180, 230, 200) else rl.Color.init(245, 120, 100, 200));
                    rl.drawText(
                        res_label,
                        @intFromFloat(screen_pos.x - @as(f32, @floatFromInt(rlw)) / 2.0),
                        @intFromFloat(pill_y + 2.0),
                        9,
                        if (speed_mult > 0.0) rl.Color.init(130, 230, 255, 255) else rl.Color.init(255, 130, 110, 255),
                    );

                    drawLabResearchSpinner(spinner_center, 18.0, progress, speed_mult, is_paused);
                }
            }
        }
    }
}

fn drawBuildingDialog(camera: rl.Camera3D, sw_f: f32, sh_f: f32) void {
    if (selected_building) |bid| {
        if (bid < buildings_count) {
            const b = buildings[bid];
            const rect = getBuildingDialogRect(b, camera, sw_f, sh_f) orelse return;
            const panel_x: f32 = rect.x;
            const panel_y: f32 = rect.y;
            const panel_w: f32 = rect.width;
            const panel_h: f32 = rect.height;

            const is_lab = (b.btype == .lab);
            const is_gh = (b.btype == .greenhouse);
            const is_cm = (b.btype == .coal_mine);
            const is_ws = (b.btype == .wood_shack);
            const is_sf = (b.btype == .steel_forge);

            const border_color = if (b.state == .dismantling)
                COLOR_DISMANTLE_SCAFFOLD
            else if (is_gh)
                rl.Color.init(60, 195, 125, 255)
            else if (is_lab)
                rl.Color.init(65, 150, 195, 255)
            else if (is_cm)
                rl.Color.init(235, 165, 60, 255)
            else if (is_ws)
                rl.Color.init(195, 130, 80, 255)
            else if (is_sf)
                rl.Color.init(120, 185, 245, 255)
            else
                rl.Color.init(184, 138, 72, 255);

            // Connecting line from card to building roof anchor
            const anchor_screen = rl.getWorldToScreen(.{ .x = b.pos.x, .y = 3.8, .z = b.pos.z }, camera);
            const card_connect_y = if (rect.y < anchor_screen.y) rect.y + rect.height else rect.y;
            const card_connect_x = std.math.clamp(anchor_screen.x, rect.x + 16.0, rect.x + rect.width - 16.0);
            rl.drawLineEx(
                .{ .x = card_connect_x, .y = card_connect_y },
                .{ .x = anchor_screen.x, .y = anchor_screen.y },
                2.0,
                border_color,
            );

            rl.drawRectangleRounded(rl.Rectangle.init(panel_x, panel_y, panel_w, panel_h), 0.04, 8, rl.Color.init(20, 24, 32, 245));
            rl.drawRectangleRoundedLinesEx(rl.Rectangle.init(panel_x, panel_y, panel_w, panel_h), 0.04, 8, 2.0, border_color);

            // Title icon + text
            const icon_color = if (is_gh)
                COLOR_GREENHOUSE_ROOF
            else if (is_lab)
                COLOR_LAB_DOME
            else if (is_cm)
                COLOR_COAL_MINE_HEADFRAME
            else if (is_ws)
                COLOR_WOOD_SHACK_LOGS
            else if (is_sf)
                COLOR_STEEL_FORGE_STEEL
            else
                COLOR_WOOD_PILE;
            rl.drawRectangle(@intFromFloat(panel_x + 14), @intFromFloat(panel_y + 12), 12, 14, icon_color);
            const title_str = if (is_gh)
                fmt("GREENHOUSE #{d}", .{bid + 1})
            else if (is_lab)
                fmt("LAB #{d}", .{bid + 1})
            else if (is_cm)
                fmt("COAL MINE #{d}", .{bid + 1})
            else if (is_ws)
                fmt("WOOD SHACK #{d}", .{bid + 1})
            else if (is_sf)
                fmt("STEEL FORGE #{d}", .{bid + 1})
            else
                fmt("HOUSE #{d}", .{bid + 1});
            rl.drawText(
                title_str,
                @intFromFloat(panel_x + 32),
                @intFromFloat(panel_y + 10),
                16,
                if (is_gh)
                    rl.Color.init(110, 240, 160, 255)
                else if (is_lab)
                    rl.Color.init(130, 225, 255, 255)
                else if (is_cm)
                    rl.Color.init(250, 195, 80, 255)
                else if (is_ws)
                    rl.Color.init(245, 185, 120, 255)
                else if (is_sf)
                    rl.Color.init(175, 205, 245, 255)
                else
                    rl.Color.init(245, 205, 70, 255),
            );

            // Close button [x]
            if (!is_paused) {
                if (rg.button(rl.Rectangle.init(panel_x + panel_w - 28, panel_y + 8, 20, 20), "x")) {
                    selected_building = null;
                }
            }

            // Subtitle & Grid coordinates
            const subtitle = if (is_gh)
                fmt("Agricultural Complex | Grid: ({d}, {d})", .{ b.grid_x, b.grid_z })
            else if (is_lab)
                fmt("Research Facility | Grid: ({d}, {d})", .{ b.grid_x, b.grid_z })
            else if (is_cm)
                fmt("Extraction Facility | Grid: ({d}, {d})", .{ b.grid_x, b.grid_z })
            else if (is_ws)
                fmt("Timber Facility | Grid: ({d}, {d})", .{ b.grid_x, b.grid_z })
            else if (is_sf)
                fmt("Metallurgical Facility | Grid: ({d}, {d})", .{ b.grid_x, b.grid_z })
            else
                fmt("Residential Shelter | Grid: ({d}, {d})", .{ b.grid_x, b.grid_z });
            rl.drawText(subtitle, @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 30), 11, rl.Color.init(140, 175, 210, 255));

            // Status & Info rows
            if (b.state == .completed) {
                if (is_gh) {
                    const status_str = if (b.assigned_workers >= GREENHOUSE_CAPACITY) "STATUS: FULL PRODUCTION" else if (b.assigned_workers > 0) "STATUS: PARTIAL PRODUCTION" else "STATUS: UNSTAFFED (IDLE)";
                    rl.drawText(status_str, @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 50), 11, if (b.assigned_workers > 0) rl.Color.init(100, 230, 140, 255) else rl.Color.init(245, 195, 65, 255));

                    const staff_str = fmt("Staff: {d} / {d} Workers", .{ b.assigned_workers, GREENHOUSE_CAPACITY });
                    rl.drawText(staff_str, @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 68), 13, rl.Color.white);

                    const yield_str = fmt("Yield: +{d:.1} Food/sec", .{@as(f32, @floatFromInt(b.assigned_workers)) * 1.0});
                    rl.drawText(yield_str, @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 86), 12, rl.Color.init(110, 235, 150, 255));

                    // Worker control buttons: None, -1, +1, Max
                    if (!is_paused) {
                        if (rg.button(rl.Rectangle.init(panel_x + 14, panel_y + 104, 48, 22), "None")) {
                            assignGreenhouseWorkers(bid, -b.assigned_workers);
                        }
                        if (rg.button(rl.Rectangle.init(panel_x + 68, panel_y + 104, 38, 22), "-1")) {
                            assignGreenhouseWorkers(bid, -1);
                        }
                        if (rg.button(rl.Rectangle.init(panel_x + 112, panel_y + 104, 38, 22), "+1")) {
                            assignGreenhouseWorkers(bid, 1);
                        }
                        if (rg.button(rl.Rectangle.init(panel_x + 156, panel_y + 104, 48, 22), "Max")) {
                            assignGreenhouseWorkers(bid, GREENHOUSE_CAPACITY);
                        }
                    }

                    if (b.is_warm) {
                        rl.drawText("Heating: WARM (In Heat Zone)", @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 134), 11, COLOR_CITIZEN_WARM);
                    } else {
                        rl.drawText("Heating: COLD (Outside Heat Zone)", @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 134), 11, rl.Color.init(110, 185, 255, 255));
                    }

                    // Action button: Destroy
                    if (!is_paused) {
                        if (rg.button(rl.Rectangle.init(panel_x + 14, panel_y + 156, panel_w - 28, 24), "Destroy")) {
                            if (b.assigned_workers > 0) {
                                assignGreenhouseWorkers(bid, -b.assigned_workers);
                            }
                            buildings[bid].state = .dismantling;
                            buildings[bid].progress = 1.0;
                            buildings[bid].active_builders = 0;
                            if (!hasCompletedLab() and research_menu_open) {
                                research_menu_open = false;
                            }
                        }
                    }
                    rl.drawText("Demolition refunds wood upon completion", @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 190), 11, rl.Color.init(140, 155, 175, 255));
                } else if (is_lab) {
                    const is_active_res = isResearchActive();
                    const speed_mult = getResearchSpeedMultiplier();
                    const status_str = if (!is_active_res)
                        "STATUS: IDLE (NO RESEARCH)"
                    else if (speed_mult > 0.0)
                        (if (b.assigned_workers >= LAB_CAPACITY) "STATUS: FULL RESEARCH" else "STATUS: RESEARCHING")
                    else
                        "STATUS: UNSTAFFED (HALTED)";
                    rl.drawText(status_str, @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 50), 11, if (speed_mult > 0.0 and is_active_res) rl.Color.init(100, 225, 255, 255) else rl.Color.init(245, 195, 65, 255));

                    const staff_str = fmt("Staff: {d} / {d} Researchers", .{ b.assigned_workers, LAB_CAPACITY });
                    rl.drawText(staff_str, @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 68), 13, rl.Color.white);

                    const speed_pct = @as(i32, @intFromFloat(speed_mult * 100.0));
                    const total_lab_staff = getTotalLabWorkers();
                    const speed_str = if (is_active_res)
                        (if (total_lab_staff > getMaxEffectiveResearchWorkers())
                            fmt("Colony Speed: {d}% (Cap 4 Labs)", .{speed_pct})
                        else
                            fmt("Colony Speed: {d}%", .{speed_pct}))
                    else
                        "Colony Speed: 0% (Idle)";
                    rl.drawText(speed_str, @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 86), 12, if (speed_mult > 0.0 and is_active_res) rl.Color.init(130, 230, 255, 255) else rl.Color.init(255, 120, 100, 255));

                    // Draw the circular research spinner inside the dialog card when research is active
                    if (is_active_res) {
                        const dlg_spinner_center = rl.Vector2{ .x = panel_x + panel_w - 44.0, .y = panel_y + 68.0 };
                        drawLabResearchSpinner(dlg_spinner_center, 18.0, getActiveResearchProgress(), speed_mult, is_paused);
                    }

                    // Worker control buttons: None, -1, +1, Max
                    if (!is_paused) {
                        if (rg.button(rl.Rectangle.init(panel_x + 14, panel_y + 104, 48, 22), "None")) {
                            assignLabWorkers(bid, -b.assigned_workers);
                        }
                        if (rg.button(rl.Rectangle.init(panel_x + 68, panel_y + 104, 38, 22), "-1")) {
                            assignLabWorkers(bid, -1);
                        }
                        if (rg.button(rl.Rectangle.init(panel_x + 112, panel_y + 104, 38, 22), "+1")) {
                            assignLabWorkers(bid, 1);
                        }
                        if (rg.button(rl.Rectangle.init(panel_x + 156, panel_y + 104, 48, 22), "Max")) {
                            assignLabWorkers(bid, LAB_CAPACITY);
                        }
                    }

                    if (b.is_warm) {
                        rl.drawText("Heating: WARM (In Heat Zone)", @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 134), 11, COLOR_CITIZEN_WARM);
                    } else {
                        rl.drawText("Heating: COLD (Outside Heat Zone)", @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 134), 11, rl.Color.init(110, 185, 255, 255));
                    }

                    // Action button: Destroy
                    if (!is_paused) {
                        if (rg.button(rl.Rectangle.init(panel_x + 14, panel_y + 156, panel_w - 28, 24), "Destroy")) {
                            if (b.assigned_workers > 0) {
                                assignLabWorkers(bid, -b.assigned_workers);
                            }
                            buildings[bid].state = .dismantling;
                            buildings[bid].progress = 1.0;
                            buildings[bid].active_builders = 0;
                            if (!hasCompletedLab() and research_menu_open) {
                                research_menu_open = false;
                            }
                        }
                    }
                    rl.drawText("Demolition refunds wood upon completion", @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 190), 11, rl.Color.init(140, 155, 175, 255));
                } else if (is_cm) {
                    const status_str = if (b.assigned_workers >= COAL_MINE_CAPACITY) "STATUS: FULL EXTRACTION" else if (b.assigned_workers > 0) "STATUS: PARTIAL EXTRACTION" else "STATUS: UNSTAFFED (IDLE)";
                    rl.drawText(status_str, @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 50), 11, if (b.assigned_workers > 0) rl.Color.init(100, 230, 140, 255) else rl.Color.init(245, 195, 65, 255));

                    const staff_str = fmt("Staff: {d} / {d} Miners", .{ b.assigned_workers, COAL_MINE_CAPACITY });
                    rl.drawText(staff_str, @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 68), 13, rl.Color.white);

                    const yield_str = fmt("Yield: +{d:.1} Coal/sec", .{@as(f32, @floatFromInt(b.assigned_workers)) * COAL_MINE_COAL_RATE_PER_WORKER_PER_SEC});
                    rl.drawText(yield_str, @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 86), 12, rl.Color.init(245, 205, 80, 255));

                    // Worker control buttons: None, -1, +1, Max
                    if (!is_paused) {
                        if (rg.button(rl.Rectangle.init(panel_x + 14, panel_y + 104, 48, 22), "None")) {
                            assignCoalMineWorkers(bid, -b.assigned_workers);
                        }
                        if (rg.button(rl.Rectangle.init(panel_x + 68, panel_y + 104, 38, 22), "-1")) {
                            assignCoalMineWorkers(bid, -1);
                        }
                        if (rg.button(rl.Rectangle.init(panel_x + 112, panel_y + 104, 38, 22), "+1")) {
                            assignCoalMineWorkers(bid, 1);
                        }
                        if (rg.button(rl.Rectangle.init(panel_x + 156, panel_y + 104, 48, 22), "Max")) {
                            assignCoalMineWorkers(bid, COAL_MINE_CAPACITY);
                        }
                    }

                    if (b.is_warm) {
                        rl.drawText("Heating: WARM (In Heat Zone)", @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 134), 11, COLOR_CITIZEN_WARM);
                    } else {
                        rl.drawText("Heating: COLD (Outside Heat Zone)", @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 134), 11, rl.Color.init(110, 185, 255, 255));
                    }

                    // Action button: Destroy
                    if (!is_paused) {
                        if (rg.button(rl.Rectangle.init(panel_x + 14, panel_y + 156, panel_w - 28, 24), "Destroy")) {
                            if (b.assigned_workers > 0) {
                                assignCoalMineWorkers(bid, -b.assigned_workers);
                            }
                            buildings[bid].state = .dismantling;
                            buildings[bid].progress = 1.0;
                            buildings[bid].active_builders = 0;
                            if (!hasCompletedLab() and research_menu_open) {
                                research_menu_open = false;
                            }
                        }
                    }
                    rl.drawText("Demolition refunds resources upon completion", @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 190), 11, rl.Color.init(140, 155, 175, 255));
                } else if (is_ws) {
                    const status_str = if (b.assigned_workers >= WOOD_SHACK_CAPACITY) "STATUS: FULL PRODUCTION" else if (b.assigned_workers > 0) "STATUS: PARTIAL PRODUCTION" else "STATUS: UNSTAFFED (IDLE)";
                    rl.drawText(status_str, @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 50), 11, if (b.assigned_workers > 0) rl.Color.init(100, 230, 140, 255) else rl.Color.init(245, 195, 65, 255));

                    const staff_str = fmt("Staff: {d} / {d} Lumberjacks", .{ b.assigned_workers, WOOD_SHACK_CAPACITY });
                    rl.drawText(staff_str, @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 68), 13, rl.Color.white);

                    const yield_str = fmt("Yield: +{d:.1} Wood/sec (Infinite)", .{@as(f32, @floatFromInt(b.assigned_workers)) * WOOD_SHACK_WOOD_RATE_PER_WORKER_PER_SEC});
                    rl.drawText(yield_str, @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 86), 12, rl.Color.init(235, 175, 100, 255));

                    // Worker control buttons: None, -1, +1, Max
                    if (!is_paused) {
                        if (rg.button(rl.Rectangle.init(panel_x + 14, panel_y + 104, 48, 22), "None")) {
                            assignWoodShackWorkers(bid, -b.assigned_workers);
                        }
                        if (rg.button(rl.Rectangle.init(panel_x + 68, panel_y + 104, 38, 22), "-1")) {
                            assignWoodShackWorkers(bid, -1);
                        }
                        if (rg.button(rl.Rectangle.init(panel_x + 112, panel_y + 104, 38, 22), "+1")) {
                            assignWoodShackWorkers(bid, 1);
                        }
                        if (rg.button(rl.Rectangle.init(panel_x + 156, panel_y + 104, 48, 22), "Max")) {
                            assignWoodShackWorkers(bid, WOOD_SHACK_CAPACITY);
                        }
                    }

                    if (b.is_warm) {
                        rl.drawText("Heating: WARM (In Heat Zone)", @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 134), 11, COLOR_CITIZEN_WARM);
                    } else {
                        rl.drawText("Heating: COLD (Outside Heat Zone)", @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 134), 11, rl.Color.init(110, 185, 255, 255));
                    }

                    // Action button: Destroy
                    if (!is_paused) {
                        if (rg.button(rl.Rectangle.init(panel_x + 14, panel_y + 156, panel_w - 28, 24), "Destroy")) {
                            if (b.assigned_workers > 0) {
                                assignWoodShackWorkers(bid, -b.assigned_workers);
                            }
                            buildings[bid].state = .dismantling;
                            buildings[bid].progress = 1.0;
                            buildings[bid].active_builders = 0;
                            if (!hasCompletedLab() and research_menu_open) {
                                research_menu_open = false;
                            }
                        }
                    }
                    rl.drawText("Demolition refunds resources upon completion", @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 190), 11, rl.Color.init(140, 155, 175, 255));
                } else if (is_sf) {
                    const status_str = if (b.assigned_workers >= STEEL_FORGE_CAPACITY) "STATUS: FULL PRODUCTION" else if (b.assigned_workers > 0) "STATUS: PARTIAL PRODUCTION" else "STATUS: UNSTAFFED (IDLE)";
                    rl.drawText(status_str, @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 50), 11, if (b.assigned_workers > 0) rl.Color.init(100, 230, 140, 255) else rl.Color.init(245, 195, 65, 255));

                    const staff_str = fmt("Staff: {d} / {d} Smiths", .{ b.assigned_workers, STEEL_FORGE_CAPACITY });
                    rl.drawText(staff_str, @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 68), 13, rl.Color.white);

                    const yield_str = fmt("Yield: +{d:.1} Steel/sec (Infinite)", .{@as(f32, @floatFromInt(b.assigned_workers)) * STEEL_FORGE_STEEL_RATE_PER_WORKER_PER_SEC});
                    rl.drawText(yield_str, @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 86), 12, rl.Color.init(160, 210, 250, 255));

                    // Worker control buttons: None, -1, +1, Max
                    if (!is_paused) {
                        if (rg.button(rl.Rectangle.init(panel_x + 14, panel_y + 104, 48, 22), "None")) {
                            assignSteelForgeWorkers(bid, -b.assigned_workers);
                        }
                        if (rg.button(rl.Rectangle.init(panel_x + 68, panel_y + 104, 38, 22), "-1")) {
                            assignSteelForgeWorkers(bid, -1);
                        }
                        if (rg.button(rl.Rectangle.init(panel_x + 112, panel_y + 104, 38, 22), "+1")) {
                            assignSteelForgeWorkers(bid, 1);
                        }
                        if (rg.button(rl.Rectangle.init(panel_x + 156, panel_y + 104, 48, 22), "Max")) {
                            assignSteelForgeWorkers(bid, STEEL_FORGE_CAPACITY);
                        }
                    }

                    if (b.is_warm) {
                        rl.drawText("Heating: WARM (In Heat Zone)", @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 134), 11, COLOR_CITIZEN_WARM);
                    } else {
                        rl.drawText("Heating: COLD (Outside Heat Zone)", @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 134), 11, rl.Color.init(110, 185, 255, 255));
                    }

                    // Action button: Destroy
                    if (!is_paused) {
                        if (rg.button(rl.Rectangle.init(panel_x + 14, panel_y + 156, panel_w - 28, 24), "Destroy")) {
                            if (b.assigned_workers > 0) {
                                assignSteelForgeWorkers(bid, -b.assigned_workers);
                            }
                            buildings[bid].state = .dismantling;
                            buildings[bid].progress = 1.0;
                            buildings[bid].active_builders = 0;
                            if (!hasCompletedLab() and research_menu_open) {
                                research_menu_open = false;
                            }
                        }
                    }
                    rl.drawText("Demolition refunds resources upon completion", @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 190), 11, rl.Color.init(140, 155, 175, 255));
                } else {
                    rl.drawText("STATUS: INHABITED", @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 54), 12, rl.Color.init(100, 220, 140, 255));
                    const cap_str = fmt("Shelter: {d} Citizens", .{b.btype.capacity()});
                    _ = rl.drawText(cap_str, @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 74), 13, rl.Color.white);
                    if (b.is_warm) {
                        rl.drawText("Heating: WARM (In Heat Zone)", @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 94), 12, COLOR_CITIZEN_WARM);
                    } else {
                        rl.drawText("Heating: COLD (Outside Heat Zone)", @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 94), 12, rl.Color.init(110, 185, 255, 255));
                    }

                    // Action button: Destroy
                    if (!is_paused) {
                        if (rg.button(rl.Rectangle.init(panel_x + 14, panel_y + 118, panel_w - 28, 26), "Destroy")) {
                            buildings[bid].state = .dismantling;
                            buildings[bid].progress = 1.0;
                            buildings[bid].active_builders = 0;
                            if (!hasCompletedLab() and research_menu_open) {
                                research_menu_open = false;
                            }
                        }
                    }
                    rl.drawText("Demolition refunds wood upon completion", @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 154), 11, rl.Color.init(140, 155, 175, 255));
                }
            } else if (b.state == .constructing) {
                rl.drawText("STATUS: UNDER CONSTRUCTION", @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 54), 12, rl.Color.init(245, 195, 65, 255));
                const pct = @as(i32, @intFromFloat(b.progress * 100.0));
                _ = rl.drawText(fmt("Progress: {d}%", .{pct}), @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 74), 13, rl.Color.white);
                _ = rl.drawText(fmt("Active Builders: {d}/{d}", .{ b.active_builders, b.btype.maxBuilders() }), @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 94), 12, rl.Color.init(180, 200, 220, 255));

                // Action button: Cancel
                if (!is_paused) {
                    if (rg.button(rl.Rectangle.init(panel_x + 14, panel_y + 118, panel_w - 28, 26), "Cancel")) {
                        stockpiles[@intFromEnum(Resource.wood)] += b.btype.woodCost();
                        stockpiles[@intFromEnum(Resource.steel)] += b.btype.steelCost();
                        removeBuilding(bid);
                        selected_building = null;
                        if (!hasCompletedLab() and research_menu_open) {
                            research_menu_open = false;
                        }
                    }
                }
                rl.drawText("Canceling refunds all construction resources", @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 154), 11, rl.Color.init(140, 155, 175, 255));
            } else if (b.state == .dismantling) {
                rl.drawText("STATUS: DISMANTLING", @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 54), 12, rl.Color.init(245, 95, 75, 255));
                const pct = @as(i32, @intFromFloat((1.0 - b.progress) * 100.0));
                _ = rl.drawText(fmt("Dismantling: {d}%", .{pct}), @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 74), 13, rl.Color.white);
                _ = rl.drawText(fmt("Active Workers: {d}/{d}", .{ b.active_builders, b.btype.maxBuilders() }), @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 94), 12, rl.Color.init(255, 180, 160, 255));

                // Action button: Cancel Dismantle
                if (!is_paused) {
                    if (rg.button(rl.Rectangle.init(panel_x + 14, panel_y + 118, panel_w - 28, 26), "Cancel Dismantle")) {
                        buildings[bid].state = .completed;
                        buildings[bid].progress = 1.0;
                        buildings[bid].active_builders = 0;
                    }
                }
                rl.drawText("Workers are tearing down the building", @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 154), 11, rl.Color.init(140, 155, 175, 255));
            }
        }
    }
}

fn drawBuildUI(mouse_pos: rl.Vector2) void {
    const sw = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const sh = @as(f32, @floatFromInt(rl.getScreenHeight()));

    // 1. Build Button (Bottom-Left)
    const btn_rect = getBuildBtnRect(sh);
    const btn_x = btn_rect.x;
    const btn_y = btn_rect.y;
    const btn_hovered = rl.checkCollisionPointRec(mouse_pos, btn_rect);

    const btn_bg = if (build_menu_open)
        rl.Color.init(245, 195, 65, 255)
    else if (btn_hovered)
        rl.Color.init(42, 52, 68, 255)
    else
        rl.Color.init(22, 28, 38, 245);

    const btn_border = if (build_menu_open)
        rl.Color.init(255, 225, 120, 255)
    else if (btn_hovered)
        rl.Color.init(245, 195, 65, 255)
    else
        rl.Color.init(90, 110, 135, 255);

    const btn_text_color = if (build_menu_open)
        rl.Color.init(15, 18, 24, 255)
    else if (btn_hovered)
        rl.Color.init(255, 225, 120, 255)
    else
        rl.Color.init(220, 230, 240, 255);

    rl.drawRectangleRounded(btn_rect, 0.25, 6, btn_bg);
    rl.drawRectangleRoundedLinesEx(btn_rect, 0.25, 6, if (build_menu_open or btn_hovered) 2.0 else 1.2, btn_border);

    // Accent icon
    rl.drawRectangle(@intFromFloat(btn_x + 12), @intFromFloat(btn_y + 11), 14, 14, if (build_menu_open) rl.Color.init(30, 36, 46, 255) else rl.Color.init(245, 195, 65, 255));
    rl.drawText("[B] BUILD", @intFromFloat(btn_x + 34), @intFromFloat(btn_y + 11), 14, btn_text_color);

    // 2. Build Strip (Bottom Drawer)
    if (build_menu_open) {
        const strip_h: f32 = 148.0;
        const strip_y: f32 = sh - strip_h;
        const strip_rect = rl.Rectangle.init(0, strip_y, sw, strip_h);

        // Dark metal background
        rl.drawRectangleRec(strip_rect, rl.Color.init(18, 22, 30, 248));
        rl.drawRectangle(0, @intFromFloat(strip_y), @intFromFloat(sw), 2, rl.Color.init(65, 80, 102, 255));

        // --- Tabs Header ---
        const tab_y = strip_y + 8.0;
        const tab_w: f32 = 110.0;
        const tab_h: f32 = 28.0;

        // Tab 1: "People"
        const is_people = (active_build_tab == .people);
        const tab_people_rect = rl.Rectangle.init(16.0, tab_y, tab_w, tab_h);
        const people_hovered = rl.checkCollisionPointRec(mouse_pos, tab_people_rect);
        rl.drawRectangleRounded(tab_people_rect, 0.25, 4, if (is_people) rl.Color.init(42, 54, 72, 255) else if (people_hovered) rl.Color.init(32, 40, 52, 220) else rl.Color.init(24, 28, 36, 180));
        if (is_people) {
            rl.drawRectangleRoundedLinesEx(tab_people_rect, 0.25, 4, 1.5, rl.Color.init(245, 195, 65, 255));
            rl.drawRectangle(18, @intFromFloat(tab_y + tab_h - 2), @intFromFloat(tab_w - 4), 2, rl.Color.init(245, 195, 65, 255));
        }
        rl.drawText("PEOPLE", 46, @intFromFloat(tab_y + 7), 13, if (is_people) rl.Color.init(245, 210, 80, 255) else rl.Color.init(140, 155, 175, 255));

        // Tab 2: "Food"
        const is_food = (active_build_tab == .food);
        const tab_food_rect = rl.Rectangle.init(134.0, tab_y, tab_w, tab_h);
        const food_hovered = rl.checkCollisionPointRec(mouse_pos, tab_food_rect);
        rl.drawRectangleRounded(tab_food_rect, 0.25, 4, if (is_food) rl.Color.init(28, 55, 40, 255) else if (food_hovered) rl.Color.init(32, 48, 38, 220) else rl.Color.init(24, 28, 36, 180));
        if (is_food) {
            rl.drawRectangleRoundedLinesEx(tab_food_rect, 0.25, 4, 1.5, rl.Color.init(100, 225, 130, 255));
            rl.drawRectangle(136, @intFromFloat(tab_y + tab_h - 2), @intFromFloat(tab_w - 4), 2, rl.Color.init(100, 225, 130, 255));
        }
        rl.drawText("FOOD", 170, @intFromFloat(tab_y + 7), 13, if (is_food) rl.Color.init(130, 245, 150, 255) else rl.Color.init(140, 155, 175, 255));

        // Tab 3: "Science"
        const is_science = (active_build_tab == .science);
        const tab_science_rect = rl.Rectangle.init(252.0, tab_y, tab_w, tab_h);
        const science_hovered = rl.checkCollisionPointRec(mouse_pos, tab_science_rect);
        rl.drawRectangleRounded(tab_science_rect, 0.25, 4, if (is_science) rl.Color.init(30, 56, 75, 255) else if (science_hovered) rl.Color.init(32, 40, 52, 220) else rl.Color.init(24, 28, 36, 180));
        if (is_science) {
            rl.drawRectangleRoundedLinesEx(tab_science_rect, 0.25, 4, 1.5, rl.Color.init(100, 215, 255, 255));
            rl.drawRectangle(254, @intFromFloat(tab_y + tab_h - 2), @intFromFloat(tab_w - 4), 2, rl.Color.init(100, 215, 255, 255));
        }
        rl.drawText("SCIENCE", 278, @intFromFloat(tab_y + 7), 13, if (is_science) rl.Color.init(130, 225, 255, 255) else rl.Color.init(140, 155, 175, 255));

        // Tab 4: "Resources"
        const is_resources = (active_build_tab == .resources);
        const tab_res_rect = rl.Rectangle.init(370.0, tab_y, tab_w + 10, tab_h);
        const res_hovered = rl.checkCollisionPointRec(mouse_pos, tab_res_rect);
        rl.drawRectangleRounded(tab_res_rect, 0.25, 4, if (is_resources) rl.Color.init(48, 42, 34, 255) else if (res_hovered) rl.Color.init(42, 38, 32, 220) else rl.Color.init(24, 28, 36, 180));
        if (is_resources) {
            rl.drawRectangleRoundedLinesEx(tab_res_rect, 0.25, 4, 1.5, rl.Color.init(245, 180, 60, 255));
            rl.drawRectangle(372, @intFromFloat(tab_y + tab_h - 2), @intFromFloat(tab_w + 6), 2, rl.Color.init(245, 180, 60, 255));
        }
        rl.drawText("RESOURCES", 382, @intFromFloat(tab_y + 7), 12, if (is_resources) rl.Color.init(255, 205, 80, 255) else rl.Color.init(140, 155, 175, 255));

        const tab_heat_rect = rl.Rectangle.init(498.0, tab_y, tab_w, tab_h);
        rl.drawRectangleRounded(tab_heat_rect, 0.25, 4, rl.Color.init(24, 28, 36, 140));
        rl.drawText("HEATING", 520, @intFromFloat(tab_y + 7), 12, rl.Color.init(90, 100, 115, 255));

        // Close button [x]
        const close_btn_rect = rl.Rectangle.init(sw - 36.0, tab_y, 24.0, 24.0);
        const close_hovered = rl.checkCollisionPointRec(mouse_pos, close_btn_rect);
        rl.drawRectangleRounded(close_btn_rect, 0.2, 4, if (close_hovered) rl.Color.init(200, 50, 50, 255) else rl.Color.init(32, 38, 48, 255));
        rl.drawText("x", @intFromFloat(sw - 29), @intFromFloat(tab_y + 3), 15, rl.Color.white);

        // --- Active Tab Content ---
        if (active_build_tab == .people) {
            // House Card
            const card_x: f32 = 16.0;
            const card_y: f32 = strip_y + 44.0;
            const card_w: f32 = 230.0;
            const card_h: f32 = 92.0;
            const card_rect = rl.Rectangle.init(card_x, card_y, card_w, card_h);
            const card_hovered = rl.checkCollisionPointRec(mouse_pos, card_rect);

            const current_wood = stockpiles[@intFromEnum(Resource.wood)];
            const can_afford = current_wood >= HOUSE_WOOD_COST;

            const card_bg = if (card_hovered)
                rl.Color.init(34, 42, 56, 255)
            else
                rl.Color.init(24, 30, 40, 240);

            const card_border = if (card_hovered)
                rl.Color.init(245, 195, 65, 255)
            else
                rl.Color.init(65, 80, 102, 255);

            rl.drawRectangleRounded(card_rect, 0.12, 6, card_bg);
            rl.drawRectangleRoundedLinesEx(card_rect, 0.12, 6, if (card_hovered) 2.0 else 1.2, card_border);

            // Mini House Preview Icon
            rl.drawRectangle(@intFromFloat(card_x + 12), @intFromFloat(card_y + 14), 28, 22, COLOR_HOUSE_WALLS);
            rl.drawRectangle(@intFromFloat(card_x + 10), @intFromFloat(card_y + 8), 32, 8, COLOR_HOUSE_ROOF);
            rl.drawRectangle(@intFromFloat(card_x + 28), @intFromFloat(card_y + 4), 6, 8, COLOR_HOUSE_CHIMNEY);

            // Building Name
            rl.drawText("House", @intFromFloat(card_x + 50), @intFromFloat(card_y + 10), 16, rl.Color.white);

            // Cost Badge
            const cost_pill_rect = rl.Rectangle.init(card_x + 50, card_y + 32, 102, 20);
            rl.drawRectangleRounded(cost_pill_rect, 0.3, 4, if (can_afford) rl.Color.init(28, 55, 38, 255) else rl.Color.init(60, 28, 28, 255));
            rl.drawRectangleRoundedLinesEx(cost_pill_rect, 0.3, 4, 1.0, if (can_afford) rl.Color.init(80, 185, 115, 255) else rl.Color.init(215, 70, 70, 255));
            const cost_text = fmt("Cost: {d} Wood", .{@as(i32, @intFromFloat(HOUSE_WOOD_COST))});
            rl.drawText(cost_text, @intFromFloat(card_x + 56), @intFromFloat(card_y + 36), 11, if (can_afford) rl.Color.init(120, 235, 150, 255) else rl.Color.init(255, 120, 120, 255));

            // Footprint, Capacity & Builder Specs
            rl.drawText("Footprint: 2x2 Grid Squares", @intFromFloat(card_x + 50), @intFromFloat(card_y + 56), 10, rl.Color.init(245, 205, 70, 255));
            rl.drawText("Shelter: 10 Citizens | Max 10 Workers", @intFromFloat(card_x + 50), @intFromFloat(card_y + 70), 10, rl.Color.init(160, 180, 205, 255));

            // Click instruction tip
            if (card_hovered) {
                rl.drawText(
                    if (can_afford) "Click to select and place in the snow" else "Cannot afford (Requires 20 Wood)",
                    @intFromFloat(card_x + card_w + 16),
                    @intFromFloat(card_y + 36),
                    13,
                    if (can_afford) rl.Color.init(245, 205, 70, 255) else rl.Color.init(255, 100, 90, 255),
                );
            }
        } else if (active_build_tab == .food) {
            const is_unlocked = (greenhouses_research_state == .completed);
            const card_x: f32 = 16.0;
            const card_y: f32 = strip_y + 44.0;
            const card_w: f32 = 250.0;
            const card_h: f32 = 92.0;
            const card_rect = rl.Rectangle.init(card_x, card_y, card_w, card_h);
            const card_hovered = rl.checkCollisionPointRec(mouse_pos, card_rect);

            const current_wood = stockpiles[@intFromEnum(Resource.wood)];
            const can_afford = current_wood >= GREENHOUSE_WOOD_COST;

            if (is_unlocked) {
                const card_bg = if (card_hovered)
                    rl.Color.init(24, 48, 36, 255)
                else
                    rl.Color.init(18, 34, 26, 240);

                const card_border = if (card_hovered)
                    rl.Color.init(90, 225, 135, 255)
                else
                    rl.Color.init(45, 95, 65, 255);

                rl.drawRectangleRounded(card_rect, 0.12, 6, card_bg);
                rl.drawRectangleRoundedLinesEx(card_rect, 0.12, 6, if (card_hovered) 2.0 else 1.2, card_border);

                // Mini Greenhouse Preview Icon
                rl.drawRectangle(@intFromFloat(card_x + 10), @intFromFloat(card_y + 14), 30, 20, COLOR_GREENHOUSE_WALLS);
                rl.drawRectangle(@intFromFloat(card_x + 8), @intFromFloat(card_y + 10), 34, 6, COLOR_GREENHOUSE_ROOF);
                rl.drawRectangle(@intFromFloat(card_x + 14), @intFromFloat(card_y + 18), 22, 14, COLOR_GREENHOUSE_GLASS);
                rl.drawRectangle(@intFromFloat(card_x + 17), @intFromFloat(card_y + 24), 16, 6, COLOR_GREENHOUSE_CROPS);

                // Building Name
                rl.drawText("Greenhouse", @intFromFloat(card_x + 50), @intFromFloat(card_y + 10), 16, rl.Color.white);

                // Cost Badge
                const cost_pill_rect = rl.Rectangle.init(card_x + 50, card_y + 32, 102, 20);
                rl.drawRectangleRounded(cost_pill_rect, 0.3, 4, if (can_afford) rl.Color.init(28, 55, 38, 255) else rl.Color.init(60, 28, 28, 255));
                rl.drawRectangleRoundedLinesEx(cost_pill_rect, 0.3, 4, 1.0, if (can_afford) rl.Color.init(80, 185, 115, 255) else rl.Color.init(215, 70, 70, 255));
                const cost_text = fmt("Cost: {d} Wood", .{@as(i32, @intFromFloat(GREENHOUSE_WOOD_COST))});
                rl.drawText(cost_text, @intFromFloat(card_x + 56), @intFromFloat(card_y + 36), 11, if (can_afford) rl.Color.init(120, 235, 150, 255) else rl.Color.init(255, 120, 120, 255));

                // Footprint, Capacity & Builder Specs
                rl.drawText("Footprint: 2x4 Grid Squares", @intFromFloat(card_x + 50), @intFromFloat(card_y + 56), 10, rl.Color.init(120, 235, 150, 255));
                rl.drawText("Staff: 10 Workers | Produces 10 Food/sec", @intFromFloat(card_x + 50), @intFromFloat(card_y + 70), 10, rl.Color.init(160, 180, 205, 255));

                // Click instruction tip
                if (card_hovered) {
                    rl.drawText(
                        if (can_afford) "Click to select and place in the snow" else "Cannot afford (Requires 20 Wood)",
                        @intFromFloat(card_x + card_w + 16),
                        @intFromFloat(card_y + 36),
                        13,
                        if (can_afford) rl.Color.init(120, 235, 150, 255) else rl.Color.init(255, 100, 90, 255),
                    );
                }
            } else {
                // Locked state
                const card_bg = rl.Color.init(20, 24, 30, 210);
                const card_border = rl.Color.init(50, 60, 72, 200);

                rl.drawRectangleRounded(card_rect, 0.12, 6, card_bg);
                rl.drawRectangleRoundedLinesEx(card_rect, 0.12, 6, 1.0, card_border);

                // Lock icon
                rl.drawRectangle(@intFromFloat(card_x + 14), @intFromFloat(card_y + 16), 24, 22, rl.Color.init(45, 52, 64, 255));
                rl.drawRectangleLines(@intFromFloat(card_x + 14), @intFromFloat(card_y + 16), 24, 22, rl.Color.init(75, 88, 105, 255));
                rl.drawText("?", @intFromFloat(card_x + 22), @intFromFloat(card_y + 18), 16, rl.Color.init(140, 155, 175, 255));

                // Building Name
                rl.drawText("Greenhouse", @intFromFloat(card_x + 50), @intFromFloat(card_y + 10), 16, rl.Color.init(140, 150, 165, 255));

                // Locked badge
                const locked_badge = rl.Rectangle.init(card_x + 50, card_y + 32, 108, 18);
                rl.drawRectangleRounded(locked_badge, 0.3, 4, rl.Color.init(40, 48, 58, 255));
                rl.drawText("[LOCKED - RESEARCH]", @intFromFloat(card_x + 54), @intFromFloat(card_y + 35), 9, rl.Color.init(245, 195, 65, 255));

                rl.drawText("Requires 'Greenhouses' research in Food tab", @intFromFloat(card_x + 50), @intFromFloat(card_y + 56), 10, rl.Color.init(160, 175, 195, 255));
                rl.drawText("2x4 Grid | Staff: 10 | Produces 10 Food/sec", @intFromFloat(card_x + 50), @intFromFloat(card_y + 70), 10, rl.Color.init(120, 135, 150, 255));
            }
        } else if (active_build_tab == .science) {
            // Lab Card
            const card_x: f32 = 16.0;
            const card_y: f32 = strip_y + 44.0;
            const card_w: f32 = 240.0;
            const card_h: f32 = 92.0;
            const card_rect = rl.Rectangle.init(card_x, card_y, card_w, card_h);
            const card_hovered = rl.checkCollisionPointRec(mouse_pos, card_rect);

            const current_wood = stockpiles[@intFromEnum(Resource.wood)];
            const can_afford = current_wood >= LAB_WOOD_COST;

            const card_bg = if (card_hovered)
                rl.Color.init(28, 46, 62, 255)
            else
                rl.Color.init(20, 32, 44, 240);

            const card_border = if (card_hovered)
                rl.Color.init(100, 215, 255, 255)
            else
                rl.Color.init(55, 95, 125, 255);

            rl.drawRectangleRounded(card_rect, 0.12, 6, card_bg);
            rl.drawRectangleRoundedLinesEx(card_rect, 0.12, 6, if (card_hovered) 2.0 else 1.2, card_border);

            // Mini Lab Preview Icon
            rl.drawRectangle(@intFromFloat(card_x + 10), @intFromFloat(card_y + 14), 30, 20, COLOR_LAB_WALLS);
            rl.drawRectangle(@intFromFloat(card_x + 8), @intFromFloat(card_y + 10), 34, 6, COLOR_LAB_ROOF);
            rl.drawCircle(@intFromFloat(card_x + 25), @intFromFloat(card_y + 10), 8, COLOR_LAB_DOME);
            rl.drawRectangle(@intFromFloat(card_x + 32), @intFromFloat(card_y + 4), 4, 8, rl.Color.init(70, 80, 95, 255));

            // Building Name
            rl.drawText("Lab", @intFromFloat(card_x + 50), @intFromFloat(card_y + 10), 16, rl.Color.white);

            // Cost Badge
            const cost_pill_rect = rl.Rectangle.init(card_x + 50, card_y + 32, 102, 20);
            rl.drawRectangleRounded(cost_pill_rect, 0.3, 4, if (can_afford) rl.Color.init(28, 55, 38, 255) else rl.Color.init(60, 28, 28, 255));
            rl.drawRectangleRoundedLinesEx(cost_pill_rect, 0.3, 4, 1.0, if (can_afford) rl.Color.init(80, 185, 115, 255) else rl.Color.init(215, 70, 70, 255));
            const cost_text = fmt("Cost: {d} Wood", .{@as(i32, @intFromFloat(LAB_WOOD_COST))});
            rl.drawText(cost_text, @intFromFloat(card_x + 56), @intFromFloat(card_y + 36), 11, if (can_afford) rl.Color.init(120, 235, 150, 255) else rl.Color.init(255, 120, 120, 255));

            // Footprint, Capacity & Builder Specs
            rl.drawText("Footprint: 3x3 Grid Squares", @intFromFloat(card_x + 50), @intFromFloat(card_y + 56), 10, rl.Color.init(130, 220, 255, 255));
            rl.drawText("Capacity: 10 Workers | Max 10 Builders", @intFromFloat(card_x + 50), @intFromFloat(card_y + 70), 10, rl.Color.init(160, 180, 205, 255));

            // Click instruction tip
            if (card_hovered) {
                rl.drawText(
                    if (can_afford) "Click to select and place in the snow" else "Cannot afford (Requires 30 Wood)",
                    @intFromFloat(card_x + card_w + 16),
                    @intFromFloat(card_y + 36),
                    13,
                    if (can_afford) rl.Color.init(130, 220, 255, 255) else rl.Color.init(255, 100, 90, 255),
                );
            }
        } else if (active_build_tab == .resources) {
            const is_unlocked = (coal_mine_research_state == .completed);
            const card_x: f32 = 16.0;
            const card_y: f32 = strip_y + 44.0;
            const card_w: f32 = 260.0;
            const card_h: f32 = 92.0;
            const card_rect = rl.Rectangle.init(card_x, card_y, card_w, card_h);
            const card_hovered = rl.checkCollisionPointRec(mouse_pos, card_rect);

            const current_wood = stockpiles[@intFromEnum(Resource.wood)];
            const can_afford = current_wood >= COAL_MINE_WOOD_COST;

            if (is_unlocked) {
                const card_bg = if (card_hovered)
                    rl.Color.init(44, 38, 32, 255)
                else
                    rl.Color.init(30, 26, 24, 240);

                const card_border = if (card_hovered)
                    rl.Color.init(250, 195, 75, 255)
                else
                    rl.Color.init(115, 85, 55, 255);

                rl.drawRectangleRounded(card_rect, 0.12, 6, card_bg);
                rl.drawRectangleRoundedLinesEx(card_rect, 0.12, 6, if (card_hovered) 2.0 else 1.2, card_border);

                // Mini Coal Mine Preview Icon
                rl.drawRectangle(@intFromFloat(card_x + 10), @intFromFloat(card_y + 14), 30, 20, COLOR_COAL_MINE_WALLS);
                rl.drawRectangle(@intFromFloat(card_x + 8), @intFromFloat(card_y + 10), 34, 6, COLOR_COAL_MINE_ROOF);
                rl.drawRectangle(@intFromFloat(card_x + 28), @intFromFloat(card_y + 4), 6, 8, COLOR_COAL_MINE_CHIMNEY);
                rl.drawRectangleLines(@intFromFloat(card_x + 14), @intFromFloat(card_y + 16), 14, 18, COLOR_COAL_MINE_HEADFRAME);

                // Building Name
                rl.drawText("Coal Mine", @intFromFloat(card_x + 50), @intFromFloat(card_y + 10), 16, rl.Color.white);

                // Cost Badge
                const cost_pill_rect = rl.Rectangle.init(card_x + 50, card_y + 32, 102, 20);
                rl.drawRectangleRounded(cost_pill_rect, 0.3, 4, if (can_afford) rl.Color.init(28, 55, 38, 255) else rl.Color.init(60, 28, 28, 255));
                rl.drawRectangleRoundedLinesEx(cost_pill_rect, 0.3, 4, 1.0, if (can_afford) rl.Color.init(80, 185, 115, 255) else rl.Color.init(215, 70, 70, 255));
                const cost_text = fmt("Cost: {d} Wood", .{@as(i32, @intFromFloat(COAL_MINE_WOOD_COST))});
                rl.drawText(cost_text, @intFromFloat(card_x + 56), @intFromFloat(card_y + 36), 11, if (can_afford) rl.Color.init(120, 235, 150, 255) else rl.Color.init(255, 120, 120, 255));

                // Footprint, Capacity & Builder Specs
                rl.drawText("Footprint: 4x4 Grid Squares", @intFromFloat(card_x + 50), @intFromFloat(card_y + 56), 10, rl.Color.init(245, 195, 75, 255));
                rl.drawText("Staff: 10 Workers | Produces 8.0 Coal/sec", @intFromFloat(card_x + 50), @intFromFloat(card_y + 70), 10, rl.Color.init(160, 180, 205, 255));

                // Click instruction tip
                if (card_hovered) {
                    rl.drawText(
                        if (can_afford) "Click to select and place in the snow" else "Cannot afford (Requires 40 Wood)",
                        @intFromFloat(556.0 + 260.0 + 16.0),
                        @intFromFloat(card_y + 36),
                        13,
                        if (can_afford) rl.Color.init(245, 205, 70, 255) else rl.Color.init(255, 100, 90, 255),
                    );
                }
            } else {
                // Locked state
                const card_bg = rl.Color.init(20, 24, 30, 210);
                const card_border = rl.Color.init(50, 60, 72, 200);

                rl.drawRectangleRounded(card_rect, 0.12, 6, card_bg);
                rl.drawRectangleRoundedLinesEx(card_rect, 0.12, 6, 1.0, card_border);

                // Lock icon
                rl.drawRectangle(@intFromFloat(card_x + 14), @intFromFloat(card_y + 16), 24, 22, rl.Color.init(45, 52, 64, 255));
                rl.drawRectangleLines(@intFromFloat(card_x + 14), @intFromFloat(card_y + 16), 24, 22, rl.Color.init(75, 88, 105, 255));
                rl.drawText("?", @intFromFloat(card_x + 22), @intFromFloat(card_y + 18), 16, rl.Color.init(140, 155, 175, 255));

                // Building Name
                rl.drawText("Coal Mine", @intFromFloat(card_x + 50), @intFromFloat(card_y + 10), 16, rl.Color.init(140, 150, 165, 255));

                // Locked badge
                const locked_badge = rl.Rectangle.init(card_x + 50, card_y + 32, 108, 18);
                rl.drawRectangleRounded(locked_badge, 0.3, 4, rl.Color.init(40, 48, 58, 255));
                rl.drawText("[LOCKED - RESEARCH]", @intFromFloat(card_x + 54), @intFromFloat(card_y + 35), 9, rl.Color.init(245, 195, 65, 255));

                rl.drawText("Requires 'Coal Mine' research in Resources tab", @intFromFloat(card_x + 50), @intFromFloat(card_y + 56), 10, rl.Color.init(160, 175, 195, 255));
                rl.drawText("4x4 Grid | Staff: 10 | Produces 8.0 Coal/sec", @intFromFloat(card_x + 50), @intFromFloat(card_y + 70), 10, rl.Color.init(120, 135, 150, 255));
            }

            // Card 2: Wood Shack
            const ws_unlocked = (wood_shack_research_state == .completed);
            const card2_x: f32 = 286.0;
            const card2_y: f32 = strip_y + 44.0;
            const card2_w: f32 = 260.0;
            const card2_h: f32 = 92.0;
            const card2_rect = rl.Rectangle.init(card2_x, card2_y, card2_w, card2_h);
            const card2_hovered = rl.checkCollisionPointRec(mouse_pos, card2_rect);

            const can_afford_ws = (stockpiles[@intFromEnum(Resource.wood)] >= WOOD_SHACK_WOOD_COST and stockpiles[@intFromEnum(Resource.steel)] >= WOOD_SHACK_STEEL_COST);

            if (ws_unlocked) {
                const card_bg = if (card2_hovered)
                    rl.Color.init(48, 38, 28, 255)
                else
                    rl.Color.init(32, 26, 20, 240);

                const card_border = if (card2_hovered)
                    rl.Color.init(245, 185, 80, 255)
                else
                    rl.Color.init(115, 80, 50, 255);

                rl.drawRectangleRounded(card2_rect, 0.12, 6, card_bg);
                rl.drawRectangleRoundedLinesEx(card2_rect, 0.12, 6, if (card2_hovered) 2.0 else 1.2, card_border);

                // Mini Wood Shack Preview Icon
                rl.drawRectangle(@intFromFloat(card2_x + 10), @intFromFloat(card2_y + 14), 20, 18, COLOR_WOOD_SHACK_WALLS);
                rl.drawRectangle(@intFromFloat(card2_x + 8), @intFromFloat(card2_y + 10), 24, 6, COLOR_WOOD_SHACK_ROOF);
                rl.drawRectangle(@intFromFloat(card2_x + 30), @intFromFloat(card2_y + 16), 14, 16, COLOR_WOOD_SHACK_FOUNDATION);
                rl.drawRectangle(@intFromFloat(card2_x + 32), @intFromFloat(card2_y + 24), 10, 6, COLOR_WOOD_SHACK_LOGS);

                // Building Name
                rl.drawText("Wood Shack", @intFromFloat(card2_x + 50), @intFromFloat(card2_y + 10), 16, rl.Color.white);

                // Cost Badge
                const cost_pill_rect = rl.Rectangle.init(card2_x + 50, card2_y + 32, 136, 20);
                rl.drawRectangleRounded(cost_pill_rect, 0.3, 4, if (can_afford_ws) rl.Color.init(28, 55, 38, 255) else rl.Color.init(60, 28, 28, 255));
                rl.drawRectangleRoundedLinesEx(cost_pill_rect, 0.3, 4, 1.0, if (can_afford_ws) rl.Color.init(80, 185, 115, 255) else rl.Color.init(215, 70, 70, 255));
                const cost_text = fmt("Cost: {d}W, {d}S", .{ @as(i32, @intFromFloat(WOOD_SHACK_WOOD_COST)), @as(i32, @intFromFloat(WOOD_SHACK_STEEL_COST)) });
                rl.drawText(cost_text, @intFromFloat(card2_x + 56), @intFromFloat(card2_y + 36), 11, if (can_afford_ws) rl.Color.init(120, 235, 150, 255) else rl.Color.init(255, 120, 120, 255));

                // Footprint, Capacity & Builder Specs
                rl.drawText("Footprint: 4x4 Grid Squares", @intFromFloat(card2_x + 50), @intFromFloat(card2_y + 56), 10, rl.Color.init(245, 185, 100, 255));
                rl.drawText("Staff: 10 Workers | Produces 10 Wood/sec", @intFromFloat(card2_x + 50), @intFromFloat(card2_y + 70), 10, rl.Color.init(160, 180, 205, 255));

                // Click instruction tip
                if (card2_hovered) {
                    rl.drawText(
                        if (can_afford_ws) "Click to select and place in the snow" else "Cannot afford (Requires 100 Wood, 50 Steel)",
                        @intFromFloat(556.0 + 260.0 + 16.0),
                        @intFromFloat(card2_y + 36),
                        13,
                        if (can_afford_ws) rl.Color.init(245, 205, 70, 255) else rl.Color.init(255, 100, 90, 255),
                    );
                }
            } else {
                // Locked state
                const card_bg = rl.Color.init(20, 24, 30, 210);
                const card_border = rl.Color.init(50, 60, 72, 200);

                rl.drawRectangleRounded(card2_rect, 0.12, 6, card_bg);
                rl.drawRectangleRoundedLinesEx(card2_rect, 0.12, 6, 1.0, card_border);

                // Lock icon
                rl.drawRectangle(@intFromFloat(card2_x + 14), @intFromFloat(card2_y + 16), 24, 22, rl.Color.init(45, 52, 64, 255));
                rl.drawRectangleLines(@intFromFloat(card2_x + 14), @intFromFloat(card2_y + 16), 24, 22, rl.Color.init(75, 88, 105, 255));
                rl.drawText("?", @intFromFloat(card2_x + 22), @intFromFloat(card2_y + 18), 16, rl.Color.init(140, 155, 175, 255));

                // Building Name
                rl.drawText("Wood Shack", @intFromFloat(card2_x + 50), @intFromFloat(card2_y + 10), 16, rl.Color.init(140, 150, 165, 255));

                // Locked badge
                const locked_badge = rl.Rectangle.init(card2_x + 50, card2_y + 32, 108, 18);
                rl.drawRectangleRounded(locked_badge, 0.3, 4, rl.Color.init(40, 48, 58, 255));
                rl.drawText("[LOCKED - RESEARCH]", @intFromFloat(card2_x + 54), @intFromFloat(card2_y + 35), 9, rl.Color.init(245, 195, 65, 255));

                rl.drawText("Requires 'Wood Shack' research in Resources tab", @intFromFloat(card2_x + 50), @intFromFloat(card2_y + 56), 10, rl.Color.init(160, 175, 195, 255));
                rl.drawText("4x4 Grid | Staff: 10 | Produces 10 Wood/sec", @intFromFloat(card2_x + 50), @intFromFloat(card2_y + 70), 10, rl.Color.init(120, 135, 150, 255));
            }

            // Card 3: Steel Forge
            const sf_unlocked = (steel_forge_research_state == .completed);
            const card3_x: f32 = 556.0;
            const card3_y: f32 = strip_y + 44.0;
            const card3_w: f32 = 260.0;
            const card3_h: f32 = 92.0;
            const card3_rect = rl.Rectangle.init(card3_x, card3_y, card3_w, card3_h);
            const card3_hovered = rl.checkCollisionPointRec(mouse_pos, card3_rect);

            const can_afford_sf = (stockpiles[@intFromEnum(Resource.wood)] >= STEEL_FORGE_WOOD_COST and stockpiles[@intFromEnum(Resource.steel)] >= STEEL_FORGE_STEEL_COST);

            if (sf_unlocked) {
                const card_bg = if (card3_hovered)
                    rl.Color.init(35, 45, 60, 255)
                else
                    rl.Color.init(24, 30, 42, 240);

                const card_border = if (card3_hovered)
                    rl.Color.init(130, 205, 255, 255)
                else
                    rl.Color.init(65, 95, 135, 255);

                rl.drawRectangleRounded(card3_rect, 0.12, 6, card_bg);
                rl.drawRectangleRoundedLinesEx(card3_rect, 0.12, 6, if (card3_hovered) 2.0 else 1.2, card_border);

                // Mini Steel Forge Preview Icon
                rl.drawRectangle(@intFromFloat(card3_x + 10), @intFromFloat(card3_y + 14), 22, 18, COLOR_STEEL_FORGE_WALLS);
                rl.drawRectangle(@intFromFloat(card3_x + 8), @intFromFloat(card3_y + 10), 26, 6, COLOR_STEEL_FORGE_ROOF);
                rl.drawRectangle(@intFromFloat(card3_x + 24), @intFromFloat(card3_y + 4), 6, 8, COLOR_STEEL_FORGE_CHIMNEY);
                rl.drawRectangle(@intFromFloat(card3_x + 25), @intFromFloat(card3_y + 2), 4, 3, COLOR_STEEL_FORGE_FIRE);
                rl.drawRectangle(@intFromFloat(card3_x + 32), @intFromFloat(card3_y + 20), 10, 10, COLOR_STEEL_FORGE_STEEL);

                // Building Name
                rl.drawText("Steel Forge", @intFromFloat(card3_x + 50), @intFromFloat(card3_y + 10), 16, rl.Color.white);

                // Cost Badge
                const cost_pill_rect = rl.Rectangle.init(card3_x + 50, card3_y + 32, 136, 20);
                rl.drawRectangleRounded(cost_pill_rect, 0.3, 4, if (can_afford_sf) rl.Color.init(28, 55, 38, 255) else rl.Color.init(60, 28, 28, 255));
                rl.drawRectangleRoundedLinesEx(cost_pill_rect, 0.3, 4, 1.0, if (can_afford_sf) rl.Color.init(80, 185, 115, 255) else rl.Color.init(215, 70, 70, 255));
                const cost_text = fmt("Cost: {d}W, {d}S", .{ @as(i32, @intFromFloat(STEEL_FORGE_WOOD_COST)), @as(i32, @intFromFloat(STEEL_FORGE_STEEL_COST)) });
                rl.drawText(cost_text, @intFromFloat(card3_x + 56), @intFromFloat(card3_y + 36), 11, if (can_afford_sf) rl.Color.init(120, 235, 150, 255) else rl.Color.init(255, 120, 120, 255));

                // Footprint, Capacity & Builder Specs
                rl.drawText("Footprint: 4x4 Grid Squares", @intFromFloat(card3_x + 50), @intFromFloat(card3_y + 56), 10, rl.Color.init(175, 205, 245, 255));
                rl.drawText("Staff: 10 Workers | Produces 10 Steel/sec", @intFromFloat(card3_x + 50), @intFromFloat(card3_y + 70), 10, rl.Color.init(160, 180, 205, 255));

                // Click instruction tip
                if (card3_hovered) {
                    rl.drawText(
                        if (can_afford_sf) "Click to select and place in the snow" else "Cannot afford (Requires 100 Wood, 50 Steel)",
                        @intFromFloat(card3_x + card3_w + 16.0),
                        @intFromFloat(card3_y + 36),
                        13,
                        if (can_afford_sf) rl.Color.init(245, 205, 70, 255) else rl.Color.init(255, 100, 90, 255),
                    );
                }
            } else {
                // Locked state
                const card_bg = rl.Color.init(20, 24, 30, 210);
                const card_border = rl.Color.init(50, 60, 72, 200);

                rl.drawRectangleRounded(card3_rect, 0.12, 6, card_bg);
                rl.drawRectangleRoundedLinesEx(card3_rect, 0.12, 6, 1.0, card_border);

                // Lock icon
                rl.drawRectangle(@intFromFloat(card3_x + 14), @intFromFloat(card3_y + 16), 24, 22, rl.Color.init(45, 52, 64, 255));
                rl.drawRectangleLines(@intFromFloat(card3_x + 14), @intFromFloat(card3_y + 16), 24, 22, rl.Color.init(75, 88, 105, 255));
                rl.drawText("?", @intFromFloat(card3_x + 22), @intFromFloat(card3_y + 18), 16, rl.Color.init(140, 155, 175, 255));

                // Building Name
                rl.drawText("Steel Forge", @intFromFloat(card3_x + 50), @intFromFloat(card3_y + 10), 16, rl.Color.init(140, 150, 165, 255));

                // Locked badge
                const locked_badge = rl.Rectangle.init(card3_x + 50, card3_y + 32, 108, 18);
                rl.drawRectangleRounded(locked_badge, 0.3, 4, rl.Color.init(40, 48, 58, 255));
                rl.drawText("[LOCKED - RESEARCH]", @intFromFloat(card3_x + 54), @intFromFloat(card3_y + 35), 9, rl.Color.init(245, 195, 65, 255));

                rl.drawText("Requires 'Steel Forge' research in Resources tab", @intFromFloat(card3_x + 50), @intFromFloat(card3_y + 56), 10, rl.Color.init(160, 175, 195, 255));
                rl.drawText("4x4 Grid | Staff: 10 | Produces 10 Steel/sec", @intFromFloat(card3_x + 50), @intFromFloat(card3_y + 70), 10, rl.Color.init(120, 135, 150, 255));
            }
        }
    }
}

fn drawResearchUI(mouse_pos: rl.Vector2) void {
    const sw = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const sh = @as(f32, @floatFromInt(rl.getScreenHeight()));
    const lab_ready = hasCompletedLab();

    // 1. Research Button (Bottom, next to Build button)
    const btn_rect = getResearchBtnRect(sh);
    const btn_x = btn_rect.x;
    const btn_y = btn_rect.y;
    const btn_hovered = rl.checkCollisionPointRec(mouse_pos, btn_rect);

    if (lab_ready) {
        const btn_bg = if (research_menu_open)
            rl.Color.init(45, 140, 195, 255)
        else if (btn_hovered)
            rl.Color.init(35, 60, 85, 255)
        else
            rl.Color.init(20, 32, 46, 245);

        const btn_border = if (research_menu_open)
            rl.Color.init(120, 225, 255, 255)
        else if (btn_hovered)
            rl.Color.init(90, 205, 250, 255)
        else
            rl.Color.init(70, 115, 155, 255);

        const btn_text_color = if (research_menu_open)
            rl.Color.init(10, 20, 30, 255)
        else if (btn_hovered)
            rl.Color.init(200, 240, 255, 255)
        else
            rl.Color.init(190, 220, 245, 255);

        rl.drawRectangleRounded(btn_rect, 0.25, 6, btn_bg);
        rl.drawRectangleRoundedLinesEx(btn_rect, 0.25, 6, if (research_menu_open or btn_hovered) 2.0 else 1.2, btn_border);

        // Research flask / science icon
        rl.drawRectangle(@intFromFloat(btn_x + 12), @intFromFloat(btn_y + 11), 14, 14, if (research_menu_open) rl.Color.init(15, 25, 35, 255) else rl.Color.init(90, 210, 255, 255));
        rl.drawText("RESEARCH", @intFromFloat(btn_x + 34), @intFromFloat(btn_y + 11), 14, btn_text_color);
    } else {
        // Disabled / locked state
        const btn_bg = rl.Color.init(18, 22, 28, 200);
        const btn_border = rl.Color.init(50, 58, 68, 220);
        const btn_text_color = rl.Color.init(95, 105, 118, 255);

        rl.drawRectangleRounded(btn_rect, 0.25, 6, btn_bg);
        rl.drawRectangleRoundedLinesEx(btn_rect, 0.25, 6, 1.0, btn_border);

        // Padlock / dim icon
        rl.drawRectangle(@intFromFloat(btn_x + 12), @intFromFloat(btn_y + 11), 14, 14, rl.Color.init(60, 68, 80, 255));
        rl.drawText("RESEARCH", @intFromFloat(btn_x + 34), @intFromFloat(btn_y + 11), 14, btn_text_color);

        // Tooltip explaining requirement
        if (btn_hovered) {
            const tip_text = "Requires completed Lab to unlock Research";
            const tw = rl.measureText(tip_text, 11);
            const tip_w: f32 = @as(f32, @floatFromInt(tw)) + 16.0;
            const tip_h: f32 = 24.0;
            const tip_x: f32 = btn_x;
            const tip_y: f32 = btn_y - tip_h - 6.0;

            rl.drawRectangleRounded(rl.Rectangle.init(tip_x, tip_y, tip_w, tip_h), 0.25, 4, rl.Color.init(16, 20, 26, 245));
            rl.drawRectangleRoundedLinesEx(rl.Rectangle.init(tip_x, tip_y, tip_w, tip_h), 0.25, 4, 1.0, rl.Color.init(85, 100, 120, 255));
            rl.drawText(tip_text, @intFromFloat(tip_x + 8.0), @intFromFloat(tip_y + 6.0), 11, rl.Color.init(180, 195, 215, 255));
        }
    }

    // 2. Research Strip (Bottom Drawer)
    if (research_menu_open) {
        const strip_h: f32 = 148.0;
        const strip_y: f32 = sh - strip_h;
        const strip_rect = rl.Rectangle.init(0, strip_y, sw, strip_h);

        // Dark scientific slate background
        rl.drawRectangleRec(strip_rect, rl.Color.init(16, 22, 32, 248));
        rl.drawRectangle(0, @intFromFloat(strip_y), @intFromFloat(sw), 2, rl.Color.init(55, 120, 160, 255));

        // --- Tabs Header ---
        const tab_y = strip_y + 8.0;
        const tab_w: f32 = 110.0;
        const tab_h: f32 = 28.0;

        // Tab 1: "TECHNOLOGY"
        const is_tech = (active_research_tab == .technology);
        const tab_tech_rect = rl.Rectangle.init(16.0, tab_y, tab_w, tab_h);
        const tech_hovered = rl.checkCollisionPointRec(mouse_pos, tab_tech_rect);
        rl.drawRectangleRounded(tab_tech_rect, 0.25, 4, if (is_tech) rl.Color.init(28, 55, 78, 255) else if (tech_hovered) rl.Color.init(25, 42, 60, 220) else rl.Color.init(22, 28, 38, 180));
        if (is_tech) {
            rl.drawRectangleRoundedLinesEx(tab_tech_rect, 0.25, 4, 1.5, rl.Color.init(90, 215, 255, 255));
            rl.drawRectangle(18, @intFromFloat(tab_y + tab_h - 2), @intFromFloat(tab_w - 4), 2, rl.Color.init(90, 215, 255, 255));
        }
        rl.drawText("TECHNOLOGY", 24, @intFromFloat(tab_y + 7), 12, if (is_tech) rl.Color.init(140, 230, 255, 255) else rl.Color.init(120, 140, 165, 255));

        // Tab 2: "FOOD"
        const is_food = (active_research_tab == .food);
        const tab_food_rect = rl.Rectangle.init(134.0, tab_y, tab_w, tab_h);
        const food_hovered = rl.checkCollisionPointRec(mouse_pos, tab_food_rect);
        rl.drawRectangleRounded(tab_food_rect, 0.25, 4, if (is_food) rl.Color.init(28, 55, 40, 255) else if (food_hovered) rl.Color.init(25, 45, 35, 220) else rl.Color.init(22, 28, 38, 180));
        if (is_food) {
            rl.drawRectangleRoundedLinesEx(tab_food_rect, 0.25, 4, 1.5, rl.Color.init(100, 225, 130, 255));
            rl.drawRectangle(136, @intFromFloat(tab_y + tab_h - 2), @intFromFloat(tab_w - 4), 2, rl.Color.init(100, 225, 130, 255));
        }
        rl.drawText("FOOD", 170, @intFromFloat(tab_y + 7), 13, if (is_food) rl.Color.init(130, 245, 150, 255) else rl.Color.init(120, 140, 165, 255));

        // Tab 3: "RESOURCES"
        const is_res = (active_research_tab == .resources);
        const tab_res_rect = rl.Rectangle.init(252.0, tab_y, tab_w, tab_h);
        const res_hovered = rl.checkCollisionPointRec(mouse_pos, tab_res_rect);
        rl.drawRectangleRounded(tab_res_rect, 0.25, 4, if (is_res) rl.Color.init(48, 40, 30, 255) else if (res_hovered) rl.Color.init(40, 35, 28, 220) else rl.Color.init(22, 28, 38, 180));
        if (is_res) {
            rl.drawRectangleRoundedLinesEx(tab_res_rect, 0.25, 4, 1.5, rl.Color.init(245, 185, 65, 255));
            rl.drawRectangle(254, @intFromFloat(tab_y + tab_h - 2), @intFromFloat(tab_w - 4), 2, rl.Color.init(245, 185, 65, 255));
        }
        rl.drawText("RESOURCES", 262, @intFromFloat(tab_y + 7), 12, if (is_res) rl.Color.init(255, 215, 90, 255) else rl.Color.init(120, 140, 165, 255));

        // Inactive tabs
        const tab_eff_rect = rl.Rectangle.init(370.0, tab_y, tab_w, tab_h);
        rl.drawRectangleRounded(tab_eff_rect, 0.25, 4, rl.Color.init(22, 28, 38, 180));
        rl.drawText("EFFICIENCY", 386, @intFromFloat(tab_y + 7), 12, rl.Color.init(90, 105, 125, 255));

        const tab_exp_rect = rl.Rectangle.init(488.0, tab_y, tab_w + 10, tab_h);
        rl.drawRectangleRounded(tab_exp_rect, 0.25, 4, rl.Color.init(22, 28, 38, 180));
        rl.drawText("EXPLORATION", 502, @intFromFloat(tab_y + 7), 12, rl.Color.init(90, 105, 125, 255));

        // Close button [x]
        const close_btn_rect = rl.Rectangle.init(sw - 36.0, tab_y, 24.0, 24.0);
        const close_hovered = rl.checkCollisionPointRec(mouse_pos, close_btn_rect);
        rl.drawRectangleRounded(close_btn_rect, 0.2, 4, if (close_hovered) rl.Color.init(200, 50, 50, 255) else rl.Color.init(32, 38, 48, 255));
        rl.drawText("x", @intFromFloat(sw - 29), @intFromFloat(tab_y + 3), 15, rl.Color.white);

        // --- Active Tab Content ---
        if (active_research_tab == .technology) {
            // Card 1: Heater Overdrive
            const card1_x: f32 = 16.0;
            const card1_y: f32 = strip_y + 44.0;
            const card1_w: f32 = 260.0;
            const card1_h: f32 = 92.0;
            const card1_rect = rl.Rectangle.init(card1_x, card1_y, card1_w, card1_h);
            const card1_hovered = rl.checkCollisionPointRec(mouse_pos, card1_rect);

            rl.drawRectangleRounded(card1_rect, 0.12, 6, if (card1_hovered) rl.Color.init(28, 48, 68, 255) else rl.Color.init(20, 32, 46, 240));
            rl.drawRectangleRoundedLinesEx(card1_rect, 0.12, 6, if (card1_hovered) 2.0 else 1.2, if (card1_hovered) rl.Color.init(90, 215, 255, 255) else rl.Color.init(55, 95, 130, 255));

            // Card 1 Icon
            rl.drawRectangle(@intFromFloat(card1_x + 12), @intFromFloat(card1_y + 12), 26, 26, rl.Color.init(35, 75, 105, 255));
            rl.drawRectangleLines(@intFromFloat(card1_x + 12), @intFromFloat(card1_y + 12), 26, 26, rl.Color.init(90, 210, 255, 255));
            rl.drawText("*", @intFromFloat(card1_x + 21), @intFromFloat(card1_y + 14), 18, rl.Color.init(245, 205, 70, 255));

            rl.drawText("Heater Overdrive", @intFromFloat(card1_x + 48), @intFromFloat(card1_y + 10), 15, rl.Color.white);
            rl.drawText("Tier I Research Project", @intFromFloat(card1_x + 48), @intFromFloat(card1_y + 30), 11, rl.Color.init(120, 200, 240, 255));
            rl.drawText("+25% Generator heat range", @intFromFloat(card1_x + 48), @intFromFloat(card1_y + 48), 11, rl.Color.init(190, 210, 230, 255));

            const badge1_rect = rl.Rectangle.init(card1_x + 48, card1_y + 68, 120, 18);
            rl.drawRectangleRounded(badge1_rect, 0.3, 4, rl.Color.init(35, 50, 65, 255));
            rl.drawText("[COMING SOON]", @intFromFloat(card1_x + 56), @intFromFloat(card1_y + 71), 10, rl.Color.init(140, 190, 220, 255));

            // Card 2: Insulation Tech
            const card2_x: f32 = card1_x + card1_w + 14.0;
            const card2_y: f32 = card1_y;
            const card2_w: f32 = 260.0;
            const card2_h: f32 = 92.0;
            const card2_rect = rl.Rectangle.init(card2_x, card2_y, card2_w, card2_h);
            const card2_hovered = rl.checkCollisionPointRec(mouse_pos, card2_rect);

            rl.drawRectangleRounded(card2_rect, 0.12, 6, if (card2_hovered) rl.Color.init(28, 48, 68, 255) else rl.Color.init(20, 32, 46, 240));
            rl.drawRectangleRoundedLinesEx(card2_rect, 0.12, 6, if (card2_hovered) 2.0 else 1.2, if (card2_hovered) rl.Color.init(90, 215, 255, 255) else rl.Color.init(55, 95, 130, 255));

            // Card 2 Icon
            rl.drawRectangle(@intFromFloat(card2_x + 12), @intFromFloat(card2_y + 12), 26, 26, rl.Color.init(35, 75, 105, 255));
            rl.drawRectangleLines(@intFromFloat(card2_x + 12), @intFromFloat(card2_y + 12), 26, 26, rl.Color.init(90, 210, 255, 255));
            rl.drawText("+", @intFromFloat(card2_x + 20), @intFromFloat(card2_y + 16), 18, rl.Color.init(100, 230, 140, 255));

            rl.drawText("Thermal Insulation", @intFromFloat(card2_x + 48), @intFromFloat(card2_y + 10), 15, rl.Color.white);
            rl.drawText("Tier I Research Project", @intFromFloat(card2_x + 48), @intFromFloat(card2_y + 30), 11, rl.Color.init(120, 200, 240, 255));
            rl.drawText("Houses stay warm longer", @intFromFloat(card2_x + 48), @intFromFloat(card2_y + 48), 11, rl.Color.init(190, 210, 230, 255));

            const badge2_rect = rl.Rectangle.init(card2_x + 48, card2_y + 68, 120, 18);
            rl.drawRectangleRounded(badge2_rect, 0.3, 4, rl.Color.init(35, 50, 65, 255));
            rl.drawText("[COMING SOON]", @intFromFloat(card2_x + 56), @intFromFloat(card2_y + 71), 10, rl.Color.init(140, 190, 220, 255));
        } else if (active_research_tab == .food) {
            // Greenhouses Research Card
            const card_rect = getGreenhousesCardRect(strip_y);
            const card_x: f32 = card_rect.x;
            const card_y: f32 = card_rect.y;
            const cancel_btn_rect = getGreenhousesCancelBtnRect(strip_y);
            const cancel_hovered = (greenhouses_research_state == .researching) and rl.checkCollisionPointRec(mouse_pos, cancel_btn_rect);
            const card_hovered = rl.checkCollisionPointRec(mouse_pos, card_rect) and !cancel_hovered;

            const current_wood = stockpiles[@intFromEnum(Resource.wood)];
            const can_afford = current_wood >= GREENHOUSES_RESEARCH_WOOD_COST;

            const card_bg = if (card_hovered and greenhouses_research_state == .available)
                rl.Color.init(25, 48, 38, 255)
            else
                rl.Color.init(18, 32, 26, 240);

            const card_border = if (card_hovered and greenhouses_research_state == .available)
                rl.Color.init(100, 225, 140, 255)
            else
                rl.Color.init(50, 95, 68, 255);

            rl.drawRectangleRounded(card_rect, 0.12, 6, card_bg);
            rl.drawRectangleRoundedLinesEx(card_rect, 0.12, 6, if (card_hovered and greenhouses_research_state == .available) 2.0 else 1.2, card_border);

            // Icon: Greenery sprout symbol
            rl.drawRectangle(@intFromFloat(card_x + 12), @intFromFloat(card_y + 12), 26, 26, rl.Color.init(25, 65, 40, 255));
            rl.drawRectangleLines(@intFromFloat(card_x + 12), @intFromFloat(card_y + 12), 26, 26, rl.Color.init(80, 215, 120, 255));
            rl.drawText("G", @intFromFloat(card_x + 20), @intFromFloat(card_y + 15), 18, rl.Color.init(100, 235, 140, 255));

            rl.drawText("Greenhouses", @intFromFloat(card_x + 48), @intFromFloat(card_y + 10), 15, rl.Color.white);
            rl.drawText("Food & Sustenance Project", @intFromFloat(card_x + 48), @intFromFloat(card_y + 28), 11, rl.Color.init(120, 220, 150, 255));

            if (greenhouses_research_state == .available) {
                // Cost badge
                const cost_text = fmt("Cost: {d} Wood | Time: 2m 00s", .{@as(i32, @intFromFloat(GREENHOUSES_RESEARCH_WOOD_COST))});
                rl.drawText(cost_text, @intFromFloat(card_x + 48), @intFromFloat(card_y + 46), 11, if (can_afford) rl.Color.init(140, 240, 160, 255) else rl.Color.init(255, 110, 110, 255));

                // Button pill
                const btn_pill_rect = rl.Rectangle.init(card_x + 48, card_y + 64, 160, 20);
                rl.drawRectangleRounded(btn_pill_rect, 0.3, 4, if (can_afford) (if (card_hovered) rl.Color.init(35, 90, 55, 255) else rl.Color.init(26, 65, 40, 255)) else rl.Color.init(55, 25, 25, 255));
                rl.drawRectangleRoundedLinesEx(btn_pill_rect, 0.3, 4, 1.0, if (can_afford) rl.Color.init(90, 210, 130, 255) else rl.Color.init(180, 60, 60, 255));
                rl.drawText(if (can_afford) "Click to Research (20 Wood)" else "Need 20 Wood to Research", @intFromFloat(card_x + 54), @intFromFloat(card_y + 68), 10, if (can_afford) rl.Color.white else rl.Color.init(255, 130, 130, 255));
            } else if (greenhouses_research_state == .researching) {
                const total_researchers = getTotalLabWorkers();
                const pct = getActiveResearchProgress();
                const speed_mult = getResearchSpeedMultiplier();
                if (speed_mult > 0.0) {
                    const rem_sec_f = (GREENHOUSES_RESEARCH_DURATION - greenhouses_research_progress) / speed_mult;
                    const rem = @max(0, @as(i32, @intFromFloat(rem_sec_f)));
                    const rem_min = @divTrunc(rem, 60);
                    const rem_sec = @rem(rem, 60);

                    const speed_pct = @as(i32, @intFromFloat(speed_mult * 100.0));
                    const staff_info = if (total_researchers > getMaxEffectiveResearchWorkers())
                        fmt("{d} Staff (Cap 4 Labs), {d}%", .{ total_researchers, speed_pct })
                    else
                        fmt("{d} Staff, {d}%", .{ total_researchers, speed_pct });

                    _ = rl.drawText(
                        fmt("Researching: {d}% | ~{d}m {d:0>2}s left ({s})", .{
                            @as(i32, @intFromFloat(pct * 100.0)),
                            rem_min,
                            rem_sec,
                            staff_info,
                        }),
                        @intFromFloat(card_x + 48),
                        @intFromFloat(card_y + 46),
                        11,
                        rl.Color.init(100, 225, 255, 255),
                    );
                } else {
                    _ = rl.drawText(
                        fmt("PAUSED: 0 Staff in Labs (Progress: {d}%)", .{@as(i32, @intFromFloat(pct * 100.0))}),
                        @intFromFloat(card_x + 48),
                        @intFromFloat(card_y + 46),
                        11,
                        rl.Color.init(255, 120, 100, 255),
                    );
                }

                // Progress Bar
                const bar_x: f32 = card_x + 48.0;
                const bar_y: f32 = card_y + 66.0;
                const bar_w: f32 = cancel_btn_rect.x - 10.0 - bar_x;
                const bar_h: f32 = 14.0;
                rl.drawRectangleRounded(rl.Rectangle.init(bar_x, bar_y, bar_w, bar_h), 0.3, 4, rl.Color.init(20, 30, 40, 255));
                rl.drawRectangleRoundedLinesEx(rl.Rectangle.init(bar_x, bar_y, bar_w, bar_h), 0.3, 4, 1.0, rl.Color.init(60, 100, 130, 255));
                rl.drawRectangleRounded(rl.Rectangle.init(bar_x, bar_y, bar_w * pct, bar_h), 0.3, 4, if (total_researchers > 0) rl.Color.init(60, 210, 140, 255) else rl.Color.init(180, 80, 70, 255));

                // Cancel Button
                rl.drawRectangleRounded(cancel_btn_rect, 0.3, 4, if (cancel_hovered) rl.Color.init(170, 40, 45, 255) else rl.Color.init(55, 25, 28, 255));
                rl.drawRectangleRoundedLinesEx(cancel_btn_rect, 0.3, 4, 1.0, if (cancel_hovered) rl.Color.init(255, 110, 110, 255) else rl.Color.init(180, 60, 65, 255));
                const cancel_tw = rl.measureText("Cancel", 11);
                const cancel_tx = @as(i32, @intFromFloat(cancel_btn_rect.x + (cancel_btn_rect.width - @as(f32, @floatFromInt(cancel_tw))) / 2.0));
                const cancel_ty = @as(i32, @intFromFloat(cancel_btn_rect.y + 4.5));
                rl.drawText("Cancel", cancel_tx, cancel_ty, 11, if (cancel_hovered) rl.Color.white else rl.Color.init(255, 180, 180, 255));
            } else if (greenhouses_research_state == .completed) {
                rl.drawText("Unlocks 2x4 Greenhouse building", @intFromFloat(card_x + 48), @intFromFloat(card_y + 46), 11, rl.Color.init(180, 215, 190, 255));

                const comp_rect = rl.Rectangle.init(card_x + 48, card_y + 64, 160, 20);
                rl.drawRectangleRounded(comp_rect, 0.3, 4, rl.Color.init(24, 60, 38, 255));
                rl.drawRectangleRoundedLinesEx(comp_rect, 0.3, 4, 1.0, rl.Color.init(80, 220, 130, 255));
                rl.drawText("[RESEARCHED - UNLOCKED]", @intFromFloat(card_x + 54), @intFromFloat(card_y + 68), 10, rl.Color.init(110, 240, 150, 255));
            }
        } else if (active_research_tab == .resources) {
            // Coal Mine Research Card
            const card_rect = getCoalMineCardRect(strip_y);
            const card_x: f32 = card_rect.x;
            const card_y: f32 = card_rect.y;
            const cancel_btn_rect = getCoalMineCancelBtnRect(strip_y);
            const cancel_hovered = (coal_mine_research_state == .researching) and rl.checkCollisionPointRec(mouse_pos, cancel_btn_rect);
            const card_hovered = rl.checkCollisionPointRec(mouse_pos, card_rect) and !cancel_hovered;

            const current_wood = stockpiles[@intFromEnum(Resource.wood)];
            const current_steel = stockpiles[@intFromEnum(Resource.steel)];
            const can_afford = current_wood >= COAL_MINE_RESEARCH_WOOD_COST and current_steel >= COAL_MINE_RESEARCH_STEEL_COST;

            const card_bg = if (card_hovered and coal_mine_research_state == .available)
                rl.Color.init(42, 36, 30, 255)
            else
                rl.Color.init(28, 24, 22, 240);

            const card_border = if (card_hovered and coal_mine_research_state == .available)
                rl.Color.init(245, 185, 65, 255)
            else
                rl.Color.init(100, 75, 50, 255);

            rl.drawRectangleRounded(card_rect, 0.12, 6, card_bg);
            rl.drawRectangleRoundedLinesEx(card_rect, 0.12, 6, if (card_hovered and coal_mine_research_state == .available) 2.0 else 1.2, card_border);

            // Icon: Mining headframe / coal symbol
            rl.drawRectangle(@intFromFloat(card_x + 12), @intFromFloat(card_y + 12), 26, 26, rl.Color.init(35, 30, 28, 255));
            rl.drawRectangleLines(@intFromFloat(card_x + 12), @intFromFloat(card_y + 12), 26, 26, rl.Color.init(210, 150, 60, 255));
            rl.drawText("M", @intFromFloat(card_x + 19), @intFromFloat(card_y + 15), 18, rl.Color.init(245, 190, 70, 255));

            rl.drawText("Coal Mine", @intFromFloat(card_x + 48), @intFromFloat(card_y + 10), 15, rl.Color.white);
            rl.drawText("Resource Extraction Project", @intFromFloat(card_x + 48), @intFromFloat(card_y + 28), 11, rl.Color.init(220, 185, 130, 255));

            if (coal_mine_research_state == .available) {
                // Cost badge
                const cost_text = fmt("Cost: {d} Wood, {d} Steel | Time: 2m 00s", .{
                    @as(i32, @intFromFloat(COAL_MINE_RESEARCH_WOOD_COST)),
                    @as(i32, @intFromFloat(COAL_MINE_RESEARCH_STEEL_COST)),
                });
                rl.drawText(cost_text, @intFromFloat(card_x + 48), @intFromFloat(card_y + 46), 11, if (can_afford) rl.Color.init(245, 205, 120, 255) else rl.Color.init(255, 110, 110, 255));

                // Button pill
                const btn_pill_rect = rl.Rectangle.init(card_x + 48, card_y + 64, 210, 20);
                rl.drawRectangleRounded(btn_pill_rect, 0.3, 4, if (can_afford) (if (card_hovered) rl.Color.init(85, 60, 30, 255) else rl.Color.init(65, 45, 25, 255)) else rl.Color.init(55, 25, 25, 255));
                rl.drawRectangleRoundedLinesEx(btn_pill_rect, 0.3, 4, 1.0, if (can_afford) rl.Color.init(215, 160, 60, 255) else rl.Color.init(180, 60, 60, 255));
                rl.drawText(if (can_afford) "Click to Research (100W, 100S)" else "Need 100 Wood, 100 Steel", @intFromFloat(card_x + 54), @intFromFloat(card_y + 68), 10, if (can_afford) rl.Color.white else rl.Color.init(255, 130, 130, 255));
            } else if (coal_mine_research_state == .researching) {
                const total_researchers = getTotalLabWorkers();
                const pct = getActiveResearchProgress();
                const speed_mult = getResearchSpeedMultiplier();
                if (speed_mult > 0.0) {
                    const rem_sec_f = (COAL_MINE_RESEARCH_DURATION - coal_mine_research_progress) / speed_mult;
                    const rem = @max(0, @as(i32, @intFromFloat(rem_sec_f)));
                    const rem_min = @divTrunc(rem, 60);
                    const rem_sec = @rem(rem, 60);

                    const speed_pct = @as(i32, @intFromFloat(speed_mult * 100.0));
                    const staff_info = if (total_researchers > getMaxEffectiveResearchWorkers())
                        fmt("{d} Staff (Cap 4 Labs), {d}%", .{ total_researchers, speed_pct })
                    else
                        fmt("{d} Staff, {d}%", .{ total_researchers, speed_pct });

                    _ = rl.drawText(
                        fmt("Researching: {d}% | ~{d}m {d:0>2}s left ({s})", .{
                            @as(i32, @intFromFloat(pct * 100.0)),
                            rem_min,
                            rem_sec,
                            staff_info,
                        }),
                        @intFromFloat(card_x + 48),
                        @intFromFloat(card_y + 46),
                        11,
                        rl.Color.init(245, 205, 100, 255),
                    );
                } else {
                    _ = rl.drawText(
                        fmt("PAUSED: 0 Staff in Labs (Progress: {d}%)", .{@as(i32, @intFromFloat(pct * 100.0))}),
                        @intFromFloat(card_x + 48),
                        @intFromFloat(card_y + 46),
                        11,
                        rl.Color.init(255, 120, 100, 255),
                    );
                }

                // Progress Bar
                const bar_x: f32 = card_x + 48.0;
                const bar_y: f32 = card_y + 66.0;
                const bar_w: f32 = cancel_btn_rect.x - 10.0 - bar_x;
                const bar_h: f32 = 14.0;
                rl.drawRectangleRounded(rl.Rectangle.init(bar_x, bar_y, bar_w, bar_h), 0.3, 4, rl.Color.init(20, 30, 40, 255));
                rl.drawRectangleRoundedLinesEx(rl.Rectangle.init(bar_x, bar_y, bar_w, bar_h), 0.3, 4, 1.0, rl.Color.init(60, 100, 130, 255));
                rl.drawRectangleRounded(rl.Rectangle.init(bar_x, bar_y, bar_w * pct, bar_h), 0.3, 4, if (total_researchers > 0) rl.Color.init(245, 185, 65, 255) else rl.Color.init(180, 80, 70, 255));

                // Cancel Button
                rl.drawRectangleRounded(cancel_btn_rect, 0.3, 4, if (cancel_hovered) rl.Color.init(170, 40, 45, 255) else rl.Color.init(55, 25, 28, 255));
                rl.drawRectangleRoundedLinesEx(cancel_btn_rect, 0.3, 4, 1.0, if (cancel_hovered) rl.Color.init(255, 110, 110, 255) else rl.Color.init(180, 60, 65, 255));
                const cancel_tw = rl.measureText("Cancel", 11);
                const cancel_tx = @as(i32, @intFromFloat(cancel_btn_rect.x + (cancel_btn_rect.width - @as(f32, @floatFromInt(cancel_tw))) / 2.0));
                const cancel_ty = @as(i32, @intFromFloat(cancel_btn_rect.y + 4.5));
                rl.drawText("Cancel", cancel_tx, cancel_ty, 11, if (cancel_hovered) rl.Color.white else rl.Color.init(255, 180, 180, 255));
            } else if (coal_mine_research_state == .completed) {
                rl.drawText("Unlocks 4x4 Coal Mine extraction building", @intFromFloat(card_x + 48), @intFromFloat(card_y + 46), 11, rl.Color.init(220, 205, 150, 255));

                const comp_rect = rl.Rectangle.init(card_x + 48, card_y + 64, 160, 20);
                rl.drawRectangleRounded(comp_rect, 0.3, 4, rl.Color.init(55, 45, 25, 255));
                rl.drawRectangleRoundedLinesEx(comp_rect, 0.3, 4, 1.0, rl.Color.init(245, 185, 65, 255));
                rl.drawText("[RESEARCHED - UNLOCKED]", @intFromFloat(card_x + 54), @intFromFloat(card_y + 68), 10, rl.Color.init(255, 215, 80, 255));
            }

            // Wood Shack Research Card
            const ws_card_rect = getWoodShackCardRect(strip_y);
            const ws_card_x: f32 = ws_card_rect.x;
            const ws_card_y: f32 = ws_card_rect.y;
            const ws_cancel_btn_rect = getWoodShackCancelBtnRect(strip_y);
            const ws_cancel_hovered = (wood_shack_research_state == .researching) and rl.checkCollisionPointRec(mouse_pos, ws_cancel_btn_rect);
            const ws_card_hovered = rl.checkCollisionPointRec(mouse_pos, ws_card_rect) and !ws_cancel_hovered;

            const current_wood_ws = stockpiles[@intFromEnum(Resource.wood)];
            const current_steel_ws = stockpiles[@intFromEnum(Resource.steel)];
            const can_afford_ws_res = current_wood_ws >= WOOD_SHACK_RESEARCH_WOOD_COST and current_steel_ws >= WOOD_SHACK_RESEARCH_STEEL_COST;

            const ws_card_bg = if (ws_card_hovered and wood_shack_research_state == .available)
                rl.Color.init(46, 36, 26, 255)
            else
                rl.Color.init(30, 24, 20, 240);

            const ws_card_border = if (ws_card_hovered and wood_shack_research_state == .available)
                rl.Color.init(245, 185, 80, 255)
            else
                rl.Color.init(100, 70, 45, 255);

            rl.drawRectangleRounded(ws_card_rect, 0.12, 6, ws_card_bg);
            rl.drawRectangleRoundedLinesEx(ws_card_rect, 0.12, 6, if (ws_card_hovered and wood_shack_research_state == .available) 2.0 else 1.2, ws_card_border);

            // Icon: Wood shack / timber axe symbol
            rl.drawRectangle(@intFromFloat(ws_card_x + 12), @intFromFloat(ws_card_y + 12), 26, 26, rl.Color.init(45, 32, 22, 255));
            rl.drawRectangleLines(@intFromFloat(ws_card_x + 12), @intFromFloat(ws_card_y + 12), 26, 26, rl.Color.init(215, 140, 65, 255));
            rl.drawText("W", @intFromFloat(ws_card_x + 19), @intFromFloat(ws_card_y + 15), 18, rl.Color.init(245, 185, 90, 255));

            rl.drawText("Wood Shack", @intFromFloat(ws_card_x + 48), @intFromFloat(ws_card_y + 10), 15, rl.Color.white);
            rl.drawText("Timber Production Project", @intFromFloat(ws_card_x + 48), @intFromFloat(ws_card_y + 28), 11, rl.Color.init(225, 180, 130, 255));

            if (wood_shack_research_state == .available) {
                // Cost badge
                const cost_text = fmt("Cost: {d} Wood, {d} Steel | Time: 2m 00s", .{
                    @as(i32, @intFromFloat(WOOD_SHACK_RESEARCH_WOOD_COST)),
                    @as(i32, @intFromFloat(WOOD_SHACK_RESEARCH_STEEL_COST)),
                });
                rl.drawText(cost_text, @intFromFloat(ws_card_x + 48), @intFromFloat(ws_card_y + 46), 11, if (can_afford_ws_res) rl.Color.init(245, 205, 120, 255) else rl.Color.init(255, 110, 110, 255));

                // Button pill
                const btn_pill_rect = rl.Rectangle.init(ws_card_x + 48, ws_card_y + 64, 210, 20);
                rl.drawRectangleRounded(btn_pill_rect, 0.3, 4, if (can_afford_ws_res) (if (ws_card_hovered) rl.Color.init(85, 60, 30, 255) else rl.Color.init(65, 45, 25, 255)) else rl.Color.init(55, 25, 25, 255));
                rl.drawRectangleRoundedLinesEx(btn_pill_rect, 0.3, 4, 1.0, if (can_afford_ws_res) rl.Color.init(215, 160, 60, 255) else rl.Color.init(180, 60, 60, 255));
                rl.drawText(if (can_afford_ws_res) "Click to Research (25W, 25S)" else "Need 25 Wood, 25 Steel", @intFromFloat(ws_card_x + 54), @intFromFloat(ws_card_y + 68), 10, if (can_afford_ws_res) rl.Color.white else rl.Color.init(255, 130, 130, 255));
            } else if (wood_shack_research_state == .researching) {
                const total_researchers = getTotalLabWorkers();
                const pct = getActiveResearchProgress();
                const speed_mult = getResearchSpeedMultiplier();
                if (speed_mult > 0.0) {
                    const rem_sec_f = (WOOD_SHACK_RESEARCH_DURATION - wood_shack_research_progress) / speed_mult;
                    const rem = @max(0, @as(i32, @intFromFloat(rem_sec_f)));
                    const rem_min = @divTrunc(rem, 60);
                    const rem_sec = @rem(rem, 60);

                    const speed_pct = @as(i32, @intFromFloat(speed_mult * 100.0));
                    const staff_info = if (total_researchers > getMaxEffectiveResearchWorkers())
                        fmt("{d} Staff (Cap 4 Labs), {d}%", .{ total_researchers, speed_pct })
                    else
                        fmt("{d} Staff, {d}%", .{ total_researchers, speed_pct });

                    _ = rl.drawText(
                        fmt("Researching: {d}% | ~{d}m {d:0>2}s left ({s})", .{
                            @as(i32, @intFromFloat(pct * 100.0)),
                            rem_min,
                            rem_sec,
                            staff_info,
                        }),
                        @intFromFloat(ws_card_x + 48),
                        @intFromFloat(ws_card_y + 46),
                        11,
                        rl.Color.init(245, 205, 100, 255),
                    );
                } else {
                    _ = rl.drawText(
                        fmt("PAUSED: 0 Staff in Labs (Progress: {d}%)", .{@as(i32, @intFromFloat(pct * 100.0))}),
                        @intFromFloat(ws_card_x + 48),
                        @intFromFloat(ws_card_y + 46),
                        11,
                        rl.Color.init(255, 120, 100, 255),
                    );
                }

                // Progress Bar
                const bar_x: f32 = ws_card_x + 48.0;
                const bar_y: f32 = ws_card_y + 66.0;
                const bar_w: f32 = ws_cancel_btn_rect.x - 10.0 - bar_x;
                const bar_h: f32 = 14.0;
                rl.drawRectangleRounded(rl.Rectangle.init(bar_x, bar_y, bar_w, bar_h), 0.3, 4, rl.Color.init(20, 30, 40, 255));
                rl.drawRectangleRoundedLinesEx(rl.Rectangle.init(bar_x, bar_y, bar_w, bar_h), 0.3, 4, 1.0, rl.Color.init(60, 100, 130, 255));
                rl.drawRectangleRounded(rl.Rectangle.init(bar_x, bar_y, bar_w * pct, bar_h), 0.3, 4, if (total_researchers > 0) rl.Color.init(245, 185, 65, 255) else rl.Color.init(180, 80, 70, 255));

                // Cancel Button
                rl.drawRectangleRounded(ws_cancel_btn_rect, 0.3, 4, if (ws_cancel_hovered) rl.Color.init(170, 40, 45, 255) else rl.Color.init(55, 25, 28, 255));
                rl.drawRectangleRoundedLinesEx(ws_cancel_btn_rect, 0.3, 4, 1.0, if (ws_cancel_hovered) rl.Color.init(255, 110, 110, 255) else rl.Color.init(180, 60, 65, 255));
                const cancel_tw = rl.measureText("Cancel", 11);
                const cancel_tx = @as(i32, @intFromFloat(ws_cancel_btn_rect.x + (ws_cancel_btn_rect.width - @as(f32, @floatFromInt(cancel_tw))) / 2.0));
                const cancel_ty = @as(i32, @intFromFloat(ws_cancel_btn_rect.y + 4.5));
                rl.drawText("Cancel", cancel_tx, cancel_ty, 11, if (ws_cancel_hovered) rl.Color.white else rl.Color.init(255, 180, 180, 255));
            } else if (wood_shack_research_state == .completed) {
                rl.drawText("Unlocks 4x4 Wood Shack timber building", @intFromFloat(ws_card_x + 48), @intFromFloat(ws_card_y + 46), 11, rl.Color.init(220, 205, 150, 255));

                const comp_rect = rl.Rectangle.init(ws_card_x + 48, ws_card_y + 64, 160, 20);
                rl.drawRectangleRounded(comp_rect, 0.3, 4, rl.Color.init(55, 45, 25, 255));
                rl.drawRectangleRoundedLinesEx(comp_rect, 0.3, 4, 1.0, rl.Color.init(245, 185, 65, 255));
                rl.drawText("[RESEARCHED - UNLOCKED]", @intFromFloat(ws_card_x + 54), @intFromFloat(ws_card_y + 68), 10, rl.Color.init(255, 215, 80, 255));
            }

            // Steel Forge Research Card
            const sf_card_rect = getSteelForgeCardRect(strip_y);
            const sf_card_x: f32 = sf_card_rect.x;
            const sf_card_y: f32 = sf_card_rect.y;
            const sf_cancel_btn_rect = getSteelForgeCancelBtnRect(strip_y);
            const sf_cancel_hovered = (steel_forge_research_state == .researching) and rl.checkCollisionPointRec(mouse_pos, sf_cancel_btn_rect);
            const sf_card_hovered = rl.checkCollisionPointRec(mouse_pos, sf_card_rect) and !sf_cancel_hovered;

            const current_wood_sf = stockpiles[@intFromEnum(Resource.wood)];
            const current_steel_sf = stockpiles[@intFromEnum(Resource.steel)];
            const can_afford_sf_res = current_wood_sf >= STEEL_FORGE_RESEARCH_WOOD_COST and current_steel_sf >= STEEL_FORGE_RESEARCH_STEEL_COST;

            const sf_card_bg = if (sf_card_hovered and steel_forge_research_state == .available)
                rl.Color.init(32, 42, 58, 255)
            else
                rl.Color.init(22, 28, 38, 240);

            const sf_card_border = if (sf_card_hovered and steel_forge_research_state == .available)
                rl.Color.init(130, 205, 255, 255)
            else
                rl.Color.init(65, 95, 130, 255);

            rl.drawRectangleRounded(sf_card_rect, 0.12, 6, sf_card_bg);
            rl.drawRectangleRoundedLinesEx(sf_card_rect, 0.12, 6, if (sf_card_hovered and steel_forge_research_state == .available) 2.0 else 1.2, sf_card_border);

            // Icon: Steel forge / blast furnace symbol
            rl.drawRectangle(@intFromFloat(sf_card_x + 12), @intFromFloat(sf_card_y + 12), 26, 26, rl.Color.init(30, 40, 56, 255));
            rl.drawRectangleLines(@intFromFloat(sf_card_x + 12), @intFromFloat(sf_card_y + 12), 26, 26, rl.Color.init(100, 160, 230, 255));
            rl.drawText("S", @intFromFloat(sf_card_x + 20), @intFromFloat(sf_card_y + 15), 18, rl.Color.init(160, 210, 255, 255));

            rl.drawText("Steel Forge", @intFromFloat(sf_card_x + 48), @intFromFloat(sf_card_y + 10), 15, rl.Color.white);
            rl.drawText("Metallurgical Project", @intFromFloat(sf_card_x + 48), @intFromFloat(sf_card_y + 28), 11, rl.Color.init(160, 195, 230, 255));

            if (steel_forge_research_state == .available) {
                // Cost badge
                const cost_text = fmt("Cost: {d} Wood, {d} Steel | Time: 2m 00s", .{
                    @as(i32, @intFromFloat(STEEL_FORGE_RESEARCH_WOOD_COST)),
                    @as(i32, @intFromFloat(STEEL_FORGE_RESEARCH_STEEL_COST)),
                });
                rl.drawText(cost_text, @intFromFloat(sf_card_x + 48), @intFromFloat(sf_card_y + 46), 11, if (can_afford_sf_res) rl.Color.init(180, 220, 255, 255) else rl.Color.init(255, 110, 110, 255));

                // Button pill
                const btn_pill_rect = rl.Rectangle.init(sf_card_x + 48, sf_card_y + 64, 210, 20);
                rl.drawRectangleRounded(btn_pill_rect, 0.3, 4, if (can_afford_sf_res) (if (sf_card_hovered) rl.Color.init(40, 75, 115, 255) else rl.Color.init(30, 55, 85, 255)) else rl.Color.init(55, 25, 25, 255));
                rl.drawRectangleRoundedLinesEx(btn_pill_rect, 0.3, 4, 1.0, if (can_afford_sf_res) rl.Color.init(80, 150, 220, 255) else rl.Color.init(180, 60, 60, 255));
                rl.drawText(if (can_afford_sf_res) "Click to Research (25W, 25S)" else "Need 25 Wood, 25 Steel", @intFromFloat(sf_card_x + 54), @intFromFloat(sf_card_y + 68), 10, if (can_afford_sf_res) rl.Color.white else rl.Color.init(255, 130, 130, 255));
            } else if (steel_forge_research_state == .researching) {
                const total_researchers = getTotalLabWorkers();
                const pct = getActiveResearchProgress();
                const speed_mult = getResearchSpeedMultiplier();
                if (speed_mult > 0.0) {
                    const rem_sec_f = (STEEL_FORGE_RESEARCH_DURATION - steel_forge_research_progress) / speed_mult;
                    const rem = @max(0, @as(i32, @intFromFloat(rem_sec_f)));
                    const rem_min = @divTrunc(rem, 60);
                    const rem_sec = @rem(rem, 60);

                    const speed_pct = @as(i32, @intFromFloat(speed_mult * 100.0));
                    const staff_info = if (total_researchers > getMaxEffectiveResearchWorkers())
                        fmt("{d} Staff (Cap 4 Labs), {d}%", .{ total_researchers, speed_pct })
                    else
                        fmt("{d} Staff, {d}%", .{ total_researchers, speed_pct });

                    _ = rl.drawText(
                        fmt("Researching: {d}% | ~{d}m {d:0>2}s left ({s})", .{
                            @as(i32, @intFromFloat(pct * 100.0)),
                            rem_min,
                            rem_sec,
                            staff_info,
                        }),
                        @intFromFloat(sf_card_x + 48),
                        @intFromFloat(sf_card_y + 46),
                        11,
                        rl.Color.init(120, 210, 255, 255),
                    );
                } else {
                    _ = rl.drawText(
                        fmt("PAUSED: 0 Staff in Labs (Progress: {d}%)", .{@as(i32, @intFromFloat(pct * 100.0))}),
                        @intFromFloat(sf_card_x + 48),
                        @intFromFloat(sf_card_y + 46),
                        11,
                        rl.Color.init(255, 120, 100, 255),
                    );
                }

                // Progress Bar
                const bar_x: f32 = sf_card_x + 48.0;
                const bar_y: f32 = sf_card_y + 66.0;
                const bar_w: f32 = sf_cancel_btn_rect.x - 10.0 - bar_x;
                const bar_h: f32 = 14.0;
                rl.drawRectangleRounded(rl.Rectangle.init(bar_x, bar_y, bar_w, bar_h), 0.3, 4, rl.Color.init(20, 30, 40, 255));
                rl.drawRectangleRoundedLinesEx(rl.Rectangle.init(bar_x, bar_y, bar_w, bar_h), 0.3, 4, 1.0, rl.Color.init(60, 100, 130, 255));
                rl.drawRectangleRounded(rl.Rectangle.init(bar_x, bar_y, bar_w * pct, bar_h), 0.3, 4, if (total_researchers > 0) rl.Color.init(80, 185, 255, 255) else rl.Color.init(180, 80, 70, 255));

                // Cancel Button
                rl.drawRectangleRounded(sf_cancel_btn_rect, 0.3, 4, if (sf_cancel_hovered) rl.Color.init(170, 40, 45, 255) else rl.Color.init(55, 25, 28, 255));
                rl.drawRectangleRoundedLinesEx(sf_cancel_btn_rect, 0.3, 4, 1.0, if (sf_cancel_hovered) rl.Color.init(255, 110, 110, 255) else rl.Color.init(180, 60, 65, 255));
                const cancel_tw = rl.measureText("Cancel", 11);
                const cancel_tx = @as(i32, @intFromFloat(sf_cancel_btn_rect.x + (sf_cancel_btn_rect.width - @as(f32, @floatFromInt(cancel_tw))) / 2.0));
                const cancel_ty = @as(i32, @intFromFloat(sf_cancel_btn_rect.y + 4.5));
                rl.drawText("Cancel", cancel_tx, cancel_ty, 11, if (sf_cancel_hovered) rl.Color.white else rl.Color.init(255, 180, 180, 255));
            } else if (steel_forge_research_state == .completed) {
                rl.drawText("Unlocks 4x4 Steel Forge metallurgical building", @intFromFloat(sf_card_x + 48), @intFromFloat(sf_card_y + 46), 11, rl.Color.init(170, 205, 240, 255));

                const comp_rect = rl.Rectangle.init(sf_card_x + 48, sf_card_y + 64, 160, 20);
                rl.drawRectangleRounded(comp_rect, 0.3, 4, rl.Color.init(30, 50, 75, 255));
                rl.drawRectangleRoundedLinesEx(comp_rect, 0.3, 4, 1.0, rl.Color.init(100, 180, 255, 255));
                rl.drawText("[RESEARCHED - UNLOCKED]", @intFromFloat(sf_card_x + 54), @intFromFloat(sf_card_y + 68), 10, rl.Color.init(150, 215, 255, 255));
            }
        }
    }
}

fn drawControlsButton(mouse_pos: rl.Vector2) void {
    const sw = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const sh = @as(f32, @floatFromInt(rl.getScreenHeight()));
    const btn_rect = getControlsBtnRect(sw, sh);
    const btn_hovered = rl.checkCollisionPointRec(mouse_pos, btn_rect);

    const btn_bg = if (btn_hovered)
        rl.Color.init(42, 52, 68, 255)
    else
        rl.Color.init(22, 28, 38, 245);

    const btn_border = if (btn_hovered)
        rl.Color.init(245, 195, 65, 255)
    else
        rl.Color.init(90, 110, 135, 255);

    const btn_text_color = if (btn_hovered)
        rl.Color.init(255, 225, 120, 255)
    else
        rl.Color.init(220, 230, 240, 255);

    rl.drawRectangleRounded(btn_rect, 0.25, 6, btn_bg);
    rl.drawRectangleRoundedLinesEx(btn_rect, 0.25, 6, if (btn_hovered) 2.0 else 1.2, btn_border);

    const label = "Controls";
    const tw = rl.measureText(label, 14);
    rl.drawText(
        label,
        @intFromFloat(btn_rect.x + (btn_rect.width - @as(f32, @floatFromInt(tw))) / 2.0),
        @intFromFloat(btn_rect.y + 11.0),
        14,
        btn_text_color,
    );
}

fn drawPlacementTooltip(mouse_pos: rl.Vector2, btype: BuildingType, check: PlacementCheck) void {
    const tip_x: i32 = @as(i32, @intFromFloat(mouse_pos.x)) + 20;
    const tip_y: i32 = @as(i32, @intFromFloat(mouse_pos.y)) + 16;

    const text = if (check.valid)
        (if (btype.steelCost() > 0.0)
            fmt("[LMB] Place {s} ({d}x{d}, {d} Wood, {d} Steel) | [Shift+LMB] Multiple | [RMB/Esc] Cancel", .{
                btype.name(),
                btype.gridWidth(),
                btype.gridLength(),
                @as(i32, @intFromFloat(btype.woodCost())),
                @as(i32, @intFromFloat(btype.steelCost())),
            })
        else
            fmt("[LMB] Place {s} ({d}x{d}, {d} Wood) | [Shift+LMB] Multiple | [RMB/Esc] Cancel", .{
                btype.name(),
                btype.gridWidth(),
                btype.gridLength(),
                @as(i32, @intFromFloat(btype.woodCost())),
            }))
    else
        fmt("Cannot Place: {s} | [RMB/Esc] Cancel", .{check.reason});

    const tw = rl.measureText(text, 12);
    const box_w = tw + 20;
    const box_h = 24;

    rl.drawRectangleRounded(
        rl.Rectangle.init(@floatFromInt(tip_x), @floatFromInt(tip_y), @floatFromInt(box_w), @floatFromInt(box_h)),
        0.3,
        4,
        rl.Color.init(16, 20, 28, 240),
    );
    rl.drawRectangleRoundedLinesEx(
        rl.Rectangle.init(@floatFromInt(tip_x), @floatFromInt(tip_y), @floatFromInt(box_w), @floatFromInt(box_h)),
        0.3,
        4,
        1.2,
        if (check.valid) rl.Color.init(80, 220, 140, 255) else rl.Color.init(235, 70, 70, 255),
    );
    rl.drawText(
        text,
        tip_x + 10,
        tip_y + 6,
        12,
        if (check.valid) rl.Color.init(140, 245, 175, 255) else rl.Color.init(255, 110, 110, 255),
    );
}

fn drawPopulationPopover(x: f32, y: f32) void {
    var resource_workers: i32 = 0;
    for (workers_assigned) |w| {
        resource_workers += w;
    }
    var construction_workers: i32 = 0;
    for (buildings[0..buildings_count]) |b| {
        if (b.state == .constructing or b.state == .dismantling) {
            construction_workers += b.active_builders;
        }
    }
    var greenhouse_workers: i32 = 0;
    for (buildings[0..buildings_count]) |b| {
        if (b.state == .completed and b.btype == .greenhouse) {
            greenhouse_workers += b.assigned_workers;
        }
    }
    var coal_mine_workers: i32 = 0;
    for (buildings[0..buildings_count]) |b| {
        if (b.state == .completed and b.btype == .coal_mine) {
            coal_mine_workers += b.assigned_workers;
        }
    }
    var wood_shack_workers: i32 = 0;
    for (buildings[0..buildings_count]) |b| {
        if (b.state == .completed and b.btype == .wood_shack) {
            wood_shack_workers += b.assigned_workers;
        }
    }
    var steel_forge_workers: i32 = 0;
    for (buildings[0..buildings_count]) |b| {
        if (b.state == .completed and b.btype == .steel_forge) {
            steel_forge_workers += b.assigned_workers;
        }
    }
    const lab_workers = getTotalLabWorkers();
    const total_working: i32 = resource_workers + construction_workers + greenhouse_workers + coal_mine_workers + wood_shack_workers + steel_forge_workers + lab_workers;
    const total_idle: i32 = @max(0, @as(i32, @intCast(total_citizens)) - total_working);

    const pop_w: f32 = 264.0;
    const pop_h: f32 = 202.0;

    // Subtle drop shadow
    rl.drawRectangleRounded(
        rl.Rectangle.init(x + 3.0, y + 3.0, pop_w, pop_h),
        0.08,
        6,
        rl.Color.init(5, 8, 12, 160),
    );

    // Popover body
    rl.drawRectangleRounded(
        rl.Rectangle.init(x, y, pop_w, pop_h),
        0.08,
        6,
        rl.Color.init(20, 24, 32, 252),
    );
    rl.drawRectangleRoundedLinesEx(
        rl.Rectangle.init(x, y, pop_w, pop_h),
        0.08,
        6,
        1.5,
        rl.Color.init(80, 105, 138, 255),
    );

    // Header
    rl.drawRectangle(@intFromFloat(x + 12.0), @intFromFloat(y + 11.0), 8, 14, rl.Color.init(245, 195, 65, 255));
    rl.drawText("CITIZEN WORKFORCE", @intFromFloat(x + 26.0), @intFromFloat(y + 10.0), 13, rl.Color.init(245, 205, 70, 255));

    // Separator line
    rl.drawLine(
        @intFromFloat(x + 12.0),
        @intFromFloat(y + 30.0),
        @intFromFloat(x + pop_w - 12.0),
        @intFromFloat(y + 30.0),
        rl.Color.init(45, 55, 70, 255),
    );

    // Working Citizens row
    rl.drawCircle(@intFromFloat(x + 18.0), @intFromFloat(y + 44.0), 4.0, rl.Color.init(80, 220, 130, 255));
    rl.drawText("Working Citizens:", @intFromFloat(x + 28.0), @intFromFloat(y + 37.0), 13, rl.Color.init(220, 230, 240, 255));
    const work_val = fmt("{d}", .{total_working});
    const work_val_w = rl.measureText(work_val, 13);
    rl.drawText(work_val, @intFromFloat(x + pop_w - 14.0 - @as(f32, @floatFromInt(work_val_w))), @intFromFloat(y + 37.0), 13, rl.Color.init(100, 235, 140, 255));

    // Breakdown details - 4 rows
    rl.drawText(
        fmt("  Gatherers: {d}  |  Builders: {d}", .{ resource_workers, construction_workers }),
        @intFromFloat(x + 20.0),
        @intFromFloat(y + 55.0),
        11,
        rl.Color.init(140, 165, 190, 255),
    );
    rl.drawText(
        fmt("  Farmers: {d}    |  Miners: {d}", .{ greenhouse_workers, coal_mine_workers }),
        @intFromFloat(x + 20.0),
        @intFromFloat(y + 69.0),
        11,
        rl.Color.init(140, 165, 190, 255),
    );
    rl.drawText(
        fmt("  Researchers: {d} | Lumberjacks: {d}", .{ lab_workers, wood_shack_workers }),
        @intFromFloat(x + 20.0),
        @intFromFloat(y + 83.0),
        11,
        rl.Color.init(140, 165, 190, 255),
    );
    rl.drawText(
        fmt("  Smiths: {d}", .{steel_forge_workers}),
        @intFromFloat(x + 20.0),
        @intFromFloat(y + 97.0),
        11,
        rl.Color.init(140, 165, 190, 255),
    );

    // Idle Citizens row
    rl.drawCircle(@intFromFloat(x + 18.0), @intFromFloat(y + 124.0), 4.0, rl.Color.init(245, 185, 65, 255));
    rl.drawText("Idle Citizens:", @intFromFloat(x + 28.0), @intFromFloat(y + 117.0), 13, rl.Color.init(220, 230, 240, 255));
    const idle_val = fmt("{d}", .{total_idle});
    const idle_val_w = rl.measureText(idle_val, 13);
    rl.drawText(idle_val, @intFromFloat(x + pop_w - 14.0 - @as(f32, @floatFromInt(idle_val_w))), @intFromFloat(y + 117.0), 13, rl.Color.init(255, 215, 80, 255));

    // Idle explanation
    rl.drawText(
        "  Available for new tasks & building",
        @intFromFloat(x + 24.0),
        @intFromFloat(y + 137.0),
        11,
        rl.Color.init(140, 165, 190, 255),
    );

    // Separator line
    rl.drawLine(
        @intFromFloat(x + 12.0),
        @intFromFloat(y + 157.0),
        @intFromFloat(x + pop_w - 12.0),
        @intFromFloat(y + 157.0),
        rl.Color.init(45, 55, 70, 255),
    );

    // Total row
    rl.drawText("Total Population:", @intFromFloat(x + 14.0), @intFromFloat(y + 168.0), 12, rl.Color.init(180, 195, 210, 255));
    const tot_val = fmt("{d}", .{total_citizens});
    const tot_val_w = rl.measureText(tot_val, 12);
    rl.drawText(tot_val, @intFromFloat(x + pop_w - 14.0 - @as(f32, @floatFromInt(tot_val_w))), @intFromFloat(y + 168.0), 12, rl.Color.white);
}

fn drawHUD(warm_count: i32, cold_count: i32, cached: CachedSceneUI, camera: rl.Camera3D, mouse_pos: rl.Vector2, placement_check: PlacementCheck) void {
    const screen_w = rl.getScreenWidth();

    // ------------------------------------------------------------------------
    // 3D FLOATING WORLD LABELS
    // ------------------------------------------------------------------------
    drawWorldLabels(cached);
    drawBuildingLabels(camera);

    // ------------------------------------------------------------------------
    // TOP STATUS BAR (Stockpiles & Population Overview)
    // ------------------------------------------------------------------------
    const top_bar_height: f32 = 46.0;
    rl.drawRectangle(0, 0, screen_w, @intFromFloat(top_bar_height), rl.Color.init(18, 22, 28, 235));
    rl.drawRectangle(0, @intFromFloat(top_bar_height - 2), screen_w, 2, rl.Color.init(45, 55, 68, 255));

    // Title
    rl.drawText("THE GENERATOR CITY", 16, 14, 16, rl.Color.init(245, 200, 70, 255));

    // Resource Stockpiles & Gathering Rates (Dynamically spaced)
    const res_start_x: i32 = 205;
    const fps_badge_w: i32 = if (LIMIT_FPS_TO_REFRESH_RATE) 124 else 76;
    const fps_box_x: i32 = screen_w - fps_badge_w - 12;

    const pop_box_w: i32 = 360;
    const pop_box_x: i32 = fps_box_x - pop_box_w - 14;

    const available_res_w: i32 = @max(320, pop_box_x - res_start_x - 16);
    const col_w: i32 = @min(105, @divTrunc(available_res_w, 4));

    var cur_x: i32 = res_start_x;

    inline for (std.meta.tags(Resource)) |r| {
        const idx = @intFromEnum(r);
        const amount = stockpiles[idx];
        const workers = workers_assigned[idx];

        // Net rate calculation (Coal accounts for generator fuel consumption and coal mines, Food accounts for greenhouses, Wood accounts for wood shacks, Steel accounts for steel forges)
        var cm_coal_rate: f32 = 0.0;
        if (r == .coal) {
            for (buildings[0..buildings_count]) |b| {
                if (b.state == .completed and b.btype == .coal_mine) {
                    cm_coal_rate += @as(f32, @floatFromInt(b.assigned_workers)) * COAL_MINE_COAL_RATE_PER_WORKER_PER_SEC;
                }
            }
        }
        var gh_food_rate: f32 = 0.0;
        if (r == .food) {
            for (buildings[0..buildings_count]) |b| {
                if (b.state == .completed and b.btype == .greenhouse) {
                    gh_food_rate += @as(f32, @floatFromInt(b.assigned_workers)) * 1.0;
                }
            }
        }
        var ws_wood_rate: f32 = 0.0;
        if (r == .wood) {
            for (buildings[0..buildings_count]) |b| {
                if (b.state == .completed and b.btype == .wood_shack) {
                    ws_wood_rate += @as(f32, @floatFromInt(b.assigned_workers)) * WOOD_SHACK_WOOD_RATE_PER_WORKER_PER_SEC;
                }
            }
        }
        var sf_steel_rate: f32 = 0.0;
        if (r == .steel) {
            for (buildings[0..buildings_count]) |b| {
                if (b.state == .completed and b.btype == .steel_forge) {
                    sf_steel_rate += @as(f32, @floatFromInt(b.assigned_workers)) * STEEL_FORGE_STEEL_RATE_PER_WORKER_PER_SEC;
                }
            }
        }
        const pile_gather = if (isPileActive(r)) (@as(f32, @floatFromInt(workers)) * r.gatherRate()) else 0.0;
        const net_rate: f32 = if (r == .coal)
            pile_gather + cm_coal_rate - (if (generator_active) GENERATOR_COAL_DRAIN_PER_SEC else 0.0)
        else if (r == .food)
            pile_gather + gh_food_rate
        else if (r == .wood)
            pile_gather + ws_wood_rate
        else if (r == .steel)
            pile_gather + sf_steel_rate
        else
            pile_gather;

        // Tag dot
        rl.drawRectangle(cur_x, 15, 10, 16, r.color());

        // Resource name & amount
        _ = rl.drawText(
            fmt("{s}: {d}", .{ r.name(), @as(i32, @intFromFloat(amount)) }),
            cur_x + 14,
            10,
            14,
            rl.Color.white,
        );

        // Gathering rate text
        const rate_color = if (net_rate > 0.01)
            rl.Color.init(120, 230, 140, 255)
        else if (net_rate < -0.01)
            rl.Color.init(255, 100, 90, 255)
        else
            rl.Color.init(140, 145, 155, 255);

        const rate_sign = if (net_rate > 0.001) "+" else "";
        _ = rl.drawText(
            fmt("{s}{d:.1}/s", .{ rate_sign, net_rate }),
            cur_x + 14,
            27,
            11,
            rate_color,
        );

        cur_x += col_w;
    }

    // Population & Shelter Overview (Top-Right, before FPS counter)
    var total_shelter_cap: i32 = 0;
    for (buildings[0..buildings_count]) |b| {
        if (b.state == .completed and b.btype == .house) {
            total_shelter_cap += b.btype.capacity();
        }
    }
    const housed_count = @min(@as(i32, @intCast(total_citizens)), total_shelter_cap);
    const shelter_color = if (housed_count >= total_citizens)
        rl.Color.init(110, 230, 140, 255)
    else if (housed_count > 0)
        rl.Color.init(245, 205, 80, 255)
    else
        rl.Color.init(255, 120, 100, 255);

    const pop_pill_rect = getPopPillRect(screen_w);
    const pop_hovered = rl.checkCollisionPointRec(mouse_pos, pop_pill_rect);

    if (pop_hovered) {
        rl.drawRectangleRounded(pop_pill_rect, 0.25, 4, rl.Color.init(42, 54, 72, 220));
        rl.drawRectangleRoundedLinesEx(pop_pill_rect, 0.25, 4, 1.2, rl.Color.init(245, 195, 65, 220));
    }

    _ = rl.drawText(
        fmt("Pop: {d}", .{total_citizens}),
        pop_box_x + 8,
        14,
        14,
        if (pop_hovered) rl.Color.init(255, 225, 120, 255) else rl.Color.init(240, 245, 250, 255),
    );

    _ = rl.drawText(
        fmt("Shelter: {d}/{d}", .{ housed_count, total_citizens }),
        pop_box_x + 80,
        14,
        14,
        shelter_color,
    );

    // Warm tag
    _ = rl.drawText(
        fmt("Warm: {d}", .{warm_count}),
        pop_box_x + 195,
        14,
        14,
        COLOR_CITIZEN_WARM,
    );

    // Cold tag
    _ = rl.drawText(
        fmt("Cold: {d}", .{cold_count}),
        pop_box_x + 278,
        14,
        14,
        rl.Color.init(110, 185, 255, 255),
    );

    // FPS Display at the top-right corner of the screen
    const fps = rl.getFPS();
    const fps_text = if (LIMIT_FPS_TO_REFRESH_RATE)
        fmt("{d} FPS ({d}Hz)", .{ fps, ACTIVE_FPS_LIMIT })
    else if (TARGET_FPS > 0)
        fmt("{d} FPS (Cap {d})", .{ fps, TARGET_FPS })
    else
        fmt("{d} FPS", .{fps});

    const fps_tw = rl.measureText(fps_text, 13);
    const actual_fps_w: i32 = @max(fps_badge_w, fps_tw + 18);
    const actual_fps_x: i32 = screen_w - actual_fps_w - 12;

    const target_for_color = if (LIMIT_FPS_TO_REFRESH_RATE) ACTIVE_FPS_LIMIT else if (TARGET_FPS > 0) TARGET_FPS else 60;
    const is_good = fps >= @max(20, target_for_color - 4);
    const is_warn = fps >= @max(15, @divTrunc(target_for_color, 2));

    rl.drawRectangleRounded(
        rl.Rectangle.init(@floatFromInt(actual_fps_x), 10.0, @floatFromInt(actual_fps_w), 26.0),
        0.3,
        6,
        rl.Color.init(12, 16, 22, 230),
    );
    rl.drawRectangleRoundedLinesEx(
        rl.Rectangle.init(@floatFromInt(actual_fps_x), 10.0, @floatFromInt(actual_fps_w), 26.0),
        0.3,
        6,
        1.2,
        if (is_good) rl.Color.init(70, 215, 115, 200) else if (is_warn) rl.Color.init(245, 195, 65, 200) else rl.Color.init(245, 80, 80, 200),
    );
    rl.drawText(
        fps_text,
        actual_fps_x + @divTrunc(actual_fps_w - fps_tw, 2),
        16,
        13,
        if (is_good) rl.Color.init(100, 235, 140, 255) else if (is_warn) rl.Color.init(255, 215, 80, 255) else rl.Color.init(255, 100, 100, 255),
    );

    // ------------------------------------------------------------------------
    // FUEL WARNING BANNER
    // ------------------------------------------------------------------------
    if (fuel_warning_timer > 0.0) {
        const banner_h: f32 = 26.0;
        const banner_y: f32 = top_bar_height;
        rl.drawRectangle(0, @intFromFloat(banner_y), screen_w, @intFromFloat(banner_h), rl.Color.init(190, 30, 30, 235));
        const warn_msg = "WARNING: Insufficient Coal! The Heat Generator needs coal to operate. Click the Coal Pile to assign workers.";
        const tw = rl.measureText(warn_msg, 13);
        rl.drawText(
            warn_msg,
            @divTrunc(screen_w - tw, 2),
            @intFromFloat(banner_y + 6),
            13,
            rl.Color.white,
        );
    }



    // ------------------------------------------------------------------------
    // HEAT GENERATOR DIALOG
    // ------------------------------------------------------------------------
    if (selected_generator) {
        const sw_f = @as(f32, @floatFromInt(screen_w));
        const sh_f = @as(f32, @floatFromInt(rl.getScreenHeight()));
        if (getGeneratorDialogRect(camera, sw_f, sh_f)) |rect| {
            const gen_panel_w: f32 = rect.width;
            const gen_panel_h: f32 = rect.height;
            const gen_panel_x: f32 = rect.x;
            const gen_panel_y: f32 = rect.y;

            const gen_border_color = if (generator_active) COLOR_GENERATOR_LIT else rl.Color.init(245, 195, 65, 255);

            // Connecting line from card to generator chimney top
            const anchor_screen = rl.getWorldToScreen(.{ .x = 0.0, .y = 11.0, .z = 0.0 }, camera);
            const card_connect_y = if (rect.y < anchor_screen.y) rect.y + rect.height else rect.y;
            const card_connect_x = std.math.clamp(anchor_screen.x, rect.x + 16.0, rect.x + rect.width - 16.0);
            rl.drawLineEx(
                .{ .x = card_connect_x, .y = card_connect_y },
                .{ .x = anchor_screen.x, .y = anchor_screen.y },
                2.0,
                gen_border_color,
            );

            rl.drawRectangleRounded(
                rl.Rectangle.init(gen_panel_x, gen_panel_y, gen_panel_w, gen_panel_h),
                0.04,
                8,
                rl.Color.init(20, 24, 32, 245),
            );
            rl.drawRectangleRoundedLinesEx(
                rl.Rectangle.init(gen_panel_x, gen_panel_y, gen_panel_w, gen_panel_h),
                0.04,
                8,
                2.0,
                gen_border_color,
            );

            // Header
            rl.drawRectangle(@intFromFloat(gen_panel_x + 14), @intFromFloat(gen_panel_y + 12), 12, 14, COLOR_GENERATOR_LIT);
            rl.drawText("THE HEAT GENERATOR", @intFromFloat(gen_panel_x + 32), @intFromFloat(gen_panel_y + 10), 16, rl.Color.init(245, 205, 70, 255));

            // Close button [x]
            if (!is_paused) {
                if (rg.button(rl.Rectangle.init(gen_panel_x + gen_panel_w - 28, gen_panel_y + 8, 20, 20), "x")) {
                    selected_generator = false;
                }
            }

            rl.drawText("Central Thermal Facility | 4x4 Grid", @intFromFloat(gen_panel_x + 14), @intFromFloat(gen_panel_y + 30), 11, rl.Color.init(140, 175, 210, 255));

            if (generator_active) {
                rl.drawRectangle(@intFromFloat(gen_panel_x + 14), @intFromFloat(gen_panel_y + 48), 10, 10, COLOR_GENERATOR_LIT);
                rl.drawText("ONLINE - HEATING ACTIVE", @intFromFloat(gen_panel_x + 30), @intFromFloat(gen_panel_y + 46), 12, COLOR_GENERATOR_LIT);
            } else {
                rl.drawRectangle(@intFromFloat(gen_panel_x + 14), @intFromFloat(gen_panel_y + 48), 10, 10, rl.Color.init(120, 125, 135, 255));
                rl.drawText("OFFLINE - COLD", @intFromFloat(gen_panel_x + 30), @intFromFloat(gen_panel_y + 46), 12, rl.Color.init(150, 160, 170, 255));
            }

            const coal_amount = stockpiles[@intFromEnum(Resource.coal)];
            const btn_label = if (generator_active)
                "TURN HEAT GENERATOR OFF"
            else if (coal_amount > 0.0)
                "TURN HEAT GENERATOR ON"
            else
                "IGNITE (NO COAL!)";

            if (!is_paused) {
                if (rg.button(rl.Rectangle.init(gen_panel_x + 14, gen_panel_y + 68, gen_panel_w - 28, 36), btn_label)) {
                    tryToggleGenerator();
                }
            }

            _ = rl.drawText(
                fmt("Heat Radius: {d:.1} m", .{GENERATOR_HEAT_RADIUS}),
                @intFromFloat(gen_panel_x + 14),
                @intFromFloat(gen_panel_y + 114),
                13,
                rl.Color.init(210, 215, 225, 255),
            );

            _ = rl.drawText(
                fmt("Citizens Protected: {d} / {d}", .{ warm_count, total_citizens }),
                @intFromFloat(gen_panel_x + 14),
                @intFromFloat(gen_panel_y + 134),
                13,
                if (generator_active) COLOR_CITIZEN_WARM else rl.Color.init(140, 150, 165, 255),
            );

            _ = rl.drawText(
                fmt("Coal Reserve: {d} coal", .{@as(i32, @intFromFloat(coal_amount))}),
                @intFromFloat(gen_panel_x + 14),
                @intFromFloat(gen_panel_y + 154),
                13,
                if (coal_amount > 10.0) rl.Color.white else rl.Color.init(255, 120, 100, 255),
            );

            if (generator_active) {
                const coal_workers = if (isPileActive(.coal)) workers_assigned[@intFromEnum(Resource.coal)] else 0;
                var cm_coal_rate: f32 = 0.0;
                for (buildings[0..buildings_count]) |b| {
                    if (b.state == .completed and b.btype == .coal_mine) {
                        cm_coal_rate += @as(f32, @floatFromInt(b.assigned_workers)) * COAL_MINE_COAL_RATE_PER_WORKER_PER_SEC;
                    }
                }
                const net_coal = (@as(f32, @floatFromInt(coal_workers)) * COAL_GATHER_RATE_PER_WORKER_PER_SEC) + cm_coal_rate - GENERATOR_COAL_DRAIN_PER_SEC;
                if (net_coal < -0.01) {
                    const secs_left = @max(0.0, coal_amount / (-net_coal));
                    const total_s = @as(i32, @intFromFloat(secs_left));
                    const mins = @divTrunc(total_s, 60);
                    const secs = @rem(total_s, 60);
                    _ = rl.drawText(
                        fmt("Fuel Depletes In: ~{d}m {d:0>2}s", .{ mins, secs }),
                        @intFromFloat(gen_panel_x + 14),
                        @intFromFloat(gen_panel_y + 174),
                        12,
                        rl.Color.init(255, 175, 70, 255),
                    );
                } else {
                    _ = rl.drawText(
                        "Fuel Sustainable (Surplus)",
                        @intFromFloat(gen_panel_x + 14),
                        @intFromFloat(gen_panel_y + 174),
                        12,
                        rl.Color.init(120, 230, 140, 255),
                    );
                }
            } else {
                _ = rl.drawText(
                    fmt("Burn Rate: {d:.1} coal/sec", .{GENERATOR_COAL_DRAIN_PER_SEC}),
                    @intFromFloat(gen_panel_x + 14),
                    @intFromFloat(gen_panel_y + 174),
                    12,
                    rl.Color.init(150, 170, 190, 255),
                );
            }
        }
    }

    // ------------------------------------------------------------------------
    // BUILDING INSPECTION DIALOG
    // ------------------------------------------------------------------------
    drawBuildingDialog(camera, @as(f32, @floatFromInt(screen_w)), @as(f32, @floatFromInt(rl.getScreenHeight())));

    // ------------------------------------------------------------------------
    // BUILD & RESEARCH UI & CONTROLS BUTTON
    // ------------------------------------------------------------------------
    drawBuildUI(mouse_pos);
    drawResearchUI(mouse_pos);
    drawControlsButton(mouse_pos);

    // ------------------------------------------------------------------------
    // PLACEMENT TOOLTIP (When in placement mode)
    // ------------------------------------------------------------------------
    if (placing_building) |btype| {
        drawPlacementTooltip(mouse_pos, btype, placement_check);
    }

    // ------------------------------------------------------------------------
    // POPULATION POPOVER (Hover on Pop badge in top bar)
    // ------------------------------------------------------------------------
    if (pop_hovered) {
        drawPopulationPopover(pop_pill_rect.x - 10.0, 48.0);
    }
}

// ============================================================================
// PAUSE MENU MODAL
// ============================================================================

fn drawPauseMenu() void {
    const screen_w = rl.getScreenWidth();
    const screen_h = rl.getScreenHeight();

    // Dark semi-transparent background overlay
    rl.drawRectangle(0, 0, screen_w, screen_h, rl.Color.init(10, 14, 20, 200));

    const modal_w: f32 = 340.0;
    const modal_h: f32 = 280.0;
    const modal_x: f32 = (@as(f32, @floatFromInt(screen_w)) - modal_w) / 2.0;
    const modal_y: f32 = (@as(f32, @floatFromInt(screen_h)) - modal_h) / 2.0;

    // Modal background card
    rl.drawRectangleRounded(
        rl.Rectangle.init(modal_x, modal_y, modal_w, modal_h),
        0.06,
        8,
        rl.Color.init(24, 28, 36, 255),
    );
    rl.drawRectangleRoundedLinesEx(
        rl.Rectangle.init(modal_x, modal_y, modal_w, modal_h),
        0.06,
        8,
        2.0,
        rl.Color.init(80, 105, 135, 255),
    );

    // Title
    const title = "GAME PAUSED";
    const title_w = rl.measureText(title, 22);
    rl.drawText(
        title,
        @intFromFloat(modal_x + (modal_w - @as(f32, @floatFromInt(title_w))) / 2.0),
        @intFromFloat(modal_y + 24),
        22,
        rl.Color.init(245, 205, 70, 255),
    );

    // Subtitle
    const subtitle = "City operations are suspended";
    const sub_w = rl.measureText(subtitle, 13);
    rl.drawText(
        subtitle,
        @intFromFloat(modal_x + (modal_w - @as(f32, @floatFromInt(sub_w))) / 2.0),
        @intFromFloat(modal_y + 52),
        13,
        rl.Color.init(160, 175, 190, 255),
    );

    // Separator line
    rl.drawLine(
        @intFromFloat(modal_x + 30),
        @intFromFloat(modal_y + 74),
        @intFromFloat(modal_x + modal_w - 30),
        @intFromFloat(modal_y + 74),
        rl.Color.init(50, 62, 78, 255),
    );

    // Buttons
    const btn_w: f32 = 220.0;
    const btn_h: f32 = 38.0;
    const btn_x: f32 = modal_x + (modal_w - btn_w) / 2.0;

    const buttons = [_]struct {
        label: [:0]const u8,
        rect: rl.Rectangle,
    }{
        .{ .label = "CONTINUE", .rect = rl.Rectangle.init(btn_x, modal_y + 92, btn_w, btn_h) },
        .{ .label = "CONTROLS", .rect = rl.Rectangle.init(btn_x, modal_y + 144, btn_w, btn_h) },
        .{ .label = "QUIT GAME", .rect = rl.Rectangle.init(btn_x, modal_y + 196, btn_w, btn_h) },
    };

    // Keyboard navigation with Arrow keys
    if (rl.isKeyPressed(.up) or rl.isKeyPressed(.w)) {
        if (pause_menu_selected_idx == 0) {
            pause_menu_selected_idx = 2;
        } else {
            pause_menu_selected_idx -= 1;
        }
    } else if (rl.isKeyPressed(.down) or rl.isKeyPressed(.s)) {
        pause_menu_selected_idx = (pause_menu_selected_idx + 1) % 3;
    }

    // Mouse movement hover updates selection
    const mouse_delta = rl.getMouseDelta();
    if (@abs(mouse_delta.x) > 0.5 or @abs(mouse_delta.y) > 0.5) {
        const mouse_pos = rl.getMousePosition();
        for (buttons, 0..) |btn, idx| {
            if (rl.checkCollisionPointRec(mouse_pos, btn.rect)) {
                pause_menu_selected_idx = idx;
                break;
            }
        }
    }

    var clicked_idx: ?usize = null;
    for (buttons, 0..) |btn, idx| {
        const is_sel = (pause_menu_selected_idx == idx);

        if (is_sel) {
            // Amber glow background behind selected button
            rl.drawRectangleRounded(
                rl.Rectangle.init(btn.rect.x - 3, btn.rect.y - 3, btn.rect.width + 6, btn.rect.height + 6),
                0.22,
                6,
                rl.Color.init(245, 205, 70, 45),
            );
        }

        if (rg.button(btn.rect, btn.label)) {
            clicked_idx = idx;
        }

        if (is_sel) {
            // Bright gold border highlight
            rl.drawRectangleRoundedLinesEx(
                rl.Rectangle.init(btn.rect.x - 2, btn.rect.y - 2, btn.rect.width + 4, btn.rect.height + 4),
                0.22,
                6,
                2.0,
                rl.Color.init(245, 205, 70, 255),
            );
        }
    }

    // Navigation hint footer
    const nav_hint = "[Up / Down] Select   [Enter] Confirm";
    const hint_w = rl.measureText(nav_hint, 11);
    rl.drawText(
        nav_hint,
        @intFromFloat(modal_x + (modal_w - @as(f32, @floatFromInt(hint_w))) / 2.0),
        @intFromFloat(modal_y + 248),
        11,
        rl.Color.init(130, 150, 175, 255),
    );

    const enter_pressed = rl.isKeyPressed(.enter) or rl.isKeyPressed(.kp_enter);
    const action_idx = if (enter_pressed) pause_menu_selected_idx else clicked_idx;

    if (action_idx) |idx| {
        switch (idx) {
            0 => {
                is_paused = false;
                pause_menu_selected_idx = 0;
            },
            1 => {
                show_controls_dialog = true;
            },
            2 => {
                should_quit = true;
            },
            else => {},
        }
    }
}

// ============================================================================
// CONTROLS DIALOG MODAL
// ============================================================================

fn drawControlSectionHeader(x: f32, y: f32, title: [:0]const u8) void {
    rl.drawRectangle(@intFromFloat(x), @intFromFloat(y + 2), 4, 12, rl.Color.init(245, 195, 65, 255));
    rl.drawText(title, @intFromFloat(x + 10), @intFromFloat(y), 12, rl.Color.init(245, 205, 80, 255));
}

fn drawControlRow(x: f32, y: f32, key_badge: [:0]const u8, description: [:0]const u8) void {
    const badge_w: f32 = 142.0;
    const badge_h: f32 = 18.0;
    const badge_rect = rl.Rectangle.init(x, y - 1.0, badge_w, badge_h);

    rl.drawRectangleRounded(badge_rect, 0.3, 4, rl.Color.init(34, 42, 54, 255));
    rl.drawRectangleRoundedLinesEx(badge_rect, 0.3, 4, 1.0, rl.Color.init(70, 90, 118, 255));
    rl.drawText(key_badge, @intFromFloat(x + 6.0), @intFromFloat(y + 2.0), 11, rl.Color.init(225, 238, 252, 255));

    rl.drawText(description, @intFromFloat(x + badge_w + 10.0), @intFromFloat(y + 2.0), 11, rl.Color.init(180, 195, 212, 255));
}

fn drawControlsDialog() void {
    const sw_f = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const sh_f = @as(f32, @floatFromInt(rl.getScreenHeight()));

    // Dark semi-transparent background overlay
    rl.drawRectangle(0, 0, rl.getScreenWidth(), rl.getScreenHeight(), rl.Color.init(10, 14, 20, 215));

    const modal_w: f32 = 750.0;
    const modal_h: f32 = 425.0;
    const modal_x: f32 = (sw_f - modal_w) / 2.0;
    const modal_y: f32 = (sh_f - modal_h) / 2.0;

    // Modal background card with subtle shadow
    rl.drawRectangleRounded(
        rl.Rectangle.init(modal_x + 3.0, modal_y + 3.0, modal_w, modal_h),
        0.04,
        8,
        rl.Color.init(5, 7, 10, 140),
    );
    rl.drawRectangleRounded(
        rl.Rectangle.init(modal_x, modal_y, modal_w, modal_h),
        0.04,
        8,
        rl.Color.init(22, 26, 36, 255),
    );
    rl.drawRectangleRoundedLinesEx(
        rl.Rectangle.init(modal_x, modal_y, modal_w, modal_h),
        0.04,
        8,
        2.0,
        rl.Color.init(80, 105, 135, 255),
    );

    // Header accent bar
    rl.drawRectangle(@intFromFloat(modal_x + 24), @intFromFloat(modal_y + 18), 10, 22, rl.Color.init(245, 195, 65, 255));

    // Title
    rl.drawText("GAME CONTROLS", @intFromFloat(modal_x + 42), @intFromFloat(modal_y + 16), 20, rl.Color.init(245, 205, 70, 255));
    rl.drawText("Quick command reference for city management", @intFromFloat(modal_x + 42), @intFromFloat(modal_y + 38), 12, rl.Color.init(150, 170, 195, 255));

    // Close button [x]
    if (rg.button(rl.Rectangle.init(modal_x + modal_w - 38, modal_y + 16, 24, 24), "x")) {
        show_controls_dialog = false;
        is_paused = false;
        pause_menu_selected_idx = 0;
    }

    // Divider line
    rl.drawLine(
        @intFromFloat(modal_x + 24),
        @intFromFloat(modal_y + 60),
        @intFromFloat(modal_x + modal_w - 24),
        @intFromFloat(modal_y + 60),
        rl.Color.init(48, 58, 74, 255),
    );

    // Vertical divider line between column 1 and column 2
    rl.drawLine(
        @intFromFloat(modal_x + 370),
        @intFromFloat(modal_y + 70),
        @intFromFloat(modal_x + 370),
        @intFromFloat(modal_y + modal_h - 60),
        rl.Color.init(40, 50, 65, 255),
    );

    // COLUMN 1: Camera Navigation & Building
    const col1_x = modal_x + 24.0;
    var y1: f32 = modal_y + 72.0;

    drawControlSectionHeader(col1_x, y1, "CAMERA & NAVIGATION");
    y1 += 22.0;
    drawControlRow(col1_x, y1, "W / A / S / D / Arrows", "Pan camera across snow");
    y1 += 22.0;
    drawControlRow(col1_x, y1, "RMB Drag", "Smooth mouse camera pan");
    y1 += 22.0;
    drawControlRow(col1_x, y1, "Mouse Wheel", "Zoom in / out");
    y1 += 30.0;

    drawControlSectionHeader(col1_x, y1, "BUILDING & CONSTRUCTION");
    y1 += 22.0;
    drawControlRow(col1_x, y1, "B / Build Button", "Open or close Build Menu");
    y1 += 22.0;
    drawControlRow(col1_x, y1, "LMB", "Place building on grid");
    y1 += 22.0;
    drawControlRow(col1_x, y1, "Shift + LMB", "Place multiple buildings");
    y1 += 22.0;
    drawControlRow(col1_x, y1, "RMB / ESC", "Cancel placement mode");

    // COLUMN 2: Settlement Management & System
    const col2_x = modal_x + 386.0;
    var y2: f32 = modal_y + 72.0;

    drawControlSectionHeader(col2_x, y2, "SETTLEMENT MANAGEMENT");
    y2 += 22.0;
    drawControlRow(col2_x, y2, "Click Resource Pile", "Assign workers (Max 15 per pile)");
    y2 += 22.0;
    drawControlRow(col2_x, y2, "Click Heat Generator", "Toggle heating ON / OFF");
    y2 += 22.0;
    drawControlRow(col2_x, y2, "Click Building", "Inspect shelter & builders");
    y2 += 22.0;
    drawControlRow(col2_x, y2, "Hover Population", "View working vs idle citizens");
    y2 += 30.0;

    drawControlSectionHeader(col2_x, y2, "SYSTEM & SHORTCUTS");
    y2 += 22.0;
    drawControlRow(col2_x, y2, "ESC", "Pause / Close open dialogs");
    y2 += 22.0;
    drawControlRow(col2_x, y2, "Controls Button", "Open this guide anytime");

    // Bottom divider line
    rl.drawLine(
        @intFromFloat(modal_x + 24),
        @intFromFloat(modal_y + modal_h - 52),
        @intFromFloat(modal_x + modal_w - 24),
        @intFromFloat(modal_y + modal_h - 52),
        rl.Color.init(48, 58, 74, 255),
    );

    // Resume Button
    const btn_w: f32 = 180.0;
    const btn_h: f32 = 32.0;
    const btn_x: f32 = modal_x + (modal_w - btn_w) / 2.0;
    const btn_y: f32 = modal_y + modal_h - 42.0;

    if (rg.button(rl.Rectangle.init(btn_x, btn_y, btn_w, btn_h), "RESUME GAME") or rl.isKeyPressed(.enter) or rl.isKeyPressed(.kp_enter)) {
        show_controls_dialog = false;
        is_paused = false;
        pause_menu_selected_idx = 0;
    }
}

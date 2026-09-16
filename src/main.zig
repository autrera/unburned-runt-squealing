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

// --- Gathering Rates (Resources gathered per assigned worker per second) ---
pub var COAL_GATHER_RATE_PER_WORKER_PER_SEC: f32 = 0.40;
pub var WOOD_GATHER_RATE_PER_WORKER_PER_SEC: f32 = 0.50;
pub var STEEL_GATHER_RATE_PER_WORKER_PER_SEC: f32 = 0.25;
pub var FOOD_GATHER_RATE_PER_WORKER_PER_SEC: f32 = 0.35;

// --- Resource Pile Positions (Generator is located at (0, 0, 0)) ---
pub var COAL_PILE_POSITION: rl.Vector3 = .{ .x = -2.5, .y = 0.0, .z = -14.5 };
pub var WOOD_PILE_POSITION: rl.Vector3 = .{ .x = 11.5, .y = 0.0, .z = -6.5 };
pub var STEEL_PILE_POSITION: rl.Vector3 = .{ .x = -11.0, .y = 0.0, .z = 6.0 };
pub var FOOD_PILE_POSITION: rl.Vector3 = .{ .x = 6.0, .y = 0.0, .z = 11.5 };

// --- Citizen Movement & Behavior Settings ---
/// Walking speed of citizens in world units per second
pub var CITIZEN_WALK_SPEED: f32 = 3.0;
/// Inner radius boundary for idle citizens gathering around the generator
pub var CITIZEN_IDLE_MIN_RADIUS: f32 = 2.8;
/// Outer radius boundary for idle citizens gathering around the generator
pub var CITIZEN_IDLE_MAX_RADIUS: f32 = 8.5;
/// Wander radius around a resource pile for working citizens
pub var CITIZEN_WORK_RADIUS: f32 = 3.6;

// --- Camera Navigation Settings ---
pub var CAMERA_PAN_SPEED: f32 = 28.0;
pub var CAMERA_ZOOM_SPEED: f32 = 3.5;
pub var CAMERA_MIN_DISTANCE: f32 = 12.0;
pub var CAMERA_MAX_DISTANCE: f32 = 80.0;
pub var CAMERA_DEFAULT_POSITION: rl.Vector3 = .{ .x = 0.0, .y = 35.0, .z = 29.0 };
pub var CAMERA_DEFAULT_TARGET: rl.Vector3 = .{ .x = 0.0, .y = 0.0, .z = -1.0 };

// --- Performance & Frame Rate Settings ---
/// Target frame rate (0 = uncapped / unlimited frame rate)
pub var TARGET_FPS: i32 = 0;
/// Whether to enable VSync (false for uncapped frame rate)
pub var ENABLE_VSYNC: bool = false;

// --- In-World Interaction & Screen Hit Settings ---
/// Screen-space pixel hit radius around pile base to register clicks and hovers
pub var PILE_SCREEN_HIT_RADIUS_PX: f32 = 65.0;
/// In-world vertical height offset where the floating badge/card is anchored above the pile
pub var PILE_LABEL_HEIGHT_OFFSET: f32 = 3.8;

// --- Building & Construction Settings ---
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
/// Clearance collision radius around the central Heat Generator
pub var GENERATOR_COLLISION_RADIUS: f32 = 5.2;
/// Clearance collision radius around resource piles
pub var RESOURCE_PILE_COLLISION_RADIUS: f32 = 4.8;
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
pub var COLOR_SCAFFOLDING: rl.Color = rl.Color.init(184, 138, 72, 255); // Construction scaffolding frame
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

    pub fn toResource(self: CitizenRole) ?Resource {
        return switch (self) {
            .idle => null,
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

    pub fn name(self: BuildingType) [:0]const u8 {
        return switch (self) {
            .house => "House",
        };
    }

    pub fn woodCost(self: BuildingType) f32 {
        return switch (self) {
            .house => HOUSE_WOOD_COST,
        };
    }

    pub fn capacity(self: BuildingType) i32 {
        return switch (self) {
            .house => HOUSE_CAPACITY,
        };
    }

    pub fn maxBuilders(self: BuildingType) i32 {
        return switch (self) {
            .house => HOUSE_MAX_BUILDERS,
        };
    }

    pub fn baseBuildTime(self: BuildingType) f32 {
        return switch (self) {
            .house => HOUSE_BASE_BUILD_TIME,
        };
    }

    pub fn collisionRadius(self: BuildingType) f32 {
        return switch (self) {
            .house => HOUSE_COLLISION_RADIUS,
        };
    }
};

pub const BuildingState = enum {
    constructing,
    completed,
};

pub const Building = struct {
    id: usize,
    btype: BuildingType,
    pos: rl.Vector3,
    state: BuildingState,
    progress: f32, // 0.0 to 1.0
    active_builders: i32,
    is_warm: bool,
};

pub const BuildTab = enum {
    people,
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
            const to_add: usize = @intCast(@min(@as(i32, @intCast(self.idle_count)), delta));
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
var workers_assigned: [4]i32 = .{ 0, 0, 0, 0 }; // workers per Resource enum
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
var should_quit: bool = false;
var fuel_warning_timer: f32 = 0.0;

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

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

fn canPlaceBuildingAt(pos: rl.Vector3, btype: BuildingType) PlacementCheck {
    const col_radius = btype.collisionRadius();

    // 1. Distance to Heat Generator at (0, 0, 0)
    const dist_gen_sq = pos.x * pos.x + pos.z * pos.z;
    const min_gen_dist = GENERATOR_COLLISION_RADIUS + col_radius;
    if (dist_gen_sq < min_gen_dist * min_gen_dist) {
        return .{ .valid = false, .reason = "Too close to Heat Generator" };
    }

    // 2. Distance to Resource Piles
    inline for (std.meta.tags(Resource)) |r| {
        const ppos = r.position();
        const dx = pos.x - ppos.x;
        const dz = pos.z - ppos.z;
        const min_pile_dist = RESOURCE_PILE_COLLISION_RADIUS + col_radius;
        if (dx * dx + dz * dz < min_pile_dist * min_pile_dist) {
            return .{ .valid = false, .reason = "Collides with resource pile" };
        }
    }

    // 3. Distance to existing buildings
    for (buildings[0..buildings_count]) |b| {
        const dx = pos.x - b.pos.x;
        const dz = pos.z - b.pos.z;
        const min_b_dist = b.btype.collisionRadius() + col_radius;
        if (dx * dx + dz * dz < min_b_dist * min_b_dist) {
            return .{ .valid = false, .reason = "Collides with existing building" };
        }
    }

    // 4. City boundary check (e.g. radius <= 85.0)
    if (dist_gen_sq > 85.0 * 85.0) {
        return .{ .valid = false, .reason = "Beyond city boundary" };
    }

    // 5. Wood cost check
    if (stockpiles[@intFromEnum(Resource.wood)] < btype.woodCost()) {
        return .{ .valid = false, .reason = "Insufficient Wood" };
    }

    return .{ .valid = true, .reason = "Click to Place" };
}

fn pickTargetForRole(role: CitizenRole) rl.Vector3 {
    if (role.toResource()) |res| {
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
            if (b.state == .constructing and b.active_builders > 0) {
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

    workers_assigned = .{ 0, 0, 0, 0 };
    selected_resource = null;
    hovered_resource = null;
    selected_generator = false;
    hovered_generator = false;

    buildings_count = 0;
    build_menu_open = false;
    active_build_tab = .people;
    placing_building = null;
    selected_building = null;
    hovered_building = null;

    citizen_mgr.init(@intCast(@min(STARTING_POPULATION, MAX_CITIZENS)));
    total_citizens = citizen_mgr.count;
    smoke_soa.init();
}

fn assignWorkers(res: Resource, delta: i32) void {
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

fn computePileUIBounds(r: Resource, camera: rl.Camera3D, selected: ?Resource, sw: f32, sh: f32) PileUIBounds {
    const p = r.position();
    const base_screen = rl.getWorldToScreen(.{ .x = p.x, .y = 0.5, .z = p.z }, camera);
    const badge_screen = rl.getWorldToScreen(.{ .x = p.x, .y = PILE_LABEL_HEIGHT_OFFSET, .z = p.z }, camera);

    const on_screen = badge_screen.x >= -120 and badge_screen.x <= sw + 120 and
        badge_screen.y >= -120 and badge_screen.y <= sh + 120;

    const badge_w: f32 = 175.0;
    const badge_h: f32 = 28.0;
    const badge_rect = rl.Rectangle.init(
        badge_screen.x - badge_w / 2.0,
        badge_screen.y - badge_h / 2.0,
        badge_w,
        badge_h,
    );

    var card_rect: ?rl.Rectangle = null;
    if (selected == r) {
        const card_w: f32 = 250.0;
        const card_h: f32 = 175.0;
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

    const gen_base_screen = rl.getWorldToScreen(.{ .x = 0.0, .y = 2.0, .z = 0.0 }, camera);
    res.gen_base_screen = gen_base_screen;
    res.gen_base_on_screen = gen_base_screen.x >= -100 and gen_base_screen.x <= sw + 100 and
        gen_base_screen.y >= -100 and gen_base_screen.y <= sh + 100;

    const gen_label_screen = rl.getWorldToScreen(.{ .x = 0.0, .y = 12.0, .z = 0.0 }, camera);
    res.gen_label_screen = gen_label_screen;
    const label_w: f32 = 190.0;
    const label_h: f32 = 28.0;
    res.gen_label_rect = rl.Rectangle.init(
        gen_label_screen.x - label_w / 2.0,
        gen_label_screen.y - label_h / 2.0,
        label_w,
        label_h,
    );
    res.gen_label_on_screen = gen_label_screen.x > 30 and gen_label_screen.x < sw - 30 and
        gen_label_screen.y > 45 and gen_label_screen.y < sh - 35;

    return res;
}

fn isMouseOverPileTarget(r: Resource, mouse_pos: rl.Vector2, ui: PileUIBounds, ray: rl.Ray) bool {
    if (!ui.is_on_screen) return false;

    // 1. Hovering the floating badge
    if (rl.checkCollisionPointRec(mouse_pos, ui.badge_rect)) {
        return true;
    }

    // 2. Hovering near the 2D screen projection of the 3D pile model on the snow
    const dist_to_base = rl.Vector2.distance(mouse_pos, ui.center_screen);
    if (dist_to_base < PILE_SCREEN_HIT_RADIUS_PX) {
        return true;
    }

    // 3. Hovering the 3D collision sphere in world space
    const pos = r.position();
    const hit = rl.getRayCollisionSphere(ray, .{ .x = pos.x, .y = 1.0, .z = pos.z }, 5.5);
    if (hit.hit) {
        return true;
    }

    return false;
}

fn isMouseOverGeneratorTarget(mouse_pos: rl.Vector2, cached: CachedSceneUI, ray: rl.Ray) bool {
    // 1. Hovering near the 2D screen projection of the Heat Generator base (height ~2.0)
    if (cached.gen_base_on_screen) {
        if (rl.Vector2.distance(mouse_pos, cached.gen_base_screen) < 70.0) {
            return true;
        }
    }

    // 2. Hovering the floating badge of the Heat Generator (height ~12.0)
    if (rl.checkCollisionPointRec(mouse_pos, cached.gen_label_rect)) {
        return true;
    }

    // 3. 3D Ray Collision with generous sphere
    const gen_hit = rl.getRayCollisionSphere(ray, .{ .x = 0.0, .y = 4.0, .z = 0.0 }, 5.8);
    if (gen_hit.hit) {
        return true;
    }

    return false;
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

    // Set target FPS if capped; otherwise leaving it unset allows uncapped frame rates
    if (TARGET_FPS > 0) {
        rl.setTargetFPS(TARGET_FPS);
    }

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

    while (!rl.windowShouldClose() and !should_quit) {
        const dt = rl.getFrameTime();

        // --------------------------------------------------------------------
        // PAUSE MENU / ESC Key handling
        // --------------------------------------------------------------------
        if (rl.isKeyPressed(.escape)) {
            if (placing_building != null) {
                placing_building = null;
            } else if (build_menu_open) {
                build_menu_open = false;
            } else if (selected_resource != null or selected_generator or selected_building != null) {
                selected_resource = null;
                selected_generator = false;
                selected_building = null;
            } else {
                is_paused = !is_paused;
            }
        }

        // --------------------------------------------------------------------
        // GAMEPLAY INPUT & SIMULATION (Only when NOT paused)
        // --------------------------------------------------------------------
        var ground_hit: ?rl.Vector3 = null;
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
                if (rl.isKeyPressed(.equal) or rl.isKeyPressed(.kp_add) or rl.isKeyPressed(.up)) {
                    assignWorkers(sel, 1);
                } else if (rl.isKeyPressed(.minus) or rl.isKeyPressed(.kp_subtract) or rl.isKeyPressed(.down)) {
                    assignWorkers(sel, -1);
                } else if (rl.isKeyPressed(.c)) {
                    assignWorkers(sel, -workers_assigned[@intFromEnum(sel)]);
                } else if (rl.isKeyPressed(.a)) {
                    assignWorkers(sel, getIdleCitizensCount());
                } else if (rl.isKeyPressed(.delete) or rl.isKeyPressed(.backspace)) {
                    selected_resource = null;
                }
            }

            // Screen & UI interaction coordinates
            const sw_f = @as(f32, @floatFromInt(rl.getScreenWidth()));
            const sh_f = @as(f32, @floatFromInt(rl.getScreenHeight()));

            const in_top_bar = mouse_pos.y < 48.0;
            const in_bottom_bar = mouse_pos.y > sh_f - 32.0;

            const build_btn_w: f32 = 126.0;
            const build_btn_h: f32 = 36.0;
            const build_btn_x: f32 = 16.0;
            const build_btn_y: f32 = sh_f - 30.0 - build_btn_h - 10.0;
            const build_btn_rect = rl.Rectangle.init(build_btn_x, build_btn_y, build_btn_w, build_btn_h);
            const in_build_btn = rl.checkCollisionPointRec(mouse_pos, build_btn_rect);

            const strip_h: f32 = 148.0;
            const strip_y: f32 = sh_f - 30.0 - strip_h;
            const in_build_strip = build_menu_open and mouse_pos.y >= strip_y and mouse_pos.y <= (sh_f - 30.0);

            const gen_dialog_w: f32 = 270.0;
            const gen_dialog_h: f32 = 220.0;
            const gen_dialog_x: f32 = sw_f - gen_dialog_w - 16.0;
            const gen_dialog_y: f32 = 46.0 + 14.0;
            const in_generator_dialog = selected_generator and
                mouse_pos.x >= gen_dialog_x and mouse_pos.x <= gen_dialog_x + gen_dialog_w and
                mouse_pos.y >= gen_dialog_y and mouse_pos.y <= gen_dialog_y + gen_dialog_h;

            const bldg_dialog_w: f32 = 250.0;
            const bldg_dialog_h: f32 = 180.0;
            const bldg_dialog_x: f32 = sw_f - bldg_dialog_w - 16.0;
            const bldg_dialog_y: f32 = 46.0 + 14.0;
            const in_building_dialog = (selected_building != null) and
                mouse_pos.x >= bldg_dialog_x and mouse_pos.x <= bldg_dialog_x + bldg_dialog_w and
                mouse_pos.y >= bldg_dialog_y and mouse_pos.y <= bldg_dialog_y + bldg_dialog_h;

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

            const in_ui = in_top_bar or in_bottom_bar or in_generator_dialog or in_active_card or in_build_btn or in_build_strip or in_building_dialog;

            const ray = rl.getScreenToWorldRay(mouse_pos, camera);
            ground_hit = getMouseGroundIntersection(ray);
            if (placing_building) |btype| {
                if (ground_hit) |pos| {
                    placement_check = canPlaceBuildingAt(pos, btype);
                }
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
                    const hit = rl.getRayCollisionSphere(ray, .{ .x = b.pos.x, .y = 1.5, .z = b.pos.z }, b.btype.collisionRadius());
                    if (hit.hit) {
                        hovered_building = b.id;
                    }
                }
            }

            // Set cursor style
            if (placing_building != null) {
                rl.setMouseCursor(if (placement_check.valid) .crosshair else .not_allowed);
            } else if (hovered_resource != null or hovered_generator or hovered_building != null or in_build_btn) {
                rl.setMouseCursor(.pointing_hand);
            } else {
                rl.setMouseCursor(.default);
            }

            // Handle Left Mouse Click
            if (rl.isMouseButtonPressed(.left)) {
                if (placing_building) |btype| {
                    if (!in_top_bar and !in_bottom_bar) {
                        if (ground_hit) |pos| {
                            if (placement_check.valid) {
                                stockpiles[@intFromEnum(Resource.wood)] -= btype.woodCost();
                                if (buildings_count < MAX_BUILDINGS) {
                                    buildings[buildings_count] = .{
                                        .id = buildings_count,
                                        .btype = btype,
                                        .pos = pos,
                                        .state = .constructing,
                                        .progress = 0.0,
                                        .active_builders = 0,
                                        .is_warm = false,
                                    };
                                    buildings_count += 1;
                                }
                                if (!rl.isKeyDown(.left_shift) and !rl.isKeyDown(.right_shift)) {
                                    placing_building = null;
                                }
                            }
                        }
                    }
                } else {
                    if (in_build_btn) {
                        build_menu_open = !build_menu_open;
                        if (build_menu_open) {
                            selected_resource = null;
                            selected_generator = false;
                            selected_building = null;
                        }
                    } else if (in_build_strip) {
                        // Check close button [x]
                        const close_rect = rl.Rectangle.init(sw_f - 36.0, strip_y + 8.0, 24.0, 24.0);
                        if (rl.checkCollisionPointRec(mouse_pos, close_rect)) {
                            build_menu_open = false;
                        }
                        // Check House card
                        const house_card_rect = rl.Rectangle.init(16.0, strip_y + 44.0, 230.0, 92.0);
                        if (rl.checkCollisionPointRec(mouse_pos, house_card_rect)) {
                            if (stockpiles[@intFromEnum(Resource.wood)] >= HOUSE_WOOD_COST) {
                                placing_building = .house;
                                build_menu_open = false;
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

            // 2. Resource gathering from infinite piles
            inline for (std.meta.tags(Resource)) |r| {
                const idx = @intFromEnum(r);
                const count = workers_assigned[idx];
                if (count > 0) {
                    stockpiles[idx] += @as(f32, @floatFromInt(count)) * r.gatherRate() * dt;
                }
            }

            // 3. Citizens SIMD movement, wandering, and warmth calculation (Single pass SoA)
            const citizen_stats = citizen_mgr.update(dt, generator_active);
            warm_count = citizen_stats.warm;
            cold_count = citizen_stats.cold;

            // 4. Generator smoke/steam particles (SIMD SoA)
            smoke_soa.update(dt, generator_active);

            // 5. Building construction simulation (idle workers)
            var idle_available: usize = citizen_mgr.getIdleCount();
            for (buildings[0..buildings_count]) |*b| {
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
                } else {
                    b.active_builders = 0;
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
        drawBuildingsSolids(ground_hit, placing_building, placement_check.valid);

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
        drawBuildingsWires(selected_building, hovered_building, ground_hit, placing_building, placement_check.valid);

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

        // 4. Pause Menu Modal Overlay (if paused)
        if (is_paused) {
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
        rl.drawCircle3D(.{ .x = 0, .y = 0.04, .z = 0 }, 8.4, .{ .x = 1, .y = 0, .z = 0 }, 90.0, rl.Color.init(255, 180, 50, 45));
    } else if (hovered) {
        rl.drawCircle3D(.{ .x = 0, .y = 0.04, .z = 0 }, 8.4, .{ .x = 1, .y = 0, .z = 0 }, 90.0, rl.Color.init(180, 220, 255, 35));
    }

    // --- Pass 1: Solid Geometries (Triangles Batch) ---
    // Base Tier 1: Wide base block
    rl.drawCube(.{ .x = 0, .y = 0.5, .z = 0 }, 7.4, 1.0, 7.4, COLOR_GENERATOR_BASE);

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
        rl.drawCylinderWires(.{ .x = 0, .y = 0.05, .z = 0 }, 8.4, 8.4, 0.15, 48, rl.Color.gold);
    } else if (hovered) {
        rl.drawCylinderWires(.{ .x = 0, .y = 0.05, .z = 0 }, 8.4, 8.4, 0.08, 48, rl.Color.init(180, 220, 255, 180));
    }

    rl.drawCubeWires(.{ .x = 0, .y = 0.5, .z = 0 }, 7.4, 1.0, 7.4, rl.Color.init(20, 22, 26, 255));
    rl.drawCubeWires(.{ .x = 0, .y = 1.4, .z = 0 }, 5.8, 0.8, 5.8, rl.Color.init(25, 28, 32, 255));
    rl.drawCubeWires(.{ .x = 0, .y = 3.4, .z = 0 }, 4.4, 3.2, 4.4, rl.Color.init(18, 20, 24, 255));
    rl.drawSphereWires(.{ .x = 0, .y = 5.8, .z = 0 }, 2.32, 8, 8, rl.Color.init(28, 30, 36, 180));
    rl.drawCylinderWires(.{ .x = 0, .y = 7.0, .z = 0 }, 1.15, 1.35, 4.2, 8, rl.Color.init(22, 24, 28, 255));
}

fn drawResourcePiles(selected: ?Resource, hovered: ?Resource) void {
    // --- Pass 1: Solid Geometries (Triangles Batch) ---
    // Selection & hover visual ground indicators
    inline for (std.meta.tags(Resource)) |r| {
        const pos = r.position();
        if (selected == r) {
            rl.drawCircle3D(.{ .x = pos.x, .y = 0.03, .z = pos.z }, 4.4, .{ .x = 1, .y = 0, .z = 0 }, 90.0, rl.Color.init(255, 205, 50, 50));
        } else if (hovered == r) {
            rl.drawCircle3D(.{ .x = pos.x, .y = 0.03, .z = pos.z }, 4.4, .{ .x = 1, .y = 0, .z = 0 }, 90.0, rl.Color.init(180, 220, 255, 40));
        }
    }

    // 1. COAL PILE (Solids)
    {
        const pos = COAL_PILE_POSITION;
        rl.drawCube(.{ .x = pos.x, .y = 1.1, .z = pos.z }, 3.0, 2.2, 3.0, COLOR_COAL_PILE);
        rl.drawCube(.{ .x = pos.x + 1.2, .y = 0.8, .z = pos.z + 0.9 }, 2.2, 1.6, 2.2, rl.Color.init(38, 38, 44, 255));
        rl.drawCube(.{ .x = pos.x - 1.1, .y = 0.7, .z = pos.z - 0.9 }, 2.0, 1.4, 2.0, rl.Color.init(44, 44, 52, 255));
        rl.drawCube(.{ .x = pos.x + 0.8, .y = 0.6, .z = pos.z - 1.1 }, 1.6, 1.2, 1.6, rl.Color.init(32, 32, 38, 255));
        rl.drawCube(.{ .x = pos.x - 0.9, .y = 0.5, .z = pos.z + 1.2 }, 1.5, 1.0, 1.5, rl.Color.init(48, 48, 56, 255));
        rl.drawCube(.{ .x = pos.x + 0.1, .y = 2.4, .z = pos.z }, 1.4, 0.9, 1.4, rl.Color.init(22, 22, 26, 255));
    }

    // 2. WOOD PILE (Solids)
    {
        const pos = WOOD_PILE_POSITION;
        rl.drawCube(.{ .x = pos.x - 1.2, .y = 0.45, .z = pos.z }, 1.0, 0.9, 4.6, COLOR_WOOD_PILE);
        rl.drawCube(.{ .x = pos.x, .y = 0.45, .z = pos.z }, 1.0, 0.9, 4.6, COLOR_WOOD_PILE);
        rl.drawCube(.{ .x = pos.x + 1.2, .y = 0.45, .z = pos.z }, 1.0, 0.9, 4.6, COLOR_WOOD_PILE);
        rl.drawCube(.{ .x = pos.x - 0.6, .y = 1.3, .z = pos.z }, 1.0, 0.85, 4.4, rl.Color.init(162, 102, 58, 255));
        rl.drawCube(.{ .x = pos.x + 0.6, .y = 1.3, .z = pos.z }, 1.0, 0.85, 4.4, rl.Color.init(162, 102, 58, 255));
        rl.drawCube(.{ .x = pos.x, .y = 2.1, .z = pos.z }, 1.0, 0.8, 4.2, rl.Color.init(178, 115, 68, 255));
    }

    // 3. STEEL PILE (Solids)
    {
        const pos = STEEL_PILE_POSITION;
        rl.drawCube(.{ .x = pos.x, .y = 0.45, .z = pos.z - 1.0 }, 4.8, 0.85, 1.2, COLOR_STEEL_PILE);
        rl.drawCube(.{ .x = pos.x, .y = 0.45, .z = pos.z + 1.0 }, 4.8, 0.85, 1.2, COLOR_STEEL_PILE);
        rl.drawCube(.{ .x = pos.x - 1.3, .y = 1.25, .z = pos.z }, 1.2, 0.75, 4.0, rl.Color.init(168, 185, 205, 255));
        rl.drawCube(.{ .x = pos.x + 1.3, .y = 1.25, .z = pos.z }, 1.2, 0.75, 4.0, rl.Color.init(168, 185, 205, 255));
        rl.drawCube(.{ .x = pos.x, .y = 1.85, .z = pos.z }, 3.2, 0.5, 2.6, rl.Color.init(190, 208, 226, 255));
        rl.drawCube(.{ .x = pos.x + 1.8, .y = 0.65, .z = pos.z + 1.9 }, 1.3, 1.3, 1.3, rl.Color.init(130, 145, 165, 255));
    }

    // 4. FOOD CACHE (Solids)
    {
        const pos = FOOD_PILE_POSITION;
        rl.drawCube(.{ .x = pos.x - 0.9, .y = 0.95, .z = pos.z - 0.7 }, 1.9, 1.9, 1.9, COLOR_FOOD_PILE);
        rl.drawCube(.{ .x = pos.x + 0.9, .y = 0.85, .z = pos.z + 0.7 }, 1.7, 1.7, 1.7, rl.Color.init(180, 50, 40, 255));
        rl.drawCylinder(.{ .x = pos.x + 1.2, .y = 0.0, .z = pos.z - 1.1 }, 0.65, 0.65, 1.6, 12, rl.Color.init(115, 82, 58, 255));
        rl.drawCylinder(.{ .x = pos.x - 1.1, .y = 0.0, .z = pos.z + 1.2 }, 0.65, 0.65, 1.6, 12, rl.Color.init(115, 82, 58, 255));
        rl.drawSphereEx(.{ .x = pos.x - 0.9, .y = 2.2, .z = pos.z - 0.7 }, 0.55, 6, 6, rl.Color.init(215, 185, 145, 255));
    }

    // --- Pass 2: Wire Outlines & Indicators (Lines Batch) ---
    inline for (std.meta.tags(Resource)) |r| {
        const pos = r.position();
        if (selected == r) {
            rl.drawCylinderWires(.{ .x = pos.x, .y = 0.05, .z = pos.z }, 4.4, 4.4, 0.12, 32, rl.Color.gold);
        } else if (hovered == r) {
            rl.drawCylinderWires(.{ .x = pos.x, .y = 0.05, .z = pos.z }, 4.4, 4.4, 0.08, 32, rl.Color.init(200, 220, 255, 180));
        }
    }

    // Coal wires
    {
        const pos = COAL_PILE_POSITION;
        rl.drawCubeWires(.{ .x = pos.x, .y = 1.1, .z = pos.z }, 3.0, 2.2, 3.0, rl.Color.init(10, 10, 14, 255));
    }

    // Wood wires
    {
        const pos = WOOD_PILE_POSITION;
        rl.drawCubeWires(.{ .x = pos.x - 1.2, .y = 0.45, .z = pos.z }, 1.0, 0.9, 4.6, rl.Color.init(80, 45, 20, 255));
        rl.drawCubeWires(.{ .x = pos.x, .y = 0.45, .z = pos.z }, 1.0, 0.9, 4.6, rl.Color.init(80, 45, 20, 255));
        rl.drawCubeWires(.{ .x = pos.x + 1.2, .y = 0.45, .z = pos.z }, 1.0, 0.9, 4.6, rl.Color.init(80, 45, 20, 255));
        rl.drawCubeWires(.{ .x = pos.x, .y = 2.1, .z = pos.z }, 1.0, 0.8, 4.2, rl.Color.init(90, 55, 25, 255));
    }

    // Steel wires
    {
        const pos = STEEL_PILE_POSITION;
        rl.drawCubeWires(.{ .x = pos.x, .y = 0.45, .z = pos.z - 1.0 }, 4.8, 0.85, 1.2, rl.Color.init(80, 95, 110, 255));
        rl.drawCubeWires(.{ .x = pos.x, .y = 0.45, .z = pos.z + 1.0 }, 4.8, 0.85, 1.2, rl.Color.init(80, 95, 110, 255));
        rl.drawCubeWires(.{ .x = pos.x, .y = 1.85, .z = pos.z }, 3.2, 0.5, 2.6, rl.Color.init(100, 115, 130, 255));
    }

    // Food wires
    {
        const pos = FOOD_PILE_POSITION;
        rl.drawCubeWires(.{ .x = pos.x - 0.9, .y = 0.95, .z = pos.z - 0.7 }, 1.9, 1.9, 1.9, rl.Color.init(100, 25, 20, 255));
        rl.drawCubeWires(.{ .x = pos.x + 0.9, .y = 0.85, .z = pos.z + 0.7 }, 1.7, 1.7, 1.7, rl.Color.init(90, 20, 18, 255));
    }
}

fn drawBuildingsSolids(cand_pos: ?rl.Vector3, placing: ?BuildingType, can_place: bool) void {
    for (buildings[0..buildings_count]) |b| {
        if (b.state == .constructing) {
            // Foundation slab
            rl.drawCube(.{ .x = b.pos.x, .y = 0.2, .z = b.pos.z }, 4.2, 0.4, 4.2, COLOR_SCAFFOLDING);

            // 4 corner timber scaffolding posts (height rises with progress)
            const post_h = @max(0.6, 3.2 * b.progress);
            rl.drawCube(.{ .x = b.pos.x - 1.8, .y = post_h / 2.0, .z = b.pos.z - 1.8 }, 0.4, post_h, 0.4, COLOR_WOOD_PILE);
            rl.drawCube(.{ .x = b.pos.x + 1.8, .y = post_h / 2.0, .z = b.pos.z - 1.8 }, 0.4, post_h, 0.4, COLOR_WOOD_PILE);
            rl.drawCube(.{ .x = b.pos.x - 1.8, .y = post_h / 2.0, .z = b.pos.z + 1.8 }, 0.4, post_h, 0.4, COLOR_WOOD_PILE);
            rl.drawCube(.{ .x = b.pos.x + 1.8, .y = post_h / 2.0, .z = b.pos.z + 1.8 }, 0.4, post_h, 0.4, COLOR_WOOD_PILE);

            // Partial walls rising with progress
            const wall_h = 2.2 * b.progress;
            if (wall_h > 0.15) {
                rl.drawCube(.{ .x = b.pos.x, .y = 0.4 + wall_h / 2.0, .z = b.pos.z }, 3.6, wall_h, 3.6, COLOR_HOUSE_WALLS);
            }
        } else {
            // Completed House
            // Base foundation
            rl.drawCube(.{ .x = b.pos.x, .y = 0.2, .z = b.pos.z }, 4.2, 0.4, 4.2, rl.Color.init(55, 42, 32, 255));
            // Main timber walls
            rl.drawCube(.{ .x = b.pos.x, .y = 1.4, .z = b.pos.z }, 3.8, 2.2, 3.8, COLOR_HOUSE_WALLS);
            // Peaked slate roof
            rl.drawCube(.{ .x = b.pos.x, .y = 2.85, .z = b.pos.z }, 4.2, 0.75, 4.2, COLOR_HOUSE_ROOF);
            rl.drawCube(.{ .x = b.pos.x, .y = 3.35, .z = b.pos.z }, 4.3, 0.35, 1.8, rl.Color.init(45, 52, 60, 255));
            // Chimney
            rl.drawCube(.{ .x = b.pos.x + 1.2, .y = 3.2, .z = b.pos.z + 1.1 }, 0.7, 1.6, 0.7, COLOR_HOUSE_CHIMNEY);
            // Front door
            rl.drawCube(.{ .x = b.pos.x, .y = 0.8, .z = b.pos.z + 1.95 }, 1.0, 1.3, 0.15, rl.Color.init(42, 30, 22, 255));
            // Windows
            const win_color = if (b.is_warm) rl.Color.init(255, 210, 85, 255) else rl.Color.init(130, 175, 220, 255);
            rl.drawCube(.{ .x = b.pos.x - 1.95, .y = 1.5, .z = b.pos.z }, 0.15, 0.8, 0.8, win_color);
            rl.drawCube(.{ .x = b.pos.x + 1.95, .y = 1.5, .z = b.pos.z }, 0.15, 0.8, 0.8, win_color);
        }
    }

    // Ghost preview (solids)
    if (placing != null) {
        if (cand_pos) |pos| {
            const col = if (can_place) COLOR_GHOST_VALID else COLOR_GHOST_INVALID;
            rl.drawCylinder(.{ .x = pos.x, .y = 0.04, .z = pos.z }, HOUSE_COLLISION_RADIUS, HOUSE_COLLISION_RADIUS, 0.06, 32, col);
            rl.drawCube(.{ .x = pos.x, .y = 1.4, .z = pos.z }, 3.8, 2.2, 3.8, col);
            rl.drawCube(.{ .x = pos.x, .y = 2.85, .z = pos.z }, 4.2, 0.75, 4.2, col);
            rl.drawCube(.{ .x = pos.x + 1.2, .y = 3.2, .z = pos.z + 1.1 }, 0.7, 1.6, 0.7, col);
        }
    }
}

fn drawBuildingsWires(selected: ?usize, hovered: ?usize, cand_pos: ?rl.Vector3, placing: ?BuildingType, can_place: bool) void {
    for (buildings[0..buildings_count]) |b| {
        if (b.state == .constructing) {
            rl.drawCubeWires(.{ .x = b.pos.x, .y = 1.6, .z = b.pos.z }, 4.2, 3.2, 4.2, COLOR_SCAFFOLDING);
        } else {
            rl.drawCubeWires(.{ .x = b.pos.x, .y = 1.4, .z = b.pos.z }, 3.8, 2.2, 3.8, rl.Color.init(35, 25, 20, 255));
            rl.drawCubeWires(.{ .x = b.pos.x, .y = 2.85, .z = b.pos.z }, 4.2, 0.75, 4.2, rl.Color.init(30, 36, 42, 255));
            rl.drawCubeWires(.{ .x = b.pos.x + 1.2, .y = 3.2, .z = b.pos.z + 1.1 }, 0.7, 1.6, 0.7, rl.Color.init(25, 20, 18, 255));
        }

        if (selected == b.id) {
            rl.drawCylinderWires(.{ .x = b.pos.x, .y = 0.08, .z = b.pos.z }, 4.4, 4.4, 0.12, 32, rl.Color.gold);
        } else if (hovered == b.id) {
            rl.drawCylinderWires(.{ .x = b.pos.x, .y = 0.06, .z = b.pos.z }, 4.4, 4.4, 0.08, 32, rl.Color.init(180, 220, 255, 180));
        }
    }

    // Ghost preview (wires)
    if (placing != null) {
        if (cand_pos) |pos| {
            const wire_col = if (can_place) rl.Color.init(90, 255, 150, 255) else rl.Color.init(255, 80, 80, 255);
            rl.drawCylinderWires(.{ .x = pos.x, .y = 0.08, .z = pos.z }, HOUSE_COLLISION_RADIUS, HOUSE_COLLISION_RADIUS, 0.12, 32, wire_col);
            rl.drawCubeWires(.{ .x = pos.x, .y = 1.4, .z = pos.z }, 3.8, 2.2, 3.8, wire_col);
            rl.drawCubeWires(.{ .x = pos.x, .y = 2.85, .z = pos.z }, 4.2, 0.75, 4.2, wire_col);
        }
    }
}

// ============================================================================
// 2D HUD & UI
// ============================================================================

fn drawWorldLabels(cached: CachedSceneUI) void {
    // 1. Heat Generator floating label
    if (cached.gen_label_on_screen) {
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
        if (ui.is_on_screen) {
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
                    fmt("{s} Pile", .{r.name()}),
                    @intFromFloat(br.x + 25),
                    @intFromFloat(br.y + 4),
                    11,
                    if (is_hovered) rl.Color.init(255, 225, 120, 255) else rl.Color.white,
                );

                const count_text = fmt("{d} workers", .{assigned});
                _ = rl.drawText(
                    count_text,
                    @intFromFloat(br.x + 25),
                    @intFromFloat(br.y + 15),
                    10,
                    if (assigned > 0) rl.Color.init(120, 230, 140, 255) else rl.Color.init(150, 165, 180, 255),
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
                    const idle_count = getIdleCitizensCount();
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
                    rl.drawText("Infinite Gathering Point", @intFromFloat(cr.x + 12), @intFromFloat(cr.y + 29), 10, rl.Color.init(140, 175, 210, 255));

                    // Divider line 1
                    rl.drawLine(
                        @intFromFloat(cr.x + 12),
                        @intFromFloat(cr.y + 43),
                        @intFromFloat(cr.x + cr.width - 12),
                        @intFromFloat(cr.y + 43),
                        rl.Color.init(55, 65, 80, 255),
                    );

                    // Status info
                    _ = rl.drawText(
                        fmt("Assigned: {d} workers", .{assigned}),
                        @intFromFloat(cr.x + 12),
                        @intFromFloat(cr.y + 49),
                        13,
                        rl.Color.white,
                    );

                    _ = rl.drawText(
                        fmt("Yield: +{d:.1} {s}/sec", .{ rate, r.name() }),
                        @intFromFloat(cr.x + 12),
                        @intFromFloat(cr.y + 67),
                        12,
                        rl.Color.init(120, 230, 140, 255),
                    );

                    _ = rl.drawText(
                        fmt("Idle Citizens: {d} / {d}", .{ idle_count, total_citizens }),
                        @intFromFloat(cr.x + 12),
                        @intFromFloat(cr.y + 84),
                        12,
                        if (idle_count > 0) rl.Color.init(190, 220, 245, 255) else rl.Color.init(240, 140, 140, 255),
                    );

                    // Divider line 2
                    rl.drawLine(
                        @intFromFloat(cr.x + 12),
                        @intFromFloat(cr.y + 102),
                        @intFromFloat(cr.x + cr.width - 12),
                        @intFromFloat(cr.y + 102),
                        rl.Color.init(50, 60, 75, 255),
                    );

                    // Worker Allocation Buttons (Only clickable when not paused)
                    if (!is_paused) {
                        // Row 1: Incremental Buttons [-5] [-1] [+1] [+5]
                        const btn_y1 = cr.y + 108.0;
                        const btn_h1: f32 = 26.0;

                        if (rg.button(rl.Rectangle.init(cr.x + 12, btn_y1, 46, btn_h1), "-5")) {
                            assignWorkers(r, -5);
                        }
                        if (rg.button(rl.Rectangle.init(cr.x + 64, btn_y1, 40, btn_h1), "-1")) {
                            assignWorkers(r, -1);
                        }
                        if (rg.button(rl.Rectangle.init(cr.x + 110, btn_y1, 40, btn_h1), "+1")) {
                            assignWorkers(r, 1);
                        }
                        if (rg.button(rl.Rectangle.init(cr.x + 156, btn_y1, 46, btn_h1), "+5")) {
                            assignWorkers(r, 5);
                        }

                        // Row 2: Bulk Buttons [Recall All] [Assign All Idle]
                        const btn_y2 = cr.y + 140.0;
                        const btn_h2: f32 = 24.0;

                        if (rg.button(rl.Rectangle.init(cr.x + 12, btn_y2, 106, btn_h2), "Recall All")) {
                            assignWorkers(r, -assigned);
                        }
                        if (rg.button(rl.Rectangle.init(cr.x + 124, btn_y2, 114, btn_h2), "+All Idle")) {
                            assignWorkers(r, idle_count);
                        }
                    }
                }
            }
        }
    }
}

fn drawBuildingLabels(camera: rl.Camera3D) void {
    const sw = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const sh = @as(f32, @floatFromInt(rl.getScreenHeight()));

    for (buildings[0..buildings_count]) |b| {
        if (b.state == .constructing) {
            const screen_pos = rl.getWorldToScreen(.{ .x = b.pos.x, .y = 3.6, .z = b.pos.z }, camera);
            if (screen_pos.x > -50 and screen_pos.x < sw + 50 and screen_pos.y > -50 and screen_pos.y < sh + 50) {
                const bar_w: f32 = 110.0;
                const bar_h: f32 = 10.0;
                const bar_x = screen_pos.x - bar_w / 2.0;
                const card_h: f32 = 42.0;
                const card_y = screen_pos.y - card_h / 2.0;
                const bar_y = card_y + 18.0;

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
                    COLOR_SCAFFOLDING,
                );

                // Title & percentage
                const pct = @as(i32, @intFromFloat(b.progress * 100.0));
                rl.drawText(
                    fmt("House: {d}%", .{pct}),
                    @intFromFloat(bar_x),
                    @intFromFloat(card_y + 4),
                    11,
                    rl.Color.init(245, 205, 70, 255),
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
                const fill_w = bar_w * std.math.clamp(b.progress, 0.0, 1.0);
                rl.drawRectangle(
                    @intFromFloat(bar_x),
                    @intFromFloat(bar_y),
                    @intFromFloat(fill_w),
                    @intFromFloat(bar_h),
                    COLOR_SCAFFOLDING,
                );
                rl.drawRectangleLines(
                    @intFromFloat(bar_x),
                    @intFromFloat(bar_y),
                    @intFromFloat(bar_w),
                    @intFromFloat(bar_h),
                    rl.Color.init(80, 95, 115, 255),
                );

                // Builder status
                if (b.active_builders > 0) {
                    rl.drawText(
                        fmt("{d}/{d} Builders", .{ b.active_builders, b.btype.maxBuilders() }),
                        @intFromFloat(bar_x),
                        @intFromFloat(card_y + 30),
                        10,
                        rl.Color.init(130, 225, 160, 255),
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
        }
    }
}

fn drawBuildingDialog(sw_f: f32) void {
    if (selected_building) |bid| {
        if (bid < buildings_count) {
            const b = buildings[bid];
            const panel_w: f32 = 250.0;
            const panel_h: f32 = 175.0;
            const panel_x: f32 = sw_f - panel_w - 16.0;
            const panel_y: f32 = 46.0 + 14.0;

            rl.drawRectangleRounded(rl.Rectangle.init(panel_x, panel_y, panel_w, panel_h), 0.04, 8, rl.Color.init(20, 24, 32, 245));
            rl.drawRectangleRoundedLinesEx(rl.Rectangle.init(panel_x, panel_y, panel_w, panel_h), 0.04, 8, 2.0, rl.Color.init(184, 138, 72, 255));

            // Title icon + text
            rl.drawRectangle(@intFromFloat(panel_x + 14), @intFromFloat(panel_y + 12), 12, 14, COLOR_WOOD_PILE);
            const title_str = fmt("HOUSE #{d}", .{bid + 1});
            rl.drawText(title_str, @intFromFloat(panel_x + 32), @intFromFloat(panel_y + 10), 16, rl.Color.init(245, 205, 70, 255));

            // Close button [x]
            if (!is_paused) {
                if (rg.button(rl.Rectangle.init(panel_x + panel_w - 28, panel_y + 8, 20, 20), "x")) {
                    selected_building = null;
                }
            }

            // Subtitle
            rl.drawText("Residential Shelter", @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 30), 11, rl.Color.init(140, 175, 210, 255));

            // Status
            if (b.state == .completed) {
                rl.drawText("STATUS: INHABITED", @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 54), 12, rl.Color.init(100, 220, 140, 255));
                _ = rl.drawText(fmt("Shelter: {d} Citizens", .{b.btype.capacity()}), @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 76), 13, rl.Color.white);
                if (b.is_warm) {
                    rl.drawText("Heating: WARM (In Heat Zone)", @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 98), 12, COLOR_CITIZEN_WARM);
                } else {
                    rl.drawText("Heating: COLD (Outside Heat Zone)", @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 98), 12, rl.Color.init(110, 185, 255, 255));
                }
            } else {
                rl.drawText("STATUS: UNDER CONSTRUCTION", @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 54), 12, rl.Color.init(245, 195, 65, 255));
                const pct = @as(i32, @intFromFloat(b.progress * 100.0));
                _ = rl.drawText(fmt("Progress: {d}%", .{pct}), @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 76), 13, rl.Color.white);
                _ = rl.drawText(fmt("Active Builders: {d}/{d}", .{ b.active_builders, b.btype.maxBuilders() }), @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 98), 12, rl.Color.init(180, 200, 220, 255));
            }

            rl.drawText("Protects citizens against the freezing cold", @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 135), 11, rl.Color.init(140, 155, 175, 255));
        }
    }
}

fn drawBuildUI(mouse_pos: rl.Vector2) void {
    const sw = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const sh = @as(f32, @floatFromInt(rl.getScreenHeight()));
    const bot_bar_h: f32 = 30.0;

    // 1. Build Button (Bottom-Left)
    const btn_w: f32 = 126.0;
    const btn_h: f32 = 36.0;
    const btn_x: f32 = 16.0;
    const btn_y: f32 = sh - bot_bar_h - btn_h - 10.0;

    const btn_rect = rl.Rectangle.init(btn_x, btn_y, btn_w, btn_h);
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
        const strip_y: f32 = sh - bot_bar_h - strip_h;
        const strip_rect = rl.Rectangle.init(0, strip_y, sw, strip_h);

        // Dark metal background
        rl.drawRectangleRec(strip_rect, rl.Color.init(18, 22, 30, 248));
        rl.drawRectangle(0, @intFromFloat(strip_y), @intFromFloat(sw), 2, rl.Color.init(65, 80, 102, 255));

        // --- Tabs Header ---
        const tab_y = strip_y + 8.0;
        const tab_w: f32 = 110.0;
        const tab_h: f32 = 28.0;

        // Tab 1: "People" (Active Tab)
        const tab_people_rect = rl.Rectangle.init(16.0, tab_y, tab_w, tab_h);
        rl.drawRectangleRounded(tab_people_rect, 0.25, 4, rl.Color.init(42, 54, 72, 255));
        rl.drawRectangleRoundedLinesEx(tab_people_rect, 0.25, 4, 1.5, rl.Color.init(245, 195, 65, 255));
        rl.drawText("PEOPLE", 46, @intFromFloat(tab_y + 7), 13, rl.Color.init(245, 210, 80, 255));
        rl.drawRectangle(18, @intFromFloat(tab_y + tab_h - 2), @intFromFloat(tab_w - 4), 2, rl.Color.init(245, 195, 65, 255));

        // Inactive tabs
        const tab_res_rect = rl.Rectangle.init(134.0, tab_y, tab_w + 10, tab_h);
        rl.drawRectangleRounded(tab_res_rect, 0.25, 4, rl.Color.init(24, 28, 36, 180));
        rl.drawText("RESOURCES", 146, @intFromFloat(tab_y + 7), 12, rl.Color.init(100, 112, 128, 255));

        const tab_heat_rect = rl.Rectangle.init(262.0, tab_y, tab_w, tab_h);
        rl.drawRectangleRounded(tab_heat_rect, 0.25, 4, rl.Color.init(24, 28, 36, 180));
        rl.drawText("HEATING", 284, @intFromFloat(tab_y + 7), 12, rl.Color.init(100, 112, 128, 255));

        // Close button [x]
        const close_btn_rect = rl.Rectangle.init(sw - 36.0, tab_y, 24.0, 24.0);
        const close_hovered = rl.checkCollisionPointRec(mouse_pos, close_btn_rect);
        rl.drawRectangleRounded(close_btn_rect, 0.2, 4, if (close_hovered) rl.Color.init(200, 50, 50, 255) else rl.Color.init(32, 38, 48, 255));
        rl.drawText("x", @intFromFloat(sw - 29), @intFromFloat(tab_y + 3), 15, rl.Color.white);

        // --- Building Card: House ---
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

        // Capacity & Builder Specs
        rl.drawText("Capacity: 10 People", @intFromFloat(card_x + 50), @intFromFloat(card_y + 57), 11, rl.Color.init(180, 195, 215, 255));
        rl.drawText("Builders: Up to 10 (20s)", @intFromFloat(card_x + 50), @intFromFloat(card_y + 72), 11, rl.Color.init(140, 160, 185, 255));

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
    }
}

fn drawPlacementTooltip(mouse_pos: rl.Vector2, check: PlacementCheck) void {
    const tip_x: i32 = @as(i32, @intFromFloat(mouse_pos.x)) + 20;
    const tip_y: i32 = @as(i32, @intFromFloat(mouse_pos.y)) + 16;

    const text = if (check.valid)
        fmt("[LMB] Place House (Cost: {d} Wood) | [RMB/Esc] Cancel", .{@as(i32, @intFromFloat(HOUSE_WOOD_COST))})
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

fn drawHUD(warm_count: i32, cold_count: i32, cached: CachedSceneUI, camera: rl.Camera3D, mouse_pos: rl.Vector2, placement_check: PlacementCheck) void {
    const screen_w = rl.getScreenWidth();
    const screen_h = rl.getScreenHeight();

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
    const fps_badge_w: i32 = 76;
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

        // Net rate calculation (Coal accounts for generator fuel consumption)
        const net_rate: f32 = if (r == .coal)
            (@as(f32, @floatFromInt(workers)) * r.gatherRate()) - (if (generator_active) GENERATOR_COAL_DRAIN_PER_SEC else 0.0)
        else
            @as(f32, @floatFromInt(workers)) * r.gatherRate();

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
        if (b.state == .completed) {
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

    _ = rl.drawText(
        fmt("Pop: {d}", .{total_citizens}),
        pop_box_x + 8,
        14,
        14,
        rl.Color.init(240, 245, 250, 255),
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
    const fps_text = fmt("{d} FPS", .{fps});
    const fps_tw = rl.measureText(fps_text, 13);
    const actual_fps_w: i32 = @max(fps_badge_w, fps_tw + 18);
    const actual_fps_x: i32 = screen_w - actual_fps_w - 12;

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
        if (fps >= 60) rl.Color.init(70, 215, 115, 200) else if (fps >= 30) rl.Color.init(245, 195, 65, 200) else rl.Color.init(245, 80, 80, 200),
    );
    rl.drawText(
        fps_text,
        actual_fps_x + @divTrunc(actual_fps_w - fps_tw, 2),
        16,
        13,
        if (fps >= 60) rl.Color.init(100, 235, 140, 255) else if (fps >= 30) rl.Color.init(255, 215, 80, 255) else rl.Color.init(255, 100, 100, 255),
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
    // IN-WORLD INTERACTION TIP
    // ------------------------------------------------------------------------
    if (selected_resource == null and !selected_generator and selected_building == null and !build_menu_open and placing_building == null) {
        rl.drawText(
            "TIP: Press [B] or click Build to construct Houses | Click any resource pile or building to inspect",
            18,
            @intFromFloat(@as(f32, @floatFromInt(screen_h)) - 55.0),
            13,
            rl.Color.init(140, 165, 185, 220),
        );
    }

    // ------------------------------------------------------------------------
    // HEAT GENERATOR DIALOG
    // ------------------------------------------------------------------------
    if (selected_generator) {
        const gen_panel_w: f32 = 270.0;
        const gen_panel_h: f32 = 215.0;
        const gen_panel_x: f32 = @as(f32, @floatFromInt(screen_w)) - gen_panel_w - 16.0;
        const gen_panel_y: f32 = top_bar_height + 14.0;

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
            if (generator_active) COLOR_GENERATOR_LIT else rl.Color.init(245, 195, 65, 255),
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

        rl.drawText("Central Thermal Facility", @intFromFloat(gen_panel_x + 14), @intFromFloat(gen_panel_y + 30), 11, rl.Color.init(140, 175, 210, 255));

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
            const coal_workers = workers_assigned[@intFromEnum(Resource.coal)];
            const net_coal = (@as(f32, @floatFromInt(coal_workers)) * COAL_GATHER_RATE_PER_WORKER_PER_SEC) - GENERATOR_COAL_DRAIN_PER_SEC;
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

    // ------------------------------------------------------------------------
    // BUILDING INSPECTION DIALOG
    // ------------------------------------------------------------------------
    drawBuildingDialog(@as(f32, @floatFromInt(screen_w)));

    // ------------------------------------------------------------------------
    // BOTTOM BAR: KEYBINDINGS HINT
    // ------------------------------------------------------------------------
    const bot_h: f32 = 30.0;
    const bot_y = @as(f32, @floatFromInt(screen_h)) - bot_h;
    rl.drawRectangle(0, @intFromFloat(bot_y), screen_w, @intFromFloat(bot_h), rl.Color.init(18, 22, 28, 220));

    rl.drawText(
        "CONTROLS: [B] Build Menu  |  [Click Building/Pile/Generator] Select & Manage  |  [W/A/S/D / RMB Drag] Pan  |  [Wheel] Zoom  |  [ESC] Pause",
        18,
        @intFromFloat(bot_y + 8),
        13,
        rl.Color.init(180, 195, 210, 255),
    );

    // ------------------------------------------------------------------------
    // BUILD BUTTON & BUILD STRIP
    // ------------------------------------------------------------------------
    drawBuildUI(mouse_pos);

    // ------------------------------------------------------------------------
    // PLACEMENT TOOLTIP (When in placement mode)
    // ------------------------------------------------------------------------
    if (placing_building != null) {
        drawPlacementTooltip(mouse_pos, placement_check);
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
    const modal_h: f32 = 230.0;
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
        @intFromFloat(modal_y + 26),
        22,
        rl.Color.init(245, 205, 70, 255),
    );

    // Subtitle
    const subtitle = "City operations are suspended";
    const sub_w = rl.measureText(subtitle, 13);
    rl.drawText(
        subtitle,
        @intFromFloat(modal_x + (modal_w - @as(f32, @floatFromInt(sub_w))) / 2.0),
        @intFromFloat(modal_y + 56),
        13,
        rl.Color.init(160, 175, 190, 255),
    );

    // Separator line
    rl.drawLine(
        @intFromFloat(modal_x + 30),
        @intFromFloat(modal_y + 78),
        @intFromFloat(modal_x + modal_w - 30),
        @intFromFloat(modal_y + 78),
        rl.Color.init(50, 62, 78, 255),
    );

    // Buttons
    const btn_w: f32 = 220.0;
    const btn_h: f32 = 38.0;
    const btn_x: f32 = modal_x + (modal_w - btn_w) / 2.0;

    // Continue Button
    if (rg.button(rl.Rectangle.init(btn_x, modal_y + 98, btn_w, btn_h), "CONTINUE")) {
        is_paused = false;
    }

    // Quit Button
    if (rg.button(rl.Rectangle.init(btn_x, modal_y + 152, btn_w, btn_h), "QUIT GAME")) {
        should_quit = true;
    }
}

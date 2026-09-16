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

// --- Generator (Power Plant) Settings ---
/// Radius around the generator where heat keeps citizens warm (in world units)
pub var GENERATOR_HEAT_RADIUS: f32 = 12.0;
/// Whether the generator starts in the active/turned-on state
pub var GENERATOR_STARTS_ACTIVE: bool = false;
/// Coal consumed per second while the generator is active (set to 0.0 for free heating)
pub var GENERATOR_COAL_DRAIN_PER_SEC: f32 = 0.3;
/// If true, generator will automatically turn off when coal reaches 0. If false, heating is always available.
pub var GENERATOR_REQUIRES_COAL: bool = false;

// --- Initial Resource Stockpiles ---
pub var INITIAL_COAL_STOCKPILE: f32 = 120.0;
pub var INITIAL_WOOD_STOCKPILE: f32 = 100.0;
pub var INITIAL_STEEL_STOCKPILE: f32 = 50.0;
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

pub const Citizen = struct {
    position: rl.Vector3,
    target_pos: rl.Vector3,
    role: CitizenRole,
    is_warm: bool,
    wander_timer: f32,
    speed: f32,
};

pub const SmokeParticle = struct {
    position: rl.Vector3,
    velocity: rl.Vector3,
    alpha: f32,
    size: f32,
    active: bool,
};

// ============================================================================
// GAME STATE
// ============================================================================

var generator_active: bool = false;
var stockpiles: [4]f32 = .{ 0.0, 0.0, 0.0, 0.0 };
var workers_assigned: [4]i32 = .{ 0, 0, 0, 0 }; // workers per Resource enum
var citizens: [256]Citizen = undefined;
var total_citizens: usize = 0;
var smoke_particles: [32]SmokeParticle = undefined;
var smoke_spawn_timer: f32 = 0.0;
var selected_resource: ?Resource = null;

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
    var assigned: i32 = 0;
    for (workers_assigned) |w| {
        assigned += w;
    }
    return @as(i32, @intCast(total_citizens)) - assigned;
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
        // Idle: wander around the central generator
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

    total_citizens = @intCast(@min(STARTING_POPULATION, 256));
    for (0..total_citizens) |i| {
        const angle = randomFloat(0.0, std.math.pi * 2.0);
        const dist = randomFloat(CITIZEN_IDLE_MIN_RADIUS, CITIZEN_IDLE_MAX_RADIUS);
        const initial_pos = rl.Vector3{
            .x = @cos(angle) * dist,
            .y = 0.0,
            .z = @sin(angle) * dist,
        };

        citizens[i] = .{
            .position = initial_pos,
            .target_pos = initial_pos,
            .role = .idle,
            .is_warm = generator_active,
            .wander_timer = randomFloat(1.0, 4.0),
            .speed = CITIZEN_WALK_SPEED * randomFloat(0.85, 1.15),
        };
    }

    for (&smoke_particles) |*p| {
        p.active = false;
    }
}

fn assignWorkers(res: Resource, delta: i32) void {
    const idx = @intFromEnum(res);
    if (delta > 0) {
        const available = getIdleCitizensCount();
        const to_add = @min(delta, available);
        if (to_add <= 0) return;

        var added: i32 = 0;
        for (citizens[0..total_citizens]) |*c| {
            if (c.role == .idle) {
                c.role = CitizenRole.fromResource(res);
                c.target_pos = pickTargetForRole(c.role);
                added += 1;
                if (added >= to_add) break;
            }
        }
        workers_assigned[idx] += added;
    } else if (delta < 0) {
        const to_remove = @min(-delta, workers_assigned[idx]);
        if (to_remove <= 0) return;

        var removed: i32 = 0;
        const target_role = CitizenRole.fromResource(res);
        for (citizens[0..total_citizens]) |*c| {
            if (c.role == target_role) {
                c.role = .idle;
                c.target_pos = pickTargetForRole(c.role);
                removed += 1;
                if (removed >= to_remove) break;
            }
        }
        workers_assigned[idx] -= removed;
    }
}

// ============================================================================
// MAIN APPLICATION
// ============================================================================

pub fn main() !void {
    rl.setConfigFlags(.{
        .vsync_hint = true,
        .window_highdpi = true,
        .window_resizable = true,
    });

    rl.initWindow(1280, 720, "Frostpunk - First Settlement");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    initGame();

    // 3D Camera Setup (Isometric / Top-Down angle)
    var camera = rl.Camera3D{
        .position = CAMERA_DEFAULT_POSITION,
        .target = CAMERA_DEFAULT_TARGET,
        .up = .{ .x = 0.0, .y = 1.0, .z = 0.0 },
        .fovy = 45.0,
        .projection = .perspective,
    };

    while (!rl.windowShouldClose()) {
        const dt = rl.getFrameTime();

        // --------------------------------------------------------------------
        // INPUT & CONTROLS
        // --------------------------------------------------------------------

        // Toggle generator with Space or P
        if (rl.isKeyPressed(.space) or rl.isKeyPressed(.p)) {
            generator_active = !generator_active;
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

        // Camera Drag with Right or Middle Mouse Button
        if (rl.isMouseButtonDown(.right) or rl.isMouseButtonDown(.middle)) {
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

        // Mouse Raycast for 3D Selection (Selecting resource piles or generator)
        const mouse_pos = rl.getMousePosition();
        if (rl.isMouseButtonPressed(.left)) {
            // Only raycast if clicking outside UI panels
            const in_left_panel = mouse_pos.x < 360 and mouse_pos.y > 50 and mouse_pos.y < 350;
            const in_right_panel = mouse_pos.x > @as(f32, @floatFromInt(rl.getScreenWidth())) - 320 and mouse_pos.y > 50 and mouse_pos.y < 280;
            const in_top_bar = mouse_pos.y < 50;

            if (!in_left_panel and !in_right_panel and !in_top_bar) {
                const ray = rl.getScreenToWorldRay(mouse_pos, camera);

                // Check generator click
                const gen_col = rl.getRayCollisionSphere(ray, .{ .x = 0, .y = 3, .z = 0 }, 4.0);
                if (gen_col.hit) {
                    generator_active = !generator_active;
                }

                // Check pile clicks
                var clicked_pile: ?Resource = null;
                inline for (std.meta.tags(Resource)) |r| {
                    const pos = r.position();
                    const hit = rl.getRayCollisionSphere(ray, .{ .x = pos.x, .y = 1.0, .z = pos.z }, 3.5);
                    if (hit.hit) {
                        clicked_pile = r;
                    }
                }
                selected_resource = clicked_pile;
            }
        }

        // --------------------------------------------------------------------
        // SIMULATION UPDATE
        // --------------------------------------------------------------------

        // 1. Coal consumption by generator (if active)
        if (generator_active and GENERATOR_COAL_DRAIN_PER_SEC > 0.0) {
            const coal_idx = @intFromEnum(Resource.coal);
            if (GENERATOR_REQUIRES_COAL) {
                if (stockpiles[coal_idx] > 0.0) {
                    stockpiles[coal_idx] -= GENERATOR_COAL_DRAIN_PER_SEC * dt;
                    if (stockpiles[coal_idx] <= 0.0) {
                        stockpiles[coal_idx] = 0.0;
                        generator_active = false; // Turned off due to lack of fuel
                    }
                } else {
                    generator_active = false;
                }
            } else {
                // Free or soft-drain mode
                stockpiles[coal_idx] = @max(0.0, stockpiles[coal_idx] - GENERATOR_COAL_DRAIN_PER_SEC * dt);
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

        // 3. Update Citizens (movement, wandering, and warmth calculation)
        var warm_count: i32 = 0;
        var cold_count: i32 = 0;

        for (citizens[0..total_citizens]) |*c| {
            // Warmth status
            if (generator_active) {
                const dist_to_gen = rl.Vector3.distance(c.position, .{ .x = 0, .y = 0, .z = 0 });
                if (dist_to_gen <= GENERATOR_HEAT_RADIUS) {
                    c.is_warm = true;
                    warm_count += 1;
                } else {
                    c.is_warm = false;
                    cold_count += 1;
                }
            } else {
                c.is_warm = false;
                cold_count += 1;
            }

            // Movement towards target position
            const diff = c.target_pos.subtract(c.position);
            const dist = diff.length();
            if (dist > 0.25) {
                const dir = diff.scale(1.0 / dist);
                const step = @min(dist, c.speed * dt);
                c.position = c.position.add(dir.scale(step));
            } else {
                c.wander_timer -= dt;
                if (c.wander_timer <= 0.0) {
                    c.wander_timer = randomFloat(2.0, 5.5);
                    c.target_pos = pickTargetForRole(c.role);
                }
            }
        }

        // 4. Update Smoke / Steam Particles
        if (generator_active) {
            smoke_spawn_timer += dt;
            if (smoke_spawn_timer >= 0.12) {
                smoke_spawn_timer = 0.0;
                for (&smoke_particles) |*p| {
                    if (!p.active) {
                        p.active = true;
                        p.position = .{
                            .x = randomFloat(-0.2, 0.2),
                            .y = 11.2,
                            .z = randomFloat(-0.2, 0.2),
                        };
                        p.velocity = .{
                            .x = randomFloat(-0.4, 0.4),
                            .y = randomFloat(2.5, 4.0),
                            .z = randomFloat(-0.4, 0.4),
                        };
                        p.alpha = 0.85;
                        p.size = randomFloat(0.4, 0.7);
                        break;
                    }
                }
            }
        }

        for (&smoke_particles) |*p| {
            if (p.active) {
                p.position = p.position.add(p.velocity.scale(dt));
                p.alpha -= dt * 0.45;
                p.size += dt * 0.5;
                if (p.alpha <= 0.0) {
                    p.active = false;
                }
            }
        }

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

        // Concentric District Rings (evoking Frostpunk's circular city blueprint)
        rl.drawCylinderWires(.{ .x = 0, .y = 0.01, .z = 0 }, 14.0, 14.0, 0.01, 64, COLOR_SNOW_RINGS);
        rl.drawCylinderWires(.{ .x = 0, .y = 0.01, .z = 0 }, 22.0, 22.0, 0.01, 64, COLOR_SNOW_RINGS);
        rl.drawCylinderWires(.{ .x = 0, .y = 0.01, .z = 0 }, 32.0, 32.0, 0.01, 64, COLOR_SNOW_RINGS);
        rl.drawCylinderWires(.{ .x = 0, .y = 0.01, .z = 0 }, 44.0, 44.0, 0.01, 64, COLOR_SNOW_RINGS);

        // Heat Zone on Ground (Visible when Generator is ON)
        if (generator_active) {
            // Warm translucent amber disc
            rl.drawCircle3D(.{ .x = 0, .y = 0.03, .z = 0 }, GENERATOR_HEAT_RADIUS, .{ .x = 1, .y = 0, .z = 0 }, 90.0, COLOR_HEAT_ZONE);
            // Outer glowing heat boundary ring
            rl.drawCylinderWires(.{ .x = 0, .y = 0.05, .z = 0 }, GENERATOR_HEAT_RADIUS, GENERATOR_HEAT_RADIUS, 0.05, 64, COLOR_HEAT_ZONE_RING);
            // Inner intensity ring
            rl.drawCylinderWires(.{ .x = 0, .y = 0.05, .z = 0 }, GENERATOR_HEAT_RADIUS * 0.5, GENERATOR_HEAT_RADIUS * 0.5, 0.04, 48, rl.Color.init(255, 175, 60, 110));
        }

        // Draw The Power Plant (Generator) at (0, 0, 0)
        drawPowerPlant(generator_active);

        // Draw Smoke / Steam Particles
        for (smoke_particles) |p| {
            if (p.active) {
                const smoke_col = rl.Color.init(220, 225, 235, @intFromFloat(std.math.clamp(p.alpha * 255.0, 0.0, 255.0)));
                rl.drawSphere(p.position, p.size, smoke_col);
            }
        }

        // Draw The 4 Infinite Resource Piles
        drawResourcePiles(selected_resource);

        // Draw Citizens (Minimal 3D figures: body rectangle + head sphere)
        for (citizens[0..total_citizens]) |c| {
            const body_color = if (c.is_warm) COLOR_CITIZEN_WARM else COLOR_CITIZEN_COLD;
            const head_color = if (c.is_warm) rl.Color.init(252, 220, 195, 255) else rl.Color.init(180, 208, 230, 255);

            // Citizen body (3D rectangle)
            rl.drawCube(
                .{ .x = c.position.x, .y = c.position.y + 0.45, .z = c.position.z },
                0.48,
                0.9,
                0.48,
                body_color,
            );
            rl.drawCubeWires(
                .{ .x = c.position.x, .y = c.position.y + 0.45, .z = c.position.z },
                0.48,
                0.9,
                0.48,
                rl.Color.init(20, 25, 30, 60),
            );

            // Citizen head (sphere)
            rl.drawSphere(
                .{ .x = c.position.x, .y = c.position.y + 1.05, .z = c.position.z },
                0.24,
                head_color,
            );
        }

        camera.end();

        // 3. 2D HUD & Management UI
        drawHUD(warm_count, cold_count, camera);
    }
}

// ============================================================================
// 3D DRAWING FUNCTIONS
// ============================================================================

fn drawPowerPlant(active: bool) void {
    const vent_color = if (active) COLOR_GENERATOR_LIT else COLOR_GENERATOR_UNLIT;

    // Base Tier 1: Wide octagonal-like base block
    rl.drawCube(.{ .x = 0, .y = 0.5, .z = 0 }, 7.4, 1.0, 7.4, COLOR_GENERATOR_BASE);
    rl.drawCubeWires(.{ .x = 0, .y = 0.5, .z = 0 }, 7.4, 1.0, 7.4, rl.Color.init(20, 22, 26, 255));

    // Base Tier 2: Stepped platform
    rl.drawCube(.{ .x = 0, .y = 1.4, .z = 0 }, 5.8, 0.8, 5.8, rl.Color.init(50, 54, 62, 255));
    rl.drawCubeWires(.{ .x = 0, .y = 1.4, .z = 0 }, 5.8, 0.8, 5.8, rl.Color.init(25, 28, 32, 255));

    // Furnace Core Block (Cubic furnace chamber)
    rl.drawCube(.{ .x = 0, .y = 3.4, .z = 0 }, 4.4, 3.2, 4.4, COLOR_GENERATOR_BASE);
    rl.drawCubeWires(.{ .x = 0, .y = 3.4, .z = 0 }, 4.4, 3.2, 4.4, rl.Color.init(18, 20, 24, 255));

    // 4 Radiant Heat Vents (Glow orange when active)
    rl.drawCube(.{ .x = 0, .y = 3.4, .z = 2.22 }, 2.4, 1.6, 0.15, vent_color);
    rl.drawCube(.{ .x = 0, .y = 3.4, .z = -2.22 }, 2.4, 1.6, 0.15, vent_color);
    rl.drawCube(.{ .x = 2.22, .y = 3.4, .z = 0 }, 0.15, 1.6, 2.4, vent_color);
    rl.drawCube(.{ .x = -2.22, .y = 3.4, .z = 0 }, 0.15, 1.6, 2.4, vent_color);

    // Boiler Drum (Sphere atop the furnace block)
    rl.drawSphere(.{ .x = 0, .y = 5.8, .z = 0 }, 2.3, rl.Color.init(65, 70, 80, 255));
    rl.drawSphereWires(.{ .x = 0, .y = 5.8, .z = 0 }, 2.32, 12, 12, rl.Color.init(28, 30, 36, 180));

    // Chimney Stack (Cylinder)
    rl.drawCylinder(.{ .x = 0, .y = 7.0, .z = 0 }, 1.15, 1.35, 4.2, 16, rl.Color.init(42, 45, 52, 255));
    rl.drawCylinderWires(.{ .x = 0, .y = 7.0, .z = 0 }, 1.15, 1.35, 4.2, 8, rl.Color.init(22, 24, 28, 255));

    // Chimney Rim / Brass Crown
    const crown_color = if (active) rl.Color.init(245, 165, 35, 255) else rl.Color.init(95, 100, 110, 255);
    rl.drawCylinder(.{ .x = 0, .y = 11.1, .z = 0 }, 1.38, 1.38, 0.35, 16, crown_color);
}

fn drawResourcePiles(selected: ?Resource) void {
    // 1. COAL PILE (North-West)
    {
        const pos = COAL_PILE_POSITION;
        // Heap of dark jagged charcoal blocks
        rl.drawCube(.{ .x = pos.x, .y = 1.1, .z = pos.z }, 3.0, 2.2, 3.0, COLOR_COAL_PILE);
        rl.drawCubeWires(.{ .x = pos.x, .y = 1.1, .z = pos.z }, 3.0, 2.2, 3.0, rl.Color.init(10, 10, 14, 255));

        rl.drawCube(.{ .x = pos.x + 1.2, .y = 0.8, .z = pos.z + 0.9 }, 2.2, 1.6, 2.2, rl.Color.init(38, 38, 44, 255));
        rl.drawCube(.{ .x = pos.x - 1.1, .y = 0.7, .z = pos.z - 0.9 }, 2.0, 1.4, 2.0, rl.Color.init(44, 44, 52, 255));
        rl.drawCube(.{ .x = pos.x + 0.8, .y = 0.6, .z = pos.z - 1.1 }, 1.6, 1.2, 1.6, rl.Color.init(32, 32, 38, 255));
        rl.drawCube(.{ .x = pos.x - 0.9, .y = 0.5, .z = pos.z + 1.2 }, 1.5, 1.0, 1.5, rl.Color.init(48, 48, 56, 255));
        rl.drawCube(.{ .x = pos.x + 0.1, .y = 2.4, .z = pos.z }, 1.4, 0.9, 1.4, rl.Color.init(22, 22, 26, 255));

        if (selected == .coal) {
            rl.drawCylinderWires(.{ .x = pos.x, .y = 0.05, .z = pos.z }, 4.0, 4.0, 0.1, 32, rl.Color.gold);
        }
    }

    // 2. WOOD PILE (North-East)
    {
        const pos = WOOD_PILE_POSITION;
        // Stack of timber logs / rectangular wooden beams
        rl.drawCube(.{ .x = pos.x - 1.2, .y = 0.45, .z = pos.z }, 1.0, 0.9, 4.6, COLOR_WOOD_PILE);
        rl.drawCubeWires(.{ .x = pos.x - 1.2, .y = 0.45, .z = pos.z }, 1.0, 0.9, 4.6, rl.Color.init(80, 45, 20, 255));

        rl.drawCube(.{ .x = pos.x, .y = 0.45, .z = pos.z }, 1.0, 0.9, 4.6, COLOR_WOOD_PILE);
        rl.drawCubeWires(.{ .x = pos.x, .y = 0.45, .z = pos.z }, 1.0, 0.9, 4.6, rl.Color.init(80, 45, 20, 255));

        rl.drawCube(.{ .x = pos.x + 1.2, .y = 0.45, .z = pos.z }, 1.0, 0.9, 4.6, COLOR_WOOD_PILE);
        rl.drawCubeWires(.{ .x = pos.x + 1.2, .y = 0.45, .z = pos.z }, 1.0, 0.9, 4.6, rl.Color.init(80, 45, 20, 255));

        rl.drawCube(.{ .x = pos.x - 0.6, .y = 1.3, .z = pos.z }, 1.0, 0.85, 4.4, rl.Color.init(162, 102, 58, 255));
        rl.drawCube(.{ .x = pos.x + 0.6, .y = 1.3, .z = pos.z }, 1.0, 0.85, 4.4, rl.Color.init(162, 102, 58, 255));

        rl.drawCube(.{ .x = pos.x, .y = 2.1, .z = pos.z }, 1.0, 0.8, 4.2, rl.Color.init(178, 115, 68, 255));
        rl.drawCubeWires(.{ .x = pos.x, .y = 2.1, .z = pos.z }, 1.0, 0.8, 4.2, rl.Color.init(90, 55, 25, 255));

        if (selected == .wood) {
            rl.drawCylinderWires(.{ .x = pos.x, .y = 0.05, .z = pos.z }, 4.0, 4.0, 0.1, 32, rl.Color.gold);
        }
    }

    // 3. STEEL PILE (South-West)
    {
        const pos = STEEL_PILE_POSITION;
        // Stack of metallic girders, steel plates, and crates
        rl.drawCube(.{ .x = pos.x, .y = 0.45, .z = pos.z - 1.0 }, 4.8, 0.85, 1.2, COLOR_STEEL_PILE);
        rl.drawCubeWires(.{ .x = pos.x, .y = 0.45, .z = pos.z - 1.0 }, 4.8, 0.85, 1.2, rl.Color.init(80, 95, 110, 255));

        rl.drawCube(.{ .x = pos.x, .y = 0.45, .z = pos.z + 1.0 }, 4.8, 0.85, 1.2, COLOR_STEEL_PILE);
        rl.drawCubeWires(.{ .x = pos.x, .y = 0.45, .z = pos.z + 1.0 }, 4.8, 0.85, 1.2, rl.Color.init(80, 95, 110, 255));

        rl.drawCube(.{ .x = pos.x - 1.3, .y = 1.25, .z = pos.z }, 1.2, 0.75, 4.0, rl.Color.init(168, 185, 205, 255));
        rl.drawCube(.{ .x = pos.x + 1.3, .y = 1.25, .z = pos.z }, 1.2, 0.75, 4.0, rl.Color.init(168, 185, 205, 255));

        rl.drawCube(.{ .x = pos.x, .y = 1.85, .z = pos.z }, 3.2, 0.5, 2.6, rl.Color.init(190, 208, 226, 255));
        rl.drawCubeWires(.{ .x = pos.x, .y = 1.85, .z = pos.z }, 3.2, 0.5, 2.6, rl.Color.init(100, 115, 130, 255));

        rl.drawCube(.{ .x = pos.x + 1.8, .y = 0.65, .z = pos.z + 1.9 }, 1.3, 1.3, 1.3, rl.Color.init(130, 145, 165, 255));

        if (selected == .steel) {
            rl.drawCylinderWires(.{ .x = pos.x, .y = 0.05, .z = pos.z }, 4.0, 4.0, 0.1, 32, rl.Color.gold);
        }
    }

    // 4. FOOD CACHE (South-East)
    {
        const pos = FOOD_PILE_POSITION;
        // Supply crates and ration barrels
        rl.drawCube(.{ .x = pos.x - 0.9, .y = 0.95, .z = pos.z - 0.7 }, 1.9, 1.9, 1.9, COLOR_FOOD_PILE);
        rl.drawCubeWires(.{ .x = pos.x - 0.9, .y = 0.95, .z = pos.z - 0.7 }, 1.9, 1.9, 1.9, rl.Color.init(100, 25, 20, 255));

        rl.drawCube(.{ .x = pos.x + 0.9, .y = 0.85, .z = pos.z + 0.7 }, 1.7, 1.7, 1.7, rl.Color.init(180, 50, 40, 255));
        rl.drawCubeWires(.{ .x = pos.x + 0.9, .y = 0.85, .z = pos.z + 0.7 }, 1.7, 1.7, 1.7, rl.Color.init(90, 20, 18, 255));

        rl.drawCylinder(.{ .x = pos.x + 1.2, .y = 0.0, .z = pos.z - 1.1 }, 0.65, 0.65, 1.6, 12, rl.Color.init(115, 82, 58, 255));
        rl.drawCylinder(.{ .x = pos.x - 1.1, .y = 0.0, .z = pos.z + 1.2 }, 0.65, 0.65, 1.6, 12, rl.Color.init(115, 82, 58, 255));

        rl.drawSphere(.{ .x = pos.x - 0.9, .y = 2.2, .z = pos.z - 0.7 }, 0.55, rl.Color.init(215, 185, 145, 255));

        if (selected == .food) {
            rl.drawCylinderWires(.{ .x = pos.x, .y = 0.05, .z = pos.z }, 4.0, 4.0, 0.1, 32, rl.Color.gold);
        }
    }
}

// ============================================================================
// 2D HUD & UI
// ============================================================================

fn drawWorldLabels(camera: rl.Camera3D) void {
    const sw = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const sh = @as(f32, @floatFromInt(rl.getScreenHeight()));

    // 1. Generator floating label
    const gen_screen = rl.getWorldToScreen(.{ .x = 0.0, .y = 12.0, .z = 0.0 }, camera);
    if (gen_screen.x > 30 and gen_screen.x < sw - 30 and gen_screen.y > 45 and gen_screen.y < sh - 35) {
        const text = if (generator_active) "POWER PLANT [ONLINE]" else "POWER PLANT [OFFLINE]";
        const tw = rl.measureText(text, 11);
        const bx = @as(i32, @intFromFloat(gen_screen.x)) - @divTrunc(tw, 2);
        const by = @as(i32, @intFromFloat(gen_screen.y));

        rl.drawRectangle(bx - 6, by - 3, tw + 12, 18, rl.Color.init(18, 22, 28, 215));
        rl.drawRectangleLines(bx - 6, by - 3, tw + 12, 18, if (generator_active) COLOR_GENERATOR_LIT else rl.Color.init(70, 75, 85, 255));
        rl.drawText(text, bx, by, 11, if (generator_active) rl.Color.init(255, 205, 60, 255) else rl.Color.init(180, 185, 195, 255));
    }

    // 2. Resource Piles floating labels
    inline for (std.meta.tags(Resource)) |r| {
        const p = r.position();
        const screen_pos = rl.getWorldToScreen(.{ .x = p.x, .y = 3.6, .z = p.z }, camera);
        if (screen_pos.x > 30 and screen_pos.x < sw - 30 and screen_pos.y > 45 and screen_pos.y < sh - 35) {
            const assigned = workers_assigned[@intFromEnum(r)];
            const text = fmt("{s} Pile ({d} workers)", .{ r.name(), assigned });
            const tw = rl.measureText(text, 11);
            const bx = @as(i32, @intFromFloat(screen_pos.x)) - @divTrunc(tw, 2);
            const by = @as(i32, @intFromFloat(screen_pos.y));

            rl.drawRectangle(bx - 6, by - 3, tw + 12, 18, rl.Color.init(18, 22, 28, 215));
            rl.drawRectangleLines(bx - 6, by - 3, tw + 12, 18, r.color());
            rl.drawText(text, bx, by, 11, rl.Color.white);
        }
    }
}

fn drawHUD(warm_count: i32, cold_count: i32, camera: rl.Camera3D) void {
    const screen_w = rl.getScreenWidth();
    const screen_h = rl.getScreenHeight();
    const idle_count = getIdleCitizensCount();

    // ------------------------------------------------------------------------
    // 3D FLOATING WORLD LABELS
    // ------------------------------------------------------------------------
    drawWorldLabels(camera);

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
    const pop_box_w: i32 = 280;
    const pop_box_x: i32 = screen_w - pop_box_w;

    const available_res_w: i32 = @max(340, pop_box_x - res_start_x - 20);
    const col_w: i32 = @min(105, @divTrunc(available_res_w, 4));

    var cur_x: i32 = res_start_x;

    inline for (std.meta.tags(Resource)) |r| {
        const idx = @intFromEnum(r);
        const amount = stockpiles[idx];
        const workers = workers_assigned[idx];
        const rate = @as(f32, @floatFromInt(workers)) * r.gatherRate();

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
        const rate_color = if (workers > 0) rl.Color.init(120, 230, 140, 255) else rl.Color.init(140, 145, 155, 255);
        _ = rl.drawText(
            fmt("+{d:.1}/s", .{rate}),
            cur_x + 14,
            27,
            11,
            rate_color,
        );

        cur_x += col_w;
    }

    // Population & Warmth Overview (Top-Right, right-aligned)
    _ = rl.drawText(
        fmt("Pop: {d}", .{total_citizens}),
        pop_box_x + 10,
        14,
        15,
        rl.Color.init(240, 245, 250, 255),
    );

    // Warm tag
    _ = rl.drawText(
        fmt("Warm: {d}", .{warm_count}),
        pop_box_x + 95,
        14,
        15,
        COLOR_CITIZEN_WARM,
    );

    // Cold tag
    _ = rl.drawText(
        fmt("Cold: {d}", .{cold_count}),
        pop_box_x + 185,
        14,
        15,
        rl.Color.init(110, 185, 255, 255),
    );

    // ------------------------------------------------------------------------
    // LEFT PANEL: WORKFORCE ASSIGNMENT
    // ------------------------------------------------------------------------
    const panel_x: f32 = 16.0;
    const panel_y: f32 = top_bar_height + 14.0;
    const panel_w: f32 = 300.0;
    const panel_h: f32 = 250.0;

    // Panel background & border
    rl.drawRectangleRounded(
        rl.Rectangle.init(panel_x, panel_y, panel_w, panel_h),
        0.04,
        8,
        rl.Color.init(22, 26, 32, 225),
    );
    rl.drawRectangleRoundedLinesEx(
        rl.Rectangle.init(panel_x, panel_y, panel_w, panel_h),
        0.04,
        8,
        1.5,
        rl.Color.init(55, 65, 78, 255),
    );

    // Panel Header
    rl.drawText("WORKFORCE ALLOCATION", @intFromFloat(panel_x + 14), @intFromFloat(panel_y + 12), 16, rl.Color.init(240, 245, 250, 255));
    _ = rl.drawText(
        fmt("Idle Citizens: {d} / {d}", .{ idle_count, total_citizens }),
        @intFromFloat(panel_x + 14),
        @intFromFloat(panel_y + 32),
        13,
        if (idle_count > 0) rl.Color.init(120, 220, 150, 255) else rl.Color.init(240, 160, 160, 255),
    );

    // Separator line
    rl.drawLine(
        @intFromFloat(panel_x + 14),
        @intFromFloat(panel_y + 52),
        @intFromFloat(panel_x + panel_w - 14),
        @intFromFloat(panel_y + 52),
        rl.Color.init(50, 58, 70, 255),
    );

    // Resource worker rows
    var row_y = panel_y + 60.0;
    inline for (std.meta.tags(Resource)) |r| {
        const idx = @intFromEnum(r);
        const assigned = workers_assigned[idx];

        // Selection highlight if clicked in 3D
        if (selected_resource == r) {
            rl.drawRectangleRounded(
                rl.Rectangle.init(panel_x + 8, row_y - 3, panel_w - 16, 28),
                0.15,
                4,
                rl.Color.init(255, 200, 50, 35),
            );
        }

        // Color badge & label
        rl.drawRectangle(@intFromFloat(panel_x + 14), @intFromFloat(row_y + 3), 10, 16, r.color());
        _ = rl.drawText(
            fmt("{s}: {d}", .{ r.name(), assigned }),
            @intFromFloat(panel_x + 30),
            @intFromFloat(row_y + 3),
            15,
            rl.Color.white,
        );

        // Reallocation Buttons: [-5] [-1] [+1] [+5]
        const btn_y = row_y - 1;
        const btn_h = 24;

        if (rg.button(rl.Rectangle.init(panel_x + 112, btn_y, 30, btn_h), "-5")) {
            assignWorkers(r, -5);
        }
        if (rg.button(rl.Rectangle.init(panel_x + 145, btn_y, 26, btn_h), "-1")) {
            assignWorkers(r, -1);
        }
        if (rg.button(rl.Rectangle.init(panel_x + 174, btn_y, 26, btn_h), "+1")) {
            assignWorkers(r, 1);
        }
        if (rg.button(rl.Rectangle.init(panel_x + 203, btn_y, 30, btn_h), "+5")) {
            assignWorkers(r, 5);
        }

        // Quick rate display
        _ = rl.drawText(
            fmt("+{d:.1}", .{@as(f32, @floatFromInt(assigned)) * r.gatherRate()}),
            @intFromFloat(panel_x + 242),
            @intFromFloat(row_y + 5),
            12,
            rl.Color.init(160, 210, 160, 255),
        );

        row_y += 44.0;
    }

    // ------------------------------------------------------------------------
    // RIGHT PANEL: POWER PLANT (GENERATOR) CONTROL
    // ------------------------------------------------------------------------
    const gen_panel_w: f32 = 260.0;
    const gen_panel_h: f32 = 185.0;
    const gen_panel_x: f32 = @as(f32, @floatFromInt(screen_w)) - gen_panel_w - 16.0;
    const gen_panel_y: f32 = top_bar_height + 14.0;

    rl.drawRectangleRounded(
        rl.Rectangle.init(gen_panel_x, gen_panel_y, gen_panel_w, gen_panel_h),
        0.04,
        8,
        rl.Color.init(22, 26, 32, 230),
    );
    rl.drawRectangleRoundedLinesEx(
        rl.Rectangle.init(gen_panel_x, gen_panel_y, gen_panel_w, gen_panel_h),
        0.04,
        8,
        1.5,
        if (generator_active) COLOR_GENERATOR_LIT else rl.Color.init(55, 65, 78, 255),
    );

    // Generator Header
    rl.drawText("THE POWER PLANT", @intFromFloat(gen_panel_x + 14), @intFromFloat(gen_panel_y + 12), 16, rl.Color.init(240, 245, 250, 255));

    // Status Indicator
    if (generator_active) {
        rl.drawRectangle(@intFromFloat(gen_panel_x + 14), @intFromFloat(gen_panel_y + 34), 10, 10, COLOR_GENERATOR_LIT);
        rl.drawText("ONLINE - HEATING ACTIVE", @intFromFloat(gen_panel_x + 30), @intFromFloat(gen_panel_y + 32), 13, COLOR_GENERATOR_LIT);
    } else {
        rl.drawRectangle(@intFromFloat(gen_panel_x + 14), @intFromFloat(gen_panel_y + 34), 10, 10, rl.Color.init(120, 125, 135, 255));
        rl.drawText("OFFLINE - COLD", @intFromFloat(gen_panel_x + 30), @intFromFloat(gen_panel_y + 32), 13, rl.Color.init(150, 160, 170, 255));
    }

    // Toggle Button
    const btn_label = if (generator_active) "TURN GENERATOR OFF" else "TURN GENERATOR ON";
    if (rg.button(rl.Rectangle.init(gen_panel_x + 14, gen_panel_y + 56, gen_panel_w - 28, 36), btn_label)) {
        generator_active = !generator_active;
    }

    // Generator details
    _ = rl.drawText(
        fmt("Heat Radius: {d:.1} m", .{GENERATOR_HEAT_RADIUS}),
        @intFromFloat(gen_panel_x + 14),
        @intFromFloat(gen_panel_y + 102),
        13,
        rl.Color.init(210, 215, 225, 255),
    );

    _ = rl.drawText(
        fmt("Citizens Protected: {d} / {d}", .{ warm_count, total_citizens }),
        @intFromFloat(gen_panel_x + 14),
        @intFromFloat(gen_panel_y + 122),
        13,
        if (generator_active) COLOR_CITIZEN_WARM else rl.Color.init(140, 150, 165, 255),
    );

    const coal_mode_str: [:0]const u8 = if (GENERATOR_REQUIRES_COAL)
        fmt("Coal Drain: {d:.1} / sec", .{GENERATOR_COAL_DRAIN_PER_SEC})
    else
        "Coal Drain: FREE (Infinite fuel)";
    _ = rl.drawText(
        coal_mode_str,
        @intFromFloat(gen_panel_x + 14),
        @intFromFloat(gen_panel_y + 142),
        12,
        rl.Color.init(150, 180, 210, 255),
    );

    // ------------------------------------------------------------------------
    // BOTTOM BAR: KEYBINDINGS HINT
    // ------------------------------------------------------------------------
    const bot_h: f32 = 30.0;
    const bot_y = @as(f32, @floatFromInt(screen_h)) - bot_h;
    rl.drawRectangle(0, @intFromFloat(bot_y), screen_w, @intFromFloat(bot_h), rl.Color.init(18, 22, 28, 220));

    rl.drawText(
        "CONTROLS: [W/A/S/D / Arrows] Pan Camera  |  [Mouse Wheel] Zoom  |  [Right Click Drag] Pan  |  [Space / P] Toggle Plant  |  [R] Reset View",
        18,
        @intFromFloat(bot_y + 8),
        13,
        rl.Color.init(180, 195, 210, 255),
    );
}

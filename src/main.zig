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
/// Coal consumed per second while the generator is active
pub var GENERATOR_COAL_DRAIN_PER_SEC: f32 = 0.5;
/// Generator requires coal fuel to operate. When fuel reaches 0, it shuts down.
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

// --- In-World Interaction & Screen Hit Settings ---
/// Screen-space pixel hit radius around pile base to register clicks and hovers
pub var PILE_SCREEN_HIT_RADIUS_PX: f32 = 65.0;
/// In-world vertical height offset where the floating badge/card is anchored above the pile
pub var PILE_LABEL_HEIGHT_OFFSET: f32 = 3.8;

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
var hovered_resource: ?Resource = null;

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

fn getPileUIBounds(r: Resource, camera: rl.Camera3D) PileUIBounds {
    const sw = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const sh = @as(f32, @floatFromInt(rl.getScreenHeight()));
    const p = r.position();

    // Pile base on the snow ground (projected to screen)
    const base_screen = rl.getWorldToScreen(.{ .x = p.x, .y = 0.5, .z = p.z }, camera);

    // Floating badge position above the pile
    const badge_screen = rl.getWorldToScreen(.{ .x = p.x, .y = PILE_LABEL_HEIGHT_OFFSET, .z = p.z }, camera);

    // Is the badge in front of the camera and within the screen viewport margin?
    const on_screen = badge_screen.x >= -120 and badge_screen.x <= sw + 120 and
        badge_screen.y >= -120 and badge_screen.y <= sh + 120;

    // Badge dimensions
    const badge_w: f32 = 175.0;
    const badge_h: f32 = 28.0;
    const badge_rect = rl.Rectangle.init(
        badge_screen.x - badge_w / 2.0,
        badge_screen.y - badge_h / 2.0,
        badge_w,
        badge_h,
    );

    // If this pile is selected, compute its on-pile worker management card rectangle
    var card_rect: ?rl.Rectangle = null;
    if (selected_resource == r) {
        const card_w: f32 = 250.0;
        const card_h: f32 = 175.0;
        var cx = badge_screen.x - card_w / 2.0;
        var cy = badge_screen.y - card_h - 14.0;

        // If card would clip against the top status bar (y < 52), place below pile badge instead
        if (cy < 52.0) {
            cy = badge_screen.y + 22.0;
        }

        // Clamp to stay inside visible viewport
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

fn isMouseOverPileTarget(r: Resource, mouse_pos: rl.Vector2, camera: rl.Camera3D, ray: rl.Ray) bool {
    const ui = getPileUIBounds(r, camera);
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

    // Disable default ESC behavior so we can use it for our Pause Menu
    rl.setExitKey(.null);

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

    while (!rl.windowShouldClose() and !should_quit) {
        const dt = rl.getFrameTime();

        // --------------------------------------------------------------------
        // PAUSE MENU TOGGLE (ESC Key)
        // --------------------------------------------------------------------
        if (rl.isKeyPressed(.escape)) {
            is_paused = !is_paused;
        }

        // --------------------------------------------------------------------
        // GAMEPLAY INPUT & SIMULATION (Only when NOT paused)
        // --------------------------------------------------------------------
        if (!is_paused) {
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
            const mouse_pos = rl.getMousePosition();
            const sw_f = @as(f32, @floatFromInt(rl.getScreenWidth()));
            const sh_f = @as(f32, @floatFromInt(rl.getScreenHeight()));

            const in_top_bar = mouse_pos.y < 48.0;
            const in_right_panel = mouse_pos.x > sw_f - 280.0 and mouse_pos.y > 48.0 and mouse_pos.y < 265.0;
            const in_bottom_bar = mouse_pos.y > sh_f - 32.0;

            // Check if mouse is inside the on-pile management card of the active pile
            var in_active_card: bool = false;
            if (selected_resource) |sel| {
                const sel_ui = getPileUIBounds(sel, camera);
                if (sel_ui.card_rect) |cr| {
                    if (rl.checkCollisionPointRec(mouse_pos, cr)) {
                        in_active_card = true;
                    }
                }
            }

            const ray = rl.getScreenToWorldRay(mouse_pos, camera);

            // Detect hover over resource piles
            hovered_resource = null;
            if (!in_top_bar and !in_right_panel and !in_bottom_bar and !in_active_card) {
                inline for (std.meta.tags(Resource)) |r| {
                    if (isMouseOverPileTarget(r, mouse_pos, camera, ray)) {
                        hovered_resource = r;
                    }
                }
            }

            // Handle Left Mouse Click (Pile Selection & Generator Interaction)
            if (rl.isMouseButtonPressed(.left)) {
                // If clicked inside the active card, top bar, right panel, or bottom bar:
                // Let the respective UI controls handle the click - do NOT alter selection!
                if (!in_top_bar and !in_right_panel and !in_bottom_bar and !in_active_card) {
                    var clicked_pile: ?Resource = null;
                    inline for (std.meta.tags(Resource)) |r| {
                        if (isMouseOverPileTarget(r, mouse_pos, camera, ray)) {
                            clicked_pile = r;
                        }
                    }

                    if (clicked_pile) |p| {
                        selected_resource = p;
                    } else {
                        // Check if generator clicked in 3D or its floating label
                        const gen_screen = rl.getWorldToScreen(.{ .x = 0.0, .y = 3.5, .z = 0.0 }, camera);
                        const gen_label_screen = rl.getWorldToScreen(.{ .x = 0.0, .y = 12.0, .z = 0.0 }, camera);
                        const dist_gen = rl.Vector2.distance(mouse_pos, gen_screen);
                        const dist_gen_label = rl.Vector2.distance(mouse_pos, gen_label_screen);
                        const gen_hit = rl.getRayCollisionSphere(ray, .{ .x = 0, .y = 3.5, .z = 0 }, 5.5);

                        if (dist_gen < 65.0 or dist_gen_label < 60.0 or gen_hit.hit) {
                            tryToggleGenerator();
                        } else {
                            // Clicked empty ground: deselect pile
                            selected_resource = null;
                        }
                    }
                }
            }

            // Set cursor style
            if (hovered_resource != null) {
                rl.setMouseCursor(.pointing_hand);
            } else {
                rl.setMouseCursor(.default);
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

            // 3. Citizens movement, wandering, and warmth calculation
            for (citizens[0..total_citizens]) |*c| {
                // Warmth calculation
                if (generator_active) {
                    const dist_to_gen = rl.Vector3.distance(c.position, .{ .x = 0, .y = 0, .z = 0 });
                    c.is_warm = (dist_to_gen <= GENERATOR_HEAT_RADIUS);
                } else {
                    c.is_warm = false;
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

            // 4. Generator smoke/steam particles
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
        }

        // Compute warm and cold citizens count for rendering
        var warm_count: i32 = 0;
        var cold_count: i32 = 0;
        for (citizens[0..total_citizens]) |c| {
            if (c.is_warm) warm_count += 1 else cold_count += 1;
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

        // Concentric District Rings (Frostpunk circular blueprint)
        rl.drawCylinderWires(.{ .x = 0, .y = 0.01, .z = 0 }, 12.0, 12.0, 0.01, 64, COLOR_SNOW_RINGS);
        rl.drawCylinderWires(.{ .x = 0, .y = 0.01, .z = 0 }, 20.0, 20.0, 0.01, 64, COLOR_SNOW_RINGS);
        rl.drawCylinderWires(.{ .x = 0, .y = 0.01, .z = 0 }, 30.0, 30.0, 0.01, 64, COLOR_SNOW_RINGS);
        rl.drawCylinderWires(.{ .x = 0, .y = 0.01, .z = 0 }, 42.0, 42.0, 0.01, 64, COLOR_SNOW_RINGS);

        // Heat Zone on Ground (Visible when Generator is ON)
        if (generator_active) {
            rl.drawCircle3D(.{ .x = 0, .y = 0.03, .z = 0 }, GENERATOR_HEAT_RADIUS, .{ .x = 1, .y = 0, .z = 0 }, 90.0, COLOR_HEAT_ZONE);
            rl.drawCylinderWires(.{ .x = 0, .y = 0.05, .z = 0 }, GENERATOR_HEAT_RADIUS, GENERATOR_HEAT_RADIUS, 0.05, 64, COLOR_HEAT_ZONE_RING);
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
        drawResourcePiles(selected_resource, hovered_resource);

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

        // 3. 2D HUD & Interactive Management UI
        drawHUD(warm_count, cold_count, camera);

        // 4. Pause Menu Modal Overlay (if paused)
        if (is_paused) {
            drawPauseMenu();
        }
    }
}

// ============================================================================
// 3D DRAWING FUNCTIONS
// ============================================================================

fn drawPowerPlant(active: bool) void {
    const vent_color = if (active) COLOR_GENERATOR_LIT else COLOR_GENERATOR_UNLIT;

    // Base Tier 1: Wide base block
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

    // Boiler Drum (Sphere atop furnace block)
    rl.drawSphere(.{ .x = 0, .y = 5.8, .z = 0 }, 2.3, rl.Color.init(65, 70, 80, 255));
    rl.drawSphereWires(.{ .x = 0, .y = 5.8, .z = 0 }, 2.32, 12, 12, rl.Color.init(28, 30, 36, 180));

    // Chimney Stack (Cylinder)
    rl.drawCylinder(.{ .x = 0, .y = 7.0, .z = 0 }, 1.15, 1.35, 4.2, 16, rl.Color.init(42, 45, 52, 255));
    rl.drawCylinderWires(.{ .x = 0, .y = 7.0, .z = 0 }, 1.15, 1.35, 4.2, 8, rl.Color.init(22, 24, 28, 255));

    // Chimney Rim / Brass Crown
    const crown_color = if (active) rl.Color.init(245, 165, 35, 255) else rl.Color.init(95, 100, 110, 255);
    rl.drawCylinder(.{ .x = 0, .y = 11.1, .z = 0 }, 1.38, 1.38, 0.35, 16, crown_color);
}

fn drawResourcePiles(selected: ?Resource, hovered: ?Resource) void {
    // 1. COAL PILE
    {
        const pos = COAL_PILE_POSITION;
        rl.drawCube(.{ .x = pos.x, .y = 1.1, .z = pos.z }, 3.0, 2.2, 3.0, COLOR_COAL_PILE);
        rl.drawCubeWires(.{ .x = pos.x, .y = 1.1, .z = pos.z }, 3.0, 2.2, 3.0, rl.Color.init(10, 10, 14, 255));

        rl.drawCube(.{ .x = pos.x + 1.2, .y = 0.8, .z = pos.z + 0.9 }, 2.2, 1.6, 2.2, rl.Color.init(38, 38, 44, 255));
        rl.drawCube(.{ .x = pos.x - 1.1, .y = 0.7, .z = pos.z - 0.9 }, 2.0, 1.4, 2.0, rl.Color.init(44, 44, 52, 255));
        rl.drawCube(.{ .x = pos.x + 0.8, .y = 0.6, .z = pos.z - 1.1 }, 1.6, 1.2, 1.6, rl.Color.init(32, 32, 38, 255));
        rl.drawCube(.{ .x = pos.x - 0.9, .y = 0.5, .z = pos.z + 1.2 }, 1.5, 1.0, 1.5, rl.Color.init(48, 48, 56, 255));
        rl.drawCube(.{ .x = pos.x + 0.1, .y = 2.4, .z = pos.z }, 1.4, 0.9, 1.4, rl.Color.init(22, 22, 26, 255));

        if (selected == .coal) {
            rl.drawCircle3D(.{ .x = pos.x, .y = 0.03, .z = pos.z }, 4.4, .{ .x = 1, .y = 0, .z = 0 }, 90.0, rl.Color.init(255, 205, 50, 50));
            rl.drawCylinderWires(.{ .x = pos.x, .y = 0.05, .z = pos.z }, 4.4, 4.4, 0.12, 32, rl.Color.gold);
        } else if (hovered == .coal) {
            rl.drawCircle3D(.{ .x = pos.x, .y = 0.03, .z = pos.z }, 4.4, .{ .x = 1, .y = 0, .z = 0 }, 90.0, rl.Color.init(180, 220, 255, 40));
            rl.drawCylinderWires(.{ .x = pos.x, .y = 0.05, .z = pos.z }, 4.4, 4.4, 0.08, 32, rl.Color.init(200, 220, 255, 180));
        }
    }

    // 2. WOOD PILE
    {
        const pos = WOOD_PILE_POSITION;
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
            rl.drawCircle3D(.{ .x = pos.x, .y = 0.03, .z = pos.z }, 4.4, .{ .x = 1, .y = 0, .z = 0 }, 90.0, rl.Color.init(255, 205, 50, 50));
            rl.drawCylinderWires(.{ .x = pos.x, .y = 0.05, .z = pos.z }, 4.4, 4.4, 0.12, 32, rl.Color.gold);
        } else if (hovered == .wood) {
            rl.drawCircle3D(.{ .x = pos.x, .y = 0.03, .z = pos.z }, 4.4, .{ .x = 1, .y = 0, .z = 0 }, 90.0, rl.Color.init(180, 220, 255, 40));
            rl.drawCylinderWires(.{ .x = pos.x, .y = 0.05, .z = pos.z }, 4.4, 4.4, 0.08, 32, rl.Color.init(200, 220, 255, 180));
        }
    }

    // 3. STEEL PILE
    {
        const pos = STEEL_PILE_POSITION;
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
            rl.drawCircle3D(.{ .x = pos.x, .y = 0.03, .z = pos.z }, 4.4, .{ .x = 1, .y = 0, .z = 0 }, 90.0, rl.Color.init(255, 205, 50, 50));
            rl.drawCylinderWires(.{ .x = pos.x, .y = 0.05, .z = pos.z }, 4.4, 4.4, 0.12, 32, rl.Color.gold);
        } else if (hovered == .steel) {
            rl.drawCircle3D(.{ .x = pos.x, .y = 0.03, .z = pos.z }, 4.4, .{ .x = 1, .y = 0, .z = 0 }, 90.0, rl.Color.init(180, 220, 255, 40));
            rl.drawCylinderWires(.{ .x = pos.x, .y = 0.05, .z = pos.z }, 4.4, 4.4, 0.08, 32, rl.Color.init(200, 220, 255, 180));
        }
    }

    // 4. FOOD CACHE
    {
        const pos = FOOD_PILE_POSITION;
        rl.drawCube(.{ .x = pos.x - 0.9, .y = 0.95, .z = pos.z - 0.7 }, 1.9, 1.9, 1.9, COLOR_FOOD_PILE);
        rl.drawCubeWires(.{ .x = pos.x - 0.9, .y = 0.95, .z = pos.z - 0.7 }, 1.9, 1.9, 1.9, rl.Color.init(100, 25, 20, 255));

        rl.drawCube(.{ .x = pos.x + 0.9, .y = 0.85, .z = pos.z + 0.7 }, 1.7, 1.7, 1.7, rl.Color.init(180, 50, 40, 255));
        rl.drawCubeWires(.{ .x = pos.x + 0.9, .y = 0.85, .z = pos.z + 0.7 }, 1.7, 1.7, 1.7, rl.Color.init(90, 20, 18, 255));

        rl.drawCylinder(.{ .x = pos.x + 1.2, .y = 0.0, .z = pos.z - 1.1 }, 0.65, 0.65, 1.6, 12, rl.Color.init(115, 82, 58, 255));
        rl.drawCylinder(.{ .x = pos.x - 1.1, .y = 0.0, .z = pos.z + 1.2 }, 0.65, 0.65, 1.6, 12, rl.Color.init(115, 82, 58, 255));

        rl.drawSphere(.{ .x = pos.x - 0.9, .y = 2.2, .z = pos.z - 0.7 }, 0.55, rl.Color.init(215, 185, 145, 255));

        if (selected == .food) {
            rl.drawCircle3D(.{ .x = pos.x, .y = 0.03, .z = pos.z }, 4.4, .{ .x = 1, .y = 0, .z = 0 }, 90.0, rl.Color.init(255, 205, 50, 50));
            rl.drawCylinderWires(.{ .x = pos.x, .y = 0.05, .z = pos.z }, 4.4, 4.4, 0.12, 32, rl.Color.gold);
        } else if (hovered == .food) {
            rl.drawCircle3D(.{ .x = pos.x, .y = 0.03, .z = pos.z }, 4.4, .{ .x = 1, .y = 0, .z = 0 }, 90.0, rl.Color.init(180, 220, 255, 40));
            rl.drawCylinderWires(.{ .x = pos.x, .y = 0.05, .z = pos.z }, 4.4, 4.4, 0.08, 32, rl.Color.init(200, 220, 255, 180));
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

    // 2. Resource Piles floating badges & On-Pile Worker Assignment Stations
    inline for (std.meta.tags(Resource)) |r| {
        const ui = getPileUIBounds(r, camera);
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

fn drawHUD(warm_count: i32, cold_count: i32, camera: rl.Camera3D) void {
    const screen_w = rl.getScreenWidth();
    const screen_h = rl.getScreenHeight();

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

        // Gathering rate text (Red if coal is draining, green if positive, gray if zero)
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
    // FUEL WARNING BANNER (If out of coal or cannot ignite)
    // ------------------------------------------------------------------------
    if (fuel_warning_timer > 0.0) {
        const banner_h: f32 = 26.0;
        const banner_y: f32 = top_bar_height;
        rl.drawRectangle(0, @intFromFloat(banner_y), screen_w, @intFromFloat(banner_h), rl.Color.init(190, 30, 30, 235));
        const warn_msg = "WARNING: Insufficient Coal! The Generator needs coal to operate. Click the Coal Pile to assign workers.";
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
    // IN-WORLD WORKER MANAGEMENT TIP (When no pile is selected)
    // ------------------------------------------------------------------------
    if (selected_resource == null) {
        rl.drawText(
            "TIP: Click any resource pile in the map to assign or remove workers directly on site",
            18,
            @intFromFloat(@as(f32, @floatFromInt(screen_h)) - 55.0),
            13,
            rl.Color.init(140, 165, 185, 220),
        );
    }

    // ------------------------------------------------------------------------
    // RIGHT PANEL: POWER PLANT (GENERATOR) CONTROL & COAL STATUS
    // ------------------------------------------------------------------------
    const gen_panel_w: f32 = 260.0;
    const gen_panel_h: f32 = 200.0;
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
    const coal_amount = stockpiles[@intFromEnum(Resource.coal)];
    const btn_label = if (generator_active)
        "TURN GENERATOR OFF"
    else if (coal_amount > 0.0)
        "TURN GENERATOR ON"
    else
        "IGNITE (NO COAL!)";

    if (rg.button(rl.Rectangle.init(gen_panel_x + 14, gen_panel_y + 56, gen_panel_w - 28, 36), btn_label)) {
        tryToggleGenerator();
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

    // Coal fuel status and burn time
    _ = rl.drawText(
        fmt("Coal Reserve: {d} coal", .{@as(i32, @intFromFloat(coal_amount))}),
        @intFromFloat(gen_panel_x + 14),
        @intFromFloat(gen_panel_y + 142),
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
                @intFromFloat(gen_panel_y + 162),
                12,
                rl.Color.init(255, 175, 70, 255),
            );
        } else {
            _ = rl.drawText(
                "Fuel Sustainable (Surplus)",
                @intFromFloat(gen_panel_x + 14),
                @intFromFloat(gen_panel_y + 162),
                12,
                rl.Color.init(120, 230, 140, 255),
            );
        }
    } else {
        _ = rl.drawText(
            fmt("Burn Rate: {d:.1} coal/sec", .{GENERATOR_COAL_DRAIN_PER_SEC}),
            @intFromFloat(gen_panel_x + 14),
            @intFromFloat(gen_panel_y + 162),
            12,
            rl.Color.init(150, 170, 190, 255),
        );
    }

    // ------------------------------------------------------------------------
    // BOTTOM BAR: KEYBINDINGS HINT
    // ------------------------------------------------------------------------
    const bot_h: f32 = 30.0;
    const bot_y = @as(f32, @floatFromInt(screen_h)) - bot_h;
    rl.drawRectangle(0, @intFromFloat(bot_y), screen_w, @intFromFloat(bot_h), rl.Color.init(18, 22, 28, 220));

    rl.drawText(
        "CONTROLS: [Click Pile] Manage Workers On-Site (+/-)  |  [W/A/S/D / Arrows / RMB Drag] Pan  |  [Wheel] Zoom  |  [Space / P] Toggle Plant  |  [ESC] Pause Menu",
        18,
        @intFromFloat(bot_y + 8),
        13,
        rl.Color.init(180, 195, 210, 255),
    );
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

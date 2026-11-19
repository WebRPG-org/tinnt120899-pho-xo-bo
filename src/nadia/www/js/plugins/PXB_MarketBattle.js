/*:
 * @plugindesc Phố Xô Bồ — Bụi Đời Chợ Cá: mode chiến thuật vui 3v3/5v5 theo lượt trên lưới isometric, vũ khí hài, giữ sạp chợ 1 tuần (GDD Mục 11; luật chi tiết CHƯA CHỐT — xem docs/market-battle-design.md).
 * @author Muse Center
 *
 * @help
 * Port GDD Mục 11 (Bụi Đời Chợ Cá) + docs/architecture-nadia.md §4.6
 * (plugin số 14, Phase 2, "luật chưa chốt") thành LOGIC LÕI THUẦN.
 *
 * - Mode chiến thuật vui 3v3/5v5 theo lượt trên lưới isometric, ~3 phút,
 *   vũ khí hài (chảo, cá khô, ghế nhựa, loa), vai theo màu chỉ số
 *   (Đỏ tank, Xanh chiến thuật, Vàng hỗ trợ, Tím chính xác, Cam burst,
 *   Lục mẹo), đội thắng giữ sạp chợ 1 tuần (giảm giá sỉ, thuế sạp,
 *   Danh vọng). Gắn công ty / hợp tác xã và xung đột danh hiệu
 *   (Tướng Cướp buff ở chợ, Cảnh sát buff khi giữ sạp). Không máu me,
 *   không chết, không mất đồ vĩnh viễn (GDD Mục 11 + Mục 12).
 * - Đây CHỈ là logic lõi: tạo trận, xếp vai, lượt đi, đánh/hỗ trợ,
 *   thắng/thua/hòa, giữ sạp, buff danh hiệu, chặn trận thiếu người.
 *   KHÔNG có scene / UI / bản đồ trận MV ở đây — scene riêng
 *   (Scene_MarketBattle, vẽ lưới isometric qua PXB_Isometric) và map
 *   (Troops/Enemies làm khung đối thủ) là việc sau, theo
 *   architecture-nadia.md §4.6. Không giả vờ đã có UI.
 * - Trận đấu sống trong biến module (không vào save — như battle MV);
 *   quyền GIỮ SẠP + lịch sử trận lưu trong $gameSystem.pxbMarketBattle
 *   nên đi theo save của MV. Mọi hàm đều nhận object thuần (JSON-safe)
 *   — không dùng class / closure giữ method, vì method mất khi save/load.
 * - Số ĐÃ CHỐT (GDD Mục 11): 3v3/5v5, ~3 phút, 4 vũ khí, 6 vai theo
 *   màu, giữ sạp 1 tuần, Tướng Cướp buff ở chợ, Cảnh sát buff khi giữ
 *   sạp, không chết/không mất đồ. MỌI SỐ KHÁC trong file này là
 *   PROVISIONAL — xem docs/market-battle-design.md (đổi số thì sửa
 *   đồng thời file đó + file này + gdd.md Mục 11 nếu chủ chốt).
 *
 * PROVISIONAL — chưa chốt GDD, đổi thì sửa ở đây + design doc:
 *   - Lưới 12×9; xuất phát 2 đầu; di chuyển 3 ô/lượt (Xanh +1).
 *   - HP gốc 100; Đỏ Max HP ×1,5 + sát thương nhận ×0,8.
 *   - Vũ khí: Chảo 12/tầm 1; Cá khô 8/tầm 2; Ghế nhựa 15/tầm 1 +
 *     đẩy lùi 1 ô; Loa 10/tầm 3.
 *   - Vai: Tím sát thương ×1,25; Cam đòn đầu trận ×2; Vàng hồi 12 HP
 *     cho đồng đội kề bên; Lục né đòn đầu tiên mỗi vòng.
 *   - Lượt tối đa 10 giây; trận tối đa 180 giây; tối đa 12 vòng.
 *     Hết giờ thì đội có tổng % HP cao hơn thắng; bằng nhau thì hòa
 *     (hòa = không đội nào giữ sạp).
 *   - Giữ sạp 7 ngày game: giá sỉ −10%, thuế sạp −20%, Danh vọng
 *     +10/ngày game; 1 đội giữ tối đa 1 sạp.
 *   - Buff danh hiệu: Tướng Cướp +10% sát thương ở chợ; Cảnh sát
 *     +10% Max HP khi thủ sạp đội mình đang giữ.
 *   - Danh vọng trận: thắng +50, hòa +20, thua +10 (thua không phạt).
 *
 * Lưu: state giữ sạp sống trong $gameSystem.pxbMarketBattle nên đi
 * theo save của MV ($gameSystem vốn đã nằm trong save contents của
 * core). Khi core MV chưa có (repo hiện tại), logic thuần vẫn chạy và
 * test được qua module.exports; hàm install() trả false và không giả
 * vờ đã móc save.
 *
 * Dùng trong event (khi có core MV):
 *   var b = PXB_MarketBattle.createBattle({
 *     teamA: { id: "ct-a", name: "Hợp tác xã A",
 *       fighters: [PXB_MarketBattle.createFighter("a1", "Tư", "Do", "Chao", { the: 80, tri: 40, tam: 50 }, [])] },
 *     teamB: { id: "ct-b", name: "Hợp tác xã B", fighters: [...] },
 *     stallId: "sap-cho-dau-moi-1", gameDay: 42 })
 *   PXB_MarketBattle.setCurrentBattle(b)  // hoặc dùng b trực tiếp
 *   PXB_MarketBattle.moveFighter(b, "a1", 2, 4)
 *   PXB_MarketBattle.attack(b, "a1", "b1")
 *   PXB_MarketBattle.support(b, "a2", "a1")  // Vàng hồi máu đồng đội
 *   PXB_MarketBattle.endTurn(b)
 *   PXB_MarketBattle.tick(b, 5)              // đồng hồ trận chạy 5 giây
 *   PXB_MarketBattle.canChallenge("ct-a", "sap-cho-dau-moi-1", 42)
 *   PXB_MarketBattle.holdBenefits("ct-a", 42) // null nếu không giữ sạp
 */
(function () {
  "use strict";

  // --- Hằng PROVISIONAL (xem @help + docs/market-battle-design.md) ---

  // Lưới trận 12×9 (chưa có trong GDD — chọn để 5v5 còn chỗ xoay xở,
  // vừa viewport dọc 9:16 với tile 64×32 của PXB_Isometric).
  var GRID_W = 12;
  var GRID_H = 9;
  // HP gốc 100; Tank Đỏ ×1,5.
  var BASE_HP = 100;
  var TANK_HP_MULT = 1.5;
  // Tank Đỏ nhận sát thương ×0,8.
  var TANK_DMG_TAKEN_MULT = 0.8;
  // Di chuyển gốc 3 ô/lượt; Xanh chiến thuật +1.
  var BASE_MOVE = 3;
  var TACTICIAN_MOVE_BONUS = 1;
  // Lượt tối đa 10 giây; trận tối đa 180 giây (~3 phút GDD);
  // tối đa 12 vòng (lưới an toàn).
  var TURN_SECONDS = 10;
  var BATTLE_SECONDS = 180;
  var MAX_ROUNDS = 12;
  // Giữ sạp 7 ngày game (1 tuần GDD).
  var HOLD_DAYS = 7;
  // Quyền lợi giữ sạp: giá sỉ −10%, thuế sạp −20%, Danh vọng +10/ngày.
  var WHOLESALE_DISCOUNT_PERCENT = 10;
  var STALL_TAX_CUT_PERCENT = 20;
  var HOLD_FAME_PER_DAY = 10;
  // Danh vọng trận: thắng +50, hòa +20, thua +10 (thua không phạt).
  var FAME_WIN = 50;
  var FAME_DRAW = 20;
  var FAME_LOSS = 10;
  // Buff danh hiệu: Tướng Cướp +10% sát thương ở chợ; Cảnh sát +10%
  // Max HP khi thủ sạp đội mình đang giữ.
  var BANDIT_DMG_BONUS_PERCENT = 10;
  var POLICE_HP_BONUS_PERCENT = 10;
  // Vai hỗ trợ (Vàng) hồi 12 HP cho đồng đội kề bên.
  var SUPPORT_HEAL = 12;
  // Vai chính xác (Tím) sát thương ×1,25; burst (Cam) đòn đầu ×2.
  var SNIPER_DMG_MULT = 1.25;
  var BURST_FIRST_HIT_MULT = 2;

  // --- Vũ khí hài (PROVISIONAL) ---

  var WEAPONS = {
    Chao:    { key: "Chao",    name: "Chảo",     dmg: 12, range: 1, knockback: 0 },
    CaKho:   { key: "CaKho",   name: "Cá khô",   dmg: 8,  range: 2, knockback: 0 },
    GheNhua: { key: "GheNhua", name: "Ghế nhựa", dmg: 15, range: 1, knockback: 1 },
    Loa:     { key: "Loa",     name: "Loa",      dmg: 10, range: 3, knockback: 0 }
  };

  // --- Vai theo màu chỉ số (GDD Mục 11 đã chốt tên vai) ---

  var ROLES = {
    Do:   { key: "Do",   color: "Đỏ",   name: "Tank",       stat: "the" },
    Xanh: { key: "Xanh", color: "Xanh", name: "Chiến thuật", stat: "tri" },
    Vang: { key: "Vang", color: "Vàng", name: "Hỗ trợ",     stat: "tam" },
    Tim:  { key: "Tim",  color: "Tím",  name: "Chính xác",  stat: "ky" },
    Cam:  { key: "Cam",  color: "Cam",  name: "Burst",      stat: "dung" },
    Luc:  { key: "Luc",  color: "Lục",  name: "Mẹo",        stat: "sang" }
  };

  // Thứ tự ưu tiên khi 2 màu hòa điểm (PROVISIONAL — vai trộn trước vai
  // gốc: vai trộn là trung bình cộng nên không bao giờ vượt vai gốc,
  // chỉ hòa được; ưu tiên trộn để nhân vật mạnh 2 chỉ số thành vai trộn,
  // còn mạnh vượt trội 1 chỉ số thì vai gốc vẫn thắng outright.
  // Chỉ số cân bằng cả 3 gốc → Tím (Kỷ).)
  var ROLE_TIE_ORDER = ["Tim", "Cam", "Luc", "Do", "Xanh", "Vang"];

  // Đội hợp lệ: 3v3 hoặc 5v5 (GDD đã chốt).
  var TEAM_SIZES = [3, 5];

  var STATUS = {
    FIGHTING: "dang-danh",
    FINISHED: "ket-thuc"
  };

  var RESULT = {
    WIN_A: "A",
    WIN_B: "B",
    DRAW: "hoa"
  };

  // Lý do chặn trận (createBattle / canChallenge trả về).
  var BLOCK_REASON = {
    TEAM_TOO_SMALL: "doi-thieu-nguoi",
    TEAM_UNEQUAL: "doi-khong-bang-nhau",
    TEAM_SIZE_INVALID: "co-doi-khong-hop-le",
    HOLDING_OTHER_STALL: "dang-giu-sap-khac",
    ALREADY_HOLDING_THIS: "da-giu-sap-nay"
  };

  // --- Danh hiệu liên quan (tên đúng PXB_Titles.js / TitleConflict.cs) ---

  var TITLE_BANDIT = "Tướng Cướp";
  var TITLE_POLICE = "Cảnh sát";

  function equalsIgnoreCase(a, b) {
    return typeof a === "string" && typeof b === "string" &&
      a.toLowerCase() === b.toLowerCase();
  }

  // Danh sách danh hiệu của 1 đấu sĩ: lấy fighter.titles nếu có; nếu
  // không có thì lấy từ PXB_Titles đã load (chỉ đấu sĩ người chơi mới
  // có sổ danh hiệu); nếu không có gì thì [].
  function titlesOf(fighter) {
    if (fighter && Array.isArray(fighter.titles)) return fighter.titles;
    if (typeof window !== "undefined" && window.PXB_Titles &&
        typeof window.PXB_Titles.all === "function") {
      return window.PXB_Titles.all();
    }
    if (typeof global !== "undefined" && global.PXB_Titles &&
        typeof global.PXB_Titles.all === "function") {
      return global.PXB_Titles.all();
    }
    return [];
  }

  function hasTitle(fighter, title) {
    var list = titlesOf(fighter);
    for (var i = 0; i < list.length; i++) {
      if (equalsIgnoreCase(list[i], title)) return true;
    }
    return false;
  }

  // --- Vai theo màu chỉ số ---

  // Tính 6 màu từ 3 chỉ số gốc (đúng docs/stats.md: Tím=(Thể+Trí)/2,
  // Cam=(Thể+Tâm)/2, Lục=(Trí+Tâm)/2) rồi lấy màu cao nhất.
  function roleFromStats(stats) {
    var s = stats || {};
    var the = (typeof s.the === "number") ? s.the : 50;
    var tri = (typeof s.tri === "number") ? s.tri : 50;
    var tam = (typeof s.tam === "number") ? s.tam : 50;
    var values = {
      Do: the,
      Xanh: tri,
      Vang: tam,
      Tim: (the + tri) / 2,
      Cam: (the + tam) / 2,
      Luc: (tri + tam) / 2
    };
    var best = ROLE_TIE_ORDER[0];
    for (var i = 1; i < ROLE_TIE_ORDER.length; i++) {
      var key = ROLE_TIE_ORDER[i];
      if (values[key] > values[best]) best = key;
    }
    return best;
  }

  // --- Đấu sĩ (object thuần, JSON-safe) ---

  // Tạo 1 đấu sĩ. role: "Do"|"Xanh"|"Vang"|"Tim"|"Cam"|"Luc" — nếu bỏ
  // trống thì tự suy từ stats (roleFromStats). weaponKey:
  // "Chao"|"CaKho"|"GheNhua"|"Loa". titles: string[] danh hiệu đang có
  // (để tính buff; bỏ trống = đọc từ PXB_Titles nếu load rồi).
  // Max HP tính ở createBattle (vì buff Cảnh sát phụ thuộc đội thủ sạp).
  function createFighter(id, name, role, weaponKey, stats, titles) {
    var st = stats || { the: 50, tri: 50, tam: 50 };
    var r = role || roleFromStats(st);
    if (!ROLES[r]) r = roleFromStats(st);
    var w = WEAPONS[weaponKey] || WEAPONS.Chao;
    return {
      id: id,
      name: name,
      role: r,
      weapon: w.key,
      stats: {
        the: (typeof st.the === "number") ? st.the : 50,
        tri: (typeof st.tri === "number") ? st.tri : 50,
        tam: (typeof st.tam === "number") ? st.tam : 50
      },
      titles: Array.isArray(titles) ? titles.slice() : [],
      x: -1,
      y: -1,
      hp: BASE_HP,
      maxHp: BASE_HP,
      alive: true,
      hasAttackedThisBattle: false,
      dodgedThisRound: false,
      movedThisTurn: false,
      actedThisTurn: false
    };
  }

  // Max HP của đấu sĩ: gốc 100, Đỏ ×1,5; Cảnh sát +10% khi thủ sạp
  // đội mình đang giữ (buff PROVISIONAL, GDD chỉ chốt "buff khi giữ sạp").
  function computeMaxHp(fighter, isDefender) {
    var hp = BASE_HP;
    if (fighter.role === "Do") hp = Math.floor(hp * TANK_HP_MULT);
    if (isDefender && hasTitle(fighter, TITLE_POLICE)) {
      hp = Math.floor(hp * (100 + POLICE_HP_BONUS_PERCENT) / 100);
    }
    return hp;
  }

  // Tầm di chuyển: 3 ô, Xanh chiến thuật +1.
  function moveRangeOf(fighter) {
    return BASE_MOVE +
      ((fighter.role === "Xanh") ? TACTICIAN_MOVE_BONUS : 0);
  }

  // --- Lưới ---

  function inBounds(x, y) {
    return x >= 0 && x < GRID_W && y >= 0 && y < GRID_H;
  }

  function manhattan(ax, ay, bx, by) {
    return Math.abs(ax - bx) + Math.abs(ay - by);
  }

  function fighterAt(battle, x, y) {
    var all = allFighters(battle);
    for (var i = 0; i < all.length; i++) {
      if (all[i].alive && all[i].x === x && all[i].y === y) return all[i];
    }
    return null;
  }

  function allFighters(battle) {
    if (!battle) return [];
    var list = [];
    var a = (battle.teamA && battle.teamA.fighters) || [];
    var b = (battle.teamB && battle.teamB.fighters) || [];
    for (var i = 0; i < a.length; i++) list.push(a[i]);
    for (var j = 0; j < b.length; j++) list.push(b[j]);
    return list;
  }

  function findFighter(battle, fighterId) {
    var all = allFighters(battle);
    for (var i = 0; i < all.length; i++) {
      if (all[i].id === fighterId) return all[i];
    }
    return null;
  }

  // Vị trí xuất phát: đội A cột 0–1, đội B cột 10–11, hàng rải đều
  // giữa lưới (PROVISIONAL — đối xứng, không bên nào lợi thế).
  function spawnPositions(teamSize, isTeamA) {
    var positions = [];
    var startRow = Math.floor((GRID_H - teamSize) / 2);
    for (var i = 0; i < teamSize; i++) {
      var col = isTeamA ? (i % 2) : (GRID_W - 1 - (i % 2));
      positions.push({ x: col, y: startRow + i });
    }
    return positions;
  }

  // --- Tạo trận ---

  // Tạo trận mới. options: { teamA: {id, name, fighters[]},
  // teamB: {...}, stallId (string|null — null = giao hữu, không giữ
  // sạp), gameDay (số, mặc định 1), defenderTeam ("A"|"B"|null —
  // đội nào đang giữ sạp khi trận này là trận tranh sạp) }.
  // Trả { ok: true, battle } hoặc { ok: false, reason } — chặn khi
  // thiếu người / cỡ đội không hợp lệ / 2 đội không bằng nhau.
  function createBattle(options) {
    var opts = options || {};
    var teamA = opts.teamA || {};
    var teamB = opts.teamB || {};
    var fa = Array.isArray(teamA.fighters) ? teamA.fighters : [];
    var fb = Array.isArray(teamB.fighters) ? teamB.fighters : [];
    if (fa.length === 0 || fb.length === 0) {
      return { ok: false, reason: BLOCK_REASON.TEAM_TOO_SMALL };
    }
    if (fa.length !== fb.length) {
      return { ok: false, reason: BLOCK_REASON.TEAM_UNEQUAL };
    }
    if (TEAM_SIZES.indexOf(fa.length) < 0) {
      return { ok: false, reason: BLOCK_REASON.TEAM_SIZE_INVALID };
    }
    var gameDay = (typeof opts.gameDay === "number" && opts.gameDay > 0) ?
      Math.floor(opts.gameDay) : 1;
    var defenderTeam = (opts.defenderTeam === "A" ||
      opts.defenderTeam === "B") ? opts.defenderTeam : null;

    var battle = {
      teamA: { id: teamA.id || "doi-a", name: teamA.name || "Đội A",
        fighters: [] },
      teamB: { id: teamB.id || "doi-b", name: teamB.name || "Đội B",
        fighters: [] },
      stallId: (typeof opts.stallId === "string" &&
        opts.stallId.length > 0) ? opts.stallId : null,
      gameDay: gameDay,
      defenderTeam: defenderTeam,
      gridW: GRID_W,
      gridH: GRID_H,
      round: 1,
      turnIndex: 0,
      activeFighterId: null,
      elapsedSeconds: 0,
      status: STATUS.FIGHTING,
      winner: null,
      result: null,
      hold: null,
      log: []
    };

    var posA = spawnPositions(fa.length, true);
    var posB = spawnPositions(fb.length, false);
    var i;
    for (i = 0; i < fa.length; i++) {
      var a = fa[i];
      a.x = posA[i].x;
      a.y = posA[i].y;
      a.maxHp = computeMaxHp(a, defenderTeam === "A");
      a.hp = a.maxHp;
      a.alive = true;
      a.hasAttackedThisBattle = false;
      a.dodgedThisRound = false;
      a.movedThisTurn = false;
      a.actedThisTurn = false;
      battle.teamA.fighters.push(a);
    }
    for (i = 0; i < fb.length; i++) {
      var b = fb[i];
      b.x = posB[i].x;
      b.y = posB[i].y;
      b.maxHp = computeMaxHp(b, defenderTeam === "B");
      b.hp = b.maxHp;
      b.alive = true;
      b.hasAttackedThisBattle = false;
      b.dodgedThisRound = false;
      b.movedThisTurn = false;
      b.actedThisTurn = false;
      battle.teamB.fighters.push(b);
    }

    // Thứ tự lượt: xen kẽ A1 → B1 → A2 → B2 … (PROVISIONAL — đơn giản,
    // công bằng, không dùng chỉ số Trí làm sáng kiến để khỏi phức tạp).
    battle.turnOrder = [];
    for (i = 0; i < fa.length; i++) {
      battle.turnOrder.push(battle.teamA.fighters[i].id);
      battle.turnOrder.push(battle.teamB.fighters[i].id);
    }
    battle.activeFighterId = battle.turnOrder[0];
    battle.log.push("Trận bắt đầu: " + battle.teamA.name + " vs " +
      battle.teamB.name + " (" + fa.length + "v" + fb.length + ").");
    return { ok: true, battle: battle };
  }

  function activeFighter(battle) {
    if (!battle || !battle.activeFighterId) return null;
    return findFighter(battle, battle.activeFighterId);
  }

  function teamOf(battle, fighter) {
    if (!battle || !fighter) return null;
    var a = battle.teamA.fighters;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id === fighter.id) return "A";
    }
    return "B";
  }

  function teamAliveCount(battle, team) {
    var fighters = (team === "A") ?
      battle.teamA.fighters : battle.teamB.fighters;
    var count = 0;
    for (var i = 0; i < fighters.length; i++) {
      if (fighters[i].alive) count++;
    }
    return count;
  }

  // Tổng % HP còn lại của 1 đội (0..1) — thước đo thắng khi hết giờ.
  function teamHpPercent(battle, team) {
    var fighters = (team === "A") ?
      battle.teamA.fighters : battle.teamB.fighters;
    var hp = 0;
    var max = 0;
    for (var i = 0; i < fighters.length; i++) {
      hp += Math.max(0, fighters[i].hp);
      max += fighters[i].maxHp;
    }
    if (max <= 0) return 0;
    return Math.round((hp / max) * 100) / 100;
  }

  // --- Lượt đi ---

  // Di chuyển đấu sĩ đang tới lượt. Trả false nếu: trận đã xong,
  // không phải lượt của mình, đã di chuyển rồi, ô đích ngoài lưới /
  // quá tầm / có người đứng.
  function moveFighter(battle, fighterId, x, y) {
    if (!battle || battle.status !== STATUS.FIGHTING) return false;
    var f = findFighter(battle, fighterId);
    if (!f || !f.alive) return false;
    if (battle.activeFighterId !== fighterId) return false;
    if (f.movedThisTurn) return false;
    if (!inBounds(x, y)) return false;
    if (manhattan(f.x, f.y, x, y) > moveRangeOf(f)) return false;
    if (fighterAt(battle, x, y)) return false;
    f.x = x;
    f.y = y;
    f.movedThisTurn = true;
    return true;
  }

  // Tính sát thương 1 đòn (chưa trừ vào HP): vũ khí → × vai Tím/Cam →
  // × buff Tướng Cướp → làm tròn xuống → × giảm thương Tank.
  // Lục né đòn đầu mỗi vòng: sát thương về 0 (xử lý ở attack).
  function calcDamage(attacker, defender) {
    var w = WEAPONS[attacker.weapon] || WEAPONS.Chao;
    var dmg = w.dmg;
    if (attacker.role === "Tim") dmg = dmg * SNIPER_DMG_MULT;
    if (attacker.role === "Cam" && !attacker.hasAttackedThisBattle) {
      dmg = dmg * BURST_FIRST_HIT_MULT;
    }
    if (hasTitle(attacker, TITLE_BANDIT)) {
      dmg = dmg * (100 + BANDIT_DMG_BONUS_PERCENT) / 100;
    }
    dmg = Math.floor(dmg);
    if (defender.role === "Do") {
      dmg = Math.floor(dmg * TANK_DMG_TAKEN_MULT);
    }
    return Math.max(0, dmg);
  }

  // Đánh: đấu sĩ đang tới lượt đánh 1 đối thủ trong tầm vũ khí.
  // Trả { ok: true, damage, ko } hoặc { ok: false, reason }.
  // reason: "tran-xong" | "khong-phai-luot" | "da-hanh-dong" |
  // "ngoai-tam" | "cung-doi" | "muc-tieu-nga".
  function attack(battle, attackerId, targetId) {
    if (!battle || battle.status !== STATUS.FIGHTING) {
      return { ok: false, reason: "tran-xong" };
    }
    var atk = findFighter(battle, attackerId);
    var def = findFighter(battle, targetId);
    if (!atk || !atk.alive || battle.activeFighterId !== attackerId) {
      return { ok: false, reason: "khong-phai-luot" };
    }
    if (atk.actedThisTurn) {
      return { ok: false, reason: "da-hanh-dong" };
    }
    if (!def || !def.alive) {
      return { ok: false, reason: "muc-tieu-nga" };
    }
    if (teamOf(battle, atk) === teamOf(battle, def)) {
      return { ok: false, reason: "cung-doi" };
    }
    var w = WEAPONS[atk.weapon] || WEAPONS.Chao;
    if (manhattan(atk.x, atk.y, def.x, def.y) > w.range) {
      return { ok: false, reason: "ngoai-tam" };
    }
    var dmg = calcDamage(atk, def);
    var dodged = false;
    if (def.role === "Luc" && !def.dodgedThisRound) {
      // Lục mẹo: né đòn đầu tiên nhận trong mỗi vòng.
      def.dodgedThisRound = true;
      dmg = 0;
      dodged = true;
    }
    def.hp = Math.max(0, def.hp - dmg);
    if (def.hp <= 0) {
      def.alive = false; // "ngã sạp" — xỉu, KHÔNG chết, hết trận hồi đầy.
      def.hp = 0;
    }
    // Ghế nhựa: đẩy lùi mục tiêu 1 ô ra xa người đánh (nếu ô trống).
    var pushed = false;
    if (!dodged && def.alive && w.knockback > 0 && dmg > 0) {
      var dx = def.x - atk.x;
      var dy = def.y - atk.y;
      var nx = def.x;
      var ny = def.y;
      if (Math.abs(dx) >= Math.abs(dy)) {
        nx = def.x + (dx >= 0 ? w.knockback : -w.knockback);
      } else {
        ny = def.y + (dy >= 0 ? w.knockback : -w.knockback);
      }
      if (inBounds(nx, ny) && !fighterAt(battle, nx, ny)) {
        def.x = nx;
        def.y = ny;
        pushed = true;
      }
    }
    atk.actedThisTurn = true;
    atk.hasAttackedThisBattle = true;
    battle.log.push(atk.name + " dùng " +
      (WEAPONS[atk.weapon] || WEAPONS.Chao).name + " đánh " + def.name +
      (dodged ? " — né được!" : " −" + dmg + " HP") +
      (pushed ? " (đẩy lùi 1 ô)" : "") +
      (def.alive ? "" : " — ngã sạp!"));
    checkEnd(battle);
    return { ok: true, damage: dmg, dodged: dodged, ko: !def.alive,
      pushed: pushed };
  }

  // Hỗ trợ (chỉ vai Vàng): hồi SUPPORT_HEAL HP cho 1 đồng đội kề bên
  // (Manhattan 1 ô), thay vì đánh. Trả { ok, healed }.
  function support(battle, supporterId, allyId) {
    if (!battle || battle.status !== STATUS.FIGHTING) {
      return { ok: false, reason: "tran-xong" };
    }
    var sup = findFighter(battle, supporterId);
    var ally = findFighter(battle, allyId);
    if (!sup || !sup.alive || battle.activeFighterId !== supporterId) {
      return { ok: false, reason: "khong-phai-luot" };
    }
    if (sup.role !== "Vang") {
      return { ok: false, reason: "khong-phai-ho-tro" };
    }
    if (sup.actedThisTurn) {
      return { ok: false, reason: "da-hanh-dong" };
    }
    if (!ally || !ally.alive) {
      return { ok: false, reason: "muc-tieu-nga" };
    }
    if (teamOf(battle, sup) !== teamOf(battle, ally)) {
      return { ok: false, reason: "khong-cung-doi" };
    }
    if (manhattan(sup.x, sup.y, ally.x, ally.y) > 1) {
      return { ok: false, reason: "ngoai-tam" };
    }
    var healed = Math.min(SUPPORT_HEAL, ally.maxHp - ally.hp);
    ally.hp = ally.hp + healed;
    sup.actedThisTurn = true;
    battle.log.push(sup.name + " hỗ trợ " + ally.name +
      " +" + healed + " HP.");
    checkEnd(battle);
    return { ok: true, healed: healed };
  }

  // Kết thúc lượt của đấu sĩ đang đánh: chuyển sang đấu sĩ còn đứng
  // tiếp theo trong thứ tự xen kẽ; hết 1 vòng thì sang vòng mới
  // (đặt lại né của Lục + cờ đã di chuyển/hành động).
  function endTurn(battle) {
    if (!battle || battle.status !== STATUS.FIGHTING) return false;
    var order = battle.turnOrder;
    var next = battle.turnIndex + 1;
    var wrapped = false;
    while (next < order.length + order.length) {
      var idx = next % order.length;
      if (idx === 0 && next > 0) wrapped = true;
      var f = findFighter(battle, order[idx]);
      if (f && f.alive) {
        battle.turnIndex = idx;
        battle.activeFighterId = f.id;
        f.movedThisTurn = false;
        f.actedThisTurn = false;
        if (wrapped) {
          battle.round++;
          resetRoundFlags(battle);
        }
        return true;
      }
      next++;
    }
    return false;
  }

  // Hết giờ lượt (đồng hồ 10s của scene): tự chuyển lượt.
  function expireTurn(battle) {
    return endTurn(battle);
  }

  function resetRoundFlags(battle) {
    var all = allFighters(battle);
    for (var i = 0; i < all.length; i++) {
      all[i].dodgedThisRound = false;
    }
  }

  // Đồng hồ trận chạy thêm N giây (scene gọi mỗi giây / mỗi khung).
  // Hết 180 giây thì kết thúc trận theo % HP.
  function tick(battle, seconds) {
    if (!battle || battle.status !== STATUS.FIGHTING) return false;
    var s = (typeof seconds === "number" && seconds > 0) ? seconds : 0;
    battle.elapsedSeconds += s;
    checkEnd(battle);
    return true;
  }

  // --- Kết thúc trận ---

  // Kiểm tra điều kiện kết thúc sau mỗi hành động / mỗi tick.
  function checkEnd(battle) {
    if (!battle || battle.status !== STATUS.FIGHTING) return;
    var aAlive = teamAliveCount(battle, "A");
    var bAlive = teamAliveCount(battle, "B");
    if (aAlive === 0 && bAlive === 0) {
      finishBattle(battle, RESULT.DRAW);
      return;
    }
    if (aAlive === 0) {
      finishBattle(battle, RESULT.WIN_B);
      return;
    }
    if (bAlive === 0) {
      finishBattle(battle, RESULT.WIN_A);
      return;
    }
    if (battle.elapsedSeconds >= BATTLE_SECONDS ||
        battle.round > MAX_ROUNDS) {
      var pa = teamHpPercent(battle, "A");
      var pb = teamHpPercent(battle, "B");
      if (pa > pb) finishBattle(battle, RESULT.WIN_A);
      else if (pb > pa) finishBattle(battle, RESULT.WIN_B);
      else finishBattle(battle, RESULT.DRAW);
    }
  }

  // Chốt trận: ghi winner, Danh vọng, giữ sạp (nếu tranh sạp và có
  // đội thắng), ghi lịch sử vào state. Hồi đầy HP mọi đấu sĩ (không
  // chết, không mất đồ — hết trận là khỏe lại).
  function finishBattle(battle, winner) {
    battle.status = STATUS.FINISHED;
    battle.winner = winner;
    var fameA = (winner === "A") ? FAME_WIN :
      (winner === "hoa") ? FAME_DRAW : FAME_LOSS;
    var fameB = (winner === "B") ? FAME_WIN :
      (winner === "hoa") ? FAME_DRAW : FAME_LOSS;
    battle.result = {
      winner: winner,
      winnerTeamId: (winner === "A") ? battle.teamA.id :
        (winner === "B") ? battle.teamB.id : null,
      winnerTeamName: (winner === "A") ? battle.teamA.name :
        (winner === "B") ? battle.teamB.name : null,
      rounds: battle.round,
      elapsedSeconds: battle.elapsedSeconds,
      hpPercentA: teamHpPercent(battle, "A"),
      hpPercentB: teamHpPercent(battle, "B"),
      rewards: {
        teamA: { famePerFighter: fameA },
        teamB: { famePerFighter: fameB }
      }
    };
    // Đội thắng trận tranh sạp thì giữ sạp 7 ngày game từ hôm nay.
    if (battle.stallId && winner !== "hoa") {
      var winTeam = (winner === "A") ? battle.teamA : battle.teamB;
      var hold = {
        stallId: battle.stallId,
        teamId: winTeam.id,
        teamName: winTeam.name,
        startGameDay: battle.gameDay,
        untilGameDay: battle.gameDay + HOLD_DAYS
      };
      battle.hold = hold;
      applyHoldWin(state(), hold);
    }
    recordBattle(state(), battle);
    var all = allFighters(battle);
    for (var i = 0; i < all.length; i++) {
      all[i].hp = all[i].maxHp; // hết trận hồi đầy — không chết.
      all[i].alive = true;
    }
    battle.log.push("Trận kết thúc: " +
      (winner === "hoa" ? "Hòa!" :
        (winner === "A" ? battle.teamA.name : battle.teamB.name) +
        " thắng!") +
      (battle.hold ? " Giữ sạp " + battle.stallId + " đến ngày game " +
        battle.hold.untilGameDay + "." : ""));
  }

  // --- Giữ sạp (state trong $gameSystem.pxbMarketBattle) ---

  function defaultState() {
    return {
      holds: {},   // stallId -> {stallId, teamId, teamName, startGameDay, untilGameDay}
      history: []  // {gameDay, stallId, winnerTeamId, result, rounds, elapsedSeconds}
    };
  }

  function createMarketBattleState() {
    return defaultState();
  }

  // Dữ liệu dự phòng khi chưa có core MV (logic thuần vẫn test được).
  var fallbackState = defaultState();

  function state() {
    if (typeof $gameSystem !== "undefined" && $gameSystem) {
      if (!$gameSystem.pxbMarketBattle) {
        $gameSystem.pxbMarketBattle = defaultState();
      }
      return $gameSystem.pxbMarketBattle;
    }
    return fallbackState;
  }

  // Khởi tạo pxbMarketBattle trong $gameSystem (gọi khi new game).
  // Trả false khi chưa có $gameSystem — không giả vờ đã lưu được.
  function initInGameSystem() {
    if (typeof $gameSystem === "undefined" || !$gameSystem) return false;
    if (!$gameSystem.pxbMarketBattle) {
      $gameSystem.pxbMarketBattle = defaultState();
    }
    return true;
  }

  // Reset sổ hiện tại (event/test dùng để bắt đầu lại).
  function resetState() {
    var st = state();
    st.holds = {};
    st.history = [];
    return true;
  }

  // Sạp này còn đội giữ ở ngày game đó không (giữ từ startGameDay đến
  // hết untilGameDay - 1; đến untilGameDay là hết hạn).
  function isHolding(st, stallId, gameDay) {
    if (!st || !st.holds || !st.holds[stallId]) return false;
    var hold = st.holds[stallId];
    return gameDay >= hold.startGameDay && gameDay < hold.untilGameDay;
  }

  // Đội này đang giữ sạp nào ở ngày game đó (trả stallId hoặc null).
  function teamHoldsStall(st, teamId, gameDay) {
    if (!st || !st.holds) return null;
    for (var stallId in st.holds) {
      if (!st.holds.hasOwnProperty(stallId)) continue;
      var hold = st.holds[stallId];
      if (hold.teamId === teamId &&
          gameDay >= hold.startGameDay &&
          gameDay < hold.untilGameDay) {
        return stallId;
      }
    }
    return null;
  }

  // Đội này có được thách đấu sạp kia không? Chặn khi: đội đang giữ
  // sạp KHÁC (1 đội giữ tối đa 1 sạp — phải đợi hết hạn hoặc thua
  // trận thủ sạp), hoặc đội đã giữ chính sạp này rồi (muốn giữ tiếp
  // thì thủ sạp khi bị thách đấu). Thách đấu sạp đang có đội khác giữ
  // là ĐƯỢC — đó là trận tranh sạp.
  // Trả { ok: true } hoặc { ok: false, reason }.
  function canChallenge(st, teamId, stallId, gameDay) {
    var held = teamHoldsStall(st, teamId, gameDay);
    if (held && held !== stallId) {
      return { ok: false, reason: BLOCK_REASON.HOLDING_OTHER_STALL,
        holdingStallId: held };
    }
    if (held && held === stallId) {
      return { ok: false, reason: BLOCK_REASON.ALREADY_HOLDING_THIS,
        holdingStallId: held };
    }
    return { ok: true };
  }

  // Ghi đội thắng giữ sạp (gọi ở finishBattle; event cũng gọi được).
  function applyHoldWin(st, hold) {
    if (!st || !hold || !hold.stallId) return false;
    if (!st.holds) st.holds = {};
    st.holds[hold.stallId] = {
      stallId: hold.stallId,
      teamId: hold.teamId,
      teamName: hold.teamName || "",
      startGameDay: hold.startGameDay,
      untilGameDay: hold.untilGameDay
    };
    return true;
  }

  // Dọn sạp đã hết hạn ở ngày game đó. Trả số sạp đã dọn.
  function expireHolds(st, gameDay) {
    if (!st || !st.holds) return 0;
    var removed = 0;
    for (var stallId in st.holds) {
      if (!st.holds.hasOwnProperty(stallId)) continue;
      if (gameDay >= st.holds[stallId].untilGameDay) {
        delete st.holds[stallId];
        removed++;
      }
    }
    return removed;
  }

  // Quyền lợi giữ sạp của 1 đội ở ngày game đó (null nếu không giữ
  // sạp nào): giá sỉ −10%, thuế sạp −20%, Danh vọng +10/ngày game.
  function holdBenefits(st, teamId, gameDay) {
    var stallId = teamHoldsStall(st, teamId, gameDay);
    if (!stallId) return null;
    return {
      stallId: stallId,
      wholesaleDiscountPercent: WHOLESALE_DISCOUNT_PERCENT,
      stallTaxCutPercent: STALL_TAX_CUT_PERCENT,
      famePerDay: HOLD_FAME_PER_DAY
    };
  }

  // Ghi 1 trận đã xong vào lịch sử (tối đa giữ 50 trận gần nhất).
  function recordBattle(st, battle) {
    if (!st || !battle) return false;
    if (!Array.isArray(st.history)) st.history = [];
    st.history.push({
      gameDay: battle.gameDay,
      stallId: battle.stallId,
      winnerTeamId: battle.result ? battle.result.winnerTeamId : null,
      result: battle.winner,
      rounds: battle.round,
      elapsedSeconds: battle.elapsedSeconds
    });
    if (st.history.length > 50) {
      st.history.splice(0, st.history.length - 50);
    }
    return true;
  }

  function battleHistory(st) {
    return (st && Array.isArray(st.history)) ? st.history.slice() : [];
  }

  // --- Đội NPC lấp chỗ cho slice (GDD Mục 11: "NPC đóng vai người chơi") ---

  // Tạo 1 đội NPC tạm để test / chơi slice Phase 1. Tên + id là TẠM —
  // PXB_Story sau này thay bằng NPC thật của chợ. Chỉ dùng khi chưa có
  // đội người chơi / công ty thật.
  function seedNpcTeam(teamId, teamName, size) {
    var n = (size === 5) ? 5 : 3;
    var roles = ["Do", "Xanh", "Vang", "Tim", "Cam"];
    var weapons = ["Chao", "CaKho", "GheNhua", "Loa", "Chao"];
    var fighters = [];
    for (var i = 0; i < n; i++) {
      fighters.push(createFighter(
        teamId + "-npc-" + (i + 1),
        "Tiểu thương " + (i + 1),
        roles[i % roles.length],
        weapons[i % weapons.length],
        { the: 50, tri: 50, tam: 50 },
        []));
    }
    return { id: teamId, name: teamName, fighters: fighters };
  }

  // Trận hiện tại (biến module — như battle MV, không vào save) ---

  var currentBattle = null;

  // Cờ chống bọc hook 2 lần: install() gọi lại (vd test gọi tay sau
  // khi file load đã tự install) thì trả true ngay, không bọc thêm —
  // nếu không pluginCommand chạy 2 lần / 1 lệnh (EndTurn nhảy 2 lượt).
  var installed = false;

  function setCurrentBattle(battle) {
    currentBattle = battle || null;
    return currentBattle;
  }

  function getCurrentBattle() {
    return currentBattle;
  }

  // --- Wrapper trên state hiện tại (event gọi trực tiếp) ---

  function canChallengeNow(teamId, stallId, gameDay) {
    return canChallenge(state(), teamId, stallId, gameDay);
  }
  function isHoldingNow(stallId, gameDay) {
    return isHolding(state(), stallId, gameDay);
  }
  function teamHoldsStallNow(teamId, gameDay) {
    return teamHoldsStall(state(), teamId, gameDay);
  }
  function holdBenefitsNow(teamId, gameDay) {
    return holdBenefits(state(), teamId, gameDay);
  }
  function expireHoldsNow(gameDay) {
    return expireHolds(state(), gameDay);
  }
  function battleHistoryNow() {
    return battleHistory(state());
  }
  function moveFighterNow(fighterId, x, y) {
    if (!currentBattle) return false;
    return moveFighter(currentBattle, fighterId, x, y);
  }
  function attackNow(attackerId, targetId) {
    if (!currentBattle) return { ok: false, reason: "khong-co-tran" };
    return attack(currentBattle, attackerId, targetId);
  }
  function supportNow(supporterId, allyId) {
    if (!currentBattle) return { ok: false, reason: "khong-co-tran" };
    return support(currentBattle, supporterId, allyId);
  }
  function endTurnNow() {
    if (!currentBattle) return false;
    return endTurn(currentBattle);
  }
  function tickNow(seconds) {
    if (!currentBattle) return false;
    return tick(currentBattle, seconds);
  }

  // --- Móc vào core MV ---

  // Plugin command cho CommonEvent / event thường:
  //   PXB_MarketBattle Move <fighterId> <x> <y>
  //   PXB_MarketBattle Attack <attackerId> <targetId>
  //   PXB_MarketBattle Support <supporterId> <allyId>
  //   PXB_MarketBattle EndTurn
  //   PXB_MarketBattle Tick <seconds>
  //   PXB_MarketBattle ExpireHolds <gameDay>
  // Tạo trận KHÔNG qua plugin command (cần đội hình đầy đủ) — event
  // gọi trực tiếp PXB_MarketBattle.createBattle(...) rồi
  // .setCurrentBattle(...).
  function install() {
    if (installed) return true;
    if (typeof DataManager !== "undefined") {
      if (typeof DataManager.createGameObjects === "function") {
        var _createGameObjects = DataManager.createGameObjects;
        DataManager.createGameObjects = function () {
          _createGameObjects.call(this);
          initInGameSystem();
        };
      }
      if (typeof DataManager.extractSaveContents === "function") {
        var _extractSaveContents = DataManager.extractSaveContents;
        DataManager.extractSaveContents = function (contents) {
          _extractSaveContents.call(this, contents);
          if (typeof $gameSystem !== "undefined" && $gameSystem &&
              $gameSystem.pxbMarketBattle) {
            // Điền lại field thiếu khi load save cũ / save sửa tay.
            var d = defaultState();
            var s = $gameSystem.pxbMarketBattle;
            for (var k in d) {
              if (typeof s[k] === "undefined") s[k] = d[k];
            }
          }
        };
      }
    }
    if (typeof Game_Interpreter !== "undefined" &&
        typeof Game_Interpreter.prototype.pluginCommand === "function") {
      var _pluginCommand = Game_Interpreter.prototype.pluginCommand;
      Game_Interpreter.prototype.pluginCommand = function (command, args) {
        _pluginCommand.call(this, command, args);
        if (command === "PXB_MarketBattle") {
          if (args[0] === "Move") {
            moveFighterNow(args[1], parseInt(args[2], 10) || 0,
              parseInt(args[3], 10) || 0);
          } else if (args[0] === "Attack") {
            attackNow(args[1], args[2]);
          } else if (args[0] === "Support") {
            supportNow(args[1], args[2]);
          } else if (args[0] === "EndTurn") {
            endTurnNow();
          } else if (args[0] === "Tick") {
            tickNow(parseInt(args[1], 10) || 0);
          } else if (args[0] === "ExpireHolds") {
            expireHoldsNow(parseInt(args[1], 10) || 1);
          }
        }
      };
      installed = true;
      return true;
    }
    if (typeof DataManager !== "undefined") installed = true;
    return typeof DataManager !== "undefined";
  }

  // Áp dụng hook ngay khi file load (quy ước MV: code plugin chạy lúc
  // load). Không có core thì install() trả false và không làm gì.
  install();

  var PXB_MarketBattle = {
    GRID_W: GRID_W,
    GRID_H: GRID_H,
    BASE_HP: BASE_HP,
    TANK_HP_MULT: TANK_HP_MULT,
    TANK_DMG_TAKEN_MULT: TANK_DMG_TAKEN_MULT,
    BASE_MOVE: BASE_MOVE,
    TACTICIAN_MOVE_BONUS: TACTICIAN_MOVE_BONUS,
    TURN_SECONDS: TURN_SECONDS,
    BATTLE_SECONDS: BATTLE_SECONDS,
    MAX_ROUNDS: MAX_ROUNDS,
    HOLD_DAYS: HOLD_DAYS,
    WHOLESALE_DISCOUNT_PERCENT: WHOLESALE_DISCOUNT_PERCENT,
    STALL_TAX_CUT_PERCENT: STALL_TAX_CUT_PERCENT,
    HOLD_FAME_PER_DAY: HOLD_FAME_PER_DAY,
    FAME_WIN: FAME_WIN,
    FAME_DRAW: FAME_DRAW,
    FAME_LOSS: FAME_LOSS,
    BANDIT_DMG_BONUS_PERCENT: BANDIT_DMG_BONUS_PERCENT,
    POLICE_HP_BONUS_PERCENT: POLICE_HP_BONUS_PERCENT,
    SUPPORT_HEAL: SUPPORT_HEAL,
    SNIPER_DMG_MULT: SNIPER_DMG_MULT,
    BURST_FIRST_HIT_MULT: BURST_FIRST_HIT_MULT,
    WEAPONS: WEAPONS,
    ROLES: ROLES,
    TEAM_SIZES: TEAM_SIZES,
    STATUS: STATUS,
    RESULT: RESULT,
    BLOCK_REASON: BLOCK_REASON,
    TITLE_BANDIT: TITLE_BANDIT,
    TITLE_POLICE: TITLE_POLICE,
    roleFromStats: roleFromStats,
    createFighter: createFighter,
    computeMaxHp: computeMaxHp,
    moveRangeOf: moveRangeOf,
    createBattle: createBattle,
    activeFighter: activeFighter,
    teamOf: teamOf,
    teamAliveCount: teamAliveCount,
    teamHpPercent: teamHpPercent,
    moveFighter: moveFighter,
    calcDamage: calcDamage,
    attack: attack,
    support: support,
    endTurn: endTurn,
    expireTurn: expireTurn,
    tick: tick,
    checkEnd: checkEnd,
    finishBattle: finishBattle,
    createMarketBattleState: createMarketBattleState,
    isHolding: isHolding,
    teamHoldsStall: teamHoldsStall,
    canChallenge: canChallenge,
    applyHoldWin: applyHoldWin,
    expireHolds: expireHolds,
    holdBenefits: holdBenefits,
    recordBattle: recordBattle,
    battleHistory: battleHistory,
    seedNpcTeam: seedNpcTeam,
    setCurrentBattle: setCurrentBattle,
    getCurrentBattle: getCurrentBattle,
    canChallengeNow: canChallengeNow,
    isHoldingNow: isHoldingNow,
    teamHoldsStallNow: teamHoldsStallNow,
    holdBenefitsNow: holdBenefitsNow,
    expireHoldsNow: expireHoldsNow,
    battleHistoryNow: battleHistoryNow,
    moveFighterNow: moveFighterNow,
    attackNow: attackNow,
    supportNow: supportNow,
    endTurnNow: endTurnNow,
    tickNow: tickNow,
    resetState: resetState,
    initInGameSystem: initInGameSystem,
    install: install
  };

  if (typeof module !== "undefined" && module.exports) {
    module.exports = PXB_MarketBattle;
  } else if (typeof window !== "undefined") {
    window.PXB_MarketBattle = PXB_MarketBattle;
  }
})();

// Phố Xô Bồ — slice web chơi được thật, kiến trúc web HTML5 kiểu RPG Maker MV
// (Treasure of Nadia trên xenvn.com): dữ liệu data-driven (data/*.js, kiểu MV),
// map tile, NPC event/dialogue, hotspot, crafting tại Góc Chế Tạo, điện thoại
// làm hub, save localStorage (kiểu xenvn lưu save theo tài khoản — ở slice này
// lưu local, tài khoản làm ở phase online). Không copy code/asset của Nadia.
// Vẽ Canvas 2D: mặc định chiếu isometric 2.5D (js/iso.js), bấm "Đổi góc nhìn"
// để về top-down như Nadia. Chưa có art thật — hình khối/màu placeholder.
(function () {
  "use strict";
  var ITEMS = window.PHO_ITEMS, ACTORS = window.PHO_ACTORS, SKILLS = window.PHO_SKILLS,
      EVENTS = window.PHO_EVENTS, MAPINFOS = window.PHO_MAPINFOS,
      MAPS = window.PHO_MAPS.maps, SYS = window.PHO_SYSTEM, ISO = window.PHO_ISO;
  var SAVE_KEY = "pho-xo-bo-web-v2", AUTO_KEY = SAVE_KEY + "-auto";

  function defaultState() {
    return {
      money: 220000, day: 1, frameIndex: 0, frameStartedAt: Date.now(),
      mapId: 1, job: "ban-rong", view: "iso",
      stats: { the: 100, tri: 100, tam: 100 }, energy: 100, exp: 0,
      inv: { "khung-sat": 1, "banh-xe": 1, "van-go": 1 },
      pickedToday: [], crafted: [], tools: {},
      quests: {}, closeness: { "co-tu": 10, "ban-than": 20, "chi-le": 5, "anh-hai": 5 },
      worked: {}, study: null, unlocked: { park: false, night: false },
      messages: [
        { from: "co-tu", text: "Con mới lên phố, cứ từ từ. Phòng trọ cô để sẵn, việc thì ra chợ mà kiếm." },
        { from: "ban-than", text: "Ê, lên phố rồi thì rủ tao đi cùng cho vui!" }
      ],
      interestEarned: 0
    };
  }
  var state = load() || defaultState();
  var player = { x: 5, y: 6, tx: null, ty: null, pending: null };
  var keys = {};
  var frameNames = SYS.frames;

  var canvas = document.getElementById("game");
  var ctx = canvas.getContext("2d");

  // ---------- tiện ích ----------
  function load() { try { return JSON.parse(localStorage.getItem(AUTO_KEY)); } catch (e) { return null; } }
  function save() { try { localStorage.setItem(AUTO_KEY, JSON.stringify(state)); } catch (e) {} }
  function saveSlot(n) { try { localStorage.setItem(SAVE_KEY + "-slot" + n, JSON.stringify(state)); log("Đã lưu vào ô " + n + "."); } catch (e) { log("Lưu ô " + n + " thất bại."); } }
  function loadSlot(n) {
    try {
      var s = JSON.parse(localStorage.getItem(SAVE_KEY + "-slot" + n));
      if (!s) { log("Ô " + n + " chưa có save."); return; }
      state = s; player.x = 5; player.y = 6; player.tx = null;
      log("Đã tải save ô " + n + " (ngày " + state.day + ")."); save(); draw();
    } catch (e) { log("Tải ô " + n + " thất bại."); }
  }
  function map() { return MAPS.find(function (m) { return m.id === state.mapId; }); }
  function frame() { return frameNames[state.frameIndex]; }
  function fmt(n) { return n.toLocaleString("vi-VN") + "đ"; }
  function itemName(id) { return (ITEMS[id] && ITEMS[id].name) || id; }
  function log(msg) {
    var el = document.getElementById("log"), div = document.createElement("div");
    div.textContent = "• " + msg; el.prepend(div);
    while (el.children.length > 30) el.removeChild(el.lastChild);
  }
  function addMsg(from, text) { state.messages.push({ from: from, text: text }); }
  function tileAt(col, row) {
    var g = map().grid;
    if (row < 0 || row >= g.length || col < 0 || col >= g[0].length) return "#";
    return g[row][col];
  }
  function npcAt(col, row) {
    var found = null;
    map().npcs.forEach(function (id) {
      var a = ACTORS[id];
      if (a && Math.round(a.x) === col && Math.round(a.y) === row) found = a;
    });
    return found;
  }
  function canWalk(col, row) {
    var t = tileAt(col, row);
    if (t === "#" || t === "S" || t === "H") return false;
    return !npcAt(col, row);
  }
  function nearSpot() {
    var found = null;
    map().craftSpots.forEach(function (c) {
      if (Math.max(Math.abs(player.x - c.x), Math.abs(player.y - c.y)) <= 1.5) found = c;
    });
    return found;
  }
  function nearestNpc() {
    var best = null, bestD = 1.8;
    map().npcs.forEach(function (id) {
      var a = ACTORS[id], d = Math.hypot(player.x - a.x, player.y - a.y);
      if (d < bestD) { bestD = d; best = a; }
    });
    return best;
  }
  function nearestHotspot() {
    var best = null, bestD = 1.8;
    map().hotspots.forEach(function (h) {
      var d = Math.hypot(player.x - h.x, player.y - h.y);
      if (d < bestD) { bestD = d; best = h; }
    });
    return best;
  }

  // ---------- HUD ----------
  function renderHud() {
    document.getElementById("h-money").textContent = "💰 " + fmt(state.money);
    document.getElementById("h-day").textContent = "Ngày " + state.day;
    document.getElementById("h-frame").textContent = frame();
    document.getElementById("h-district").textContent = map().name;
    document.getElementById("h-stats").textContent =
      "Thể " + state.stats.the + " · Trí " + state.stats.tri + " · Tâm " + state.stats.tam + " · ⚡" + state.energy;
    var left = Math.max(0, SYS.frameMinutes * 60 - Math.floor((Date.now() - state.frameStartedAt) / 1000));
    document.getElementById("h-clock").textContent =
      "⏱ " + Math.floor(left / 60) + ":" + ("0" + (left % 60)).slice(-2) + " tới khung sau";
  }

  // ---------- vẽ map (iso mặc định, top-down khi đổi) ----------
  function tileCenter(col, row) {
    return state.view === "iso" ? ISO.isoPos(col, row) : ISO.topPos(col, row);
  }
  function drawTile(col, row) {
    var t = tileAt(col, row), p = tileCenter(col, row);
    var colors = { ".": "#d9c48a", "#": "#8a6a3b", S: "#b4452f", C: "#3e7a6e", T: "#2b6a8a", G: "#6a9a4e", H: "#6b4a2b" };
    if (state.view === "iso") {
      var w = 20, h = 10;
      ctx.fillStyle = colors[t] || "#d9c48a";
      ctx.beginPath();
      ctx.moveTo(p.x, p.y - h); ctx.lineTo(p.x + w, p.y); ctx.lineTo(p.x, p.y + h); ctx.lineTo(p.x - w, p.y);
      ctx.closePath(); ctx.fill();
      ctx.strokeStyle = "rgba(0,0,0,.15)"; ctx.stroke();
      if (t === "#" || t === "H" || t === "S") { // khối cao — gợi 2.5D
        ctx.fillStyle = colors[t];
        ctx.fillRect(p.x - w, p.y - h - 12, w * 2, 12);
        ctx.fillStyle = "rgba(0,0,0,.25)";
        ctx.fillRect(p.x - w, p.y - h - 12, w * 2, 3);
      }
      if (t === "T") { ctx.fillStyle = "#fff"; ctx.font = "bold 9px system-ui"; ctx.fillText("CỔNG", p.x - 12, p.y + 3); }
      if (t === "C") { ctx.fillStyle = "#fff"; ctx.font = "bold 9px system-ui"; ctx.fillText("CHẾ", p.x - 10, p.y + 3); }
    } else {
      ctx.fillStyle = colors[t] || "#d9c48a";
      ctx.fillRect(20 + col * 32, 96 + row * 32, 32, 32);
      ctx.strokeStyle = "rgba(0,0,0,.15)"; ctx.strokeRect(20 + col * 32, 96 + row * 32, 32, 32);
      if (t === "T" || t === "C") { ctx.fillStyle = "#fff"; ctx.font = "bold 10px system-ui"; ctx.fillText(t === "T" ? "CỔNG" : "CHẾ", 20 + col * 32 + 2, 96 + row * 32 + 18); }
    }
  }
  function drawActor(x, y, color, label, sub) {
    var p = tileCenter(Math.round(x), Math.round(y));
    if (state.view === "iso") { p = ISO.isoPos(x, y); }
    ctx.fillStyle = color;
    ctx.beginPath(); ctx.arc(p.x, p.y - 6, 11, 0, Math.PI * 2); ctx.fill();
    ctx.fillStyle = "#fff"; ctx.font = "bold 10px system-ui"; ctx.textAlign = "center";
    ctx.fillText(label, p.x, p.y - 2);
    if (sub) { ctx.fillStyle = "#1a1408"; ctx.font = "10px system-ui"; ctx.fillText(sub, p.x, p.y + 16); }
    ctx.textAlign = "left";
  }
  function draw() {
    var m = map();
    ctx.fillStyle = "#f9edce"; ctx.fillRect(0, 0, canvas.width, canvas.height);
    ctx.fillStyle = "#1a1408"; ctx.font = "bold 16px system-ui";
    ctx.fillText(m.name + " — " + frame() + " ngày " + state.day, 14, 24);
    ctx.font = "12px system-ui";
    ctx.fillText(state.view === "iso" ? "Góc nhìn 2.5D isometric (thử nghiệm) — chạm để đi, E để nói chuyện/nhặt" : "Góc nhìn top-down kiểu Nadia — chạm để đi, E để nói chuyện/nhặt", 14, 44);
    // Vẽ theo thứ tự col+row để khối trước không che khối sau (painter's algorithm).
    var order = [];
    for (var s = 0; s <= 20; s++) {
      for (var r = 0; r < 9; r++) for (var c = 0; c < 12; c++) {
        if (c + r === s) order.push([c, r]);
      }
    }
    order.forEach(function (rc) { drawTile(rc[0], rc[1]); });
    // Hotspot lấp lánh kiểu Nadia: to, vàng (thường) / cam (hiếm), không biến mất.
    var t = Date.now() / 400;
    m.hotspots.forEach(function (h) {
      var p = tileCenter(h.x, h.y), picked = state.pickedToday.indexOf(h.id) !== -1;
      var good = h.frame === frame();
      var pulse = 0.6 + 0.4 * Math.sin(t + h.x);
      ctx.globalAlpha = picked ? 0.2 : (good ? pulse : 0.45);
      ctx.fillStyle = h.rare ? "#e07b00" : "#e0a800";
      ctx.beginPath(); ctx.arc(p.x, p.y - 6, 12, 0, Math.PI * 2); ctx.fill();
      ctx.globalAlpha = 1;
      ctx.fillStyle = "#1a1408"; ctx.font = "bold 10px system-ui"; ctx.textAlign = "center";
      ctx.fillText(h.name + " (" + h.frame + ")", p.x, p.y + 18);
      ctx.textAlign = "left";
    });
    // NPC + người chơi, vẽ sau tile cùng hàng để đúng thứ tự che khuất.
    m.npcs.forEach(function (id) {
      var a = ACTORS[id];
      drawActor(a.x, a.y, a.color, a.name.slice(0, 1), a.name);
    });
    drawActor(player.x, player.y, "#b4452f", "B", "BẠN");
    renderHud();
  }

  // ---------- tương tác: nói chuyện / nhặt / chế / làm việc ----------
  var dlgNpc = null;
  function openTalk(npc) {
    dlgNpc = npc;
    document.getElementById("dlg-name").textContent = npc.name + " — " + npc.title;
    var q = npc.questGiver ? EVENTS[npc.questGiver] : null;
    var qs = q ? state.quests[q.id] : null;
    var text = npc.greet, choices = [];
    if (q && !qs) {
      choices.push({ label: "Nhận quest: " + q.title, act: function () { acceptQuest(q); } });
    } else if (q && qs === "accepted") {
      if (questReady(q)) choices.push({ label: "Trả quest: " + q.title, act: function () { finishQuest(q); } });
      else text = q.accept;
    } else if (q && qs === "done") {
      text = q.done;
    }
    choices.push({ label: "Hỏi gợi ý", act: function () { showDlg(npc, npc.hint, [{ label: "Cảm ơn cô/chị/anh", act: closeDlg }]); } });
    choices.push({ label: "Tạm biệt", act: closeDlg });
    showDlg(npc, text, choices);
  }
  function showDlg(npc, text, choices) {
    document.getElementById("dlg-name").textContent = npc.name + " — " + npc.title;
    document.getElementById("dlg-text").textContent = text;
    var box = document.getElementById("dlg-choices");
    box.innerHTML = "";
    choices.forEach(function (c) {
      var b = document.createElement("button");
      b.textContent = c.label; b.onclick = c.act; box.appendChild(b);
    });
    document.getElementById("dlg").style.display = "block";
  }
  function closeDlg() { document.getElementById("dlg").style.display = "none"; dlgNpc = null; }
  function acceptQuest(q) {
    state.quests[q.id] = "accepted";
    addMsg(q.giver, "Quest mới: " + q.title + " — " + q.accept);
    log("Đã nhận quest: " + q.title + ".");
    closeDlg(); save(); draw();
  }
  function questReady(q) {
    if (q.need.crafted) return state.crafted.indexOf(q.need.crafted) !== -1;
    if (q.need.workedJob) return !!state.worked[state.day + "-" + state.frameIndex] &&
      state.worked[state.day + "-" + state.frameIndex] === q.need.workedJob &&
      (!q.need.frame || q.need.frame === frame());
    return false;
  }
  function finishQuest(q) {
    state.quests[q.id] = "done";
    var r = q.reward;
    if (r.money) state.money += r.money;
    if (r.items) Object.keys(r.items).forEach(function (k) { state.inv[k] = (state.inv[k] || 0) + r.items[k]; });
    if (r.closeness) Object.keys(r.closeness).forEach(function (k) { state.closeness[k] = Math.min(100, (state.closeness[k] || 0) + r.closeness[k]); });
    if (r.unlock === "park") { state.unlocked.park = true; MAPINFOS.find(function (m) { return m.id === 17; }).locked = false; }
    addMsg(q.giver, "Cảm ơn con! Quest '" + q.title + "' xong rồi.");
    log("Hoàn thành quest: " + q.title + (r.money ? " (+" + fmt(r.money) + ")" : "") + ".");
    closeDlg(); save(); draw();
  }
  function explore() {
    var h = nearestHotspot();
    if (!h) { log("Lại gần hotspot lấp lánh rồi nhấn E để nhặt."); return; }
    if (state.pickedToday.indexOf(h.id) !== -1) { log(h.name + " hôm nay đã nhặt rồi, mai quay lại có đồ mới."); return; }
    if (h.frame !== frame()) { log(h.name + " chỉ có đồ vào khung " + h.frame + " (đang " + frame() + ")."); return; }
    if (h.needTool && !state.tools[h.needTool] && !state.inv[h.needTool]) {
      log(h.name + " là hotspot ẩn — cần " + itemName(h.needTool) + " mới thấy đồ."); return;
    }
    state.inv[h.item] = (state.inv[h.item] || 0) + h.qty;
    state.pickedToday.push(h.id);
    log("Nhặt được " + itemName(h.item) + " ×" + h.qty + " ở " + h.name + ".");
    save(); draw();
  }
  function craft(recipeId) {
    var spot = nearSpot();
    if (!spot) { log("Phải tới Góc Chế Tạo mới chế được — như Native Shrine của Nadia, không chế từ menu ở đâu cũng được."); return; }
    var recipe = SYS.recipes.find(function (r) { return r.id === recipeId; });
    var missing = Object.keys(recipe.needs).filter(function (k) { return (state.inv[k] || 0) < recipe.needs[k]; });
    if (missing.length) { log("Chế " + recipe.name + " còn thiếu: " + missing.map(itemName).join(", ") + ". Đi nhặt ở hotspot hoặc mua ở Chợ."); return; }
    Object.keys(recipe.needs).forEach(function (k) { state.inv[k] -= recipe.needs[k]; });
    state.crafted.push(recipe.id);
    state.tools[recipe.id] = 1;
    state.inv[recipe.id] = (state.inv[recipe.id] || 0) + 1;
    log("Chế xong " + recipe.name + "! " + recipe.note);
    if (recipe.id === "xe-day") log("Đã mở đường tới Công Viên An Bình — xem tab Bản đồ trên điện thoại.");
    save(); draw();
  }
  function workShift() {
    var key = state.day + "-" + state.frameIndex;
    if (state.worked[key]) { log("Khung này đã làm 1 ca rồi — nghỉ đi, mai làm tiếp (không FOMO)."); return; }
    if (state.energy < 10) { log("Mệt quá rồi (năng lượng " + state.energy + ") — về phòng nghỉ hoặc ăn cơm tấm đi."); return; }
    var job = SYS.jobs.find(function (j) { return j.id === state.job; });
    var mult = Math.max(0.5, state.stats[job.stat] / 100);
    if (frame() === job.goodFrame) mult *= 1.25;
    if (job.goodMap === state.mapId) mult *= 1.1;
    if (job.id === "ban-rong" && (state.tools["xe-day"] || 0) >= 2) mult *= 1.2;
    var pay = Math.round(job.basePay * mult);
    state.money += pay; state.energy -= 10; state.exp += 50;
    state.worked[key] = job.id;
    log("Làm ca " + job.name + " (" + frame() + "): +" + fmt(pay) + ", EXP +50, năng lượng -10.");
    var q = Object.keys(EVENTS).map(function (k) { return EVENTS[k]; })
      .find(function (e) { return state.quests[e.id] === "accepted" && e.need.workedJob === job.id; });
    if (q && questReady(q)) log("Đủ điều kiện trả quest '" + q.title + "' — về gặp " + ACTORS[q.giver].name + ".");
    save(); draw();
  }
  function nextFrame(auto) {
    state.frameIndex++;
    if (state.frameIndex >= 3) {
      state.frameIndex = 0; state.day++;
      state.pickedToday = [];
      var interest = Math.round(state.money * 0.005); // lãi 0,5%/ngày game ở slice (cho thấy rõ; bản đầy đủ tính theo tháng)
      state.money += interest; state.interestEarned += interest;
      if (state.study) {
        state.study.daysLeft--;
        if (state.study.daysLeft <= 0) {
          state.stats.tri = Math.max(state.stats.tri, state.study.tri);
          state.exp += state.study.exp;
          log("Học xong " + state.study.name + "! Trí lên " + state.stats.tri + ", EXP +" + state.study.exp + ".");
          state.study = null;
        }
      }
      log("Sang ngày " + state.day + ". Hotspot có đồ mới, lãi tiết kiệm +" + fmt(interest) + ".");
    } else {
      log("Sang khung " + frame() + " ngày " + state.day + ".");
    }
    state.energy = Math.min(100, state.energy + 20);
    state.frameStartedAt = Date.now();
    save(); draw();
  }

  // ---------- điện thoại: 9 tab, menu chính ----------
  var phoneOpen = false, currentTab = 0;
  function renderPhone() {
    var tabsEl = document.getElementById("tabs");
    tabsEl.innerHTML = "";
    SYS.phoneTabs.forEach(function (t, i) {
      var b = document.createElement("button");
      b.textContent = t; if (i === currentTab) b.className = "on";
      b.onclick = function () { currentTab = i; renderPhone(); };
      tabsEl.appendChild(b);
    });
    var body = "";
    if (currentTab === 0) {
      body = Object.keys(ACTORS).map(function (id) {
        var a = ACTORS[id];
        return "• <b>" + a.name + "</b> (" + a.title + ") — thân thiết " + (state.closeness[id] || 0) +
          ' <button data-act="talk" data-id="' + id + '">Nói chuyện</button>';
      }).join("<br>") + "<br><b>Tin nhắn:</b><br>" +
        state.messages.slice(-4).map(function (m) { return "• <b>" + ACTORS[m.from].name + ":</b> " + m.text; }).join("<br>");
    } else if (currentTab === 1) {
      body = "Số dư: <b>" + fmt(state.money) + "</b><br>Lãi tiết kiệm đã nhận: " + fmt(state.interestEarned) +
        " (0,5%/ngày game ở slice).<br>Không cash-out, không cho vay lãi, không cờ bạc — luật VN.";
    } else if (currentTab === 2) {
      body = MAPINFOS.map(function (m) {
        var here = m.id === state.mapId;
        var go = !m.locked && m.id <= 2
          ? ' <button data-act="go" data-id="' + m.id + '">Đi</button>'
          : (m.locked ? ' 🔒 ' + (m.unlock || "") : ' (đang xây map, mở sau)');
        return "• " + (m.locked ? "🔴 " : "🟢 ") + m.name + (here ? " (đang ở đây)" : "") + " — " + m.note + go;
      }).join("<br>");
    } else if (currentTab === 3) {
      body = SYS.jobs.map(function (j) {
        return "• " + j.name + " — " + fmt(j.basePay) + "/ca, khung tốt " + j.goodFrame +
          (j.id === state.job ? " (đang làm)" : "") +
          ' <button data-act="job" data-id="' + j.id + '">Chọn</button>';
      }).join("<br>") + "<br>Đã làm khung này: " + (state.worked[state.day + "-" + state.frameIndex] || "chưa");
    } else if (currentTab === 4) {
      body = "<b>Mua:</b><br>" + ["com-tam", "ca-phe", "sach-cu"].map(function (id) {
        var it = ITEMS[id];
        return "• " + it.name + " — " + fmt(it.price) + ' <button data-act="buy" data-id="' + id + '">Mua</button>';
      }).join("<br>") + "<br><b>Bán nguyên liệu:</b><br>" +
        Object.keys(state.inv).filter(function (k) { return state.inv[k] > 0 && ITEMS[k] && ITEMS[k].kind === "material"; }).map(function (k) {
          return "• " + ITEMS[k].name + " ×" + state.inv[k] + " — " + fmt(ITEMS[k].price) +
            ' <button data-act="sell" data-id="' + k + '">Bán 1</button>';
        }).join("<br>") + "<br><b>Túi:</b> " + Object.keys(state.inv).filter(function (k) { return state.inv[k] > 0; })
          .map(function (k) { return itemName(k) + " ×" + state.inv[k]; }).join(", ");
    } else if (currentTab === 5) {
      body = (state.study ? "Đang học: <b>" + state.study.name + "</b>, còn " + state.study.daysLeft + " ngày game.<br>" : "") +
        SYS.education.map(function (e) {
          return "• " + e.name + " — " + fmt(e.cost) + ", " + e.days + " ngày, Trí " + e.tri +
            ' <button data-act="study" data-id="' + e.name + '">Đăng ký</button>';
        }).join("<br>") + "<br><b>Khóa ngắn:</b><br>" + SYS.shortCourses.map(function (c) {
          return "• " + c.name + " — " + fmt(c.cost) + ", +" + c.gain + " " + c.stat +
            ' <button data-act="course" data-id="' + c.name + '">Học</button>';
        }).join("<br>");
    } else if (currentTab === 6) {
      body = "Thể " + state.stats.the + " · Trí " + state.stats.tri + " · Tâm " + state.stats.tam +
        "<br>Năng lượng: " + state.energy + "/100 · EXP: " + state.exp +
        '<br><button data-act="rest">😴 Nghỉ ngơi (sang khung sau, +20 năng lượng)</button>' +
        "<br>Nghỉ ngơi không bị phạt — mệt thì về phòng trọ ngủ.";
    } else if (currentTab === 7) {
      body = Object.keys(state.closeness).map(function (id) {
        return "• " + ACTORS[id].name + " — thân thiết " + state.closeness[id] + "/100";
      }).join("<br>") + "<br>Đi cùng bạn thân hỗ trợ +20% EXP. Bỏ bê 7 ngày game sẽ giảm thân thiết.";
    } else {
      body = 'Góc nhìn: <b>' + (state.view === "iso" ? "2.5D isometric" : "Top-down") + '</b>' +
        ' <button data-act="view">Đổi góc nhìn</button><br>' +
        'Lưu tự động đã bật. Ô save:<br>' +
        [1, 2, 3].map(function (n) {
          return 'Ô ' + n + ' <button data-act="save" data-id="' + n + '">Lưu</button>' +
            ' <button data-act="load" data-id="' + n + '">Tải</button>';
        }).join("<br>") + '<br><button data-act="reset">Chơi lại từ đầu</button>';
    }
    document.getElementById("tabbody").innerHTML = body;
  }
  document.getElementById("tabbody").addEventListener("click", function (e) {
    var b = e.target.closest("button[data-act]");
    if (!b) return;
    var act = b.getAttribute("data-act"), id = b.getAttribute("data-id");
    if (act === "go") { goMap(parseInt(id, 10)); }
    else if (act === "job") { state.job = id; log("Đã chọn nghề " + id + "."); save(); renderPhone(); }
    else if (act === "talk") { var a = ACTORS[id]; if (a && a.mapId === state.mapId) openTalk(a); else log(a.name + " đang ở " + MAPINFOS.find(function (m) { return m.id === a.mapId; }).name + " — tới đó mới nói chuyện được."); }
    else if (act === "buy") {
      var it = ITEMS[id];
      if (state.money < it.price) { log("Không đủ tiền mua " + it.name + "."); return; }
      state.money -= it.price; state.inv[id] = (state.inv[id] || 0) + 1;
      log("Đã mua " + it.name + " (" + fmt(it.price) + ")."); save(); renderPhone(); draw();
    }
    else if (act === "sell") {
      if ((state.inv[id] || 0) <= 0) return;
      state.inv[id]--; state.money += ITEMS[id].price;
      log("Đã bán " + ITEMS[id].name + " (+" + fmt(ITEMS[id].price) + ")."); save(); renderPhone(); draw();
    }
    else if (act === "study") {
      var edu = SYS.education.find(function (x) { return x.name === id; });
      if (state.study) { log("Đang học " + state.study.name + " rồi — học xong đã."); return; }
      if (state.money < edu.cost) { log("Không đủ tiền đăng ký " + edu.name + " (" + fmt(edu.cost) + ")."); return; }
      state.money -= edu.cost; state.study = { name: edu.name, daysLeft: edu.days, tri: edu.tri, exp: edu.exp };
      log("Đã đăng ký " + edu.name + " — " + edu.days + " ngày game."); save(); renderPhone(); draw();
    }
    else if (act === "course") {
      var c = SYS.shortCourses.find(function (x) { return x.name === id; });
      if (state.money < c.cost) { log("Không đủ tiền học " + c.name + "."); return; }
      state.money -= c.cost; state.stats[c.stat] = Math.min(100, state.stats[c.stat] + c.gain);
      log("Học xong " + c.name + ": " + c.stat + " +" + c.gain + "."); save(); renderPhone(); draw();
    }
    else if (act === "rest") { nextFrame(false); renderPhone(); }
    else if (act === "view") { state.view = state.view === "iso" ? "top" : "iso"; save(); renderPhone(); draw(); }
    else if (act === "save") { saveSlot(parseInt(id, 10)); }
    else if (act === "load") { loadSlot(parseInt(id, 10)); renderPhone(); }
    else if (act === "reset") { if (confirm("Chơi lại từ đầu? Save hiện tại sẽ mất.")) { state = defaultState(); player.x = 5; player.y = 6; save(); renderPhone(); draw(); } }
  });
  function goMap(id) {
    if (id > 2) { log("Map này đang xây — mở ở phase sau."); return; }
    state.mapId = id; player.x = 5; player.y = 6; player.tx = null;
    log("Fast travel tới " + map().name + ".");
    save(); renderPhone(); draw();
  }
  function togglePhone() {
    phoneOpen = !phoneOpen;
    document.getElementById("phone").classList.toggle("open", phoneOpen);
    if (phoneOpen) renderPhone();
  }
  function useSelectedItem() {
    // Dùng đồ ăn/sách trong túi: ưu tiên cơm tấm > cà phê > sách cũ.
    var order = ["com-tam", "ca-phe", "sach-cu"];
    for (var i = 0; i < order.length; i++) {
      var id = order[i];
      if ((state.inv[id] || 0) > 0) {
        state.inv[id]--;
        var it = ITEMS[id];
        if (it.energy) { state.energy = Math.min(100, state.energy + it.energy); log("Ăn/uống " + it.name + ": năng lượng +" + it.energy + "."); }
        if (it.tri) { state.stats.tri = Math.min(100, state.stats.tri + it.tri); log("Đọc " + it.name + ": Trí +" + it.tri + "."); }
        save(); draw(); return;
      }
    }
    log("Túi không có đồ ăn/sách để dùng — mua ở tab Chợ trên điện thoại.");
  }

  // ---------- input: bàn phím + chạm ----------
  function screenToTile(sx, sy) {
    return state.view === "iso" ? ISO.screenToTile(sx, sy) : ISO.topToTile(sx, sy);
  }
  document.addEventListener("keydown", function (e) {
    var k = e.key.toLowerCase();
    keys[k] = true;
    if (k === "e") { var n = nearestNpc(); if (n) openTalk(n); else explore(); }
    if (k === "p") togglePhone();
    if (k === "u") useSelectedItem();
  });
  document.addEventListener("keyup", function (e) { keys[e.key.toLowerCase()] = false; });
  canvas.addEventListener("pointerdown", function (e) {
    var r = canvas.getBoundingClientRect();
    var x = (e.clientX - r.left) * canvas.width / r.width;
    var y = (e.clientY - r.top) * canvas.height / r.height;
    var t = screenToTile(x, y);
    var npc = npcAt(t.col, t.row);
    if (npc) { openTalk(npc); return; }
    var hs = map().hotspots.find(function (h) { return h.x === t.col && h.y === t.row; });
    if (hs) { player.tx = hs.x; player.ty = hs.y; player.pending = { type: "explore" }; return; }
    if (canWalk(t.col, t.row)) { player.tx = t.col; player.ty = t.row; player.pending = null; }
  });
  document.getElementById("btn-work").onclick = workShift;
  document.getElementById("btn-craft").onclick = function () { craft("xe-day"); };
  document.getElementById("btn-craft2").onclick = function () { craft("den-soi"); };
  document.getElementById("btn-phone").onclick = togglePhone;
  document.getElementById("btn-next").onclick = function () { nextFrame(false); };
  document.getElementById("btn-view").onclick = function () {
    state.view = state.view === "iso" ? "top" : "iso"; save(); draw();
  };
  document.getElementById("btn-use").onclick = useSelectedItem;

  // ---------- vòng lặp chính ----------
  setInterval(function () {
    // Đồng hồ thật: 1 khung = 10 phút thật (GDD Mục 1, kiểu C). Hết giờ tự sang khung.
    if (Date.now() - state.frameStartedAt >= SYS.frameMinutes * 60 * 1000) nextFrame(true);
    var sp = 0.09, dx = 0, dy = 0;
    if (keys["w"] || keys["arrowup"]) dy -= 1;
    if (keys["s"] || keys["arrowdown"]) dy += 1;
    if (keys["a"] || keys["arrowleft"]) dx -= 1;
    if (keys["d"] || keys["arrowright"]) dx += 1;
    if (dx || dy) { player.tx = null; player.pending = null; }
    else if (player.tx !== null && player.tx !== undefined) {
      dx = player.tx - player.x; dy = player.ty - player.y;
      if (Math.hypot(dx, dy) < 0.15) {
        player.x = player.tx; player.y = player.ty; player.tx = null;
        if (player.pending && player.pending.type === "explore") { player.pending = null; explore(); }
      } else { dx /= Math.hypot(dx, dy); dy /= Math.hypot(dx, dy); }
    }
    if (dx || dy) {
      var nx = player.x + dx * sp, ny = player.y + dy * sp;
      if (canWalk(Math.round(nx), Math.round(player.y))) player.x = nx;
      if (canWalk(Math.round(player.x), Math.round(ny))) player.y = ny;
    }
    player.x = Math.max(0.5, Math.min(11.5, player.x));
    player.y = Math.max(0.5, Math.min(8.5, player.y));
    // Cổng chuyển khu: đứng lên ô T là sang khu kia (kiểu MV transfer event).
    var tr = map().transfers.find(function (t) { return Math.round(player.x) === t.x && Math.round(player.y) === t.y; });
    if (tr) {
      state.mapId = tr.toMap; player.x = tr.toX; player.y = tr.toY; player.tx = null;
      log(tr.label + "."); save();
    }
    draw();
  }, 50);

  log("Chào mừng tới " + map().name + "! Lại gần hotspot vàng lấp lánh để nhặt đồ, gặp cô Tư để nhận quest chế Xe Đẩy.");
  log("1 ngày game = 30 phút thật, 3 khung Sáng/Chiều/Tối. Hết 10 phút tự sang khung — miss khung không bị phạt.");
  draw();
})();

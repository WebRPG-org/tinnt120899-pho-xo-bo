// Phố Xô Bồ — slice web tĩnh, theo mô hình web của Treasure of Nadia:
// mở link là chơi, không cài đặt, chạm được trên mobile, lưu local (kiểu xenvn
// lưu save theo tài khoản — ở slice này lưu localStorage, tài khoản làm ở phase online).
// Vẽ Canvas 2D bằng hình khối/màu (chưa có art thật). Không copy code/asset của Nadia.
(function () {
  "use strict";
  var DATA = window.PHO_MAPS;
  var SAVE_KEY = "pho-xo-bo-web-v1";

  // ---- State (cùng số chốt với GameBalance.cs: ngày 30 phút / 3 khung, lãi 0.5%, phí 5%) ----
  var state = load() || {
    money: 220000, day: 1, frameIndex: 0, districtId: 1,
    stats: { the: 100, tri: 100, tam: 100 },
    inv: { "Khung Sắt": 1, "Bánh Xe": 1, "Ván Gỗ": 1 },
    pickedToday: [], crafted: [], job: "ban-rong"
  };
  var player = { x: 232, y: 210, r: 12 };
  var keys = {};
  var frameNames = DATA.frames;

  var canvas = document.getElementById("game");
  var ctx = canvas.getContext("2d");

  function load() { try { return JSON.parse(localStorage.getItem(SAVE_KEY)); } catch (e) { return null; } }
  function save() { try { localStorage.setItem(SAVE_KEY, JSON.stringify(state)); } catch (e) {} }
  function district() { return DATA.districts.find(function (d) { return d.id === state.districtId; }); }
  function frame() { return frameNames[state.frameIndex]; }
  function log(msg) {
    var el = document.getElementById("log");
    var div = document.createElement("div");
    div.textContent = "• " + msg;
    el.prepend(div);
  }
  function fmt(n) { return n.toLocaleString("vi-VN") + "đ"; }

  function renderHud() {
    document.getElementById("h-money").textContent = "💰 " + fmt(state.money);
    document.getElementById("h-day").textContent = "Ngày " + state.day;
    document.getElementById("h-frame").textContent = frame();
    document.getElementById("h-district").textContent = district().name;
    document.getElementById("h-stats").textContent =
      "Thể " + state.stats.the + " · Trí " + state.stats.tri + " · Tâm " + state.stats.tam;
  }

  // ---- Vẽ map 2D (placeholder hình khối — chưa có art thật) ----
  function draw() {
    var d = district();
    ctx.fillStyle = d.color; ctx.fillRect(0, 0, canvas.width, canvas.height);
    ctx.fillStyle = "#f9edce";
    ctx.fillRect(20, 20, canvas.width - 40, 60);
    ctx.fillStyle = "#1a1408"; ctx.font = "bold 16px system-ui";
    ctx.fillText(d.name + " — " + d.desc, 30, 45);
    ctx.font = "12px system-ui";
    ctx.fillText("NPC: " + d.npcs.map(function (n) { return n.name; }).join(" · "), 30, 65);
    // Hotspot lấp lánh kiểu Nadia: to, sáng, vàng (thường) — nhặt 1 lần/ngày game
    var t = Date.now() / 400;
    d.hotspots.forEach(function (h) {
      var picked = state.pickedToday.indexOf(h.id) !== -1;
      var good = h.frame === frame();
      var pulse = 0.6 + 0.4 * Math.sin(t + h.x);
      ctx.globalAlpha = picked ? 0.25 : (good ? pulse : 0.5);
      ctx.fillStyle = good ? "#e0a800" : "#888";
      ctx.beginPath(); ctx.arc(h.x, h.y, 18, 0, Math.PI * 2); ctx.fill();
      ctx.globalAlpha = 1;
      ctx.fillStyle = "#1a1408"; ctx.font = "bold 11px system-ui";
      ctx.fillText(h.name + " (" + h.frame + ")", h.x - 30, h.y + 32);
    });
    // Người chơi
    ctx.fillStyle = "#b4452f";
    ctx.beginPath(); ctx.arc(player.x, player.y, player.r, 0, Math.PI * 2); ctx.fill();
    ctx.fillStyle = "#fff"; ctx.font = "bold 10px system-ui";
    ctx.fillText("BẠN", player.x - 12, player.y - 18);
    renderHud();
  }

  function nearestHotspot() {
    var best = null, bestD = 60;
    district().hotspots.forEach(function (h) {
      var d = Math.hypot(player.x - h.x, player.y - h.y);
      if (d < bestD) { bestD = d; best = h; }
    });
    return best;
  }

  function explore() {
    var h = nearestHotspot();
    if (!h) { log("Lại gần hotspot lấp lánh rồi chạm để nhặt."); return; }
    if (state.pickedToday.indexOf(h.id) !== -1) { log(h.name + " hôm nay đã nhặt rồi, mai quay lại có đồ mới."); return; }
    if (h.frame !== frame()) {
      log(h.name + " chỉ có đồ vào khung " + h.frame + " (đang " + frame() + ").");
      return;
    }
    state.inv[h.item] = (state.inv[h.item] || 0) + h.qty;
    state.pickedToday.push(h.id);
    log("Nhặt được " + h.item + " ×" + h.qty + " ở " + h.name + ".");
    save(); draw();
  }

  function workShift() {
    var job = DATA.jobs.find(function (j) { return j.id === state.job; });
    var stat = state.stats[job.stat];
    var mult = Math.max(0.5, stat / 100);
    if (frame() === job.goodFrame) mult *= 1.25; // khung tốt +25%
    var pay = Math.round(job.basePay * mult);
    state.money += pay;
    log("Làm ca " + job.name + " (" + frame() + "): +" + fmt(pay) + ".");
    save(); draw();
  }

  function craft() {
    var recipe = DATA.recipes[0]; // Xe Đẩy Hàng
    var missing = Object.keys(recipe.needs).filter(function (k) {
      return (state.inv[k] || 0) < recipe.needs[k];
    });
    if (missing.length) {
      log("Chế " + recipe.name + " còn thiếu: " + missing.join(", ") +
        ". Đi nhặt ở hotspot hoặc chợ. (" + recipe.note + ")");
      return;
    }
    Object.keys(recipe.needs).forEach(function (k) { state.inv[k] -= recipe.needs[k]; });
    state.crafted.push(recipe.id);
    log("Chế xong " + recipe.name + "! " + recipe.note);
    save(); draw();
  }

  function nextFrame() {
    state.frameIndex++;
    if (state.frameIndex >= 3) {
      state.frameIndex = 0; state.day++;
      state.pickedToday = []; // sang ngày mới, hotspot có đồ mới (như Nadia)
      state.money += Math.round(state.money * 0.005); // lãi tiết kiệm 0.5%/tháng game — ở slice tính mỗi ngày cho thấy rõ
      log("Sang ngày " + state.day + ". Hotspot có đồ mới, tiền lãi +0.5%.");
    } else {
      log("Sang khung " + frame() + " ngày " + state.day + ".");
    }
    save(); draw();
  }

  // ---- Điện thoại: menu chính 9 tab (như PhoneHub.cs) ----
  var phoneOpen = false, currentTab = 0;
  function renderPhone() {
    var tabsEl = document.getElementById("tabs");
    tabsEl.innerHTML = "";
    DATA.phoneTabs.forEach(function (t, i) {
      var b = document.createElement("button");
      b.textContent = t; if (i === currentTab) b.className = "on";
      b.onclick = function () { currentTab = i; renderPhone(); };
      tabsEl.appendChild(b);
    });
    var d = district(), body = "";
    switch (currentTab) {
      case 0: body = d.npcs.map(function (n) { return "• <b>" + n.name + "</b> — " + n.role; }).join("<br>"); break;
      case 1: body = "Số dư: <b>" + fmt(state.money) + "</b><br>Lãi tiết kiệm 0,5%/tháng game. Không cash-out, không cờ bạc."; break;
      case 2: body = DATA.districts.map(function (x) {
        return "• " + x.name + (x.id === state.districtId ? " (đang ở đây)" : "") +
          ' <button onclick="window.__phoGo(' + x.id + ')">Đi</button>';
      }).join("<br>"); break;
      case 3: body = DATA.jobs.map(function (j) {
        return "• " + j.name + " — " + fmt(j.basePay) + "/ca, khung tốt " + j.goodFrame +
          (j.id === state.job ? " (đang làm)" : "") +
          ' <button onclick="window.__phoJob(\'' + j.id + '\')">Chọn</button>';
      }).join("<br>"); break;
      case 4: body = "Túi: " + Object.keys(state.inv).map(function (k) { return k + " ×" + state.inv[k]; }).join(", ") +
        "<br>Đồ đã chế: " + (state.crafted.join(", ") || "chưa có"); break;
      case 5: body = "Học vấn: THPT miễn phí → Cao đẳng 20tr → Cử nhân 80tr → Thạc sĩ 200tr → Tiến sĩ 500tr (xem GDD Mục 5)."; break;
      case 6: body = "Thể " + state.stats.the + " · Trí " + state.stats.tri + " · Tâm " + state.stats.tam +
        "<br>Nghỉ ngơi không bị phạt — mệt thì về phòng trọ ngủ."; break;
      case 7: body = "Quan hệ: bạn thân NPC hỗ trợ +20% EXP. Bỏ bê 7 ngày game sẽ giảm thân thiết."; break;
      default: body = "Cài đặt: âm thanh, ngôn ngữ Tiếng Việt, lưu tự động đã bật.";
    }
    document.getElementById("tabbody").innerHTML = body;
  }
  window.__phoGo = function (id) { state.districtId = id; player.x = 232; player.y = 210; log("Fast travel tới " + district().name + "."); save(); renderPhone(); draw(); };
  window.__phoJob = function (id) { state.job = id; log("Đã chọn nghề " + id + "."); save(); renderPhone(); };
  function togglePhone() {
    phoneOpen = !phoneOpen;
    document.getElementById("phone").classList.toggle("open", phoneOpen);
    if (phoneOpen) renderPhone();
  }

  // ---- Input: bàn phím + chạm (mobile như Nadia web) ----
  document.addEventListener("keydown", function (e) {
    keys[e.key.toLowerCase()] = true;
    if (e.key === "e" || e.key === "E") explore();
    if (e.key === "p" || e.key === "P") togglePhone();
  });
  document.addEventListener("keyup", function (e) { keys[e.key.toLowerCase()] = false; });
  canvas.addEventListener("pointerdown", function (e) {
    var r = canvas.getBoundingClientRect();
    var x = (e.clientX - r.left) * canvas.width / r.width;
    var y = (e.clientY - r.top) * canvas.height / r.height;
    player.tx = x; player.ty = y;
    if (nearestHotspot()) explore();
  });
  document.getElementById("btn-work").onclick = workShift;
  document.getElementById("btn-craft").onclick = craft;
  document.getElementById("btn-phone").onclick = togglePhone;
  document.getElementById("btn-next").onclick = nextFrame;

  setInterval(function () {
    var sp = 3;
    if (keys["w"] || keys["arrowup"]) player.y -= sp;
    if (keys["s"] || keys["arrowdown"]) player.y += sp;
    if (keys["a"] || keys["arrowleft"]) player.x -= sp;
    if (keys["d"] || keys["arrowright"]) player.x += sp;
    if (player.tx !== undefined) {
      var dx = player.tx - player.x, dy = player.ty - player.y;
      if (Math.hypot(dx, dy) > 4) { player.x += dx * 0.08; player.y += dy * 0.08; }
    }
    player.x = Math.max(20, Math.min(canvas.width - 20, player.x));
    player.y = Math.max(80, Math.min(canvas.height - 20, player.y));
    draw();
  }, 50);

  log("Chào mừng tới " + district().name + "! Lại gần hotspot vàng lấp lánh để nhặt đồ, rồi chế Xe Đẩy Hàng.");
  log("Cô Tư (chủ trọ) là người dẫn đường của bạn — gặp bí thì hỏi cô ấy trong tab Danh bạ.");
  draw();
})();

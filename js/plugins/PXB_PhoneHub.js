/*:
 * @plugindesc Phố Xô Bồ — Điện thoại là menu chính: overlay hub 9 tab, mở bằng phím P / nút điện thoại, không thay thế thế giới.
 * @author Muse Center
 *
 * @help
 * Port trung thực PhoneHub.cs (src/client/Assets/Scripts/PhoneHub.cs).
 *
 * - 9 tab đúng thứ tự GDD Mục 2: Danh bạ / Tin nhắn, Ngân hàng, Bản đồ,
 *   Việc làm, Chợ, Học tập, Sức khỏe, Xã hội, Cài đặt. Tab mặc định khi
 *   mở là Danh bạ / Tin nhắn.
 * - Open(tab) / Close() / Toggle() / SelectTab(tab): mở tab thì đánh
 *   dấu đã đọc tab đó (số chưa đọc của tab về 0). Close không đổi tab
 *   hiện tại, nên Toggle mở lại giữ đúng tab trước khi đóng.
 * - Notify(tab) tăng số chưa đọc của tab; UnreadCount(tab) đọc số đó;
 *   TotalUnread cộng dồn mọi tab. UI hiển thị chấm đỏ theo số này.
 * - Sự kiện C# (TabChanged / OpenChanged) port sang callback kiểu MV:
 *   PXB_PhoneHub.onTabChanged(fn) / onOpenChanged(fn) (đăng ký nhiều
 *   callback được; gỡ bằng offTabChanged(fn) / offOpenChanged(fn)).
 *   Callback sống ở runtime, KHÔNG nằm trong save — lớp UI đăng ký lại
 *   sau mỗi lần load (xem install()).
 *
 * HÀNH VI ĐÃ GHI NHẬN (theo đúng C#, KHÔNG tự sửa — để GDD/PM xem lại):
 * - Notify đếm cả khi điện thoại đang đóng (không kiểm tra IsOpen):
 *   tin đến lúc đóng vẫn được đếm, mở ra sẽ thấy chấm đỏ.
 * - Open(tab) luôn gọi SelectTab nên luôn kích hoạt TabChanged, kể cả
 *   mở đúng tab đang hiển thị; SelectTab cũng luôn kích hoạt TabChanged
 *   kể cả chọn đúng tab hiện tại (code không kiểm tra tab có đổi không).
 * - Thứ tự kích hoạt khi Open: TabChanged trước, OpenChanged(true) sau.
 *
 * LỆCH PHÁT HIỆN GIỮA PhoneHub.cs VÀ GDD / DOCS (không bịa số mới):
 * - GDD Mục 2 viết "Sức khoẻ", PhoneHub.cs viết enum SucKhoe (Sức
 *   khỏe). Plugin dùng "Sức khỏe" theo C#; chỉ khác chính tả, không
 *   đổi nghĩa. GDD/PM chốt cách viết thì sửa đúng tên tab ở TABS.
 * - docs/architecture-nadia.md §6 #4 chốt "Mở bằng phím P / nút điện
 *   thoại" — PhoneHub.cs KHÔNG có binding phím hay nút nào (chỉ giữ
 *   trạng thái + điều hướng tab). Plugin này thêm hook phím P trong
 *   install() (chỉ chạy khi có core MV: gán Input.keyMapper[80] = "phone"
 *   rồi Scene_Map kiểm tra Input.isTriggered("phone") để Toggle).
 *   Nút điện thoại trên màn hình là việc của lớp UI (Scene_Map), không
 *   nằm trong plugin này.
 * - GDD Mục 2: "Điện thoại không thay thế thế giới — vẫn phải đi lại
 *   trong phố." Plugin này chỉ giữ trạng thái hub, không di chuyển
 *   nhân vật, không mở fast-travel — đúng ranh giới đó.
 * - PhoneHub.cs không có số cấu hình nào (không lương, không phí,
 *   không thời gian) nên plugin này không dùng PXB_Balance và không có
 *   số PROVISIONAL.
 *
 * Lưu: state sống trong $gameSystem.pxbPhoneHub nên đi theo save của MV
 * ($gameSystem vốn đã nằm trong save contents của core). Khi core MV
 * chưa có (repo hiện tại), logic thuần vẫn chạy và test được qua
 * module.exports; hàm install() trả false và không giả vờ đã móc save.
 *
 * Dùng trong event (khi có core MV):
 *   PXB_PhoneHub.open()                  // mở ở tab hiện tại
 *   PXB_PhoneHub.open("ban-do")          // mở thẳng tab Bản đồ
 *   PXB_PhoneHub.close()                 // đóng điện thoại
 *   PXB_PhoneHub.toggle()                // đóng ↔ mở (phím P gọi hàm này)
 *   PXB_PhoneHub.selectTab("viec-lam")   // true = đổi tab, false = tab sai
 *   PXB_PhoneHub.notify("cho")           // có tin mới ở tab Chợ
 *   PXB_PhoneHub.unreadCount("cho")      // số chưa đọc tab Chợ
 *   PXB_PhoneHub.totalUnread()           // tổng số chưa đọc mọi tab
 *   PXB_PhoneHub.onTabChanged(function(tab) { ... })
 *   PXB_PhoneHub.onOpenChanged(function(isOpen) { ... })
 * Plugin command (event thường / CommonEvent):
 *   PXB_PhoneHub Open [tabId]   — mở (không truyền tab: tab Danh bạ / Tin nhắn)
 *   PXB_PhoneHub Close          — đóng
 *   PXB_PhoneHub Toggle         — đóng ↔ mở
 *   PXB_PhoneHub SelectTab <tabId>
 *   PXB_PhoneHub Notify <tabId>
 */
(function () {
  "use strict";

  // 9 tab đúng thứ tự GDD Mục 2 / PhoneHub.cs TabOrder.
  // id kebab-case theo quy ước plugin PXB_* (vd PXB_Jobs dùng "ban-rong").
  var TABS = [
    { id: "danh-ba-tin-nhan", name: "Danh bạ / Tin nhắn" },
    { id: "ngan-hang",        name: "Ngân hàng" },
    { id: "ban-do",           name: "Bản đồ" },
    { id: "viec-lam",         name: "Việc làm" },
    { id: "cho",              name: "Chợ" },
    { id: "hoc-tap",          name: "Học tập" },
    { id: "suc-khoe",         name: "Sức khỏe" },
    { id: "xa-hoi",           name: "Xã hội" },
    { id: "cai-dat",          name: "Cài đặt" }
  ];

  var TAB_IDS = [];
  for (var i = 0; i < TABS.length; i++) TAB_IDS.push(TABS[i].id);

  var DEFAULT_TAB = TAB_IDS[0]; // "danh-ba-tin-nhan"

  function tabExists(tabId) {
    return TAB_IDS.indexOf(tabId) !== -1;
  }

  function tabName(tabId) {
    for (var i = 0; i < TABS.length; i++) {
      if (TABS[i].id === tabId) return TABS[i].name;
    }
    return null;
  }

  function tabList() {
    // Trả bản sao để caller không sửa được thứ tự chuẩn.
    var out = [];
    for (var i = 0; i < TABS.length; i++) {
      out.push({ id: TABS[i].id, name: TABS[i].name });
    }
    return out;
  }

  // --- Callback kiểu MV (thay cho event C# TabChanged / OpenChanged) ---
  // Callback sống ở runtime, không lưu vào $gameSystem (function không
  // serialize được) — lớp UI đăng ký lại sau mỗi lần load game.

  var _tabChangedCallbacks = [];
  var _openChangedCallbacks = [];

  function addCallback(list, fn) {
    if (typeof fn !== "function") return false;
    if (list.indexOf(fn) !== -1) return false; // không đăng ký trùng
    list.push(fn);
    return true;
  }

  function removeCallback(list, fn) {
    var idx = list.indexOf(fn);
    if (idx === -1) return false;
    list.splice(idx, 1);
    return true;
  }

  function fireCallbacks(list, arg) {
    // Chạy trên bản sao: callback được phép tự gỡ mình trong lúc chạy.
    var copy = list.slice();
    for (var i = 0; i < copy.length; i++) copy[i](arg);
  }

  function onTabChanged(fn) { return addCallback(_tabChangedCallbacks, fn); }
  function offTabChanged(fn) { return removeCallback(_tabChangedCallbacks, fn); }
  function onOpenChanged(fn) { return addCallback(_openChangedCallbacks, fn); }
  function offOpenChanged(fn) { return removeCallback(_openChangedCallbacks, fn); }

  // --- State (sống trong $gameSystem.pxbPhoneHub để vào save) ---

  function defaultState() {
    return {
      isOpen: false,
      currentTab: DEFAULT_TAB,
      unread: {} // số chưa đọc theo tabId; tab chưa notify thì không có key (= 0)
    };
  }

  // Dữ liệu dự phòng khi chưa có core MV (logic thuần vẫn test được).
  var fallbackState = defaultState();

  function state() {
    if (typeof $gameSystem !== "undefined" && $gameSystem) {
      if (!$gameSystem.pxbPhoneHub) {
        $gameSystem.pxbPhoneHub = defaultState();
      }
      return $gameSystem.pxbPhoneHub;
    }
    return fallbackState;
  }

  // Khởi tạo pxbPhoneHub trong $gameSystem (gọi khi new game).
  // Trả false khi chưa có $gameSystem — không giả vờ đã lưu được.
  function initInGameSystem() {
    if (typeof $gameSystem === "undefined" || !$gameSystem) return false;
    if (!$gameSystem.pxbPhoneHub) {
      $gameSystem.pxbPhoneHub = defaultState();
    }
    return true;
  }

  // --- Mở / đóng / đổi tab (port trung thực PhoneHub.cs) ---

  function isOpen() {
    return !!state().isOpen;
  }

  function currentTab() {
    return state().currentTab;
  }

  // Chọn tab. Trả false nếu tab không có trong TabOrder (không bao giờ
  // xảy ra với tab hợp lệ). Mở tab thì đánh dấu đã đọc tab đó
  // (UnreadCount về 0). Luôn kích hoạt TabChanged, kể cả chọn đúng tab
  // hiện tại — hành vi theo C#, xem @help.
  function selectTab(tabId) {
    if (!tabExists(tabId)) return false;
    var st = state();
    st.currentTab = tabId;
    st.unread[tabId] = 0; // Mở tab thì đánh dấu đã đọc.
    fireCallbacks(_tabChangedCallbacks, tabId);
    return true;
  }

  // Mở điện thoại ở tab cho trước (mặc định: tab Danh bạ / Tin nhắn,
  // khớp tham số mặc định PhoneTab.DanhBaTinNhan của PhoneHub.Open).
  // Luôn kích hoạt TabChanged (qua SelectTab) rồi OpenChanged(true).
  function open(tabId) {
    if (typeof tabId === "undefined" || tabId === null) tabId = DEFAULT_TAB;
    var st = state();
    st.isOpen = true;
    selectTab(tabId);
    fireCallbacks(_openChangedCallbacks, true);
    return true;
  }

  function close() {
    var st = state();
    st.isOpen = false;
    // Close không đổi CurrentTab — hành vi theo C#.
    fireCallbacks(_openChangedCallbacks, false);
    return true;
  }

  // Đang đóng thì mở lại ở tab hiện tại (giữ đúng tab trước khi đóng),
  // đang mở thì đóng. Khớp PhoneHub.Toggle dùng CurrentTab.
  function toggle() {
    if (isOpen()) close();
    else open(currentTab());
    return true;
  }

  // --- Tin chưa đọc (port trung thực PhoneHub.cs) ---

  // Notify đếm cả khi điện thoại đang đóng (không kiểm tra IsOpen) —
  // hành vi theo C#, xem @help. Trả false nếu tab sai.
  function notify(tabId) {
    if (!tabExists(tabId)) return false;
    var st = state();
    st.unread[tabId] = (st.unread[tabId] || 0) + 1;
    return true;
  }

  function unreadCount(tabId) {
    if (!tabExists(tabId)) return 0;
    return state().unread[tabId] || 0;
  }

  function totalUnread() {
    var total = 0;
    var unread = state().unread;
    for (var tabId in unread) {
      if (Object.prototype.hasOwnProperty.call(unread, tabId)) {
        total += unread[tabId] || 0;
      }
    }
    return total;
  }

  // --- Móc vào core MV ---

  // Phím P mở/đóng điện thoại — đã chốt ở architecture §6 #4.
  var PHONE_KEY_CODE = 80; // keyCode 80 = "P"
  var PHONE_KEY_NAME = "phone";

  // Guard chống móc trùng: install() chạy lúc load; gọi lại (vd test
  // gọi tay) không được wrap core lần nữa — wrap 2 lần sẽ kích hoạt
  // plugin command / phím P 2 lần cho 1 thao tác. Chỉ khóa khi lần
  // trước đã móc được core (hasCore true); chưa có core thì lần sau
  // vẫn thử lại được.
  var _installed = false;

  function install() {
    if (_installed) return true;
    var hasCore = false;
    if (typeof DataManager !== "undefined") {
      hasCore = true;
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
              $gameSystem.pxbPhoneHub) {
            // Điền lại field thiếu khi load save cũ / save sửa tay.
            var d = defaultState();
            var s = $gameSystem.pxbPhoneHub;
            for (var k in d) {
              if (typeof s[k] === "undefined") s[k] = d[k];
            }
            if (typeof s.unread !== "object" || s.unread === null) {
              s.unread = {};
            }
          }
        };
      }
    }
    // Phím P: gán keyMapper rồi Scene_Map kiểm tra mỗi khung.
    if (typeof Input !== "undefined" && Input &&
        typeof Input.keyMapper === "object" && Input.keyMapper) {
      Input.keyMapper[PHONE_KEY_CODE] = PHONE_KEY_NAME;
      hasCore = true;
    }
    if (typeof Scene_Map !== "undefined" && Scene_Map &&
        typeof Scene_Map.prototype.update === "function") {
      var _sceneMapUpdate = Scene_Map.prototype.update;
      Scene_Map.prototype.update = function () {
        _sceneMapUpdate.call(this);
        if (typeof Input !== "undefined" && Input &&
            typeof Input.isTriggered === "function" &&
            Input.isTriggered(PHONE_KEY_NAME)) {
          toggle();
        }
      };
      hasCore = true;
    }
    if (typeof Game_Interpreter !== "undefined" &&
        typeof Game_Interpreter.prototype.pluginCommand === "function") {
      var _pluginCommand = Game_Interpreter.prototype.pluginCommand;
      Game_Interpreter.prototype.pluginCommand = function (command, args) {
        _pluginCommand.call(this, command, args);
        if (command === "PXB_PhoneHub") {
          if (args[0] === "Open") {
            // Không truyền tab: open() mặc định Danh bạ / Tin nhắn,
            // khớp tham số mặc định của PhoneHub.Open trong C#.
            open(args[1]);
          } else if (args[0] === "Close") {
            close();
          } else if (args[0] === "Toggle") {
            toggle();
          } else if (args[0] === "SelectTab") {
            selectTab(args[1]);
          } else if (args[0] === "Notify") {
            notify(args[1]);
          }
        }
      };
      hasCore = true;
    }
    if (hasCore) _installed = true;
    return hasCore;
  }

  // Áp dụng hook ngay khi file load (quy ước MV: code plugin chạy lúc
  // load). Không có core thì install() trả false và không làm gì.
  install();

  var PXB_PhoneHub = {
    TABS: TABS,
    TAB_IDS: TAB_IDS,
    DEFAULT_TAB: DEFAULT_TAB,
    PHONE_KEY_CODE: PHONE_KEY_CODE,
    PHONE_KEY_NAME: PHONE_KEY_NAME,
    tabList: tabList,
    tabExists: tabExists,
    tabName: tabName,
    isOpen: isOpen,
    currentTab: currentTab,
    open: open,
    close: close,
    toggle: toggle,
    selectTab: selectTab,
    notify: notify,
    unreadCount: unreadCount,
    totalUnread: totalUnread,
    onTabChanged: onTabChanged,
    offTabChanged: offTabChanged,
    onOpenChanged: onOpenChanged,
    offOpenChanged: offOpenChanged,
    initInGameSystem: initInGameSystem,
    install: install
  };

  if (typeof module !== "undefined" && module.exports) {
    module.exports = PXB_PhoneHub;
  } else if (typeof window !== "undefined") {
    window.PXB_PhoneHub = PXB_PhoneHub;
  }
})();

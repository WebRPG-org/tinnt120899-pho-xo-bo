// Phố Xô Bồ — js/main.js (RPG Maker MV).
// Thứ tự MV: PluginManager.setup($plugins) rồi SceneManager.run(Scene_Boot)
// (docs/architecture-nadia.md §1.2). Guard window: file này chỉ chạy trong
// trình duyệt — khi require bằng node để kiểm tra cú pháp thì không chạy.
if (typeof window !== "undefined") {
  PluginManager.setup($plugins);
  window.onload = function () {
    SceneManager.run(Scene_Boot);
  };
}

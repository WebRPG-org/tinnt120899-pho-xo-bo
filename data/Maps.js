// Phố Xô Bồ — dữ liệu map dạng tile (Maps), kiểu RPG Maker MV (data/Map001.json).
// Lưới tile 12x9. Ký hiệu: '.' đường đi được · '#' tường/nhà (chặn) · 'S' sạp
// (chặn) · 'C' Góc Chế Tạo (phải đứng gần mới chế được — như Native Shrine của
// Nadia) · 'T' cổng chuyển khu · 'G' cỏ/cây · 'H' cửa nhà (chặn, NPC đứng cạnh).
// Hotspot: nhặt 1 lần/ngày game, đúng khung mới có đồ (sparkle của Nadia).
// NPC: vị trí theo tile, khớp Actors.js. Transfer: đi tới ô T là sang khu kia.
window.PHO_MAPS = {
  maps: [
    {
      id: 1, name: "Xóm Trọ Cũ",
      grid: [
        "############",
        "#....#....G#",
        "#.C..#.....#",
        "#....#..G..#",
        "#....T.....#",
        "#..G...#...#",
        "#......#H..#",
        "#....G.....#",
        "############"
      ],
      npcs: ["co-tu", "ban-than"],
      hotspots: [
        { id: "hs-tro-toi",  name: "Cuối hẻm",    frame: "Tối",   item: "chai-nhua", qty: 2, x: 10, y: 3, rare: false },
        { id: "hs-hem-sang", name: "Góc hẻm",     frame: "Sáng",  item: "vai-vun",   qty: 1, x: 2,  y: 1, rare: false }
      ],
      craftSpots: [{ x: 2, y: 2, name: "Góc Chế Tạo trong phòng trọ" }],
      transfers: [{ x: 5, y: 4, toMap: 2, toX: 5, toY: 4, label: "Ra Chợ Đầu Mối" }]
    },
    {
      id: 2, name: "Chợ Đầu Mối",
      grid: [
        "############",
        "#.S..S....G#",
        "#..........#",
        "#..G...S...#",
        "#....T.....#",
        "#.S....C...#",
        "#......#...#",
        "#....G.....#",
        "############"
      ],
      npcs: ["chi-le", "anh-hai"],
      hotspots: [
        { id: "hs-cho-sang",  name: "Sạp chị Lệ",   frame: "Sáng",  item: "la-chuoi", qty: 2, x: 3, y: 1, rare: false },
        { id: "hs-cho-chieu", name: "Góc phế liệu", frame: "Chiều", item: "sat-vun",  qty: 1, x: 10, y: 2, rare: false },
        { id: "hs-cho-dem",   name: "Góc tối cuối chợ", frame: "Tối", item: "sat-vun", qty: 1, x: 1, y: 6, rare: true, needTool: "den-soi" }
      ],
      craftSpots: [{ x: 7, y: 5, name: "Góc Chế Tạo ở sạp chợ" }],
      transfers: [{ x: 5, y: 4, toMap: 1, toX: 5, toY: 4, label: "Về Xóm Trọ Cũ" }]
    }
  ]
};

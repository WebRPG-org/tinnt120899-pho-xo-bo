// Phố Xô Bồ — GameManager (MonoBehaviour mỏng, C2 scene slice)
// Lớp Unity duy nhất giữ trạng thái chơi; mọi luật vẫn nằm ở logic thuần C#
// (Stats / TimeSystem / District / Exploration / Crafting / PhoneHub / Inventory / Jobs)
// để còn test được ngoài Unity. Không hardcode số chốt — dùng GameBalance / TimeSystem.
// Bám sát Treasure of Nadia (docs/nadia-reference.md §1):
// vòng lặp Khám phá → Thu thập → Chế tạo → Mở khóa; NPC dẫn đường thay Soul Crystal;
// điện thoại là hub nhưng KHÔNG thay thế việc đi lại trong phố.
// CHƯA MỞ/BUILD ĐƯỢC trên VM này (không có Unity) — scene chỉ được kiểm tra ở mức YAML + cross-ref.
using System;
using System.Collections.Generic;
using UnityEngine;

namespace PhoXoBo
{
    /// <summary>
    /// Điều phối 1 phiên chơi slice: khởi tạo nhân vật, chạy vòng ngày
    /// (1 ngày game = 30 phút thật, 3 khung Sáng/Chiều/Tối — TimeSystem),
    /// giữ túi đồ / nguyên liệu / khu đã mở, cầu nối cho các View gọi vào.
    /// </summary>
    public class GameManagerBehaviour : MonoBehaviour
    {
        public static GameManagerBehaviour Instance { get; private set; }

        // PROVISIONAL — xuất thân khởi đầu cân bằng (100/100/100, tổng = trần 300).
        // Gacha xuất thân đổi phân bổ (xem Stats.cs) sẽ gắn vào đây khi làm màn gacha.
        [SerializeField] private int startThe = 100;
        [SerializeField] private int startTri = 100;
        [SerializeField] private int startTam = 100;
        [SerializeField] private int startingDistrictId = 1; // 1 = Xóm Trọ Cũ

        // PROVISIONAL — mục tiêu hiện tại để NPC dẫn đường gợi ý theo (GuideHint).
        [SerializeField] private string currentGoal = "làm xong quest đầu tiên ở Xóm Trọ Cũ";

        public Stats PlayerStats { get; private set; }
        public PhoneHub Phone { get; } = new PhoneHub();
        public Inventory Bag { get; } = new Inventory();
        public Dictionary<string, int> Materials { get; } = new Dictionary<string, int>();
        public HashSet<string> VisitedToday { get; } = new HashSet<string>();
        public HashSet<int> UnlockedDistricts { get; } = new HashSet<int>();

        public int GameDay { get; private set; } = 1;
        public int CurrentDistrictId { get; private set; }
        public string CurrentGoal
        {
            get => currentGoal;
            set => currentGoal = value;
        }

        public TimeFrame CurrentFrame { get; private set; } = TimeFrame.Sang;

        private float _elapsedInDaySeconds; // Giây thật đã trôi trong ngày game hiện tại.

        private void Awake()
        {
            if (Instance != null && Instance != this)
            {
                Destroy(gameObject);
                return;
            }
            Instance = this;

            PlayerStats = new Stats(startThe, startTri, startTam);
            CurrentDistrictId = startingDistrictId;
            foreach (var id in Exploration.FastTravelUnlockedSlice)
                UnlockedDistricts.Add(id);
        }

        private void Update()
        {
            _elapsedInDaySeconds += Time.deltaTime;

            // Hết 1 ngày game (30 phút thật) thì sang ngày mới: reset lượt khám phá
            // trong ngày (kiểu Nadia: quay lại địa điểm cũ ngày sau có đồ mới).
            // TimeSystem.CurrentFrame không tự wrap quá 30 phút nên wrap ở đây
            // trước khi gọi — không sửa logic thuần trong lượt này.
            var dayLength = (float)TimeSystem.GameDayLength.TotalSeconds;
            while (_elapsedInDaySeconds >= dayLength)
            {
                _elapsedInDaySeconds -= dayLength;
                GameDay++;
                Exploration.NewGameDay(VisitedToday);
            }

            var frame = TimeSystem.CurrentFrame(TimeSpan.FromSeconds(_elapsedInDaySeconds));
            if (frame != CurrentFrame)
            {
                Bag.EndFrame(CurrentFrame); // Buff tạm 1 khung hết hiệu lực.
                CurrentFrame = frame;
            }
        }

        /// <summary>Khám phá 1 hotspot: nhặt nguyên liệu (1 lần / 1 ngày game). Trả false nếu đã nhặt hôm nay.</summary>
        public bool ExploreHotspot(string hotspotId) =>
            Exploration.Explore(hotspotId, GameDay, VisitedToday, Materials);

        /// <summary>Chế 1 món ở Góc Chế Tạo. Trả ResultId, hoặc null nếu thiếu nguyên liệu / sai công thức.</summary>
        public string Craft(string recipeId)
        {
            var recipe = Crafting.Get(recipeId);
            if (recipe == null) return null;
            return Crafting.Craft(recipe, Materials);
        }

        /// <summary>Fast travel — chỉ tới khu đã mở (kiểu Nadia: ô xanh đi được / cửa đỏ chưa mở).</summary>
        public bool FastTravel(int districtId)
        {
            if (!Exploration.CanFastTravel(districtId, UnlockedDistricts)) return false;
            CurrentDistrictId = districtId;
            return true;
        }

        /// <summary>NPC dẫn đường gợi ý bằng lời thoại theo khu đang đứng (thay Soul Crystal của Nadia).</summary>
        public string GetGuideHint() => GuideHint.HintForDistrict(CurrentDistrictId, CurrentGoal);

        /// <summary>Số nguyên liệu đang có (để UI / Sổ Tay hiển thị).</summary>
        public int MaterialCount(string materialId) =>
            Materials.TryGetValue(materialId, out var count) ? count : 0;
    }
}

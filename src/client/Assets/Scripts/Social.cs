// Phố Xô Bồ — Hệ xã hội (Mục 8 đã chốt, GDD)
// Ưu tiên: 1) Người yêu / Vợ – chồng, 2) Bạn thân / Hội bạn, 3) Gia đình,
// 4) Công ty / Đối tác làm ăn. Chơi 1 mình được nhưng chậm hơn, không có
// ending gia đình / cặp đôi.
// Bám Nadia (docs/nadia-reference.md #7, #9): quan hệ gắn nhân vật —
// quest giúp NPC đang khủng hoảng, NPC dẫn đường gợi ý bằng lời thoại,
// không phải menu quan hệ khô khan. KHÔNG lấy nội dung người lớn / harem.
// Số chốt dùng đúng GameBalance: bỏ bê 7 ngày game → thân thiết giảm;
// được hỗ trợ: +20% EXP; solo chậm hơn 30–50%. Mọi ngưỡng khác (thân thiết
// cần để cưới, mức giảm thân thiết mỗi lần bỏ bê, tối đa quan hệ sâu)
// là số cấu hình slice, PROVISIONAL — sửa ở đây khi GDD chốt.
using System;
using System.Collections.Generic;

namespace PhoXoBo
{
    public enum RelationshipKind
    {
        Lover,        // Người yêu
        Spouse,       // Vợ / chồng
        BestFriend,   // Bạn thân (tối đa 1)
        FriendGroup,  // Hội bạn (nhóm 3–5 người)
        Parent,       // Cha / mẹ
        Child,        // Con cái
        CompanyPartner, // Đối tác làm ăn / công ty
    }

    public enum RelationshipStage
    {
        QuenBiet,   // mới quen
        ThanThiet,  // thân thiết
        HenHo,      // đang hẹn hò (chỉ Lover)
        DinhHon,    // đã đính hôn (chỉ Lover)
        Cuoi,       // đã cưới (chỉ Spouse)
        TanRa,      // đã tan / ly hôn — giữ lại để tính lịch sử, không tính là quan hệ sâu
    }

    /// <summary>Một quan hệ. Thân thiết 0..100. LastInteractionGameDay là ngày game gặp / nhắn lần cuối.</summary>
    public sealed class Relationship
    {
        public string PersonId { get; }
        public string DisplayName { get; }
        public RelationshipKind Kind { get; }
        public RelationshipStage Stage { get; private set; }
        public int Closeness { get; private set; } // 0..100
        public int LastInteractionGameDay { get; private set; }

        public Relationship(string personId, string displayName, RelationshipKind kind, int startGameDay)
        {
            PersonId = personId;
            DisplayName = displayName;
            Kind = kind;
            Stage = RelationshipStage.QuenBiet;
            Closeness = 20; // PROVISIONAL — thân thiết khởi đầu khi mới quen.
            LastInteractionGameDay = startGameDay;
        }

        public bool IsDeep =>
            Stage != RelationshipStage.TanRa &&
            (Kind == RelationshipKind.Lover || Kind == RelationshipKind.Spouse ||
             Kind == RelationshipKind.BestFriend || Kind == RelationshipKind.Parent ||
             Kind == RelationshipKind.Child);

        public void Interact(int gameDay, int closenessGain = 5)
        {
            // PROVISIONAL — mỗi lần gặp / nhắn tăng 5 thân thiết (chưa chốt).
            LastInteractionGameDay = gameDay;
            Closeness = Math.Clamp(Closeness + closenessGain, 0, 100);
        }

        /// <summary>
        /// Bỏ bê: quá GameBalance.NeglectDaysToDropCloseness (7) ngày game không tương tác
        /// thì thân thiết giảm. Mức giảm 10 / mỗi 7 ngày là PROVISIONAL — chỉ ngưỡng 7 ngày là số chốt.
        /// </summary>
        public int ApplyNeglect(int currentGameDay)
        {
            var daysIdle = currentGameDay - LastInteractionGameDay;
            if (daysIdle < GameBalance.NeglectDaysToDropCloseness) return 0;
            var steps = daysIdle / GameBalance.NeglectDaysToDropCloseness;
            var drop = steps * 10; // PROVISIONAL
            Closeness = Math.Clamp(Closeness - drop, 0, 100);
            return drop;
        }

        public bool AdvanceStage(RelationshipStage next)
        {
            // Hẹn hò → đính hôn → cưới: cần thân thiết đủ cao. Ngưỡng là PROVISIONAL.
            if (next == RelationshipStage.HenHo && Closeness < 50) return false;
            if (next == RelationshipStage.DinhHon && (Stage != RelationshipStage.HenHo || Closeness < 70)) return false;
            if (next == RelationshipStage.Cuoi && (Stage != RelationshipStage.DinhHon || Closeness < 80)) return false;
            Stage = next;
            return true;
        }

        public void BreakUp()
        {
            Stage = RelationshipStage.TanRa;
            Closeness = 0;
        }
    }

    /// <summary>
    /// Sổ quan hệ của người chơi. Chỉ duy trì được 2–3 quan hệ sâu trong 3 khung/ngày
    /// (GDD Mục 8) — giới hạn 3 là PROVISIONAL, theo đúng khoảng 2–3 đã chốt.
    /// </summary>
    public sealed class SocialBook
    {
        public const int MaxDeepRelationships = 3; // PROVISIONAL — khoảng 2–3 đã chốt
        public const int MaxGroupMembers = 5;      // Hội bạn 3–5 người (GDD Mục 8)
        public const int MinGroupMembers = 3;

        private readonly Dictionary<string, Relationship> _relations = new();
        private readonly HashSet<string> _marriages = new(); // PersonId đã cưới (Kind Lover → Spouse)

        public IReadOnlyCollection<Relationship> All => _relations.Values;

        public int DeepCount
        {
            get
            {
                var count = 0;
                foreach (var r in _relations.Values)
                    if (r.IsDeep) count++;
                return count;
            }
        }

        public bool HasBestFriend
        {
            get
            {
                foreach (var r in _relations.Values)
                    if (r.Kind == RelationshipKind.BestFriend && r.Stage != RelationshipStage.TanRa) return true;
                return false;
            }
        }

        /// <summary>Thêm quan hệ mới. Trả false nếu đã đủ 3 quan hệ sâu, hoặc đã có bạn thân khác.</summary>
        public bool Add(Relationship rel)
        {
            if (_relations.ContainsKey(rel.PersonId)) return false;
            if (rel.IsDeep && DeepCount >= MaxDeepRelationships) return false;
            if (rel.Kind == RelationshipKind.BestFriend && HasBestFriend) return false;
            _relations[rel.PersonId] = rel;
            return true;
        }

        public Relationship? Get(string personId) =>
            _relations.TryGetValue(personId, out var rel) ? rel : null;

        /// <summary>Có quan hệ thân thiết đang hỗ trợ mình không (thân thiết ≥ 50, PROVISIONAL).</summary>
        public bool HasSupporter
        {
            get
            {
                foreach (var r in _relations.Values)
                    if (r.IsDeep && r.Closeness >= 50) return true;
                return false;
            }
        }

        /// <summary>
        /// EXP nhận được khi được người thân hỗ trợ: +20% (GameBalance.SupportedExpBonusPercent, đã chốt).
        /// Solo (không có supporter): chậm hơn 30–50% (GameBalance) — dùng điểm giữa 40% là
        /// PROVISIONAL, nằm trong khoảng đã chốt; sửa 1 chỗ duy nhất ở đây khi chốt số.
        /// </summary>
        public int ApplySupportBonus(int baseExp)
        {
            if (HasSupporter)
                return baseExp * (100 + GameBalance.SupportedExpBonusPercent) / 100;
            return baseExp;
        }

        public int ApplySoloPenalty(int baseExp)
        {
            if (HasSupporter) return baseExp;
            const int soloPenaltyPercent = 40; // PROVISIONAL — trong khoảng 30–50% đã chốt
            return baseExp * (100 - soloPenaltyPercent) / 100;
        }

        /// <summary>
        /// Hội bạn tan nếu 7 ngày game không họp (PROVISIONAL — lấy cùng ngưỡng bỏ bê 7 ngày).
        /// Trả true nếu nhóm đã tan.
        /// </summary>
        public bool CheckGroupDissolved(Relationship group, int currentGameDay)
        {
            if (group.Kind != RelationshipKind.FriendGroup) return false;
            return currentGameDay - group.LastInteractionGameDay >= GameBalance.NeglectDaysToDropCloseness;
        }

        /// <summary>Ly hôn: chia tài sản — việc chia tiền làm ở Economy.SplitAssets; ở đây chỉ đổi trạng thái.</summary>
        public bool Divorce(string personId)
        {
            var rel = Get(personId);
            if (rel == null || (rel.Kind != RelationshipKind.Spouse && rel.Stage != RelationshipStage.Cuoi)) return false;
            rel.BreakUp();
            _marriages.Remove(personId);
            return true;
        }

        public void RecordMarriage(string personId) => _marriages.Add(personId);
        public bool IsMarriedTo(string personId) => _marriages.Contains(personId);
    }
}

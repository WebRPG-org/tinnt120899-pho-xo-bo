// Phố Xô Bồ — Hệ chỉ số nhân vật (Mục 4 đã chốt)
// 3 gốc: Đỏ Thể / Xanh Trí / Vàng Tâm. Trộn ra Tím Kỷ / Cam Dũng / Lục Sáng + Trắng An Yên.
// Quy tắc: có trần tổng, không ai max hết; nâng một chỉ số phải đánh đổi chỉ số khác.
// Tiền / Danh vọng / EXP là tài nguyên, KHÔNG phải chỉ số gốc.
using System;

namespace PhoXoBo
{
    /// <summary>3 chỉ số gốc. Giá trị từng chỉ số: 0..100.</summary>
    public enum BaseStat { The, Tri, Tam } // Thể (Đỏ), Trí (Xanh), Tâm (Vàng)

    /// <summary>Chỉ số trộn, chỉ tính khi đủ điều kiện gốc.</summary>
    public enum MixedStat { Ky, Dung, Sang, AnYen } // Kỷ (Tím), Dũng (Cam), Sáng (Lục), An Yên (Trắng)

    public sealed class Stats
    {
        // CẢNH BÁO QC: TotalCap = 300 là SỐ VÍ DỤ, CHƯA CHỐT — plan chỉ chốt "có trần tổng",
        // chưa chốt con số. Đổi trần thì sửa ở đây + docs/stats.md + docs/gdd.md cùng lúc.
        // Không hardcode 300 ở file khác.
        public const int TotalCap = 300; // PROVISIONAL — cần chủ chốt
        public const int StatMax = 100;  // PROVISIONAL — cần chủ chốt cùng TotalCap

        public int The { get; private set; } // Đỏ — Thể
        public int Tri { get; private set; } // Xanh — Trí
        public int Tam { get; private set; } // Vàng — Tâm

        public Stats(int the, int tri, int tam)
        {
            The = Math.Clamp(the, 0, StatMax);
            Tri = Math.Clamp(tri, 0, StatMax);
            Tam = Math.Clamp(tam, 0, StatMax);
            if (Total != TotalCap)
                throw new ArgumentException($"Tổng chỉ số khởi đầu phải bằng trần {TotalCap} (gacha chỉ đổi phân bổ, không đổi tổng).");
        }

        public int Total => The + Tri + Tam;

        // Chỉ số trộn = trung bình 2 gốc (làm tròn xuống). An Yên chỉ tính khi 3 gốc cân bằng.
        public int Ky => (The + Tri) / 2;   // Tím — Kỷ
        public int Dung => (The + Tam) / 2;  // Cam — Dũng
        public int Sang => (Tri + Tam) / 2;  // Lục — Sáng
        // PROVISIONAL — ngưỡng cân bằng ±10 là số tạm, chưa chốt; cần chủ chốt cùng TotalCap.
        public int AnYen => Math.Abs(The - Tri) <= 10 && Math.Abs(Tri - Tam) <= 10
            ? (The + Tri + Tam) / 3 : 0;     // Trắng — An Yên, chỉ khi cân bằng

        /// <summary>Tăng 1 chỉ số phải giảm 1 chỉ số khác cùng lượng (đánh đổi). Trả false nếu không hợp lệ.</summary>
        public bool Train(BaseStat up, BaseStat down, int amount)
        {
            if (up == down || amount <= 0) return false;
            if (Get(down) - amount < 0 || Get(up) + amount > StatMax) return false;
            Set(up, Get(up) + amount);
            Set(down, Get(down) - amount);
            return true;
        }

        private int Get(BaseStat s) => s switch { BaseStat.The => The, BaseStat.Tri => Tri, _ => Tam };
        private void Set(BaseStat s, int v)
        {
            switch (s) { case BaseStat.The: The = v; break; case BaseStat.Tri: Tri = v; break; default: Tam = v; break; }
        }
    }
}

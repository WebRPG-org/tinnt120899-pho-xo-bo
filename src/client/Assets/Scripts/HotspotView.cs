// Phố Xô Bồ — Hotspot lấp lánh trên bản đồ isometric (MonoBehaviour mỏng, C2)
// Bám sát Treasure of Nadia (docs/nadia-reference.md §1 hàng 2): hotspot TO,
// lấp lánh, nhìn là biết chạm được — KHÔNG rà từng pixel. Quay lại ngày sau
// có vật mới (Exploration.Explore: 1 lần / 1 ngày game). Hotspot ẩn chỉ hiện
// khi có Đèn Soi bậc cao — bản slice này chưa có hotspot ẩn, chỉ ghi chú.
// Visual hiện tại là hình khối/màu tạm do code tạo lúc chạy (chưa có art thật,
// assets/ đang trống — art chỉ dùng placeholder CC0, xem docs/art-assets.md §3).
// CHƯA MỞ/BUILD ĐƯỢC trên VM này (không có Unity).
using System.Collections.Generic;
using UnityEngine;

namespace PhoXoBo
{
    /// <summary>Điểm khám phá trong thế giới. Gắn hotspotId trong Inspector / scene.</summary>
    public class HotspotView : MonoBehaviour
    {
        // Id phải có trong Exploration.Hotspots (vd: hs-tro-toi, hs-cho-sang).
        [SerializeField] private string hotspotId = "hs-tro-toi";

        // PROVISIONAL — kích thước chạm / độ sáng, chưa chốt; đổi khi test trên máy thật.
        [SerializeField] private float sparkleBaseSize = 0.6f;
        [SerializeField] private float colliderRadius = 1.2f;

        public string HotspotId => hotspotId;
        public Hotspot Hotspot => Exploration.Get(hotspotId);

        // Màu Vàng Tâm #E0A800 (palette lock, docs/art-assets.md §0).
        private static readonly Color SparkleColor = new Color(0.878f, 0.659f, 0f);

        private static readonly List<HotspotView> AllViews = new List<HotspotView>();

        private GameObject _sparkle;
        private Renderer _sparkleRenderer;
        private Material _sparkleMaterial;

        /// <summary>Hotspot gần 1 vị trí nhất trong tầm cho trước (để phím E tương tác).</summary>
        public static HotspotView Nearest(Vector3 position, float range)
        {
            HotspotView nearest = null;
            var best = float.MaxValue;
            foreach (var view in AllViews)
            {
                if (view == null || !view.isActiveAndEnabled) continue;
                var d = Vector3.Distance(position, view.transform.position);
                if (d <= range && d < best)
                {
                    best = d;
                    nearest = view;
                }
            }
            return nearest;
        }

        private void Awake()
        {
            AllViews.Add(this);
            // Vùng chạm rộng để ngón tay chạm được (tối thiểu 44×44 pt trên mobile — xem docs/art-assets.md §0).
            var collider = gameObject.AddComponent<SphereCollider>();
            collider.isTrigger = true;
            collider.radius = colliderRadius;
        }

        private void OnDestroy() => AllViews.Remove(this);

        private void Start()
        {
            if (Hotspot == null)
            {
                Debug.LogWarning($"[HotspotView] hotspotId '{hotspotId}' không có trong Exploration.Hotspots — tắt view này.");
                enabled = false;
                return;
            }
            CreateSparkleVisual();
        }

        private void Update()
        {
            if (_sparkle == null) return;
            // Nhấp nháy kiểu Nadia: to dần / nhỏ dần theo nhịp sin.
            var pulse = 0.85f + 0.15f * Mathf.Sin(Time.time * 3f);
            _sparkle.transform.localScale = Vector3.one * sparkleBaseSize * pulse;
            // Khung tốt của hotspot thì sáng rõ nhất; đã nhặt hôm nay thì mờ đi.
            var gm = GameManagerBehaviour.Instance;
            var collectedToday = gm != null && gm.VisitedToday.Contains(hotspotId);
            var isBestFrame = gm != null && Hotspot.BestFrame == gm.CurrentFrame;
            var brightness = collectedToday ? 0.25f : isBestFrame ? 1.5f : 0.8f;
            if (_sparkleMaterial != null)
                _sparkleMaterial.SetColor("_EmissionColor", SparkleColor * brightness);
        }

        /// <summary>Chạm vào hotspot: nhặt nguyên liệu qua GameManager (1 lần / 1 ngày game).</summary>
        public bool Interact()
        {
            var gm = GameManagerBehaviour.Instance;
            if (gm == null || Hotspot == null) return false;
            var ok = gm.ExploreHotspot(hotspotId);
            if (ok)
                Debug.Log($"[HotspotView] Nhặt {Hotspot.MaterialId} x{Hotspot.AmountPerVisit} ở '{Hotspot.Name}'.");
            return ok;
        }

        // Hình khối tạm thay art thật: quả cầu vàng lấp lánh nổi trên mặt đất.
        // Khi có sprite CC0 thì thay bằng SpriteRenderer + sprite, giữ lại logic nhấp nháy.
        private void CreateSparkleVisual()
        {
            _sparkle = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            _sparkle.name = "Sparkle (tam — chua co art)";
            _sparkle.transform.SetParent(transform, false);
            _sparkle.transform.localPosition = new Vector3(0f, 0.6f, 0f);
            _sparkle.transform.localScale = Vector3.one * sparkleBaseSize;
            var ownCollider = _sparkle.GetComponent<Collider>();
            if (ownCollider != null) Destroy(ownCollider);

            _sparkleRenderer = _sparkle.GetComponent<Renderer>();
            _sparkleMaterial = new Material(Shader.Find("Standard"));
            _sparkleMaterial.color = SparkleColor;
            _sparkleMaterial.SetColor("_EmissionColor", SparkleColor);
            _sparkleMaterial.EnableKeyword("_EMISSION");
            _sparkleRenderer.material = _sparkleMaterial;
        }
    }
}

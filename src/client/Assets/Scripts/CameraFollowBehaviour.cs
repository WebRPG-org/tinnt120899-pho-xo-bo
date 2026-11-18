// Phố Xô Bồ — Camera theo nhân vật (MonoBehaviour mỏng, C2)
// GIẢI PHÁP TẠM cho tới khi gắn Cinemachine trong Editor: camera giữ góc
// isometric đã lock (X ~30° / Y 45°, orthographic) và lerp theo Player.
// Setup Cinemachine đã chốt (xem Scripts/README.md): package com.unity.cinemachine
// 2.9.7 đã có trong Packages/manifest.json — trong Editor gắn CinemachineBrain
// lên Main Camera + CinemachineVirtualCamera (Follow = Player, Lens Orthographic
// Size 5, Body = Framing Transposer), rồi TẮT component này đi. Không tự bịa
// GUID script của package trong file .unity (GUID sai sẽ thành Missing Script).
// CHƯA MỞ/BUILD ĐƯỢC trên VM này (không có Unity).
using UnityEngine;

namespace PhoXoBo
{
    /// <summary>Camera lerp theo target, giữ nguyên góc xoay isometric. Gắn lên Main Camera.</summary>
    public class CameraFollowBehaviour : MonoBehaviour
    {
        [SerializeField] private Transform target; // Để trống: tự tìm PlayerController lúc chạy.
        [SerializeField] private Vector3 offset = new Vector3(0f, 10f, -10f); // Khớp vị trí camera trong scene slice.
        [SerializeField] private float smooth = 5f; // PROVISIONAL — độ mượt theo dõi, chốt khi test trên máy thật.

        private void Start()
        {
            if (target == null)
            {
                var player = FindObjectOfType<PlayerController>();
                if (player != null) target = player.transform;
            }
            if (target != null)
                transform.position = target.position + offset;
        }

        private void LateUpdate()
        {
            if (target == null) return;
            var desired = target.position + offset;
            var t = 1f - Mathf.Exp(-smooth * Time.deltaTime);
            transform.position = Vector3.Lerp(transform.position, desired, t);
            // Không xoay camera ở đây — góc isometric (30° X / 45° Y) đã lock trong scene.
        }
    }
}
